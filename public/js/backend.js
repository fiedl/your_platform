var changesSavedText = 'Änderung wurde gespeichert.';
var revertChangesText = 'Letzte Änderung Rückgängig machen.';

function deletePage(id) {
    $.ajax({
        beforeSend: function(XMLHttpRequest) {
            $.fancybox.showActivity();
        },
        dataType: "json",
        success: function(data, textStatus) {
            $.fancybox.close();
            location.reload();
        },
        error: function(jqXHR, textStatus) {
            $.showMessage(jqXHR.responseText, message_options_failure);
        },
        complete:function () {
            $.fancybox.hideActivity();
        },
        type: "post",
        url: webroot + "pages/delete/" + id + "/"
    });
    return false;
}

// Neue Bindings für Enter, ESC und Klick ausserhalb der Fancybox für speichern und abbrechen
function newFancyBindings(saveFunc){
    window.setTimeout(function(){
        //overlay unbinden und neu binden
        $('#fancybox-overlay').unbind('click');
        $('#fancybox-overlay').bind('click', function(){
            if(checkPflicht()){
                pflichtError(errorText);
            } else {
                window[saveFunc]();
            }
        });
        //key unbinden und neu binden
        $(document).unbind('keydown.fb');
        $(document).bind('keydown.fb', function(e) {
            if (e.keyCode == 27) {
                e.preventDefault();
                fancyClose();
            }

            if (e.keyCode == 13) {
                e.preventDefault();
                if(window[saveFunc]()){
                    fancyClose();
                }
            }
        });
    }, 500);
}

// Speichern Bestätigungsdialog
function confirmSave(saveFunc){
    newConfirm({
        text:'Es wurden Daten geändert. Sollen die Daten gespeichert werden?',
        okText:"Daten speichern",
        abortText:"Daten verwerfen",
        okFunc:saveFunc,
        abortFunc:"fancyClose"
    });
}

// Fehler bestätigungsdialog für Pflichtfelder
function pflichtError(errorText){
    newConfirm({
        title:"Fehler",
        text:errorText,
        okText:"Ok",
        abortText: false
    });
    return true;
}

function showRevert(){
    $('#revert_changes').show();
}

// "Änderungen rückgangig machen"
function revertChanges(data) {
    $.ajax({
        type:"post",
        url:data.url,
        data: data.data,
        beforeSend:function (XMLHttpRequest) {
        },

        success:function (data, textStatus) {
            location.reload();
        },

        error:function (jqXHR, textStatus) {
            $.showMessage(jqXHR.responseText, message_options_failure);
        }
    });
    return false;
}
