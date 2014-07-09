# Account management: server side code
getUser = (id) -> Meteor.users.findOne id
isAdmin = (id) -> id and getUser(id).type is 'admin'
###mailVerified = (id) ->
  return unless id; u = getUser id
  u and (!u.emails or (u.emails[0].verified is yes))###
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
      email: 'user'+i+"@photon.app", verified: yes
      type: 'student'

Meteor.startup -> # Executed when the server starts
  # Create default admin user if there are no users
  if Meteor.users.find().count() is 0
    id = Accounts.createUser
      username: 'admin', password: 'admin',
      email: 'admin@photon.app', type: 'admin', verified: yes
    console.log '''No users in the database. Created default admin user
    Username: admin - Password: admin - ID: '''+id
  else
    userCount = Meteor.users.find().count()
    console.log "There are "+userCount+" users in the database."
  # Check email settings
  if !process.env.MAIL_URL
    console.log "### WARNING ###\nPhoton won't be able to send emails!"
  else console.log "Using EMAIL: "+process.env.MAIL_URL

Accounts.config forbidClientAccountCreation: yes
Accounts.onCreateUser (options,user) ->
  user.type = options.type or 'student'; user
  user.fullname = options.fullname or options.username #or options.email
  if options.verified is yes then user.emails[0].verified = yes
  return user # Don't remove this instruction.

# Email configuration
Accounts.emailTemplates.siteName = 'Photon'
Accounts.emailTemplates.from = 'Admin'
Accounts.emailTemplates.resetPassword.subject = (user) ->
  "Reset your "+Accounts.emailTemplates.siteName+" password"
Accounts.emailTemplates.resetPassword.text = (user, url) ->
  token = url.split '/'; token = token[token.length - 1]
  link = url.split('/')[0]+'//'+url.split('/')[1]+'/set/'+token
  '''You can set a new password by clicking\
  on the following link: '''+link
Accounts.emailTemplates.enrollAccount.subject = (user) ->
  "Activate your "+Accounts.emailTemplates.siteName+" account"
Accounts.emailTemplates.enrollAccount.text = (user, url) ->
  token = url.split '/'; token = token[token.length - 1]
  link = url.split('/')[0]+'//'+url.split('/')[1]+'/set/'+token
  '''You can set a password and activate your account by clicking\
  on the following link: '''+link

Meteor.methods
  'newUser': (options) ->
    u = getUser @userId
    if !u or u.type isnt 'admin'
      throw new Meteor.Error 403, 'Insufficient permission'
    if Meteor.users.findOne(username:options.username)
      console.log Meteor.users.findOne(username:options.username)
      return no
    console.log "Create Account request accepted from "+u.username
    id = Accounts.createUser options
    if options.email and !options.verified
      console.log "Sending enrollment email to "+id
      Accounts.sendEnrollmentEmail id
    return id
  'deleteUser': (id) ->
    u = getUser @userId
    if u and u.type is 'admin'
      console.log "user id:"+id+" is being deleted from the database"
      Meteor.users.remove id; yes
    else no
  'assumeIdentity': (id) ->
    # This is broken, needs fix
    u = getUser @userId
    if u.type is 'admin'
      @setUserId id; yes
    else no
  'newPassword': (id,pass) ->
    if isAdmin(@userId) and getUser id
      console.log "user id:"+id+" has been given a new password"
      Accounts.setPassword id, pass
    else
      console.log "Password change request for "+id+"by "+@userId+" denied"
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
    else
      if user.type is 'student'
        classes.findOne students: user._id
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
