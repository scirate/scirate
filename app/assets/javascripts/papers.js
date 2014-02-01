$(function() {
  // Expand author lists with >20 authors
  $('li.paper .expand-authors').click(function() {
    $paper = $(this).closest('li.paper');

    $paper.find('.more-authors').toggleClass('hidden');
    $paper.find('.expand-authors').remove();
  })

  // Feed sidebar tree expansion
  $('.feed-folder i').click(function() {
    $(this).toggleClass('icon-chevron-right');
    $(this).toggleClass('icon-chevron-down');
    $(this).closest('li').children('ul.tree').toggle(300);
  })
});
