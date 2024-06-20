on convertSmallFurniNames tCastName
  repeat with i = 1 to the number of castMembers of castLib tCastName
    tMem = member(i, tCastName)
    tHandle = (tMem.type = #field) and (tMem.name contains ".props")
    tHandle = tHandle or ((tMem.type = #bitmap) and not (tMem.name contains "trophyblink"))
    tHandle = tHandle or ((tMem.type = #palette) and not (tMem.name contains "trophyblink"))
    if tHandle then
      put tMem.name
      tMem.name = "s_" & tMem.name
    end if
    tHandle = 0
  end repeat
end

on convertSmallMemberAlias tCastName
  tText = member("memberalias.index", tCastName).text
  tNewText = EMPTY
  repeat with i = 1 to tText.line.count
    tLine = tText.line[i]
    tBreak = offset("=", tLine)
    if tBreak > 1 then
      tLine = "s_" & tLine.char[1..tBreak] & "s_" & tLine.char[tBreak + 1..tLine.length]
    end if
    tNewText = tNewText & tLine & RETURN
  end repeat
  member("memberalias.index", tCastName).text = tNewText
  put tNewText
end

on mergeObjSets
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tCollectedList = [:]
  tChangedCasts = []
  repeat with tCastNum = 1 to the number of castLibs
    repeat with tMemNum = 1 to the number of castMembers of castLib tCastNum
      tMem = member(tMemNum, tCastNum)
      if tMem.type = #field then
        tName = tMem.name
        tDefType = EMPTY
        if tName contains ".zshift" then
          tDefType = #zshift
        end if
        if tName contains ".blend" then
          tDefType = #blend
        end if
        if tName contains ".ink" then
          tDefType = #ink
        end if
        if tDefType <> EMPTY then
          tPart = tName.char[offset(".", tName) - 1]
          delete char -30002 of tName
          if tCollectedList[tName] <> VOID then
            tNewPropsMem = tCollectedList[tName]
            tPropsList = value(field(tNewPropsMem))
          else
            put "creating" && tName
            tNewPropsMem = new(#field, castLib(tCastNum))
            tNewPropsMem.name = tName & ".props"
            tCollectedList.addProp(tName, tNewPropsMem)
            if tChangedCasts.getOne(castLib(tCastNum).name) = 0 then
              tChangedCasts.append(castLib(tCastNum).name)
            end if
            tPropsList = [:]
          end if
          if (tDefType = #ink) or (tDefType = #blend) then
            tThisProp = integer(tMem.text.line[1])
          else
            tThisProp = []
            repeat with i = 1 to tMem.text.line.count
              if (tMem.text.line[i] <> EMPTY) or (i < tMem.text.line.count) then
                tThisProp.append(integer(tMem.text.line[i]))
              end if
            end repeat
          end if
          if tPropsList.getaProp(tPart) = VOID then
            tPropsList.addProp(tPart, [:])
          end if
          tPropsList[tPart].addProp(tDefType, tThisProp)
          tNewPropsMem.text = string(tPropsList)
          tMem.erase()
          next repeat
        end if
      end if
    end repeat
  end repeat
  put "Changed casts:" && tChangedCasts
  the itemDelimiter = tDelim
  return tCollectedList
end

on convJpChars
  tOldStr = member("prohibited_name_chars").text
  tNewStr = EMPTY
  the itemDelimiter = ":"
  repeat with i = 1 to tOldStr.line.count
    tLine = tOldStr.line[i]
    tLine = tLine.item[2]
    tA = 256 * integer(tLine.word[1])
    tB = integer(tLine.word[2])
    tCode = tA + tB
    put tCode & RETURN after tNewStr
  end repeat
  member("prohibited_name_chars").text = tNewStr
end

on changename startnum, endnum, replaceFrom, replaceTo, cl
  repeat with i = startnum to endnum
    oldName = member(i, cl).name
    newName = stringReplace(oldName, replaceFrom, replaceTo)
    member(i, cl).name = newName
  end repeat
end

on stringReplace input, oldStr, newStr
  s = EMPTY
  repeat while input contains oldStr
    posn = offset(oldStr, input) - 1
    if posn > 0 then
      put char 1 to posn of input after s
    end if
    put newStr after s
    delete char 1 to posn + length(oldStr) of input
  end repeat
  put input after s
  return s
end

on resetObject tid
  if not objectExists(tid) then
    return 0
  end if
  tObj = getObject(tid)
  tStr = string(tObj)
  tScriptName = tStr.char[13..offset(QUOTE, tStr.char[14..tStr.length]) + 12]
  tNewObject = new(script(getmemnum(tScriptName)))
  repeat with i = 1 to count(tObj)
    put tNewObject[tObj.getPropAt(i)]
    tNewObject[tObj.getPropAt(i)] = tObj.getaProp(tObj.getPropAt(i))
  end repeat
  getObjectManager().pObjectList[tid] = tNewObject
  return tNewObject
end

on release
  tCastCount = the number of castLibs
  repeat with tCastNum = 1 to tCastCount
    if castLib(tCastNum).name = "bin" then
      repeat with i = 1 to the number of castMembers of castLib tCastNum
        member(i, "bin").erase()
      end repeat
      exit repeat
    end if
  end repeat
  tEmptyCastNum = 1
  repeat with tCastNum = 4 to tCastCount
    tCastName = castLib(tCastNum).name
    castLib(tCastNum).name = "empty" && tEmptyCastNum
    castLib(tCastNum).fileName = the moviePath & "empty" & ".cst"
    tEmptyCastNum = tEmptyCastNum + 1
  end repeat
end

on test
  s = "gsjhfdg dfhg fgkhfdshg"
  repeat with i = 1 to 5
    tTime = the milliSeconds
    repeat with j = 1 to 1000000
      v = s.char[4..12]
    end repeat
    tTime = the milliSeconds - tTime
    put tTime
  end repeat
  put EMPTY
  s = "gsjhfdg dfhg fgkhfdshg"
  repeat with i = 1 to 5
    tTime = the milliSeconds
    repeat with j = 1 to 1000000
      v = char 4 to 12 of s
    end repeat
    tTime = the milliSeconds - tTime
    put tTime
  end repeat
end

on fixErrorCallHandlers
  tHandlerCall = "error(me,"
  tPutAllLines = 0
  tCurrentHandler = VOID
  repeat with tCastLib = 1 to the number of castLibs
    tMemberAmount = the number of castMembers of castLib tCastLib
    repeat with i = 1 to tMemberAmount
      if member(i, tCastLib).type = #script then
        tText = member(i, tCastLib).scriptText
        repeat with j = 1 to tText.line.count
          tLine = tText.line[j]
          if (tLine.word[1] = "on") and (tLine.char[1..3] = "on ") then
            tCurrentHandler = tLine.word[2]
            next repeat
          end if
          if (tLine.word[1] = "end") and (tLine.word.count = 1) then
            tCurrentHandler = VOID
            next repeat
          end if
          if tLine contains tHandlerCall then
            if tLine contains "--" then
              put RETURN & "###" & member(i, tCastLib).name && "/" && tCurrentHandler && "/" && tLine & RETURN
              next repeat
            end if
            repeat while tLine.char[length(tLine)] = EMPTY
              tLine = tLine.char[1..length(tLine) - 1]
            end repeat
            if tLine.char[length(tLine)] = ")" then
              tLine = tLine.char[1..length(tLine) - 1]
              if voidp(tCurrentHandler) then
                put RETURN & "###" && member(i, tCastLib).name && "/" && tCurrentHandler && "/" && tLine & RETURN
                next repeat
              end if
              if tLine.word[tLine.word.count] <> ("#" & tCurrentHandler) then
                tLine = tLine & "," && "#" & tCurrentHandler
              end if
              tLine = tLine & ")"
              if tPutAllLines then
                put tLine
              end if
              put tLine into tText.line[j]
            end if
          end if
        end repeat
        member(i, tCastLib).scriptText = tText
      end if
    end repeat
  end repeat
end
