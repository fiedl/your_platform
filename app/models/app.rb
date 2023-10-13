class App

  def self.organization
    # TODO: generalize this to support switching orgs per configuration or per request.
    "wingolf"
  end

  # Using this namespace, the organization can overwrite classes, locales, etc.
  #
  def self.code_namespace
    organization
  end

  def self.database_namespace
    # TODO: Unify this with our database namespacing mechanism, which also concerns the environment, possibly subdomain, etc.
  end

end