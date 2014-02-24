class View.Search extends Backbone.View
  initialize: ->
    @updateFolder()

  events:
    'change #folder': "updateFolder"

  updateFolder: ->
    @$('.feed').addClass('hidden').attr('disabled', true)
    $sel = @$('#feed_' + @$('#folder').val())
    $sel.removeClass('hidden').attr('disabled', false)

View.AdvancedSearch = Ractive.extend(
  template: RactiveTemplates['advanced_search']

  data:
    query: ''
    expand: window.location.hash == "#advanced"

  escape: (s) ->
    if s.indexOf(' ') != -1
      s = '(' + s + ')'
    s

  compile_query: ->
    query = []

    @$el.find('#authors').val().split(/,\s*/).forEach (author) =>
      return if author.length == 0
      query.push("au:#{@escape(author)}")

    title = @$el.find('#title').val()
    query.push("ti:#{@escape(title)}") if title.length > 0

    abstract = @$el.find('#abstract').val()
    query.push("abs:#{@escape(abstract)}") if abstract.length > 0

    order = @$el.find('#order').val()
    if order != "scites"
      query.push("order:#{order}")


    query_text = query.join(' & ')
    $('input#advanced').val(query_text)
    $('#search-preview').text(query_text)

  init: ->
    @$el = $(@el)

    @on 'expand', =>
      @set(expand: true)
      window.location.hash = "#advanced"

    @on 'collapse', =>
      @set(expand: false)
      window.location.hash = ""

    @on 'changed', (ev) =>
      setTimeout (=> @compile_query()), 100

    
      

)

$ ->
  $('#search_page').each ->
    new View.Search(el: this)

  $('#advanced_search').each ->
    new View.AdvancedSearch(el: this)
