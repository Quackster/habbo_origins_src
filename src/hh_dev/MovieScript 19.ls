on createFigurePartIdsOLD
  repeat with tsex in ["male", "female"]
    if tsex = "male" then
      idcounter = 95
      tDestMem = "figure_ids_male"
      tList = ["hr_specs_male", "hd_specs_male", "ch_specs_male", "lg_specs_male", "sh_specs_male"]
    else
      idcounter = 495
      tDestMem = "figure_ids_female"
      tList = ["hr_specs_female", "hd_specs_female", "ch_specs_female", "lg_specs_female", "sh_specs_female"]
    end if
    member(tDestMem).text = EMPTY
    newColors = member(tDestMem).text
    repeat with tMem in tList
      s = member(tMem).text
      the itemDelimiter = "/"
      tMultiPart = VOID
      the itemDelimiter = "/"
      repeat with f = 1 to s.line.count
        the itemDelimiter = "/"
        ss = s.line[f].item[2]
        tpartNum = s.line[f].item[1]
        tPartName = tMem.char[1..2]
        tsex = tMem.char[10]
        idcounter = idcounter + 5
        the itemDelimiter = ","
        if tpartNum.item.count = 1 then
          newColors = newColors & "*/partId=" & idcounter & "/" & tPartName & "=" & tpartNum & RETURN
        else
          if tpartNum.item.count > 1 then
            if tPartName = "ch" then
              newColors = newColors & "*/partId=" & idcounter & "/" & tPartName & "=" & tpartNum.item[2] & "/ls=" & tpartNum.item[1] & "/rs=" & tpartNum.item[3] & RETURN
            else
              if tPartName = "hd" then
                newColors = newColors & "*/partId=" & idcounter & "/" & tPartName & "=" & tpartNum.item[1] & "/ey=" & tpartNum.item[2] & "/fc=" & tpartNum.item[3] & RETURN
              end if
            end if
          end if
        end if
        the itemDelimiter = "&"
        repeat with i = 1 to ss.item.count
          the itemDelimiter = "&"
          tempColor = ss.item[i]
          if ss = EMPTY then
            newColors = newColors & i & ":" & rgb(255, 255, 255).hexString() & RETURN
            next repeat
          end if
          if tempColor <> EMPTY then
            newLineNum = newColors.line.count
            the itemDelimiter = ","
            newColors = newColors & string(i) & ":" & rgb(value(tempColor.item[1]), value(tempColor.item[2]), value(tempColor.item[3])).hexString() & RETURN
          end if
        end repeat
        newColors = newColors & RETURN
      end repeat
      newColors = newColors & RETURN
    end repeat
    member(tDestMem).text = newColors
  end repeat
end