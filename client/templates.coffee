# Here goes the Templates logic code
login = (user,pass) -> # Perform login request
Template.login.events
	'keypress .form-control': (e,t) ->
		if e.keyCode is 13 then login t.find('.mail').value, t.find('.pass').value
	'click .login': (e,t) -> login t.find('.mail').value, t.find('.pass').value
