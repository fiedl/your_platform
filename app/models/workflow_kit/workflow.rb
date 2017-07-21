module WorkflowKit
  class Workflow < ApplicationRecord
    self.table_name = "workflow_kit_workflows"

    has_many :steps, dependent: :destroy

    extend WorkflowKit::Parameterable
    has_many_parameters

    def execute( params = {} )
      params = {} unless params
      params = params.merge( self.parameters_to_hash ) if self.parameters.count > 0
      ApplicationRecord.transaction do
        self.steps.collect do |step|
          step.execute( params )
        end
      end
    end

    def steps
      super.order( :sequence_index ).order( :created_at )
    end


    has_dag_links ancestor_class_names: %w(Group), link_class_name: 'DagLink'
    include Structureable
    include Navable

    def title
      name
    end

    def name_as_verb

      # TODO: This is German only! Internationalize!
      name
        .gsub( /ung/, 'en' )
        .gsub( /ation/, 'ieren' )
        .downcase
    end

    def name_as_participle_perfect_passive
      #     Workflow.pluck(:name).uniq   # => ["Aktivmeldung", "Reception", "Branderung", "Burschung", "Inaktivierung loci",
      #                                        "Inaktivierung non loci", "Reaktivierung", "Konkneipierung", "Philistration",
      #                                        "Todesfall", "Streichung", "Schlichter Austritt", "Ehrenhafter Austritt",
      #                                        "Dimissio i.p.", "Exclusio"]
      name
        .gsub(/(.*)meldung/, '\1gemeldet')  # Aktivmeldung -> aktivgemeldet
        .gsub(/(.*)ception/, '\1cipiert')  # Reception -> recipiert
        .gsub(/(.*)ierung/, '\1iert')  # Inaktivierung -> inaktiviert
        .gsub('Streichung', 'gestrichen')
        .gsub(/(.*)er Austritt/, '\1 ausgetreten') # Ehrenhafter Austritt -> ehrenhaft ausgetreten
        .gsub('Exclusio', 'ausgeschlossen per exclusio')
        .gsub('Dimissio i.p.', 'ausgeschlossen per dimissio in perpetuo')
        .gsub(/(.*)ung/, 'ge\1t')  # Burschung -> geburscht
        .gsub(/(.*)ation/, '\1iert')  # Philistration -> philistriert
        .downcase
    end

    # Generates a message that announces the promotion of the
    # given user, e.g.
    #
    #   "John Doe has been promoted to Board Member"
    #
    def promotion_message_string(user)
      if self.name == "Todesfall"
        "#{user.title} ist verstorben."
      elsif self.name == "Aktivmeldung"
        "#{user.title} hat sich #{self.name_as_participle_perfect_passive}."
      elsif self.name.include? "Austritt"
        "#{user.title} ist #{self.name_as_participle_perfect_passive} (#{corporation.title})."
      else
        "#{user.title} wurde #{self.name_as_participle_perfect_passive} (#{corporation.title})."
      end
    end

    def corporation
      self.ancestor_groups.where(type: 'Corporation').first
    end

    def wah_group  # => TODO: Delete this method and check specs.
      corporation
    end
    deprecate :wah_group  # http://stackoverflow.com/a/7112231/2066546

    def parent
      parent_groups.first
    end

    def self.find_or_create_mark_as_deceased_workflow
      self.find_mark_as_deceased_workflow || self.create_mark_as_deceased_workflow
    end

    def self.find_mark_as_deceased_workflow
      Workflow.where(name: "Todesfall").first
    end
    def self.find_mark_as_deceased_workflow_id
      @find_mark_as_deceased_workflow_id ||= Workflow.where(name: "Todesfall").pluck(:id).first
    end

    def self.create_mark_as_deceased_workflow
      raise ActiveRecord::RecordInvalid, 'Workflow already present.' if self.find_mark_as_deceased_workflow
      workflow = Workflow.create(name: "Todesfall")
      step = workflow.steps.build
      step.sequence_index = 1
      step.brick_name = "MarkAsDeceasedBrick"
      step.save
      return workflow
    end

    # Role overrides:
    def find_officers_parent_groups_of_self_and_of_descendant_groups
      []
    end

    include WorkflowCaching if use_caching?
  end
end
