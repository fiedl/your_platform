require_dependency YourPlatform::Engine.root.join('app/controllers/users_controller').to_s

class UsersController
  
  def new
    @title = "Aktivmeldung eintragen" # t(:create_user)
    @user = User.new
    
    @group = Group.find(params[:group_id]) if params[:group_id]
    @user.add_to_corporation = @group.becomes(Corporation).id if @group && @group.corporation?

    @user.alias = params[:alias]
  end
  
  def create
    #
    # Parameter für Aktivmeldung:
    #   :first_name, :last_name, :date_of_birth, :add_to_corporation, :aktivmeldungsdatum, 
    #   :study_address, :home_address, :email, :phone, :mobile, :create_account
    #
    
    @user_params = user_params
    @basic_user_params = @user_params.select { |key, value| key.in? ['first_name', 'last_name', 'email', 'add_to_corporation', 'create_account'] }

    @required_parameters_keys = ['first_name', 'last_name', 'date_of_birth(1i)', 'date_of_birth(2i)', 'date_of_birth(3i)', 'study_address', 'home_address', 'email', 'mobile' ]
    
    # Lokale Administratoren müssen eine Verbindung angeben, da sie sonst einen Benutzer anlegen,
    # den sie selbst nicht mehr administrieren können.
    #
    @required_parameters_keys += ['add_to_corporation'] if not current_user.global_admin?
    
    if (@user_params.select { |k,v| v.present? }.keys & @required_parameters_keys).count != @required_parameters_keys.count

      # Wenn nicht alle erforderlichen Parameter angegeben wurden, muss nocheinmal nachgefragt werden.
      
      @title = "Aktivmeldung eintragen"
      @user = User.new(@basic_user_params)
      @user.valid?
      
      flash[:error] = 'Informationen zur Aktivmeldung wurden nicht vollständig ausgefüllt. Bitte Eingabe wiederholen.'
      if not current_user.global_admin? and not @basic_user_params['add_to_corporation'].present?
        flash[:error] += " Es wurde keine Verbindung angegeben. Die Aktivmeldung konnte nicht eingetragen werden."
      end
      
      render :action => "new"
      
    else
      
      # Wenn alle erforderlichen Parameter angegeben wurden, kann die Aktivmeldung eingetragen werden.

      UsersController.delay.create_async(@basic_user_params, @user_params)
      flash[:notice] = "Die Aktivmeldung wurde eingetragen. Es dauert ein paar Minuten, bis der neue Wingolfit auf der Plattform angezeigt wird."
      redirect_to root_path
      
    end
  end
  
  # This method asynchronously creates a new user when called like this:
  # 
  #    UsersController.delay.create_async(@basic_user_params, @user_params)
  #
  def self.create_async(basic_user_params, all_user_params)
    user = User.create!(basic_user_params)
    
    # $enable_tracing = false
    # $trace_out = open('trace.txt', 'w')
    # 
    # set_trace_func proc { |event, file, line, id, binding, classname|
    #   if $enable_tracing && event == 'call'
    #     $trace_out.puts "#{Time.zone.now.to_s} #{file}:#{line} #{classname}##{id}"
    #   end
    # }
    # 
    # $enable_tracing = true

    user.date_of_birth = Date.new all_user_params["date_of_birth(1i)"].to_i, all_user_params["date_of_birth(2i)"].to_i, all_user_params["date_of_birth(3i)"].to_i
    
    if all_user_params["aktivmeldungsdatum(1i)"].present? and user.corporations.count > 0
      user.aktivmeldungsdatum = Date.new all_user_params["aktivmeldungsdatum(1i)"].to_i, all_user_params["aktivmeldungsdatum(2i)"].to_i, all_user_params["aktivmeldungsdatum(3i)"].to_i
    end
    
    user.study_address = all_user_params["study_address"]
    user.home_address = all_user_params["home_address"]
    user.phone = all_user_params["phone"]
    user.mobile = all_user_params["mobile"]
    user.save
    
    user.send_welcome_email if user.account
    
    # FIXME: This may raise 'stack level too deep' when run through sidekiq:
    user.fill_in_template_profile_information
    
    user.delay.fill_cache
    Group.alle_aktiven.delay.fill_cache
  end
  
end