# Routes and Routing handling goes here
# Memo: this file is shared on client and server

Router.configure
  layoutTemplate: 'layout' # All routes templates are inserted in 'layout'
  # The router is automatically rendered and takes up all the body.

Router.map ->
  @route 'home', # Declare a route named 'home'
    path: '/' # the url that triggers this route
    template: 'homepage' # The template shown in this route
  @route 'login', path: '/login'
