# Client side code

# Code that is executed when the client starts.
Meteor.startup ->
  # Helpers and general stuff
  UI.registerHelper 'user', -> Meteor.user()
  UI.registerHelper 'admin', -> Meteor.user() and Meteor.user().type is 'admin'
  UI.registerHelper 'classes', -> share.classes.find().fetch()
  UI.registerHelper 'loading', ->
    Meteor.loggingIn() or (Router.current() and !Router.current().ready())
  # My user data
  Meteor.subscribe 'user'
  # Users data. Only receivable by admins
  Meteor.subscribe 'users'
  # Classes
  share.classes = new Meteor.Collection 'classes'
  Meteor.subscribe 'classes'

# Layout template

Template.layout.isCurrent = (i) ->
  if Router.current() and Router.current().lookupTemplate() is i
    return 'current'
  # Find "subroutes"
  if Router.current() and Router.current().path.lastIndexOf('/'+i,0) is 0
    return 'current'
Template.layout.events
  # Toggle dropdown event
  'click .drop-wrap': (e) -> $('ul', $(e.target).parent()).slideToggle()
  'click .logout': -> Meteor.logout(); Router.go 'home'
  'click .go-me': ->
    if !Meteor.user()
      Router.go 'login'
    else
      if Meteor.user().type is 'student'
        Router.go 'student'
      else if Meteor.user().type is 'teacher'
        Router.go 'teacher'
      else Router.go 'admin'

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
