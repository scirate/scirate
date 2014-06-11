$ ->
  # Expand author lists with >20 authors
  $('li.paper .expand-authors').click ->
    $paper = $(this).closest('li.paper')

    $paper.find('.more-authors').toggleClass('hidden')
    $paper.find('.expand-authors').remove()

  # Feed sidebar tree expansion
  $('.feed-folder i').click ->
    $(this).toggleClass('fa-chevron-right')
    $(this).toggleClass('fa-chevron-down')
    $(this).closest('li').children('ul.tree').toggle(300)

  # Moderators: hide from recent comments
  $('.hide-from-recent').click ->
    $comment = $(this).closest('.abbr-comment')
    id = $comment.attr('data-comment-id')
    $.post "/api/hide_from_recent/#{id}", ->
      $comment.fadeOut()

