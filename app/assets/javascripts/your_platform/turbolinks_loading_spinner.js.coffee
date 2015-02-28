# Turbolinks Loading Spinner
# Source: https://gist.github.com/cpuguy83/5016442

@PageSpinner =

  spin: (ms=500)->
    @spinner = setTimeout( (=> @add_spinner()), ms)
    $(document).on 'page:change', =>
      @remove_spinner()

  icon: ->
    if ((new Date).getHours() > 18)
      "beer"
    else
      "coffee"

  icon_html: ->
    # See IconHelper#awesome_icon and
    # https://github.com/bokmann/font-awesome-rails
    #
    # Available icons:
    # http://fortawesome.github.io/Font-Awesome/icons/
    #
    '<i class="page-spinner-icon fa fa-' + @icon() + ' fa-2x"></i>'

  title: ->
    str = $('title').text()  # "My Page - Your Platform"
    second_str = str.split(" - ")[1]
    second_str || str

  spinner_html: -> 
    # http://getbootstrap.com/javascript/#modals
    '
    <div class="modal fade" id="page-spinner">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header"><h3 class="modal-title">
            ' + @title() + '
          </h3></div>
          <div class="modal-body">
            ' + @icon_html() + '
            <span class="page-spinner-message">
              Inhalt wird geladen. Bitte warten ...
            </span>
          </div>
        </div>
      </div>
    </div>
  '

  spinner: null

  add_spinner: ->
    @append_spinner()
    @show_modal_delayed()
    
  append_spinner: ->
    $('body').append(@spinner_html())
    
  show_modal: ->
    $('body div#page-spinner').modal({keyboard: false, backdrop: 'static'})
    
  show_modal_delayed: ->
    @show_modal()
    dialog_selector = 'body div#page-spinner .modal-dialog' 
    $(dialog_selector).hide()
    setTimeout( ->
      $(dialog_selector).show('fade')
    , 2000)

  remove_spinner: ->
    clearTimeout(@spinner)
    $('div#page-spinner').modal('hide')
    $('div#page-spinner').on 'hidden', ->
      $(this).remove()

$(document).on 'page:fetch', ->
  PageSpinner.spin()
