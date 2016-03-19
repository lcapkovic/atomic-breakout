AtomicBreakoutView = require './atomic-breakout-view'
{CompositeDisposable} = require 'atom'

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

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomicBreakoutView.destroy()

  serialize: ->
    atomicBreakoutViewState: @atomicBreakoutView.serialize()

  convert: ->
    console.log 'AtomicBreakout was toggled!'
    if editor = atom.workspace.getActiveTextEditor()
      editor.insertText('Hello, World!')

    # if @modalPanel.isVisible()
    #   @modalPanel.hide()
    # else
    #   @modalPanel.show()
