<template>
  <div class="row">
    <div class="col-md-9">
      <div class="card">
        <div class="card-body">
          <vue-full-calendar
            class='card-calendar'
            :plugins="calendar_plugins"
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
  import interactionPlugin from '@fullcalendar/interaction'
  import de from '@fullcalendar/core/locales/de'
  import Vue from 'vue'
  import moment from 'moment'

  Vue.component('vue-full-calendar', FullCalendar)

  export default {
    props: ['calendars', 'timezone'],
    data() { return {
      current_calendars: this.calendars,
      calendar_plugins: [
        dayGridPlugin,
        interactionPlugin // needed for dateClick
      ],
      calendar_options: {
        header: {
          left: 'title',
          center: '',
          right: 'prev,next'
        },
        themeSystem: 'standard',
        views: {
          dayGridMonth: { buttonText: 'month' },
          //timeGridWeek: { buttonText: 'week' },
          //timeGridDay: { buttonText: 'day' }
        },
        initialView: 'dayGridMonth',
        events: [],
        editable: true,
        selectable: true,
        selectMirror: true,
        dayMaxEvents: true,
        weekends: true,
        locale: 'de',
        firstDay: 1, // Monday
        //select: this.handleDateSelect,
        //eventClick: this.handleEventClick,
        //eventsSet: this.set_events
        /* you can update a remote database when these fire:
        eventAdd:
        eventChange:
        eventRemove:
        */
      }
    } },
    created() {
      this.calendar_options.events = this.initial_events
      //console.log(this.calendar_options.events)
    },
    methods: {
      //set_events(events) {
      //  console.log("yes", events)
      //  events = this.initial_events
      //}
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
            events[e.id]['start'] = moment(e.start_at).toDate(); // Rename according to the calendar
            events[e.id]['className'] = 'bg-lime-lt'
          }
        }
        return events.filter((event) => event.id)
      }
    }
  }
</script>

<style>
</style>
