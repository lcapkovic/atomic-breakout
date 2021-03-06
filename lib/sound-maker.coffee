module.exports =
class SoundMaker
  constructor: (soundTheme) ->
    @soundTheme = soundTheme
    console.log("SoundMaker constructed with theme: " + soundTheme)

  playHit: ->
    if @soundTheme == 'basic'
      number = Math.floor(Math.random() * 4) + 1
      hit = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/basicHit' + number + '.wav')
      hit.play()
    else if @soundTheme == 'martin'
      explNumber = Math.floor(Math.random() * 2) + 1
      hit = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/martinExplosion' + explNumber + '.m4a')
      hit.play()
    else if @soundTheme == 'arnie'
      number = Math.floor(Math.random() * 3) + 1
      if number < 3
        hit = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/arnieHit' + number + '.mp3')
      else
        hit = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/arnieHit3.wav')
      hit.play()
    else if @soundTheme == 'goat'
      number = Math.floor(Math.random() * 4) + 1
      hit = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/goatHit' + number + '.mp3')
      hit.play()

  playComboBreaker: ->
    if @soundTheme == 'basic'
      sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/basicComboBreaker.wav')
      sound.play()
    else if @soundTheme == 'arnie'
      sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/arnieComboBreaker.mp3')
      sound.play()
    else if @soundTheme == 'goat'
      sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/goatComboBreaker.mp3')
      sound.play()

  playCombo: (level) ->
    if @soundTheme == 'basic'
      sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/basicCombo' + level + '.wav')
      sound.play()
    else if @soundTheme == 'arnie'
      if level == 1 || level == 3
        sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/arnieCombo1.wav')
        sound.play()
      else
        sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/arnieCombo2.mp3')
        sound.play()
    else if @soundTheme == 'goat'
      sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/goatCombo' + level + '.mp3')
      sound.play()

  playGameover: ->
    if @soundTheme == 'basic'
      sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/basicComboBreaker.wav')
      sound.play()
    else if @soundTheme == 'arnie'
      sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/arnieGameover.wav')
      sound.play()
    else if @soundTheme == 'goat'
      sound = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/goatComboBreaker.mp3')
      sound.play()

  playPaddle: ->
    if @soundTheme == 'basic' || @soundTheme == 'arnie'
      hit = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/basicPaddle.wav')
      hit.play()
