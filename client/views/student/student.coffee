tests = new Meteor.Collection
# Populate tests (temporary)
if tests.find().count() is 0
  tests.insert
    title: 'Verifica di Matematica', index: tests.find().count()+1,
    date: moment().format("MM-DD-YYYY"),
    questions: [
      {
        title: 'Di che colore è il cavallo bianco di napoleone?', index: 1
        answers: [
          {title:"Wow!"}, {title:"Not wow"}, {title:"Such wow"}
        ]
        correctAnswers:[{title:true}, {title:false}, {title:false}],
        questResult:false
      }
      {
        title: 'Questa è la domanda numero 2?', index: 2
        answers: [
          {title:"no"}, {title:"forse"}, {title: "si"}
        ]
        correctAnswers:[{title:false}, {title:false}, {title:true}],
        questResult:false
      }
      {
        title: 'Bisogna tenere a mente che una domanda pobrebbe essere
        piuttosto lunga. Questo significa che 1+2 non fa half life 3, giusto?',
        index: 3
        answers:[
          {title:"a dire il vero non sappiamo bene la lunghezza di una
          risposta. Infatti ad una domanda molto lunga la risposta potrebbe
          essere breve. E invece no!"},
          {title:"a dire il vero non sappiamo bene la lunghezza di una
          risposta. Infatti ad una domanda molto lunga la risposta potrebbe
          essere breve. E invece no!"},
          {title:"a dire il vero non sappiamo bene la lunghezza di una
          risposta. Infatti ad una domanda molto lunga la risposta potrebbe
          essere breve. E invece no!"}
        ]
        correctAnswers:[{title:false}, {title:false}, {title:false}],
        questResult:false
      }
    ]


Template.quiz.get = -> tests.findOne() # Temporary

Template.quiz.events 'click .btn-end': ->
