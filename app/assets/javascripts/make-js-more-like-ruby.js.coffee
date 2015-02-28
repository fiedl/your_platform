#
# In desperation, I write this series of patches to make javascript more like ruby.
# I know, it's my fault not to appreciate javascript as it is.
# But, let's make the world how I would like it to be ...
#
# We could also have a look at:
#
#   * https://github.com/sagivo/Ruby-Javascript/blob/master/rjs.js
#   * https://github.com/rubyjs/core-lib
#
# SF 2013-03-08
#

# Array
# ==========================================================================================

Array.prototype.removeItem = (itemToRemoveFromArray)->
  this.splice( this.indexOf( itemToRemoveFromArray ), 1 )

Array.prototype.delete = (itemToRemoveFromArray)->
  this.removeItem( itemToRemoveFromArray )

Array.prototype.includes = (itemToCheckIfItIsIncluded)->
  return ( $.inArray( itemToCheckIfItIsIncluded, this ) != -1 )

Array.prototype.clear = ->
  this.length = 0

Array.prototype.pushArray = (arrayOfItemsToAppend)->
  this.push.apply( this, arrayOfItemsToAppend )
  # see: http://stackoverflow.com/questions/4156101/

