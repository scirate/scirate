# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('.feed-folder i').click ->
    $(this).toggleClass('icon-chevron-right')
    $(this).toggleClass('icon-chevron-down')
    $(this).closest('li').children('ul.tree').toggle(300)

  $('.paper').on 'click', '.scite', (ev) ->
    return Scirate.login() unless Scirate.current_user
    $toggle = $(ev.target).closest('.scite-toggle')
    console.log($toggle.attr('data-paper-id'))
    $.post '/scite', { paper_id: $toggle.attr('data-paper-id') }, (resp) =>
      $toggle.closest('li.paper').find('.abstract').removeClass('hidden')
      $toggle.replaceWith(resp)
    return false

  $('.paper').on 'click', '.unscite', (ev) ->
    return Scirate.login() unless Scirate.current_user
    $toggle = $(ev.target).closest('.scite-toggle')
    $.post '/unscite', { paper_id: $toggle.attr('data-paper-id') }, (resp) =>
      $toggle.closest('li.paper').find('.abstract').addClass('hidden')
      $toggle.replaceWith(resp)
    return false
