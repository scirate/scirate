class SubscribeToggle
  subscribe: ->
    $.post "/feed/#{@fid}/subscribe", (newel) =>
      @$el.html($(newel).html())

  unsubscribe: ->
    $.post "/feed/#{@fid}/unsubscribe", (newel) =>
      @$el.html($(newel).html())

  constructor: (@$el) ->
    @fid = @$el.attr('data-feedid')

    @$el.on 'click', '.subscribe', => @subscribe()

    # Unsubscribe button rollover
    @$el.on 'mouseenter', '.unsubscribe', =>
      @$el.find('.unsubscribe')
          .removeClass('btn-success')
          .addClass('btn-danger')
          .text("Unsubscribe")

    @$el.on 'mouseleave', '.unsubscribe', =>
      @$el.find('.unsubscribe')
          .removeClass('btn-danger')
          .addClass('btn-success')
          .text("Subscribed")

    @$el.on 'click', '.unsubscribe', => @unsubscribe()



$ ->
  if $('.subscribe-toggle').length
    $('.subscribe-toggle').each ->
      new SubscribeToggle($(this))
