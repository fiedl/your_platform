var admin_edit_mode = false;

$(function(){
    navi_fix();
    init_box_minimizer();
    bindFancybox();
});

loadTinyMce = false; // TinyMce laden

$(document).ready(function(){
    // Tastaturkürzel
    /*jQuery(document).bind('keydown', 's',function (evt){
        $('#header_search_input').focus();
        return false;
    });*/

    loadOnLoad();
});

if (typeof $.datepicker == 'object') {
    $.datepicker.setDefaults({
        showOn: "both",
        buttonImage: webroot + "img/calendar.png",
        buttonImageOnly: true,
        dateFormat: 'dd.mm.yy',
        dayNames: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'],
        dayNamesMin: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
        dayNamesShort: ['Son', 'Mon', 'Die', 'Mit', 'Don', 'Fre', 'Sam'],
        monthNames: ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
        monthNamesShort: ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez']
    });
}

//newConfirm({title:"titel",text:"text",okText:"ok Text",abortText:"abbrechen",okFunc:"function name",okFuncParams:okfuncparams,abortFunc:"function name",abortFuncParams:abortfuncparams});
function newConfirm(data){
    var title, text, okText, abortText, okFuncParams, abortFuncParams;
    if(typeof(data.title) == "string"){
        title = data.title;
    } else {
        title = 'Bitte bestätigen Sie';
    }
    if(typeof(data.text) == "string"){
        text = data.text;
    } else {
        text = '';
    }
    if(typeof(data.okText) == "string"){
        okText = data.okText;
    } else {
        okText = 'Ja';
    }
    if(typeof(data.abortText) == "string"){
        abortText = data.abortText;
    } else if (typeof data.abortText == 'undefined'){
        abortText = 'Abbrechen';
    }
    if(typeof(data.okFuncParams) == "string" || typeof(data.okFuncParams) == "object"){
        okFuncParams = data.okFuncParams;
    } else {
        okFuncParams = '';
    }
    if(typeof(data.abortFuncParams) == "string" || typeof(data.abortFuncParams) == "object"){
        abortFuncParams = data.abortFuncParams;
    } else {
        abortFuncParams = '';
    }

    var vals = new Object;
    vals[okText] = function() {
        if(typeof(data.okFunc) == "string"){
            window[data.okFunc](okFuncParams);
        }
        $( this ).dialog( "close" );
    };
    if(typeof(data.abortFunc) == "string"){
        vals[abortText] = function() {

            window[data.abortFunc](abortFuncParams);
            $( this ).dialog( "close" );
        };
    } else {
        if(typeof(abortText) == "string"){
            vals[abortText] = function() {
                $( this ).dialog( "close" );
            };
        }
    }

    $('#dialog-confirm').html(text);
    $( "#dialog-confirm" ).dialog({
        modal: true,
        title: title,
        buttons: vals
    });
    return false;
}

function fancyClose(){
    $.fancybox.close();
}

$(function() {
    $('#backendBar_content_navi ul li ul.sub').each(function () {
        $(this).css('min-width', $(this).parent().width());
        var parent = $(this).parent();
        var pos = $(parent).position();
        var width_diff = ($(this).outerWidth() - $(parent).outerWidth());
        $(this).css('left', '-1px');
        $(this).css('top', ($(parent).outerHeight() - 1) + 'px');
    });
});

function navi_fix(){
    $('#content .subnavi').each(function(){
        var subnavis = this;
        $(subnavis).each(function(){
            var subnavi = this;
            if($(subnavi).find('.active').length < 1){
                $(subnavi).find('>li').show();
            } else {
                $(subnavi).find('li:first').show();
                $(subnavi).find('.active').parent().show();
                $(subnavi).find('.active:last').parent().parent().children('li').show();
            }
        });
    });
}

function init_box_minimizer(){
    if($('.box_minimize').length > 0){
        $('.box_minimize').each(function(){
            var minimize_button = this;
            $(minimize_button).click(function(){
                $(this).toggleClass('closed');
                $(this).parent().children('.box_content').slideToggle('fast');
            });
        });
    }
}

