# Routes and Routing handling goes here
# Memo: this file is shared on client and server

Router.configure
  layoutTemplate: 'layout' # All routes templates are inserted in 'layout'
  notFoundTemplate: '404' # Shown when the user accesses a non existant route
  # The router is automatically rendered and takes up all the body.

# True if the user is logged in and is an administrator
UI.registerHelper 'is', (what) ->
  Meteor.user() and Meteor.user().type is what

Router.map ->
  @route 'home', # Declare a route named 'home'
    path: '/' # the url that triggers this route
    #onBeforeAction: -> Router.go 'me' if Meteor.user()
  @route 'me',
    onBeforeAction: ->
      Router.go 'admin' if Meteor.user() and Meteor.user().type is 'admin'
      Router.go 'login' if !Meteor.user()
  @route 'admin',
    path: '/admin/:_id?'
    data: -> Meteor.users.findOne _id: @params._id
  @route 'login',
    path: '/login', onBeforeAction: -> Router.go 'me' if Meteor.user()
  @route '404', path: '*'
