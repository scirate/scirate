class Feed
  subscribe: ->
    $.post "/feeds/#{@fid}/subscribe", (html) =>
      @$el.find('.subscribe').replaceWith(html)

  unsubscribe: ->
    $.post "/feeds/#{@fid}/unsubscribe", (html) =>
      @$el.find('.unsubscribe').replaceWith(html)

  constructor: (@$el) ->
    @fid = @$el.attr('data-id')

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
  if $('.feed').length
    new Feed($('.feed'))
