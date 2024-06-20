global temptrack

on gri
  return getThread(#room).getInterface()
end

on griv
  return gri().getRoomVisualizer()
end

on grc
  return getThread(#room).getComponent()
end

on mtrack
  tstart = [314, 500]
  txpoints = [568]
  tdir = -1
  tydiff = abs(tstart[1] - txpoints[1]) / 2
  ttrack = []
  ttrack[1] = [txpoints[1], tstart[2] + (tydiff * tdir)]
  repeat with i = 2 to count(txpoints)
    ttrack[i] = [txpoints[i], ttrack[i - 1][2] + (tdir * (abs(txpoints[i] - ttrack[i - 1][1]) / 2))]
  end repeat
  temptrack = ttrack
  put ttrack
end
