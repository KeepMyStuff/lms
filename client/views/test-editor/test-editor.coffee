tests = share.tests
Meteor.subscribe 'tests'

getTest = -> tests.findOne({},skip: 1)
getQuestionCount =-> getTest().questions.length

Template.testEditor.getQuestions= -> getTest().questions
#for question in getTest().questions
Template.testEditor.that  = -> this
Template.testEditor.qindex= -> @index+1 + " )"

getAnswerInfo= (e)->
  #info_index = $($(e.currentTarget).parents().get 2).find('h4').text().replace(")","") - 1
  info_index = $($(e.currentTarget).parent().parent().parent()).find('h4').text().replace(")","") - 1
  #start temporary workaround
  info_answer = $($(e.currentTarget).parent()).find('textarea').text()
  #end temporary workaround
  console.log '['+info_index+','+info_answer+']'
  [info_index,info_answer]

Template.testEditor.events
  "click .addanswerbtn":->
    console.log 'TestEditor>> asking to add an empty answer to the question n '+ (@index+1)
    Meteor.call('addAnswer', getTest()._id, @index)

  "click .removeanswerbtn":(e) ->
    index = $($(e.currentTarget).parents().get 2).find('h4').text().replace(" )","")- 1
    answer = $($(e.currentTarget).parent()).find('textarea').text()#temporary
    console.log 'TestEditor>> asking to remove the answer "'+this+'" from the question n '+ (index+1)
    Meteor.call 'pullAnswer', getTest()._id, index, ""+this

  "click .addquestionbtn":->
    console.log "TestEditor>> asking to add an empty question"
    Meteor.call 'addQuestion',getTest()._id

  #"keypress .questionarea"->


    ###
    toremove='questions.'+index+'.answers'
    console.log "remove from: '"+toremove+"'"
    tests.update {_id: record._id}, $pull:{ toremove: this}
    ###
