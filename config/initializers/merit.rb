# Use this hook to configure merit parameters
Merit.setup do |config|
  # Check rules on each request or in background
  # config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongoid
  config.orm = :active_record

  # Add application observers to get notifications when reputation changes.
  # config.add_observer 'ReputationChangeObserver'

  # Define :user_model_name. This model will be used to grand badge if no
  # `:to` option is given. Default is 'User'.
  config.user_model_name = 'User'

  # Define :current_user_method. Similar to previous option. It will be used
  # to retrieve :user_model_name object if no `:to` option is given. Default
  # is "current_#{user_model_name.downcase}".
  config.current_user_method = 'current_user'
end

# Create application badges (uses https://github.com/norman/ambry)
badge_id = 0
[{
  id: (badge_id = badge_id+1),
  name: 'first-login',
  level: 1,
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'commentator',
  level: 10,
  description: 'leave 10 comments',
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'blogger',
  level: 10,
  description: 'create 10 blog posts with 100 or more characters',
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'auto-biographer',
  description: 'create an about-myself profile field with 100 or more characters',
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'editor',
  description: 'edit a page or blog post created by another user',
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'yearling',
  description: 'sign in when your first sign in has been over a year ago',
  custom_fields: { difficulty: :silver }
}, {
  id: (badge_id = badge_id+1),
  name: 'global-admin',
  description: 'become a global administrator',
  custom_fields: { difficulty: :gold }
}, {
  id: (badge_id = badge_id+1),
  name: 'admin',
  description: 'become an administrator',
  custom_fields: { difficulty: :silver }
}, {
  id: (badge_id = badge_id+1),
  name: 'compliant',
  description: 'accept the terms of use',
  custom_fields: { difficulty: :bronce },
  multiple: true
}, {
  id: (badge_id = badge_id+1),
  name: 'data-kraken',
  description: 'download 10 exported lists',
  level: 10,
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'post-office',
  description: 'download 10 exported address label pdfs',
  level: 10,
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'captain-of-the-enterprise',
  description: 'create a post or comment containing the legendary phrase "make it so"',
  custom_fields: { difficulty: :silver }
}, {
  id: (badge_id = badge_id+1),
  name: 'damsel-in-distress',
  description: 'only a true hero is honest enough to ask for help: create a support-request with the help button',
  custom_fields: { difficulty: :silver }
}, {
  id: (badge_id = badge_id+1),
  name: 'eliminator',
  description: 'execute each destructive status workflow at least once',
  custom_fields: { difficulty: :silver }
}, {
  id: (badge_id = badge_id+1),
  name: 'princess-leia',
  description: 'exeute each constructive status workflow at least once',
  custom_fields: { difficulty: :silver }
}, {
  id: (badge_id = badge_id+1),
  name: 'calendar-uplink',
  description: 'subscribe to your personal ical calendar feed',
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'thanks-for-letting-us-know',
  description: 'update own profile',
  custom_fields: { difficulty: :bronce }
}, {
  id: (badge_id = badge_id+1),
  name: 'good-profile',
  description: 'fill out at least 14 profile fields',
  level: 14,
  custom_fields: { difficulty: :bronce }


}].each do |attrs|
  Merit::Badge.create! attrs
end
