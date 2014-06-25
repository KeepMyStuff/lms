tests = new Meteor.Collection
# Populate tests (temporary)
if tests.find().count() is 0
	
else
  tests.insert
    title: 'Verifica', index: tests.find().count()+1, questions: [
      {
        title: 'Di che colore è il cavallo di napoleone?', index: 1
        answers: [
          {title:"Wow!"}, {title:"Not wow"}
        ]
      }
      {
        title: 'Questa è la domanda numero?', index: 2
        answers: [
          {title:"2"}, {title:"17"}, title: "22"
        ]
      }
    ]

Template.quiz.get = -> tests.findOne() # Temporary
