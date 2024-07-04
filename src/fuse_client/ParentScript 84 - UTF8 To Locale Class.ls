property pUnicodeValues, pLocaleValues, pLocaleFormat

on construct me
  pUnicodeValues = [:]
  pLocaleValues = [:]
  pLocaleFormat = EMPTY
end

on defineLocale me, tLocaleFormat
  if (tLocaleFormat <> "sjis") and (tLocaleFormat <> "windows-1251") then
    return error(me, "Invalid locale format:" && tLocaleFormat, #defineLocale, #major)
  end if
  pLocaleFormat = tLocaleFormat
  tResult = me.createCharacterConversionArrays(tLocaleFormat)
  pUnicodeValues = tResult["unicode_values"]
  pLocaleValues = tResult["locale_values"]
end

on convertToUnicode me, tStr
  if (pUnicodeValues.count = 0) or (pLocaleValues.count = 0) then
    return 0
  end if
  tUnicodeData = []
  repeat with i = 1 to tStr.length
    tChar = tStr.char[i]
    tValue = charToNum(tChar)
    tUnicodeValue = 0
    tIndex = tValue + 1
    if tValue < 128 then
      tUnicodeValue = tValue
    else
      if tIndex <= pUnicodeValues.count then
        tUnicodeValue = pUnicodeValues[tIndex]
      end if
    end if
    if tUnicodeValue > 0 then
      tUnicodeData.add(tUnicodeValue)
      next repeat
    end if
  end repeat
  return tUnicodeData
end

on convertFromUnicode me, tUnicodeData
  if (pUnicodeValues.count = 0) or (pLocaleValues.count = 0) then
    return 0
  end if
  tResult = EMPTY
  repeat with i = 1 to tUnicodeData.count
    tUnicodeValue = tUnicodeData[i]
    tLocaleValue = 0
    tIndex = tUnicodeValue + 1
    if tUnicodeValue < 128 then
      tLocaleValue = tUnicodeValue
    else
      if tIndex <= pLocaleValues.count then
        tLocaleValue = pLocaleValues[tIndex]
      end if
    end if
    if tLocaleValue > 0 then
      tResult = tResult & numToChar(tLocaleValue)
      next repeat
    end if
  end repeat
  return tResult
end

on generateStringFromUTF8 me, tUTF8Data
  if pLocaleFormat = "windows-1251" then
    return VOID
  end if
  tResult = EMPTY
  i = 1
  repeat while i <= tUTF8Data.count
    tValue = tUTF8Data[i]
    i = i + 1
    if ((tValue >= 129) and (tValue <= 159)) or ((tValue >= 224) and (tValue <= 239)) then
      if i <= tUTF8Data.count then
        tValue = (tValue * 256) + tUTF8Data[i]
        i = i + 1
      else
      end if
    end if
    tResult = tResult & numToChar(tValue)
  end repeat
  return tResult
end

on createCharacterConversionArrays me, tEncodingFormat
  tUnicodeValues = []
  tLocaleValues = []
  tText = EMPTY
  case tEncodingFormat of
    "sjis":
      tText = member("Shift JIS to Unicode map").text
    "windows-1251":
      tText = member("Windows-1251 to Unicode map").text
  end case
  if ilk(tText) = #string then
    tLineCount = the number of lines in tText
    tChunkSize = 100
    tChunkCount = tLineCount / tChunkSize
    if (tLineCount mod tChunkSize) <> 0 then
      tChunkCount = tChunkCount + 1
    end if
    repeat with j = 1 to tChunkCount
      tFirstLineIndex = 1 + ((j - 1) * tChunkSize)
      tLastLineIndex = tFirstLineIndex + tChunkSize - 1
      tSubText = tText.line[tFirstLineIndex..tLastLineIndex]
      tSubLineCount = the number of lines in tSubText
      repeat with i = 1 to tSubLineCount
        tLine = line 1 of tSubText
        delete line 1 of tSubText
        tValueLocale = word 1 of tLine
        if tValueLocale.char[1..2] = "0x" then
          tValueUnicode = word 2 of tLine
          tValueLocale = tValueLocale.char[3..tValueLocale.length]
          if tValueUnicode.char[1..2] = "0x" then
            tValueUnicode = tValueUnicode.char[3..tValueUnicode.length]
            tValueUnicode = me.hexToInt(tValueUnicode)
            tValueLocale = me.hexToInt(tValueLocale)
            tUnicodeValues[tValueLocale + 1] = tValueUnicode
            tLocaleValues[tValueUnicode + 1] = tValueLocale
          end if
        end if
      end repeat
    end repeat
  end if
  return ["unicode_values": tUnicodeValues, "locale_values": tLocaleValues]
end

on hexToInt me, tStr
  tValue = 0
  repeat with i = 1 to tStr.length
    tValue = tValue * 16
    tChar = tStr.char[i]
    tVal = value(tChar)
    if voidp(tVal) then
      if tChar = "a" then
        tVal = 10
      else
        if tChar = "b" then
          tVal = 11
        else
          if tChar = "c" then
            tVal = 12
          else
            if tChar = "d" then
              tVal = 13
            else
              if tChar = "e" then
                tVal = 14
              else
                if tChar = "f" then
                  tVal = 15
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    tValue = tValue + tVal
  end repeat
  return tValue
end
