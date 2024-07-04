on testBillboard tdir
  tThread = getThread(#room)
  if tThread = 0 then
    put "ERROR! There is no room available"
    return 0
  end if
  tVisObj = tThread.getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    put "ERROR! There is no room visualizer!"
    return 0
  end if
  if not tVisObj.spriteExists("billboard_img") then
    put "ERROR! Room has no billboard sprite"
    return 0
  end if
  if not tVisObj.spriteExists("billboard_bg") then
    put "ERROR! Room has no billboard background sprite"
    return 0
  end if
  tSprAd = tVisObj.getSprById("billboard_img")
  tSprBg = tVisObj.getSprById("billboard_bg")
  if (tdir = #left) or (tdir contains "l") then
    tmember = member("testBillboardLeft")
  else
    if (tdir = #right) or (tdir contains "r") then
      tmember = member("testBillboardRight")
    else
      if tSprAd.locH < 350 then
        tmember = member("testBillboardLeft")
      else
        tmember = member("testBillboardRight")
      end if
    end if
  end if
  tSprAd.setMember(tmember)
  tSprAd.width = tmember.width
  tSprAd.height = tmember.height
  tmember.trimWhiteSpace = 0
  tSprAd.blend = 100
  tSprAd.visible = 1
  tSprBg.blend = 100
  tSprBg.visible = 1
  if not tVisObj.spriteExists("billboard_bg") then
    put "ERROR! There is no billboard background!"
    return 0
  end if
  tSpr = tVisObj.getSprById("billboard_bg")
  tSpr.member.paletteRef = member(getmemnum("billboardtestpalette2"))
end
