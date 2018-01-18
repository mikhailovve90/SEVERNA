
local ScreenID="KTP8516"
local USO_ID="USOKTP1_"
local ObjID="GSP_SEV_KSSEV_E_"..USO_ID
local PLC_Name="A1_"
local ObjDesc= "КТП 8516. "

local Logs=true

local User=ObjDesc.."ПЛК "..string.gsub(PLC_Name,"_"," ").. "(система)"
local pulse_duration=10 -- минимально допустимая длительность входного импульса, мс  (если меньше - то отсечка дребезга контактов)
local bounce_check=true  -- проверка дребезга контактов (true- включена)
local dis_border_val=-32768 --значение отключенной тревожной границы AI

-- //Загрузка конфигурации из файлов
--........................................................
local RawDI=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "DI_map") --считываем конфигурацию дискретных входов ПЛК
local RawAI=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "AI_map") --считываем конфигурацию аналоговых входов ПЛК
local RawDO=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "DO_map") --считываем конфигурацию дискретных выходов ПЛК
local DI_Signals=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "DI_data") --считываем базу дискретных тегов и их свойств
local AI_Signals=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "AI_data") --считываем базу аналоговых тегов и их свойств
local DO_Signals=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "DO_data") --считываем базу дискретных выходов и их свойств
--........................................................
local event =require("./_events_desc"); -- считаем описание классов аварийных сообщений
local noValid =require("./_reliabilityField"); -- считаем описание битового поля недостоверности сигнала
local start_delay=5 -- задержка старта инициализации
local OldAIValueFlag=false-- флаг фиксации последнего достоверного значения аналогового сигнала
--........................................................
-- // Конец загрузка конфигурации
local oldsignals = {} 	-- буферная таблица  предыдущего значения дискретных входов
local CurrentAiAlarms= {-- буферная таблица действующих алармов для AI
						["LL"]={},
						["LH"]={},
						["HL"]={},
						["HH"]={},
						["DIS"]={},
						}--CurrentAiAlarms


--local function ChangeIn()--функция имитации дребезга
--local InDI=Core["InDI"]
--
--if  InDI==false then  InDI=true else  InDI=false end
--Core["InDI"]=InDI
--end

-- /////////////////////// блок функций////////////////////
-- ///////////////////////Обработка значений переменных////////////////////
local function Process_DI_Data(Signal) -- обработка входных дискретов
		-- переменные
		local points=2 -- количество дополнительных точек для проверки
		local timestamp=os.time(); -- время фиксации сигнала (передний фронт)--найдем в таблице соответствующий выходной тэг, проверив его наличие
		local OutputName --имя выходного тега 
		local VarName=Signal[1]--
		local ModuleNum=Signal[2]	
		local InputName=string.gsub(Signal[1], USO_ID, "")
		local e_type -- тип события (появление/исчезновение)
	--	local user="USER_:)"			
				if DI_Signals[InputName]==nil then -- если сигнал в таблице не описан
						Core.addLogMsg(" Опрос "..InputName..". Для данного DI входа отсутствует описание в таблице DI_Signals") -- отправим сообщение об ошибке в логи
						return -- завершить работу функции Process_DI_Data
				else
				  	    OutputName=ObjID..DI_Signals[InputName]["Tag"] --имя выходного тега присвоим
						if DI_Signals[InputName]["repaireFlag"]== true -- и проверим на нахождение в ремонте (запрет опроса)
						then
						  if Logs -- если логи включены
							then	
							 	Core.addLogMsg("Опрос тэга"..ObjID..DI_Signals[InputName]["Tag"].." отключен из-за вывода оборудования в ремонт(канал ".. InputName.. ").") -- отправим сообщение в логи	 
					   		end
						  return -- прекращаем работу функции Process_DI_Data
						end
				end --DI_Signals[InputName]["Tag"]
			-- проверка на дребезг
				if  bounce_check==true 
				then --если включена проверка на дребезг
					local InDI={} -- массив данных со входа 
					local bounce_flag=false -- признак дребезга контактов
					local step=pulse_duration/points --шаг проверки длительности импульса (/2 значит по трём точкам)
					-- цикл контрольного опроса входа
							for i=1, points+1 do  
								InDI[i]=Core[USO_ID..InputName] -- опрашиваем вход
								os.sleep(0.001*step) -- ждем отрезок до следующего опроса входа
						--	if Core["bounce"]==true then ChangeIn() end -- имитируем дребезг если разрешено
				 			end --for
					-- цикл проверки наличия дребезга 
							for i=1, points do  
								if InDI[i]~=InDI[i+1] then bounce_flag=true end
							end --for
					if bounce_flag==false then 
						OutDI=InDI[1] --присваеваем переменной первое значение
						Core[OutputName..".dt"]=timestamp -- и метку времени
					else
						Core[USO_ID..InputName]=InDI[1] -- возвращаем на вход первоначальное значение
					 end --if
 		  		 else -- bounce_check==true 
					OutDI=Core[USO_ID..InputName] -- если проверка дребезга отключена - присваиваем напрямую
 		 	     end --if  bounce_check
			-- проверка на дребезг конец
			if OutDI==oldsignals[InputName]--если сигнал не менял значение
			then
					return -- прекращаем работу функции Process_DI_Data
			end
			Core[OutputName..".Value"]=OutDI -- присваеваем значение глобальной переменной
			DI_Signals[InputName]["Value"]=OutDI  -- и заносим в таблицу
	
		-- ....проверка на связку с другим сигналом
		--.... в перспективе !!
		--.... проверка на связку с другим сигналом конец
	
 		--////// Формирование сообщения в журнал событий
		-- проверка изменения сигнала
				if OutDI~=oldsignals[InputName] -- строка будет формироваться, если полученное и предыдущее значения сигнала не совпадают
				then	
						--определяем тип события
							local e_type
							if DI_Signals[InputName]["Value"]==true  -- тип события 1-возникновение, 0 - исчезновение
							then
									if DI_Signals[InputName]["InvFlag"]==false --сигнал неинвертированный,
									then 
										e_type=1
									else	--сигнал инвертированный,
										e_type=0
									end
							else
									if DI_Signals[InputName]["InvFlag"]==false --сигнал неинвертированный,
									then 
										e_type=0
									else	--сигнал инвертированный,
										e_type=1
									end
							end --тип события
							--если это событие						
							-- ОБРАБОТКА ПОЯВЛЕНИЯ СОБЫТИЙ
							--
						if DI_Signals[InputName]["AlarmClass"]~=event.disabled  -- если включены сообщения для сигнала
						then
								local EventMsg=ObjDesc -- текст сообщения
								if DI_Signals[InputName]["AlarmClass"]==event.s or DI_Signals[InputName]["AlarmClass"]==event.c -- если событие или команда, то формируем строку сообщения из описания сигнала и его состоянияы
								then
									EventMsg=EventMsg..DI_Signals[InputName]["Comment"]	-- описания сигнала
									if OutDI==true -- если сигнал принял значение "1"
									then
											if DI_Signals[InputName]["InvFlag"]==false -- выбираем текст в зависимости от инверсии сигнала,
											then 
													EventMsg=EventMsg.." "..DI_Signals[InputName]["Txt_1"]--если инверсии нет - то для true значения сигнала присвоим текст состояния "1"
											else
													EventMsg=EventMsg.." "..DI_Signals[InputName]["Txt_0"] -- если есть - то для "0"
											end--DI_Signals[InputName]["InvFlag"]==false
									 else -- если сигнал принял значение "0"	
											if DI_Signals[InputName]["InvFlag"]==false-- выбираем текст в зависимости от инверсии сигнала,
											then 
														EventMsg=EventMsg.." "..DI_Signals[InputName]["Txt_0"] --если инверсии нет - то для false значения сигнала присвоим текст состояния "0"
											else
														EventMsg=EventMsg.." "..DI_Signals[InputName]["Txt_1"]-- если есть - то для "1"
											end	--	DI_Signals[InputName]["InvFlag"]==false
								 	end	--if OutDI==true
								 else -- если авария или предупреждение
										EventMsg=EventMsg..DI_Signals[InputName]["Comment"]..". "..DI_Signals[InputName]["AlarmMsg"] -- добавим текст 

								 end	-- DI_Signals[InputName]["AlarmClass"]==event.s 
								if  DI_Signals[InputName]["reliabilityFlag"] == false then EventMsg="ЗНАЧЕНИЕ НЕДОСТОВЕРНО. "..EventMsg end -- ЕСЛИ недостоверно - отметим и это
								-- создадим сообщение в логах
								  if Logs -- если логи включены
									then 
										Core.addLogMsg(EventMsg.." "..DI_Signals[InputName]["AlarmClass"].." "..ObjID..DI_Signals[InputName]["Tag"].." "..timestamp.."_"..e_type.." "..ScreenID.." "..User)
									end --	if Logs
								-- создадим сообщение в стоке событий
								Core.addEvent(EventMsg, DI_Signals[InputName]["AlarmClass"], e_type ,DI_Signals[InputName]["Source"], User, ObjID..DI_Signals[InputName]["Tag"], timestamp, ScreenID )
						 end --DI_Signals[InputName]["AlarmClass"]~=0
				end --if OutDI~=oldsignals[InputName]	
			--////// Формирование сообщения в журнал событий конец
	   		oldsignals[InputName]=OutDI -- заменяем значение переменной в буфере предыдущего значения	 	
