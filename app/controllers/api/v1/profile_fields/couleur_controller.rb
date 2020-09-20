class Api::V1::ProfileFields::CouleurController < Api::V1::BaseController

  expose :profile_field, -> { ProfileFields::Couleur.find params[:id] }

  expose :colors, -> { params[:profile_field][:colors] }
  expose :percussion_colors, -> { params[:profile_field][:percussion_colors] }
  expose :ground_color, -> { params[:profile_field][:ground_color] }
  expose :reverse, -> { params[:profile_field][:reverse] }

  def update
    authorize! :update, profile_field

    profile_field.set colors: colors,
      percussion_colors: percussion_colors,
      ground_color: ground_color,
      reverse: reverse.to_b
    profile_field.save!

    render json: profile_field, status: :ok
  end

end