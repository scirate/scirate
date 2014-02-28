class View.Search extends Backbone.View
  initialize: ->
    # Compute preset date ranges
    @ranges = {}
    now = moment()
    @ranges.week = @compileDateRange(now.clone().subtract('weeks', 1), now)
    @ranges.month = @compileDateRange(now.clone().subtract('months', 1), now)
    @ranges.year = @compileDateRange(now.clone().subtract('years', 1), now)
    @ranges.custom = null

    # If this is the result of a previous advanced search
    # then restore the fields from the query string
    if FromServer.advanced? && FromServer.advanced.length > 0
      @toggleAdvanced()
      @readQuery(FromServer.advanced)

    engine = new Bloodhound(
      datumTokenizer: ((d) -> Bloodhound.tokenizers.whitespace(d.uid))
      queryTokenizer: Bloodhound.tokenizers.whitespace
      local: FromServer.feeds.map((f) -> { uid: f })
    )

    engine.initialize()

    $('#category').typeahead({ highlight: true },
      displayKey: 'uid', source: engine.ttAdapter())

    @compileQuery()
    $(window).click => @compileQuery()

  events:
    'click #toggleAdvanced': 'toggleAdvanced'
    'change input': 'compileQuery'
    'keyup input': 'compileQuery'
    'change #date': 'changeDate'
    'change #order': 'compileQuery'
    'click #submitCustomDate': 'changeCustomDate'

  # XXX (Mispy): This is a bit messy and redundant
  # with the server-side code. Perhaps refactor so
  # we can just pass through the results of server-side
  # query parsing.
  psplit: (query) ->
    split = []
    depth = 0
    current = ""

    for ch, i in query
      if i == query.length-1
        split.push current+ch
      else if ch == ' ' && depth == 0
        split.push current
        current = ""
      else
        current += ch

        if ch == '('
          depth += 1
        else if  ch == ')'
          depth -= 1

    split

  readQuery: (query) ->
    authors = []
    title = ""
    abstract = ""
    category = ""
    date = null
    order = null

    for term in @psplit(query)
      [name, content] = term.split(':')
      if content[0] == '(' && content[-1..-1][0] == ')'
        content = content[1..-2]
      console.log @psplit(query)

      switch name
        when 'au' then authors.push content
        when 'ti' then title = content
        when 'abs' then abstract = content
        when 'in' then category = content
        when 'date'
          date = switch content
            when @ranges.week then 'week'
            when @ranges.month then 'month'
            when @ranges.year then 'year'
            else 'custom'
        when 'order'
          order = content

    @$('#authors').val authors.join(', ')
    @$('#title').val title
    @$('#abstract').val abstract
    @$('#category').val category
    @$('#date').val date if date?
    @$('#order').val order if order?

  toggleAdvanced: ->
    console.log @$('#advancedSearch')
    if @$('#advancedSearch').hasClass('hidden')
      @$('#advancedSearch').removeClass('hidden')
      @$('#toggleAdvanced i').removeClass('fa-chevron-right').addClass('fa-chevron-down')
    else
      @$('#advancedSearch').addClass('hidden')
      @$('#toggleAdvanced i').removeClass('fa-chevron-down').addClass('fa-chevron-right')

  changeDate: ->
    if @$('#date').val() == 'custom'
      @$('#datepicker').modal()
    else
      @ranges.custom = null
      @compileQuery()

  changeCustomDate: ->
    start = moment(@$('#dateRangeFrom').val())
    end = moment(@$('#dateRangeTo').val())
    @ranges.custom = @compileDateRange(start, end)

    if @ranges.custom == null
      @$('#date').val('any')

    @$('#datepicker').modal('hide')
    @compileQuery()

  escape: (s) ->
    if s.indexOf(' ') != -1
      s = '(' + s + ')'
    s

  compileDateRange: (start, finish) ->
    if !start.isValid() && !finish.isValid()
      null
    else
      range = ""
      if start.isValid() then range += start.format('YYYY-MM-DD')
      range += '..'
      if finish.isValid() then range += finish.format('YYYY-MM-DD')
      range

  compileQuery: ->
    query = []

    @$('#authors').val().split(/,\s*/).forEach (author) =>
      return if author.length == 0
      query.push("au:#{@escape(author)}")

    title = @$('#title').val()
    query.push("ti:#{@escape(title)}") if title.length > 0

    abstract = @$('#abstract').val()
    query.push("abs:#{@escape(abstract)}") if abstract.length > 0

    category = @$('#category').val()
    query.push("in:#{@escape(category)}") if category.length > 0

    date = @$('#date').val()
    if date != 'any' && @ranges[date]?
      query.push "date:#{@ranges[date]}"

    order = @$('#order').val()
    if order != "scites"
      query.push("order:#{order}")

    query_text = query.join(' ')
    $('input#advanced').val(query_text)
    $('#advancedPreview').text(@$('#q').val() + ' ' + query_text)



$ ->
  $('#searchPage').each ->
    new View.Search(el: this)
