hasFlash = false
try
  fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash")
  hasFlash = true if fo
catch e
  console.log e
  hasFlash = true if navigator.mimeTypes and navigator.mimeTypes["application/x-shockwave-flash"] != undefined and navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin

setupPaperPage = ->
  return unless $('#paperPage')

  $('.share-button').click (ev) ->
    el = $(ev.target)
    title = encodeURIComponent($(el).data('title') || '')
    img = encodeURIComponent($(el).data("img") || '')
    url = encodeURIComponent($(el).data("url") || '')
    if url.length == 0
      url = encodeURIComponent(location.href)

    if $(el).hasClass('twitter')
      window.open("https://twitter.com/home?status=#{title} #{url}")
    else if $(el).hasClass('facebook')
      window.open("http://www.facebook.com/sharer.php?u=#{url}")
    else if $(el).hasClass('google')
      window.open("https://plus.google.com/share?url=#{url}")


setupBibtex = ->
  return unless $('.bibtex')
  ZeroClipboard.config(moviePath: asset_path("ZeroClipboard.swf"), cacheBust: false)

  $('.bibtex').each ->
    $bibtex = $(this)

    remove = (ev) ->
      if $(ev.target).closest('.bibtex').length
        $(window).one 'click', remove
      else
        $bibtex.find('a').removeClass('btn-success')
        $bibtex.find('.card').addClass('hidden')

    if hasFlash
      $('.bibtex').each ->
        window.clip = new ZeroClipboard($bibtex.find('a').get(0))

        clip.on 'mouseover', ->
          $(this).attr('data-clipboard-text', $bibtex.find('textarea').text())

        clip.on 'complete', (event) ->
          $bibtex.find('.card').removeClass('hidden')
          $bibtex.find('textarea').focus()
          $bibtex.find('textarea').select()
          $(this).addClass("btn-success")
          $bibtex.find('button').addClass("btn-success")
          $bibtex.find('button').text("BibTeX copied to clipboard")
          $(window).one 'click', remove
    else
      $bibtex.find('a').on 'click', ->
        $bibtex.find('a').addClass('btn-success')
        $bibtex.find('.card').removeClass('hidden')
        $bibtex.find('textarea').focus()
        $bibtex.find('textarea').select()
        $bibtex.find('button').remove()
        $(window).one 'click', remove

$(document).on "ready", ->
  console.log 'ready'
  setupBibtex()
  setupPaperPage()

$(document).on "page:load", ->
  $('.bibtex a').removeClass('zeroclipboard-js-hover')
  ZeroClipboard.destroy()
  setupBibtex()
  setupPaperPage()

$(document).on 'page:restore', ->
  $('.bibtex a').removeClass('zeroclipboard-js-hover')
  ZeroClipboard.destroy()
  setupBibtex()
  setupPaperPage()

window.SocialShareButton =
  openUrl : (url) ->
    window.open(url)
    false

