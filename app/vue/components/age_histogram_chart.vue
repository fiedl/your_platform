<template>
  <vue-apexchart ref="apex_chart" type="bar" :options="chart_options" :series="series"></vue-apexchart>
</template>

<script lang="coffee">
  d3 = require('d3-array')

  AgeHistogramChart =
    props: ['ages']
    data: ->
      current_ages: @ages
    created: ->
      @$root.$on 'update_age_histogram', @on_update
    methods:
      on_update: (new_ages)->
        @current_ages = new_ages
    computed:
      series: -> [
        {name: "Mitglieder im Alter", data: @histogram_ydata}
      ]
      age_min: ->
        20
      age_max: ->
        100
      number_of_bins: ->
        20
      age_step: ->
        (@age_max - @age_min) / @number_of_bins
      age_histogram: ->
        histogram_generator = d3.histogram().domain([@age_min, @age_max]).thresholds(@number_of_bins)
        histogram = histogram_generator(@valid_ages)
        histogram
      valid_ages: ->
        @current_ages.filter((age) -> (age && age > 0))
      histogram_xdata: ->
        component = this
        d3.ticks(@age_min, @age_max, @number_of_bins).map (age)->
          "#{age}-#{age + component.age_step}"
      histogram_ydata: ->
        @age_histogram.map (row) -> row.length
      chart_options: ->
        grid:
          show: false,
          padding:
            left: 0,
            top: 0,
            bottom: 0,
            right: 0
        xaxis:
          labels: {show: true},
          categories: @histogram_xdata,
          tooltip: {enabled: true}
        yaxis:
          show: false
        chart:
          toolbar: {show: false},
          animations: {enabled: true},
          zoom: {enabled: false},
          #parentHeightOffset: 0,
          sparkline: {enabled: true}
        dataLabels: {enabled: false},
        title:
          text: 'Altersverteilung',
          floating: false,
          offsetY: -5,
          align: 'left',

  export default AgeHistogramChart
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