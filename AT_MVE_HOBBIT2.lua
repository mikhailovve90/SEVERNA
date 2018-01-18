require "./lua_lib/crc16_ansi"
require "./lua_lib/acs_data_lib"

update_signal = "RAW_HOBBIT2_UPDATE"
PORT_CONNECT_ERROR = 10
port = nil
msg = {0x21}
pref_msg = {0x7e, 0x01}
bad_answer_count = 0
-- таблица состояний каналов
raw_state_signal = {
  "RAW_HOBBIT2_CH1_STATE_WORD",
  "RAW_HOBBIT2_CH2_STATE_WORD",
  "RAW_HOBBIT2_CH3_STATE_WORD",
  "RAW_HOBBIT2_CH4_STATE_WORD"
}

-- таблица концентраций
raw_concentrate_signal = {
  "RAW_HOBBIT2_CH1_CONCENTRATE",
  "RAW_HOBBIT2_CH2_CONCENTRATE",
  "RAW_HOBBIT2_CH3_CONCENTRATE",
  "RAW_HOBBIT2_CH4_CONCENTRATE"
}

-- Функция для связи с ком портом
function com_connect()
  port = SerialPort.new("COM6", 9600, 8, 1, "NONE")
  
-- Если порт не открылся, то сообщение в лог и выход из программы
  if port == nil then
    Core.addLogMsg("Can't connect to host")
    com_connect()
  end  
end

function close_port_on_reserve(id_port)
  id_port:close()
end

