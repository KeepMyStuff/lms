tests = share.tests = new Meteor.Collection 'tests'

Meteor.subscribe 'tests', ->
  Template.test.currentTest = Template.testResult.currentTest = tests.findOne()
  console.log Template.test.currentTest

Template.test.helpers
  that : -> this
  # why it doesn't work? just trying with the class id, in future it will be
  # the class name
  class : -> share.classes.find({students: Meteor.user()._id})._id

Template.test.events 'click .btn-end': ->
  # trying to print when I click the "test end" button but
  # it returns "undefinied"
  console.log share.classes.find({students: Meteor.user()._id})._id
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
