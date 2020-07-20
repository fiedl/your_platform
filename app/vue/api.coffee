class Api
  path: null
  options: {}

  @post: (path, options)->
    request = new Api
    request.path = path
    request.options = options
    request.options.method = 'post'
    request.execute()

  url: ->
    "/api/v1/#{@path}"

  execute: ->
    @options.url = @url()
    $.ajax @options

`export default Api`