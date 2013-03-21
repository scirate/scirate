# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Comment
  @setupComments: ->
    @converter = Markdown.getSanitizingConverter()
    if $('#comment_form').length
      @bindEditor() # Setup the main commenting form
      # Grab the inline editor html
      @editor_html = $('#comment_editor').removeClass('hidden').remove()[0].outerHTML

    # Render markup and setup interface for individual comments
    $('.comment').each -> new Comment($(this))

  @bindEditor: (suffix) ->
    # Binds pagedown editor functionality to #wmd-panel#{suffix}
    editor = new Markdown.Editor(@converter, suffix)

    # Apply MathJax rendering to standard pagedown preview box
    editor.hooks.chain 'onPreviewRefresh', ->
      MathJax.Hub.Typeset($('#wmd-preview' + (suffix||''))[0])

    editor.run()

  changeScore: (shift) ->
    """Modifies the displayed comment vote score by shift."""
    current = parseInt(@$el.find('.score').text())
    @$el.find('.score').text(current + shift)

  upvote: ->
    """Upvote the comment."""
    $.post "/comments/#{@cid}/upvote", =>
      @$el.find('.upvote').addClass('active')
      if @votestate == 'downvote'
        @$el.find('.downvote').removeClass('active')
        @changeScore(+2)
      else
        @changeScore(+1)
      @votestate = 'upvote'

  downvote: ->
    """Downvote the comment."""
    $.post "/comments/#{@cid}/downvote", =>
      @$el.find('.downvote').addClass('active')
      if @votestate == 'upvote'
        @$el.find('.upvote').removeClass('active')
        @changeScore(-2)
      else
        @changeScore(-1)
      @votestate = 'downvote'
  
  unvote: ->
    """Undo an existing downvote or upvote."""
    $.post "/comments/#{@cid}/unvote", =>
      @$el.find('.upvote, .downvote').removeClass('active')
      @changeScore(-1)

  setupVoting: ->
    # Read the DOM to find out if we've already voted
    if @$el.find('.upvote').hasClass('active')
      @votestate = 'upvote'
    else if @$el.find('.downvote').hasClass('active')
      @votestate = 'downvote'
    else
      @votestate = null

    @$el.on 'click', '.upvote', =>
      return Scirate.login() unless Scirate.current_user
      if @votestate == 'upvote' then @unvote() # Undo upvote
      else @upvote()

    @$el.on 'click', '.downvote', =>
      return Scirate.login() unless Scirate.current_user
      if @votestate == 'downvote' then @unvote()
      else @downvote()

  startEditing: ->
    # Make a new editor for this comment
    content = @$el.attr('data-markup')

    @$el.find('.body').html(Comment.editor_html)
    @$el.find('textarea').val(content)

    Comment.bindEditor('-second')

    @$el.find('.save').click =>
      content = @$el.find('textarea').val()
      $.post "/comments/#{@$el.attr('data-id')}/edit", { content: content }, =>
        @$el.attr('data-markup', content)
        @renderMarkup()

  stopEditing: ->
    $('#comment_editor').remove()
    @renderMarkup()

  toggleEditing: ->
    if @$el.find('#comment_editor').length
      @stopEditing()
    else
      @startEditing()

  setupEditing: ->
    @$el.find('.actions .edit').click => @toggleEditing()

  renderMarkup: ->
    """Processes markdown and LaTeX in the data-markup attribute for display."""
    @$el.find('.body').html Comment.converter.makeHtml(@$el.attr('data-markup'))
    MathJax.Hub.Typeset(@$el[0])

  constructor: (@$el) ->
    @cid = @$el.attr('data-id')
    @renderMarkup()
    @setupVoting()
    @setupEditing()


$ ->
  $('a.has-tooltip').tooltip()
  return unless $('.comment').length
  Comment.setupComments()

