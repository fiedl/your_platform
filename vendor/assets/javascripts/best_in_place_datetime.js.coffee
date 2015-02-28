datetime =
  "datetime" :
    activateForm: ->
      that      = this
      output    = jQuery(document.createElement('form'))
                  .addClass('form_in_place')
                  .attr('action', 'javascript:void(0);')
                  .attr('style', 'display:inline')
      input_elt = jQuery(document.createElement('input'))
                  .attr('type', 'text')
                  .attr('name', this.attributeName)
                  .attr('value', this.sanitizeValue(this.display_value))

      if (this.inner_class != null)
        input_elt.addClass(this.inner_class)

      output.append(input_elt)

      this.element.html(output)
      this.setHtmlAttributes()
      this.element.find('input')[0].select()
      this.element.find("form").bind('submit', {editor: this}, BestInPlaceEditor.forms.input.submitHandler)
      this.element.find("input").bind('keyup', {editor: this}, BestInPlaceEditor.forms.input.keyupHandler)

      this.element.find('input')
        .datetimepicker
          onClose: ->
            that.update()

        .datepicker('show')
    ,

    getValue: ->
      this.sanitizeValue(this.element.find("input").val())
    ,

    submitHandler : (event)  ->
      event.data.editor.update()
    ,

    keyupHandler : (event) ->
      if (event.keyCode == 27)
        event.data.editor.abort()

$.extend BestInPlaceEditor.forms, datetime