function bindFancybox() {
    $(".fancybox_cla").fancybox({
        'speedIn'           : 0,
        'speedOut'          : 0,
        'changeSpeed'       : 0,
        'overlayOpacity'    : 0.3,
        'overlayColor'      : '#000',
        'padding'           : 0,
        'showCloseButton'   : false,
        'titleShow'         : false,
        'centerOnScroll'    : true,
        'hideOnOverlayClick': true,
        'hideOnContentClick': false
    });

    var selector;
    $(".fancybox").fancybox({
        'myTop'             : 1,
        'myleft'            : 1,
        'speedIn'           : 0,
        'speedOut'          : 0,
        'changeSpeed'       : 0,
        'overlayOpacity'    : 0.3,
        'overlayColor'      : '#000',
        'padding'           : 0,
        'showCloseButton'   : false,
        'titleShow'         : false,
        'centerOnScroll'    : false,
        'hideOnOverlayClick': true,
        'hideOnContentClick': false,
        'transitionIn'      : "none",
        'transitionOut'     : "none",
        'showNavArrows'     : false,
        'onComplete'        : function(){
            loadOnLoad();
            if ($(this.orig).get(0).tagName == 'IMG') {
                selector = '.placeholder.' + $(this.orig).parent().attr('rel');
            } else {
                selector = '.placeholder.' + $(this.orig[0]).attr('rel');
            }

            var offset = $(selector).offset();
            if (offset !== null) {
                this.myTop = offset.top - 20;
                this.myLeft = offset.left - 20;
                $('#fancybox-wrap').css({
                    'left': (this.myLeft) + 'px',
                    'top': (this.myTop) + 'px'
                });
                if($(selector).hasClass('overlay')){
                    var addHeight = (($('#fancybox-wrap .fancybox').height()) - ($('.box.'+ $(this.orig[0]).attr('rel')).height()));
                    $('.box.'+ $(this.orig[0]).attr('rel') + ' .box_content').animate({
                        'padding-bottom': (addHeight + 9)
                    }, 100);
                } else {
                    $(selector).animate({
                        'height': ($('#fancybox-wrap .fancybox').height() + 15)
                    }, 100);
                }
                $('#fancybox-bg-n, #fancybox-bg-ne, #fancybox-bg-e, #fancybox-bg-se, #fancybox-bg-s, #fancybox-bg-sw, #fancybox-bg-w, #fancybox-bg-nw').css('background', 'none');
            }
        },

        'onClosed'          : function(){

            $('.box.'+ $(this.orig[0]).attr('rel') + ' .box_content').animate({
                'padding-bottom': 10
            }, 100);
            $(selector).animate({
                'height': 0
            }, 100);

        }
    });
}

$(function() {
    $(".fancybox_img").fancybox({
        'overlayOpacity'    : 0.3,
        'overlayColor'      : '#000',
        'padding'           : 0
    });
});


/**
 *
 */
function highlight(e, text, bgcolor, append) {
    if (typeof append == 'undefined') {
        append = false;
    }
    if($.trim($(e).html()) != text){
        if (bgcolor !== undefined) {
            $(e).css('background-color', bgcolor);
            setTimeout(function() {
                if (append) {
                    $(e).append(text);
                    $(e).autolink();
                } else {
                    $(e).html(text);
                    $(e).autolink();
                }
                $(e).effect('highlight', {
                    color: '#fbb900'
                }, 1000 ,fct);
            }, 1000 );
        } else {
            setTimeout(function() {
                if (append) {
                    $(e).append(text);
                    $(e).autolink();
                } else {
                    $(e).html(text);
                    $(e).autolink();
                }
                $(e).effect('highlight', {
                    color: '#fbb900'
                }, 1000);
            }, 1000 );
        }

        function fct() {
            $(e).removeAttr('style');
        }
    }
}

/**
 * Wird beim ersten Laden sowie nach allen
 * content-verändernden Ajax Requests ausgeführt
 */
function loadOnLoad() {
    $('.emptyme').focus(function() {
        if ($(this).val() == $(this).attr('title')) {
            $(this).val('');
        }
    });
    $('.emptyme').blur(function() {
        if ($(this).val() == '') {
            $(this).val($(this).attr('title'));
        }
    });

    $('a').focus(function() {
        $(this).blur();
    });

    if (typeof bindTooltip != 'undefinded') {
        bindTooltip();
    }

    if (typeof $().dataTable == 'function') {
        $('.supertable').dataTable( {
            "sScrollX": "100%",
            "fnDrawCallback": function() {
                formatSupertable();
                tableFooter();
            },
            "bFilter": true,
            "bJQueryUI": true,
            "oLanguage": {
                "sProcessing":   "Bitte warten...",
                "sLengthMenu":   "_MENU_ Einträge anzeigen",
                "sZeroRecords":  "Keine Einträge vorhanden.",
                "sInfo":         "_START_ bis _END_ von _TOTAL_ Einträgen",
                "sInfoEmpty":    "0 bis 0 von 0 Einträgen",
                "sInfoFiltered": "(gefiltert von _MAX_  Einträgen)",
                "sInfoPostFix":  "",
                "sSearch":       "Suchen",
                "sUrl":          "",
                "oPaginate": {
                    "sFirst":    "Erster",
                    "sPrevious": "Zurück",
                    "sNext":     "Nächster",
                    "sLast":     "Letzter"
                }
            }
        });

        $('.supertable tbody tr').live('click', function () {
            $(this).toggleClass('row_selected');
            $(this).find('td').toggleClass('col_selected');
            if ($(this).closest('.dataTables_wrapper').find('.dataTables_info_selected_rows').length) {
                $(this).closest('.dataTables_wrapper').find('.dataTables_info_selected_rows').html($(this).closest('.dataTables_wrapper').find('tr.row_selected').length + ' Zeilen ausgewählt');
            } else {
                $(this).closest('.dataTables_wrapper').find('.dataTables_info').after('<div class="dataTables_info_selected_rows"></div>');
                $(this).closest('.dataTables_wrapper').find('.dataTables_info_selected_rows').html($(this).closest('.dataTables_wrapper').find('tr.row_selected').length + ' Zeilen ausgewählt');
            }
            tableFooter();
        });
    }

    $('ul.subnavi li').hover(function() {
        if (admin_edit_mode) {
            $(this).find('div.page_admin_controls').stop(true,true).fadeIn('fast');
        }
    }, function () {
        $(this).find('div.page_admin_controls').stop(true,true).fadeOut('fast');
    });


    if (loadTinyMce) {
        tinyMCE.init({
            // General options
            mode : "textareas",
            // Location of TinyMCE script

            // General options
            theme : "advanced",
            plugins : "advimage,paste,visualchars",
            theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,formatselect",
            theme_advanced_buttons2 : "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup",
            theme_advanced_buttons3 : false,
            theme_advanced_toolbar_location : "top",
            theme_advanced_toolbar_align : "left",
            theme_advanced_statusbar_location : "bottom",
            theme_advanced_resizing : true,
            width: "630",
            language : 'de'
        });
    }
}

