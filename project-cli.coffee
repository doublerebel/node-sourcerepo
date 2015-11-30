Prompt = require "prompt"
{log}  = console
{errify, extend} = require "./utils"


class ProjectCLI
  @abort: (error) ->
    console.error "error"
    console.error error
    process.exit 0

  constructor: (@project) ->
    @esc = errify @constructor.abort

  login: (callback) ->
    schema =
      properties:
        username:
          default: @project.username
          required: true
        password:
          hidden: true

    Prompt.start()
    await Prompt.get schema, @esc defer input
    await @project.login input.username, input.password, @esc defer()
    callback()

  create: (callback) ->
    Prompt.start()
    await Prompt.get ["new project name"], @esc defer input
    await @project.create input["new project name"], "Git", @esc defer id
    callback id

  authorize: (id, callback) ->
    log "available usernames:"
    log "  #{name}" for name, userid of @project.users
    Prompt.start()
    await Prompt.get ["username to authorize"], @esc defer input
    username = input["username to authorize"]
    userid   = @project.users[username]
    await @project.authorize id, userid, defer()
    callback()


module.exports = ProjectCLI
