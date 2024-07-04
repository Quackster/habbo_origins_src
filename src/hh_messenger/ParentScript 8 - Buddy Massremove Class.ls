property pWindowList, pAlertList, pDefWndType, pWriterPlain, pWriterLink, pWriterBold, pReadyFlag, pChosenHelpRadio, pHelpChoiceCount, pCfhType, pReportTopicId, pReportWindowTitle, pReportWindowID, pReportedUserSelectionList, pReportedChatSelectionList, pReportPageNr, pReportPageCount, pTotalReportableUsers, pTotalReportableChatLines, pReportedUserCheckBoxList, pReportedChatCheckBoxList

on construct me
  pWindowList = []
  pAlertList = []
  pDefWndType = "habbo_basic.window"
  pReadyFlag = 0
  registerMessage(#openGeneralDialog, me.getID(), #showDialog)
  registerMessage(#alert, me.getID(), #ShowAlert)
  pHelpChoiceCount = me.countHelpChoices()
  pChosenHelpRadio = 0
  pCfhType = #none
  pReportTopicId = #none
  pReportWindowTitle = VOID
  pReportWindowID = EMPTY
  pReportedUserSelectionList = []
  pReportedUserCheckBoxList = []
  pReportedChatSelectionList = []
  pReportedChatCheckBoxList = []
  pReportPageNr = 1
  pReportPageCount = 1
  pTotalReportableUsers = 10
  pTotalReportableChatLines = 9
  repeat with i = 1 to pTotalReportableUsers
    pReportedUserCheckBoxList.add(0)
  end repeat
  repeat with i = 1 to pTotalReportableChatLines
    pReportedChatCheckBoxList.add(0)
  end repeat
  return 1
end

on deconstruct me
  if pReadyFlag then
    repeat with tid in pWindowList
      if windowExists(tid) then
        removeWindow(tid)
      end if
    end repeat
    repeat with tid in pAlertList
      if windowExists(tid) then
        removeWindow(tid)
      end if
    end repeat
    if writerExists(pWriterPlain) then
      removeWriter(pWriterPlain)
    end if
    if writerExists(pWriterLink) then
      removeWriter(pWriterLink)
    end if
    if writerExists(pWriterBold) then
      removeWriter(pWriterBold)
    end if
  end if
  pWindowList = []
  pAlertList = []
  pReadyFlag = 0
  unregisterMessage(#openGeneralDialog, me.getID())
  unregisterMessage(#alert, me.getID())
  return 1
end

on countHelpChoices me
  if not textExists("help_pointer_1") then
    error(me, "No help choices defined. All go to emergency help.", #countHelpChoices)
    return 0
  end if
  repeat with i = 2 to 7
    if not textExists("help_pointer_" & i) then
      return i - 1
    end if
  end repeat
  return 7
end

on ShowAlert me, tProps
  if not pReadyFlag then
    me.buildResources()
  end if
  if voidp(tProps) then
    return error(me, "Properties for window expected!", #showHideWindow)
  end if
  if stringp(tProps) then
    tProps = [#msg: tProps]
  end if
  tText = getText(tProps[#msg])
  tWndTitle = getText("win_error", "Notice!")
  tTextImg = getWriter(pWriterPlain).render(tText).duplicate()
  if voidp(tProps[#id]) then
    tActualID = "alert" && the milliSeconds
  else
    tActualID = "alert" && tProps[#id]
  end if
  if tProps[#modal] = 1 then
    tSpecial = #modal
  else
    tSpecial = VOID
  end if
  if pAlertList.getOne(tActualID) then
    me.removeDialog(tActualID, pAlertList)
  end if
  if not createWindow(tActualID, VOID, VOID, VOID, tSpecial) then
    return 0
  end if
  tWndObj = getWindow(tActualID)
  tWndObj.setProperty(#title, tWndTitle)
  tWndObj.merge(pDefWndType)
  if stringp(tProps[#title]) then
    tWndObj.merge("habbo_alert_a.window")
    tTitle = getText(tProps[#title])
    getWriter(pWriterBold).define([#alignment: #center])
    tTitleImg = getWriter(pWriterBold).render(tTitle).duplicate()
    tTitleElem = tWndObj.getElement("alert_title")
    tTitleElem.feedImage(tTitleImg)
    tTitleWidth = tTitleImg.width
    tTitleHeight = tTitleImg.height
  else
    tTitleWidth = 0
    tTitleHeight = 0
    tWndObj.merge("habbo_alert_b.window")
    tTitle = EMPTY
  end if
  tTextElem = tWndObj.getElement("alert_text")
  tWidth = tTextElem.getProperty(#width)
  tHeight = tTextElem.getProperty(#height)
  tTextElem.moveBy(0, tTitleHeight)
  tOffW = 0
  tOffH = 0
  tTextElem.feedImage(tTextImg)
  if tTitleWidth > tTextImg.width then
    if tWidth < tTitleWidth then
      tOffW = tTitleWidth - tWidth
    end if
  else
    if tWidth < tTextImg.width then
      tOffW = tTextImg.width - tWidth
    end if
  end if
  if tHeight < (tTextImg.height + tTitleHeight) then
    tOffH = tTextImg.height + tTitleHeight - tHeight
  end if
  tWndObj.resizeBy(tOffW, tOffH)
  if tTitle <> EMPTY then
    tTitleV = tTitleElem.getProperty(#locV)
    tTitleH = tTitleElem.getProperty(#locH)
    tTitleElem.moveTo((tWndObj.getProperty(#width) / 2) - (tTitleWidth / 2) - tTitleH, tTitleV)
  end if
  tWndObj.center()
  tLocOff = pAlertList.count * 10
  tWndObj.moveBy(tLocOff, tLocOff)
  tWndObj.registerClient(me.getID())
  if symbolp(tProps[#registerProcedure]) then
    tWndObj.registerProcedure(tProps[#registerProcedure], me.getID(), #mouseUp)
  else
    tWndObj.registerProcedure(#eventProcAlert, me.getID(), #mouseUp)
  end if
  pAlertList.add(tActualID)
  return 1
end

on showDialog me, tWndID, tProps
  if not pReadyFlag then
    me.buildResources()
  end if
  case tWndID of
    #alert, "alert", #modal_alert, "modal_alert":
      return me.ShowAlert(tProps)
    #purse, "purse":
      return executeMessage(#show_hide_purse)
    #help, "help":
      tWndTitle = getText("win_help", "Help")
      if windowExists(tWndTitle) then
        return me.removeDialog(tWndTitle, pWindowList)
      end if
      me.createDialog(tWndTitle, pDefWndType, "habbo_help.window", #eventProcHelp)
      tWndObj = getWindow(tWndTitle)
      tStr = EMPTY
      i = 0
      repeat while 1
        i = i + 1
        if textExists("help_txt_" & i) then
          tStr = tStr & getText("help_txt_" & i) & RETURN
          next repeat
        end if
        exit repeat
      end repeat
      tStr = tStr.line[1..tStr.line.count - 1]
      tLinkImg = getWriter(pWriterLink).render(tStr).duplicate()
      tWndObj.getElement("link_list").feedImage(tLinkImg)
      if threadExists(#room) then
        if getThread(#room).getComponent().getRoomID() = EMPTY then
          tWndObj.getElement("help_callforhelp_textlink").hide()
        end if
      end if
      if tWndObj.elementExists("help_tutorial_link") then
        tLinkURL = getText("reg_tutorial_url", EMPTY)
        if not stringp(tLinkURL) or (tLinkURL.length < 10) then
          tWndObj.getElement("help_tutorial_link").setProperty(#visible, 0)
        else
          tWndObj.getElement("help_tutorial_link").setText(getText("reg_tutorial_txt") && ">>")
        end if
      end if
    #call_for_help, "call_for_help":
      tReportableUsers = getObject(#session).get("reportable_users")
      if count(tReportableUsers) = 0 then
        me.ShowAlert([#msg: "help.cfh.error.nochathistory"])
      else
        me.openCfhWindowWithReportingOptions()
      end if
    #help_choice, "help_choice":
      me.openHelpChoiceWindow()
    #ban, "ban":
      tProps[#registerProcedure] = #eventProcBan
      return me.ShowAlert(tProps)
  end case
end

on buildResources me
  pWriterPlain = "dialog_writer_plain"
  pWriterLink = "dialog_writer_link"
  pWriterBold = "dialog_writer_bold"
  tFontPlain = getStructVariable("struct.font.plain")
  tFontLink = getStructVariable("struct.font.link")
  tFontBold = getStructVariable("struct.font.bold")
  tFontPlain.setaProp(#lineHeight, 14)
  tFontLink.setaProp(#lineHeight, 14)
  tFontBold.setaProp(#lineHeight, 14)
  createWriter(pWriterPlain, tFontPlain)
  createWriter(pWriterLink, tFontLink)
  createWriter(pWriterBold, tFontBold)
  pReadyFlag = 1
  return 1
end

on createDialog me, tWndTitle, tWndType, tContentType, tEventProc
  if not createWindow(tWndTitle, tWndType) then
    return 0
  end if
  tWndObj = getWindow(tWndTitle)
  tWndObj.merge(tContentType)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(tEventProc, me.getID(), #mouseUp)
  pWindowList.add(tWndTitle)
  return 1
end

on removeDialog me, tWndTitle, tWndList
  if tWndList.getOne(tWndTitle) then
    tWndList.deleteOne(tWndTitle)
    return removeWindow(tWndTitle)
  else
    return error(me, "Attempted to remove unknown dialog:" && tWndTitle, #removeDialog)
  end if
end

on showAlertSentWindow me, tWndObj
  tWndObj.unmerge()
  tWndObj.merge("habbo_hobba_alertsent.window")
  if pCfhType = #habbo_helpers then
    tHeader = getText("callhelp_sent")
    tText = getText("callhelp_allwillreceive")
  else
    tHeader = getText("help_emergency_sent")
    tText = getText("help_emergency_whathappens")
  end if
  tWndObj.getElement("alertsent_header").setText(tHeader)
  tWndObj.getElement("alertsent_text").setText(tText)
  return 1
end

on openCfhWindow me
  tWndTitle = getText("win_callforhelp")
  if windowExists(tWndTitle) then
    me.removeDialog(tWndTitle, pWindowList)
  end if
  me.createDialog(tWndTitle, pDefWndType, "habbo_hobba_compose.window", #eventProcCallHelp)
  tWndObj = getWindow(tWndTitle)
  if pCfhType = #habbo_helpers then
    tTopText = getText("callhelp_explanation")
    tMidText = getText("callhelp_writeyour")
    tBotText = getText("callhelp_example")
  else
    tTopText = getText("help_emergency_explanation")
    tMidText = getText("help_emergency_writeyour")
    tBotText = getText("help_emergency_example")
  end if
  tWndObj.getElement("hobbaalert_top").setText(tTopText)
  tWndObj.getElement("hobbaalert_mid").setText(tMidText)
  tWndObj.getElement("hobbaalert_bottom").setText(tBotText)
  return 1
end

on openCfhWindowWithReportingOptions me
  pReportWindowTitle = "win_callforhelp_with_reports"
  if not createWindow(pReportWindowTitle, "habbo_full.window", 0, 0, #modal) then
    return error(me, "Failed to open Messenger window!!!", #openRemoveWindow, #major)
  end if
  tWndObj = getWindow(pReportWindowTitle)
  if not tWndObj.merge("cfh_flow_with_reporting.window") then
    tWndObj.close()
    return error(me, "Failed to open Messenger window!!!", #openRemoveWindow, #major)
  end if
  pReportedUserSelectionList = getObject(#session).get("reportable_users").duplicate()
  repeat with i = 1 to pReportedUserSelectionList.count
    pReportedUserSelectionList[i].addProp(#selected, 0)
  end repeat
  pReportPageCount = pReportedUserSelectionList.count / pTotalReportableUsers
  if (pReportedUserSelectionList.count mod pTotalReportableUsers) <> 0 then
    pReportPageCount = pReportPageCount + 1
  end if
  me.arrangeReportUsers()
  tCfhCategories = getObject(#session).get("cfh_categories")
  tCategoryText = []
  tCategoryIdentifier = []
  repeat with i = 1 to tCfhCategories.count
    tCategoryText[i] = getText("help.cfh.reason." & tCfhCategories[i].name)
    tCategoryIdentifier[i] = tCfhCategories[i].name
  end repeat
  tCfhCategoriesDropMenu = tWndObj.getElement("dropmenu_cfh_categories")
  tCfhCategoriesDropMenu.updateData(tCategoryText, tCategoryIdentifier, 1)
  tCfhCategoriesDropMenu.setOrdering(0)
  me.updateCfhTopicDropDown(tCfhCategories[1].name)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcCallForHelpWithReportingWindow, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcCallForHelpWithReportingWindow, me.getID(), #mouseDown)
  pWindowList.add(pReportWindowTitle)
  return 1
end

on updateCfhTopicDropDown me, categoryName
  if not windowExists(pReportWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pReportWindowTitle)
  tTopicTexts = []
  tTopicyIdentifiers = []
  tCfhTopics = me.findTopicsByCategoryName(categoryName)
  repeat with i = 1 to tCfhTopics.count
    tTopicTexts[i] = getText("help.cfh.topic." & tCfhTopics[i].topicId)
    tTopicyIdentifiers[i] = tCfhTopics[i].topicId
  end repeat
  tCfhCategoriesDropMenu = tWndObj.getElement("dropmenu_cfh_topics")
  tCfhCategoriesDropMenu.updateData(tTopicTexts, tTopicyIdentifiers, 1)
  tCfhCategoriesDropMenu.setOrdering(0)
end

on findTopicsByCategoryName me, categoryName
  tCfhCategories = getObject(#session).get("cfh_categories")
  repeat with i = 1 to tCfhCategories.count
    if tCfhCategories[i].name = categoryName then
      return tCfhCategories[i].topics
    end if
  end repeat
  return VOID
end

on arrangeReportUsers me
  tNewList = [:]
  tTemp = the itemDelimiter
  the itemDelimiter = "-"
  repeat with i = 1 to pReportedUserSelectionList.count
    tNewList.addProp(pReportedUserSelectionList[i].name, pReportedUserSelectionList[i])
  end repeat
  pReportedUserSelectionList.sort()
  the itemDelimiter = tTemp
  pReportedUserSelectionList = tNewList.duplicate()
  pReportPageNr = 1
  me.updateReportView()
  return 1
end

on updateReportView me
  if not windowExists(pReportWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pReportWindowTitle)
  tStartNr = (pReportPageNr - 1) * pTotalReportableUsers
  repeat with i = 1 to pTotalReportableUsers
    tElem1ID = "cfh_report_target" & i
    tElem2ID = "friendremove_checkbox" & i
    tElem1 = tWndObj.getElement(tElem1ID)
    tElem2 = tWndObj.getElement(tElem2ID)
    if (tStartNr + i) > pReportedUserSelectionList.count then
      tElem1.hide()
      tElem2.hide()
      next repeat
    end if
    tElem1.show()
    tElem2.show()
    tElem1.setText(pReportedUserSelectionList[tStartNr + i].name)
    if not pReportedUserSelectionList[tStartNr + i].selected then
      pReportedUserCheckBoxList[i] = 0
      me.updateCheckButton(tElem2ID, "button.checkbox.off")
      next repeat
    end if
    pReportedUserCheckBoxList[i] = 1
    me.updateCheckButton(tElem2ID, "button.checkbox.on")
  end repeat
  tElem = tWndObj.getElement("report_user_continue_button")
  tElem.Activate()
end

on unselectAllReportableUsers me
  repeat with i = 1 to pTotalReportableUsers
    tElem2ID = "friendremove_checkbox" & i
    pReportedUserCheckBoxList[i] = 0
    me.updateCheckButton(tElem2ID, "button.checkbox.off")
  end repeat
  repeat with i = 1 to pReportedUserSelectionList.count
    pReportedUserSelectionList[i].selected = 0
  end repeat
end

on selectReportedUser me, tElementId
  if not windowExists(pReportWindowTitle) then
    return 0
  end if
  tPrefixLength = length("friendremove_checkbox") + 1
  tNum = integer(tElementId.char[tPrefixLength..tElementId.char.count])
  tStartNr = (pReportPageNr - 1) * pTotalReportableUsers
  tBoxID = "friendremove_checkbox" & tNum
  if pReportedUserCheckBoxList[tNum] = 0 then
    me.unselectAllReportableUsers()
    pReportedUserCheckBoxList[tNum] = 1
    pReportedUserSelectionList[tStartNr + tNum].selected = 1
    pChosen = 1
    me.updateCheckButton(tBoxID, "button.checkbox.on")
  else
    pReportedUserCheckBoxList[tNum] = 0
    pReportedUserSelectionList[tStartNr + tNum].selected = 0
    pChosen = 0
    me.updateCheckButton(tBoxID, "button.checkbox.off")
  end if
  tWndObj = getWindow(pReportWindowTitle)
  tElem = tWndObj.getElement("report_user_continue_button")
  if pChosen then
    tElem.Activate()
  else
    tElem.deactivate()
  end if
end

on selectReportedchatLine me, tElementId
  if not windowExists(pReportWindowTitle) then
    return 0
  end if
  tPrefixLength = length("chatselection_checkbox") + 1
  tNum = integer(tElementId.char[tPrefixLength..tElementId.char.count])
  tStartNr = (pReportPageNr - 1) * pTotalReportableChatLines
  tBoxID = "chatselection_checkbox" & tNum
  if pReportedChatCheckBoxList[tNum] = 0 then
    tCurrentRoomID = pReportedChatSelectionList[tStartNr + tNum].roomId
    me.unselectChatLinesNotInProvidedRoomId(tCurrentRoomID)
    pReportedChatCheckBoxList[tNum] = 1
    pReportedChatSelectionList[tStartNr + tNum].selected = 1
    pReportedChatSelectionList[tStartNr + tNum].roomId = tCurrentRoomID
    me.updateCheckButton(tBoxID, "button.checkbox.on")
    pChosen = 1
  else
    pReportedChatCheckBoxList[tNum] = 0
    pReportedChatSelectionList[tStartNr + tNum].selected = 0
    pReportedChatSelectionList[tStartNr + tNum].roomId = -1
    me.updateCheckButton(tBoxID, "button.checkbox.off")
    pChosen = 0
  end if
  tWndObj = getWindow(pReportWindowTitle)
  tElem = tWndObj.getElement("report_chat_continue_button")
  if pChosen then
    tElem.Activate()
  else
    tElem.deactivate()
  end if
end

on unselectChatLinesNotInProvidedRoomId me, tRoomID
  tWndObj = getWindow(pReportWindowTitle)
  tStartNr = (pReportPageNr - 1) * pTotalReportableChatLines
  repeat with i = 1 to count(pReportedChatSelectionList)
    if (pReportedChatSelectionList[i].selected = 1) and (pReportedChatSelectionList[i].roomId <> tRoomID) then
      pReportedUserCheckBoxList[i] = 0
      pReportedUserSelectionList[tStartNr + i].selected = 0
      tElementId = "chatselection_checkbox" & i
      if tWndObj.elementExists(tElementId) then
        me.updateCheckButton("chatselection_checkbox" & i, "button.checkbox.off")
      end if
    end if
  end repeat
end

on showChatSelectionWindow me
  tReportedUser = EMPTY
  repeat with i = 1 to pReportedUserSelectionList.count
    if pReportedUserSelectionList[i].selected then
      tReportedUser = pReportedUserSelectionList[i].name
    end if
  end repeat
  if tReportedUser = EMPTY then
    me.ShowAlert([#msg: "help.cfh.error.nochathistory"])
    return 0
  end if
  tWndObj = getWindow(pReportWindowTitle)
  pReportTopicId = tWndObj.getElement("dropmenu_cfh_topics").getSelection()
  tWndObj.unmerge()
  if not tWndObj.merge("cfh_flow_with_reporting_2.window") then
    return tWndObj.close()
  end if
  tChatHistory = me.getChatHistoryForUser(tReportedUser)
  if count(tChatHistory) > 0 then
    tNewList = [:]
    repeat with i = 1 to count(tChatHistory)
      tNewList.addProp("chatLine" & i, [#content: tChatHistory[i].chatLine, #selected: 0, #roomId: tChatHistory[i].roomId])
    end repeat
    pReportedChatSelectionList = tNewList.duplicate()
    tStartNr = (pReportPageNr - 1) * pTotalReportableChatLines
    repeat with i = 1 to pTotalReportableChatLines
      tElem1ID = "cfh_chat_target" & i
      tElem2ID = "chatselection_checkbox" & i
      tElem1 = tWndObj.getElement(tElem1ID)
      tElem2 = tWndObj.getElement(tElem2ID)
      if (tStartNr + i) > tChatHistory.count then
        tElem1.hide()
        tElem2.hide()
        next repeat
      end if
      tElem1.show()
      tElem2.show()
      tElem1.setText(tChatHistory[tStartNr + i].chatLine)
      if not pReportedChatSelectionList[tStartNr + i].selected then
        pReportedChatCheckBoxList[i] = 0
        me.updateCheckButton(tElem2ID, "button.checkbox.off")
        next repeat
      end if
      pReportedChatCheckBoxList[i] = 1
      me.updateCheckButton(tElem2ID, "button.checkbox.on")
    end repeat
  else
    me.ShowAlert([#msg: "help.cfh.error.nochathistory"])
    return tWndObj.close()
  end if
end

on showFreeInputTextWindow me
  tWndObj = getWindow(pReportWindowTitle)
  tWndObj.unmerge()
  if not tWndObj.merge("cfh_flow_with_reporting_3.window") then
    return tWndObj.close()
  end if
  tWndObj.getElement("cfh_report_text_top").setText(getText("help_emergency_explanation"))
  tWndObj.getElement("cfh_report_text_middle").setText(getText("help_emergency_writeyour"))
  tWndObj.getElement("cfh_report_text_bottom").setText(getText("help_emergency_example"))
end

on sendCallForHelpWithReporting me
  tWndObj = getWindow(pReportWindowTitle)
  tReportText = tWndObj.getElement("callhelp_text").getText()
  tReportedUser = EMPTY
  repeat with i = 1 to pReportedUserSelectionList.count
    if pReportedUserSelectionList[i].selected then
      tReportedUser = pReportedUserSelectionList[i].name
    end if
  end repeat
  if tReportedUser = EMPTY then
    me.ShowAlert([#msg: "help.cfh.error.nochathistory"])
    return 0
  end if
  tReportedRoomId = -1
  tSelectedChatList = []
  tCount = pReportedChatSelectionList.count
  repeat with i = 1 to tCount
    tKey = pReportedChatSelectionList.getPropAt(i)
    tItem = pReportedChatSelectionList[tKey]
    if ilk(tItem, #propList) and (tItem.getaProp(#selected) = 1) then
      tSelectedChatList.add(tItem.getaProp(#content))
      if tReportedRoomId = -1 then
        tReportedRoomId = tItem.getaProp(#roomId)
      end if
    end if
  end repeat
  if tSelectedChatList.count = 0 then
    me.ShowAlert([#msg: "help.cfh.error.nochathistory"])
    return 0
  end if
  executeMessage(#sendCallForHelpWithReporting, [#topicId: pReportTopicId, #reportedRoomId: tReportedRoomId, #reportedUser: tReportedUser, #reportText: tReportText, #selectedChat: tSelectedChatList])
  me.showAlertSentWindow(tWndObj)
end

on getChatHistoryForUser me, userName
  tReportableUsers = getObject("session").get("reportable_users")
  repeat with i = 1 to count(tReportableUsers)
    if tReportableUsers[i][#name] = userName then
      return me.reverseList(tReportableUsers[i][#chatLines])
    end if
  end repeat
  return []
end

on reverseList me, tList
  tReversedList = []
  repeat with i = count(tList) down to 1
    tReversedList.append(tList[i])
  end repeat
  return tReversedList
end

on updateCheckButton me, tElementId, tMemName
  if not windowExists(pReportWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pReportWindowTitle)
  tNewImg = member(getmemnum(tMemName)).image
  if tWndObj.elementExists(tElementId) then
    tWndObj.getElement(tElementId).feedImage(tNewImg)
  end if
  return 1
end

on openHelpChoiceWindow me
  if pHelpChoiceCount = 0 then
    pCfhType = #emergency
    return me.showDialog("call_for_help")
  end if
  tWndTitle = getText("win_callforhelp")
  if windowExists(tWndTitle) then
    return me.removeDialog(tWndTitle, pWindowList)
  end if
  me.createDialog(tWndTitle, "habbo_full.window", "habbo_help_choise.window", #eventProcHelp)
  tWndObj = getWindow(tWndTitle)
  if getMember("button.radio.off").type <> #bitmap then
    return 0
  end if
  repeat with i = 1 to pHelpChoiceCount
    tRadioImg = getMember("button.radio.off").image
    tText = getText("help_option_" & i)
    if tText <> ("help_option_" & i) then
      tWndObj.getElement("help_option_" & i).setText(tText)
      tWndObj.getElement("help_radio_" & i).feedImage(tRadioImg)
    end if
  end repeat
  tWndObj.getElement("help_choise_ok").deactivate()
  return 1
end

on helpChoiceMade me
  if pChosenHelpRadio = 0 then
    return 0
  end if
  tAction = getText("help_pointer_" & pChosenHelpRadio)
  if tAction starts "http" then
    openNetPage(tAction)
    return me.removeDialog(getText("win_callforhelp"), pWindowList)
  end if
  if tAction = "hotel_help" then
    pCfhType = #habbo_helpers
    return me.showDialog("call_for_help")
  else
    if tAction = "emergency_help" then
      pCfhType = #emergency
      return me.showDialog("call_for_help")
    end if
  end if
  return error(me, "Help pointer " & pChosenHelpRadio & " not working, check syntax.", #helpChoiceMade)
end

on helpRadioClicked me, tChoiceNum, tWndID
  if not memberExists("button.radio.on") then
    return 0
  end if
  tRadioOnImg = getMember("button.radio.on").image
  tRadioOffImg = getMember("button.radio.off").image
  tWnd = getWindow(tWndID)
  if not tWnd.elementExists("help_radio_" & pHelpChoiceCount) then
    return 0
  end if
  repeat with i = 1 to pHelpChoiceCount
    tElem = tWnd.getElement("help_radio_" & i)
    if i = tChoiceNum then
      tElem.feedImage(tRadioOnImg)
      next repeat
    end if
    tElem.feedImage(tRadioOffImg)
  end repeat
  tWnd.getElement("help_choise_ok").Activate()
  pChosenHelpRadio = tChoiceNum
  return 1
end

on eventProcAlert me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "alert_ok", "close":
        return me.removeDialog(tWndID, pAlertList)
    end case
  end if
end

on eventProcPurse me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "close", "purse_close":
        return executeMessage(#hide_purse)
      "purse_link_text":
        tSession = getObject(#session)
        if tSession.get("user_rights").getOne("can_buy_credits") then
          tURL = getText("url_purselink")
        else
          tURL = getText("url_purse_subscribe")
        end if
        tURL = tURL & urlEncode(tSession.get("user_name"))
        if tSession.exists("user_checksum") then
          tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
        end if
        openNetPage(tURL, "_new")
    end case
  end if
end

on eventProcHelp me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "link_list":
        tLineNum = (tParam[2] / 14) + 1
        if textExists("url_help_" & tLineNum) then
          tSession = getObject(#session)
          tURL = getText("url_help_" & tLineNum)
          tName = urlEncode(tSession.get("user_name"))
          if tURL = EMPTY then
            return 1
          end if
          if tURL contains "\user_name" then
            tURL = replaceChunks(tURL, "\user_name", tName)
            if tSession.exists("user_checksum") then
              tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
            end if
          end if
          openNetPage(tURL, "_new")
        end if
        return 1
      "close", "help_ok", "help_choise_cancel":
        return me.removeDialog(tWndID, pWindowList)
      "help_tutorial_link":
        openNetPage(getText("reg_tutorial_url", "_new"))
      "help_callforhelp_textlink":
        me.removeDialog(tWndID, pWindowList)
        me.showDialog(#help_choice)
        return 1
      "help_choise_ok":
        me.helpChoiceMade()
      otherwise:
        if stringp(tElemID) then
          if tElemID.char[1..11] = "help_radio_" then
            me.helpRadioClicked(tElemID.char[12], tWndID)
          end if
        end if
    end case
  end if
end

on eventProcCallHelp me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "close", "callhelp_cancel", "alertsent_ok":
        return me.removeDialog(tWndID, pWindowList)
      "callhelp_send":
        tWndObj = getWindow(tWndID)
        executeMessage(#sendCallForHelp, tWndObj.getElement("callhelp_text").getText(), pCfhType)
        me.showAlertSentWindow(tWndObj)
        return 1
    end case
  end if
end

on eventProcBan me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "alert_ok", "close":
        me.removeDialog(tWndID, pAlertList)
        resetClient()
    end case
  end if
end

on eventProcCallForHelpWithReportingWindow me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "close", "callhelp_cancel", "alertsent_ok", "report_cancel_button":
        me.removeDialog(pReportWindowTitle, pWindowList)
        if windowExists(pReportWindowTitle) then
          tWndObj = getWindow(pReportWindowTitle)
          tWndObj.close()
        end if
      "dropmenu_cfh_categories":
        me.updateCfhTopicDropDown(tParam)
      "report_user_continue_button":
        me.showChatSelectionWindow()
      "report_chat_continue_button":
        me.showFreeInputTextWindow()
      "report_send_button":
        me.sendCallForHelpWithReporting()
    end case
    tLen = tElemID.char.count
    if tLen > 2 then
      if tElemID.char[1..21] = "friendremove_checkbox" then
        me.selectReportedUser(tElemID)
      end if
      if tElemID.char[1..22] = "chatselection_checkbox" then
        me.selectReportedchatLine(tElemID)
      end if
    end if
  end if
  if tEvent = #mouseDown then
    case tElemID of
    end case
  end if
end
