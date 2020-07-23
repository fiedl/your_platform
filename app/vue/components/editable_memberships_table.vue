<template>
  <div>
    <table class="table table-vcenter card-table">
      <thead>
        <tr>
          <th class="w-1"></th>
          <th>Amtsträger</th>
          <th>Von</th>
          <th>Bis</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="membership in memberships">
          <td>
            <span class="avatar"
              :style="'background-image: url(' + membership.user.avatar_path + ')'"></span>
            </td>
          <td>
            <a :href="'/users/' + membership.user.id">{{ membership.user.title }}</a>
          </td>
          <td>
            <vue-editable
              type="date"
              :initialValue="formatted_date(membership.valid_from)"
              :editable="editable"
              :url="'/memberships/' + membership.id"
              paramKey="membership[valid_from]"
            ></vue-editable>
          </td>
          <td>
            <vue-editable
              type="date"
              :initialValue="formatted_date(membership.valid_to)"
              :editable="editable"
              :url="'/memberships/' + membership.id"
              paramKey="membership[valid_to]"
            ></vue-editable>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script lang="coffee">
  `import moment from 'moment'`

  EditableMembershipsTable =
    props: ['initial_memberships', 'editable']
    data: ->
      memberships: []
    created: ->
      @memberships = @initial_memberships
    methods:
      formatted_date: (date)->
        moment(date).locale('de').format('L') if date

  `export default EditableMembershipsTable`
</script>