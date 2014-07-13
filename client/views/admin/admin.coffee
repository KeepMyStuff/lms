# - ADMIN template and subtemplates -

# Admin UI
Template.admin.nusers = -> Meteor.users.find().count()
Template.admin.ntype = (t) -> Meteor.users.find(type:t).count()
Template.admin.nclasses = -> share.classes.find().count()

Template.users.paginator = new share.Paginator 5
Template.users.users = ->
  opt = Template.users.paginator.queryOptions(); opt.sort = username: 1
  Template.users.paginator.calibrate Meteor.users.find().count()
  Meteor.users.find({},opt).fetch()
Template.users.active = ->
  if Router.current().data() and Router.current().data()._id is @_id
    return 'active'
Template.users.events
  'click .page': (e,t) ->
    Template.users.paginator.page parseInt e.currentTarget.innerText
  'keypress .new': (e,t) ->
    if e.keyCode is 13 and t.find('.new').value isnt ''
      data = t.find('.new').value; t.find('.new').value = ''
      if !Meteor.users.findOne {username: data}
        Meteor.call 'newUser', {
          username: data, password: data
          type: 'student' },
          (e) ->
            if e then share.errCallback e else
            share.notify title: 'OK', type: 'success', msg: 'Account created'
      else share.notify msg: 'Account already exists'

# User adder
Template.userAdder.show = -> !Template.userEditor.user()
Template.userAdder.events
  'click .btn-insert': (e,t) ->
    name = t.find('.username').value
    pass = t.find('.pass').value
    email = t.find('.addr').value
    type = t.find('.usertype').value
    if type isnt 'admin' and type isnt 'teacher' and type isnt 'student'
      return share.notify msg: 'invalid user type'
    if !pass and !email
      return share.notify msg: 'either password or email is required!'
    if !name
      return share.notify msg: 'username is required'
    Meteor.call 'newUser', {
      username: name, password: pass, fullname: t.find('.fullname').value
      type: type, email: email }, (e,x) ->
      if e then share.errCallback e else
        if x is no
          share.notify msg: 'username already exists'
        else
          share.notify title: 'OK', type: 'success', msg: 'Account created'
# User editor
Template.userEditor.checked = ->
  "checked" if Template.userEditor.userMail().verified
Template.userEditor.matches = ->
  cl = share.classes.findOne(students: Router.current().params._id)
  cl and cl._id is @_id
Template.userEditor.currentUserIs = (what) ->
  u = Meteor.users.findOne Router.current().params._id
  u and u.type is what
Template.userEditor.userMail = ->
  u = Meteor.users.findOne Router.current().params._id
  if u and u.emails
    {address: u.emails[0].address, verified: u.emails[0].verified}
  else {address: '', verified: false}
Template.userEditor.classes = -> share.classes.find().fetch()
Template.userEditor.user = ->
  Meteor.users.findOne Router.current().params._id
Template.userEditor.events
  'click .btn-close': -> Router.go 'users'
  'click .btn-insert': (e,t) ->
    if Meteor.users.findOne Router.current().params._id
      # Account exists
      Meteor.users.update Router.current().params._id,
        $set:
          fullname: t.find('.fullname').value
          username: t.find('.name').value #, type: t.find('.type').value
          'emails.0': address: t.find('.addr').value
      if t.find('.pass').value # Update the password
        p = t.find('.pass').value
        Meteor.call 'newPassword', Router.current().params._id, p,
        (e) ->
          if e then share.errCallback e else
          share.notify title: 'OK', type: 'success', msg: 'data updated and \
          password changed'
        t.find('.pass').value = ''
      else share.notify title: 'OK', type: 'success', msg: 'data updated'
    else share.notify msg: 'User does not exist'
  'click .btn-assume': ->
    Meteor.call 'assumeIdentity', Router.current().params._id, (e,r) ->
      if e then share.errCallback e else
      share.notify title:'OK',type:'success', msg:"you're a wizard now!"
  'click .btn-delete': (e,t) ->
    Meteor.call 'deleteUser', Router.current().params._id,
    (e,r) ->
      if e then share.errCallback e
      else
        if r is yes
          share.notify
            title: 'OK', type: 'success', msg: 'account has been deleted'
        else share.notify msg: 'account deletion failed'
        Router.go 'users'
  'click .toggle': ->
    id = Router.current().params._id
    cl = share.classes.findOne(_id: @_id, students: id)
    if cl
      Meteor.call 'cleanUp', id
    else
      Meteor.call 'cleanUp', id, @_id
      share.classes.update @_id, $addToSet: students: id
  'click .set-student': ->
    Meteor.users.update Router.current().params._id, $set: type: 'student'
  'click .set-teacher': ->
    Meteor.users.update Router.current().params._id, $set: type: 'teacher'
  'click .set-admin': ->
    Meteor.users.update Router.current().params._id, $set: type: 'admin'

# Classes

Template.adminClasses.paginator = new share.Paginator 5
Template.adminClasses.active = ->
  Router.current() and Router.current().params._id is @_id
Template.adminClasses.classes = ->
  Template.adminClasses.paginator.calibrate share.classes.find().count()
  opt = Template.adminClasses.paginator.queryOptions()
  opt.sort = year: 1, course: 1, section: 1
  share.classes.find({},opt).fetch()
Template.adminClasses.events
  'click .page': (e,t) ->
    Template.adminClasses.paginator.page parseInt e.currentTarget.innerText

Template.classAdder.show = -> !Template.classEditor.class()
Template.classAdder.events
  'click .btn-close': -> Router.go 'admin-classes'
  'click .btn-insert': (e,t) ->
    year = t.find('.year-val').value
    section = t.find('.section-val').value
    course = t.find('.course-val').value
    if !year
      return share.notify msg: 'Missing "year"'
    else if !course
      return share.notify msg: 'Missing "course"'
    else if !section
      return share.notify msg: 'Missing "section"'
    else if !share.classes.find {year: year, section:section, course:course}
      return share.notify msg: 'This class already exists'
    share.classes.insert {
      year: year, section: section, course: course,
      teachers:[], students: []
      }, (e) ->
      if e then share.errCallback e else
      share.notify title: 'OK', type: 'success', msg: 'class added successfully'

Template.classEditor.class = ->
  share.classes.findOne Router.current().params._id
Template.classEditor.students = -> Meteor.users.find type: 'student'
Template.classEditor.teachers = -> Meteor.users.find type: 'teacher'
Template.classEditor.added = ->
  if Meteor.users.findOne(@_id).type is 'student'
    cl = share.classes.findOne(students: @_id)
  else cl = share.classes.findOne(teachers: @_id)
  #console.log cl
  cl and cl._id is Router.current().params._id
Template.classEditor.events
  'click .toggle': ->
    id = Router.current().params._id
    if Meteor.users.findOne(@_id).type is 'student'
      cl = share.classes.findOne(_id: id, students: @_id)
      if cl
        Meteor.call 'cleanUp', @_id
      else
        Meteor.call 'cleanUp', @_id, id
        share.classes.update id, $addToSet: students: @_id
    else if Meteor.users.findOne(@_id).type is 'teacher'
      if share.classes.findOne(_id: id,teachers:@_id)
        share.classes.update id, $pull: teachers: @_id
      else share.classes.update id, $addToSet: teachers: @_id
  'click .btn-close': -> Router.go 'admin-classes'
  'click .btn-delete': ->
    share.classes.remove Router.current().params._id,
    (e) ->
      if e then share.errCallback e
      else
        share.notify title: 'OK', type: 'success', msg: 'class has been deleted'
        Router.go 'admin-classes'
