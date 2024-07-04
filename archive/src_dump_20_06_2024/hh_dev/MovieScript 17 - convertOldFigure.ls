on convertOldFigure tFigure, tsex, tName
  put "OLD FIGURE", tName
  if voidp(tsex) then
    tsex = "male"
  end if
  if (tsex = "f") or (tsex = "female") then
    tsex = "female"
  else
    tsex = "male"
  end if
  tFigureIds = member("figure_ids_" & tsex).text
  tValidPartProps = [:]
  ttempProp = VOID
  tPartId = VOID
  ttempColor = [:]
  repeat with f = 1 to tFigureIds.line.count
    tLine = tFigureIds.line[f]
    if (tLine.char[1] <> "*") and (tLine.char.count > 7) then
      the itemDelimiter = ":"
      if not voidp(ttempProp) then
        ttempColor.addProp(tLine.item[2], tLine.item[1])
      end if
      if voidp(ttempColor["partid"]) then
        ttempColor.addProp("partid", tPartId)
      end if
      next repeat
    end if
    if tLine.char[1] = "*" then
      if not voidp(ttempProp) and (ttempColor <> [:]) then
        tValidPartProps.addProp(ttempProp, ttempColor)
      end if
      ttempColor = [:]
      the itemDelimiter = "/"
      tPartId = tLine.item[2].char[8..tLine.item[2].char.count]
      ttempProp = tLine.item[3]
      if tLine.item.count > 3 then
        repeat with tMultiParts = 4 to tLine.item.count
          ttempProp = ttempProp & "/" & tLine.item[tMultiParts]
        end repeat
      end if
    end if
  end repeat
  tNewFigure = [:]
  repeat with tPart in ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"]
    if not voidp(tFigure[tPart]) then
      if not voidp(tFigure[tPart]["model"]) then
        tmodel = tFigure[tPart]["model"]
      else
        tmodel = "not found part" && tPart
      end if
    else
      tmodel = "not found part" && tPart
      tFigure[tPart] = [:]
    end if
    if not voidp(tFigure[tPart]) then
      if not voidp(tFigure[tPart]["color"]) then
        tColor = tFigure[tPart]["color"]
      else
        tColor = "not found part color" && tPart
      end if
    else
      tColor = "not found part color" && tPart
    end if
    tPartId = "not found part id" && tPart
    case tPart of
      "ls", "ch", "rs":
        if voidp(tFigure["ls"]) or voidp(tFigure["ch"]) or voidp(tFigure["rs"]) then
          tmodel = "ch=1/ls=1/rs=1"
        else
          tmodel = "ch=" & value(tFigure["ch"]["model"]) & "/ls=" & value(tFigure["ls"]["model"]) & "/rs=" & value(tFigure["rs"]["model"])
        end if
        tMultiPart = "ch"
        tPartId = tmodel
      "hd", "ey", "fc", "bd", "lh", "rh":
        if voidp(tFigure["hd"]) or voidp(tFigure["ey"]) or voidp(tFigure["fc"]) or voidp(tFigure["bd"]) or voidp(tFigure["lh"]) or voidp(tFigure["rh"]) then
          tmodel = "hd=1/ey=1/fc=1"
        else
          tmodel = "hd=" & value(tFigure["hd"]["model"]) & "/ey=" & value(tFigure["ey"]["model"]) & "/fc=" & value(tFigure["fc"]["model"])
        end if
        tMultiPart = "hd"
        tPartId = tmodel
      otherwise:
        if not (tmodel contains "not found") then
          tPartId = tPart & "=" & value(tmodel)
        end if
    end case
    if not voidp(tValidPartProps[tPartId]) then
      tValidColors = tValidPartProps[tPartId]
      tValidPartId = tValidColors["partid"]
      if tColor.ilk = #color then
        if not voidp(tValidColors[tColor.hexString()]) then
          if voidp(tNewFigure[tPart]) and not voidp(tValidPartId) then
            tNewFigure.addProp(tPart, ["model": tValidPartId, "color": tValidColors[tColor.hexString()]])
          end if
        else
          if tPart <> "ey" then
            put "COLOR NOT FOUND" && tPart, tColor
          end if
          if voidp(tNewFigure[tPart]) then
            tNewFigure.addProp(tPart, ["model": tValidPartId, "color": tValidColors[1]])
          end if
        end if
      else
        if voidp(tNewFigure[tPart]) then
          tNewFigure.addProp(tPart, ["model": tValidPartId, "color": tValidColors[1]])
        end if
      end if
      next repeat
    end if
    tValidPartId = tValidPartProps[1]["partid"]
    if voidp(tNewFigure[tPart]) then
      tNewFigure.addProp(tPart, ["model": tValidPartId, "color": tValidPartProps[1][1]])
    end if
  end repeat
  tFigureToServer = EMPTY
  tTempFigure = [:]
  repeat with f = 1 to tNewFigure.count
    tFpart = tNewFigure.getPropAt(f)
    case tFpart of
      "ls", "rs", "ey", "fc", "bd", "lh", "rh":
      otherwise:
        tTempFigure.addProp(tNewFigure[tFpart]["model"], tNewFigure[tFpart]["color"])
        if f <> tNewFigure.count then
          tFigureToServer = tFigureToServer & tNewFigure[tFpart]["model"] & "=" & tNewFigure[tFpart]["color"] & "/"
        else
          tFigureToServer = tFigureToServer & tNewFigure[tFpart]["model"] & "=" & tNewFigure[tFpart]["color"]
        end if
    end case
  end repeat
  return ParseFigureData(tTempFigure, tsex)
end
