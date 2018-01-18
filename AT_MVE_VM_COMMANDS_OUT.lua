-- Команды на СПАК

outs = "RAW_SPAC_L2210_SIG_BLOCK_VIHOD1_DP"
allow_reg = "RAW_SPAC_L2210_UPR_BLOCK_VIHOD1_DP"
cat = 100

list_device_prefix = {"SPAC_VV1_803.", "SPAC_VV2_803.", "SPAC_SV_803.",
                     "SPAC_1_1_803.", "SPAC_1_6_803.", "SPAC_1_12_803.", 
                     "SPAC_2_6_803.", "SPAC_2_8_803.", "SPAC_2_11_803.", "SPAC_2_17_803.", "SPAC_1_3_803."}
                     
spac_source = {
["SPAC_VV1_803."] = "ЗРУ 10кВ Ввод1",
["SPAC_VV2_803."] = "ЗРУ 10кВ Ввод2",
["SPAC_SV_803."] = "ЗРУ 10кВ Секционный выключатель",
["SPAC_1_6_803."] = "ЗРУ 10кВ T3 КТП вспомогательной зоны",
["SPAC_1_1_803."] = "ЗРУ 10кВ T5 КТП ВОС",
["SPAC_1_12_803."] = "ЗРУ 10кВ T1 КТП основной зоны",
["SPAC_2_6_803."] = "ЗРУ 10кВ Вдольтрассовая ЛЭП",
["SPAC_2_8_803."] = "ЗРУ 10кВ Т2 Основной зоны",
["SPAC_2_11_803."] = "ЗРУ 10кВ Т4 Вспомогательной зоны",
["SPAC_2_17_803."] = "ЗРУ 10кВ Т6 ВОС",
["SPAC_1_3_803."] = "ЗРУ 10кВ Ячейка 1_3"
}
                     
allow_signal = "UPDATE_WRITE_ALLOWS_OUT"
write_signal_on = "UPDATE_WRITE_COMMAND_VKL"
write_signal_off = "UPDATE_WRITE_COMMAND_VIKL"
read_signal = "UPDATE_READ_OUTS_AND_ALLOWS"
read_allow_scada = "READ_ALLOW_SCADA"

external_vikl = "VIKL_VIKL"
external_vkl = "VKL_VIKL"
get_permit = "ALLOW_GET"
pick_up_permit = "ALLOW_PICK_UP"

function read_allow_rpv_rpo(device_prefix)
  if Core[device_prefix[1]..read_signal] == false then
    Core[device_prefix[1]..read_signal] = true
  else
    Core.addLogMsg("Команда в драйвер на считывание уже была послана, но не отработана корректно")
  end
  
  Core[device_prefix[1]..read_allow_scada] = false
end

function permit_on(device_prefix)
  if Core[device_prefix[1]..get_permit] == true then
-- Даём разрешение на изменение выходных состояний 
    if Core[device_prefix[1]..allow_reg] == 0 then
      Core[device_prefix[1]..allow_reg] = 1
      
      if Core[device_prefix[1]..allow_signal] == false then
        Core[device_prefix[1]..allow_signal] = true
      else
        Core[device_prefix[1]..allow_signal] = false
        Core[device_prefix[1]..allow_signal] = true
      end  
    else
      Core.addLogMsg("Разрешение уже есть")
    end
  os.sleep(1)
  end
  
  Core[device_prefix[1]..get_permit] = false
  
  read_allow_rpv_rpo(device_prefix)
end

function permit_off(device_prefix)
  if Core[device_prefix[1]..pick_up_permit] == true then
-- Забираем разрешение на изменение выходных состояний 
    if Core[device_prefix[1]..allow_reg] == 1 then
      Core[device_prefix[1]..allow_reg] = 0
      
      if Core[device_prefix[1]..allow_signal] == false then
        Core[device_prefix[1]..allow_signal] = true
      else
        Core[device_prefix[1]..allow_signal] = false
    os.sleep(0.1)      
    Core[device_prefix[1]..allow_signal] = true
      end  
    else
      Core.addLogMsg("Разрешение уже есть")
    end
  
    os.sleep(1)
  end
  Core[device_prefix[1]..pick_up_permit] = false
  
  read_allow_rpv_rpo(device_prefix)
