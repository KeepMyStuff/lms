inediting = new Meteor.Collection null
#Meteor.subscribe 'inediting'

if inediting.find().count() is 0
  console.log ">> BEFORE INSERT"
  console.log inediting.findOne()
  inediting.insert
    title:''
    assignations:[
      {
        class:''
        date:''
        hour:''
        duration:''
      }
    ]
    permissions:[
      {
        permission:''
        subject:''
      }
    ]
    questions:[{
        i: 0
        question:''
        score:''
        answers:[]
      }
    ]
  console.log ">> AFTER INSERT"
  console.log inediting.findOne()
    #solutions:[[]]

getEmptyQuestion= ->
#  console.log "Adding question n° " + inediting.findOne().questions.length
  emptyquestion= {
    i: inediting.findOne().questions.size
    question:''
    score:''
    answers:["prova"]
  }

#console.log "number of questions " + inediting.findOne().questions.length
record = inediting.findOne()
Template.testEditor.questions= -> inediting.findOne().questions
Template.testEditor.resp= -> this
Template.testEditor.qindex= -> @i+1

console.log ">> AFTER HELPERS"

Template.testEditor.events
  "click .addanswerbtn":()->
    inediting.update {_id: record._id, 'questions.i': @i},
                      $push: 'questions.$.answers': ''

  "click .addquestionstbtn":->
    inediting.update {_id: record._id},
                    $push: 'questions': getEmptyQuestion()
    #console.log inediting.findOne()

  "click .removeanswerbtn":(e) ->
    id = $($(e.currentTarget).parents().get 3).find('h4').text().replace(")","") - 1
    #console.log id
    #answers.find('.btn').each (i)->
    #  if $(this).is(e.currentarget)
    #Meteor.call 'pullAnswer', record._id, id, this
    #inediting.update {_id: record._id, 'questions.i': id}, $pull: {'questions.$.answers': this}
console.log ">> COFEE END"
