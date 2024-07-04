property pWndID, pPeeloObj

on construct me
  pWndID = "peeloview"
  if createWindow(pWndID) then
    tWndObj = getWindow(pWndID)
    tWndObj.merge("habbo_full.window")
    tWndObj.merge("peeloview.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProc, me.getID(), #keyDown)
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    pPeeloObj = createObject(#temp, "Human Class EX")
    registerListener(getVariable("connection.info.id"), me.getID(), [128: #setInfo])
    registerCommands(getVariable("connection.info.id"), me.getID(), ["FINDUSER": 41])
    return 1
  else
    return error(me, "Failed to create window!", #construct)
  end if
end

on deconstruct me
  pPeeloObj = VOID
  unregisterListener(getVariable("connection.info.id"), me.getID(), [128: #setInfo])
  unregisterCommands(getVariable("connection.info.id"), me.getID(), ["FINDUSER": 41])
  return removeWindow(pWndID)
end

on getInfo me, tName
  if tName <> EMPTY then
    if connectionExists(getVariable("connection.info.id", #info)) then
      getConnection(getVariable("connection.info.id", #info)).send("FINDUSER", tName & TAB & "PEELOVIEW")
    end if
  end if
  return 1
end

on setInfo me, tMsg
  case tMsg.content.line[1].word[1] of
    "PEELOVIEW":
      tProps = [:]
      tStr = tMsg.getaProp(#content)
      tStr = tStr.line[2..tStr.line.count]
      tProps[#name] = tStr.line[1]
      tProps[#customText] = QUOTE & tStr.line[2] & QUOTE
      tProps[#lastAccess] = tStr.line[3]
      tProps[#location] = tStr.line[4]
      tProps[#figure] = tStr.line[5]
      tProps[#sex] = tStr.line[6]
      tdata = [:]
      tdata[#name] = "PEELO"
      tdata[#custom] = EMPTY
      tdata[#direction] = [0, 0, 0]
      tdata[#x] = 0
      tdata[#y] = 0
      tdata[#h] = 0
      if (tProps[#sex] contains "f") or (tProps[#sex] contains "F") then
        tdata[#sex] = "F"
      else
        tdata[#sex] = "M"
      end if
      if objectExists("Figure_System") then
        tdata[#figure] = getObject("Figure_System").parseFigure(tProps[#figure], tProps[#sex], "user")
      end if
      if objectp(pPeeloObj) then
        pPeeloObj.define(tdata)
      end if
  end case
end

on eventProc me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    if tElemID = "close" then
      return removeObject(me.getID())
    else
      return 1
    end if
  end if
  if tEvent = #keyDown then
    if the key = RETURN then
      put getWindow(pWndID).getElement("name").getText()
      return me.getInfo(getWindow(pWndID).getElement("name").getText())
    else
      return 0
    end if
  end if
end
