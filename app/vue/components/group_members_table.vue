<template>
  <div class="table-responsive">
    <vue-good-table
      :columns="columns"
      :rows="processed_rows"
      :sort-options="sort_options"
      :search-options="search_options"
      styleClass="members child_users display table card-table table-vcenter"
    ></vue-good-table>
  </div>
</template>

<script lang="coffee">
  `import Vue from 'vue'`
  `import moment from 'moment'`
  `import { VueGoodTable } from 'vue-good-table'`

  Vue.component 'vue-good-table', VueGoodTable

  GroupMembersTable = {
    props: ['rows'],
    data: ->
      current_rows: []
      query: null
      columns: [
        { label: "", field: 'avatar', html: true, tdClass: 'w-1' }
        { label: this.translate('last_name'), field: 'last_name' }
        { label: this.translate('first_name'), field: 'first_name' }
        { label: this.translate('name_affix'), field: 'name_affix' }
        { label: this.translate('status'), field: 'status_link', html: true, hidden: (! this.has_status_entries()) }
        { label: this.translate('since'), field: 'since', type: 'date', dateOutputFormat: 'dd.MM.yyyy', firstSortType: 'desc', dateInputFormat: 'dd.MM.yyyy' }
      ]
      sort_options:
        initialSortBy: { field: 'since', type: 'desc' }
    created: ->
      self = this
      @current_rows = @rows
      this.$root.$on 'add_member', self.add_member
      this.$root.$on 'search', self.search
    methods:
      translate: (str)->
        I18n.translate str
      format_date: (date)->
        moment(date).locale('de').format('L') if date
      add_member: (member)->
        @current_rows.push(member)
      search: (query)->
        @query = query
      has_status_entries: ->
        @rows.some (row) -> row.status
    computed:
      processed_rows: ->
        self = this
        self.current_rows.map (row)->
          row.since = self.format_date(row.joined_at)
          if row.avatar_path
            row.avatar = "<span class=\"avatar\" style=\"background-image: url(#{row.avatar_path})\"></span>"
          if row.status
            row.status_link = "<a href=\"/groups/#{row.status_group_id}/members\">#{row.status}</a>"
          row
      search_options: ->
        enabled: true
        externalQuery: @query
  }
  `export default GroupMembersTable`
</script>

<style lang="sass">
  .vgt-global-search
    display: none
</style>