end --of Process_DI_Data(Signal) 


--!!! функция добавления тревожных событий для аналового сигнала
local function Add_AI_Alarm(Signal)
		--local user="USER_:)"	
		local timestamp=os.time(); -- время фиксации сигнала (передний фронт)--найдем в таблице соответствующий выходной тэг, проверив его наличие		
		local AlarmMsg= -- таблица аварийных сообщений
		{
		--	["SC_Txt"]= "Короткое замыкание измерительного канала канала параметра '" .. ObjDesc..AI_Signals[Signal[1]].Comment.."'",
			["HH_Txt"]= "Превышен верхний аварийный порог параметра '".. ObjDesc..AI_Signals[Signal[1]].Comment.."' ("..AI_Signals[Signal[1]].HH ..")",
			["HL_Txt"]= "Превышен верхний предупредительный порог параметра '".. ObjDesc..AI_Signals[Signal[1]].Comment.."' ("..AI_Signals[Signal[1]].HL ..")",
			["LH_Txt"]= "Значение параметра '".. ObjDesc..AI_Signals[Signal[1]].Comment.."' ниже предупредительного порога ("..AI_Signals[Signal[1]].LH ..")",
			["LL_Txt"]= "Значение параметра '".. ObjDesc..AI_Signals[Signal[1]].Comment.."' ниже аварийного порога ("..AI_Signals[Signal[1]].LL ..")",
		--	["BR_Txt"]= "Обрыв измерительного канала параметра '" .. ObjDesc..AI_Signals[Signal[1]].Comment.."'",
		}
			local AlarmClass-- класс тревоги
			local AlarmString -- выводимый пользователю текст
			local AlarmTxt=	Signal[2].."_Txt" -- описание тревоги
			local Ch =Signal[1] -- измерительный канал
			local AlarmType =Signal[2] -- тип тревоги
			local reliabilityTXT -- текст о недостоверности
			if CurrentAiAlarms[AlarmType][Ch]==true -- если авария уже зарегистрирована
				then 
				--Core.addLogMsg("ТРЕВОГА УЖЕ ЗАРЕГИСТРИРОВАНА :".. AlarmTxt.. " " .. AlarmMsg[AlarmTxt])
					return -- прервем выполнение функции
			else
				-- НАЙДЕМ ПРЕДЫДУЩУЮ ТРЕВОГУ	
				for AlarmTypes, _  in pairs(CurrentAiAlarms) -- в таблице действующих тревог
				do	
					 AlarmString= AlarmMsg[tostring(AlarmTypes.."_Txt")]
					if CurrentAiAlarms[AlarmTypes][Ch]~=nil -- просматриваем все существующие значения
					then
						if AlarmTypes~=AlarmType -- просматриваем все значения, отличные от переданного в функцию
						then	
							if CurrentAiAlarms[AlarmTypes][Ch]==true -- ищем ранее активированную тревогу
							then
								CurrentAiAlarms[AlarmTypes][Ch]=false -- сбрасываем 
								--if AlarmTypes=="BR" or AlarmTypes=="SC" or AlarmTypes=="LL" or AlarmTypes=="HH" --выбираем класс тревоги в зависимости от предела
								if AlarmTypes=="LL" or AlarmTypes=="HH" --выбираем класс тревоги в зависимости от предела
									then
										AlarmClass=event.a
								elseif AlarmTypes=="LH" or AlarmTypes=="HL" 
									then
										AlarmClass=event.w
								else  AlarmClass=event.disabled
								end --AlarmTypes=="LL" or 
									if  AI_Signals[Ch]["reliabilityFlag"] == false -- если вдруг значение недостоверно - добавим текста
									then 	
				 	 					    if Logs -- если логи включены											
											then
												Core.addLogMsg("Исчезновение: ".. AlarmString.." Класс " ..AlarmClass..")" .." (значение НЕДОСТОВЕРНО)".." "..User)  -- делаем запись в лог
											end --						  if Logs -- если логи включены	
										Core.addEvent(AlarmString.." (значение НЕДОСТОВЕРНО)", event.dr,0, AI_Signals[Ch]["Source"], User, ObjID..AI_Signals[Ch].Tag, timestamp, ScreenID) --делаем запись в строку сообщений
									else
											  if Logs -- если логи включены											
											  then
													Core.addLogMsg("Исчезновение: ".. AlarmString.." Класс " ..AlarmClass..")".." "..User)  -- делаем запись в лог
											  end --						  if Logs -- если логи включены	
											Core.addEvent(AlarmString, AI_Signals[Ch].AlarmClass,0 , AI_Signals[Ch]["Source"], User,ObjID..AI_Signals[Ch].Tag, timestamp, ScreenID) --делаем запись в строку сообщений
									end --AI_Signals[Ch]["reliabilityFlag"] == false 
							end --CurrentAiAlarms[AlarmTypes][Ch]==true
						end --AlarmTypes~=AlarmType
					end --CurrentAiAlarms[AlarmTypes][Ch]~=nil 
				end --_,  AlarmTypes		
-- добавление новой тревоги

				if AlarmType=="LL" or AlarmType=="HH" --выбираем класс тревоги
					then
						AlarmClass=event.a
				elseif AlarmType=="LH" or AlarmType=="HL" 
					 then
						AlarmClass=event.w
				else  AlarmClass=event.disabled
				end --AlarmType=="LH" or 
				if AlarmClass~=event.disabled --сделаем записи, если сообщение не отключено
				then
					AlarmString= AlarmMsg[tostring(AlarmType.."_Txt")]
					if  AI_Signals[Ch]["reliabilityFlag"] == false -- если вдруг значение недостоверно - добавим текста
					then 
						AlarmString=AlarmMsg[tostring(AlarmType.."_Txt")] .." (значение НЕДОСТОВЕРНО)"
					end --AI_Signals[Ch]["reliabilityFlag"] == false 
					CurrentAiAlarms[AlarmType][Ch]=true -- сохраняем тревогу в буфер
  					if Logs -- если логи включены	
						then						
							Core.addLogMsg("Возникновение: "..AlarmString.." (Класс " ..AlarmClass..")" .." "..User)-- делаем запись в лог
					end --	if Logs 
					if  AI_Signals[Ch]["reliabilityFlag"] == false then-- если вдруг значение недостоверно - покрасим в фиолэтовый
						Core.addEvent(AlarmString, event.dr,1, AI_Signals[Ch]["Source"], User, ObjID..AI_Signals[Ch].Tag, timestamp, ScreenID) --делаем запись в строку сообщений в фиолетовом колоре
					else
						Core.addEvent(AlarmString, AI_Signals[Ch].AlarmClass,1, AI_Signals[Ch]["Source"], User, ObjID..AI_Signals[Ch].Tag, timestamp, ScreenID) --делаем запись в строку сообщений в колоре по ситуации
					end--if  AI_Signals[Ch]["reliabilityFlag"] == false
				end --AlarmClass~=event.disabled
			end--CurrentAiAlarms[Signal[2]][Signal[1]]==true
		--if AI_Signals[Signal[1]].reliabilityFlag==false
end --function Add_AI_Alarm(Signal)
 
