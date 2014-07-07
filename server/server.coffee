# Account management: server side code
getUser = (id) -> Meteor.users.findOne id
isAdmin = (id) -> id and getUser(id).type is 'admin'
mailVerified = (id) ->
  id and (!getUser(id).emails or getUser(id).emails[0].verified is yes)
gibPowerToAdmins = insert: isAdmin, remove: isAdmin, update: isAdmin

# Collections

classes = new Meteor.Collection 'classes'
# Function to test behaviur with a lot of users.
populate = (count) ->
  for i in [1..count]
    console.log "Creating user "+i
    Accounts.createUser
      username: 'user'+i
      password: 'user'+i
      email: 'user'+i+"@user.com"
      type: 'student'

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
  user.fullname = options.fullname or options.username #or options.email

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
    u = getUser @userId
    if !u or u.type isnt 'admin'
      throw new Meteor.Error 403, 'Insufficient permission'
    console.log "Create Account request accepted from "+u.username
    Accounts.createUser options
  'deleteUser': (id) ->
    u = getUser @userId
    if id is @userId or (u and u.type is 'admin')
      console.log "user id:"+id+" is being deleted from the database"
      Meteor.users.remove id;s yes
    else no
  'assumeIdentity': (id) ->
    u = getUser @userId
    if u.type is 'admin'
      @setUserId id; yes
    else no
  'newPassword': (id,pass) ->
    if isAdmin @userId and getUser id
      console.log "user id:"+id+" has been given a new password"
      Accounts.setPassword id, pass; yes
    else
      console.log "Password change request for "+id+"by "+@userId+" denied"; no
  'cleanUp': (id,except) ->
    u = getUser id
    if isAdmin(@userId) and u
      if u.type is 'student'
        classes.update {_id: {$ne: except}, students: id}, $pull: students: id
      else if u.type is 'teacher'
        classes.update {_id: {$ne: except}, teachers: id}, $pull: teachers: id

# Publications and Permissions

Meteor.publish 'classes', ->
  if @userId
    user = getUser @userId
    if user.type is 'admin'
      classes.find()
    else if user.type is 'student'
      classes.findOne user.classId
    else if user.type is 'teacher'
      classes.find teachers: @userId
    else []

Meteor.users.allow gibPowerToAdmins
classes.allow gibPowerToAdmins

Meteor.publish 'users', ->
  if isAdmin @userId then Meteor.users.find({},fields:services:0) else []
# Tell the user his "type" field
# For some reason meteor doesn't like "findOne" inside publish functions...
Meteor.publish 'user', ->
  if @userId then Meteor.users.find @userId, fields: { type: 1 } else []
