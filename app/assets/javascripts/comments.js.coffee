# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('.upvote').click ->
    $comment = $(this).closest('.comment')
    return if $comment.hasClass('voted')
    $.post "/comments/#{$comment.attr('data-id')}/upvote", ->
      $comment.find('.score').text(parseInt($comment.find('.score').text())+1)


  $('.downvote').click ->
    $comment = $(this).closest('.comment')
    return if $comment.hasClass('voted')
    $.post "/comments/#{$comment.attr('data-id')}/downvote", ->
      $comment.find('.score').text(parseInt($comment.find('.score').text())-1)

