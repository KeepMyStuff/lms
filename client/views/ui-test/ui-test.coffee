Template.uiTest.rendered = ->
  $('.main-drop').on 'click', -> $('.drop-wrap ul').slideToggle()
