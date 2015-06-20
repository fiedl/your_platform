$(document).ready ->
  
  # remove previous binds
  $('textarea').off('atwhoInner')
  
  # adding @mentions to:
  # - new-comment form
  # - new-post form
  #
  autocomplete_url = $('.new_comment textarea').attr('data-user-titles-path')
  $('.new_comment textarea, .new_post textarea').atwho {
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
              unless user_title.includes("✟") # only mention alive users
                users.push {title: user_title, name: user_title}
            callback(users)
    }
  }