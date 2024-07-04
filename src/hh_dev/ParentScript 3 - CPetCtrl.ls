property pWndID, pPetID, pPetName

on construct me
  pWndID = "petctrlwnd" && me.getID()
  pPetID = getObject(#session).get("selected_pet_id")
  pPetName = getObject(#session).get("selected_pet_name")
  if createWindow(pWndID) then
    tWndObj = getWindow(pWndID)
    tWndObj.setProperty(#title, pPetName && "Control")
    tWndObj.merge("habbo_basic.window")
    tWndObj.merge("petctrl.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    return me.executeCmd(":passivate" && pPetID)
  else
    return error(me, "Failed to create window!", #construct)
  end if
end

on deconstruct me
  removeWindow(pWndID)
  return me.executeCmd(":activate" && pPetID)
end

on executeCmd me, tCmd
  if connectionExists(getVariable("connection.info.id", #info)) then
    getConnection(getVariable("connection.info.id", #info)).send("CHAT", [#string: tCmd])
  end if
  return 1
end

on eventProc me, tEvent, tElemID, tParam
  case tElemID of
    "dir_0":
      return me.executeCmd(":setdir" && pPetID && "0" && "0")
    "dir_1":
      return me.executeCmd(":setdir" && pPetID && "1" && "1")
    "dir_2":
      return me.executeCmd(":setdir" && pPetID && "2" && "2")
    "dir_3":
      return me.executeCmd(":setdir" && pPetID && "3" && "3")
    "dir_4":
      return me.executeCmd(":setdir" && pPetID && "4" && "4")
    "dir_5":
      return me.executeCmd(":setdir" && pPetID && "5" && "5")
    "dir_6":
      return me.executeCmd(":setdir" && pPetID && "6" && "6")
    "dir_7":
      return me.executeCmd(":setdir" && pPetID && "7" && "7")
    "btn_on":
      return me.executeCmd(":actionon" && pPetID && "Dev" && getWindow(pWndID).getElement("cmd_field").getText())
    "btn_off":
      return me.executeCmd(":actionoff" && pPetID && "Dev" && getWindow(pWndID).getElement("cmd_field").getText())
    "close":
      return removeObject(me.getID())
  end case
end
