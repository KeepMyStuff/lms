# - ADMIN template and subtemplates -

# Admin UI
Template.admin.nusers = -> Meteor.users.find().count()
Template.admin.nteachers = -> Meteor.users.find(type:'teacher').count()
Template.admin.nstudents = -> Meteor.users.find(type:'student').count()
Template.admin.nadmins = -> Meteor.users.find(type:'admin').count()
Template.admin.nclasses = -> share.classes.find().count()

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
Template.classes.classes = -> share.classes.find().fetch()

Template.classAdder.events
  'click .btn-close': -> Router.go 'classes'
  'click .btn-insert': (e,t) ->
    year = t.find('.year-val').value
    section = t.find('.section-val').value
    course = t.find('.course-val').value
    if !year
      return notify msg: 'Missing "year"'
    else if !course
      return notify msg: 'Missing "course"'
    else if !section
      return notify msg: 'Missing "section"'
    else if !share.classes.find {year: year, section:section, course:course}
      return notify msg: 'This class already exists'
    share.classes.insert {
      year: year, section: section, course: course,
      teachers:[], students: []
      }, (e) ->
      if e then errCallback e else
      notify title: 'OK', type: 'success', msg: 'class added successfully'

Template.classEditor.class = ->
  share.classes.findOne _id: Router.current().params._id
Template.classEditor.events
  'click .btn-close': -> Router.go 'classes'
  'click .btn-delete': ->
    share.classes.remove Router.current().params._id,
    (e) ->
      if e then errCallback e
      else
        notify title: 'OK', type: 'success', msg: 'class has been deleted'
        Router.go 'classes'
