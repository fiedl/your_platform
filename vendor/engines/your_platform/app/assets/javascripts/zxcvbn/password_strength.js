var PasswordStrength = {
    watch: function (password_input_id, password_confirmation_input_id) {
        var input = $(password_input_id);
        var confirmation_input = $(password_confirmation_input_id)
        var submit = $(":submit");

        var container = $('<div class="password_strength_container" />');
        input.parent().append(container);

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

        var advice = "A good password is easy to remember but hard for a stranger to guess. Uncommon words work well, but only if you use several. Also helpful: non-standard uPPercasing, creative spelllling, personal neologisms, and non-obvious numbers and symbols (using $ for s or 0 for o is too obvious!)";
        var info_button = $("<span class='password_strength_icon'/>");

        //var info_button = $("<a href='#' tabindex='-1' class='password_strength_icon' />");
        //info_button.val(Sprite.make('web', 'information'));
        info_button.text('?');
        info_button.css("display", 'none');
        info_button.tooltip({trigger: "hover"});
        info_button.prop("title", advice);

        info_button.click(function (e) {e.preventDefault();});
        container.append(info_button);

        var password_desc = $('<div class="password_strength_desc" />');
        //password_desc.text('&nbsp;');
        container.append(password_desc);

        var color_map = [
            "",
            "#c81818",
            "#ffac1d",
            "#a6c060",
            "#27b30f"
        ];

        var word_map = [
            // TRANSLATORS the following strings refer to a password strength meter on the registration page
            ["", "Very weak"],
            ["#c81818", "Weak"],
            ["#e28f00", "So-so"],
            ["#8aa050", "Good"],
            ["#27b30f", "Great!"]
        ];

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

            var score, word;

            if (pwd == 'correcthorsebatterystaple' || pwd == 'Tr0ub4dour&3' || pwd == 'Tr0ub4dor&3') { // easteregg
                score = 0;
                word = ['', 'lol'];
                if (pwd == 'correcthorsebatterystaple') {
                    // TRANSLATORS this text is displayed rarely, whenever a user selects a password that is from this comic:
                    // http://imgs.xkcd.com/comics/password_strength.png
                    info_button.prop("title","Whoa there, don't take advice from a webcomic too literally ;)")
                } else {
                    // TRANSLATORS this text is displayed rarely, whenever a user selects a password that is from this comic:
                    // http://imgs.xkcd.com/comics/password_strength.png
                    info_button.prop("title","Guess again")
                }
            } else {
                score = PasswordStrength.score(pwd);
                word = word_map[score];
                info_button.prop("title", advice);
            }

            password_desc.css("color", word[0]);
            password_desc.text(pwd.length ? word[1] : "");

            if (pwd.length && score < 3) {
                info_button.show();
            } else {
                info_button.hide();
                if (info_button.tooltip) {
                    //info_button.tooltip.hide();
                }
            }

            var password_mismatch = pwd != confirmation_input.val();
            if (password_mismatch){
                confirmation_input.css("background-color", "rgba(255, 218, 218, 1)");
            } else {
                confirmation_input.css("background-color", "");
            }

            if (score < 4 || password_mismatch ) {
                submit.prop("disabled", true);
            } else {
                submit.removeProp("disabled");
            }

            var color_ind = score;
            elm.css("backgroundColor", color_map[color_ind]);
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
    get_user_inputs: function () {
        return ["wingolf", "kanne", "bier", "bierjunge", "bundesbruder", "bibel", "gott"];
    },
    score: function (str) {
        if (!window.zxcvbn) {
            return 0;
        }
        var result = zxcvbn(str, PasswordStrength.get_user_inputs());
        return result.score;
    }
};

// inline copy of /assets/zxcvbn-async.js
(function() { var a; a=function(){ var a,b; b=document.createElement("script"); b.src="/assets/zxcvbn/zxcvbn-async.js"; b.type="text/javascript"; b.async=!0; a=document.getElementsByTagName("script")[0]; return a.parentNode.insertBefore(b,a) }; document.readyState == 'complete' ? setTimeout(a, 0) : (null!=window.attachEvent?window.attachEvent("onload",a):window.addEventListener("load",a,!1)) }).call(this);