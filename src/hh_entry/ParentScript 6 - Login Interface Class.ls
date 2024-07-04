property pConnectionId, pTempPassword, pOriginalFontSize, pMinFontSize

on construct me
  pConnectionId = getVariable("connection.info.id")
  pTempPassword = EMPTY
  pOriginalFontSize = 18
  pMinFontSize = 9
  return 1
end

on deconstruct me
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return 1
end

on showLogin me
  getObject(#session).set(#userName, EMPTY)
  getObject(#session).set(#password, EMPTY)
  getObject(#session).set(#email, EMPTY)
  getObject(#session).set(#totp, EMPTY)
  pTempPassword = EMPTY
  if createWindow(#login_a, "habbo_simple.window", 444, 100) then
    tWndObj = getWindow(#login_a)
    tWndObj.merge("login_a.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
  end if
  if createWindow(#login_b, "habbo_simple.window", 444, 230) then
    tWndObj = getWindow(#login_b)
    tWndObj.merge("login_b.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #keyDown)
    tWndObj.getElement("login_username").setFocus(1)
    if variableExists("username_input.font.size") then
      tElem = tWndObj.getElement("login_username")
      if tElem = 0 then
        return 0
      end if
      if tElem.pMember = VOID then
        return 0
      end if
      if tElem.pMember.type <> #field then
        return 0
      end if
      tElem.pMember.fontSize = getIntVariable("username_input.font.size")
      pOriginalFontSize = tElem.pMember.fontSize
      pMinFontSize = 9
      tElem = tWndObj.getElement("login_password")
      if tElem = 0 then
        return 0
      end if
      if tElem.pMember = VOID then
        return 0
      end if
      if tElem.pMember.type <> #field then
        return 0
      end if
      tElem.pMember.fontSize = getIntVariable("username_input.font.size")
    end if
  end if
  return 1
end

on hideLogin me
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  if windowExists(#login_topt) then
    removeWindow(#login_topt)
  end if
  return 1
end

on showDisconnect me
  createWindow(#error, "error.window", 0, 0, #modal)
  tWndObj = getWindow(#error)
  tWndObj.getElement("error_title").setText(getText("Alert_ConnectionFailure"))
  tWndObj.getElement("error_text").setText(getText("Alert_ConnectionDisconnected"))
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcDisconnect, me.getID(), #mouseUp)
  the keyboardFocusSprite = 0
end

on showOneTimePassword me
  getObject(#session).set(#totp, EMPTY)
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  if createWindow(#login_totp, "habbo_simple.window", 444, 230) then
    tWndObj = getWindow(#login_totp)
    tWndObj.merge("login_totp.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #keyDown)
    tWndObj.getElement("login_totp_code").setFocus(1)
  end if
  return 1
end

on tryLogin me
  tOneTimePassword = EMPTY
  if windowExists(#login_b) and (getObject(#session).get(#userName) = EMPTY) then
    tWndObj = getWindow(#login_b)
    tUserName = tWndObj.getElement("login_username").getText()
    tPassword = pTempPassword
    if tUserName = EMPTY then
      return 0
    end if
    if tPassword = EMPTY then
      return 0
    end if
    getWindow(#login_b).getElement("login_ok").hide()
    getWindow(#login_b).getElement("login_connecting").setProperty(#blend, 100)
    me.blinkConnection(#login_b)
    getObject(#session).set(#userName, tUserName)
    getObject(#session).set(#password, tPassword)
    getObject(#session).set(#totp, tOneTimePassword)
  end if
  if windowExists(#login_totp) and (getObject(#session).get(#userName) <> EMPTY) and (getObject(#session).get(#totp) = EMPTY) then
    tWndObj = getWindow(#login_totp)
    tOneTimePassword = tWndObj.getElement("login_totp_code").getText()
    getObject(#session).set(#totp, tOneTimePassword)
  end if
  if tOneTimePassword <> EMPTY then
    tElem = getWindow(#login_a).getElement("login_createUser")
    tElem.setProperty(#blend, 99)
    tElem.setProperty(#cursor, 0)
    if connectionExists(pConnectionId) then
      me.blinkConnection(#login_totp)
      getConnection(pConnectionId).send("TRY_LOGIN", [#string: getObject(#session).get(#userName), #string: getObject(#session).get(#password), #string: getObject(#session).get(#totp)])
    end if
  else
    me.getComponent().setaProp(#pOkToLogin, 1)
    return me.getComponent().connect()
  end if
end

on blinkConnection me, windowtype
  if not windowExists(windowtype) then
    return 0
  end if
  if timeoutExists(#login_blinker) then
    return 0
  end if
  tElem = getWindow(windowtype).getElement("login_connecting")
  if not tElem then
    return 0
  end if
  okElemName = "login_ok"
  if windowtype = #login_totp then
    okElemName = "login_totp_ok"
  end if
  if getWindow(windowtype).getElement(okElemName).getProperty(#visible) = 1 then
    return 0
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  return createTimeout(#login_blinker, 500, #blinkConnection, me.getID(), VOID, 1)
end

on showUserFound me
  if windowExists(#login_totp) then
    removeWindow(#login_totp)
  end if
  if windowExists(#login_b) then
    getWindow(#login_b).unmerge()
  else
    createWindow(#login_b, "habbo_simple.window", 444, 230)
  end if
  tWndObj = getWindow(#login_b)
  tWndObj.merge("login_c.window")
  tTxt = tWndObj.getElement("login_c_welcome").getText()
  tTxt = tTxt && getObject(#session).get("user_name")
  tWndObj.getElement("login_c_welcome").setText(tTxt)
  if objectExists("Figure_Preview") then
    tBuffer = getObject("Figure_Preview").createTemplateHuman("h", 3, "wave")
    tWndObj.getElement("login_preview").setProperty(#buffer, tBuffer)
    me.delay(800, #myHabboSmile)
  else
    me.hideLogin()
  end if
  return 1
end

on myHabboSmile me
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createTemplateHuman("h", 3, "gest", "temp sml")
  end if
  me.delay(1200, #stopWaving)
  getObject(#session).set(#password, VOID)
end

on stopWaving me
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createTemplateHuman("h", 3, "reset")
    getObject("Figure_Preview").createTemplateHuman("h", 3, "gest", "temp sml")
    getObject("Figure_Preview").createTemplateHuman("h", 3, "remove")
  end if
  me.delay(400, #hideLogin)
end

on adjustFieldSize me, tFieldName
  if not windowExists(#login_b) then
    return 0
  end if
  tmember = getWindow(#login_b).getElement(tFieldName)
  tFieldWidth = 240
  tTextLength = tmember.getText().length
  tFontSize = pOriginalFontSize
  if tTextLength > 14 then
    tmember.pMember.fontSize = 9
  end if
  return 1
end

on updatePasswordAsterisks me
  if not windowExists(#login_b) then
    return 0
  end if
  tPwdTxt = getWindow(#login_b).getElement("login_password").getText()
  repeat with i = 1 to tPwdTxt.length
    tChar = chars(tPwdTxt, i, i)
    if (tChar <> "*") and (tChar <> " ") then
      pTempPassword = chars(pTempPassword, 1, i - 1) & tChar & chars(pTempPassword, i + 1, i + 1)
    end if
  end repeat
  tStars = EMPTY
  repeat with i = 1 to pTempPassword.length
    tStars = tStars & "*"
  end repeat
  getWindow(#login_b).getElement("login_password").setText(tStars)
  me.adjustFieldSize("login_password")
end

on forgottenpw me
  if not createWindow(#login_b, "habbo_simple.window", 444, 230) then
    return 0
  end if
  getWindow(#login_b).merge("habbo_forgottenpw.window")
  getWindow(#login_b).registerProcedure(#eventProcForgottenpw, me.getID(), #mouseUp)
  if not connectionExists(pConnectionId) then
    getThread(#navigator).getComponent().updateState("connection")
  end if
  getThread(#navigator).getComponent().updateState("forgottenPassWord")
  return 1
end

on eventProcLogin me, tEvent, tSprID, tParam
  tWndObj = getWindow(#login_b)
  if not tWndObj then
    tWndObj = getWindow(#login_totp)
    if not tWndObj then
      return 0
    end if
  end if
  case tEvent of
    #mouseUp:
      case tSprID of
        "login_password":
          tCount = tWndObj.getElement(tSprID).getText().length
          set the selStart to tCount
          set the selEnd to tCount
        "login_ok":
          return me.tryLogin()
        "login_totp_ok":
          return me.tryLogin()
        "login_createUser":
          pTempPassword = EMPTY
          if getWindow(#login_a).getElement(tSprID).getProperty(#blend) = 100 then
            if windowExists(#login_a) then
              removeWindow(#login_a)
            end if
            if windowExists(#login_b) then
              removeWindow(#login_b)
            end if
            executeMessage(#show_registration)
            return 1
          end if
        "login_forgotten":
          openNetPage(getText("forgotten_password_url"))
      end case
    #keyDown:
      tTimeoutHideName = "pwdhide" & the milliSeconds
      if the keyCode = 36 then
        me.tryLogin()
        return 1
      end if
      case tSprID of
        "login_username":
          me.adjustFieldSize("login_username")
        "login_password":
          case the keyCode of
            48:
              return 0
            49:
              return 1
            51:
              if pTempPassword.length > 0 then
                pTempPassword = chars(pTempPassword, 1, pTempPassword.length - 1)
              end if
            123, 124, 125, 126:
              return 1
            117:
              if windowExists(#login_b) then
                tWndObj.getElement(tSprID).setText(EMPTY)
                pTempPassword = EMPTY
              end if
          end case
          createTimeout(tTimeoutHideName, 1, #updatePasswordAsterisks, me.getID(), VOID, 1)
      end case
  end case
  return 0
end

on eventProcForgottenpw me, tEvent, tSprID, tParm
  if tEvent = #mouseUp then
    case tSprID of
      "forgottenpw_back":
        getThread(#navigator).getComponent().updateState("login")
      "forgottenpw_emailpw":
        tName = getWindow(#login_b).getElement("forgottenpw_name").getText()
        tMail = getWindow(#login_b).getElement("forgottenpw_email").getText()
        if connectionExists(pConnectionId) then
          getConnection(pConnectionId).send(#info, "SEND_USERPASS_TO_EMAIL" && tName && tMail)
        else
          error(me, "Couldn't find connection:" && pConnectionId, #eventProcForgottenpw)
        end if
        if not createWindow(#login_b, "habbo_simple.window", 444, 230) then
          return 0
        end if
        getWindow(#login_b).merge("habbo_forgotten2.window")
        getWindow(#login_b).registerProcedure(#eventProcForgottenpw, me.getID(), #mouseUp)
      "forgottenpw_ok":
        getThread(#navigator).getComponent().updateState("login")
    end case
  end if
end

on eventProcDisconnect me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    if tElemID = "error_close" then
      removeWindow(#error)
      resetClient()
    end if
  end if
end
