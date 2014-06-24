# - LOGIN template -

login = (mail,pass) -> # Perform login request
  if mail.length < 4 then return notify msg: 'Invalid E-Mail Address'
  Meteor.loginWithPassword mail, pass, (e) ->
    if e then errCallback e else Router.go 'me'

# Events
Template.login.events
  'keypress .form-control': (e,t) ->
    if e.keyCode is 13 then login t.find('.mail').value, t.find('.pass').value
  'click .login-btn': (e,t) ->
    login t.find('.mail').value, t.find('.pass').value
