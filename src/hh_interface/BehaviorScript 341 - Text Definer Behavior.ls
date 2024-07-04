property type, id, model, key, strech

on print me
  tsprite = sprite(me.spriteNum)
  put RETURN & "-- -- -- -- -- -- -- -- -- -- -- --" & RETURN & "type:      " && type & RETURN & "id:        " && id & RETURN & "model:     " && model & RETURN & "key:       " && key & RETURN & "strech:    " && strech & RETURN & "member:    " && tsprite.member.name & RETURN & "location:  " && tsprite.loc & RETURN & "-- -- -- -- -- -- -- -- -- -- -- --"
end

on getBehaviorDescription me
  return "Defines text areas in window objects..."
end

on getPropertyDescriptionList me
  tStreches = [#fixed, #center, #strechH, #strechV, #strechHV, #moveH, #moveV, #moveHV, #moveHstrechV, #moveVstrechH, #centerH, #centerV, #centerHV]
  tList = [:]
  tList[#type] = [#format: #string, #default: "text", #range: ["text"], #comment: "type:"]
  tList[#id] = [#format: #string, #default: "identifier", #comment: "id:"]
  tList[#model] = [#format: #symbol, #range: [#image, #edit], #default: #image, #comment: "model:"]
  tList[#key] = [#format: #string, #default: "key", #comment: "text key:"]
  tList[#strech] = [#format: #symbol, #range: tStreches, #default: tStreches[1], #comment: "strech:"]
  return tList
end
