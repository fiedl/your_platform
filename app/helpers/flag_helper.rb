module FlagHelper

  def flags(object)
    object.flags.collect do |flag|
      content_tag :span, class: 'label label-info flag' do
        icon(:tag) + t(flag)
      end
    end.join(" ").html_safe
  end

  def flagged_navables(flag)
    Page.flagged(flag) + Group.flagged(flag)
  end

end