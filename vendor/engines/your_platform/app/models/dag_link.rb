# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true

  def save( *args )
    delete_cache_daglink
    super( *args )
  end

  def delete_cache_daglink
    if self.descendant_type == "User"
      if User.exists?( self.descendant_id )
        desc_user = User.find( self.descendant_id )
      end
    end
    if desc_user
      desc_user.delete_cache
    end
  end

end