-- Функция которая выполняющая запрос на устройство
function processing(req_info)
  while(Core['@RESERVE'] == true) do
    close_port_on_reserve(port)
    Core.addLogMsg("Порт закрыт, узел в резерве")
  end
  
  if Core[update_signal] == true then -- Если есть команда на запрос выполнить запрос и записать результат в переменную
    answer = request_on_port(request_for_port(req_info[1], req_info[2]))-- выполнение запроса выполняется функцией request_for_port(req_info[1], req_info[2]), где req_info[1] - стандартные байты префикса сообщения, req_info[2] - тело сообщения
    if answer[2] == "bad" then
      Core.addLogMsg("Error port connect or read data")
      Core.addLogMsg("Try to connect ...")
      bad_answer_count = bad_answer_count + 1
      
      if port == nil then
        com_connect()
        os.sleep(1)
      end
      
      if bad_answer_count == 5 then
        Core["HOBBIT2_DS_DP"] = 2
        Core.addLogMsg("HOBBIT ERROR")
      end
      
      processing({pref_msg, msg})
    end
  end
  
  
 
  -- Считаем CRC пришедшего пакета
  validation = answer[1]:sub(3, -3)
  validation = string_to_byte(validation)
  validation = count_crc(validation)
  
  -- Вызываем функцию сравнения посчитанного crc пришедшего пакета и crc пришедшего вместе с пакетоm 
  if deepcompare(validation, string_to_byte(answer[1]:sub(-2))) then
    -- Core.addLogMsg("it looking good")
    bad_answer_count = 0
    unpackage_answer = unpackage(answer[1])
    -- Запись полученных значений в переменные  
    write_on_variables(unpackage_answer)
    
    if answer[2] == "good" then -- Проверяем если запрос и ответ прошли успешно(функция request_on_port вернула true, во втором элементе возвращаемого массива
      Core["RAW_HOBBIT2_UPDATE"] = false -- Скидываем переменную вызова
      Core["HOBBIT2_DS_DP"] = 0
    end
  else
    Core.addLogMsg("crc package not corrected")
    Core["RAW_HOBBIT2_UPDATE"] = false -- Скидываем переменную вызова
    Core["HOBBIT2_DS_DP"] = 16 -- код ошибки для недостоверных показаний
  end
end

-- формирование посылки для отправки на порт
function request_for_port(pref_msg, msg)
  loc_pref_msg = assigument_of_array(pref_msg)
  loc_msg = assigument_of_array(msg)
  -- Прибавление к префиксу посылки самого тела посылки 
  for _, value in ipairs(loc_msg) do
    table.insert(loc_pref_msg, value)
  end
  
  -- Прибавление к телу посылки с префиксом кода CRC 
  for _, value in ipairs(count_crc(loc_msg)) do
    table.insert(loc_pref_msg,value)
  end

  -- Формирование посылки на отправку 
  request = ""
  for _, value in ipairs(loc_pref_msg) do
    request = request..string.char(value)
  end

  return request
end

-- Отправка запроса на порт, возвращает ответ
function request_on_port(request)
  local success = "bad"  -- Переменная для подтверждения статуса запроса
  local answer = nil  -- ответ от устройства
  port:send(string.char(0x0f)) -- Согласно протокола отправляем на устройство байт 0x0f
  os.sleep(0.1)
  
  count_bytes = port:recvBytesAvailable()
  accept_answer = port:recv(count_bytes)
  if accept_answer == nil then
    return {0, "bad"}
  end
  
  accept_byte = string.byte(accept_answer, 1)
  

  if accept_byte == 0x06 then -- Если от устройства приходит ответ 0х06, то это означает что можно послать запрос на получение данных
    port:send(request) -- Посылаем интересующий нас запрос
    os.sleep(0.1)
    count_bytes = port:recvBytesAvailable()
    answer = port:recv(count_bytes)
    success = "good"
    
    if answer == nil then
      return {0, "bad"}
    end
  --[[else
    Core.addLogMsg("Устройство не ответило корректно на запрос, повтор...")  
    bad_answer_count = bad_answer_count + 1
      
      if bad_answer_count >= 7 then
        return {0, 10}
      end]]
  end
  
  return {answer, success}  
end

-- Разбор посылки
function unpackage(pack)
  if #pack == 8 then 
  end

  if #pack > 8 then--Если пришла посылка с состоянием нескольких канало
    byte_7E = string.byte(pack, 1)
    data_size = string.byte(pack, 2)
    data_type = string.byte(pack, 3)
    channel_amount = string.byte(pack, 4)
    
    channnel_params = channel_info(string.sub(pack, 5, #pack - 2))
    return {byte_7E, data_size, data_type, channel_amount, channnel_params}
  end
end

-- Достаём из посылки сведения и концентрацию по каждому каналу,
-- функция принимает пакет из которого убраны символы не относящиеся
-- к данным каналов(а)
function channel_info(byte_channel_info)
  channel_state = {} -- Массив состояний канала на каждый индекс приходится по состоянию одного канала(если канал один то массив из одного элемента)
  concentration = {{}} -- Двухмерный массив для значений концентрации, в каждом элементе массива находиться четыре байта данных
  count_for_byte = 1 -- Вспомогательная переменная для записи концентрации в массив побайтно
  count_for_state = 1 -- Вспомогательная переменная для записи состояний в массив
  
  for i = 1, #byte_channel_info, 5 do -- Цикл для записи значений в массивы
    channel_state[count_for_state] = string.byte(byte_channel_info, i) -- Запись в массив состояний байта состояния, в случае посылки больше чем из одного канала, каждый пятый байт является состоянием каждого следующего канала
    concentration[count_for_state] = {} -- Инициализация массива для записи концентрации( нужно для корректной работы записи в двухмерный маассив)
    
    for j = i+1, i+4 do -- Цикл по четырём байтам(следующим после байта состояния) и их запись в массив
      concentration[count_for_state][count_for_byte] = string.byte(byte_channel_info, j) -- Запись байтов из которых складывается значение концентрации в массив
      count_for_byte = count_for_byte + 1 
    end
    
    count_for_state = count_for_state + 1
    count_for_byte = 1
  end
  
  return {channel_state, concentration} -- Возвращаем массив из состоящий из состояний каналов - массив(channel_state), и концентраций - двухмерный массив(concentration)
end

-- Функция для записи посылки в переменные
function write_on_variables(data_pack)
  for i = 1, #data_pack[5][1] do 
    Core[raw_state_signal[i]] = data_pack[5][1][i]
    Core[raw_concentrate_signal[i]] = array_byte_to_int(data_pack[5][2][i],true)
  end
end  
  
  -- Вызов функции для открытия соединения с ком портом.
com_connect()

Core.onExtChange({update_signal}, processing, {pref_msg, msg})
Core.waitEvents()