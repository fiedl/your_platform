# -*- coding: utf-8 -*-
#
# This class models a relationship between two users.
#
# For example, John is the brother of Sue. 
#
#   who: John        relationship.user1    relationship.who
#   is:  Brother     relationship.is       relationship.name
#   of:  Sue         relationship.user2    relationship.of
#
class Relationship < ActiveRecord::Base

  attr_accessible :user1, :user2, :name, :who, :is, :of, :who_by_title, :of_by_title

  belongs_to :user1, class_name: "User", inverse_of: :relationships_as_first_user
  belongs_to :user2, class_name: "User", inverse_of: :relationships_as_second_user

  # John is the brother of Sue.
  # ----                           who: John
  #
  def who
    self.user1
  end
  def who=( user )
    self.user1 = user
  end

  # John is the brother of Sue.
  #             -------           is: brother
  #
  def is
    self.name
  end
  def is=( name )
    self.name = name
  end

  # John is the brother of Sue.
  #                        ---    of: Sue
  #
  def of 
    self.user2
  end
  def of=( user )
    self.user2 = user
  end

  # Adding new relationships:
  # 
  #     Relationship.add( who: john_user, is: :brother, of: :sue_user )
  #
  # which is the same as:
  #
  #     Relationship.create( who: john_user, is: :brother, of: :sue_user )
  #
  def self.add( params )
    self.create( params )
  end

  # Access method for the first user being given by his title.
  #
  def who_by_title
    self.who.title if self.who
  end
  def who_by_title=( title )
    self.who = User.find_by_title( title )
  end
  
  # Access method for the second user being given by his title.
  #
  def of_by_title
    self.of.title if self.of
  end
  def of_by_title=( title )
    self.of = User.find_by_title( title )
  end

end
