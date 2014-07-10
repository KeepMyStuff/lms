Meteor.methods
  'pullAnswer': (test,ques,answ) ->
    tests.update {_id: test, 'questions.i': ques},
                    $pull: {'questions.$.answers': answ}
