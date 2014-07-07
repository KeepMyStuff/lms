Tests= new Meteor.Collection "tests"

Meteor.subscribe 'tests', ->
  Template.test.currentTest=currentTest=Tests.findOne()
  console.log Template.test.currentTest

#Template.quiz.get = -> tests.findOne() # Temporary

Template.test.events 'click .btn-end': ->
  console.log "WOW"
  solutions = []
  i=0
  $('.question').each ->
    solutions.push []
    i++
    $('.check', this).each ->
      solutions[i-1].push $(this).is(':checked')
  console.log solutions
