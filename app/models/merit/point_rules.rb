# Be sure to restart your server when you modify this file.
#
# Points are a simple integer value which are given to "meritable" resources
# according to rules in +app/models/merit/point_rules.rb+. They are given on
# actions-triggered, either to the action user or to the method (or array of
# methods) defined in the +:to+ option.
#
# 'score' method may accept a block which evaluates to boolean
# (recieves the object as parameter)

module Merit
  class PointRules
    include Merit::PointRulesMethods

    def initialize
      # score 10, :on => 'users#create' do |user|
      #   user.bio.present?
      # end
      #
      # score 15, :on => 'reviews#create', :to => [:reviewer, :reviewed]
      #
      # score 20, :on => [
      #   'comments#create',
      #   'photos#create'
      # ]
      #
      # score -10, :on => 'comments#destroy'
      
      score 10, on: 'workflows#execute', category: 'administration'
      score 5, on: ['blog_posts#create', 'pages#create'], category: 'information'
      score 5, on: 'posts#create', category: 'communication'
      score 2, on: 'comments#create', category: 'communication'
      score 1, on: 'events#join', category: 'social activity'
      score 1, on: 'events#update', category: 'social activity'
    end
  end
end
