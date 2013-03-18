# A sample Guardfile
# More info at https://github.com/guard/guard#readme

require 'active_support/core_ext'

guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('spec/spec_helper.rb')
  watch(%r{^spec/support/.+\.rb$})
  watch(%r{^spec/factories/.+\.rb$})
  watch(%r{^vendor/engines/your_platform/spec/factories/.+\.rb$})
end

#guard( #'focus', # see https://github.com/supaspoida/guard-focus
       #on: :rspec, :version => 2, 
guard( 'rspec', :version => 2,
       :cli => '--drb',
       :all_after_pass => false,
       spec_paths: %w(spec vendor/engines/your_platform/spec)) do

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| %W(spec/routing/#{m[1]}_routing_spec.rb spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb spec/acceptance/#{m[1]}_spec.rb) }
  watch(%r{^spec/support/(.+)\.rb$})                  { 'spec' }
  watch('config/routes.rb')                           { 'spec/routing' }
  watch('app/controllers/application_controller.rb')  { 'spec/controllers' }
  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }


  # TODO: Move this into its own testing environment
  # Temporary integration of the your_platform engine's tests
  watch(%r{^vendor/engines/your_platform/spec/.+_spec\.rb$})
  watch(%r{^vendor/engines/your_platform/app/(.+)\.rb$})    { |m| "vendor/engines/your_platform/spec/#{m[1]}_spec.rb" }

end