local function Process_AI_Data(Signal) -- обработка входных аналогов
-- переменные
		local OutputName --имя выходного тега 
		local VarName=Signal[1]
		local ModuleNum=Signal[2]	
		local InputName=string.gsub(Signal[1], USO_ID, "")
--		Core.addLogMsg("VarName="..VarName.." ModuleNum="..ModuleNum .." InputName="..InputName) -- отправим сообщение об ошибке в логи
				if AI_Signals[InputName]==nil then -- если сигнал в таблице не описан
						Core.addLogMsg("Опрос "..InputName..". Для данного AI входа отсутствует описание в таблице AI_Signals") -- отправим сообщение об ошибке в логи
						return -- завершить работу функции Process_DI_Data
				else
					if AI_Signals[InputName]["repaireFlag"]==false	-- если сингал не выведен из опроса
					then 	
						local Values={}-- временные значения
						local OutputName=ObjID..AI_Signals[InputName]["Tag"]
						Values[1]=Core[VarName] -- опрашиваем вход
						 Values[2]=Values[1]
						--Core[OutputName..".Value"]=Values[1]--присвоим значение тегу
						if Core[OutputName..".reliabilityFlag"]==true then --если сигнал достоверен
								Values[1]=Core[VarName] -- присвоим значение со входа
						else
								Core[OutputName..".OldValue"]=Values[1] --запомним последнее значение
								Values[1]=0/0 --присвоим значение 'nan'
						end
						Core[OutputName..".Value"]=Values[1]
						--проведем проверку на тревоги
						
							if Values[1]<=AI_Signals[InputName].LL-- если зафиксировали нижнюю аварийную границу
							then	
								if AI_Signals[InputName].LL_check==true -- если проверка включена
								then
								Add_AI_Alarm({InputName,"LL"})--создать сообщение о нижней аварийной границе
								end--AI_Signals[InputName].LL_check
				
						elseif Values[1]>AI_Signals[InputName].LL and Values[1]<=AI_Signals[InputName].LH-- если зафиксировали нижнюю предупредительную границу
							then	
							if AI_Signals[InputName].LH_check==true -- если проверка включена
								then
									Add_AI_Alarm({InputName,"LH"})--создать сообщение о нижней предупредительной границе
								end--AI_Signals[InputName].LH_check
						elseif Values[1]>AI_Signals[InputName].LH and Values[1]<AI_Signals[InputName].HL-- если зафиксировали нижнюю предупредительную границу
							then	
									Add_AI_Alarm({InputName,"DIS"}) -- деактивировать предыдущую тревогу
									--return -- ничего не делать - значение в норме
						elseif Values[1]>=AI_Signals[InputName].HL and Values[1]<AI_Signals[InputName].HH-- если зафиксировали верхнюю предупредительную границу
							then	
								if AI_Signals[InputName].HL_check==true -- если проверка включена
								then
										--CurrentAiAlarms["HL"][InputName]=true
										Add_AI_Alarm({InputName,"HL"}) --создать сообщение о верхней предупредительной границе
								end--AI_Signals[InputName].HL_check	
						elseif Values[1]>=AI_Signals[InputName].HH -- если зафиксировали верхнюю границу аварийную границу
							then	
								if AI_Signals[InputName].HH_check==true -- если проверка включена
								then
										Add_AI_Alarm({InputName,"HH"})--создать сообщение о верхней аварийной границе
								end--AI_Signals[InputName].HH_check
						else return
						end --Values[1]<=AI_Signals[InputName].BR
			   	   end --Signals[InputName]["repaireFlag"]==false
				end --AI_Signals[InputName]==nil then -- если сигнал в таблице не описан
end --of Process_AI_Data(Signal) 

local function Process_DO_Data(Signal) -- обработка выходных дискретов

				local pulse_timer=3 --длительность удержания выходного контакта
				local Output_Tag=ObjID..Signal[2]..".Value"  -- имя тега
				local Comment=DO_Signals[Signal[1]]["Comment"] -- комментарий к тегу
				local Txt_1=DO_Signals[Signal[1]]["Txt_1"]  -- текст при значении true
				local Txt_0=DO_Signals[Signal[1]]["Txt_0"] -- текст при значении false
				local Fix_cont=DO_Signals[Signal[1]]["Fix_Con"] -- флаг фиксации контактов после исполнения команды
				local InvFlag=DO_Signals[Signal[1]]["InvFlag"] --флаг инверсии сигнала
				local Valid=DO_Signals[Signal[1]]["reliabilityFlag"]-- --значение флага достоверности
				local Repaire=Core[ObjID..Signal[2]..".repaireFlag"]--значение флага вывода сигнала в ремонт
				--local Output_Channel_val=Core[USO_ID..Signal[1]]
				local Output_Tag_Val=Core[ObjID..Signal[2]..".Value"] --значение тега

				local Msg= "Получена команда на изменение параметра '"..Comment.."' " --текст сообщения, начало
				if InvFlag==false --если инверсии нет
					then
						if Output_Tag_Val==true 
							then
								Msg=Msg..Txt_1.." " 
							else
								Msg=Msg..Txt_0.." "
							end--	if Output_Tag_Val==true 
					else
						 if Output_Tag_Val==true 
							then
								Msg=Msg..Txt_0.." " 
							else
								Msg=Msg..Txt_1.." "
							end--	if Output_Tag_Val==true 
				end --				if InvFlag==false
					Msg=Msg.."(тег ".. Output_Tag .. "). " --текст сообщения. финал


				if Repaire==true --если сигнал в ремонте
					then
						if Logs --если логи включны
							then
							Core.addLogMsg(Msg.. "Команда не выполнена из-за нахождения оборудования в ремонте. ("..USO_ID..Signal[1]..")")	
						end --		if Logs
						Core[ObjID..Signal[2]..".Value"]=not Output_Tag_Val --сбросим тег команды 
						return -- прекратить обработку
				end --				if Repaire==true
				if Valid==false --если значение недостоверно
					then
						if Logs
							then
							Core.addLogMsg(Msg.. "Команда не выполнена из-за недостоверности ПЛК. ("..USO_ID..Signal[1]..")")	
					--Core.addEvent() --делаем запись в строку сообщений
						end --		if Logs
						Core[ObjID..Signal[2]..".Value"]=not Output_Tag_Val --сбросим тег команды 
						return -- прекратить обработку
				end --				if Repaire==true

				if InvFlag==false --если инверсии нет
					then
						Core[USO_ID..Signal[1]]=Output_Tag_Val --передадим команду на выход
					else
						Core[USO_ID..Signal[1]]=not Output_Tag_Val --передадим инвертированную команду на выход
				end --	if InvFlag==false 
				Core[ObjID..Signal[2]..".dt"]=os.time()
				if Fix_cont==false --если контакты фиксировать не надо (импульсный сигнал)
					then					
						os.sleep(pulse_timer) -- держим паузу
						Core[USO_ID..Signal[1]]=not Output_Tag_Val --отпустим контакт
						Core[ObjID..Signal[2]..".Value"]=not Output_Tag_Val
					else
						return
				end --if Fix_cont==false
			
end --of Process_DO_Data(Signal) 


