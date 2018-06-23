stimulus.register "term-reports", class extends Stimulus.Controller
  @targets = ["statusComment"]

  #get_data: (key)->
  #  this.element.getAttribute("data-#{this.identifier.replace('_', '-')}-#{key.replace('_', '-')}")
  #get_target: (key)->
  #  this.targets.find(key)

  #accept_url: -> this.get_data("accept_url")
  #reject_url: -> this.get_data("reject_url")
  #comment: -> this.get_target("status_comment").value

  accept: ->
    #alert("accept: #{this.accept_url()} #{this.comment()}")
    console.log this.statusCommentTarget.value
    console.log this.data.get("acceptUrl")


  reject: ->
    alert("reject")

  #%textarea.form-control{placeholder: "Kommentar hinzufügen"}
  #
  #
  #= button_to term_report_accept_path(term_report_id: term_report.id), class: 'btn btn-default  accept_term_report', method: :post do
  #  = icon 'ok-circle'
  #  Verbindlich akzeptieren
  #= button_to term_report_reject_path(term_report_id: term_report.id), class: 'btn btn-default btn-danger reject_term_report', method: :post do
  #  = icon 'remove-circle'
  #  Ablehnen
  #
  #.test{data: {controller: 'hello'}}
  #  %a.btn.btn-default{data: {action: 'click->hello#greet'}} Test