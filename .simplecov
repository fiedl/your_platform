# This is the shared SimpleCov configuration. It will be called whenever the simplecov gem is required.
SimpleCov.start :rails do
  # For reasons yet unknown, the default formatter seems to be overwritten by our app
  # so reset it
  formatter = SimpleCov::Formatter::HTMLFormatter
end
