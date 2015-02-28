/* German translation for the jQuery Timepicker Addon */
/* Written by Marvin */
/* Ergänzungen SF */
(function($) {
	$.timepicker.regional['de'] = {
		timeOnlyTitle: 'Zeit wählen',
		timeText: 'Zeit',
		hourText: 'Stunde',
		minuteText: 'Minute',
		secondText: 'Sekunde',
		millisecText: 'Millisekunde',
		microsecText: 'Mikrosekunde',
		timezoneText: 'Zeitzone',
		currentText: 'Jetzt',
		closeText: 'Fertig',
		amNames: ['vorm.', 'AM', 'A'],
		pmNames: ['nachm.', 'PM', 'P'],
    dayNames: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'],
  	dayNamesShort: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
  	dayNamesMin: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
    monthNames: ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
    firstDay: 1,
		isRTL: false
	};
	$.timepicker.setDefaults($.timepicker.regional['de']);
})(jQuery);
