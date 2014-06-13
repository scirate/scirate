hasFlash = false
try
  fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash")
  hasFlash = true if fo
catch e
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

  if hasFlash
    ZeroClipboard.config(moviePath: asset_path("ZeroClipboard.swf"), cacheBust: false)
    window.clip = new ZeroClipboard($('#copyButton').get(0))

    clip.on 'mouseover', ->
      $(this).attr('data-clipboard-text', $('.reference textarea').text())

    clip.on 'complete', (event) ->
      $(".reference textarea").focus()
      $(".reference textarea").select()
      $(this).addClass("btn-success")
      $(this).text("Copied to clipboard")

    clip.on 'mouseover', ->
      $(this).removeClass("btn-success")
      $(this).text("Copy Citation")
  else
    $('#copyButton').on 'click', ->
      $(".reference textarea").focus()
      $(".reference textarea").select()

$(document).on "ready", setupPaperPage
$(document).on "page:load", ->
  $('#copyButton').removeClass('zeroclipboard-js-hover')
  ZeroClipboard.destroy()
  setupPaperPage()

window.SocialShareButton =
  openUrl : (url) ->
    window.open(url)
    false

