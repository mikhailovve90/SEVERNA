require "./lua_lib/acs_data_lib"


spac_prefix = {["SPAC_VV1_803."] = "HMI_ZRU_VV1.",
               ["SPAC_VV2_803."] = "HMI_ZRU_VV2.",
               ["SPAC_SV_803."] = "HMI_ZRU_SV." }
               
signal_spac_name = { ["RAW_SPAC_L2210_RPV_DP"] = "switch.q.on",
                     ["RAW_SPAC_L2210_RPO_DP"] = "switch.q.off",
                     ["RAW_SPAC_L2210_MU_DU_DP"] = "switch.du",
                     ["RAW_SPAC_L2210_STATUS_READ_INPUT_AND_OTPUT_ST"] = "switch.q.valid",
                     ["RAW_SPAC_L2210_SIG_BLOCK_VIHOD1_DP[2]"] = "switch.q.avoff"}
                     


function adapter(param_tables)
  spac_name = param_tables[1]
  hmi_spac_name = param_tables[2]
  spac_signal = param_tables[3]
  hmi_spac_signal = param_tables[4]

  if hmi_spac_signal == "switch.q.valid" then 
    if Core[spac_name..spac_signal] == 2 then
      Core[hmi_spac_name..hmi_spac_signal] = true
    else 
      Core[hmi_spac_name..hmi_spac_signal] = false
    end
  else
    signal = byte_to_bool(Core[spac_name..spac_signal])
    Core[hmi_spac_name..hmi_spac_signal] = signal[1]
  end
end
  

  
for spac_name, hmi_spac_name in pairs(spac_prefix) do
  for spac_signal, hmi_spac_signal in pairs(signal_spac_name) do 
    Core.addLogMsg(spac_name..spac_signal)  
    adapter({spac_name, hmi_spac_name, spac_signal, hmi_spac_signal})
  end
end

for spac_name, hmi_spac_name in pairs(spac_prefix) do
  for spac_signal, hmi_spac_signal in pairs(signal_spac_name) do
    Core.addLogMsg(spac_name..spac_signal)
    Core.onExtChange({spac_name..spac_signal}, adapter, {spac_name, hmi_spac_name, spac_signal, hmi_spac_signal})
  end
end

Core.waitEvents()