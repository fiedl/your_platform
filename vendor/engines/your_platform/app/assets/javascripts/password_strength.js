var PasswordStrength = {
    watch: function (password_input_id, password_confirmation_input_id) {
        var input = $(password_input_id);
        var confirmation_input = $(password_confirmation_input_id)
        var submit = $(":submit");

        var container = $('.password_strength_container');

        var bg_elm = $('<div class="password_strength_bg" />');
        container.append(bg_elm);

        var elm = $('<div class="password_strength" />');
        elm.cur_score = 0;
        container.append(elm);

        //add separators
        for (var i = 1; i <= 3; i++) {
            var style = {left: 25*i + '%'};
            container.append($('<div class="password_strength_separator" />').css(style));
        }

        var advice = container.data('password-strength-advice');
        var min_score = container.data('min-score');
        if (min_score == null || min_score < 0 || min_score > 4) {
            min_score = 3;
        }
        var user_inputs = container.data('user-inputs');

        //shoutout to the nice guys from http://glyphicons.com/
        var info_button = $("<div class='password_strength_icon'/>");

        info_button.css("display", 'none');
        info_button.tooltip({trigger: "hover"});

        info_button.click(function (e) {e.preventDefault();});

        var info_icon = $("<i class='icon-info-sign'/>");
        info_button.append(info_icon);

        container.append(info_button);

        var password_desc = $('<div class="password_strength_desc" />');
        //password_desc.text('&nbsp;');
        container.append(password_desc);

        var score_description_map = container.data('score-descriptions')

        var last_pwd = '';
        var last_confirmation_pwd = '';

        var animator = function () {
            var pwd = input.val();
            var confirmation_pwd = confirmation_input.val();
            if (pwd == last_pwd && confirmation_pwd == last_confirmation_pwd) {
                return;
            }
            last_pwd = pwd;
            last_confirmation_pwd = confirmation_pwd;

            var score, word, tooltip;
            var found_triggerword = false;

            var triggerwords = container.data('triggerwords')
            // triggerword[0]: the actual triggerword
            // triggerword[1]: the description response
            // triggerword[2]: the tooltip

            if (triggerwords != null) {
                for (var i = 0; i< triggerwords.length; ++i){
                    var triggerword = triggerwords[i]
                    if (pwd.match(new RegExp(triggerword[0]))){
                        score = 0;
                        word = triggerword[1];
                        tooltip = triggerword[2];
                        found_triggerword = true;
                    }
                }
            }
            if (!found_triggerword) {
                score = PasswordStrength.score(pwd, user_inputs);
                tooltip = advice;
                word = score_description_map[score]
            }

            info_button.prop("title", tooltip);

            container.removeClass()
            container.addClass('password_strength_container')
            container.addClass('password_strength_score' + score)
            password_desc.text(pwd.length ? word : "");

            if (pwd.length && score < min_score) {
                info_button.show();
            } else {
                info_button.hide();
            }

            var password_mismatch = pwd != confirmation_input.val();
            if (password_mismatch){
                confirmation_input.css("background-color", "rgba(255, 218, 218, 1)");
            } else {
                confirmation_input.css("background-color", "");
            }

            if (score < min_score || password_mismatch ) {
                submit.prop("disabled", true);
            } else {
                submit.removeProp("disabled");
            }

            elm.cur_score = score;
            if (score == 0) {
                elm.css("width", "0%");
            }
            else {
                elm.css("width", (score * 25) + "%");
            }
        };

        setInterval(animator, 350);
    },
    score: function (str, user_inputs) {
        if (!window.zxcvbn) {
            return 0;
        }
        var result = zxcvbn(str, user_inputs);
        return result.score;
    }
};

// inline copy of https://github.com/dropbox/zxcvbn/blob/master/zxcvbn-async.js
(function() { var a; a=function(){ var a,b; b=document.createElement("script"); b.src="//dl.dropbox.com/u/209/zxcvbn/zxcvbn.js"; b.type="text/javascript"; b.async=!0; a=document.getElementsByTagName("script")[0]; return a.parentNode.insertBefore(b,a) }; document.readyState == 'complete' ? setTimeout(a, 0) : (null!=window.attachEvent?window.attachEvent("onload",a):window.addEventListener("load",a,!1)) }).call(this);