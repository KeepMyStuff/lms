# Client side code

# I want to know my "type" field if I'm logged in
Meteor.subscribe 'userType'
# User data. Only receivable by admins
Meteor.subscribe 'users'

# - LOGIN -

login = (mail,pass) -> # Perform login request
  if mail.length < 4 then return showErr msg: 'Invalid E-Mail Address'
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
showErr = (err) ->
  currentError = err; if err? and !err.title then err.title = 'Error'
  errorDep.changed()
errCallback = (err) -> if err then showErr msg: err.reason

Template.error.error = -> errorDep.depend(); currentError
Template.error.events
  'click .close': -> showErr() # Set current error to undefined

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
  if selectedUser() is this
    console.log 'active: '+@username; return 'active'
Template.admin.events
  'click .user': -> selectUser this; showEditor yes

# User editor
show_editor = no; showEditorDep = new Deps.Dependency
showEditor = (v) -> show_editor = v; showEditorDep.changed()
Template.userEditor.show = -> showEditorDep.depend(); show_editor
Template.userEditor.user = -> selectedUser()
Template.userEditor.events
  'click .btn-close': -> selectUser(); showEditor no
  'click .btn-insert': (e,t) ->
    if Meteor.users.findOne {username: t.find('.name').value}
      # Account already exists
      Meteor.users.update {_id: selectedUser()._id},
        $set: type: t.find('.type').value
      if t.find('#pass').value # Update the password
        Meteor.call 'newPassword', selectedUser()._id,
                    t.find('.pass').value, errCallback
    else # Create new user
      Meteor.call 'newUser', {
        username: t.find('.name').value
        password: t.find('.pass').value
        type: t.find('.type').value }, errCallback
  'click .btn-delete': (e,t) ->
    Meteor.call 'deleteUser', selectedUser()._id, errCallback
