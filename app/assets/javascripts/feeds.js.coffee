setupFeedPage = ->
  # Feed sidebar tree expansion
  $('.feed-folder i').click ->
    $(this).toggleClass('fa-chevron-right')
    $(this).toggleClass('fa-chevron-down')
    $(this).closest('li').children('ul.tree').toggle(300)

  $('.arXiv-feed-header i').click ->
    $(this).toggleClass('fa-chevron-right')
    $(this).toggleClass('fa-chevron-down')
    $(".arXiv-feed").toggle(300)

  # Moderators: hide from recent comments
  $('.hide-from-recent').click ->
    $comment = $(this).closest('.abbr-comment')
    id = $comment.attr('data-comment-id')
    $.post "/api/hide_from_recent/#{id}", ->
      $comment.fadeOut()

  $('#customDate').click ->
    SciRate.customDateRange (start, end) ->
      [start, end] = [end, start] if (start > end)
      if (!start.isValid() && !end.isValid())
        # No date provided, do nothing
        return
      else if (!start.isValid() || !end.isValid())
        # Only one date provided, treat as single day query
        range = 1
        if start.isValid()
          date = start.format("YYYY-MM-DD")
        else
          date = end.format("YYYY-MM-DD")
      else
        # Here we have a proper date range
        range = end.diff(start, 'days')+1
        date = end.format("YYYY-MM-DD")

      url = window.location.toString().replace(/\?.+/, '')
      url += "?date=#{date}&range=#{range}"
      window.location = url


$(document).on 'ready', ->
  setupFeedPage()

$(document).on 'page:load', ->
  setupFeedPage()