-- ///////////////////////Задание первоначальных значений переменных////////////////////
local function Init_DI_Data(Signal) --функция инициализации DI входа контроллера
-- переменные
local OutputName --имя выходного тега
local inputValue--значение входного тега
local OutputValue--  значение выходного тега
local InputName=string.gsub(Signal, ObjID, "") -- название необработанного сигнала со входа ПЛК игнорируя название усо
	if DI_Signals[InputName]==nil then -- если сигнал в таблице не описан
		Core.addLogMsg("Опрос "..InputName..". Для данного DI входа отсутствует описание в таблице DI_Signals") -- отправим сообщение об ошибке в логи
		return -- завершить работу функции Process_DI_Data
	else
		inputValue=Core[USO_ID..InputName] --получим значение входа ПЛК
		oldsignals[InputName]=inputValue -- сохраним его в буфер значений
		OutputName=ObjID..DI_Signals[InputName]["Tag"] --имя выходного тега присвоим
		OutputTag=OutputName..".Value" -- сформируем имя тэга (поле с текущим значением)
		Core[OutputTag]=inputValue -- передадим значение входа ПЛК тэгу
			--//синхронизация таблиц свойств сигналов (приоритет у ЛУА)
		-- описание параметра
			if  not DI_Signals[InputName]["Comment"] or string.len(DI_Signals[InputName]["Comment"])==0  --если не задано в луа
			then 
				local tmp_var=Core[OutputName..".Comment"] -- считаем из системы
				if  not tmp_var or string.len(tmp_var)==0 --==nil  --если и там пусто
					then 
						DI_Signals[InputName]["Comment"]=ObjDesc.."Описание переменной ".. tostring(OutputName) -- присвоим по умолчанию имя тэга
						Core[OutputName..".Comment"]=DI_Signals[InputName]["Comment"] -- и отправим в систему
					else
						DI_Signals[InputName]["Comment"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			else 
				Core[OutputName..".Comment"]=ObjDesc..DI_Signals[InputName]["Comment"] -- и отправим описание в систему
			end --Comment
			-- тестовое описание значения "1"
			if not DI_Signals[InputName]["Txt_1"] or string.len( DI_Signals[InputName]["Txt_1"])==0--если не задано в луа
			then 
				local tmp_var=Core[OutputName..".Txt_1"] -- считаем из системы
				if  not tmp_var or string.len(tmp_var)==0--если и там пусто
					then 
						DI_Signals[InputName]["Txt_1"]=" присвоено значение '1'" -- присвоим по умолчанию имя тэга
						Core[OutputName..".Txt_1"]=DI_Signals[InputName]["Txt_1"] -- и отправим в систему
					else 
						DI_Signals[InputName]["Txt_1"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else 		
				Core[OutputName..".Txt_1"]=DI_Signals[InputName]["Txt_1"] -- отправим в систему
			 end --Txt_1
			-- тестовое описание значения "0"
			if not DI_Signals[InputName]["Txt_0"] or 	string.len(DI_Signals[InputName]["Txt_0"])==0 --если не задано в луа
			then 
				local tmp_var=Core[OutputName..".Txt_0"] -- считаем из системы
				if not tmp_var or string.len(tmp_var)==0--если и там пусто
					then 
						DI_Signals[InputName]["Txt_0"]=DI_Signals[InputName]["Txt_1"] -- присвоим по умолчанию имя тэга (для состояния "1")
						Core[OutputName..".Txt_0"]=DI_Signals[InputName]["Txt_1"] -- и отправим в систему
					else 
						DI_Signals[InputName]["Txt_0"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else 
		    		Core[OutputName..".Txt_0"]=DI_Signals[InputName]["Txt_0"] --  отправим в систему
			 end --Txt_0
			-- тестовый источник сигнала
			if not DI_Signals[InputName]["Source"] or 	string.len(DI_Signals[InputName]["Source"])==0 --если не задано в луа
			then 
				local tmp_var=Core[OutputName..".Source"] -- считаем из системы
				if not tmp_var or string.len(tmp_var)==0--если и там пусто
					then 
						DI_Signals[InputName]["Source"]="Источник сигнала"  -- присвоим по умолчанию текст
						Core[OutputName..".Source"]=DI_Signals[InputName]["Source"] -- и отправим в систему
					else 
						DI_Signals[InputName]["Source"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else 
		    		Core[OutputName..".Source"]=DI_Signals[InputName]["Source"] --  отправим в систему
			 end --Source

			-- значение флага инверсии сигнала
			if not DI_Signals[InputName]["InvFlag"] --если не задано в луа
			then 
				local tmp_var=Core[OutputName..".InvFlag"] -- считаем из системы
				if not tmp_var --если и там пусто
					then 
						DI_Signals[InputName]["InvFlag"]=false -- присвоим по умолчанию значение "ложь"
						Core[OutputName..".InvFlag"]=DI_Signals[InputName]["InvFlag"] -- и отправим в систему
					else 
						DI_Signals[InputName]["InvFlag"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else 
				Core[OutputName..".InvFlag"]=DI_Signals[InputName]["InvFlag"] -- отправим в систему
			 end --InvFlag
			-- значение флага достоверности сигнала  
--[[
			if not DI_Signals[InputName]["reliabilityFlag"] or string.len(tostring(DI_Signals[InputName]["reliabilityFlag"]))==0--если не задано в луа
			then 
				local tmp_var=Core[OutputName..".reliabilityFlag"] -- считаем из системы
				if  not tmp_var or string.len(tostring(tmp_var))==0--если и там пусто
					then 
						DI_Signals[InputName]["reliabilityFlag"]=true -- присвоим по умолчанию значение "ложь"
						Core[OutputName..".reliabilityFlag"]=DI_Signals[InputName]["reliabilityFlag"] -- и отправим в систему
					else 
						DI_Signals[InputName]["reliabilityFlag"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else
				Core[OutputName..".reliabilityFlag"]=DI_Signals[InputName]["reliabilityFlag"] -- отправим в систему
			 end --reliabilityField
]]--


			-- значение флага запрета опроса сигнала (вывода в ремонт) 
			if not DI_Signals[InputName]["repaireFlag"] or string.len(tostring(DI_Signals[InputName]["repaireFlag"]))==0--если не задано в луа
			then 
				local tmp_var=Core[OutputName..".repaireFlag"] -- считаем из системы
				if  not tmp_var or string.len(tostring(tmp_var))==0--если и там пусто
					then 
						DI_Signals[InputName]["repaireFlag"]=false-- присвоим по умолчанию значение "ложь"
						Core[OutputName..".repaireFlag"]=DI_Signals[InputName]["repaireFlag"] -- и отправим в систему
					else 
						DI_Signals[InputName]["repaireFlag"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else
				Core[OutputName..".repaireFlag"]=DI_Signals[InputName]["repaireFlag"] -- отправим в систему
			 end --repaireFlag
			-- значение флага создания сообщений и событии (аварии)
			if not DI_Signals[InputName]["AlarmClass"] or string.len(DI_Signals[InputName]["AlarmClass"])==0 --если не задано в луа
			then 
					local tmp_var=Core[OutputName..".AlarmClass"] -- считаем из системы
					if  not tmp_var or string.len(tmp_var)==0  --если и там пусто
					then 
						DI_Signals[InputName]["AlarmClass"]=event.disabled -- присвоим по умолчанию значение не создавать сообщения
						Core[OutputName..".AlarmClass"]=DI_Signals[InputName]["AlarmClass"] -- и отправим в систему
					--else --если что-то в значении есть...
					end --tmp_var
			else --если в таблице не пусто
					local tmp_var=DI_Signals[InputName]["AlarmClass"] -- считаем из таблицы
					local found_in_events=false -- флаг нахождения типа события в описании
						for al_type, al_type_val in pairs(event) --проверка класса аларма по таблице event
						do 
							if 	tmp_var==al_type or tmp_var==al_type_val --если тип описан в таблице, то присвоим
							then 

								DI_Signals[InputName]["AlarmClass"]=al_type_val 
								Core[OutputName..".AlarmClass"]=al_type_val
								found_in_events=true -- найдено
								break
	
							end--if 	tmp_var==al_type or tmp_var==al_type_val
						end --al_type, al_type_val in pairs(event)
						if found_in_events==false -- если событие в таблице не описано
						then
								DI_Signals[InputName]["AlarmClass"]=event.disabled  --отключим
								Core[OutputName..".AlarmClass"]=event.disabled
						end
			end --AlarmClass
			-- текст тревожного сообщения
			if not DI_Signals[InputName]["AlarmMsg"] or string.len(DI_Signals[InputName]["AlarmMsg"])==0 --если не задано в луа
			then 
				local tmp_var=Core[OutputName..".AlarmMsg"] -- считаем из системы
				if not tmp_var or string.len(tmp_var)==0--если и там пусто
					then 
						DI_Signals[InputName]["AlarmMsg"]="Возникновение события для тэга: ".. tostring(OutputName) -- присвоим по умолчанию имя тэга
						Core[OutputName..".AlarmMsg"]=DI_Signals[InputName]["AlarmMsg"] -- и отправим в систему
					else 
						DI_Signals[InputName]["AlarmMsg"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else 
					 Core[OutputName..".AlarmMsg"]=DI_Signals[InputName]["AlarmMsg"] --  отправим в систему
			 end --AlarmMsg    
	end --DI_Signals[InputName]



	-- значение флага достоверности сигнала  
		local reliabilityField=Core[OutputName..".reliabilityField"]--значение поля достоверности
				if reliabilityField==0 -- - если значение поля достоверности сигнала нулевое - 
					then 	
						reliabilityFlag=true --достоверно
				else
						reliabilityFlag=false --недостоверно
				end --Core[OutputName..".reliabilityField"]==0
					DI_Signals[InputName]["reliabilityFlag"] =reliabilityFlag --значение в локальную таблицу
					Core[OutputName..".reliabilityFlag"]=reliabilityFlag -- отправим в систему


end --of Init__DI_Data

--//////////////////////////////////////////////////////////
local function Init_DO_Data(Signal) --функция инициализации DI входа контроллера
	if not DO_Signals[Signal].Comment or string.len(DO_Signals[Signal].Comment) <1  -- Описание сигнала
	then
		Core[ObjID..DO_Signals[Signal].Tag..".Comment"]="Дискретный выход ".. Signal	--значение по умолчанию
	else			
		Core[ObjID..DO_Signals[Signal].Tag..".Comment"]=DO_Signals[Signal].Comment
	end --if DO_Signals[Signal].Comment==nil 

	if not DO_Signals[Signal].Txt_0 or string.len(DO_Signals[Signal].Txt_0) <1  -- Описание состояния false
	then
		Core[ObjID..DO_Signals[Signal].Tag..".Txt_0"]=0 -- --значение по умолчанию
	else
		Core[ObjID..DO_Signals[Signal].Tag..".Txt_0"]=DO_Signals[Signal].Txt_0
	end --if not DO_Signals[Signal].Txt_0 or string.len(DO_Signals[Signal].Txt_0) <1

	if not DO_Signals[Signal].Txt_1 or string.len(DO_Signals[Signal].Txt_1) <1  -- Описание состояния true
	then
		Core[ObjID..DO_Signals[Signal].Tag..".Txt_1"]=1 --значение по умолчанию
	else
		Core[ObjID..DO_Signals[Signal].Tag..".Txt_1"]=DO_Signals[Signal].Txt_1 
	end --if not DO_Signals[Signal].Txt_1 or string.len(DO_Signals[Signal].Txt_1) <1

	--if not DO_Signals[Signal].InvFlag   -- флаг инверсии сигнала
--	then
--		Core[ObjID..DO_Signals[Signal].Tag..".InvFlag"]=false --значение по умолчанию
--	else
--		Core[ObjID..DO_Signals[Signal].Tag..".InvFlag"]=DO_Signals[Signal].InvFlag 
--	end --	if not DO_Signals[Signal].InvFlag 

	if not DO_Signals[Signal].repaireFlag   -- флаг вывода из обработки
	then
		Core[ObjID..DO_Signals[Signal].Tag..".repaireFlag"]=false --значение по умолчанию
	else
		Core[ObjID..DO_Signals[Signal].Tag..".repaireFlag"]=DO_Signals[Signal].repaireFlag 
	end --	if not DO_Signals[Signal].repairelag 

	--[[if not DO_Signals[Signal].reliabilityFlag   -- флаг достоверности
	then
		Core[ObjID..DO_Signals[Signal].Tag..".reliabilityFlag"]=false --значение по умолчанию
	else
		Core[ObjID..DO_Signals[Signal].Tag..".reliabilityFlag"]=DO_Signals[Signal].reliabilityFlag 
	end --	if not DO_Signals[Signal].reliabilityFlag 
]]--
	if not DO_Signals[Signal].Fix_Con   -- признак фиксации контактов реле после подачи на выход команды
	then
		Core[ObjID..DO_Signals[Signal].Tag..".Fix_Con"]=false --значение по умолчанию - импульсная команда
	else
		Core[ObjID..DO_Signals[Signal].Tag..".Fix_Con"]=DO_Signals[Signal].Fix_Con 
	end --	if not DO_Signals[Signal].Fix_Con


	-- значение флага достоверности сигнала  
		local reliabilityField=Core[ObjID..DO_Signals[Signal].Tag..".reliabilityField"]--значение поля достоверности
				if reliabilityField==0 -- - если значение поля достоверности сигнала нулевое - 
					then 	
						reliabilityFlag=true --достоверно
				else
						reliabilityFlag=false --недостоверно
				end --Core[OutputName..".reliabilityField"]==0
					DO_Signals[Signal]["reliabilityFlag"] =reliabilityFlag --значение в локальную таблицу
					Core[ObjID..DO_Signals[Signal].Tag..".reliabilityFlag"]=reliabilityFlag -- отправим в систему


end --of Init__DO_Data
--/////////////////////////////////////////////////////////

local function Init_AI_Data(Signal) --функция инициализации AI входа контроллера
-- переменные

local OutputName --имя выходного тега
local inputValue--значение входного тега
local OutputValue--  значение выходного тега
local reliabilityFlag --значение флага достоверности
local InputName=string.gsub(Signal, ObjID, "") -- название необработанного сигнала со входа ПЛК игнорируя название усо
	if AI_Signals[InputName]==nil then -- если сигнал в таблице не описан
		Core.addLogMsg("Опрос "..InputName..". Для данного AI входа отсутствует описание в таблице AI_Signals") -- отправим сообщение об ошибке в логи
		return -- завершить работу функции Process_AI_Data
	else
		inputValue=Core[USO_ID..InputName] --получим значение входа ПЛК
		OutputName=ObjID..AI_Signals[InputName]["Tag"] --имя выходного тега присвоим
		OutputTag=OutputName..".Value" -- сформируем имя тэга (поле с текущим значением)
		Core[OutputTag]=inputValue -- передадим значение входа ПЛК тэгу
		-- иницализуем таблицу действующих для параметра тревог
				for AlarmTypes, _  in pairs(CurrentAiAlarms) -- в таблице действующих тревог
				do	
					if CurrentAiAlarms[AlarmTypes][InputName]==nil -- если не описана
					then
						CurrentAiAlarms[AlarmTypes][InputName]=false -- считаем, что тревоги нет
					end -- CurrentAiAlarms[AlarmTypes][InputName]==nil
				end --_,  AlarmTypes	
			--//синхронизация таблиц свойств сигналов (приоритет у ЛУА)
			-- описание параметра
			if  not AI_Signals[InputName]["Comment"] or string.len(AI_Signals[InputName]["Comment"])==0  --если не задано в луа
			then 
				local tmp_var=ObjDesc..Core[OutputName..".Comment"] -- считаем из системы
				if  not tmp_var or string.len(tmp_var)==0 --==nil  --если и там пусто
					then 
						AI_Signals[InputName]["Comment"]="Описание переменной ".. tostring(OutputName) -- присвоим по умолчанию имя тэга
						Core[OutputName..".Comment"]=AI_Signals[InputName]["Comment"] -- и отправим в систему
					else
						AI_Signals[InputName]["Comment"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			else 
				Core[OutputName..".Comment"]=ObjDesc..AI_Signals[InputName]["Comment"] -- и отправим описание в систему
			end --Comment


		-- текстовый источник сигнала
			if not AI_Signals[InputName]["Source"] or 	string.len(AI_Signals[InputName]["Source"])==0 --если не задано в луа
			then 
				local tmp_var=Core[OutputName..".Source"] -- считаем из системы
				if not tmp_var or string.len(tmp_var)==0--если и там пусто
					then 
						AI_Signals[InputName]["Source"]="Источник сигнала"  -- присвоим по умолчанию текст
						Core[OutputName..".Source"]=DI_Signals[InputName]["Source"] -- и отправим в систему
					else 
						AI_Signals[InputName]["Source"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else 
		    		Core[OutputName..".Source"]=AI_Signals[InputName]["Source"] --  отправим в систему
			 end --Source
        -- значение флага создания сообщений и событии (аварии)ОТКЛЮЧЕНО В СВЯЗИ С ФОРМИРОВАНИЕМ СООБЩЕНИЯ АВТОМАТИЧЕСКИ В ФУНКЦИИ   Add_AI_Alarm(Signal), ОСТАВЛЕНО ДЛЯ ВАРИАЦИИ
		--	if not AI_Signals[InputName]["AlarmClass"] or string.len(AI_Signals[InputName]["AlarmClass"])==0 --если не задано в луа
		--	then 
		--			local tmp_var=Core[OutputName..".AlarmClass"] -- считаем из системы
		--			if  not tmp_var or string.len(tmp_var)==0  --если и там пусто
		--			then 
		--				AI_Signals[InputName]["AlarmClass"]=event.disabled -- присвоим по умолчанию значение не создавать сообщения
		--				Core[OutputName..".AlarmClass"]=AI_Signals[InputName]["AlarmClass"] -- и отправим в систему
		--			--else --если что-то в значении есть...
				--			
		--			end --tmp_var
		--	else --если в таблице не пусто
		--			local tmp_var=AI_Signals[InputName]["AlarmClass"] -- считаем из таблицы
		--			local found_in_events=false -- флаг нахождения типа события в описании
		--						--Core.addLogMsg(tostring(DI_Signals[InputName]["AlarmClass"]))
		--				for al_type, al_type_val in pairs(event) --проверка класса аларма по таблице event
		--				do 
		--					if 	tmp_var==al_type or tmp_var==al_type_val --если тип описан в таблице, то присвоим
		--					then 
		--						--Core.addLogMsg(tostring(DI_Signals[InputName]["Tag"]).." "..tostring(al_type).. " "..tostring(al_type_val))
		--						AI_Signals[InputName]["AlarmClass"]=al_type_val 
		--						Core[OutputName..".AlarmClass"]=al_type_val
		--						found_in_events=true -- найдено
		--						break
	--		  				end--if 	tmp_var==al_type or tmp_var==al_type_val
		--				end --al_type, al_type_val in pairs(event)
			--			if found_in_events==false -- если событие в таблице не описано
			--			then
			--					AI_Signals[InputName]["AlarmClass"]=event.disabled  --отключим
			--					Core[OutputName..".AlarmClass"]=event.disabled
			--			end--found_in_events==false
			--end --AlarmClass	
	end --AI_Signals[InputName]
-- текст тревожного сообщения - ОТКЛЮЧЕНО В СВЯЗИ С ФОРМИРОВАНИЕМ СООБЩЕНИЯ АВТОМАТИЧЕСКИ В ФУНКЦИИ   Add_AI_Alarm(Signal), ОСТАВЛЕНО ДЛЯ ВАРИАЦИИ
--			if not AI_Signals[InputName]["AlarmMsg"] or string.len(AI_Signals[InputName]["AlarmMsg"])==0 --если не задано в луа
	--		then 
		--		local tmp_var=Core[OutputName..".AlarmMsg"] -- считаем из системы
			--	if not tmp_var or string.len(tmp_var)==0--если и там пусто
				--	then 
					--	AI_Signals[InputName]["AlarmMsg"]=ObjDesc.."Тревожное сообщение величины: ".. tostring(OutputName) -- присвоим по умолчанию имя тэга
					--	Core[OutputName..".AlarmMsg"]=AI_Signals[InputName]["AlarmMsg"] -- и отправим в систему
					--else 
					--	AI_Signals[InputName]["AlarmMsg"]=tmp_var -- иначе присвоим значение из системы
					--end --tmp_var
			-- else 
				--	 Core[OutputName..".AlarmMsg"]=ObjDesc..AI_Signals[InputName]["AlarmMsg"] --  отправим в систему
			 --end --AI_Signals[InputName]["AlarmMsg"]
-- значение флага запрета опроса сигнала (вывода в ремонт) 
			if not AI_Signals[InputName]["repaireFlag"] or string.len(tostring(AI_Signals[InputName]["repaireFlag"]))==0--если не задано в луа
			then 
				local tmp_var=Core[OutputName..".repaireFlag"] -- считаем из системы
				if  not tmp_var or string.len(tostring(tmp_var))==0--если и там пусто
					then 
						AI_Signals[InputName]["repaireFlag"]=false-- присвоим по умолчанию значение "ложь"
						Core[OutputName..".repaireFlag"]=AI_Signals[InputName]["repaireFlag"] -- и отправим в систему
					else 
						AI_Signals[InputName]["repaireFlag"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else
				Core[OutputName..".repaireFlag"]=AI_Signals[InputName]["repaireFlag"] -- отправим в систему
			 end --repaireFlag
		

-- значение границы нижнего аварийного значения
			
			if AI_Signals[InputName]["LL_check"] ==true
			then 
				if not AI_Signals[InputName]["LL"] or string.len(tostring(AI_Signals[InputName]["LL"]))==0--если не задано в луа
				then
					local tmp_var=Core[OutputName..".LL"] -- считаем из системы	
					if  not tmp_var or tmp_var==0--если и там пусто
					then
						Core[OutputName..".LL"]=dis_border_val	
						 AI_Signals[InputName]["LL"]=dis_border_val	
						 AI_Signals[InputName]["LL_check"]=false
					else
						 AI_Signals[InputName]["LL"]=tmp_var	
					end --not tmp_var
				else 
						Core[OutputName..".LL"]=AI_Signals[InputName]["LL"]	
				end	--not AI_Signals			
			else
					Core[OutputName..".LL"]=dis_border_val	
			end-- AI_Signals[InputName]["LL_check"] ==true

-- значение границы нижнего предупредительного значения
			
			if AI_Signals[InputName]["LH_check"] ==true
			then 
				if not AI_Signals[InputName]["LH"] or string.len(tostring(AI_Signals[InputName]["LH"]))==0--если не задано в луа
				then
					local tmp_var=Core[OutputName..".LH"] -- считаем из системы	
					if  not tmp_var or tmp_var==0--если и там пусто
					then
						Core[OutputName..".LH"]=dis_border_val	
						 AI_Signals[InputName]["LH"]=dis_border_val	
						 AI_Signals[InputName]["LH_check"]=false
					else
						 AI_Signals[InputName]["LH"]=tmp_var	
					end --not tmp_var
				else 
						Core[OutputName..".LH"]=AI_Signals[InputName]["LH"]	
				end	--not AI_Signals			
			else
					Core[OutputName..".LH"]=dis_border_val	
			end-- AI_Signals[InputName]["LH_check"] ==true
-- значение границы верхнего предупредительного значения	
			if AI_Signals[InputName]["HL_check"] ==true
			then 
				if not AI_Signals[InputName]["HL"] or string.len(tostring(AI_Signals[InputName]["HL"]))==0--если не задано в луа
				then
					local tmp_var=Core[OutputName..".HL"] -- считаем из системы	
					if  not tmp_var or tmp_var==0--если и там пусто
					then
						Core[OutputName..".HL"]=dis_border_val	
						 AI_Signals[InputName]["HL"]=dis_border_val	
						 AI_Signals[InputName]["HL_check"]=false
					else
						 AI_Signals[InputName]["HL"]=tmp_var	
					end --not tmp_var
				else 
						Core[OutputName..".HL"]=AI_Signals[InputName]["HL"]	
				end	--not AI_Signals			
			else
					Core[OutputName..".HL"]=dis_border_val	
			end-- AI_Signals[InputName]["HL_check"] ==true
	-- значение границы верхнего аварийного значения
			if AI_Signals[InputName]["HH_check"] ==true
			then 
				if not AI_Signals[InputName]["HH"] or string.len(tostring(AI_Signals[InputName]["HH"]))==0--если не задано в луа
				then
					local tmp_var=Core[OutputName..".HH"] -- считаем из системы	
					if  not tmp_var or tmp_var==0--если и там пусто
					then
						Core[OutputName..".HH"]=dis_border_val	
						 AI_Signals[InputName]["HH"]=dis_border_val	
						 AI_Signals[InputName]["HH_check"]=false
					else
						 AI_Signals[InputName]["HH"]=tmp_var	
					end --not tmp_var
				else 
						Core[OutputName..".HH"]=AI_Signals[InputName]["HH"]	
				end	--not AI_Signals			
			else
					Core[OutputName..".HH"]=dis_border_val	
			end-- AI_Signals[InputName]["HH_check"] ==true	




	
	-- значение флага достоверности сигнала  
		local reliabilityField=Core[OutputName..".reliabilityField"]--значение поля достоверности
		--[[	if not AI_Signals[InputName]["reliabilityFlag"] or string.len(tostring(AI_Signals[InputName]["reliabilityFlag"]))==0--если не задано в луа
			then 
				local tmp_var=Core[OutputName..".reliabilityFlag"] -- считаем из системы
				if  not tmp_var or string.len(tostring(tmp_var))==0--если и там пусто
					then 
						AI_Signals[InputName]["reliabilityFlag"]=true -- присвоим по умолчанию значение "ложь"
						Core[OutputName..".reliabilityFlag"]=AI_Signals[InputName]["reliabilityFlag"] -- и отправим в систему
					else 
						AI_Signals[InputName]["reliabilityFlag"]=tmp_var -- иначе присвоим значение из системы
					end --tmp_var
			 else
				Core[OutputName..".reliabilityFlag"]=AI_Signals[InputName]["reliabilityFlag"] -- отправим в систему
			 end --reliabilityFlag		]]--

				if reliabilityField==0 -- - если значение поля достоверности сигнала нулевое - 
					then 	
						reliabilityFlag=true --достоверно
				else
						reliabilityFlag=false --недостоверно
				end --Core[OutputName..".reliabilityField"]==0
					AI_Signals[InputName]["reliabilityFlag"] =reliabilityFlag --значение в локальную таблицу
					Core[OutputName..".reliabilityFlag"]=reliabilityFlag -- отправим в систему

	
end --of Init_AI_Data


local function SetReliabilityFlag(Signal)-- функция включения\отключения флага достоверности сигнала из вне
	local DI_Channel=Signal[1] -- присвоим ссылку на таблицу дискретных сигналов
	local AI_Channel=Signal[1]-- присвоим ссылку на таблицу аналоговых сигналов
	local Signal_type= Signal[3] ---- присвоим ссылку на имя тега
	local ReliabilityFlield=Core[Signal[2]]---- получим из системы значение тега поля достоверности
	local ReliabilityFlag -- переменная флага достоверности
	
	
	if ReliabilityFlield== 0 -- если битовое поле достоверности пустое
	then 
				ReliabilityFlag=true --сигнал достоверен
	else 	-- иначе
				ReliabilityFlag=false --сигнал недостоверен
	end --if ReliabilityFlield== 0

	if Signal_type=="AI" -- если изменилась достоверность входного аналога
		then
			local AI_data=Core[ObjID..AI_Signals[AI_Channel].Tag..".Value"]
			Core.addLogMsg("SetReliabilityFlag: " .. ObjID..AI_Signals[AI_Channel].Tag..".Value=".. AI_data)
			AI_Signals[AI_Channel]["reliabilityFlag"]=ReliabilityFlag -- внесем запись в таблицу аналоговых сигналов
			Core[ObjID..AI_Signals[AI_Channel].Tag..".reliabilityFlag"]=ReliabilityFlag -- внесем запись в таблицу свойств сигнала в ядре
			if ReliabilityFlag==false then --если сигнал стал недостоверен
				if 	OldAIValueFlag==false	then --если последнее достоверное значение не фиксировалось
						Core[ObjID..AI_Signals[AI_Channel].Tag..".OldValue"]=AI_data --зафиксировать
						OldAIValueFlag=true  --установить флаг фиксации последнего достоверного значения
				end--if 	OldAIValueFlag==false
				Core[ObjID..AI_Signals[AI_Channel].Tag..".Value"]=0/0 --присвоим занчению переменной 'nan' чтобы не писались тренды
			else
				OldAIValueFlag=false  --сбросить флаг фиксации последнего достоверного значения
			end
	elseif Signal_type=="DI"-- если изменилась достоверность входного дискрета
		then
			 DI_Signals[DI_Channel]["reliabilityFlag"]=ReliabilityFlag-- внесем запись в таблицу дискретных сигналов
			Core[ObjID..DI_Signals[DI_Channel].Tag..".reliabilityFlag"]=ReliabilityFlag -- внесем запись в таблицу свойств сигнала в ядре
	elseif 	Signal_type=="DO"-- если изменилась достоверность выходного дискрета
		then
		Core.addLogMsg(Signal[1])
			DO_Signals[Signal[1]]["reliabilityFlag"]=ReliabilityFlag-- внесем запись в таблицу дискретных выходов
			Core[ObjID..DO_Signals[Signal[1]].Tag..".reliabilityFlag"]=ReliabilityFlag -- внесем запись в таблицу свойств сигнала в ядре
	else 
		return
	end --	Signal_type=="AI"

end --function SetReliabilityFlag(Signal)

--[[ в текущей редакции функция выведена в скрипт проверки данных Status
local function SetRepaireMode(Signal)-- функция включения\отключения ремонтного режима
	local InputName=Signal[1]
	local DI_Channel=ObjID..Signal[1]
	local AI_Channel=Signal[1]
	local Signal_type= Signal[3]
	local e_type -- появление - исчезновение события 
	local repaireFlagValue=Core[Signal[2]] --
--[[	local repaireField --
	local STable --выбор таблицы в зависимости от типа сигнала
	if Signal_type=="DI" -- если изменилось свойство входного дискрета
	then
		STable=DI_Signals[InputName] -- смотрим таблицу дискретов
	else
		if  Signal_type=="AI"-- если изменилось свойство входного аналога
		then
			STable=AI_Signals[InputName]	-- смотрим таблицу аналогов
		else	
			return -- завершим работу функции если задано что-то иное
		end --	Signal_type=="AI"
	end --	Signal_type=="DI"

		
	if repaireFlagValue~=STable["repaireFlag"]--!!!!!!!!!!!!!!1 --если значение флага в системе и в таблице не совпадают
	then
		STable["repaireFlag"]=repaireFlagValue
		repaireField=Core[ObjID..STable["Tag"]..".reliabilityField"]-- получим из ядра битовое поле признака достоверности сигнала
				if STable["repaireFlag"]==true 
					then
						e_type=1 --событие появилось
						--STable["reliabilityFlag"]=false-- сделаем параметр недостоверным
						repaireField=bit32.bor(repaireField,noValid.Rep)-- добавим признак ремонта
					else
						e_type=0 --событие исчезло
						repaireField=bit32.bxor(repaireField,noValid.Rep)
						-- STable["reliabilityFlag"]=true-- сделаем параметр достоверным

				 end --if DI_Signals[InputName]["repaireFlag"]==true 
				--Core[ObjID..STable["Tag"]..".reliabilityFlag"]=STable["reliabilityFlag"] --сохранаяем свойство сигнала
				Core[ObjID..STable["Tag"]..".reliabilityField"]=repaireField -- передадим  в ядро битовое поле признака достоверности сигнала
				SetReliabilityFlag({InputName,ObjID..STable["Tag"]..".reliabilityField",Signal_type})--вызов функции обновления флага достоверности
				if Signal_type=="DI" 
				then
						Core.addEvent("Значение параметра '".. ObjDesc.." " ..STable["Comment"]..STable["Txt_1"] .."' (тэг '"..ObjID..STable["Tag"].. "') недостоверно. Оборудование выведено в ремонт".." ("..e_type..")", event.dr, e_type, ObjID..string.gsub(PLC_Name,"_",""), User, STable.Tag, timestamp, ScreenID )
							if Logs -- если логи включены
								then Core.addLogMsg("Значение параметра '".. ObjDesc.." " ..STable["Comment"]..STable["Txt_1"] .."' (тэг '"..ObjID..STable["Tag"].. "') недостоверно. Оборудование выведено в ремонт_"..e_type.." "..User)	
							end --if Logs -- если логи включены
						if repaireFlagValue == false then Process_DI_Data({DI_Channel})end --если признак ремонта исчез - вызов функции отслеживания значения сигнала
				else
						Core.addEvent("Значение параметра '".. ObjDesc.." " ..STable["Comment"] .."' (тэг '"..ObjID..STable["Tag"].. "') недостоверно. Оборудование выведено в ремонт".." ("..e_type..")", event.dr, e_type, ObjID..string.gsub(PLC_Name,"_",""), User, STable.Tag,timestamp, ScreenID )
							if Logs -- если логи включены
								then	Core.addLogMsg("Значение параметра '".. ObjDesc.." " ..STable["Comment"] .."' (тэг '"..ObjID..STable["Tag"].. "') недостоверно. Оборудование выведено в ремонт_"..e_type.." "..User)	
							end --if Logs -- если логи включены
						if repaireFlagValue == false then Process_AI_Data({AI_Channel})end --если признак ремонта исчез - вызов функции отслеживания значения сигнала
				end		
	end --if repaireFlagValue~=STable["repaireFlag"]

end --local function SetRepaireMode
]]--

-- !!!Функция изменения значений аварийных уставок аналоговых сигналов
local function ChangeAlarmSettings(Signal)
		
	local AlarmSetType= string.sub(tostring(Signal[2]), -2) -- определяем тип изменяемой уставки
	AI_Signals[tostring(Signal[1])][AlarmSetType]=Core[tostring(Signal[2])] -- сохраним уставку в скрипте
end --function ChangeAlarmSettings(Signal)

-- ///////////////////////конец блока функций////////////////////

-- ///////////////////////main()////////////////////
-- опрашиваем первоначальное состояние входов контроллера и их свойств(инициализация)
	--	os.sleep(start_delay)
	for Module, ChNum in pairs(RawDI) --DI
		do 
			-- первом опросим все активные входы и занесем их значение в буфер oldsignals
			for _, Ch in pairs(ChNum) 
			do
				local DI_Channel=ObjID..PLC_Name..Module.."."..Ch -- сформируем полное имя канала
				Init_DI_Data(DI_Channel) --вызов функции инициализации входа
			end --_, Ch
	end --for Module, ChNum 	
	for Module, ChNum in pairs(RawAI) --AI
		do 
			-- первом опросим все активные входы 
			for _, Ch in pairs(ChNum) 
			do
				local AI_Channel=ObjID..PLC_Name..Module.."."..Ch -- сформируем полное имя канала
			--	os.sleep(0.1) --ждем 100 мс до инициализации аналогового входа ПЛК
				Init_AI_Data(AI_Channel) --вызов функции инициализации входа
			end --_, Ch
	end --for Module, ChNum 
	for Ch, _ in pairs(DO_Signals) --DO
			do 
				-- проверим появление команд от оператора
				local DO_Channel=DO_Signals[Ch]["Tag"]-- сформируем имя тега
				--Init_DO_Data(DO_Channel)
				Init_DO_Data(Ch)
	end --for Ch, _ 



--!!!!Дискретные входы!!!!---
-- отслеживаем изменения состояния дискретных входов и их состояния
		for Module, ChNum in pairs(RawDI)
			do 
				-- проверим изменение входов
				for _, Ch in pairs(ChNum) 
				do
					DI_Channel=USO_ID..PLC_Name..Module.."."..Ch -- сформируем полное имя канала
					--DI_Channel_status=USO_ID..PLC_Name..Module.."."..Ch.."_status" -- сформируем  имя статуса канала
					Core.onExtChange({DI_Channel}, Process_DI_Data,{DI_Channel, Module}) 
				--	Core.onExtChange({DI_Channel_status}, CheckChStatus,{"DI",DI_Channel}) 
					--Core.onExtChange({DI_Channel}, Init_DI_Data,{DI_Channel, true}) 	
				end --_, Ch
			end --for Module, ChNum 
	
-- проверим изменение оператором свойств   входных дискретных тегов 

		for Module, ChNum in pairs(RawDI)--дискретных
			do 			
				for _, Ch in pairs(ChNum) 
				do
					DI_Channel=PLC_Name..Module.."."..Ch -- сформируем  имя канала
				--	RepaireTag=ObjID..DI_Signals[DI_Channel].Tag..".repaireFlag"-- сформируем имя переменной вывода в ремонт
					--Core.onExtChange({RepaireTag}, SetRepaireMode,{DI_Channel,RepaireTag,"DI"}) 
					ReliabilityField=ObjID..DI_Signals[DI_Channel].Tag..".reliabilityField"-- сформируем  имя признака достоверности
					Core.onExtChange({ReliabilityField}, SetReliabilityFlag,{DI_Channel,ReliabilityField,"DI"}) 		
				end --_, Ch
		end --for Module, ChNum 
	
--!!!!Аналоговые входы!!!!---
-- отслеживаем изменения состояния аналоговых входов		
	for Module, ChNum in pairs(RawAI)
			do 
			for _, Ch in pairs(ChNum) 
				do
					AI_Channel=USO_ID..PLC_Name..Module.."."..Ch -- сформируем  имя канала
					Core.onExtChange({AI_Channel}, Process_AI_Data,{AI_Channel, Module}) 
				end --_, Ch
			end --for Module, ChNum 		

-- проверим изменение оператором свойств аналоговых сигналов
	for Module, ChNum in pairs(RawAI)
		do 			
				for _, Ch in pairs(ChNum) 
				do
					AI_Channel=PLC_Name..Module.."."..Ch -- сформируем  имя канала
					--RepaireTag=ObjID..AI_Signals[AI_Channel].Tag..".repaireFlag"-- сформируем переменной вывода в ремонт
					--Core.onExtChange({RepaireTag}, SetRepaireMode,{AI_Channel,RepaireTag,"AI"}) 
					AlarmSetHH=ObjID..AI_Signals[AI_Channel].Tag..".HH"-- сформируем адрес значения верхней аварийной уставки
					Core.onExtChange({AlarmSetHH}, ChangeAlarmSettings,{AI_Channel,AlarmSetHH}) 
					AlarmSetHL=ObjID..AI_Signals[AI_Channel].Tag..".HL"-- сформируем адрес значения верхней предупредительной уставки
					Core.onExtChange({AlarmSetHL}, ChangeAlarmSettings,{AI_Channel,AlarmSetHL})
					AlarmSetLH=ObjID..AI_Signals[AI_Channel].Tag..".LH"-- сформируем адрес значения нижней предупредительной уставки
					Core.onExtChange({AlarmSetLH}, ChangeAlarmSettings,{AI_Channel,AlarmSetLH})
					AlarmSetLL=ObjID..AI_Signals[AI_Channel].Tag..".LL"-- сформируем адрес значения нижней аварийной уставки
					Core.onExtChange({AlarmSetLL}, ChangeAlarmSettings,{AI_Channel,AlarmSetLL})
					--AlarmSetSC=ObjID..AI_Signals[AI_Channel].Tag..".SC"-- сформируем адрес значения КЗ
					--Core.onExtChange({AlarmSetSC}, ChangeAlarmSettings,{AI_Channel,AlarmSetSC})
					--AlarmSetBR=ObjID..AI_Signals[AI_Channel].Tag..".BR"-- сформируем адрес значения обрыва линии
					--Core.onExtChange({AlarmSetBR}, ChangeAlarmSettings,{AI_Channel,AlarmSetBR})
					ReliabilityField=ObjID..AI_Signals[AI_Channel].Tag..".reliabilityField"--  сформируем  имя признака достоверности
					Core.onExtChange({ReliabilityField}, SetReliabilityFlag,{AI_Channel,ReliabilityField,"AI"}) 

				end --_, Ch
		end --for Module, ChNum 	

-- отслеживаем изменения состояния дискретных выходов (команд от оператора)
	
			for Ch, _ in pairs(DO_Signals)
			do 
				-- проверим появление команд от оператора
				local DO_Channel=DO_Signals[Ch]["Tag"]-- сформируем имя тега
				--Core.onExtChange({ObjID..DO_Channel..".reliabilityField"}, SetReliabilityFlag,{Ch,ObjID..DO_Channel..".reliabilityField","DO"}) --проверим обновление флага достоверности
				--Core.onExtChange({ObjID..DO_Channel..".repaireFlag"}, SetRepaireMode,{Ch,ObjID..DO_Channel..".repaireFlag","DO"}) --проверим обновление флага вывода в ремонт
				Core.onExtChange({ObjID..DO_Channel..".Value"}, Process_DO_Data,{Ch,DO_Channel}) --проверим обновление тега
--				ReliabilityField=ObjID..DO_Channel..".reliabilityField"-- сформируем  имя признака достоверности
	--			Core.onExtChange({ReliabilityField}, SetReliabilityFlag,{DO_Channel,ReliabilityField,"DO"}) 
			end --for Ch, _ 
-- отслеживаем изменения достоверности дискретных выходов ()
		for Module, ChNum in pairs(RawDO)
		do 			
				for _, Ch in pairs(ChNum) 
				do
					DO_Channel=PLC_Name..Module.."."..Ch -- сформируем  имя канала
					ReliabilityField=ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"--  сформируем  имя признака достоверности
					Core.onExtChange({ReliabilityField}, SetReliabilityFlag,{DO_Channel,ReliabilityField,"DO"}) 

				end --_, Ch
		end --for Module, ChNum 	





Core.waitEvents( )