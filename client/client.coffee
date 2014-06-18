# Client side code

# I want to know my "type" field if I'm logged in
Meteor.subscribe 'userType'
# User data. Only receivable by admins
Meteor.subscribe 'users'

UI.registerHelper 'user', -> Meteor.user()
UI.registerHelper 'admin', -> Meteor.user() and Meteor.user().type is 'admin'

# Layout
Template.layout.isCurrent = (i) ->
  if Router.current() and Router.current().lookupTemplate() is i
    return 'current'

# - LOGIN -

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

# - ERROR -

currentError = undefined
errorDep = new Deps.Dependency

# This rective function can be used to show an error to the user. The user can
# dismiss the error. Example of an error: { title: "404", msg: "not found" }
notify = (err) ->
  if !err then currentError = undefined; errorDep.changed(); return
  currentError = err; if !err.title then err.title = 'Error'
  if !err.type then err.type = 'danger'
  errorDep.changed()
errCallback = (err) -> if err then notify msg: err.reason

Template.error.error = -> errorDep.depend(); currentError
Template.error.events
  'click .close': -> notify() # Set current error to undefined

# - ADMIN -

# SelectedUser - Reactive user list component

selectedUserVar = undefined; selectedUserDep = new Deps.Dependency
# Selects a new user and displays the editor for him
selectUser = (u) -> selectedUserVar = u; selectedUserDep.changed()
# Returns the selected user. These functions are all reactive
selectedUser = -> selectedUserDep.depend(); selectedUserVar

# Admin UI

Template.admin.users = -> Meteor.users.find().fetch()
Template.admin.active = ->
  if Router.current().data() is this
    return 'active'
Template.admin.events
  'keypress .new': (e,t) ->
    if e.keyCode is 13 and t.find('.new').value isnt ''
      data = t.find('.new').value; t.find('.new').value = ''
      if !Meteor.users.findOne {username: data}
        Meteor.call 'newUser', {
          username: data, password: data
          type: 'student' },
          (e) ->
            if e then errCallback e
            else notify title: 'OK', type: 'success', msg: 'Account created'
      else notify msg: 'Account already exists'

# User editor
Template.userEditor.show = ->
  Router.current().params._id and Router.current().params._id isnt ''
Template.userEditor.user = ->
  Meteor.users.findOne _id: Router.current().params._id
Template.userEditor.events
  'click .btn-close': -> Router.go 'admin'
  'click .btn-insert': (e,t) ->
    if Meteor.users.findOne {_id: Router.current().params._id}
      # Account exists
      Meteor.users.update {_id: Router.current().params._id},
        $set:
          username: t.find('.name').value
          type: t.find('.type').value
      if t.find('#pass').value # Update the password
        Meteor.call 'newPassword', selectedUser()._id, t.find('.pass').value,
        (e) ->
          if e then errCallback e
          else notify title: 'OK', type: 'success', msg: 'password changed'
    else notify msg: 'User does not exist'
  'click .btn-delete': (e,t) ->
    Meteor.call 'deleteUser', Router.current().params._id,
    (e) ->
      if e then errCallback e
      else
        notify title: 'OK', type: 'success', msg: 'Account has been deleted'
        Router.go 'admin'

"""currently I let it here"""
Template.quiz.materia=->"Matematica"
