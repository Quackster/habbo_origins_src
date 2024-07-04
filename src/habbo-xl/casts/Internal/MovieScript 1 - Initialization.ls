on prepareMovie
  castLib(2).preloadMode = 1
  preloadNetThing(castLib(2).fileName)
  (the stage).drawRect = rect(0, 0, 1440, 1080)
  (the stage).rect = rect(the stageLeft, the stageTop, the stageLeft + 1440, the stageTop + 1080)
  set the centerStage to 1
  moveToFront(the stage)
  set the exitLock to 1
  puppetTempo(15)
end

on stopMovie
  stopClient()
  go(1)
end
