AtomicBreakoutView = require './atomic-breakout-view'
{CompositeDisposable} = require 'atom'

globalEditor = null
goingLeft = false
goingRight = false

paddleStart = 30
paddle = " ########## "

currentX = 20
currentY = 15
previousX = 0
previousY = 0
vectorX = 0.3
vectorY = 0.2

BOTTOM = 30
RIGHT = 80

fpscounter = 0
selection = ""

isCollision = ->
  y = Math.round(currentY)
  x = Math.round(currentX)
  console.log("I AM COMPLETE")
  collision = false
  a = globalEditor.getTextInBufferRange([[x,y], [x,y+1]]) # left
  if a != " "
    collision = true
  collision

savePreviousPosition = () ->
  previousX = Math.round(currentX)
  previousY = Math.round(currentY)

drawPaddle = () ->
  paddleLength = paddle.length
  globalEditor.setTextInBufferRange([[BOTTOM,paddleStart],[BOTTOM,paddleStart+paddleLength]],paddle)

removeBall = () ->
  x = Math.round(currentX)
  y = Math.round(currentY)

  globalEditor.setTextInBufferRange([[x,y],[x,y+1]], ' ')

drawBall = () ->
  x = Math.round(currentX)
  y = Math.round(currentY)

  globalEditor.setTextInBufferRange([[x,y],[x,y+1]], 'O')

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

gameloop = ->
  if goingLeft && paddleStart > 0
    paddleStart--
  if goingRight && paddleStart < 70
    paddleStart++
  drawPaddle()
  removeBall()
  savePreviousPosition()
  moveBall()
  console.log(isCollision())
  drawBall()


gameInit = (selection) ->
  space = ""
  space += ' ' for i in [0..80]

  as = ""
  as += 'a' for i in [0..80]

  lines = selection.split('\n')
  globalEditor.insertText(space + '\n') for i in [0..7]
  globalEditor.insertText(as + '\n')
  globalEditor.insertText(space + '\n') for i in [0..(BOTTOM - getStringLines(selection)+1)]
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

getStringLines = (str) ->
  counter = 1
  for c in str
    if c == '\n'
      counter++
  counter

  # if @modalPanel.isVisible()
  #   @modalPanel.hide()
  # else
  #   @modalPanel.show()


moveBall = ->

  paddleLength = paddle.length-2

  if isCollision()
    X = Math.round(currentX)
    Y = Math.round(currentY)
    console.log(previousX.toString() + " " + X.toString())
    if previousY != Y
      vectorY = -vectorY
    if previousX != X
      vectorX = -vectorX

  # Calculate column coordinate: (version without letters)
  newY = currentY + vectorY
  vectorY = switch
    when newY > RIGHT then -vectorY
    when newY < 0 then -vectorY
    else vectorY
  currentY = currentY + vectorY

  # Calculate row coordinate: (version without paddle angle and letters)
  newX = currentX + vectorX
  if ((newX > BOTTOM and newY > paddleStart and newY < paddleStart + paddleLength) or (newX < BOTTOM))
    vectorX = switch
      when newX > BOTTOM then -vectorX
      when newX < 0 then -vectorX
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
        editorView = atom.views.getView(editor)

        editorView.addEventListener 'keydown', handler = (event) ->
          onLeftDown() if event.which is 37
          onRightDown() if event.which is 39

        editorView.addEventListener 'keyup', handler = (event) ->
          onLeftUp() if event.which is 37
          onRightUp() if event.which is 39

        gameInit(selection)

        # editor.insertText(selection)
        #
        # console.log(editor.getLastScreenRow())
        # console.log(editor.getLastScreenRow())
