property type, id, model, keylist, direction, alignment, maxwidth, fixedsize

on print me
  tsprite = sprite(me.spriteNum)
  put RETURN & "-- -- -- -- -- -- -- -- -- -- -- --" & RETURN & "type:      " && type & RETURN & "id:        " && id & RETURN & "model:     " && model & RETURN & "keylist:   " && keylist & RETURN & "direction: " && direction & RETURN & "alignment: " && alignment & RETURN & "maxwidth:  " && maxwidth & RETURN & "fixedsize: " && fixedsize & RETURN & "member:    " && tsprite.member.name & RETURN & "location:  " && tsprite.loc & RETURN & "-- -- -- -- -- -- -- -- -- -- -- --"
end

on getBehaviorDescription me
  return "Defines dropmenus in window objects..."
end

on getPropertyDescriptionList me
  tList = [:]
  tList[#type] = [#format: #string, #default: "dropmenu", #range: ["dropmenu"], #comment: "type:"]
  tList[#id] = [#format: #string, #default: "identifier", #comment: "id:"]
  tList[#model] = [#format: #integer, #range: [#min: 1, #max: 10], #default: 1, #comment: "model:"]
  tList[#keylist] = [#format: #string, #default: "key1, key2...", #comment: "text keys:"]
  tList[#direction] = [#format: #symbol, #range: [#up, #lastselected, #down], #default: #down, #comment: "direction:"]
  tList[#alignment] = [#format: #symbol, #range: [#left, #center, #right], #default: #left, #comment: "alignment:"]
  tList[#maxwidth] = [#format: #integer, #default: 100, #comment: "maximum width:"]
  tList[#fixedsize] = [#format: #boolean, #default: 0, #comment: "fixed size:"]
  return tList
end
