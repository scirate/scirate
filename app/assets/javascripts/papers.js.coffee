ZeroClipboard.config(moviePath: "/assets/ZeroClipboard.swf")
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
