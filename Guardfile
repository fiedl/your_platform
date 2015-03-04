require 'active_support/core_ext'

guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('spec/spec_helper.rb')
  watch(%r{^spec/support/.+\.rb$})
  watch(%r{^spec/factories/.+\.rb$})
end

guard( 'rspec', :version => 2,
       :cli => '--drb --tag focus --format Fuubar',
       :all_after_pass => false,
       :all_on_start => false,
       spec_paths: %w(spec)) do

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }

  # Rails
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| %W(spec/routing/#{m[1]}_routing_spec.rb spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb spec/acceptance/#{m[1]}_spec.rb) }
  watch(%r{^spec/support/(.+)\.rb$})                  { 'spec' }
  watch('config/routes.rb')                           { 'spec/routing' }
  watch('app/controllers/application_controller.rb')  { 'spec/controllers' }

  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
end

# guard 'brakeman', :run_on_start => true do
#   watch(%r{^app/.+\.(erb|haml|rhtml|rb)$})
#   watch(%r{^config/.+\.rb$})
#   watch(%r{^lib/.+\.rb$})
#   watch('your_platform.gemspec')
#   watch('Gemfile')
# end
