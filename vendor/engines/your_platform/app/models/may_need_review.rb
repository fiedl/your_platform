module MayNeedReview
  
  def may_need_review
    
    raise 'The model needs to be able to have flags associated.' if not self.instance_methods.include? :flags
    
    extend ClassMethods
    include InstanceMethods
    
  end
  
  module ClassMethods
  
    # This class method gets all ProfileFields that are marked as :needs_review.
    # 
    def find_all_that_need_review
      self.joins(:flags).where('flags.key' => :needs_review, 'flags.flagable_type' => 'ProfileField')
    end
    
    # This class method gets all ProfileFields that match the given ids
    # and are marked as :needs_review.
    #
    def find_all_that_need_review_by_profile_field_ids(profile_field_ids)
      self.find_all_that_need_review.where(id: profile_field_ids)
    end
    
  end

  module InstanceMethods
    
    def needs_review?
      has_flag? :needs_review
    end
    def needs_review!
      self.needs_review = true
    end
    def needs_review
      self.needs_review?
    end
    def needs_review=(does_need_review)
      if does_need_review
        self.add_flag :needs_review
      else
        self.remove_flag :needs_review
      end
    end
    
  end

end