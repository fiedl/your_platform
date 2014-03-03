# require File.join(Rails.root, 'app/models/group')
# 
# class Group
#   
#   # Override the == method to avoid a strange problem, where the same object
#   # is regarded as being another object when patching W64525.
#   #
#   # The original method can be found here:
#   # http://apidock.com/rails/v3.2.13/ActiveResource/Base/%3D%3D
#   #
#   def ==(other)
#     equal?(other) or (id == other.id and self.class.name == other.class.name)
#   end
#   
# end