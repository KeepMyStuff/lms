Meteor.methods
  'addAnswer':(test,ques)->
    tests.update {_id: test, 'ques': @index},
                      $push: 'questions.$.answers':''

  'pullAnswer': (test,ques,answ) ->
    tests.update {_id: test, 'questions.i': ques},
                    $pull: {'questions.$.answers': answ}
