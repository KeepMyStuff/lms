# Client side code

# Code that is executed when the client starts.
Meteor.startup ->
  # Helpers and general stuff
  Meteor.subscribe 'user'
  UI.registerHelper 'user', -> Meteor.user()
  UI.registerHelper 'admin', -> Meteor.user() and Meteor.user().type is 'admin'
  # User data. Only receivable by admins
  Meteor.subscribe 'users'
  # Classes
  share.classes = new Meteor.Collection 'classes'
  Meteor.subscribe 'classes'

# Layout template
Template.layout.isCurrent = (i) ->
  if Router.current() and Router.current().lookupTemplate() is i
    return 'current'
Template.layout.events
  'click .logout': -> Meteor.logout(); Router.go 'home'

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

# - STUDENT -

Template.quiz.materia = -> "Matematica"