end

function switch_on(device_prefix)
  if Core[device_prefix[1]..external_vkl] == true then
    -- Записываем на выход отвечающий за включение еденицу
    if Core[device_prefix[1]..outs.."[3]"] == 0 then
      Core[device_prefix[1]..outs.."[3]"] = 1
      
      if Core[device_prefix[1]..write_signal_on] == false then
        Core[device_prefix[1]..write_signal_on] = true
      else  -- в случае когда на драйвере зависла еденица или не скиеуласть по каким либо причинам
        Core[device_prefix[1]..write_signal_on] = false
        os.sleep(1)
        Core[device_prefix[1]..write_signal_on] = true
      end
    else
      Core.addLogMsg("Команда уже подана")
    end
    
    os.sleep(0.2)
    -- Core.addEvent("Команда оператора включить", cat, 1, spac_source[device_prefix[1]])
    Core.addLogMsg(spac_source[device_prefix[1]])
    

    if Core[device_prefix[1]..outs.."[3]"] == 1 then
      Core[device_prefix[1]..outs.."[3]"] = 0
      
      if Core[device_prefix[1]..write_signal_on] == false then
        Core[device_prefix[1]..write_signal_on] = true
      else
        Core[device_prefix[1]..write_signal_on] = false
       os.sleep(1)
      Core[device_prefix[1]..write_signal_on] = true
      end
    else
      Core.addLogMsg("Команда на включение не была подана")    
    end
  
    os.sleep(0.2)
    
    read_allow_rpv_rpo(device_prefix)
    
    for i = 1, #list_device_prefix, 1 do
      read_allow_rpv_rpo({list_device_prefix[i]})
    end
  end
  
  Core[device_prefix[1]..external_vkl] = false
end

function switch_off(device_prefix)
  if Core[device_prefix[1]..external_vikl] == true then
    -- Записываем на выход отвечающий за выключение еденицу
    if Core[device_prefix[1]..outs.."[2]"] == 0 then
      Core[device_prefix[1]..outs.."[2]"] = 1
      
      if Core[device_prefix[1]..write_signal_off] == false then
        Core[device_prefix[1]..write_signal_off] = true
      else
        Core[device_prefix[1]..write_signal_off] = false
        os.sleep(1)
    Core[device_prefix[1]..write_signal_off] = true
      end
    else
      Core.addLogMsg("Команда уже подана")
    end
    
    os.sleep(0.2)
    -- Core.addEvent("Команда оператора отключать", cat, 1, spac_source[device_prefix[1]])
    Core.addLogMsg(spac_source[device_prefix[1]])
    
    -- Скидываем команду, длительность команды регулируется os.sleep
    if Core[device_prefix[1]..outs.."[2]"] == 1 then
      Core[device_prefix[1]..outs.."[2]"] = 0
      
      if Core[device_prefix[1]..write_signal_off] == false then
        Core[device_prefix[1]..write_signal_off] = true
      else
       Core[device_prefix[1]..write_signal_off] = false
       os.sleep(1)
    Core[device_prefix[1]..write_signal_off] = true
      end
    else
      Core.addLogMsg("Команда на вsключение не была подана")
    end
    
    os.sleep(0.2)
    
    read_allow_rpv_rpo(device_prefix)
    
    for i = 1, #list_device_prefix, 1 do
   --   read_allow_rpv_rpo({list_device_prefix[i]})
    end
  end
  Core[device_prefix[1]..external_vikl] = false
end

for i = 1, #list_device_prefix, 1 do
  Core.onExtChange({list_device_prefix[i]..external_vikl}, switch_off, {list_device_prefix[i]})
  Core.onExtChange({list_device_prefix[i]..external_vkl}, switch_on, {list_device_prefix[i]})
  Core.onExtChange({list_device_prefix[i]..get_permit}, permit_on, {list_device_prefix[i]})
  Core.onExtChange({list_device_prefix[i]..pick_up_permit}, permit_off, {list_device_prefix[i]})
  Core.onExtChange({list_device_prefix[i]..read_allow_scada}, read_allow_rpv_rpo, {list_device_prefix[i]})
end

Core.waitEvents()