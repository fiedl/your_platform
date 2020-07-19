<template>
  <div class="editable-property">
    <label class="form-label" v-on:mouseenter="suggestEdit" v-on:click="editAndFocus" @dblclick="editLabel" >{{label}}</label>
    <div class="value" v-if="! hideValue">
      <vue-editable :property="property" :type="type" :initial-value="initialValue" :url="url" :param-key="valueParamKey" :render-value="renderValue" :editable="editable"></vue-editable>
    </div>
  </div>
</template>

<script>
  export default {
    props: ["initialLabel", "property", "type", "initialValue", "url", "valueParamKey", "labelParamKey", "renderValue", "editable", "labelEditable", "hideValue"],
    data() { return {
      label: ""
    } },
    created() {
      this.label = this.initialLabel
    },
    methods: {
      editLabel() {
        if (this.editable && (! (this.labelEditable == false))) {
          var newLabel = prompt(`Beschriftung "${this.label}" ändern in:`, this.label)
          if (newLabel) {
            var oldLabel = this.label
            this.label = newLabel
            $.ajax({
              url: this.url,
              method: 'post',
              data: {
                _method: 'put',
                [this.labelParamKey]: this.label
              },
              error: function(result, message) {
                this.label = oldLabel
              }
            })
          }
        }
      },
      editBox() {
        if (this.$parent.editBox) {
          return this.$parent.editBox()
        }
      },
      editables() { return this.$children },
      editAndFocus() {
        if (this.editable) { this.editableElement.edit(); this.editableElement.focus() }
      },
      suggestEdit() {
        if (this.editable) { this.editableElement.suggestEdit() }
      }
    },
    computed: {
      value: {
        get() { return this.editable.value },
        set(v) { this.editable.value = v }
      },
      editableElement() { return this.editables()[0] }
    }
  }
</script>