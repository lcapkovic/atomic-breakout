module.exports =
class SoundMaker
  constructor: (soundTheme) ->
    @soundTheme = soundTheme
    console.log("SoundMaker constructed with theme: " + soundTheme)

  playHit: ->
    if @soundTheme == 'basic'
      console.log('Later')
    else if @soundTheme == 'martin'
      explNumber = Math.floor(Math.random() * 2) + 1
      hit = new Audio(atom.packages.getPackageDirPaths()[0] + '/atomic-breakout/sound/martinExplosion' + explNumber + '.m4a')
      hit.play()
    else if @soundTheme == 'insane'
      console.log('Insane hit!')
