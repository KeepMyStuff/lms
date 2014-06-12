# Account management: server side code
tokenFromUrl = (url) -> s = url.split '/'; s[s.length - 1]
Meteor.startup -> # Executed when the server starts
  # Create default admin user if there are no users
  if Meteor.users.find().count() is 0
    id = Accounts.createUser
      username: 'admin', password: 'admin', email: 'admin@admin.app'
    console.log '''No users in the database. Creating default admin user
    Username: admin - Password: admin - Email: admin@admin.app - ID: '''+id

Accounts.config forbidClientAccountCreation: yes
Accounts.onCreateUser (options,user) ->
  # If user type is not specified, then create an administrator user.
  user.type = options.type or 'admin'

# Email configuration
Accounts.emailTemplates.siteName = 'Photon'
Accounts.emailTemplates.from = 'Admin'
Accounts.emailTemplates.verifyEmail.subject = (user) ->
  "You can now activate your Photon account"
Accounts.emailTemplates.verifyEmail.text = (user, url) ->
  token = url.split '/'; token = token[token.length - 1]
  '''You can verify this email address and start using your account by logging\
  in and using the following token: #{token}'''
