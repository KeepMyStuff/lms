# Client side code

# I want to know my "type" field if I'm logged in
Meteor.subscribe 'userType'

# - LOGIN -

login = (mail,pass) -> # Perform login request
  if mail.length < 4 then return showErr msg: 'Invalid E-Mail Address'
  Meteor.loginWithPassword mail, pass, errCallback

# Events
Template.login.events
  'keypress .form-control': (e,t) ->
    if e.keyCode is 13 then login t.find('.mail').value, t.find('.pass').value
  'click .login-btn': (e,t) ->
    login t.find('.mail').value, t.find('.pass').value

# - ERROR -

currentError = undefined
errorDep = new Deps.Dependency

# This rective function can be used to show an error to the user. The user can
# dismiss the error. Example of an error: { title: "404", msg: "not found" }
showErr = (err) ->
  currentError = err; if err? and !err.title then err.title = 'Error'
  errorDep.changed()
errCallback = (err) -> if err then showErr msg: err.reason

# Events
Template.error.error = -> errorDep.depend(); currentError
Template.error.events
  'click .close': -> showErr() # Set current error to undefined
