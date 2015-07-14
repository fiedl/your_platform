$(document).ready ->
  $(document).process_mentions()

$.fn.process_mentions = ->
  
  # remove previous binds
  $(this).find('textarea').off('atwhoInner')
  
  # adding @mentions to:
  # - new-comment form
  # - new-post form
  #
  autocomplete_url = $(this).find('.new_comment textarea').attr('data-user-titles-path')
  $(this).find('.new_comment textarea, .new_post textarea').atwho {
    at: '@',
    maxLen: 50,
    delay: 400,
    searchKey: 'title',
    insertTpl: "${atwho-at}[[${title}]]",
    callbacks: {
      remoteFilter: (query, callback)->
        # https://github.com/ichord/At.js/wiki/How-to-use-remoteFilter
        #
        # The callback needs this kind of argument:
        #    callback([
        #      {name: "Foo", title: "Foo"}, 
        #      {name: "Bar", title: "Bar"}
        #    ])
        #
        if query.length >= 3
          $.getJSON autocomplete_url, {term: query}, (response)->
            user_titles = response  # ["John Doe", ...]
            users = []
            for user_title in user_titles
              unless user_title.indexOf("✟") != -1 # only mention alive users
                users.push {title: user_title, name: user_title}
            callback(users)
    }
  }
  
  # adding :emoji: to:
  # - all textareas
  #
  $(this).find('textarea').atwho {
    at: ':',
    searchKey: 'key',
    displayTpl: "<li>${image_tag} :${key}:</li>",
    insertTpl: ":${key}:",
    callbacks: {
      remoteFilter: (query, callback)->
        $.getJSON "/emojis.json", {query: query, limit: 5}, (response)->
          callback(response)
    }
  }