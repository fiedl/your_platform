<template>
  <div>
    <label class="form-label">Mitglied manuell in "{{group.name}}" eintragen:</label>
    <vue-user-select placeholder="Bestehendes Mitglied suchen und eintragen" v-model="new_member" />

    <div v-if="new_member">
      <label class="form-label mt-4 required">Mitgliedschaft beginnt am:</label>
      <vue-datepicker v-model="new_date"/>

      <div class="mt-4">
        <div class="form-label error required mb-2" v-if="need_more_fields">
          Bitte alle benötigten Felder ausfüllen
        </div>

        <button class="btn btn-outline-primary" @click="add_new_member" :disabled="! submission_enabled">Eintragen</button>
      </div>
    </div>
  </div>
</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default

  AddGroupMemberForm =
    props: ['group']
    data: ->
      new_date: moment().locale('de').format('L')
      new_member: null
      submitting: false
    methods:
      add_new_member: ->
        component = this
        this.submitting = true
        this.new_member.joined_at = moment(this.new_date, 'DD.MM.YYYY').toDate()
        this.$root.$emit 'add_member', this.new_member
        Api.post "groups/#{@group.id}/members", {
          data:
            user_id: @new_member.id
            joined_at: @new_date,
          success: (data)->
            component.reset()
            component.$root.$emit 'update_member_table', data.member_table_rows
          error: (request, status, error)->
            console.log request.responseText
            component.reset()
        }
      reset: ->
        this.new_date = moment().locale('de').format('L')
        this.new_member = null
        this.submitting = false
    computed:
      submission_enabled: ->
        (!@submitting) && (!@need_more_fields)
      need_more_fields: ->
        !(@new_date && @new_member)


  export default AddGroupMemberForm
</script>