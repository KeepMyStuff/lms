# Routes and Routing handling goes here
# Memo: this file is shared on client and server

Router.configure
  layoutTemplate: 'layout' # All routes templates are inserted in 'layout'
  notFoundTemplate: '404' # Shown when the user accesses a non existant route
  # The router is automatically rendered and takes up all the body.

# True if the user is logged in and is an administrator
admin = -> Meteor.user() and Meteor.user().type is 'admin'

Router.map ->
  @route 'home', # Declare a route named 'home'
    path: '/' # the url that triggers this route
    template: 'homepage' # The template shown in this route
    onBeforeAction: -> Router.go 'admin' if admin()
  @route 'login', path: '/login'
  @route 'admin',
    onBeforeAction: -> Router.go 'home' if !admin()
