AtomicBreakoutView = require './atomic-breakout-view'
{CompositeDisposable} = require 'atom'

globalEditor = null
goingLeft = false
goingRight = false

paddleStart = 30
paddle = " ########## "

BOTTOM = 30

drawPaddle = () ->
  paddleLength = paddle.length
  globalEditor.setTextInBufferRange([[BOTTOM,paddleStart],[BOTTOM,paddleStart+paddleLength]],paddle)


setupGameLoop = (gameLoop) ->
  animationFrame = window.requestAnimationFrame

  if animationFrame != null
    recursiveAnimation = () ->
      gameLoop()
      animationFrame(recursiveAnimation)
    animationFrame(recursiveAnimation)

  if animationFrame is null
    every = (ms, cb) -> setInterval cb, ms
    every 1000/60, () ->
      gameLoop()

gameloop = (editor) ->
  if goingLeft && paddleStart > 0
    paddleStart--
  if goingRight && paddleStart < 70
    paddleStart++
  drawPaddle()


gameInit = (editor) ->
  globalEditor.insertText('                           \n') for i in [0..40]
  setupGameLoop(gameloop)

onLeftDown = (event) ->
  if !goingLeft
    goingLeft = true
    console.log('GOING LEFT')

onRightDown = (event) ->
  if !goingRight
    goingRight = true
    console.log('GOING RIGHT')

onLeftUp = (event) ->
  goingLeft = false

onRightUp = (event) ->
  goingRight = false

  # if @modalPanel.isVisible()
  #   @modalPanel.hide()
  # else
  #   @modalPanel.show()

# Global variables needed:
# currentX, currentX
# vectorX, vectorY
# bottom, right
# paddleY, length

# The floor function has to be done at the drawing stage

moveBall = ->

  paddleLeft = paddleY - length / 2
  paddleRight = paddleY + length / 2

  # Calculate column coordinate: (version without letters)
  newY = currentY + vectorY
  vectorY = switch
    when newY > right then -vectorY
    when newY < 0 then -vectorY
    else vectorY
  currentY = currentY + vectorY

  # Calculate row coordinate: (version without paddle angle and letters)
  newX = currentX + vectorX
    if ((newX > bottom and newY > paddleLeft and newY < paddleRight) or (newX < bottom))
      vectorX = switch
        when newX > bottom then -vectorX
        when newY < 0 then -vectorX
        else vectorX
    else
      vectorX = vectorX
    currentX = currentX + vectorX

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

      atom.commands.add 'a',
        'user:moveLeft': (event) ->
          console.log("test")

      atom.workspace.open().then (editor) ->
        globalEditor = editor
        editor.insertText(selection)
        editorView = atom.views.getView(editor)

        editorView.addEventListener 'keydown', handler = (event) ->
          onLeftDown() if event.which is 37
          onRightDown() if event.which is 39

        editorView.addEventListener 'keyup', handler = (event) ->
          onLeftUp() if event.which is 37
          onRightUp() if event.which is 39

        gameInit(editor)

        gameloop(editor)

        # editor.insertText(selection)
        #
        # console.log(editor.getLastScreenRow())
        # console.log(editor.getLastScreenRow())
