<template>
  <div class="table-responsive">
    <vue-good-table
      :columns="columns"
      :rows="processed_rows"
      :sort-options="sort_options"
      :search-options="search_options"
      styleClass="members child_users display table card-table table-vcenter"
    >
      <template slot="table-row" slot-scope="props">
        <span v-if="props.column.field == 'last_name'">
          <a :href="props.row.href" v-if="props.row.href">{{props.row.last_name}}</a>
          <span v-if="!props.row.href">{{props.row.last_name}}</span>
        </span>
        <span v-else-if="props.column.field == 'status'">
          <a :href="'/groups/' + props.row.status_group_id + '/members'">{{props.row.status}}</a>
        </span>
        <span v-else-if="props.column.field == 'direct_group'">
          <a :href="'/groups/' + props.row.direct_group_id + '/members'">{{props.row.direct_group_name}}</a>
        </span>
        <span v-else v-html="props.formattedRow[props.column.field]"></span>
      </template>
    </vue-good-table>
  </div>
</template>

<script lang="coffee">
  Vue = require('vue').default
  moment = require('moment')
  VueGoodTable = require('vue-good-table').VueGoodTable

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
        { label: this.translate('status'), field: 'status', hidden: (! this.has_status_entries()) }
        { label: this.translate('group'), field: 'direct_group', hidden: (! this.has_direct_group_entries()) || this.has_status_entries() }
        { label: this.translate('since'), field: 'since', type: 'date', dateOutputFormat: 'dd.MM.yyyy', firstSortType: 'desc', dateInputFormat: 'dd.MM.yyyy' }
      ]
      sort_options:
        initialSortBy: { field: 'since', type: 'desc' }
    created: ->
      component = this
      @current_rows = @rows
      this.$root.$on 'add_member', component.add_member
      this.$root.$on 'search', component.search
      this.$root.$on 'update_member_table', component.update_member_table
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
      has_direct_group_entries: ->
        @rows.some (row) -> row.direct_group_name
      update_member_table: (member_table_rows)->
        @current_rows = member_table_rows
    computed:
      processed_rows: ->
        component = this
        component.current_rows.map (row)->
          row.since = component.format_date(row.joined_at)
          if row.avatar_path
            row.avatar = "<span class=\"avatar\" style=\"background-image: url(#{row.avatar_path})\"></span>"
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