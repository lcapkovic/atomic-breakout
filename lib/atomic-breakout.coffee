AtomicBreakoutView = require './atomic-breakout-view'
{CompositeDisposable} = require 'atom'

gameloop = (editor) ->
  editor.insertText("TEST123")
  # if @modalPanel.isVisible()
  #   @modalPanel.hide()
  # else
  #   @modalPanel.show()

module.exports = AtomicBreakout =
  atomicBreakoutView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomicBreakoutView = new AtomicBreakoutView(state.atomicBreakoutViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomicBreakoutView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atomic-breakout:convert': => @convert()

  serialize: ->
    atomicBreakoutViewState: @atomicBreakoutView.serialize()

  convert: ->
    if editor = atom.workspace.getActiveTextEditor()
      selection = editor.getSelectedText()
      atom.workspace.open().then (editor) ->
        editorView = atom.views.getView(editor)
        gameloop(editor)

        # editor.insertText(selection)
        #
        # console.log(editor.getLastScreenRow())
        # console.log(editor.getLastScreenRow())
