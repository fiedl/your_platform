module WingolfitischeVitaHelper
  
  def wingolfitische_vita_ul( user )
    render partial: 'shared/wingolfitische_vita', locals: { user: user }
  end

end
