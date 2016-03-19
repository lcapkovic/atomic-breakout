AtomicBreakoutView = require './atomic-breakout-view'
{CompositeDisposable} = require 'atom'

globalEditor = null
goingLeft = false
goingRight = false

paddleStart = 30
paddle = " ########## "

currentX = 20
currentY = 15
vectorX = 0.2
vectorY = 0.2

gameOver = false

BOTTOM = 30
RIGHT = 80

fpscounter = 0
selection = ""

averageLengthOfLine = (str) ->
  arr = str.split("\n")
  lengths = []
  lengths.push(a.length) for a in arr
  sum = 0
  for l in lengths
    sum += l

  Math.round(sum/arr.length)

isCollision = ->
  x = Math.round(currentX)
  y = Math.round(currentY)
  returnVal = -1
  globalEditor.setSelectedBufferRange([[x,y-1], [x,y]]) # top
  if globalEditor.getSelectedText() == " "
    returnVal = 0
  globalEditor.setSelectedBufferRange([[x+1,y], [x+1,y+1]]) # right
  if globalEditor.getSelectedText() == " "
    returnVal =  1
  globalEditor.setSelectedBufferRange([[x,y+1], [x,y+2]]) # down
  if globalEditor.getSelectedText() == " "
    returnVal = 2
  globalEditor.setSelectedBufferRange([[x-1,y], [x-1,y+1]]) # left
  if globalEditor.getSelectedText() == " "
    returnVal = 3
  returnVal

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

checkEndCondition = ->
  if currentX > 30
    console.log("GAME OVER")
    gameOver = true

gameloop = ->
  if goingLeft && paddleStart > 0
    paddleStart--
  if goingRight && paddleStart < 70
    paddleStart++

  if !gameOver
    drawPaddle()
    removeBall()
    moveBall()
    console.log(isCollision())
    checkEndCondition()
    drawBall()
  else
    globalEditor.setTextInBufferRange([[20, 35], [20, 45]], "GAME OVER")


gameInit = (selection) ->
  goingLeft = false
  goingRight = false

  paddleStart = 30

  currentX = 20
  currentY = 15
  vectorX = 0.2
  vectorY = 0.2
  gameOver = false

  space = ""
  space += ' ' for i in [0..80]

  lines = selection.split('\n')
  globalEditor.insertText(space + '\n') for i in [0..3]
  for line in lines
    globalEditor.insertText(line + space + '\n')
  globalEditor.insertText(space + '\n') for i in [0..(BOTTOM - getStringLines(selection)-4)]
  globalEditor.scrollToScreenPosition([0,0])
  setupGameLoop(gameloop)

onLeftDown = (event) ->
  if !goingLeft
    goingLeft = true

onRightDown = (event) ->
  if !goingRight
    goingRight = true

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

# Global variables needed:
# currentX, currentX
# vectorX, vectorY
# bottom, right
# paddleY, length

# The floor function has to be done at the drawing stage

moveBall = ->

  paddleLength = paddle.length-2

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
