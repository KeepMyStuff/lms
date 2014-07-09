Tests = new Meteor.Collection "tests"
TestsResults = new Meteor.Collection "testsResults"

Meteor.publish 'tests', ->
  Tests.find({},{fields: {solutions:0}})

Meteor.methods
  'checkTest': (answers) ->
    currentTest=Tests.findOne()
    sScore=0 #student's total score
    totScore=0 #test's total score
    x=0  #number of correct options in a question
    corrAns=[] #corrected answers
    for i in [0..currentTest.questions.length-1]
      totScore+= currentTest.questions[i].score
    for i in [0..answers.length-1]
      corrAns.push []
      for k in [0..answers[i].length-1]
        if answers[i][k] is currentTest.solutions[i][k]
          corrAns[i].push true
          x++
        else
          corrAns[i].push false
        currentTest.questions[i].answers.length
      if currentTest.questions[i].answers.length is x
        sScore+=currentTest.questions[i].score
      x=0
    console.log "student's score= "+sScore
    mark = sScore/totScore*100
    result=
      testId:Tests.findOne()._id
      studentName:Meteor.users.findOne(@userId).username,
      studentScore:sScore,
      totScore:totScore,
      mark:sScore/totScore*100
    console.log result
    TestsResults.insert result
    console.log corrAns
    corrAns

# Populate tests (temporary)
Meteor.startup ->
  Tests.remove({})
  if Tests.find().count() is 0
    sampleQuiz=
      solutions:[[true, false, false],[false,false,true],[true,false,false]]
      assignations:[{classe:"4IA"},
                    {date:moment().format("DD/MM/YYYY")},
                    {duration:"60"}],
      title: 'Verifica di Matematica',
      questions: [
        {
          question: 'Di che colore è il cavallo bianco di napoleone?',
          index: 1, questResult:false, score:2
          answers: [
            {answer:"Wow!"}, {answer:"Not wow"}, {answer:"Such wow"}
          ]
        },
        {
          question: 'Questa è la domanda numero 2?',
          index: 2, questResult:false, score:2,
          answers: [
            {answer:"no"}, {answer:"forse"}, {answer: "si"}
          ]
        },
        {
          question: 'Bisogna tenere a mente che una domanda pobrebbe essere
          piuttosto lunga. Questo significa che 1+2 non fa half life 3,giusto?',
          index: 3, questResult:false, score:1
          answers:[
            {answer:"a dire il vero non sappiamo bene la lunghezza di una
            risposta. Infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!"},
            {answer:"a dire il vero non sappiamo bene la lunghezza di una
            risposta. Infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!"},
            {answer:"a dire il vero non sappiamo bene la lunghezza di una
            risposta. Infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!"}
          ]
        }
      ]
    Tests.insert sampleQuiz
