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
      @reply_html = $('#comment_reply').removeClass('hidden').remove()[0].outerHTML

    # Render markup and setup interface for individual comments
    $('.comment').each -> new Comment($(this))

  @bindEditor: (suffix) ->
    suffix ?= ''
    # Binds pagedown editor functionality to #wmd-panel#{suffix}
    editor = new Markdown.Editor(@converter, suffix)

    # Apply MathJax rendering to standard pagedown preview box
    editor.hooks.chain 'onPreviewRefresh', ->
      if $("#wmd-preview#{suffix}").text().empty()
        $("#wmd-preview#{suffix}").addClass('hidden')
      else
        $("#wmd-preview#{suffix}").removeClass('hidden')
      MathJax.Hub.Typeset($("#wmd-preview#{suffix}")[0])

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
    if @votestate == 'upvote'
      @$el.find('.upvote').removeClass('active')
      @changeScore(-1)
    else if @votestate == 'downvote'
      @$el.find('.downvote').removeClass('active')
      @changeScore(+1)
    @votestate = null
    $.post "/comments/#{@cid}/unvote"

  report: ->
    @$el.find('.report')
        .removeClass('report')
        .addClass('unreport')
        .text('reported (undo)')
    $.post "/comments/#{@cid}/report"

  unreport: ->
    @$el.find('.unreport')
        .removeClass('unreport')
        .addClass('report')
        .text('report')
    $.post "/comments/#{@cid}/unreport"

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
    @editing = true
    @stopReply() if @replying

    # Make a new editor for this comment
    content = @$el.attr('data-markup')

    @$el.find('.body').html(Comment.editor_html)
    @$el.find('textarea').val(content)

    Comment.bindEditor('-edit')
    @$el.find('.wmd-input').focus()

    @$el.find('.save').click =>
      content = @$el.find('textarea').val()
      $.post "/comments/#{@$el.attr('data-id')}/edit", { content: content }, =>
        @$el.attr('data-markup', content)
        @renderMarkup()
      return false

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
    @replying = true
    @stopEditing() if @editing

    @$el.append(Comment.reply_html)
    Comment.bindEditor('-reply')
    @$el.find('form').attr('action', "/comments/#{@$el.attr('data-id')}/reply")
    @$el.find('.wmd-input').focus()

  stopReply: ->
    @$el.find('#comment_reply').remove()
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
    MathJax.Hub.Typeset(@$el.find('.body')[0])

  constructor: (@$el) ->
    @cid = @$el.attr('data-id')
    @renderMarkup()
    @setupVoting()
    @setupActions()

$ ->
  $('a.has-tooltip').tooltip()
  return unless ($('.comments').length || $('.comment').length)
  Comment.setupComments()

