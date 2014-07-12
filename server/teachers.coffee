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
    tests.update {_id: test, 'questions.index': ques},$push: 'questions.$.answers':''
    console.log 'added an empty answer to the question n ' + (ques+1) + ' (index:'+ques+')'

  'pullAnswer': (test,ques,answ) ->
    tests.update {_id: test, 'questions.index': ques},$pull: {'questions.$.answers': answ}
    console.log 'removed the answer "'+answ+'" from the quwstion n ' + (ques+1) + '(index:'+ques+')'

  'addQuestion':(test) ->
    tests.update {_id: test},$push: 'questions': getEmptyQuestion(test)

  'updateQuestion':(test,ques,cont) ->
    tests.update {_id: test, 'questions.index': ques}
