Tests= new Meteor.Collection "tests"

Meteor.subscribe 'tests', ->
  Template.test.currentTest=Template.testResult.currentTest=Tests.findOne()
  console.log Template.test.currentTest

#Template.quiz.get = -> tests.findOne() # Temporary

#Template.quiz.events 'click .btn-end': ->
