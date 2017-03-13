concern :DagLinkRepair do

  included do
    # If there are some inconsistencies in the DAG, correct them on the fly
    # instead of raising an error in the validator.
    #
    before_validation {
      self.internal_count = 1 if (not self.direct?) && (self.count < 1)
    }
  end

  class_methods do

    # This starts all automatic dag link repair operations.
    #
    def repair
      delete_links_without_edges
      delete_redundant_indirect_links
      recalculate_indirect_counts
    end

    def delete_links_without_edges
      print "\n\nDeleting links without ancestor or descendant.\n".blue
      p DagLink.where(ancestor_id: nil).delete_all
      p DagLink.where(ancestor_type: nil).delete_all
      p DagLink.where(descendant_id: nil).delete_all
      p DagLink.where(descendant_type: nil).delete_all
    end

    def delete_redundant_indirect_links
      RedundantLinkRepairer.scan_and_repair
    end

    def recalculate_indirect_counts
      LinkCountRepairer.repair
    end

    class RedundantLinkRepairer

      def self.scan_and_repair
        self.new.scan_and_repair
      end

      def scan_and_repair
        mute_sql_log
        delete_links_without_edges
        scan
        delete_redundant_links
        recalculate_links
        print "\n\nFinished.\n".blue
        unmute_sql_log
      end

      def mute_sql_log
        @old_log_level = ActiveRecord::Base.logger.level
        ActiveRecord::Base.logger.level = 1
      end
      def unmute_sql_log
        ActiveRecord::Base.logger.level = @old_log_level
      end

      # There are cases when an indirect membership is represented by multiple dag links
      # by error. We don't know how those issues arise, yet. This method scans for such
      # occurances.
      #
      # Example:
      #
      #   Alle Amtsträger
      #         |-------- Alle Seniores -------.
      #         |                              |
      #         |                              |
      #         |------ Alle Admins ------- User
      #
      # In this example, the link between "Alle Amtsträger" and "User" should be one
      # DagLink(direct: false, count: 2). But, by error, there are two DagLink objects.
      #
      def scan
        @occurances = []
        print "Scanning for redundant links.\n".blue
        DagLink.where(direct: false).each do |link|
          redundant_links = DagLink.where(
            ancestor_type: link.ancestor_type, ancestor_id: link.ancestor_id,
            descendant_type: link.descendant_type, descendant_id: link.descendant_id
          )
          if redundant_links.count > 1
            @occurances << redundant_links
            print "DATA CORRUPTION: REDUNDANT INDIRECT LINKS: #{redundant_links.inspect}\n\n".red
          else
            print ".".green
          end
        end
        return @occurances
      end

      def delete_redundant_links
        print "\n\nRepairing redundant links.\n".blue
        @occurances.each do |redundant_links|
          redundant_links[1..-1].each do |redundant_link| # all links but the first, which is the original one
            redundant_link.delete
            print ".".blue
          end
        end
      end

      def recalculate_links
        print "\n\nRecalculating affected indirect validity ranges.\n".blue
        @occurances.each do |redundant_links|
          original_link = redundant_links[0].becomes UserGroupMembership
          original_link.recalculate_validity_range_from_direct_memberships
          original_link.save
          print ".".blue
        end
      end
    end

    class LinkCountRepairer

      def self.repair
        print "\n\nRecalculating counts of all #{DagLink.where(direct: false).count} indirect links.\n".blue
        DagLink.where(direct: false).find_each do |link|
          self.new(link).repair
        end
      end

      def initialize(dag_link)
        @dag_link = dag_link
      end

      def repair
        @dag_link.internal_count = recalculated_count
        if @dag_link.save
          print "*".blue
        else
          print ".".green
        end
      end

      def ancestor
        @dag_link.ancestor
      end

      def descendant
        @dag_link.descendant
      end

      def recalculated_count
        pages_count + groups_count + events_count + users_count
      end

      def pages_count
        abstract_count(:descendant_pages, 'Page')
      end

      def groups_count
        abstract_count(:descendant_groups, 'Group')
      end

      def events_count
        abstract_count(:descendant_events, 'Event')
      end

      def users_count
        abstract_count(:descendant_users, 'User')
      end

      def workflows_count
        abstract_count(:descendant_workflows, 'Workflow')
      end

      def projects_count
        abstract_count(:descendant_projects, 'Project')
      end

      def abstract_count(descendants_method_name, type_name)
        if ancestor && ancestor.respond_to?(descendants_method_name)
          DagLink
            .where(descendant_id: @dag_link.descendant_id, descendant_type: @dag_link.descendant_type)
            .where(ancestor_id: ancestor.send(descendants_method_name).pluck(:id), ancestor_type: type_name)
            .where(direct: true)
            .count
        else
          0
        end
      end

    end
  end
end