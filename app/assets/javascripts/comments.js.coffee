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
      if $('#wmd-preview').text().empty()
        $('#wmd-preview').addClass('hidden')
      else
        $('#wmd-preview').removeClass('hidden')
      MathJax.Hub.Typeset($('#wmd-preview' + (suffix||''))[0])

    editor.run()

  changeScore: (shift) ->
    """Modifies the displayed comment vote score by shift."""
    current = parseInt(@$el.find('.score').text())
    @$el.find('.score').text(current + shift)

  upvote: ->
    """Upvote the comment."""
    @$el.find('.upvote').addClass('active')
    if @votestate == 'downvote'
      @$el.find('.downvote').removeClass('active')
      @changeScore(+2)
    else
      @changeScore(+1)
    @votestate = 'upvote'

    $.post "/comments/#{@cid}/upvote"

  downvote: ->
    """Downvote the comment."""
    @$el.find('.downvote').addClass('active')
    if @votestate == 'upvote'
      @$el.find('.upvote').removeClass('active')
      @changeScore(-2)
    else
      @changeScore(-1)
    @votestate = 'downvote'

    $.post "/comments/#{@cid}/downvote"
  
  unvote: ->
    """Undo an existing downvote or upvote."""
    $.post "/comments/#{@cid}/unvote", =>
      if @votestate == 'upvote'
        @$el.find('.upvote').removeClass('active')
        @changeScore(-1)
      else if @votestate == 'downvote'
        @$el.find('.downvote').removeClass('active')
        @changeScore(+1)
      @votestate = null

  report: ->
    $.post "/comments/#{@cid}/report", =>
      @$el.find('.report')
          .removeClass('report')
          .addClass('unreport')
          .text('reported (undo)')

  unreport: ->
    $.post "/comments/#{@cid}/unreport", =>
      @$el.find('.unreport')
          .removeClass('unreport')
          .addClass('report')
          .text('report')

  setupVoting: ->
    # Read the DOM to find out if we've already voted
    if @$el.find('.upvote').hasClass('active')
      @votestate = 'upvote'
    else if @$el.find('.downvote').hasClass('active')
      @votestate = 'downvote'
    else
      @votestate = null

    @$el.on 'click', '.upvote', =>
      return SciRate.login() unless SciRate.current_user
      if @votestate == 'upvote' then @unvote() # Undo upvote
      else @upvote()

    @$el.on 'click', '.downvote', =>
      return SciRate.login() unless SciRate.current_user
      if @votestate == 'downvote' then @unvote()
      else @downvote()

  startEditing: ->
    @stopReply() if @replying

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
      return false

    @editing = true

  stopEditing: ->
    $('#comment_editor').remove()
    @renderMarkup()
    @editing = false

  toggleEditing: ->
    if @editing
      @stopEditing()
    else
      @startEditing()

  startReply: ->
    @stopEditing() if @editing

    @$el.append(Comment.editor_html)
    Comment.bindEditor('-second')
    @$el.find('form').attr('action', "/comments/#{@$el.attr('data-id')}/reply")
    @replying = true

  stopReply: ->
    @$el.find('#comment_editor').remove()
    @replying = false

  toggleReply: ->
    if @replying
      @stopReply()
    else
      @startReply()

  setupActions: ->
    @$el.on 'click', '.actions .edit', => @toggleEditing()
    @$el.on 'click', '.actions .report', => @report()
    @$el.on 'click', '.actions .unreport', => @unreport()
    @$el.on 'click', '.actions .reply', => @toggleReply()

  renderMarkup: ->
    """Processes markdown and LaTeX in the data-markup attribute for display."""
    @$el.find('.body').html Comment.converter.makeHtml(@$el.attr('data-markup'))
    MathJax.Hub.Typeset(@$el[0])

  constructor: (@$el) ->
    @cid = @$el.attr('data-id')
    @renderMarkup()
    @setupVoting()
    @setupActions()

$ ->
  $('a.has-tooltip').tooltip()
  return unless ($('.comments').length || $('.comment').length)
  Comment.setupComments()

