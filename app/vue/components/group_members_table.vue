<template>
  <div>
    <div class="card-header d-flex">
      <vue-select :options="vue_select_options" v-model="query" class="form-control" placeholder="Mitgliederliste filtern (Name, Status, Beitrittsjahr)" @search="handle_search">
        <template #no-options="{ search, searching, loading }">
        </template>
      </vue-select>
      <div class="results text-muted text-nowrap ml-2" v-if="query && query.length > 3">
        {{ filtered_rows.length }} Treffer
      </div>
    </div>
    <div class="table-responsive">
      <vue-good-table
        ref="good_table"
        :columns="columns"
        :rows="filtered_rows"
        :sort-options="sort_options"
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
  </div>
</template>

<script lang="coffee">
  Vue = require('vue').default
  moment = require('moment')
  VueGoodTable = require('vue-good-table').VueGoodTable
  VueSelect = require('vue-select').default # https://github.com/sagalbot/vue-select

  Vue.component 'vue-good-table', VueGoodTable
  Vue.component 'vue-select', VueSelect

  GroupMembersTable = {
    props: ['rows', 'current_user'],
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
      vue_select_options: []
    created: ->
      component = this
      @current_rows = @rows
      this.$root.$on 'add_member', component.add_member
      this.$root.$on 'search', component.search
      this.$root.$on 'update_member_table', component.update_member_table
      @vue_select_options = @default_vue_select_options
    methods:
      translate: (str)->
        I18n.translate str
      format_date: (date)->
        moment(date).locale('de').format('L') if date
      add_member: (member)->
        @current_rows.push(member)
      search: (query)->
        @query = query
      handle_search: (query)->
        if query.length > 2
          result = Object.assign [], @default_vue_select_options
          result.unshift(query) unless result.includes(query)
          @vue_select_options = result
          @query = query
      has_status_entries: ->
        @rows.some (row) -> row.status
      has_direct_group_entries: ->
        @rows.some (row) -> row.direct_group_name
      update_member_table: (member_table_rows)->
        @current_rows = member_table_rows
    computed:
      filtered_rows: ->
        component = this
        if @query && @query.length > 2
          @processed_rows.filter (row)->
            [row.last_name, row.first_name, row.status, row.since].join(" ").toLowerCase().includes(component.query.toLowerCase())
        else
          @processed_rows
      processed_rows: ->
        component = this
        component.current_rows.map (row)->
          row.since = component.format_date(row.joined_at)
          if row.avatar_path
            row.avatar = "<span class=\"avatar\" style=\"background-image: url(#{row.avatar_path})\"></span>"
          row
      statuses: ->
        @current_rows.map((row) -> row.status).unique()
      default_vue_select_options: ->
        options = @statuses.sort().filter((status) -> status != "Philister") # because I'd like to move this entry up
        options.unshift("Philister") if @statuses.includes("Philister")
        options.unshift("Bursch") if @statuses.includes("Aktiver Bursch")
        options.unshift("Fux") if @statuses.includes("Kraßfux")
        options.unshift(new Date().getFullYear().toString())
        options.unshift(@current_user.last_name) if @current_user
        options
      ages: ->
        @filtered_rows.map((row)-> row.age).filter((age) -> (age && age > 0))
      statuses: ->
        @filtered_rows.map((row)-> row.status)
    watch:
      ages: (new_ages, old_ages)->
        @$root.$emit('update_age_histogram', new_ages)
      statuses: (new_statuses)->
        @$root.$emit('update_status_histogram', new_statuses)
  }
  `export default GroupMembersTable`
</script>

<style lang="sass">
  .vgt-global-search
    display: none
  .vs__no-options
    display: none
</style>