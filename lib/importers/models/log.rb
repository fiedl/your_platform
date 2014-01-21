class Log
  def head( text )
    info ""
    info "==========================================================".blue
    info text.blue
    info "==========================================================".blue
  end
  def section( heading )
    info ""
    info heading.blue
    info "----------------------------------------------------------".blue
  end
  def info( text )
    self.write text
  end
  def success( text )
    self.write text.green
  end
  def error( text )
    self.write text.red
  end
  def warning( text )
    self.write "Warning: ".yellow.bold + text.yellow
  end
  def prompt( text )
    self.write "$ " + text.bold
  end
  def write( text )
    @filter_out ||= []
    @filter_out.each do |expression|
      text = text.gsub(expression, "[...]")
    end
    print text + "\n"
  end
  def filter_out( expression )
    @filter_out ||= []
    @filter_out << expression
  end
end