<template>
  <div>
    <label class="form-label">Mitglied manuell in "{{group.name}}" eintragen:</label>
    <vue-user-select placeholder="Bestehendes Mitglied suchen und eintragen" v-model="new_member" />

    <div v-if="new_member">
      <label class="form-label mt-4">Mitgliedschaft beginnt am:</label>
      <vue-datepicker v-model="new_date"/>

      <button class="btn btn-outline-primary mt-4" @click="add_new_member">Eintragen</button>
    </div>
  </div>
</template>

<script lang="coffee">
  `import moment from 'moment'`
  `import Api from '../api.coffee'`

  AddGroupMemberForm =
    props: ['group']
    data: ->
      new_date: moment().toDate()
      new_member: null
    methods:
      add_new_member: ->
        this.new_member.joined_at = this.new_date
        this.$root.$emit 'add_member', this.new_member
        Api.post "groups/#{@group.id}/members", {
          data:
            user_id: @new_member.id
            joined_at: @new_date
        }
        this.reset()
      reset: ->
        this.new_date = moment().toDate()
        this.new_member = null
    computed:
      formatted_new_date: ->
        moment(this.new_date).locale('de').format('L')
  `export default AddGroupMemberForm`
</script>