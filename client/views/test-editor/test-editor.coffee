tests = share.tests
Meteor.subscribe 'tests'

console.log ">> TEST EDITOR after subscribe:"
console.log tests.findOne(skip: 1)

console.log ">> TEST EDITOR after (possible) insert"
console.log getTest

getEmptyQuestion= ->
#  console.log "Adding question n " + getTest.questions.length
  emptyquestion= {
    i: getTest.questions.length
    question:''
    score:''
    answers:['','']
  }

#console.log "number of questions " + getTest.questions.length

getTest = Template.testEditor.get = -> tests.findOne(skip: 1)
Template.testEditor.getquestions= -> getTest().questions
Template.testEditor.that= -> this #hahahaha, no!
Template.testEditor.qindex= -> @i+1

Template.testEditor.events
  "click .addanswerbtn":()->
    tests.update {_id: record._id, 'questions.i': @i},
                      $push: 'questions.$.answers':''

  "click .addquestionbtn":->
    tests.update {_id: record._id},
                    $push: 'questions': getEmptyQuestion()
    #console.log getTest

  "click .removeanswerbtn":(e) ->
    index = $($(e.currentTarget).parents().get 3).find('h4').text().replace(")","") - 1
    console.log 'TestEditor>> Trying to remove the answer "'+this+'" from the question n '+index
    Meteor.call 'pullAnswer', record._id, index, this

###
    toremove='questions.'+index+'.answers'
    console.log "remove from: '"+toremove+"'"
    tests.update {_id: record._id}, $pull:{ toremove: this}
###

#, 'questions.i': index
    #console.log id
    #answers.find('.btn').each (i)->
    #if $(this).is(e.currentarget)
    #Meteor.call 'pullAnswer', record._id, index, this
    #tests.update {_id: record._id, 'questions.i': id}, $pull: {'questions.$.answers': this}
