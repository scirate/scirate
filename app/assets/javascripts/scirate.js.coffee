class window.SciRate
  @login: -> redirect("/login")

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

class View.SciteToggle extends View
  events:
    'click .scite': "scite"
    'click .unscite': "unscite"
    'click .expand': "expand"
    'click .collapse': "collapse"

  scite: ->
    paper_id = @$el.attr('data-paper-id')
    @expand()
    @$el.addClass('active')
    # We don't wait for the post to come back before updating UI
    # May want error handling here at some stage
    $.post "/api/scite/#{paper_id}"
    return false

  unscite: ->
    paper_id = @$el.attr('data-paper-id')
    @collapse()
    @$el.removeClass('active')
    $.post "/api/unscite/#{paper_id}"
    return false

  expand: ->
    $paper = @$el.closest('li.paper')
    $paper.find('.abstract').removeClass('hidden')
    $paper.find('.expand').addClass('hidden')
    $paper.find('.collapse').removeClass('hidden')

  collapse: ->
    $paper = @$el.closest('li.paper')
    $paper.find('.abstract').addClass('hidden')
    $paper.find('.expand').removeClass('hidden')
    $paper.find('.collapse').addClass('hidden')


class View.SubscribeToggle extends View
  initialize: ->
    @uid = @$el.attr('data-feed-uid')
    @fullname = @$el.attr('data-feed-fullname')

  events:
    'click .subscribe': "subscribe"
    'click .unsubscribe': "unsubscribe"
    'mouseenter .unsubscribe': "rolloverStart"
    'mouseleave .unsubscribe': "rolloverStop"

  subscribe: ->
    @$el.addClass('active')
    $.post "/api/subscribe/#{@uid}"

    # Update "my feeds" list
    $leaf = $(".my-feeds .leaf:first").clone()
    $leaf.attr('title', @uid)
    $leaf.find('a').attr('href', "/arxiv/#{@uid}")
    $leaf.find('a').text(@fullname)
    $(".my-feeds .tree").append($leaf)

    $(".my-feeds .leaf").sort((a, b) ->
      if $(a).find('a').text() > $(b).find('a').text()
        1
      else
        -1
    ).appendTo(".my-feeds .tree")
    

  unsubscribe: ->
    @$el.removeClass('active')
    $.post "/api/unsubscribe/#{@uid}"
    $(".my-feeds [title='#{@uid}']").remove()

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

class View.AbstractToggle extends View
  initialize: ->
    if SciRate.current_user
      @expand = SciRate.current_user.expand_abstracts
    else
      @expand = false
    @render()

  events:
    'click': 'toggle'

  render: ->
    if @expand
      $('.abstract.hideable').removeClass('hidden')
      @$el.html('Hide unscited abstracts')
    else
      $('.abstract.hideable').addClass('hidden')
      @$el.html('Show all abstracts')

  toggle: ->
    if @expand
      @disable()
    else
      @enable()

  disable: ->
    @expand = false; @render()
    if SciRate.current_user
      $.post '/api/settings', { expand_abstracts: false }

  enable: ->
    @expand = true; @render()
    if SciRate.current_user
      $.post '/api/settings', { expand_abstracts: true }

$ ->
  $(document).ajaxError (ev, jqxhr, settings, err) ->
    if err == "Unauthorized"
      SciRate.login()

  # Setup generic dropdowns
  $('.dropdown').each ->
    $(this).mouseenter -> $(this).find('.dropdown-toggle').dropdown('toggle')
    $(this).mouseleave -> $(this).find('.dropdown-toggle').dropdown('toggle')

  # Bind scite toggles
  $('.scite-toggle').each ->
    new View.SciteToggle(el: this)

  # Feed subscription toggles
  $('.subscribe-toggle').each ->
    new View.SubscribeToggle(el: this)

  # Global toggle for showing all abstracts
  $('.abstract-toggle').each ->
    new View.AbstractToggle(el: this)

  # Welcome banner resend confirm button
  $('#resend-confirm-email').click ->
    $.post '/api/resend_confirm', ->
      $('#resend-confirm-email').popover(
        content: "Sent"
      )

  # Landing page specific
  $('#landing').each ->
    $('.searchbox input').focus()

  # Search page specific
  $('#search_page').each ->
    new View.Search(el: this)

  # Show links on hover
  $('li.paper').on 'mouseover', (ev) ->
    $(this).find('.links').removeClass('hidden')

  $('li.paper').on 'mouseout', (ev) ->
    $(this).find('.links').addClass('hidden')
