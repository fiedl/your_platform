module MobileHelper

  def mobile_user_link(user)
    link_to user_path(user, format: 'vcf'), class: 'user_link' do
      user_avatar(user) + content_tag(:span, user.title, class: 'user_name')
    end
  end

end