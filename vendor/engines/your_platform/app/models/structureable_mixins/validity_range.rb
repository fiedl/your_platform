# In order to let GroupMemberships have a ValidityRange, we have to override
# some methods provided by acts_as_dag or neo4j_ancestry.
#
module StructureableMixins::ValidityRange

  extend ActiveSupport::Concern

  included do
  end

  # module ClassMethods
  #   
  #   def now_and_in_the_past
  #   end
  #   
  #   def now
  #   end
  #   
  #   def in_the_past
  #   end
  #   
  # end
  # 
  # def parents(time = :now)
  #   apply_validity_range(super, time)
  # end
  # 
  # def children(time = :now)
  #   apply_validity_range(super, time)
  # end
  # 
  # def ancestors(time = :now)
  #   parents(time) + parents(time).collect do |parent|
  #     parent.ancestors(:now_and_in_the_past)
  #   end.flatten
  # end
  # 
  # def descendants(time = :now)
  #   children(time) + children(time).collect do |child|
  #     child.descendants(:now_and_in_the_past)
  #   end.flatten
  # end
  
  
private
  
  def apply_validity_range(method, time)
    if time == :now
      time = { at: Time.zone.now }
    elsif time == :in_the_past
      time = { before: Time.zone.now }
    end
    if time == :now_and_in_the_past
      method
    elsif time.kind_of?(Hash) and time[:at].present?
      method.where("
        ( `dag_links`.valid_from is null OR `dag_links`.valid_from <= ? )
        AND ( `dag_links`.valid_to is null OR `dag_links`.valid_to >= ? )
      ", time[:at])
    elsif time.kind_of?(Hash) and time[:before].prenet?
      method.where("`dag_links`.valid_to < ?", time[:before])
    end
  end
  
end
