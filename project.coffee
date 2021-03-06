Ajax   = require "awaitajax"
{errify, extend} = require "./utils"


class Project
  types:
    Git:        1
    Subversion: 2
    Mercurial:  3

  account:         "account"
  users:           {}

  req:
    ## Legacy request type
    contentType: "application/x-www-form-urlencoded"
    dataType:    "xml"
    processData: true

  constructor: (options) ->
    {@account}       = options
    ## URIs
    @baseurl         = "https://#{@account}.sourcerepo.com"
    @loginurl        = "#{@baseurl}/login/check_login"
    @newurl          = "#{@baseurl}/projects/new"
    @createurl       = "#{@baseurl}/projects/create_project"
    @accessurl       = "#{@baseurl}/projects/project_access"
    @updateaccessurl = "#{@baseurl}/projects/update_project_access"

    @[key] = value for key, value of options

  ## Get login
  login: (username, password, callback) ->
    esc = errify callback

    req =
      url: @loginurl
      data:
        login:    username
        password: password

    @log "logging in"
    await @post req, esc defer data, xhr
    return callback "did not receive cookie" unless @cookie

    callback null, @cookie

  create: (name, type = "Git", callback) ->
    esc = errify callback

    req =
      url: @newurl
      headers:
        Cookie: @cookie

    await @get req, esc defer data
    token = @parseToken data
    return callback "unable to get authenticity_token" unless token
    @log "token: #{token}"

    req =
      url: @createurl
      data:
        "project[name]":               name
        "project[repository_type_id]": @types[type]
        authenticity_token:            token
      headers:
        Cookie: @cookie

    @log "creating project"
    await @post req, esc defer data, xhr

    location  = xhr.getResponseHeader "location"
    lastslash = 1 + location.lastIndexOf "/"
    projectid = location[lastslash..]

    @log "project id: #{projectid}"
    callback null, projectid

    ## Check that project exists?

  authorize: (projectid, userids..., callback) ->
    esc = errify callback

    req =
      url: "#{@accessurl}/#{projectid}"
      headers:
        Cookie: @cookie

    await @get req, esc defer data
    token = @parseToken data
    return callback "unable to get authenticity_token" unless token
    @log "token: #{token}"

    req =
      url: @updateaccessurl
      data:
        id:           projectid
        "user_ids[]": userids
        commit:       "Save Changes"
        authenticity_token: token
      headers:
        Cookie: @cookie

    @log "authorizing #{userids} on project #{projectid}"
    await @post req, esc defer data
    callback null, data

  resource: (req, callback) ->
    req = extend {}, @req, req
    @log "#{req.type} to #{req.url}"
    await Ajax.awaitAjax req, defer status, xhr, statusText, data
    [@cookie] = xhr.getResponseHeader "set-cookie" if xhr?

    if status is "error"
      callback data, xhr
    else
      @log "success"
      callback null, data, xhr

  get: (req, callback) ->
    esc = errify callback

    req.type = "GET"
    await @resource req, esc defer data, xhr
    callback null, data, xhr

  post: (req, callback) ->
    req.type = "POST"
    await @resource req, defer data, xhr
    if xhr?.status isnt 302
      callback data, xhr
    else
      @log "success"
      callback null, data, xhr

  parseToken: (data) ->
    match = /authenticity_token[a-z" \-=]+value="(.*)"/.exec data
    unless data and match and token = match[1]
      null
    else token



module.exports = Project
