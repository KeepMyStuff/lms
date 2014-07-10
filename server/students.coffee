tests = new Meteor.Collection "tests"
testsResults = new Meteor.Collection "testsResults"

tests.allow
  insert: -> yes
  update: -> yes
  remove: -> yes

Meteor.publish 'tests', ->
  tests.find({},{fields: {solutions:0}})

Meteor.methods
  'checkTest': (answers) ->
    currentTest=tests.findOne()
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
      testId:tests.findOne()._id
      studentName:Meteor.users.findOne(@userId).username,
      studentScore:sScore,
      totScore:totScore,
      mark:sScore/totScore*100
    console.log result
    testsResults.insert result
    console.log corrAns
    corrAns

# Populate tests (temporary)
Meteor.startup ->
  tests.remove({})
  console.log moment().format()
  if tests.find().count() < 2
    tests.insert
      title: 'Verifica di Matematica'
      assignations:[
        {
          class:"4IA"
          time:moment().format("DD/MM/YYYY")
          duration:"60"
        }
      ]
      questions: [
        {
          index: 1, score:2
          question: 'Di che colore è il cavallo bianco di napoleone?',
          answers: ["Bianco", "Nero", "Giallo"]
        },
        {
          index: 2, score:2,
          question: 'Questa è la domanda numero 2?',
          answers: ["no", "forse", "si"]
        },
        {
          index: 3, score:1
          question: 'Bisogna tenere a mente che una domanda pobrebbe essere
          piuttosto lunga. Questo significa che 1+2 non fa half life 3,giusto?',
          answers:[
            "a dire il vero non sappiamo bene la lunghezza di una
            risposta. Infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!",
            "a dire il vero non sappiamo bene la lunghezza di una
            risposta.Infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!",
            "a dire il vero non sappiamo bene la lunghezza di una
            risposta. infatti ad una domanda molto lunga la risposta potrebbe
            essere breve. E invece no!"
          ]
        }
      ]
      solutions:[[true, false, false],[false,false,true],[true,false,false]]
###
      tests.insert
        title:''
        assignations:[
          {
            class:''
            time:''
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
            index: 0
            score:''
            question:''
            answers:['','']
          }
        ]
###