function showAjaxLoader(selector, append){
    if (append) {
        $(selector).append('<img src="' + webroot + 'img/ui-anim_basic_16x16.gif" id="ajaxLoader" alt="ajax loader" />');
    } else {
        $(selector).after('<img src="' + webroot + 'img/ui-anim_basic_16x16.gif" id="ajaxLoader" alt="ajax loader" />');
    }

}

function hideAjaxLoader(){
    $('#ajaxLoader').remove();
}

function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

var datepicker_options = {
    showOn: "button",
    buttonImage: webroot + "img/calendar.png",
    buttonImageOnly: true,
    dateFormat: 'dd.mm.yy',
    dayNames: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'],
    dayNamesMin: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
    dayNamesShort: ['Son', 'Mon', 'Die', 'Mit', 'Don', 'Fre', 'Sam'],
    monthNames: ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
    monthNamesShort: ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez']
};

message_options_success = {
    id: 'alert_message_success',
    position: 'top',
    delay: 5000,
    fontSize: '20px',
    size: 60
};
message_options_failure = {
    id: 'alert_message_failure',
    position: 'top',
    delay: 5000,
    fontSize: '20px',
    size: 60
};

jQuery.fn.autolink = function () {
    return this.each( function(){
        var re = /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g;
        $(this).html( $(this).html().replace(re, '<a href="$1" target="_blank">$1</a> ') );
    });
}

function bindTooltip() {
    if (typeof $().tooltip == 'function') {
        $(".help").tooltip({
            tip: '.tooltip',
            effect: 'fade',
            fadeOutSpeed: 100,
            predelay: 0,
            position: "top right",
            offset: [0, 0]
        });
    }
}

function formatSupertable() {
    // Währungen
    $('.supertable tbody td.currency').each(function() {
        if (parseFloat($(this).attr('rel')) >= 0) {
            $(this).addClass('positive');
        } else {
            $(this).addClass('negative');
        }
        $(this).html($(this).attr('rel').replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1.") + ' €');
    });
}
function tableFooter() {
    // Währung
    $('.dataTables_scrollFoot .supertable tfoot th.footer_currencies').each(function() {
        if ($(this).closest('.dataTables_scroll').find('td.col_selected').length > 0) {
            var selector = '.' + $(this).attr('rel') + '.col_selected';
        } else {
            var selector = '.' + $(this).attr('rel');
        }
        var sum = 0;
        $(this).closest('.dataTables_scroll').find(selector).each(function() {
            sum += parseFloat($(this).attr('rel'));
        });
        $(this).html(sum.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1.") + ' €');
    });

    // Datum
    $('.dataTables_scrollFoot .supertable tfoot th.footer_dates').each(function() {
        if ($(this).closest('.dataTables_scroll').find('td.col_selected').length > 0) {
            var selector = '.' + $(this).attr('rel') + '.col_selected';
        } else {
            var selector = '.' + $(this).attr('rel');
        }
        var smallest = 10000000000;
        var biggest = -10000000000;
        $(this).closest('.dataTables_scroll').find(selector).each(function() {
            if ($(this).attr('rel') > biggest) {
                biggest = $(this).attr('rel');
            }
            if ($(this).attr('rel') < smallest) {
                smallest = $(this).attr('rel');
            }
        });
        var date = new Date((smallest * 1000));
        smallest = (date.getDate() < 10 ? '0' + date.getDate() : date.getDate()) + '.' + (date.getMonth() < 9 ? '0' + (date.getMonth() + 1) : (date.getMonth() + 1)) + '.' + date.getFullYear();
        date = new Date((biggest * 1000));
        biggest = (date.getDate() < 10 ? '0' + date.getDate() : date.getDate()) + '.' + (date.getMonth() < 9 ? '0' + (date.getMonth() + 1) : (date.getMonth() + 1)) + '.' + date.getFullYear();
        $(this).html(smallest + ' - ' + biggest);
    });
}

function startEditMode() {
    if (!admin_edit_mode) {
        admin_edit_mode = true;
        $('#start_edit a').html('Bearbeiten an');
    } else {
        admin_edit_mode = false;
        $('#start_edit a').html('Bearbeiten aus');
    }
}
