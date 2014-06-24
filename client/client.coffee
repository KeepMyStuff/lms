# Client side code

# I want to know my "type" field if I'm logged in
Meteor.subscribe 'userType'
# User data. Only receivable by admins
Meteor.subscribe 'users'
# Classes
classes = new Meteor.Collection 'classes'
Meteor.subscribe 'classes'

UI.registerHelper 'user', -> Meteor.user()
UI.registerHelper 'admin', -> Meteor.user() and Meteor.user().type is 'admin'

# Layout
Template.layout.isCurrent = (i) ->
  if Router.current() and Router.current().lookupTemplate() is i
    return 'current'
Template.layout.events
  'click .logout': -> Meteor.logout(); Router.go 'home'

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
  currentError = err; if !currentError.title then currentError.title = 'Error'
  if !currentError.type then currentError.type = 'danger'
  errorDep.changed()
errCallback = (err) -> if err then notify msg: err.reason

Template.error.error = -> errorDep.depend(); currentError
Template.error.events
  'click .close': -> notify() # Set current error to undefined

# - STUDENT -

Template.quiz.materia = -> "Matematica"

# - ADMIN -

# Admin UI
Template.admin.nusers = -> Meteor.users.find().count()
Template.admin.nteachers = -> Meteor.users.find(type:'teacher').count()
Template.admin.nstudents = -> Meteor.users.find(type:'student').count()
Template.admin.nadmins = -> Meteor.users.find(type:'admin').count()
Template.admin.nclasses = -> classes.find().count()

Template.users.users = -> Meteor.users.find().fetch()
Template.users.active = ->
  if Router.current().data() and Router.current().data()._id is @_id
    return 'active'
Template.users.events
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
  'click .btn-close': -> Router.go 'users'
  'click .btn-insert': (e,t) ->
    if Meteor.users.findOne {_id: Router.current().params._id}
      # Account exists
      Meteor.users.update {_id: Router.current().params._id},
        $set:
          username: t.find('.name').value
          type: t.find('.type').value
      if t.find('.pass').value # Update the password
        p = t.find('.pass').value
        Meteor.call 'newPassword', Router.current().params._id, p,
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
        Router.go 'users'

# Classes

Template.classes.active = ->
  Router.current() and Router.current().params._id is @_id
Template.classes.classes = classes.find().fetch()

Template.classAdder.events
  'click .btn-close': -> Router.go 'classes'
  'click .btn-insert': (e,t) ->
    console.log t.find('.new')
    year = t.find('.year-val').value
    section = t.find('.section-val').value
    course = t.find('.course-val').value
    if !year
      return showErr msg: 'Missing "year"'
    else if !course
      return showErr msg: 'Missing "course"'
    else if !section
      return showErr msg: 'Missing "section"'
    else if !classes.find {year: year, section:section, course:course}
      return showErr msg: 'This class already exists'
    classes.insert {year: year, section: section, course: course}, (e) ->
      if e then errCallback e else
      showErr title: 'OK', type: 'success', msg: 'class added successfully'
