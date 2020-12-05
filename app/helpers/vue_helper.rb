module VueHelper

  def vue_edit_box(large_button: false)
    content_tag 'vue-edit-box', {
      ':large_button': large_button.to_json,
      edit_icon: edit_icon
    } do
      yield
    end
  end

  # Display a list of posts and comments with a vue component.
  #
  # show_public_badges: Whether to show a badge indicating whether the
  #   post is to be published on the public website.
  #
  def vue_posts(posts, show_public_badges: false, sent_via: nil, show_single_post: false)
    content_tag :vue_post_list_group, "", {
      ':posts': posts.where.not(author_user_id: nil).includes({author: [:avatar_attachments]}, :attachments, {comments: [author: [:avatar_attachments]]}, :group, :parent_groups, :parent_events).collect { |post|
        post.as_json.merge({
          author: post.author.as_json.merge({
            path: (polymorphic_path(post.author) if can?(:read, post.author))
          }),
          attachments: post.attachments.as_json,
          comments: post.comments.order(:created_at).collect { |comment|
            comment.as_json.merge({
              author: comment.author
            })
          },
          can_comment: can?(:create_comment, post),
          editable: can?(:update, post),
          groups: (post.parent_groups + [post.group] - [nil]).as_json,
          events: post.parent_events.as_json,
          can_update_publish_on_public_website: can?(:update_public_website_publication, post)
        })
      }.to_json,
      send_icon: send_icon,
      sent_via: sent_via,
      ':current_user': current_user.to_json,
      ':show_public_badges': show_public_badges.to_b.to_json,
      ':show_single_post': show_single_post.to_json
    }
  end

  def vue_post_page(post)
    content_tag :vue_post_page, "", {
      ':post': post.as_json.merge({
        author: post.author.as_json.merge({
          path: (polymorphic_path(post.author) if can?(:read, post.author))
        }),
        attachments: post.attachments.as_json,
        comments: post.comments.order(:created_at).collect { |comment|
          comment.as_json.merge({
            author: comment.author
          })
        },
        can_comment: can?(:create_comment, post),
        editable: can?(:update, post),
        groups: (post.parent_groups + [post.group] - [nil]).collect { |group|
          group.as_json(methods: [:avatar_path, :title])
        },
        events: post.parent_events.collect { |event|
          event.as_json(methods: [:avatar_path, :title])
        },
        can_update_publish_on_public_website: can?(:update_public_website_publication, post),
        sent_deliveries: Rails.cache.fetch([post, "sent_deliveries", "v3", post.deliveries.sent.count]) {
          post.deliveries.sent.collect { |delivery|
            delivery.as_json(methods: :user)
          }
        },
        failed_deliveries: Rails.cache.fetch([post, "failed_deliveries", "v3", post.deliveries.failed.count]) {
          post.deliveries.failed.collect { |delivery|
            delivery.as_json(methods: :user)
          }
        },
      }).to_json,
      mail_icon: mail_icon,
      trash_icon: trash_icon,
      edit_icon: edit_icon,
      send_icon: send_icon,
      ':current_user': current_user.to_json,
    }
  end

  def vue_create_post_form(initial_post: nil, sent_via: nil, show_send_via_email_toggle: false, suggested_groups: Group.none, send_via_email: nil, show_publish_on_website_toggle: false, parent_group: nil, placeholder: nil)
    content_tag :vue_create_post_form, "", {
      camera_icon: camera_icon,
      send_icon: send_icon,
      sent_via: sent_via,
      placeholder: placeholder,
      ':parent_group': parent_group.to_json,
      ':initial_post': (initial_post.as_json.merge({
        attachments: initial_post.attachments.as_json,
        parent_groups: initial_post.parent_groups.includes(:avatar_attachments, :flags).collect { |group|
          group.as_json.merge({
            title: group.title,
            avatar_path: group.avatar_path
          })
        }
      }).to_json if initial_post),
      ':suggested_groups': suggested_groups.includes(:avatar_attachments, :flags).collect { |group|
        group.as_json.merge({
          title: group.title,
          avatar_path: group.avatar_path
        })
      }.to_json,
      ':show_send_via_email_toggle': show_send_via_email_toggle.to_json,
      ':initial_send_via_email': send_via_email.to_json,
      ':show_publish_on_website_toggle': show_publish_on_website_toggle.to_json,
    }
  end

  def vue_semester_calendar_events(semester_calendar:, events: nil)
    content_tag :vue_semester_calendar_events, "", {
      ':initial_events': (events || semester_calendar.events)
        .select { |event| can? :read, event }
        .collect { |event|
          event.as_json(methods: [:aktive, :philister]).merge({
            attendees_count: event.attendees.count,
            can_create_post: can?(:create_post, event)
          })}
        .to_json,
      ':editable': can?(:update, semester_calendar).to_json,
      ':group': semester_calendar.group.to_json,
      default_location: semester_calendar.group.postal_address,
      ':semester_calendar': semester_calendar.to_json,
      ':next_semester_calendar': semester_calendar.next.to_json,
      camera_icon: camera_icon
    }
  end

  def vue_profile_field(profile_field)
    content_tag 'vue-profile-field', "", {
      ':initial-profile-field': profile_field.as_json.merge({
        editable: can?(:update, profile_field)
      }).to_json
    }
  end

  def vue_couleur_profile_field(profile_field, rotate: nil)
    content_tag 'vue-couleur-profile-field', "", {
      ':initial_profile_field': profile_field.to_json,
      ':editable': can?(:update, profile_field).to_json,
      ':colors': ProfileFields::Couleur.colors.to_json,
      rotate: rotate
    }
  end

  def vue_new_event_form
    content_tag 'vue_new_event_form', "", {
      ':current_user': current_user.to_json,
      ':initial_groups': [current_user.primary_corporation.as_json.merge({
        title: current_user.primary_corporation.title,
        avatar_path: current_user.primary_corporation.avatar_path,
        avatar_background_path: current_user.primary_corporation.avatar_background_path
      })].to_json,
      ':suggested_groups': current_user.groups.regular.includes(:avatar_attachments, :flags).collect { |group|
        group.as_json.merge({
          title: group.title,
          avatar_path: group.avatar_path,
          avatar_background_path: group.avatar_background_path,
        })
      }.to_json,
      initial_location: current_user.primary_corporation.postal_address.gsub("\n", ", ")
    }
  end

  def vue_event_attendees_card(event)
    content_tag 'vue_event_attendees', "", {
      ':initial_event': event.as_json.merge({
        contact_people: event.contact_people.collect { |user|
          user.as_json.merge({
            phone: user.phone
          })
        },
        attendees: event.attendees
      }).to_json,
      ':editable': can?(:update, event),
      ':joinable': can?(:join, event),
      ':current_user': current_user.to_json,
      ':attendees_group': event.attendees_group.to_json,
      join_icon: calendar_plus_icon,
      leave_icon: calendar_minus_icon
    }
  end

  def vue_right_corner_ribbon
    show_ribbon = true
    show_ribbon = false if current_user && current_user.settings.show_ribbon.in?(['false', false])
    content_tag 'vue_right_corner_ribbon', "", {
      ':current_user': current_user.to_json,
      ':initial_dark_mode': ((current_user && current_user.settings.dark_mode) || 'auto').to_json,
      ':initial_show_ribbon': show_ribbon,
      ':color_palette': ProfileFields::Couleur.colors.to_json,
      ':current_user_ribbons': current_couleurs.to_json
    }
  end

  def vue_editable_image(attachment = nil, src: nil, tools_alignment: 'right', editable: false, image_class: '', icon: 'fa fa-image', update_url: nil, attribute_name: nil, style: nil, link_to: nil)
    content_tag 'vue-editable-image', "", {
      src: attachment.try(:big_path) || src,
      download_url: attachment.try(:path),
      tools_alignment: tools_alignment,
      ':editable': editable.to_json,
      img_class: image_class,
      icon: icon,
      download_icon: download_icon,
      update_url: update_url,
      attribute_name: attribute_name,
      style: style,
      link_to: link_to
    }
  end

end