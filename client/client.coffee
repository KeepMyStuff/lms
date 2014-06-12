# Here goes the Templates logic code

# - LOGIN -

login = (mail,pass) -> # Perform login request
  if mail.length < 4 then return showErr msg: 'Invalid E-Mail Address'
  if pass.length < 8 then return showErr msg: 'Invalid Password'
  Accounts.loginWithPassword user, pass, errCallback

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
  currentError = err; if !err.title then err.title = 'Error'; errorDep.changed()
errCallback = (err) -> showErr msg: err.reason
# Returns current error. This function is reactive
getError = -> errorDep.depend(); currentError

# Events
Template.error.error = -> errorDep.depend(); currentError
Template.error.events
  'click .close': -> showErr() # Set current error to undefined
