class window.Scirate
  @login: -> redirect("/signin")

class View extends Backbone.View

class View.Search extends View
  events:
    'change #folder': "updateFolder"

  updateFolder: ->
    @$('.feed').addClass('hidden').attr('disabled', true)
    $sel = @$('#feed_' + @$('#folder').val())
    $sel.removeClass('hidden').attr('disabled', false)

  initialize: ->
    @updateFolder()
  

$ ->
  if $('#landing').is(':visible')
    $('.searchbox input').focus()

  if $('#search_page').is(':visible')
    new View.Search(el: '#search_page')
