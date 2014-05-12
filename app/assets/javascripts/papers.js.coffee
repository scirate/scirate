hasFlash = false
try
  fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash")
  hasFlash = true if fo
catch e
  hasFlash = true if navigator.mimeTypes and navigator.mimeTypes["application/x-shockwave-flash"] != undefined and navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin

if hasFlash
  ZeroClipboard.config(moviePath: asset_path("ZeroClipboard.swf"))
  clip = new ZeroClipboard($('#copyButton').get(0))

  clip.on 'mouseover', ->
    $(this).attr('data-clipboard-text', $('.reference textarea').text())

  clip.on 'complete', (event) ->
    $(".reference textarea").focus()
    $(".reference textarea").select()
    $(this).addClass("btn-success")
    $(this).text("Copied to clipboard")

  clip.on 'mouseout', ->
    $(this).removeClass("btn-success")
    $(this).text("Copy Reference")
else
  $('#copyButton').on 'click', ->
    $(".reference textarea").focus()
    $(".reference textarea").select()
