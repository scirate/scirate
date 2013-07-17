class window.Scirate
  @login: -> redirect("/signin")

$ ->
  if $('#landing').is(':visible')
    $('.searchbox input').focus()
