on puukotaKoiraa
  tList = [:]
  tList["hd_std"] = [[36, -21], [38, -18], [37, -18], [32, -15], [32, -20]]
  tList["hd_sit"] = [[36, -21], [38, -18], [37, -18], [32, -14], [32, -17]]
  tList["hd_lay"] = [[36, -13], [38, -11], [37, -12], [32, -8], [32, -11]]
  tList["hd_slp"] = [[36, -11], [38, -9], [37, -10], [32, -6], [32, -9]]
  tList["hd_wlk"] = tList["hd_std"]
  tList["hd_pla"] = tList["hd_sit"]
  tList["hd_spc"] = tList["hd_std"]
  tList["hd_rdy"] = [[35, -17], [38, -11], [37, -7], [32, -11], [32, -17]]
  tList["hd_beg"] = [[24, -24], [25, -27], [26, -28], [32, -26], [32, -24]]
  tList["hd_ded"] = [[40, -3], [38, 1], [37, 5], [32, 8], [32, -7]]
  tList["hd_jmp_0"] = tList["hd_rdy"]
  tList["hd_jmp_1"] = tList["hd_sit"]
  tList["hd_jmp_2"] = [[36, -33], [38, -30], [37, -30], [32, -27], [32, -32]]
  tList["hd_jmp_3"] = [[36, -25], [38, -22], [37, -22], [32, -19], [32, -24]]
  tList["hd_scr_0"] = tList["hd_sit"]
  tList["hd_scr_1"] = [[36, -19], [39, -16], [37, -16], [32, -12], [32, -15]]
  tList["hd_scr_2"] = tList["hd_sit"]
  tList["hd_scr_3"] = tList["hd_scr_1"]
  tList["hd_bnd_0"] = tList["hd_rdy"]
  tList["hd_bnd_1"] = [[35, -22], [36, -19], [36, -19], [32, -16], [32, -21]]
  tList["hd_bnd_2"] = tList["hd_bnd_1"]
  tList["hd_bnd_3"] = tList["hd_bnd_1"]
  tList["tl_std"] = [[21, -10], [20, -12], [23, -19], [32, -23], [32, -10]]
  tList["tl_sit"] = [[21, -2], [22, -1], [23, -6], [32, -19], [32, -3]]
  tList["tl_lay"] = [[21, 1], [18, -1], [23, -10], [32, -15], [32, 0]]
  tList["tl_slp"] = tList["tl_lay"]
  tList["tl_wlk"] = tList["tl_std"]
  tList["tl_pla"] = tList["tl_sit"]
  tList["tl_spc"] = tList["tl_std"]
  tList["tl_rdy"] = [[21, -10], [20, -12], [23, -19], [32, -23], [32, -11]]
  tList["tl_beg"] = [[21, -2], [22, -1], [23, -5], [32, -14], [32, 1]]
  tList["tl_ded"] = [[23, 2], [18, 1], [23, -19], [32, -20], [32, -10]]
  tList["tl_jmp_0"] = tList["tl_rdy"]
  tList["tl_jmp_1"] = tList["tl_sit"]
  tList["tl_jmp_2"] = [[21, -16], [20, -18], [23, -25], [32, -28], [32, -16]]
  tList["tl_jmp_3"] = [[21, -20], [20, -22], [23, -29], [32, -33], [32, -20]]
  tList["tl_scr_0"] = tList["tl_sit"]
  tList["tl_scr_1"] = [[21, -1], [22, 0], [23, -5], [32, -18], [32, -2]]
  tList["tl_scr_2"] = tList["tl_sit"]
  tList["tl_scr_3"] = tList["tl_scr_1"]
  tList["tl_bnd_0"] = tList["tl_rdy"]
  tList["tl_bnd_1"] = [[23, -13], [24, -14], [25, -21], [32, -27], [32, -12]]
  tList["tl_bnd_2"] = tList["tl_bnd_1"]
  tList["tl_bnd_3"] = tList["tl_bnd_1"]
  tUserList = getThread(#room).getComponent().pUserObjList
  repeat with i = 1 to tUserList.count
    tuser = tUserList[i]
    if tuser.pInfoStruct[#class] = "pet" then
      tuser.pOffsetList = tList
      tuser.pChanges = 1
      tuser.render()
      tuser.Refresh()
    end if
  end repeat
end

on petOff
  tUserList = getThread(#room).getComponent().pUserObjList
  repeat with i = 1 to tUserList.count
    tuser = tUserList[i]
    if tuser.pInfoStruct[#class] = "pet" then
      tuser.pOffsetList = tuser.pOffsetList / 2
      tuser.render()
    end if
  end repeat
end
