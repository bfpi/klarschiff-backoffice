$.fn.imageUploadResizer = (options) ->
  settings = $.extend({
    max_width: 1000
    max_height: 1000
    quality: 1
    do_not_resize: []
  }, options)
  @filter('input[type="file"]').each ->

    @onchange = ->
      that = this
      # input node
      originalFile = @files[0]
      if !originalFile or !originalFile.type.startsWith('image')
        return
      # Don't resize if doNotResize is set
      if settings.do_not_resize.includes('*') or settings.do_not_resize.includes(originalFile.type.split('/')[1])
        return
      reader = new FileReader

      reader.onload = (e) ->
        img = document.createElement('img')
        canvas = document.createElement('canvas')
        img.src = e.target.result

        img.onload = ->
          `var ctx`
          ctx = canvas.getContext('2d')
          ctx.drawImage img, 0, 0
          if img.width < settings.max_width and img.height < settings.max_height
            # Resize not required
            return
          ratio = Math.min(settings.max_width / img.width, settings.max_height / img.height)
          width = Math.round(img.width * ratio)
          height = Math.round(img.height * ratio)
          canvas.width = width
          canvas.height = height
          ctx = canvas.getContext('2d')
          ctx.drawImage img, 0, 0, width, height
          canvas.toBlob ((blob) ->
            resizedFile = new File([ blob ], 'resized_' + originalFile.name, originalFile)
            dataTransfer = new DataTransfer
            dataTransfer.items.add resizedFile
            # temporary remove event listener, change and restore
            currentOnChange = that.onchange
            that.onchange = null
            that.files = dataTransfer.files
            that.onchange = currentOnChange
            return
          ), 'image/jpeg', settings.quality

      reader.readAsDataURL originalFile
