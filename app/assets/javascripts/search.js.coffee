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

  compile_query: ->
    query = ""
    $inputs = $(@el).find('td input')
    $inputs.each (i, el) =>
      term = $(el).val()
      name = $(el).attr('name')

      if term.length > 0
        query += name + ':' + term
    $('input#advanced').val(query)
    $('#search-preview').text(query)

  init: ->
    @on 'expand', =>
      @set(expand: true)
      window.location.hash = "#advanced"

    @on 'collapse', =>
      @set(expand: false)
      window.location.hash = ""

    @on 'changed', (ev) =>
      setTimeout => @compile_query()

    
      

)

$ ->
  $('#search_page').each ->
    new View.Search(el: this)

  $('#advanced_search').each ->
    new View.AdvancedSearch(el: this)
