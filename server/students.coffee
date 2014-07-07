Tests = new Meteor.Collection "tests"

Meteor.publish 'tests', ->
  Tests.find({},{fields: {'questions.answers.correctAnswer':0}})
# Populate tests (temporary)
Meteor.startup ->
  Tests.remove()
  if Tests.find().count() is 0
    sampleQuiz=
      title: 'Verifica di Italiano', index: Tests.find().count()+1,
      date: moment().format("DD/MM/YYYY"),
      questions: [
        {
          title: 'Di che colore è il cavallo bianco di napoleone?', index: 1
          answers: [
            {title:"Wow!", correctAnswer:true},
            {title:"Not wow", correctAnswer:true},
            {title:"Such wow", correctAnswer:false}
          ], questResult:false, questValue:1
        }
        {
          title: 'Questa è la domanda numero 2?', index: 2
          answers: [
            {title:"no", correctAnswer:false},
            {title:"forse", correctAnswer:false},
            {title: "si", correctAnswer:true}
          ], questResult:false, questValue:2
        }
        {
          title: 'Bisogna tenere a mente che una domanda pobrebbe essere
          piuttosto lunga. Questo significa che 1+2 non fa half life 3,giusto?',
          index: 3
          answers:[
            {title:"a dire il vero non sappiamo bene la lunghezza di una
            risposta. Infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!", correctAnswer:false},
            {title:"a dire il vero non sappiamo bene la lunghezza di una
            risposta. Infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!", correctAnswer:false},
            {title:"a dire il vero non sappiamo bene la lunghezza di una
            risposta. Infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!", correctAnswer:true}
          ], questResult:false, questValue:1
        }
      ]
    Tests.insert sampleQuiz
    console.log 'Test "'+sampleQuiz.title+'" added.'
