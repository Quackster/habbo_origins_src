property pWindowTitle, pFigure, pDir, pSize, pNude, pPart, pAction, pAnimFrame, pBodyBartObjects, pRegPoint, pPelleType

on new me
  return me
end

on deconstruct me
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  return 1
end

on showHideHahmoEdit me
  reset(me)
  if windowExists(pWindowTitle) then
    return removeWindow(pWindowTitle)
  end if
  me.changeHahmoEditWindowView(pWindowTitle, "hahmoedit.window", "eventProcHahmoedit")
end

on changeHahmoEditWindowView me, tWindowTitle, tWindowName, tEventProc, tX, tY, tWindowType
  if voidp(tWindowType) then
    tTemp = "habbo_basic.window"
  else
    tTemp = tWindowType
  end if
  createWindow(tWindowTitle, "habbo_basic.window", tX, tY)
  if windowExists(tWindowTitle) then
    if voidp(tX) then
      tX = ((the stageRight - the stageLeft) / 2) - (getWindow(tWindowTitle).getProperty(#width) / 2)
    end if
    if voidp(tY) then
      tY = ((the stageBottom - the stageTop) / 2) - (getWindow(tWindowTitle).getProperty(#height) / 2)
    end if
    mergeWindow(tWindowTitle, tWindowName)
    getWindow(tWindowTitle).moveTo(tX, tY)
    registerClient(pWindowTitle, me.getID())
    registerProcedure(tWindowTitle, symbol(tEventProc), me.getID(), #mouseUp)
    registerProcedure(tWindowTitle, symbol(tEventProc), me.getID(), #mouseDown)
    registerProcedure(tWindowTitle, symbol(tEventProc), me.getID(), #keyDown)
    me.createFigurePrew()
  end if
end

on reset me
  pWindowTitle = "HAHMOEDIT"
  pSize = "h"
  pAction = "std"
  pAnimFrame = 0
  pDir = 4
  pNude = 0
  pFigure = getObject(#session).get("figure")
end

on createFigurePrew me
  tFigure = pFigure
  if pSize = "sh" then
    tFigure["hd"]["model"] = "001"
    tFigure["fc"]["model"] = "001"
    if pPelleType then
      tFigure["lh"]["model"] = "s01"
      tFigure["bd"]["model"] = "s01"
      tFigure["rh"]["model"] = "s01"
      tFigure["ch"]["model"] = "s01"
    end if
    if pNude = 0 then
      tPartList = ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "hr", "rh", "rs"]
    else
      tPartList = ["lh", "bd", "hd", "fc", "hr", "rh"]
    end if
  else
    if pNude = 0 then
      tPartList = ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"]
    else
      tPartList = ["lh", "bd", "hd", "fc", "ey", "hr", "rh"]
    end if
  end if
  tdir = pDir
  if tdir = 6 then
    tdir = 0
  else
    if tdir = 5 then
      tdir = 1
    else
      if tdir = 4 then
        tdir = 2
      end if
    end if
  end if
  if pSize = "sh" then
    tHumanImg = image(32, 60, 16)
  else
    tHumanImg = image(64, 120, 16)
  end if
  tHumanImg = me.getHumanPartImg(tPartList, tFigure, tdir, pSize)
  tPrewImg = image(getWindow(pWindowTitle).getSpriteByID("human.preview.img").width, getWindow(pWindowTitle).getSpriteByID("human.preview.img").height, 16)
  tHumanImg = tHumanImg.trimWhiteSpace()
  if pSize = "sh" then
    tdestrect = tPrewImg.rect - (tHumanImg.rect * 4)
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, (tHumanImg.width * 4) + (tdestrect.width / 2), (tdestrect.height / 2) + (tHumanImg.height * 4))
  else
    tdestrect = tPrewImg.rect - (tHumanImg.rect * 2)
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, (tHumanImg.width * 2) + (tdestrect.width / 2), (tdestrect.height / 2) + (tHumanImg.height * 2))
  end if
  tPrewImg.copyPixels(tHumanImg, tdestrect, tHumanImg.rect)
  if tdir <> pDir then
    tPrewImg = me.flipImage(tPrewImg)
  end if
  if getWindow(pWindowTitle).elementExists("human.preview.img") then
    getWindow(pWindowTitle).getElement("human.preview.img").feedImage(tPrewImg)
  end if
end

on setDir me, tdir
  if (pDir + tdir) < 0 then
    pDir = 7
  else
    if (pDir + tdir) > 7 then
      pDir = 0
    else
      if ((pDir + tdir) <= 7) and ((pDir + tdir) >= 0) then
        pDir = pDir + tdir
      end if
    end if
  end if
  me.showActiveMemName()
  me.createFigurePrew()
end

on getHumanPartImg me, tPartList, tFigure, tdir, tSize
  me.createTemplateParts(tFigure, tPartList, tdir, tSize)
  tHumanImg = image(64, 102, 16)
  me.getPartImg(tPartList, tHumanImg, tdir, tSize)
  return tHumanImg
end

on createTemplateParts me, tFigure, tPartList, tdir, tSize
  if voidp(tSize) then
    pPeopleSize = "h"
  else
    tSize = tSize
  end if
  pBuffer = image(1, 1, 8)
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pBodyBartObjects = [:]
  repeat with tPart in tPartList
    if not (tPart contains "it") then
      tmodel = tFigure[tPart]["model"]
      tColor = tFigure[tPart]["color"]
      tDirection = tdir
      tAction = "std"
      tAncestor = me
      if tmodel.char.count = 1 then
        tmodel = "00" & tmodel
      else
        if tmodel.char.count = 2 then
          tmodel = "0" & tmodel
        end if
      end if
      tTempPartObj = createObject(#temp, "Bodypart Class")
      tTempPartObj.define(tPart, tmodel, tColor, tDirection, tAction, tAncestor)
      pBodyBartObjects.addProp(tPart, tTempPartObj)
    end if
  end repeat
end

on getPartImg me, tPartList, tImg, tdir, tSize
  if tPartList.ilk <> #list then
    list(tPartList)
  end if
  repeat with tPart in tPartList
    tAction = VOID
    tAnimFrame = VOID
    if not voidp(pFigure[tPart]["action"]) then
      tAction = pFigure[tPart]["action"]
    end if
    if not voidp(pFigure[tPart]["frame"]) then
      tAnimFrame = pFigure[tPart]["frame"]
    end if
    if not (tPart contains "it") then
      call(#copyPicture, pBodyBartObjects[tPart], tImg, tdir, tSize, tAction, tAnimFrame)
    end if
  end repeat
end

on animFrame me
  if not voidp(pPart) then
    pFigure[pPart]["frame"] = integer(pAnimFrame)
    if pAction = "wlk" then
      repeat with f in ["bd", "lh", "rh", "ls", "rs", "lg", "sh"]
        pFigure[f]["action"] = pAction
        pFigure[f]["frame"] = integer(pAnimFrame)
      end repeat
    end if
    me.showActiveMemName()
    me.createFigurePrew()
  end if
end

on showActiveMemName me
  if voidp(pPart) then
    return 
  end if
  tdir = pDir
  if tdir = 6 then
    tdir = 0
  else
    if tdir = 5 then
      tdir = 1
    else
      if tdir = 4 then
        tdir = 2
      end if
    end if
  end if
  tMem = pSize & "_" & pAction & "_" & pPart & "_" & pFigure[pPart]["model"] & "_" & tdir & "_" & pAnimFrame
  getWindow(pWindowTitle).getSpriteByID("hahmoedit_part").member.text = tMem
end

on setRegPoint me, tpoint
  if voidp(pPart) then
    return 
  end if
  tdir = pDir
  if tdir = 6 then
    tdir = 0
  else
    if tdir = 5 then
      tdir = 1
    else
      if tdir = 4 then
        tdir = 2
      end if
    end if
  end if
  tMem = pSize & "_" & pAction & "_" & pPart & "_" & pFigure[pPart]["model"] & "_" & tdir & "_" & pAnimFrame
  me.showActiveMemName()
  if memberExists(tMem) then
    pRegPoint = member(getmemnum(tMem)).regPoint
    member(getmemnum(tMem)).regPoint = pRegPoint + tpoint
    me.createFigurePrew()
  else
    put "member not found: " && tMem
  end if
end

on eventProcHahmoEdit me, tEvent, tSprID, tParm
  if tEvent = #mouseUp then
    case tSprID of
      "close":
        if windowExists(pWindowTitle) then
          return removeWindow(pWindowTitle)
        end if
      "hahmoedit_drop":
        if tParm contains "Big" then
          pSize = "h"
        else
          pSize = "sh"
        end if
        if tParm contains "Nude" then
          pNude = 1
        else
          pNude = 0
        end if
        if tParm contains "Pelle" then
          pPelleType = 1
          pNude = 1
        else
          pPelleType = 0
        end if
        me.createFigurePrew()
      "hahmoedit _reset_button":
        me.reset()
        me.createFigurePrew()
      "hahmoedit_ok_button":
        tempItemD = the itemDelimiter
        the itemDelimiter = "_"
        tPartDesc = getWindow(pWindowTitle).getSpriteByID("hahmoedit_part").member.text
        if tPartDesc.item.count < 6 then
          return 
        end if
        pPart = tPartDesc.item[3]
        tmodel = tPartDesc.item[4]
        pAction = tPartDesc.item[2]
        pDir = integer(tPartDesc.item[5])
        pAnimFrame = integer(tPartDesc.item[6])
        if pPelleType then
          tmodel = "s" & tmodel.char[2..3]
        end if
        pFigure[pPart]["model"] = tmodel
        pFigure[pPart]["action"] = pAction
        pFigure[pPart]["frame"] = integer(pAnimFrame)
        the itemDelimiter = tempItemD
        if pAction = "wlk" then
          repeat with f in ["bd", "lh", "rh", "ls", "rs", "lg", "sh"]
            pFigure[f]["action"] = pAction
            pFigure[f]["frame"] = integer(pAnimFrame)
          end repeat
        end if
        me.createFigurePrew()
      "hahmoedit.anim.right.button":
        if (pAnimFrame + 1) > 3 then
          return 
        else
          pAnimFrame = pAnimFrame + 1
        end if
        me.animFrame()
      "hahmoedit.anim.left.button":
        if (pAnimFrame - 1) < 0 then
          return 
        else
          pAnimFrame = pAnimFrame - 1
        end if
        me.animFrame()
      "hahmoedit.dir.right.button":
        me.setDir(-1)
      "hahmoedit.dir.left.button":
        me.setDir(1)
      "hahmoedit_recpoint_right":
        me.setRegPoint(point(-1, 0))
      "hahmoedit_recpoint_left":
        me.setRegPoint(point(1, 0))
      "hahmoedit_recpoint_up":
        me.setRegPoint(point(0, 1))
      "hahmoedit_recpoint_down":
        me.setRegPoint(point(0, -1))
    end case
  end if
end

on flipImage me, tImg_a
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return tImg_b
end
