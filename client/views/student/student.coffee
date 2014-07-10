tests = share.tests = new Meteor.Collection 'tests'

Meteor.subscribe 'tests', ->
  Template.test.currentTest = tests.findOne()
  console.log Template.test.currentTest

Template.test.that = -> this
Template.test.class = -> share.classes.findOne students: Meteor.user()._id
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
  Meteor.call 'checkTest', solutions, (e, x) ->
    console.log x
