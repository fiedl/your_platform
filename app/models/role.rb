require_dependency YourPlatform::Engine.root.join('app/models/role').to_s

class Role
  
  # Example:
  #   Role.of(user).administrated_aktivitates
  #
  def administrated_aktivitates
    administrated_objects & Aktivitas.all.collect { |a| a.becomes(Group) }
  end
  
end