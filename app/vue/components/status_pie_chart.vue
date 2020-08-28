<template>
  <vue-apexchart ref="apex_chart" type="pie" :options="chart_options" :series="series"></vue-apexchart>
</template>

<script lang="coffee">
  StatusPieChart =
    props: ['statuses', 'title']
    data: ->
      current_statuses: @statuses
    created: ->
      @$root.$on 'update_status_histogram', @on_update
    methods:
      on_update: (new_statuses)->
        @current_statuses = new_statuses
    computed:
      series: -> @histogram_ydata
      unique_statuses: ->
        @current_statuses.unique()
      status_histogram: ->
        histogram = {}
        for status in @unique_statuses
          histogram[status] = 0
        for status in @current_statuses
          histogram[status]++
        histogram
      histogram_xdata: ->
        @unique_statuses
      histogram_ydata: ->
        data_array = []
        for status in @unique_statuses
          data_array.push @status_histogram[status]
        data_array
      chart_options: ->
        grid:
          show: false,
          padding:
            left: 0,
            top: 0,
            bottom: 0,
            right: 0
        labels: @histogram_xdata
        legend:
          position: 'bottom'
        chart:
          toolbar: {show: false},
          animations: {enabled: true},
          zoom: {enabled: false},
          width: '100%'
          #parentHeightOffset: 0,
          sparkline: {enabled: true}
        dataLabels: {enabled: true},
        title:
          text: if @title == null then 'Statusverteilung' else @title,
          floating: false,
          offsetY: -5,
          align: 'left',

  export default StatusPieChart
</script>

<style lang="sass">
  .apexcharts-title-text
    // tabler .subheader
    font-size: .625rem
    font-weight: 500
    text-transform: uppercase
    letter-spacing: .04em
    line-height: 1.6
    color: #6e7582
    margin-bottom: 3px
</style>