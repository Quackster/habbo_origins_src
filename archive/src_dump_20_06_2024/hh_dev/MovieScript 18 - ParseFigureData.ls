on ParseFigureData tFigure, tsex
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
        ttempColor.addProp(tLine.item[1], tLine.item[2])
      end if
      next repeat
    end if
    if tLine.char[1] = "*" then
      if not voidp(ttempProp) and (ttempColor <> [:]) then
        ttempColor.addProp("part", ttempProp)
        tValidPartProps.addProp(tPartId, ttempColor)
      end if
      ttempColor = [:]
      the itemDelimiter = "/"
      tPartId = tLine.item[2].char[8..tLine.item[2].char.count]
      ttempProp = tLine.item[3]
      if tLine.item[3] contains "hd" then
        tLine = tLine & "/bd=1/lh=1/rh=1"
      end if
      if tLine.item.count > 3 then
        repeat with tMultiParts = 4 to tLine.item.count
          ttempProp = ttempProp & "/" & tLine.item[tMultiParts]
        end repeat
      end if
    end if
  end repeat
  tHumanPartList = [:]
  repeat with f = 1 to tFigure.count
    tPartId = tFigure.getPropAt(f)
    if not voidp(tValidPartProps[tPartId]) then
      tValidColors = tValidPartProps[tPartId]
      tPartColor = tFigure[tPartId]
      if integerp(tPartColor) then
        tPartColor = string(tPartColor)
      end if
      if not voidp(tValidColors[tPartColor]) then
        tColor = tValidColors[tPartColor]
      else
        tColor = tValidColors[1]
      end if
    else
      tValidColors = tValidPartProps[1]
      tColor = tValidColors[1]
    end if
    tTempParts = tValidColors["part"]
    the itemDelimiter = "/"
    repeat with t = 1 to tTempParts.item.count
      tPartList = tTempParts.item[t]
      the itemDelimiter = "="
      tHumanPart = tPartList.item[1]
      tHumanPartModel = tPartList.item[2]
      if tHumanPartModel.char.count = 1 then
        tHumanPartModel = "00" & tHumanPartModel
      end if
      if tHumanPartModel.char.count = 2 then
        tHumanPartModel = "0" & tHumanPartModel
      end if
      if tHumanPart <> "ey" then
        tHumanPartColor = tColor
      else
        tHumanPartColor = "#FFFFFF"
      end if
      tHumanPartList.addProp(tHumanPart, ["model": tHumanPartModel, "color": tHumanPartColor])
      the itemDelimiter = "/"
    end repeat
  end repeat
  return tHumanPartList
end
