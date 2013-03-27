class SubscribeToggle
  subscribe: ->
    $.post "/feeds/#{@fid}/subscribe", (html) =>
      @$el.replaceWith(html)

  unsubscribe: ->
    $.post "/feeds/#{@fid}/unsubscribe", (html) =>
      @$el.replaceWith(html)

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
