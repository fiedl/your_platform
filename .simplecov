# This is the shared SimpleCov configuration. It will be called whenever the simplecov gem is required.
SimpleCov.start :rails do
  # For reasons yet unknown, the default formatter seems to be overwritten by our app
  # so reset it
  formatter = SimpleCov::Formatter::HTMLFormatter

  # SimpleCov filters out every non-App code, including your_platform
  # for now, we want to include it.
  # TODO: Remove this code when the your_platform gem has been extracted
  filters.clear # This will remove the :root_filter that comes via simplecov's defaults
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}/) unless src.filename =~ /your_platform/
  end
end
