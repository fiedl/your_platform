<template>
  <div class="profile-field">
    <editable-property
      v-if="!profile_field.children || profile_field.children.length == 0"
      :property="'profile_field_' + profile_field.id"
      :initial-value="profile_field.value"
      :initial-label="profile_field.label"
      :type="input_type"
      :url="'/profile_fields/' + profile_field.id"
      value-param-key="profile_field[value]"
      label-param-key="profile_field[label]"
      :render-value="render_value"
      :editable="editable"
      :label-editable="profile_field.label_editable"
    ></editable-property>
    <span class="profile-field-with-children" v-if="profile_field.children && profile_field.children.length > 0">
      <div class="profile_field_parent_label">
        <editable
          :property="'profile_field_label_' + profile_field.id"
          type="text"
          :initial-value="profile_field.label"
          :url="'/profile_fields/' + profile_field.id"
          param-key="profile_field[label]"
          :editable="editable"
          v-on:edit="edit_children()"
        ></editable>
      </div>
      <div class="profile-field-children">
        <editable-property
          v-for="child_profile_field in profile_field.children"
          :property="'profile_field_' + child_profile_field.id"
          :initial-value="child_profile_field.value"
          :initial-label="child_profile_field.label"
          :type="input_type"
          :url="'/profile_fields/' + child_profile_field.id"
          value-param-key="profile_field[value]"
          label-param-key="profile_field[label]"
          :render-value="render_value"
          :editable="editable"
          :label-editable="false"
        ></editable-property>
      </div>
    </span>
  </div>
</template>

<script>
  export default {
    props: ["initial-profile-field"],
    data() { return {
      profile_field: {}
    } },
    created() {
      this.profile_field = this.initialProfileField
    },
    methods: {
      render_value(value) {
        if (value) {
          if (this.profile_field.type == "ProfileFields::Email") { return `<a href="mailto:${value}">${value}</a>`}
          if (this.profile_field.type == "ProfileFields::Phone") { return `<a href="tel:${value}">${value}</a>`}
          if (this.profile_field.type == "ProfileFields::Homepage") { return `<a href="${value}">${value}</a>`}
        }
        return value
      },
      editBox() {
        if (this.$parent.editBox) {
          return this.$parent.editBox()
        }
      },
      editables() {
        return (this.$children.map((child) => child.editables()).flat())
      },
      edit_children() {
        this.$children.map((e) => {
          if (e.$options.name == "editable-property") {
            e.editables().map((e) => e.edit())
          }
        })
      }
    },
    computed: {
      input_type() {
        if (this.profile_field.type == "ProfileFields::Email") { return "email" }
        if (this.profile_field.type == "ProfileFields::Phone") { return "phone" }
        if (this.profile_field.type == "ProfileFields::Date") { return "date" }
        if (this.profile_field.type == "ProfileFields::About") { return "textarea" }
        return "text"
      },
      editable() {
        return this.profile_field.editable
      }
    }
  }
</script>

<style lang="sass">
  .profile-field-children
    display: flex
    flex-wrap: wrap
    .editable-property
      margin: 1em
  .profile_field_parent_label
    font-size: 110%
    font-weight: bold
</style>