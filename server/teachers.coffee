tests = share.tests

getQuestionCount= (test) -> tests.findOne(_id: test).questions.length
getEmptyQuestion= (test) ->
  {
    index: getQuestionCount(test)
    question:''
    score:''
    answers:['','']
  }


Meteor.methods
  'addAnswer':(test,ques)->
    console.log 'TestEditor>> adding an empty answer to the question n ' + (ques+1)
    tests.update {_id: test, 'questions.index': ques},$push: 'questions.$.answers':''


  'pullAnswer': (test,ques,answ) ->
    console.log 'TestEditor>> removing the answer "'+answ+'" from the question n ' + (ques+1)
    tests.update {_id: test, 'questions.index': ques},$pull: {'questions.$.answers': answ}


  'addQuestion':(test) ->
    console.log 'TestEditor>> adding an empty question'
    tests.update {_id: test},$push: 'questions': getEmptyQuestion(test)

  'updateQuestion':(test,ques,cont) ->
    tests.update {_id: test, 'questions.index': ques}
