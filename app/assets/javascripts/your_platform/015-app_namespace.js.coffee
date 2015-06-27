# This defines an App namespace.
#
# Define classes like this:
#
#     Class App.MyClass
#       my_variable: "foo"
#       my_method: ->
#         ...
#       constructor: (bar)->
#         ...
#
# Instanciate classes like this:
# 
#     my_instance = new App.MyClass("bar")
#
# Store singleton instances in App namespace:
#
#     App.my_instance = new ApplMyClass("bar")
#
window.App = {} if typeof(App) == 'undefined'