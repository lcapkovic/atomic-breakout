{CompositeDisposable} = require 'atom'

globalEditor = null
goingLeft = false
goingRight = false

paddleStart = 30
paddle = " ########## "


currentX = BOTTOM-1
currentY = paddleStart+5
vectorX = 0.12
vectorY = -0.14

loopp = null

gameOver = false
beforeStart = true

animationFrame = null
BOTTOM = 30
RIGHT = 80

fpscounter = 0
selection = ""

letters = ((false for sth in [1..2*BOTTOM]) for sth2 in [1..2*RIGHT])

maximumLengthOfLine = (str) ->
  arr = str.split("\n")
  lengths = []
  lengths.push(a.length) for a in arr
  max = 0
  for l in lengths
    console.log(l.toString())
    if l > max
      max = l
  max

isCollision = ->
  letters[Math.round(currentX)][Math.round(currentY)]

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

  globalEditor.setTextInBufferRange([[x,y],[x,y+1]], 'Θ')

setupGameLoop = (gameLoop) ->
  animationFrame = window.requestAnimationFrame
  every = (ms, cb) -> setInterval cb, ms
  loopp = every 1000/200, () ->
    gameLoop()

  # if animationFrame != null
  #   recursiveAnimation = () ->
  #     gameLoop()
  #     animationFrame(recursiveAnimation)
  #   animationFrame(recursiveAnimation)

stopGameLoop = ->
  if animationFrame != null
    clearInterval(loopp)


checkEndCondition = ->
  if currentX > 30
    console.log("GAME OVER")
    gameOver = true


gameloop = ->
  if goingLeft && paddleStart > 0
    paddleStart--
  if goingRight && paddleStart < 70
    paddleStart++

  if beforeStart
    vectorX = 0
    vectorY = 0
    removeBall()
    currentX = BOTTOM-1
    currentY = paddleStart+5
    drawPaddle()
    drawBall()
  else if !gameOver
    drawPaddle()
    removeBall()
    moveBall()
    checkEndCondition()
    drawBall()
  else
    globalEditor.setTextInBufferRange([[20, 35], [20, 45]], "GAME OVER")
    stopGameLoop()



gameInit = (selection) ->
  goingLeft = false
  goingRight = false

  paddleStart = 30

  currentX = 20
  currentY = 15
  vectorX = 0.06
  vectorY = 0.05
  gameOver = false
  beforeStart = true

  space = ""
  space += ' ' for i in [0..RIGHT]


  console.log("Max: " + maximumLengthOfLine(selection))
  console.log(((RIGHT - maximumLengthOfLine(selection)) // 2).toString())
  centeringLength = ((RIGHT - maximumLengthOfLine(selection)) // 2)
  centering = ""
  if centeringLength > 0
    centering += ' ' for i in [0..((RIGHT - maximumLengthOfLine(selection)) // 2)]

  lines = selection.split('\n')
  globalEditor.insertText(space + '\n') for i in [0..3]
  for line in lines
    line = centering + line
    globalEditor.insertText(line + space + '\n')
  globalEditor.insertText(space + '\n') for i in [0..(BOTTOM - getStringLines(selection)-4)]
  globalEditor.scrollToScreenPosition([0,0])

  for i in [0..BOTTOM]
    for j in [0..RIGHT]
      letters[i][j] = globalEditor.getTextInBufferRange([[i,j], [i,j+1]]) != " "

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

onSpaceDown = (event) ->
  beforeStart = false
  vectorX = -0.2
  vectorY = 0.1

onEscDown = (event) ->
  stopGameLoop()

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

  # Calculate column coordinate: (version without letters)
  newY = currentY + vectorY
  vectorY = switch
    when newY > RIGHT then -vectorY
    when newY < 0 then -vectorY
    else vectorY
  currentY = currentY + vectorY

  # Calculate row coordinate: (version without paddle angle and letters)
  newX = currentX + vectorX
  if ((Math.round(newX) == BOTTOM and newY > paddleStart and newY < paddleStart + paddleLength + 1) or (Math.round(newX) < BOTTOM))
    vectorX = switch
      when Math.round(newX) == BOTTOM then -vectorX
      when newX < 0 then -vectorX
      else vectorX

    if (Math.round(newX) == BOTTOM)
      direction = newY - paddleStart - 5.5
      vectorY = 0.4 * direction / 4.5
  else
    vectorX = vectorX
  currentX = currentX + vectorX

  if isCollision()
    X = Math.round(currentX)
    Y = Math.round(currentY)
    letters[X][Y] = false

    r = Y + 0.5 - currentY
    l = currentY - Y + 0.5
    d = X + 0.5 - currentX
    u = currentX - X + 0.5
    if Math.min(r, l) < Math.min(d, u)
      vectorY = -vectorY
    else
      vectorX = -vectorX

module.exports = AtomicBreakout =
  atomicBreakoutView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atomic-breakout:convert': => @convert()

  deactivate: ->
    @subscriptions.dispose()

  convert: ->
    if editor = atom.workspace.getActiveTextEditor()
      selection = editor.getSelectedText()

      suffix = editor.getTitle().split('.')[1]
      atom.workspace.open("breakout." + suffix).then (editor) ->
        globalEditor = editor
        editorView = atom.views.getView(editor)

        editorView.addEventListener 'keydown', handler = (event) ->
          onLeftDown() if event.which is 37
          onRightDown() if event.which is 39
          onSpaceDown() if event.which is 32
          onEscDown() if event.which is 27

        editorView.addEventListener 'keyup', handler = (event) ->
          onLeftUp() if event.which is 37
          onRightUp() if event.which is 39

        gameInit(selection)

        # editor.insertText(selection)
        #
        # console.log(editor.getLastScreenRow())
        # console.log(editor.getLastScreenRow())
