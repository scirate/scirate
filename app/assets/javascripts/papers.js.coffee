# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('label.tree-toggler').click ->
    $(this).parent().children('ul.tree').toggle(300)

  $('li.paper').on 'click', '.scite', (ev) ->
    $toggle = $(ev.target).closest('.scite-toggle')
    console.log($toggle.attr('data-paper-id'))
    $.post '/scite', { paper_id: $toggle.attr('data-paper-id') }, (resp) =>
      $toggle.replaceWith(resp)
    return false

  $('li.paper').on 'click', '.unscite', (ev) ->
    $toggle = $(ev.target).closest('.scite-toggle')
    $.post '/unscite', { paper_id: $toggle.attr('data-paper-id') }, (resp) =>
      $toggle.replaceWith(resp)
    return false
