module PasswordHelper

  def password_strength_container
    content_tag(:div, '', class: 'password_strength_container', data: {
      lib_script_path: asset_path('password_strength.js'),
      min_score: 4,
      password_strength_advice: t('password_strength.advice'),
      score_descriptions: t([:s0, :s1, :s2, :s3, :s4],
      scope: 'password_strength.score_descriptions'),
      user_inputs: [],
      triggerwords: [
        # Eingabe-Regexp, Antwort des Systems, Tooltip
        ['abend lustig bowle lecker', 'Selber ausdenken!', ''],
        ['abendlustigbowlelecker', 'Selber ausdenken!', ''],
        ['p4ssw0rt!', 'Schlechte Idee!', ''],
        ['correcthorsebatterystaple', 'Plagiat!! :)', "Whoa there, don't take advice from a webcomic too literally"],
        ['correct horse battery staple', 'Gute Idee :/', "Whoa there, don't take advice from a webcomic too literally"],
        ['Tr0ub4do[u]?r&3','Lieber nochmal nachdenken','']
      ]
    }).html_safe
  end
  
end