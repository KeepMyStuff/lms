###
inediting = new Meteor.Collection 'inediting'
Meteor.publish 'tests', -> inediting.find()
inediting.allow
  insert: -> yes
  update: -> yes
  remove: -> yes

Meteor.methods
  'pullAnswer': (test,ques,answ) ->
    inediting.update {_id: test, 'questions.i': ques},
                    $pull: {'questions.$.answers': answ}
###
