# Routes and Routing handling goes here
# Memo: this file is shared on client and server

Router.configure
  layoutTemplate: 'layout' # All routes templates are inserted in 'layout'
  notFoundTemplate: '404' # Shown when the user accesses a non existant route
  # The router is automatically rendered and takes up all the body.

###share.verified = ->
  no unless Meteor.user()
  !Meteor.user().emails or Meteor.user().emails[0].verified is yes###
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
  @route 'home', path: '/'
  @route 'admin', controller: adminController
  @route 'users', path: '/admin/users/:_id?', controller: usersController
  @route 'admin-classes',
    path: '/admin/classes/:_id?',
    template: 'adminClasses',
    controller: classesController
  @route 'reset',
    path: '/set/:token?'
    onBeforeAction: -> Router.go 'me' if Meteor.user()
  @route 'login', onBeforeAction: -> Router.go 'me' if Meteor.user()
  @route 'settings',
    onBeforeAction: -> Router.go 'login' if !Meteor.user()
  @route 'me',
    # Auto user redirect
    template: '404',
    onBeforeAction: ->
      Router.go 'login' if !Meteor.user()
      Router.go 'admin' if Meteor.user() and Meteor.user().type is 'admin'
      Router.go 'student' if Meteor.user() and Meteor.user().type is 'student'
  @route 'student'
  @route 'test-editor', template: 'testEditor'
  @route 'class', path: '/class/:_id'
  @route 'ui-test', template: 'uiTest' # TODO: remove this later
  @route 'test',
    path: '/student/test'
    onBeforeAction: ->
      Router.go 'me' if !Meteor.user() or Meteor.user().type isnt 'student'
  @route 'test-result', template: 'testResult',
    path:'/student/test/test-result',
    onbeforeAction: ->
      Router.go 'me' if !Meteor.user() or Meteor.User().type isnt 'student'
  @route '404', path: '*'
