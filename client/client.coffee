# Client side code

# Code that is executed when the client starts.
Meteor.startup ->
  # Collections and subscriptions
  Meteor.subscribe 'user' # My user data
  Meteor.subscribe 'users' # Users data. Only receivable by admins
  share.classes = new Meteor.Collection 'classes' # Classes
  Meteor.subscribe 'classes'
  # Helpers and general stuff
  share.user = ->
    u = Meteor.user(); return unless u; u.email = 'no email'
    u.class = share.classes.findOne students: u._id
    u.email = u.emails[0].address if u.emails and u.emails[0]; u
  UI.registerHelper 'user', -> share.user()
  UI.registerHelper 'admin', -> Meteor.user() and Meteor.user().type is 'admin'
  UI.registerHelper 'loading', ->
    Meteor.loggingIn() or (Router.current() and !Router.current().ready())

# Layout template

Template.layout.isCurrent = (i) ->
  return unless Router.current()
  return 'current' if i is Router.match(Router.current().path).name

Template.layout.events
  # Toggle dropdown event
  'click .drop-wrap': (e) -> $('ul', $(e.target).parent()).slideToggle()
  'click #my-class': ->
    Router.go 'class', _id: share.classes.findOne(student: share.user()._id)._id

# - ERROR template -

currentError = undefined
errorDep = new Deps.Dependency

# This rective function can be used to show an error to the user. The user can
# dismiss the error. Example of an error: { title: "404", msg: "not found" }
share.notify = (err) ->
  if !err then currentError = undefined; errorDep.changed(); return
  currentError = err; if !currentError.title then currentError.title = 'Error'
  if !currentError.type then currentError.type = 'danger'
  errorDep.changed()
share.errCallback = (err) -> if err then share.notify msg: err.reason

Template.error.error = -> errorDep.depend(); currentError
Template.error.events
  'click .close': -> share.notify() # Set current error to undefined

# - CONFIRM template -
currentConfirm = undefined
confirmDep = new Deps.Dependency
# Show a confirmation dialog. The cb is called if the users confirms the action
share.confirm = (cb,msg) ->
  if !cb
    currentConfirm = undefined
  else
    msg ?= 'Are you sure?'
    currentConfirm = msg: msg, cb: cb
  confirmDep.changed()
Template.confirm.get = -> confirmDep.depend(); currentConfirm
Template.confirm.events
  'click .yes': -> cb()
  'click .btn': -> share.confirm()

# Autorun stuff

# Automatically clears notification when user logs in or logs out
Deps.autorun -> Meteor.user(); share.notify()
