# Here goes the Templates logic code

# - LOGIN -

login = (user,pass) -> # Perform login request
  return null

# Events
Template.login.events
  'keypress .form-control': (e,t) ->
    if e.keyCode is 13 then login t.find('.mail').value, t.find('.pass').value
    'click .login': (e,t) -> login t.find('.mail').value, t.find('.pass').value

# - ERROR -

currentError = undefined
errorDep = new Deps.Dependency

# This rective function can be used to show an error to the user. The user can
# dismiss the error. Example of an error: { title: "404", msg: "not found" }
showErr = (err) ->
  currentError = err; errorDep.changed()

# Returns current error. This function is reactive
getError = -> errorDep.depend(); currentError

# Events
Template.error.error = -> errorDep.depend(); currentError
Template.error.events
  'click .close': -> showErr() # Set current error to undefined
