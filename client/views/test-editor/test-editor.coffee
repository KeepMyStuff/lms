tests = share.tests
Meteor.subscribe 'tests'

getTest = -> tests.findOne({},skip: 1)
getQuestionCount =-> getTest().questions.length -1

console.log getTest()

getEmptyQuestion= ->
#console.log "Adding question n " + getQuestionCount()
  {
    index: getQuestionCount()
    question:''
    score:''
    answers:['','']
  }

#console.log "number of questions " + getTest().questions.length


Template.testEditor.getQuestions= -> getTest().questions
  #for question in getTest().questions

Template.testEditor.that= -> this
Template.testEditor.qindex= -> @i+1

Template.testEditor.events
  "click .addanswerbtn":->
    Meteor.call 'addAnswer', getTest()._id, @index
###
    tests.update {_id: getTest()._id, 'questions.index': @index},
                      $push: 'questions.$.answers':''
###
  "click .addquestionbtn":->
    console.log "adding question no"
    tests.update {_id: getTest()._id},
                    $push: 'questions': getEmptyQuestion()
    #console.log getTest()

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
