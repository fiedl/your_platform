concern :DagLinkRepair do
  
  class_methods do
    
    # This starts all automatic dag link repair operations.
    #
    def repair
      RedundantLinkRepairer.scan_and_repair
    end
    
    class RedundantLinkRepairer
      
      def self.scan_and_repair
        self.new.scan_and_repair
      end
      
      def scan_and_repair
        mute_sql_log
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
  end
end