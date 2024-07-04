property pTableStr, pTableList, pLineMaxLength, pLineBreak, pPaddingChar

on construct me
  pLineMaxLength = 72
  pLineBreak = RETURN
  pPaddingChar = "="
  pTableStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  pTableList = [:]
  repeat with tNum = 1 to pTableStr.length
    pTableList.addProp(pTableStr.char[tNum], tNum)
  end repeat
  return 1
end

on deconstruct me
  pTableStr = VOID
  pTableList = VOID
  return 1
end

on encode me, tStr
  tOutputStr = EMPTY
  tLineCharCount = 0
  repeat with tOffset = 1 to tStr.length
    tChars = me.encodeBlock(tStr.char[tOffset..tOffset + 2])
    if tChars.length < 3 then
      tChars = tChars & pPaddingChar
    end if
    if tChars.length < 4 then
      tChars = tChars & pPaddingChar
    end if
    tOutputStr = tOutputStr & tChars
    tLineCharCount = tLineCharCount + 4
    if (tLineCharCount >= pLineMaxLength) and (pLineMaxLength > 0) then
      tOutputStr = tOutputStr & pLineBreak
      tLineCharCount = 0
    end if
    tOffset = tOffset + 2
    if tOffset > tStr.length then
      exit repeat
    end if
  end repeat
  return tOutputStr
end

on decode me, tStr
  repeat while tStr contains pPaddingChar
    tStr = tStr.char[1..offset(pPaddingChar, tStr) - 1]
  end repeat
  repeat while tStr contains pLineBreak
    tOffset = offset(pLineBreak, tStr)
    tStr = tStr.char[1..tOffset - 1] & tStr.char[tOffset + 1..tStr.length]
  end repeat
  tOutputStr = EMPTY
  repeat with tOffset = 1 to tStr.length
    tBytes = tStr.length - (tOffset - 1)
    if tBytes > 4 then
      tBytes = 4
    end if
    if tBytes < 2 then
      exit repeat
    end if
    tChars = me.decodeBlock(tStr.char[tOffset..tOffset + tBytes - 1])
    tOutputStr = tOutputStr & tChars
    tOffset = tOffset + (tBytes - 1)
  end repeat
  return tOutputStr
end

on encodeBlock me, tStr
  tNum1 = charToNum(tStr.char[1])
  tNum2 = charToNum(tStr.char[2])
  tNum3 = charToNum(tStr.char[3])
  tByte1 = bitAnd(tNum1, 252) / 4
  tByte2a = bitAnd(tNum1, 3) * 16
  tByte2b = bitAnd(tNum2, 240) / 16
  tByte2 = bitOr(tByte2a, tByte2b)
  tOutputStr = pTableStr.char[tByte1 + 1] & pTableStr.char[tByte2 + 1]
  if tStr.length > 1 then
    tByte3a = bitAnd(tNum2, 15) * 4
    tByte3b = bitAnd(tNum3, 192) / 64
    tByte3 = bitOr(tByte3a, tByte3b)
    tOutputStr = tOutputStr & pTableStr.char[tByte3 + 1]
  end if
  if tStr.length > 2 then
    tByte4 = bitAnd(tNum3, 63)
    tOutputStr = tOutputStr & pTableStr.char[tByte4 + 1]
  end if
  return tOutputStr
end

on decodeBlock me, tStr
  tNum1 = pTableList[tStr.char[1]] - 1
  tNum2 = pTableList[tStr.char[2]] - 1
  tByte1a = tNum1 * 4
  tByte1b = bitAnd(tNum2, 48) / 16
  tByte1 = bitOr(tByte1a, tByte1b)
  tOutputStr = numToChar(tByte1)
  if tStr.length > 2 then
    tNum3 = pTableList[tStr.char[3]] - 1
    tByte2a = bitAnd(tNum2, 15) * 16
    tByte2b = bitAnd(tNum3, 60) / 4
    tByte2 = bitOr(tByte2a, tByte2b)
    tOutputStr = tOutputStr & numToChar(tByte2)
  end if
  if tStr.length > 3 then
    tNum4 = pTableList[tStr.char[4]] - 1
    tByte3a = bitAnd(tNum3, 3) * 64
    tByte3b = bitAnd(tNum4, 63)
    tByte3 = bitOr(tByte3a, tByte3b)
    tOutputStr = tOutputStr & numToChar(tByte3)
  end if
  return tOutputStr
end
