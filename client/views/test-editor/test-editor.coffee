tests = share.tests
Meteor.subscribe 'tests'

getTest = -> tests.findOne({},skip: 1)
getQuestionCount =-> getTest().questions.length

Template.testEditor.getQuestions= -> getTest().questions
#for question in getTest().questions
Template.testEditor.that  = -> this
Template.testEditor.qindex= -> @index+1 + " )"

getAnswerQuestionIndex= (e) ->
  $($(e.currentTarget).parents().get 2).find('h4').text().replace(" )","")- 1

modifying = ''
Template.testEditor.events
  "click .addanswerbtn":->
    console.log 'TestEditor>> asking to add an empty answer to the question n '+ (@index+1)
    Meteor.call('addAnswer', getTest()._id, @index)

  "click .removeanswerbtn":(e) ->
    index = $($(e.currentTarget).parents().get 2).find('h4').text().replace(" )","")- 1
    answer = $($(e.currentTarget).parent()).find('textarea').text()#temporary
    console.log 'TestEditor>> asking to remove the answer "'+this+'" from the question n '+ (index+1)
    Meteor.call 'pullAnswer', getTest()._id, index, ""+this

  "click .addquestionbtn": ->
    console.log "TestEditor>> asking to add an empty question"
    Meteor.call 'addQuestion',getTest()._id

  "blur .questionarea": (e)->
    console.log "TestEditor>> asking to modify the question n "+@index+' in "'+$(e.currentTarget).val()+'"'
    Meteor.call 'updateQuestion', getTest()._id, @index, $(e.currentTarget).val()

  "focus .answerarea": (e)->
    modifying = $(e.currentTarget).val()
    
  "blur .aswerarea": (e)->
    console.log 'TestEditor>> asking to modify the answer "'+modifying+'" in "'+$(e.currentTarget).val()+'"'
    Mateor.Call 'updateAnswer', getTest()._id, getAnswerQuestionIndex(e) , modifying, $(e.currentTarget).val()
