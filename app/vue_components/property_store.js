import Vue from 'vue'

export var propertyStore = new Vue({
  data: {
    editables: [],
    properties: {}
  },
  methods: {
    registerEditable(editable) {
      if (editable.property) {
        this.editables.push(editable)
      }
    },
    updateProperty(sourceEditable) {
      var property = sourceEditable.property
      if (property) {
        var value = sourceEditable.value
        this.properties[property] = value
        this.notifyEditables(property, sourceEditable)
      }
    },
    notifyEditables(property, sourceEditable) {
      var value = this.properties[property]
      this.editables.forEach(function(editable) {
        if (editable.property == property) {
          if (editable != sourceEditable) {
            editable.value = value
            editable.valueBeforeEdit = value
          }
        }
      })
    }
  }
})