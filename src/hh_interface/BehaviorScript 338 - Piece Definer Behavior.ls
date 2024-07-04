property type, id, strech

on print me
  tsprite = sprite(me.spriteNum)
  put RETURN & "-- -- -- -- -- -- -- -- -- -- -- --" & RETURN & "type:      " && type & RETURN & "id:        " && id & RETURN & "strech:    " && strech & RETURN & "member:    " && tsprite.member.name & RETURN & "location:  " && tsprite.loc & RETURN & "-- -- -- -- -- -- -- -- -- -- -- --"
end

on getBehaviorDescription me
  return "Defines pieces in window objects..."
end

on getPropertyDescriptionList me
  tStreches = [#fixed, #centerV, #strechH, #strechV, #strechHV, #moveH, #moveV, #moveHV, #moveHstrechV, #moveVstrechH, #centerH, #centerV, #centerHV, #moveHcenterV, #moveVcenterH]
  tList = [:]
  tList[#type] = [#format: #string, #default: "piece", #range: ["piece"], #comment: "type:"]
  tList[#id] = [#format: #string, #default: "identifier", #comment: "id:"]
  tList[#strech] = [#format: #symbol, #range: tStreches, #default: tStreches[1], #comment: "strech:"]
  return tList
end
