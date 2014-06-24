# Account management: server side code
getUser = (id) -> Meteor.users.findOne _id: id

Meteor.startup -> # Executed when the server starts
  # Create default admin user if there are no users
  if Meteor.users.find().count() is 0
    id = Accounts.createUser
      username: 'admin', password: 'admin',
      email: 'admin@admin.app', type: 'admin'
    console.log '''No users in the database. Creating default admin user
    Username: admin - Password: admin - Email: admin@admin.app - ID: '''+id
  else
    userCount = Meteor.users.find().count()
    console.log "There are "+userCount+" users in the database."

Accounts.config forbidClientAccountCreation: yes
Accounts.onCreateUser (options,user) ->
  user.type = options.type or 'student'; user

# Email configuration
Accounts.emailTemplates.siteName = 'Photon'
Accounts.emailTemplates.from = 'Admin'
Accounts.emailTemplates.verifyEmail.subject = (user) ->
  "You can now activate your Photon account"
Accounts.emailTemplates.verifyEmail.text = (user, url) ->
  token = url.split '/'; token = token[token.length - 1]
  '''You can verify this email address and start using your account by logging\
  in and using the following token: #{token}'''

Meteor.methods
  'newUser': (options) ->
    u = getUser @userId; return no if !u or u.type isnt 'admin'
    console.log "Create Account request accepted from "+u.username
    Accounts.createUser options
  'deleteUser': (id) ->
    u = getUser @userId
    if id is @userId or (u and u.type is 'admin')
      console.log "user id:"+id+" is being deleted from the database"
      Meteor.users.remove id; return yes
    else return no
  'newPassword': (id,pass) ->
    u = getUser @userId
    if u and u.type is 'admin' and user id
      console.log "user id:"+id+" has been given a new password"
      Accounts.setPassword id, pass; return yes
    else
      console.log u
      console.log "Password change request denied"
      return no

# Collections

classes = new Meteor.Collection 'classes'

# Publications and Permissions

Meteor.publish 'classes', ->
  if @userId
    user = Meteor.users.findOne _id:@userId
    if user.type is 'admin'
      return classes.find()
    else if user.type is 'student'
      return classes.findOne _id:user.classId
    else if user.type is 'teacher'
      return classes.find teachers: $elemMatch: _id: @userId

Meteor.users.allow
  insert: (id) -> id and getUser(id).type is 'admin'
  remove: (id) -> id and getUser(id).type is 'admin'
  update: (id) ->
    console.log "ID: "+id+" Type:"+getUser(id).type
    id and getUser(id).type is 'admin'

Meteor.publish 'users', ->
  if @userId and Meteor.users.findOne(_id:@userId).type is 'admin'
    return Meteor.users.find()
# Tell the user his "type" field
Meteor.publish 'userType', ->
  Meteor.users.find { _id: @userId }, fields: { type: 1 }
