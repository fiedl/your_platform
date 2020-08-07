class Api
  path: null
  options: {}

  @get: (path, options)->
    request = new Api
    request.path = path
    request.options = options
    request.options.method = 'get'
    request.execute()

  @post: (path, options)->
    request = new Api
    request.path = path
    request.options = options
    request.options.method = 'post'
    request.execute()

  @put: (path, options)->
    request = new Api
    request.path = path
    request.options = options
    request.options.method = 'post'
    request.options.data._method = 'put'
    request.execute()

  @delete: (path, options)->
    request = new Api
    request.path = path
    request.options = options
    request.options.method = 'delete'
    request.execute()

  url: ->
    if @path.startsWith("/")
      "/api/v1#{@path}"
    else
      "/api/v1/#{@path}"

  execute: ->
    @options.url = @url()
    $.ajax @options

`export default Api`