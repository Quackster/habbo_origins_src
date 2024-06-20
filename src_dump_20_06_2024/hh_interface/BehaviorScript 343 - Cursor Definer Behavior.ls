property cursor

on print me
  tsprite = sprite(me.spriteNum)
  put RETURN & "-- -- -- -- -- -- -- -- -- -- -- --" & RETURN & "cursor:    " && cursor & RETURN & "member:    " && tsprite.member.name & RETURN & "location:  " && tsprite.loc & RETURN & "-- -- -- -- -- -- -- -- -- -- -- --"
end

on getBehaviorDescription me
  return "Defines element's mouse cursor in window recordings..."
end

on getPropertyDescriptionList me
  tList = [:]
  tList[#cursor] = [#format: #string, #default: EMPTY, #comment: "Cursor member's name:"]
  return tList
end
