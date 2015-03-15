class BashpassPassword < Password
  
  def initialize
    generate!
  end
  
  def self.generate
    correct_battery_horse_staple_de
  end
  
  # This uses bashpass and a German dictionary to generate xkcd passwords
  # like "correct horse battery staple".
  #
  # See: vendor/scripts/bashpass
  #
  def self.correct_battery_horse_staple_de
    `cd #{bashpass_dir} && #{osx_shuf_path_workaround} #{bashpass_command}`.gsub("\n", "").gsub(" n ", "")
  end
  
  def self.bashpass_dir
    YourPlatform::Engine.root.join('vendor/scripts/bashpass').to_s
  end
  
  def self.bashpass_command
    './bashpass -d german.dic -n 4 |tr "&1234567890\`=@+#~\!\%*_^-" " "'
  end
  
  def self.osx_shuf_path_workaround
    'PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"'
  end  
  
end