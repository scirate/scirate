# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  # Feed sidebar tree expansion
  $('.feed-folder i').click ->
    $(this).toggleClass('icon-chevron-right')
    $(this).toggleClass('icon-chevron-down')
    $(this).closest('li').children('ul.tree').toggle(300)

  # Show links on hover
  $('.paper').on 'mouseover', (ev) ->
    $(this).find('.links').removeClass('hidden')

  $('.paper').on 'mouseout', (ev) ->
    $(this).find('.links').addClass('hidden')
