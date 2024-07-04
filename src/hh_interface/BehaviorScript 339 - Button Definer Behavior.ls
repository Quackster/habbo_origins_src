property type, id, model, key, alignment, maxwidth, fixedsize, icon

on print me
  tsprite = sprite(me.spriteNum)
  put RETURN & "-- -- -- -- -- -- -- -- -- -- -- --" & RETURN & "type:      " && type & RETURN & "id:        " && id & RETURN & "model:     " && model & RETURN & "key:       " && key & RETURN & "alignment: " && alignment & RETURN & "maxwidth:  " && maxwidth & RETURN & "fixedsize: " && fixedsize & RETURN & "member:    " && tsprite.member.name & RETURN & "location:  " && tsprite.loc & RETURN & "icon:      " && icon & RETURN & "-- -- -- -- -- -- -- -- -- -- -- --"
end

on getBehaviorDescription me
  return "Defines buttons in window objects..."
end

on getPropertyDescriptionList me
  tList = [:]
  tList[#type] = [#format: #string, #default: "button", #range: ["button"], #comment: "type:"]
  tList[#id] = [#format: #string, #default: "identifier", #comment: "id:"]
  tList[#model] = [#format: #integer, #range: [#min: 1, #max: 20], #default: 1, #comment: "model:"]
  tList[#key] = [#format: #string, #default: "key", #comment: "text key:"]
  tList[#alignment] = [#format: #symbol, #range: [#left, #center, #right], #default: #left, #comment: "alignment:"]
  tList[#maxwidth] = [#format: #integer, #default: 100, #comment: "maximum width:"]
  tList[#fixedsize] = [#format: #boolean, #default: 0, #comment: "fixed size:"]
  tList[#icon] = [#format: #string, #default: EMPTY, #comment: "icon member name:"]
  return tList
end
