tests = share.tests = new Meteor.Collection 'tests'

Meteor.subscribe 'tests', ->
  Template.test.currentTest = Template.testResult.currentTest = tests.findOne()
  console.log Template.test.currentTest

Template.test.helpers
  that : -> this

Handlebars.registerHelper 'className', ->
  share.classes.findOne({students: Meteor.user()._id}).year +
  share.classes.findOne({students: Meteor.user()._id}).course +
  share.classes.findOne({students: Meteor.user()._id}).section

Handlebars.registerHelper 'todayDate', ->
  moment().format("DD/MM/YYYY")

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
    Handlebars.registerHelper 'result', ->
      Meteor.call 'getTestResult', tests.findOne(), (e, result) ->
        result
  UI.render(Template.testResult)
