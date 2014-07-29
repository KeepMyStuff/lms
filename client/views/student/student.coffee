tests = share.tests = new Meteor.Collection 'tests'

Meteor.subscribe 'tests', ->
  Template.test.currentTest = Template.testResult.currentTest = tests.findOne()
  console.log Template.test.currentTest

share.classes = new Meteor.Collection 'classes' # Classes
Meteor.subscribe 'classes'

Template.test.helpers
  class : -> share.classes.find({students: Meteor.user()._id})
  that : -> this

Template.test.events 'click .btn-end': ->
  solutions = []
  x=0
  i=0
  $('.question').each ->
    solutions.push []
    i++
    $('.check', this).each ->
      solutions[i-1].push $(this).is(':checked')
  console.log solutions
  console.log share.classes.find({students: Meteor.user()._id})
  Meteor.call 'checkTest', solutions, (e, x) ->
    console.log x
