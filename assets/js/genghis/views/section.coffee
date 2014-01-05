define (require) ->
  $    = require('jquery')
  _    = require('underscore')
  View = require('genghis/views/view')

  require 'jquery.tablesorter'
  require 'tablesorter-size-parser'

  class Section extends View
    ui:
      '$title':         '> header h2'
      '$table':         'table'
      '$tbody':         'table tbody'
      '$addForm':       '.add-form'
      '$addInput':      '.add-form input'
      '$addFormToggle': '.add-form-toggle'

    events:
      'click .add-form-toggle button': 'showAddForm'
      'click .add-form button.add':    'submitAddForm'
      'click .add-form button.cancel': 'closeAddForm'
      'keyup .add-form input.name':    'updateOnKeyup'

    keyboardEvents:
      'c': 'showAddForm'

    modelEvents:
      'change': 'updateTitle'

    collectionEvents:
      'reset':   'render'
      'add':     'addModelAndUpdate'
      'request': 'startSpinning'
      'sync':    'stopSpinning'
      'destroy': 'stopSpinning'

    initialize: ->
      @render()

    serialize: ->
      title: @formatTitle(@model)

    afterRender: ->
      @addAll()

      # Sort this bad boy.
      @$table.tablesorter textExtraction: (el) ->
        $('.value', el).text() or $(el).text()

      if @collection.size()
        @$table.trigger 'sorton', [[[0, 0]]]

    updateTitle: =>
      @$title.text @formatTitle(@model)

    showAddForm: (e) =>
      e?.preventDefault?()
      @$addFormToggle.hide()
      @$addForm.show()
      @$addInput.select().focus()

    submitAddForm: =>
      {alerts} = @app
      @collection.create(
        {name: @$addInput.val()}
        wait: true
        success: @closeAddForm
        error: (model, response) -> alerts.handleError response
      )

    closeAddForm: =>
      @$addFormToggle.show()
      @$addForm.hide()
      @$addInput.val('')

    updateOnKeyup: (e) =>
      switch e.keyCode
        when 13 then @submitAddForm() # enter
        when 27 then @closeAddForm()  # escape

    addModel: (model) =>
      @$tbody.append (new @rowView(model: model)).render().el

    addModelAndUpdate: (model) =>
      @addModel model
      @$table.trigger 'update'

    addAll: =>
      @$tbody.empty()
      @collection.each @addModel

    show: =>
      @bindKeyboardEvents()
      $('body').addClass "section-#{@$el.attr('id')}"
      @$el.show()
      $(document).scrollTop 0

    hide: =>
      @unbindKeyboardEvents()
      $('body').removeClass "section-#{@$el.attr('id')}"
      @$el.hide()

    startSpinning: =>
      @$el.addClass 'spinning'

    stopSpinning: =>
      @$el.removeClass 'spinning'