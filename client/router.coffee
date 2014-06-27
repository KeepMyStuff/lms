# Routes and Routing handling goes here
# Memo: this file is shared on client and server

Router.configure
  layoutTemplate: 'layout' # All routes templates are inserted in 'layout'
  notFoundTemplate: '404' # Shown when the user accesses a non existant route
  # The router is automatically rendered and takes up all the body.

# True if the user is logged in and has corresponding type
UI.registerHelper 'is', (what) ->
  Meteor.user() and Meteor.user().type is what

adminController = RouteController.extend
  action: ->
    # Deny access and show '404' to users without permission
    if !Meteor.user() or Meteor.user().type isnt 'admin'
      @render '404'
    else @render()

usersController = adminController.extend
  data: -> Meteor.users.findOne _id: @params._id

classesController = adminController.extend
  data: -> share.classes.findOne _id: @params._id

Router.map ->
  @route 'home', # Declare a route named 'home'
    path: '/' # the url that triggers this route
    #onBeforeAction: -> Router.go 'me' if Meteor.user()
  @route 'admin', controller: adminController
  @route 'users', path: '/admin/users/:_id?', controller: usersController
  @route 'classes', path: '/admin/classes/:_id?', controller: classesController
  @route 'login',
    path: '/login', onBeforeAction: -> Router.go 'me' if Meteor.user()
  @route 'me',
    # Auto user redirect
    onBeforeAction: ->
      Router.go 'login' if !Meteor.user()
      Router.go 'admin' if Meteor.user() and Meteor.user().type is 'admin'
      Router.go 'student' if Meteor.user() and Meteor.user().type is 'student'
  @route 'student',
    path: '/student'
  @route 'quiz',
    path: '/student/quiz'
  @route 'test-editor', template: 'testEditor'
      #onBeforeAction: ->
        #Router.go 'me' if !Meteor.user() or Meteor.user().type isnt 'teacher'
  # Todo: remove this when we finish
  @route 'ui-test', template: 'uiTest'
  @route 'quiz',
    onBeforeAction: ->
      Router.go 'me' if !Meteor.user() or Meteor.user().type isnt 'student'
  @route 'test-result', template: 'testResult', path:'/quiz/test-result',
    onbeforeAction: ->
      Router.go 'me' if !Meteor.user() or Meteor.User().type isnt 'student'
  @route '404', path: '*'
