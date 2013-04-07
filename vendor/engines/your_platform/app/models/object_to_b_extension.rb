module ObjectToBExtension

  # This method converts the object to the boolean type.
  # The method returns either +true+ or +false+.
  #
  def to_b 
    !! self
  end

end

Object.send( :include, ObjectToBExtension )
