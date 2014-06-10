Router.configure
  layoutTemplate: 'layout'

Router.map ->
  @route 'home',
    path: '/'
    template: 'homepage'
