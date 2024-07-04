on openHahmoEdit
  if not objectExists(#hahmoedit) then
    createObject(#hahmoedit, "hahmoedit Class")
  end if
  if objectExists(#hahmoedit) then
    getObject(#hahmoedit).showHideHahmoEdit()
  end if
  return 1
end
