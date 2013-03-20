# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

changeScore = ($comment, shift) ->
  current = parseInt($comment.find('.score').text())
  $comment.find('.score').text(current + shift)

makeCommentEditor = (suffix) ->
  converter = Markdown.getSanitizingConverter()
  editor = new Markdown.Editor(converter, suffix)

  # Apply MathJax rendering to standard pagedown preview box
  editor.hooks.chain 'onPreviewRefresh', ->
    delay 400, 'mathjax', ->
      MathJax.Hub.Typeset($('#wmd-preview' + (suffix||''))[0])

  editor.run()

setupVoting = ->
  $('.upvote').click ->
    $button = $(this)
    $comment = $button.closest('.comment')
    cid = $comment.attr('data-id')

    if $button.hasClass('active')
      # Undo upvote
      $.post "/comments/#{cid}/unvote", ->
        $button.removeClass('active')
        changeScore($comment, -1)
    else
      # Either new upvote or switch from downvote
      $.post "/comments/#{cid}/upvote", ->
        $button.addClass('active')
        if $comment.find('.downvote').hasClass('active')
          $comment.find('.downvote').removeClass('active')
          changeScore($comment, +2)
        else
          changeScore($comment, +1)

  $('.downvote').click ->
    $button = $(this)
    $comment = $button.closest('.comment')
    cid = $comment.attr('data-id')

    if $button.hasClass('active')
      # Undo downvote
      $.post "/comments/#{cid}/unvote", ->
        $button.removeClass('active')
        changeScore($comment, +1)
    else
      # Either new downvote or switch from upvote
      $.post "/comments/#{cid}/downvote", ->
        $button.addClass('active')
        if $comment.find('.upvote').hasClass('active')
          $comment.find('.upvote').removeClass('active')
          changeScore($comment, -2)
        else
          changeScore($comment, -1)


$ ->
  converter = Markdown.getSanitizingConverter()
  renderComment = ($comment) ->
    $comment.find('.body').html converter.makeHtml($comment.attr('data-markup'))
    MathJax.Hub.Typeset($comment[0])

  $('.comment').each -> renderComment($(this))

  setupVoting()
  makeCommentEditor()

  

  editor_html = $('#comment_editor').removeClass('hidden').remove()[0].outerHTML
  $('.actions .edit').click ->
    $comment = $(this).closest('.comment')
    if $comment.find('#comment_editor').length
      # Toggle editing off if we're already editing this comment
      $('#comment_editor').remove()
      renderComment($comment)
    else
      # Make a new editor for this comment
      content = $comment.attr('data-markup')

      $comment.find('.body').html(editor_html)
      $comment.find('textarea').val(content)

      editor2 = makeCommentEditor('-second')

      $comment.find('.save').click ->
        content = $comment.find('textarea').val()
        $.post "/comments/#{$comment.attr('data-id')}/edit", { content: content }, ->
          $comment.attr('data-markup', content)
          renderComment($comment)
