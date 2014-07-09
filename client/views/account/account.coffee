# - LOGIN template -

login = (mail,pass) -> # Perform login request
  #if mail.length < 4 then return share.notify msg: 'Invalid E-Mail Address'
  Meteor.loginWithPassword mail, pass, (e) ->
    if e then share.errCallback e else Router.go 'me'

# Events
Template.login.events
  'keypress .form-control': (e,t) ->
    if e.keyCode is 13 then login t.find('.mail').value, t.find('.pass').value
  'click .login-btn': (e,t) ->
    login t.find('.mail').value, t.find('.pass').value
  'click .forgot-btn': (e,t) ->
    mail = t.find('.mail').value
    if !mail
      share.notify type:'warning', title: 'Notice:', msg:"please insert your \
      email: we will send you instructions so you can set a new password."
    else Accounts.forgotPassword email:mail, (e) ->
      console.log e
      if e then share.errCallback e
      else
        share.notify type:'success', title:'OK', msg:'the email has been sent'

# - RESET template -
Template.reset.token = -> Router.current().params.token
Template.reset.events
  'click .btn-ok': (e,t) ->
    pass = t.find('.pass').value; token = t.find('.token').value
    t.find('.token').value = ''; t.find('.pass').value = ''
    console.log token+" "+pass
    if !pass
      share.notify msg:'please insert a new password'
    if !token
      share.notify msg:'please insert token'
    Accounts.resetPassword token, pass, (e) ->
      if e then share.errCallback e
      else share.notify title: 'OK', type:'success', msg:'password changed'

# - SETTINGS -

Template.settings.events
  'click .logout-btn': -> Meteor.logout(); Router.go 'home'
