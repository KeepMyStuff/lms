# Account management: server side code
getUser = (id) -> Meteor.users.findOne id
isAdmin = (id) -> id and getUser(id).type is 'admin'
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

# Meteor-side clean up and error checking
impeartiveCleanUp = ->
  count = classes.find().count() + Meteor.users.find().count()
  if count > 0
    console.log "Checking "+count+" documents..."
    for i in Meteor.users.find().fetch()
      # Clean up admin documents
      if i.type is 'admin'
        Meteor.users.update i._id, $unset: {classes:'', class: ''}
      # Clean up teacher documents
      else if i.type is 'teacher'
        Meteor.users.update i._id, $unset: class: ''
        if not i.classes then Meteor.users.update j._id, classes: []
        for j in classes.find().fetch()
          # Check classes
          if !j.students then classes.update j._id, $set: students: []
          if !j.teachers then classes.update j._id, $set: teachers: []
          if j.teachers.indexOf i._id >= 0
            Meteor.users.update i._id, $addToSet: classes: j._id
          else if i.classes.indexOf j._id >= 0
            Meteor.users.update i._id, $pull: classes: j._id
      # Clean up student documents
      else if i.type is 'student'
        Meteor.users.update i._id, $unset: classes: ''
      # Invalid user document
      else
        console.log "Found user with no valid type: "+i._id
        Meteor.users.remove i._id
  console.log 'Done Clean up'

# Database-side clean up and error checking
dbCleanUp = ->
  console.log "Starting db cleanup..."
  a = classes.update (teachers: $exists: no), $set: teachers: []
  a = classes.update (students: $exists: no), $set: students: []
  if a>0
    console.log "Found some problems in the classes. Fixed"
  a=Meteor.users.find (type: 'teacher', classes: $exists: no), $set: classes: []
  if a>0
    console.log "Found some problems in teachers. Fixed"
  a = Meteor.users.find(type: 'student', class: $exists: no).count()
  if a>0
    console.log "Done. There are "+a+"students that do not belong in a class"
  a = Meteor.users.remove ($exists: type: no)
  if a>0
    console.log "Found "+a+" invalid user documents. Removed"
  console.log "Done."

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

# Publications and Permissions

Meteor.publish 'classes', ->
  if @userId
    user = getUser @userId
    if user.type is 'admin'
      classes.find()
    else if user.type is 'student'
      classes.findOne user.classId
    else if user.type is 'teacher'
      classes.find teachers: $elemMatch: _id: @userId
    else []

Meteor.users.allow gibPowerToAdmins
classes.allow gibPowerToAdmins

Meteor.publish 'users', ->
  if isAdmin @userId then Meteor.users.find() else []
# Tell the user his "type" field
# For some reason meteor doesn't like "findOne" inside publish functions...
Meteor.publish 'user', ->
  if @userId then Meteor.users.find @userId, fields: { type: 1 } else []
