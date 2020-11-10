
KS.photoCurrStackItem
KS.photoIndex = 0
KS.photoIsMouseDown = false
KS.photoUndoStack = []
KS.photoX1
KS.photoXMove
KS.photoY1
KS.photoYMove

KS.photoUndoStackItem = (top, left, height, width, obj) ->
  @rect = new KS.photoRectangle(top, left, height, width)
  @domObj = obj
  return

KS.photoRectangle = (top, left, height, width) ->
  @top = top
  @left = left
  @height = height
  @width = width
  return

KS.resetPhotoVariables = ->
  KS.photoUndoStack = []
  KS.photoCurrStackItem = null

KS.initializePhotoActions = ->
  $('table#photos tr a.rotate').click (event) ->
    event.preventDefault()
    return if (row = $(event.target).parents('tr')).length == 0
    row.find('input.modification').val('rotate')
    Rails.fire(row.parents('form')[0], 'submit')

  $('table#photos tr a.edit').click (event) ->
    event.preventDefault()
    $(event.target).parents('table').find('tr.active a.stop-edit').click()
    KS.resetPhotoVariables()
    return if (row = $(event.target).parents('tr')).length == 0
    row.addClass('active')
    row.find('a.edit').hide();
    row.find('a.stop-edit').show();
    row.find('a.stop-edit ~ a').show(300);

  $('table#photos tr a.stop-edit').click (event) ->
    event.preventDefault()
    return if (row = $(event.target).parents('tr')).length == 0
    row.removeClass('active')
    row.find('a.edit').show();
    row.find('a.stop-edit').hide();
    row.find('a.stop-edit ~ a').hide(300);

    row.find('div.record').children().remove()
    KS.resetPhotoVariables()

  $('table#photos tr a.undo').click (event) ->
    event.preventDefault()
    return if (row = $(event.target).parents('tr')).length == 0
    if KS.photoCurrStackItem.length != 0
      KS.photoCurrStackItem.domObj.hide()
      index = KS.photoUndoStack.indexOf(KS.photoCurrStackItem) - 1
      if index >= 0
        KS.photoCurrStackItem = KS.photoUndoStack[index]
      else
        KS.photoCurrStackItem = []

  $('table#photos tr a.save').click (event) ->
    event.preventDefault()
    return if (row = $(event.target).parents('tr')).length == 0

    picture = row.find('img')
    t = picture[0].y
    l = picture[0].x
    w = picture.width()
    h = picture.height()
    rectCoords = ''
    i = 0
    while i < KS.photoUndoStack.length
      rect = KS.photoUndoStack[i].rect
      rectCoords += (rect.left - l) + ',' + (rect.top - t) + ',' + (rect.width + 2) + ',' + (rect.height + 2) + ';'
      #+2 to compensate border
      if KS.photoUndoStack[i] == KS.photoCurrStackItem
        break
      i++
    row.find('.censor_rectangles').val(rectCoords)
    row.find('.censor_width').val(w)
    row.find('.censor_height').val(h)

    row.find('input.modification').val('censor')
    KS.resetPhotoVariables()
    Rails.fire(row.parents('form')[0], 'submit')

  $('table#photos tr a.redo').click (event) ->
    event.preventDefault()
    return if (row = $(event.target).parents('tr')).length == 0
    if KS.photoUndoStack.length == 0
      return
    if KS.photoCurrStackItem == null or KS.photoCurrStackItem.length == 0
      KS.photoCurrStackItem = KS.photoUndoStack[0]
    else if KS.photoCurrStackItem != KS.photoUndoStack[KS.photoUndoStack.length - 1]
      index = KS.photoUndoStack.indexOf(KS.photoCurrStackItem) + 1
      KS.photoCurrStackItem = KS.photoUndoStack[index]
    KS.photoCurrStackItem.domObj.fadeIn 'slow'

  $('table#photos tr a.delete').on 'click', (event) ->
    event.preventDefault()
    return if (row = $(event.target).parents('tr')).length == 0
    row.find('input.delete').val(true)
    row.hide()

  $('table#photos tr img').mousedown (event) ->
    return if (row = $(event.target).parents('tr.active')).length == 0
    KS.photoIsMouseDown = true
    event.preventDefault()
    KS.photoIndex++
    if KS.photoUndoStack.length > 0
      targetLength = undefined
      if KS.photoCurrStackItem != KS.photoUndoStack[KS.photoUndoStack.length - 1]
        if KS.photoCurrStackItem.length == 0
          targetLength = 0
        else
          targetLength = KS.photoUndoStack.indexOf(KS.photoCurrStackItem) + 1
        while KS.photoUndoStack.length > targetLength
          KS.photoUndoStack.pop()
    # adding new censoring box
    box = $('<div style="background: black; border:1px #DDDDDD solid; position:absolute; margin:0"></div>').hide()
    row.find('div.record').append box
    modal = $(event.target).parents('.modal-body')
    KS.photoX1 = event.pageX - modal.offset().left
    KS.photoY1 = event.pageY - modal.offset().top
    # save reference to the new box
    KS.photoCurrStackItem = new KS.photoUndoStackItem(KS.photoX1, KS.photoX1, 1, 1, box)
    KS.photoUndoStack.push KS.photoCurrStackItem

  # Adjust size of the censoring box while dragging the mouse
  $('table#photos tr img').mousemove (event) ->
    return if (row = $(event.target).parents('tr.active')).length == 0
    if KS.photoIsMouseDown and KS.photoCurrStackItem != null and KS.photoCurrStackItem.length != 0
      t = undefined
      l = undefined
      w = undefined
      h = undefined
      modal = $(event.target).parents('.modal-body')
      KS.photoXMove = event.pageX - modal.offset().left
      KS.photoYMove = event.pageY - modal.offset().top
      w = Math.abs(KS.photoXMove - KS.photoX1)
      h = Math.abs(KS.photoYMove - KS.photoY1)
      if KS.photoXMove >= KS.photoX1
        l = KS.photoX1
      else
        l = KS.photoXMove
      if KS.photoYMove >= KS.photoY1
        t = KS.photoY1
      else
        t = KS.photoYMove
      KS.photoCurrStackItem.domObj.css(
        top: t
        left: l
        height: h
        width: w).fadeIn 'slow'
      KS.photoCurrStackItem.rect = new KS.photoRectangle(t, l, h, w)

  # Stop size adjustment on mouseup event
  $(document).mouseup (e) ->
    return if (row = $(event.target).parents('tr')).length == 0
    KS.photoIsMouseDown = false
    $('#current').attr id: 'rect' + KS.photoIndex
