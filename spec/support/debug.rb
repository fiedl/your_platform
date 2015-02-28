module Debug
  
  def debug
    require 'pry'
    binding.pry
  end
  
end