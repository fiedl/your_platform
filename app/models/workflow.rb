class Workflow < WorkflowKit::Workflow  #< ActiveRecord::Base
  attr_accessible    :name if defined? attr_accessible

  is_structureable   ancestor_class_names: %w(Group)

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
      "#{user.title} ist #{self.name_as_participle_perfect_passive}."
    else
      "#{user.title} wurde #{self.name_as_participle_perfect_passive}."
    end
  end

  def corporation
    self.ancestor_groups.where(type: 'Corporation').first
  end

  def wah_group  # => TODO: Delete this method and check specs.
    corporation
  end
  deprecate :wah_group  # http://stackoverflow.com/a/7112231/2066546

  def self.find_or_create_mark_as_deceased_workflow
    self.find_mark_as_deceased_workflow || self.create_mark_as_deceased_workflow
  end

  def self.find_mark_as_deceased_workflow
    Workflow.where(name: "Todesfall").first
  end

  def self.create_mark_as_deceased_workflow
    raise 'Workflow already present.' if self.find_mark_as_deceased_workflow
    workflow = Workflow.create(name: "Todesfall")
    step = workflow.steps.build
    step.sequence_index = 1
    step.brick_name = "MarkAsDeceasedBrick"
    step.save
    return workflow
  end
end
