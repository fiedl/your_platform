# http://railscasts.com/episodes/371-strong-parameters
#
ActiveRecord::Base.send(:include, ActiveModel::ForbiddenAttributesProtection)
