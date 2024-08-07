property pHubuWndID, pTimerStart, pTimerBarHeight, pTimerBarLocY

on construct me
  pHubuWndID = getText("hubu_win", "Hubu")
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  if windowExists(pHubuWndID) then
    removeWindow(pHubuWndID)
  end if
  return 1
end

on showBusClosed me, tMsg
  if windowExists(pHubuWndID) then
    removeWindow(pHubuWndID)
  end if
  createWindow(pHubuWndID, "habbo_basic.window")
  tWndObj = getWindow(pHubuWndID)
  tWndObj.merge("hubu_bus_notopen.window")
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcHubu, me.getID(), #mouseUp)
  tWndObj.getElement("hubunote_txt").setText(tMsg)
  if not (getText("hubu_info_url_1") starts "http://") then
    tWndObj.getElement("hubu_info_link1").setProperty(#visible, 0)
  end if
  if not (getText("hubu_info_url_2") starts "http://") then
    tWndObj.getElement("hubu_info_link2").setProperty(#visible, 0)
  end if
  return 1
end

on hideVoteScreen
  if windowExists(pHubuWndID) then
    removeWindow(pHubuWndID)
  end if
end

on showVoteQuestion me, tQuestion, tChoiceList
  if windowExists(pHubuWndID) then
    removeWindow(pHubuWndID)
  end if
  createWindow(pHubuWndID, "hubu_poll.window")
  tWndObj = getWindow(pHubuWndID)
  tWndObj.moveTo(6, 306)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcHubu, me.getID(), #mouseUp)
  tWndObj.getElement("hubu_q").setText(tQuestion)
  repeat with i = 1 to tChoiceList.count
    tWndObj.getElement("hubu_a" & i).setText(tChoiceList[i])
    tWndObj.getElement("button_" & i).setProperty(#blend, 100)
  end repeat
  pTimerStart = the milliSeconds
  pTimerBarHeight = tWndObj.getElement("time_bar").getProperty(#height)
  pTimerBarLocY = tWndObj.getElement("time_bar").getProperty(#locY)
  receiveUpdate(me.getID())
  return 1
end

on showVoteWait me
  tWndObj = getWindow(pHubuWndID)
  repeat with i = 1 to 6
    tWndObj.getElement("button_" & i).setProperty(#blend, 50)
  end repeat
  return 1
end

on showVoteResults me, tTotalVotes, tVoteResults
  removeUpdate(me.getID())
  if not windowExists(pHubuWndID) then
    return error(me, "Vote window is closed!", #showVoteResults)
  end if
  tWndObj = getWindow(pHubuWndID)
  tCurrentQuestionText = tWndObj.getElement("hubu_q").getText()
  tWndObj.getElement("hubu_q").setText("(" & tTotalVotes & " Votes) " & tCurrentQuestionText)
  tWndObj.getElement("time_bar_bg").hide()
  tWndObj.getElement("time_bar").hide()
  tWndObj.getElement("hubu_time").hide()
  tWndObj.getElement("hubu_statusbar").setText(EMPTY)
  repeat with i = 1 to tVoteResults.count
    tVoteCount = tVoteResults[i]
    if tTotalVotes > 0 then
      tPercentage = tVoteCount / tTotalVotes * 100
      tPercentage = float(integer((tPercentage * 100) + 0.5)) / 100
    else
      tPercentage = 0
    end if
    tPercentageStr = string(tPercentage)
    tDotPosition = offset(".", tPercentageStr)
    if tDotPosition = 0 then
      tPercentageStr = tPercentageStr & ".00"
    else
      tDecimals = length(tPercentageStr) - tDotPosition
      if tDecimals < 2 then
        tPercentageStr = tPercentageStr & "0"
      end if
    end if
    tDisplayText = string(integer(tPercentage)) & "%" && "(" & string(tVoteCount) & ")"
    tWndObj.getElement("hubu_res_" & i).setProperty(#blend, 100)
    tWndObj.getElement("hubu_res_" & i).setText(tDisplayText)
    tW = tWndObj.getElement("hubu_answ_" & i).getProperty(#width)
    if tTotalVotes > 0 then
      tWndObj.getElement("hubu_answ_" & i).setProperty(#width, tW * tPercentage / 100)
    else
      tWndObj.getElement("hubu_answ_" & i).setProperty(#width, 0)
    end if
    tWndObj.getElement("hubu_answ_" & i).setProperty(#blend, 100)
  end repeat
  return 1
end

on update me
  tWndObj = getWindow(pHubuWndID)
  if tWndObj = 0 then
    return removeUpdate(me.getID())
  end if
  tTime = float(the milliSeconds - pTimerStart) / 30000.0
  if tTime > 1.0 then
    tTime = 1.0
  end if
  tSecsLeft = integer(30 - (float(the milliSeconds - pTimerStart) * 0.001))
  if tSecsLeft < 0 then
    tSecsLeft = 0
  end if
  tNewHeight = 1 * pTimerBarHeight
  if tNewHeight < 0 then
    tNewHeight = 0
  end if
  tWndObj.getElement("hubu_time").hide()
  tWndObj.getElement("hubu_statusbar").setText(EMPTY)
  tWndObj.getElement("time_bar").setProperty(#height, tNewHeight)
  tWndObj.getElement("time_bar").setProperty(#locY, pTimerBarLocY + pTimerBarHeight - tNewHeight)
end

on eventProcHubu me, tEvent, tSprID, tParam
  if tEvent <> #mouseUp then
    return 0
  end if
  if tSprID = "close" then
    return removeWindow(pHubuWndID)
  else
    if tSprID = "hubu_info_link1" then
      openNetPage(getText("hubu_info_url_1"))
    else
      if tSprID = "hubu_info_link2" then
        openNetPage(getText("hubu_info_url_2"))
      else
        if tSprID contains "button_" then
          if getWindow(pHubuWndID).getElement(tSprID).getProperty(#blend) = 100 then
            me.showVoteWait()
            getThread(#room).getComponent().getRoomConnection().send("VOTE", tSprID.char[length(tSprID)])
          end if
        end if
      end if
    end if
  end if
end
