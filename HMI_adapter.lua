-- Добавление библиотеки
require "./lua_lib/acs_data_lib"

-- ключ - структура спака из нижнего уровня, значение - структура в ЧМИ
spac_prefix = {["SPAC_VV1_803."] = "HMI_ZRU_VV1.",
               ["SPAC_VV2_803."] = "HMI_ZRU_VV2.",
               ["SPAC_SV_803."] = "HMI_ZRU_SV.",
               ["SPAC_1_1_803."] = "HMI_ZRU_OL1_1.",
               ["SPAC_1_3_803."] = "HMI_ZRU_OL1_3.",
               ["SPAC_1_6_803."] = "HMI_ZRU_OL1_6.",
               ["SPAC_1_12_803."] = "HMI_ZRU_OL1_12.",
               ["SPAC_2_6_803."] = "HMI_ZRU_OL2_6.",
               ["SPAC_2_8_803."] = "HMI_ZRU_OL2_8.",
               ["SPAC_2_11_803."] = "HMI_ZRU_OL2_11.",
               ["SPAC_2_17_803."] = "HMI_ZRU_OL2_17."
               }

-- Сопоставление конкретных переменных из структуры конкретным переменным из структуры ЧМИ          
signal_spac_name = { ["RAW_SPAC_L2210_RPV_DP"] = "switch.q.on",
                     ["RAW_SPAC_L2210_RPO_DP"] = "switch.q.off",
                     ["RAW_SPAC_L2210_MU_DU_DP"] = "switch.du",
                     ["RAW_SPAC_L2210_DEVICE1_STATUS"] = "switch.q.valid",
                     ["RAW_SPAC_L2210_SIG_BLOCK_VIHOD2_DP[2]"] = "switch.q.avoff"}
                     

-- адаптер который по изменению значения с устройства изменяет значение в ЧМИ 
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
  

-- инициализация  
for spac_name, hmi_spac_name in pairs(spac_prefix) do
  for spac_signal, hmi_spac_signal in pairs(signal_spac_name) do 
    Core.addLogMsg(spac_name..spac_signal)  
    adapter({spac_name, hmi_spac_name, spac_signal, hmi_spac_signal})
  end
end

-- сторож по изменению
for spac_name, hmi_spac_name in pairs(spac_prefix) do
  for spac_signal, hmi_spac_signal in pairs(signal_spac_name) do
    Core.addLogMsg(spac_name..spac_signal)
    Core.onExtChange({spac_name..spac_signal}, adapter, {spac_name, hmi_spac_name, spac_signal, hmi_spac_signal})
  end
end

Core.waitEvents()