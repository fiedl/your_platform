<template>
  <div class="row">
    <div class="col-md-9">
      <div class="card">
        <div class="card-body">
          Coming soon ...
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="subheader mb-2">Angezeigte Kalender</div>
      <label class="form-check mb1" v-for="calendar in current_calendars">
        <input type="checkbox" class="form-check-input" v-model="calendar.checked">
        <span class="form-check-label">{{ calendar.name }}</span>
      </label>
    </div>
  </div>
</template>

<script>
  export default {
    props: ['calendars', 'timezone'],
    data() { return {
      current_calendars: this.calendars
    } }
  }
</script>

<style>
</style>
