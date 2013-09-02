class window.SciRate
  @login: -> redirect("/signin")

class View extends Backbone.View

class View.Search extends View
  initialize: ->
    @updateFolder()

  events:
    'change #folder': "updateFolder"

  updateFolder: ->
    @$('.feed').addClass('hidden').attr('disabled', true)
    $sel = @$('#feed_' + @$('#folder').val())
    $sel.removeClass('hidden').attr('disabled', false)

class View.PaperItem extends View
  events:
    'click .scite': "scite"
    'click .unscite': "unscite"
    'click .expand': "expand"
    'click .collapse': "collapse"

  scite: ->
    $toggle = @$('.scite-toggle')
    paper_id = $toggle.attr('data-paper-id')
    $.post "/api/scite/#{paper_id}", (resp) =>
      @expand()
      $toggle.replaceWith(resp)
    return false

  unscite: ->
    $toggle = @$('.scite-toggle')
    paper_id = $toggle.attr('data-paper-id')
    $.post "/api/unscite/#{paper_id}", (resp) =>
      @collapse()
      $toggle.replaceWith(resp)
    return false

  expand: ->
    @$('.abstract').removeClass('hidden')
    @$('.expand').addClass('hidden')
    @$('.collapse').removeClass('hidden')

  collapse: ->
    @$('.abstract').addClass('hidden')
    @$('.expand').removeClass('hidden')
    @$('.collapse').addClass('hidden')


class View.SubscribeToggle extends View
  initialize: ->
    @fid = @$el.attr('data-feedid')

  events:
    'click .subscribe': "subscribe"
    'click .unsubscribe': "unsubscribe"
    'mouseenter .unsubscribe': "rolloverStart"
    'mouseleave .unsubscribe': "rolloverStop"

  subscribe: ->
    $.post "/api/subscribe/#{@fid}", (newel) =>
      @$el.html($(newel).html())

  unsubscribe: ->
    $.post "/api/unsubscribe/#{@fid}", (newel) =>
      @$el.html($(newel).html())

  rolloverStart: ->
    @$('.unsubscribe')
      .removeClass('btn-success')
      .addClass('btn-danger')
      .text("Unsubscribe")

  rolloverStop: ->
    @$('.unsubscribe')
      .removeClass('btn-danger')
      .addClass('btn-success')
      .text("Subscribed")

$ ->
  $(document).ajaxError (ev, jqxhr, settings, err) ->
    if err == "Unauthorized"
      SciRate.login()
    
  $('#landing').each ->
    $('.searchbox input').focus()

  $('#search_page').each ->
    new View.Search(el: this)

  $('li.paper').each ->
    new View.PaperItem(el: this)

  $('.subscribe-toggle').each ->
    new View.SubscribeToggle(el: this)
