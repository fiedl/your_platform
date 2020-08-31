<template>
  <a :href="href" class="card">
    <div class="card-body">
      <div class="d-flex align-items-center">
        <div class="subheader">Mitglieder</div>
        <div class="ml-auto lh-1" v-if="sub_charts.length > 1">
          <div class="dropdown">
            <a class="dropdown-toggle text-muted" href="#" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              {{ current_chart.name }}
            </a>
            <div class="dropdown-menu dropdown-menu-right">
              <a class="dropdown-item" href="#" v-for="sub_chart in sub_charts" v-on:click="current_chart = sub_chart" :class="{active: (sub_chart.name == current_chart.name)}">{{sub_chart.name}}</a>
            </div>
          </div>
        </div>
      </div>
      <div class="d-flex align-items-baseline">
        <div class="h1 mb-0 mr-2">{{ current_chart.count }}</div>
        <div class="mr-auto" :title="current_chart.change_title">
          <span class="text-red d-inline-flex align-items-center lh-1" v-if="current_chart.change < 0">
            {{ current_chart.change }}
          </span>
          <span class="text-green d-inline-flex align-items-center lh-1" v-else>
            +{{ current_chart.change }}
          </span>
        </div>
      </div>
      <div class="d-flex mt-2">
        <div>{{ group_name }}</div>
      </div>
    </div>
    <div class="chart_section">
      <vue-apexchart type="area" :options="options" :series="series" :height="height"></vue-apexchart>
    </div>
    <slot></slot>
  </a>
</template>

<script lang="coffee">
NumberOfMembersChart = {
  props: ['height', 'sub_charts', 'group_name', 'years', 'href'],
  mounted: ->
    @current_chart = @sub_charts[0]
  data: -> {
    current_chart: {},
  }
  computed: {
    series: -> [
      {name: I18n.translate('members'), data: this.current_chart.data_points}
    ]
    options: -> {
      grid: {
        show: false,
        padding: {
          left: 0,
          top: 0,
          bottom: 0,
          right: 0
        }
      },
      xaxis: {
        labels: {show: false},
        categories: this.years,
        tooltip: {enabled: false}
      }
      yaxis: {
        show: false
      },
      chart: {
        toolbar: {show: false},
        animations: {enabled: false},
        zoom: {enabled: false},
        parentHeightOffset: 0,
        sparkline: {enabled: true}
      },
      stroke: {
        curve: 'straight',
        colors: ['#4c87cf'],
        width: 1
      },
      fill: {
        type: 'solid',
        opacity: 0.2
      },
      dataLabels: {enabled: false},
    }
  }
}
`export default NumberOfMembersChart`
</script>

<style lang="sass">
  .chart_section
    margin-top: -20px
</style>