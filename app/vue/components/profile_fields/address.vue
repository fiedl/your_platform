<template>
  <div class="profile-field address-profile-field">
    <vue-editable-property
      :property="'profile_field_' + profile_field.id"
      :initial-value="profile_field.value"
      :initial-label="profile_field.label"
      :type="input_type"
      :url="'/profile_fields/' + profile_field.id"
      value-param-key="profile_field[value]"
      label-param-key="profile_field[label]"
      :render-value="render_value"
      :editable="editable"
    ></vue-editable-property>
    <span class="badge bg-blue" v-if="!(editable && editBox().editMode) && has_postal_address_flag()">{{postal_address_flag_label}}</span>
    <div class="postal-address-option" v-if="editable && editBox().editMode">
      <label class="form-check">
        <input class="form-check-input" type="radio" :checked="has_postal_address_flag()" v-on:click="set_postal_address_flag()" name="postal_address">
        <span class="form-check-label">{{postal_address_flag_label}}</span>
      </label>
    </div>
  </div>
</template>

<script>
  import ProfileField from '../profile_field.vue'
  export default {
    extends: ProfileField,
    mounted() {
      this.editBox().$on("remove_postal_address_flags", (args) => {
        if (args.except != this.profile_field.id) { this.remove_postal_address_flag() }
      })
    },
    methods: {
      render_value(value) {
        return value
      },
      has_postal_address_flag() {
        return (this.profile_field.flags || []).map((flag) => flag.key).includes("postal_address")
      },
      toggle_postal_address() {
        if (this.has_postal_address_flag()) {
          this.remove_postal_address_flag()
        } else {
          this.set_postal_address_flag()
        }
      },
      set_postal_address_flag() {
        this.editBox().$emit("remove_postal_address_flags", {except: this.profile_field.id})
        this.profile_field.postal_address = true
        $.ajax({
          url: `/profile_fields/${this.profile_field.id}`,
          method: 'post',
          data: {
            _method: 'put',
            profile_field: this.profile_field
          },
          success: ((result) => this.profile_field.flags = result.flags),
          error: ((message) => console.log(message))
        })
      },
      remove_postal_address_flag() {
        this.profile_field.postal_address = false
        this.profile_field.flags = this.profile_field.flags.filter((flag) => (flag.key != "postal_address"))
      }
    },
    computed: {
      input_type() {
        return "textarea"
      },
      postal_address_flag_label() {
        return I18n.translate('postal_address')
      }
    }
  }
</script>

<style lang="sass">
  .postal-address-option
    margin-top: 0.5rem
    margin-bottom: 2rem
</style>