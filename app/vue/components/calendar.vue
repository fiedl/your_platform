<template>
  <div class="row">
    <div class="col-md-9">
      <div class="card">
        <div class="card-body">
          <vue-full-calendar
            class='demo-app-calendar'
            :options='calendar_options'>
            <template v-slot:eventContent='arg'>
              <b>{{ arg.timeText }}</b>
              <i>{{ arg.event.title }}</i>
            </template>
          </vue-full-calendar>
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
  import FullCalendar from '@fullcalendar/vue'
  import dayGridPlugin from '@fullcalendar/daygrid'
  import timeGridPlugin from '@fullcalendar/timegrid'
  import interactionPlugin from '@fullcalendar/interaction'
  import Vue from 'vue'

  Vue.component('vue-full-calendar', FullCalendar)

  export default {
    props: ['calendars', 'timezone'],
    data() { return {
      current_calendars: this.calendars,
      calendar_options: {
        plugins: [
          dayGridPlugin,
          timeGridPlugin,
          //interactionPlugin // needed for dateClick
        ],
        headerToolbar: {
          left: 'prev,next today',
          center: 'title',
          right: 'dayGridMonth,timeGridWeek,timeGridDay'
        },
        initialView: 'dayGridMonth',
        initialEvents: this.initial_events, //[], //INITIAL_EVENTS, // alternatively, use the `events` setting to fetch from a feed
        editable: true,
        selectable: true,
        selectMirror: true,
        dayMaxEvents: true,
        weekends: true,
        //select: this.handleDateSelect,
        //eventClick: this.handleEventClick,
        //eventsSet: this.handleEvents
        /* you can update a remote database when these fire:
        eventAdd:
        eventChange:
        eventRemove:
        */
      }
    } },
    created() {

    },
    methods: {
    },
    computed: {
      initial_events() {
        let events = [];
        for(let calendar of this.calendars) {
          for(let e of calendar.events) {
            events[e.id] = events[e.id] || e;
            // Add calendars
            if(!events[e.id].calendarIds) {
              events[e.id].calendarIds = [];
            }
            events[e.id].calendarIds.push(calendar.id); // Calendars it belongs to
            events[e.id]['title'] = e.name; // Rename according to the calendar
          }
        }
        return events
      }
    }
  }
</script>

<style>
</style>
