local ScreenID="ZRU"
local e_type
local Logs=true
local USO_ID="USOE_"
local ObjID="GSP_SEV_KSSEV_E_"..USO_ID
local PLC_Name="A1_"
local PLC_Desc="УСО Э. ПЛК A1. "
local ObjDesc= "ЗРУ-10кВ. "


--  ver/ 16-08-17
-- скрипт установления достоверности сигнала в зависимости от состояния модуля и канала.

local event =require("./_events_desc"); -- считаем описание классов аварийных сообщений
local User=PLC_Desc..string.gsub(PLC_Name,"_"," ").. "(система)"
local ChannelFaults={} -- стек отказов каналов модулей
local Faults = { -- таблица значений отказов 
				unknouwn=32, --состояние неизвестно
				sc=8,  -- КЗ
				br=4,  -- обрыв
				crash=2, --отказ
				fault=1, -- частично неисправно или не отвечает
				no=0,  -- ошибок нет, всё в порядке
				 }

-- //Загрузка конфигурации из файлов
--........................................................
local RawDI=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "DI_map") --считываем конфигурацию дискретных входов ПЛК
local RawAI=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "AI_map") --считываем конфигурацию аналоговых входов ПЛК
local RawDO=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "DO_map") --считываем конфигурацию дискретных выходов ПЛК
local DI_Signals=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "DI_data") --считываем базу дискретных тегов и их свойств
local AI_Signals=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "AI_data") --считываем базу аналоговых тегов и их свойств
local DO_Signals=require("./PLC_config/".. string.gsub(USO_ID,"_","").."/"..string.gsub(PLC_Name,"_","").."/".. "DO_data") --считываем базу дискретных выходов и их свойств
--........................................................
local noValid =require("./_reliabilityField"); -- считаем описание битового поля недостоверности сигнала

--.......добавление событий о недостоверности сигнала со входа ПЛК  
local function add_DR_msg(ModuleStat) -- добавление событий о недостоверности сигнала со входа ПЛК
--	local DR_Value=Core[ModuleStat[2]] -- достоверно/недостоверно
	local timestamp=os.time(); -- метка времени
    local AlarmMsg -- собщение в строку
	local e_type -- появление/исчезновение
--	local connect=Core[ObjDesc..PLC_Name.."FAULT.CPU"]
	if Core[ModuleStat[2]]>Faults.no
	then 
		e_type=1
	--	DR_Value=false
	 else
		 e_type=0
	--	DR_Value=true
	 end -- если достоверно,
	local reliabilityField -- поле недостоверности сигнала
	--выводим сообщение о состоянии модуля
	AlarmMsg=PLC_Desc.." Неисправен модуль "..string.gsub(PLC_Name,"_",".")..ModuleStat[1]
	if Logs then
		Core.addLogMsg(AlarmMsg.." ("..e_type..") ".. event.w.." ".. e_type.." ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. ModuleStat[2].." ".. timestamp.." ".. ScreenID) --в логи
	end --Logs
	Core.addEvent(AlarmMsg, event.w, e_type, USO_ID..string.gsub(PLC_Name,"_",""), User, ModuleStat[2], timestamp, ScreenID)--в строку событий
	--выводим сообщения о недостоверности сигналов

	for Module, ChNum in pairs(RawDI) --проидемся списку дискретных модулей 
			do 
				if Module==ModuleStat[1] -- если номер модуля соответствует неисправному - выведем сообщения для всех каналов
				then 
							for _, Ch in pairs(ChNum) -- пройдемся по каналам
							do
									DI_Channel=PLC_Name..ModuleStat[1].."."..Ch -- сформируем полное имя канала
									AlarmMsg=ObjDesc..DI_Signals[DI_Channel].Comment..DI_Signals[DI_Channel].Txt_1..". ЗНАЧЕНИЕ НЕДОСТОВЕРНО"-- сформируем текст сообщения								
 									reliabilityField=Core[ObjID..DI_Signals[DI_Channel].Tag..".reliabilityField"]-- считаем слово достоверности
									if e_type==1 --если событие произошло
									then
										reliabilityField=bit32.bor(reliabilityField,noValid.Mod) --добавим в слово достоверности бит неисправности модуля ПЛК
									else 
										reliabilityField=bit32.bxor(reliabilityField,noValid.Mod) --уберем из слова достоверности бит неисправности модуля
									end --	if e_type==1
									Core[ObjID..DI_Signals[DI_Channel].Tag..".reliabilityField"]=reliabilityField -- передадим в ядро  слово достоверности 
									if Logs -- если логи включены
										then Core.addLogMsg(AlarmMsg.. " " ..  tostring(reliabilityField).." "..User)
									end --if Logs 
 									Core.addEvent(AlarmMsg, event.dr, e_type, USO_ID..string.gsub(PLC_Name,"_",""), User, ObjID..DI_Signals[DI_Channel].Tag, timestamp, ScreenID)

							end --_, Ch
				end --if
	end --Module, ChNum in pairs(RawDI

	for Module, ChNum in pairs(RawAI) --проидемся списку аналоговых модулей 
			do 
				if Module==ModuleStat[1] -- если номер модуля соответствует неисправному - выведем сообщения для всех каналов
				then 
							for _, Ch in pairs(ChNum) -- пройдемся по каналам
							do
									AI_Channel=PLC_Name..ModuleStat[1].."."..Ch -- сформируем полное имя канала
									AlarmMsg=ObjDesc..AI_Signals[AI_Channel].Comment..". ЗНАЧЕНИЕ НЕДОСТОВЕРНО"-- сформируем текст сообщения
																	
									reliabilityField=Core[ObjID..AI_Signals[AI_Channel].Tag..".reliabilityField"]-- считаем слово достоверности
					
									if e_type==1 --если событие произошло
									then
										reliabilityField=bit32.bor(reliabilityField,noValid.Mod) --добавим в слово достоверности бит неисправности модуля ПЛК
									else 
										reliabilityField=bit32.bxor(reliabilityField,noValid.Mod) --уберем из слова достоверности бит неисправности модуля
									end --	if e_type==1
									Core[ObjID..AI_Signals[AI_Channel].Tag..".reliabilityField"]=reliabilityField -- передадим в ядро  слово достоверности 
									if Logs -- если логи включены
									then Core.addLogMsg(AlarmMsg.. " " ..  tostring(reliabilityField).." "..User)
 									end --if Logs
									Core.addEvent(AlarmMsg, event.dr, e_type, USO_ID..string.gsub(PLC_Name,"_",""), User, ObjID..AI_Signals[AI_Channel].Tag, timestamp, ScreenID)

							end --_, Ch
				end --if
	end -- Module, ChNum in pairs(RawAI)

	for Module, ChNum in pairs(RawDO) --проидемся списку дискретных выходных модулей 
			do 
				if Module==ModuleStat[1] -- если номер модуля соответствует неисправному - выведем сообщения для всех каналов
				then 
					for _, Ch in pairs(ChNum) -- пройдемся по каналам
							do
								
									DO_Channel=PLC_Name..ModuleStat[1].."."..Ch -- сформируем полное имя канала
									AlarmMsg=ObjDesc..DO_Signals[DO_Channel].Comment..". ЗНАЧЕНИЕ НЕДОСТОВЕРНО"-- сформируем текст сообщения
																	
									reliabilityField=Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]-- считаем слово достоверности
					
									if e_type==1 --если событие произошло
									then
										reliabilityField=bit32.bor(reliabilityField,noValid.Mod) --добавим в слово достоверности бит неисправности модуля ПЛК
									else 
										reliabilityField=bit32.bxor(reliabilityField,noValid.Mod) --уберем из слова достоверности бит неисправности модуля
									end --	if e_type==1
									Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]=reliabilityField -- передадим в ядро  слово достоверности 
									if Logs -- если логи включены
									then Core.addLogMsg(AlarmMsg.. " " ..  tostring(reliabilityField).." "..User)
 									end --if Logs
									Core.addEvent(AlarmMsg, event.dr, e_type, USO_ID..string.gsub(PLC_Name,"_",""), User, ObjID..DO_Signals[DO_Channel].Tag, timestamp, ScreenID)
								
					end --_, Ch
					
				end --if
	end -- Module, ChNum in pairs(RawDO)


end --add_DR_msg(ModuleStat)

local function CheckChannelStatus(Signal)
		local Module=string.gsub(PLC_Name,"_",".")..Signal[1] -- имя модуля
		local Channel
		local Ch
		if Signal[4]=="DO" -- в зависимости от типа сигнала 
		 then 
				Channel=string.gsub(Signal[2],"o","") -- номер канала
				Ch=Signal[5] --ссылка на таблицу тегов
		else
				Channel=string.gsub(Signal[2],"i","") -- номер канала
				Ch=PLC_Name..Signal[1].."."..Signal[2] --ссылка на таблицу тегов
		end --if Signal[4]=="DO"
		local Tag=Signal[3] -- имя тега статуса канала
		local Value=Core[Tag] -- значение тега статуса канала
		local timestamp=os.time() -- время события
		local reliabilityField -- поле достоверности привязанного ко входу сигнала	
		local reliabilityField_tag -- имя поля достоверности привязанного ко входу сигнала	
		local reliabilityValue -- связянная переменная, чью достоверность блюдём
		local AlarmMsg= PLC_Desc.." Модуль "  .. Module..". Неисправность канала ".. Channel

		local reliabilityMsg -- сообщение о достоверности привязанного ко входу сигнала	
		if not ChannelFaults[Tag] then ChannelFaults[Tag]=-1 end --если значение стека пусто - запишем -1
		if Signal[4]=="DI" -- в зависимости от типа сигнала формируем имя тега достоверности
			then
				reliabilityField_tag=ObjID..DI_Signals[Ch].Tag..".reliabilityField"
--				reliabilityMsg=ObjDesc..DI_Signals[Ch].Comment.. " ".. DI_Signals[Ch].Txt_1.. " ЗНАЧЕНИЕ НЕДОСТОВЕРНО"
				reliabilityMsg=ObjDesc..DI_Signals[Ch].Comment.. " ".. DI_Signals[Ch].Txt_1
				--reliabilityValue=ObjID..DI_Signals[Ch].Tag
				STable=DI_Signals
		elseif Signal[4]=="AI"
			 then
				reliabilityField_tag=ObjID..AI_Signals[Ch].Tag..".reliabilityField"
				reliabilityMsg=ObjDesc..AI_Signals[Ch].Comment
--				reliabilityMsg=ObjDesc..AI_Signals[Ch].Comment.. " ЗНАЧЕНИЕ НЕДОСТОВЕРНО"
--				reliabilityValue=ObjID..AI_Signals[Ch].Tag
				STable=AI_Signals
		elseif Signal[4]=="DO"
			 then
				reliabilityField_tag=ObjID..DO_Signals[Ch].Tag..".reliabilityField"
--				reliabilityMsg=ObjDesc..DO_Signals[Ch].Comment.. " ЗНАЧЕНИЕ НЕДОСТОВЕРНО"
				reliabilityMsg=ObjDesc..DO_Signals[Ch].Comment
			--	reliabilityValue=ObjID..DO_Signals[Ch].Tag
				STable=DO_Signals
	
		else return -- если не описан - прервемся
		end -- Signal[5]=="DI" -- в зависимости от типа сигнала формируем имя тега достоверности
		reliabilityField=Core[reliabilityField_tag]--получим значение поля достоверности
 		

		if Value==Faults.no --если неисправностей нет
				then			
					--Core[reliabilityFlag]=true
					reliabilityField=bit32.bxor(reliabilityField,noValid.Ch) -- уберем из поля недостоверность канала
					if Logs
					then
						Core.addLogMsg(reliabilityMsg.." значение НЕДОСТОВЕРНО(исчезновение)".. event.dr .." 0 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. reliabilityField_tag .." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs

					Core.addEvent(reliabilityMsg.." значение НЕДОСТОВЕРНО (исчезновение)", event.dr, 0, USO_ID..string.gsub(PLC_Name,"_",""), User,reliabilityField_tag , timestamp, ScreenID) --создадим запись в строке сообщений
					Core[reliabilityField_tag]=reliabilityField -- передадим в ядро поле достоверности
			else
				--	Core[reliabilityFlag]=false 
					reliabilityField=bit32.bor(reliabilityField,noValid.Ch)-- сделаем привязанный ко входу сигнал недостоверным по каналу
					if Logs
					then
						Core.addLogMsg(reliabilityMsg.." значение НЕДОСТОВЕРНО(появление)".. event.dr .." 1 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. reliabilityField_tag.." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs

					Core.addEvent(reliabilityMsg.." значение НЕДОСТОВЕРНО (появление)", event.dr, 1, USO_ID..string.gsub(PLC_Name,"_",""), User, reliabilityField_tag, timestamp, ScreenID) --создадим запись в строке сообщений
					Core[reliabilityField_tag]=reliabilityField -- передадим в ядро поле достоверности		USO_ID..string.gsub(PLC_Name,"_",""), User, Tag, timestamp, ScreenID	
--ЗНАЧЕНИЕ НЕДОСТОВЕРНО.
			end --if Value==Faults.no 



		if  ChannelFaults[Tag]~=Value -- если код отказа канала не сопадает со значением в стеке
		then
			if Value==Faults.no --если повреждения нет
				then
					if Logs
					then
						Core.addLogMsg(AlarmMsg.. " устранена. ".. event.w .." 0 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. Tag.." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs
			--		reliabilityField=bit32.bxor(reliabilityField,noValid.Ch) --добавим в слово достоверности бит неисправности модуля ПЛК
					Core.addEvent(AlarmMsg.. " устранена.", event.w, 0, USO_ID..string.gsub(PLC_Name,"_",""), User, Tag, timestamp, ScreenID) --создадим запись в строке сообщений
			elseif Value==Faults.fault  --частично неисправно 
				then
					if Logs
					then
						Core.addLogMsg(AlarmMsg.. " . Частично неисправен. ".. event.w .." 1 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. Tag.." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs
		--			reliabilityField=bit32.bor(reliabilityField,noValid.Ch)
					Core.addEvent(AlarmMsg.. " . Частично неисправен.", event.w, 1, USO_ID..string.gsub(PLC_Name,"_",""), User, Tag, timestamp, ScreenID) --создадим запись в строке сообщений
			elseif Value==Faults.crash  --полностью неисправно или не отвечает
				then
					if Logs
					then
						Core.addLogMsg(AlarmMsg.. " . Полностью неистравен или не отвечает. ".. event.w .." 1 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. Tag.." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs
	--				reliabilityField=bit32.bor(reliabilityField,noValid.Ch)
					Core.addEvent(AlarmMsg.. " . Полностью неистравен или не отвечает.", event.w, 1, USO_ID..string.gsub(PLC_Name,"_",""), User, Tag, timestamp, ScreenID) --создадим запись в строке сообщений
			elseif Value==Faults.br  --обрыв
				then
					if Logs
					then
						Core.addLogMsg(AlarmMsg.. " . Обрыв. ".. event.w .." 1 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. Tag.." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs
--					reliabilityField=bit32.bor(reliabilityField,noValid.Ch)
					Core.addEvent(AlarmMsg.. " . Обрыв.", event.w, 1, USO_ID..string.gsub(PLC_Name,"_",""), User, Tag, timestamp, ScreenID) --создадим запись в строке сообщений
			 elseif Value==Faults.sc  --КЗ
				then
					if Logs
					then
						Core.addLogMsg(AlarmMsg.. " . Короткое замыкание. ".. event.w .." 1 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. Tag.." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs
					--reliabilityField=bit32.bor(reliabilityField,noValid.Ch)
					Core.addEvent(AlarmMsg.. " . Короткое замыкание.", event.w, 1, USO_ID..string.gsub(PLC_Name,"_",""), User, Tag, timestamp, ScreenID) --создадим запись в строке сообщений
			 elseif Value==Faults.unknouwn  --состояние неизвестно
				then
					if Logs
					then
						Core.addLogMsg(AlarmMsg.. " . Состояние неизвестно. ".. event.w .." 1 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. Tag.." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs
					--reliabilityField=bit32.bor(reliabilityField,noValid.Ch)
					Core.addEvent(AlarmMsg.. " . Состояние неизвестно.", event.w, 1, USO_ID..string.gsub(PLC_Name,"_",""), User, Tag, timestamp, ScreenID) --создадим запись в строке сообщений
			else 
					if Logs
					then
						Core.addLogMsg(AlarmMsg.. " . Множественные неисправности. ".. event.w .." 1 ".. USO_ID..string.gsub(PLC_Name,"_","").." ".. User.." ".. Tag.." ".. timestamp.." ".. ScreenID) --запишем в логи
					end --if Logs
				--	reliabilityField=bit32.bor(reliabilityField,noValid.Ch)
					Core.addEvent(AlarmMsg.. " . Множественные неисправности.", event.w, 1, USO_ID..string.gsub(PLC_Name,"_",""), User, Tag, timestamp, ScreenID) --создадим запись в строке сообщений

			 end --Value==Faults.no

			

		end -- ChannelFaults[Tag]~=Value

		ChannelFaults[Tag]=Value --сохраним код отказа в стеке
end --function CheckChannelStatus (Signal)

local function Init_DI_Module(Slot) --функция инициализации состочния модуля и определния достоверности сигналов на старте в зависимости от состояния дискретного входного модуля
	
		for Module, ChNum in pairs(RawDI) --DI
			do 

				local Module_Fault=Core[USO_ID..PLC_Name.."FAULT".. ".Slot"..Slot] --получим из ядра состояние модуля
				for _, Ch in pairs(ChNum) 
				do
					local DI_Channel=PLC_Name..Module.."."..Ch -- сформируем полное имя канала
					--local Tag=Core[ObjID..DI_Signals[DI_Channel].Tag..".Value"]
					
						if 	Module_Fault > Faults.no  --если ошибок в модуле нет и сигнал достоверен
							then	
								local reliabilityField=Core[ObjID..DI_Signals[DI_Channel].Tag..".reliabilityField"]-- получим из ядра значение поля достоверности сигнала
								reliabilityField=bit32.bor(reliabilityField,noValid.Mod) -- добавим неисправность модуля
								Core[ObjID..DI_Signals[DI_Channel].Tag..".reliabilityField"]=reliabilityField -- отправим обратно в ядро
					
						end--if 	Module_Fault > Faults.no 
						
						local ChannelStatus=Core[USO_ID..PLC_Name..Module.."."..Ch.."_status"] -- получим состояние текущего канала
						if 	ChannelStatus > Faults.no  --если ошибок в модуле нет и сигнал достоверен
							then	
								reliabilityField=Core[ObjID..AI_Signals[AI_Channel].Tag..".reliabilityField"]-- получим из ядра значение поля достоверности сигнала
								reliabilityField=bit32.bor(reliabilityField,noValid.Ch) -- добавим неисправность канала
								Core[ObjID..DI_Signals[DI_Channel].Tag..".reliabilityField"]=reliabilityField -- отправим обратно в ядро
					
						end--if 	ChannelStatus  > Faults.no 
						
				end --_, Ch
		end --for Module, ChNum 	
end -- local function Init_DI_Module(Module)

local function Init_AI_Module(Slot) --функция инициализации состочния модуля и определния достоверности сигналов на старте в зависимости от состояния аналогового входного модуля

		for Module, ChNum in pairs(RawAI) --AI
			do 
				local Module_Fault=Core[USO_ID..PLC_Name.."FAULT".. ".Slot"..Slot] --получим из ядра состояние модуля
				for _, Ch in pairs(ChNum) 
				do
					local AI_Channel=PLC_Name..Module.."."..Ch -- сформируем полное имя канала
					--local Tag=Core[ObjID..AI_Signals[AI_Channel].Tag..".Value"]
						if 	Module_Fault > Faults.no  --если ошибок в модуле нет и сигнал достоверен
							then	
								local reliabilityField=Core[ObjID..AI_Signals[AI_Channel].Tag..".reliabilityField"]-- получим из ядра значение поля достоверности сигнала
								reliabilityField=bit32.bor(reliabilityField,noValid.Mod) -- добавим неисправность модуля
								Core[ObjID..AI_Signals[AI_Channel].Tag..".reliabilityField"]=reliabilityField -- отправим обратно в ядро
					
						end--if 	Module_Fault > Faults.no 
						
						local ChannelStatus=Core[USO_ID..PLC_Name..Module.."."..Ch.."_status"] -- получим состояние текущего канала
						if 	ChannelStatus > Faults.no  --если ошибок в модуле нет и сигнал достоверен
							then	
								reliabilityField=Core[ObjID..AI_Signals[AI_Channel].Tag..".reliabilityField"]-- получим из ядра значение поля достоверности сигнала
								reliabilityField=bit32.bor(reliabilityField,noValid.Ch) -- добавим неисправность канала
								Core[ObjID..AI_Signals[AI_Channel].Tag..".reliabilityField"]=reliabilityField -- отправим обратно в ядро
						end--if 	ChannelStatus  > Faults.no 			
				end --_, Ch
		end --for Module, ChNum 	
end -- local function Init_AI_Module(Module)

local function Init_DO_Module(Slot) --функция инициализации состочния модуля и определния достоверности сигналов на старте в зависимости от состояния дискретного входного модуля

	for Module, ChNum in pairs(RawDO) --DO
	do
				local Module_Fault=Core[USO_ID..PLC_Name.."FAULT".. ".Slot"..Slot] --получим из ядра состояние модуля
			for _, Ch in pairs(ChNum) --DO
			do
				local DO_Channel=PLC_Name..Module.."."..Ch -- сформируем полное имя канала
				if 	Module_Fault > Faults.no  --если ошибок в модуле нет и сигнал достоверен
				then	
						
								local reliabilityField=Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]-- получим из ядра значение поля достоверности сигнала
								reliabilityField=bit32.bor(reliabilityField,noValid.Mod) -- добавим неисправность модуля
								Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]=reliabilityField -- отправим обратно в ядро								
				end--if 	Module_Fault > Faults.no 	
				local ChannelStatus=Core[USO_ID..PLC_Name..Module.."."..Ch.."_status"] -- получим состояние текущего канала
				
				if 	ChannelStatus > Faults.no  --если ошибок в модуле нет и сигнал достоверен
				then	
								reliabilityField=Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]-- получим из ядра значение поля достоверности сигнала
								reliabilityField=bit32.bor(reliabilityField,noValid.Ch) -- добавим неисправность канала
								Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]=reliabilityField -- отправим обратно в ядро
				end--if 	ChannelStatus  > Faults.no 							

			end --_, Ch in pairs(ChNum)
	end


--[[			for Module, ChNum in pairs(RawDO) --DO
			do 
				local Module_Fault=Core[USO_ID..PLC_Name.."FAULT".. ".Slot"..Slot] --получим из ядра состояние модуля
				for _, Ch in pairs(ChNum) 
				do
					local DO_Channel=PLC_Name..Module.."."..Ch -- сформируем полное имя канала			
						if 	Module_Fault > Faults.no  --если ошибок в модуле нет и сигнал достоверен
							then	
								local reliabilityField=Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]-- получим из ядра значение поля достоверности сигнала
								reliabilityField=bit32.bor(reliabilityField,noValid.Mod) -- добавим неисправность модуля
								Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]=reliabilityField -- отправим обратно в ядро
						end--if 	Module_Fault > Faults.no 

--[[						
						local ChannelStatus=Core[USO_ID..PLC_Name..Module.."."..Ch.."_status"] -- получим состояние текущего канала
						if 	ChannelStatus > Faults.no  --если ошибок в модуле нет и сигнал достоверен
							then	
								reliabilityField=Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]-- получим из ядра значение поля достоверности сигнала
								reliabilityField=bit32.bor(reliabilityField,noValid.Ch) -- добавим неисправность канала
								Core[ObjID..DO_Signals[DO_Channel].Tag..".reliabilityField"]=reliabilityField -- отправим обратно в ядро
					
						end--if 	ChannelStatus  > Faults.no 
						
]]--
		--		end --_, Ch
		--end --for Module, ChNum 	
end -- local function Init_DO_Module(Module)


local function SetRepaireMode(Signal)-- функция включения\отключения ремонтного режима
	local InputName=Signal[1]
	local DI_Channel=ObjID..Signal[1]
	local AI_Channel=Signal[1]
	local Signal_type= Signal[3]
	local e_type -- появление - исчезновение события 
	local repaireFlagValue=Core[Signal[2]]
	local repaireField --
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
				if Signal_type=="DI" 
				then
						Core.addEvent("Значение параметра '".. ObjDesc.." " ..STable["Comment"]..STable["Txt_1"] .."' (тэг '"..ObjID..STable["Tag"].. "') недостоверно. Оборудование выведено в ремонт".." ("..e_type..")", event.dr, e_type, ObjID..string.gsub(PLC_Name,"_",""), User, STable.Tag, timestamp, ScreenID )
							if Logs -- если логи включены
								then Core.addLogMsg("Значение параметра '".. ObjDesc.." " ..STable["Comment"]..STable["Txt_1"] .."' (тэг '"..ObjID..STable["Tag"].. "') недостоверно. Оборудование выведено в ремонт_"..e_type.." "..User)	
							end --if Logs -- если логи включены
					--	if repaireFlagValue == false then Process_DI_Data({DI_Channel})end --если признак ремонта исчез - вызов функции отслеживания значения сигнала
				else
						Core.addEvent("Значение параметра '".. ObjDesc.." " ..STable["Comment"] .."' (тэг '"..ObjID..STable["Tag"].. "') недостоверно. Оборудование выведено в ремонт".." ("..e_type..")", event.dr, e_type, ObjID..string.gsub(PLC_Name,"_",""), User, STable.Tag,timestamp, ScreenID )
							if Logs -- если логи включены
								then	Core.addLogMsg("Значение параметра '".. ObjDesc.." " ..STable["Comment"] .."' (тэг '"..ObjID..STable["Tag"].. "') недостоверно. Оборудование выведено в ремонт_"..e_type.." "..User)	
							end --if Logs -- если логи включены
					--	if repaireFlagValue == false then Process_AI_Data({AI_Channel})end --если признак ремонта исчез - вызов функции отслеживания значения сигнала
				end		
	end --if repaireFlagValue~=STable["repaireFlag"]

end --local function SetRepaireMode

-- функция проверки двубитовых сигналов на достоверность
local function Check_Related_DI_Data (DI_Channel)
	local InputName=string.gsub(DI_Channel[1], USO_ID, "")
				if DI_Signals[InputName]==nil then -- если сигнал в таблице не описан
						Core.addLogMsg(" Опрос "..InputName..". Для данного DI входа отсутствует описание в таблице DI_Signals (Check_Related_DI_Data)") -- отправим сообщение об ошибке в логи
						return -- завершить работу функции Check_Related_DI_Data 
				else
						if not DI_Signals[InputName]["related_DI"] or string.len (DI_Signals[InputName]["related_DI"]) <2  --если связанный тег не определен или его длина меньше 2
						then return
						else
			 			    local Tag=ObjID..DI_Signals[InputName]["Tag"]..".Value" --имя выходного тега присвоим
	 					    local TagValue=Core[Tag]--значение выходного тега
							local RelatedDI=DI_Signals[InputName]["related_DI"]-- название связанного входа ПЛК
							if RelatedDI==nil or string.len(RelatedDI)<2 then
								RelatedDI=Tag
							end
						    local RelatedTag=ObjID..DI_Signals[RelatedDI]["Tag"]..".Value" -- имя ввязанной переменной
  						    local RelatedTagValue=Core[RelatedTag]--значение связанного тега
							local Tag_reliabilityField=Core[ObjID..DI_Signals[InputName]["Tag"]..".reliabilityField"] --получим поле достоверности сигнала
							local RelatedTag_reliabilityField=Core[ObjID..DI_Signals[RelatedDI]["Tag"]..".reliabilityField"]--получим поле достоверности связанного сигнала
							 if TagValue==RelatedTagValue --если значения совпадают
							 then
								Tag_reliabilityField=bit32.bxor(Tag_reliabilityField,noValid.Rel) --добавим признак недостоверности по связанному тегу
								RelatedTag_reliabilityField=bit32.bxor(RelatedTag_reliabilityField,noValid.Rel)--добавим признак недостоверности по связанному тегу
							 else 
								Tag_reliabilityField=bit32.bor(Tag_reliabilityField,noValid.Rel) --добавим признак недостоверности по связанному тегу
								RelatedTag_reliabilityField=bit32.bor(RelatedTag_reliabilityField,noValid.Rel)--добавим признак недостоверности по связанному тегу
							 end --	if TagValue==RelatedTagValue
	
 							 Core[ObjID..DI_Signals[InputName]["Tag"]..".reliabilityField"]=Tag_reliabilityField --отправим в ядро поле достоверности сигнала
							 Core[ObjID..DI_Signals[RelatedDI]["Tag"]..".reliabilityField"]=RelatedTag_reliabilityField--отправим в ядро поле достоверности связанного сигнала
						end --if not DI_Signals[InputName]["related_DI"] or..
 				end --DI_Signals[InputName]["Tag"]


end --local function Check_Related_DI_Data (DI_Channel)


-- функция инициализации двубитовых сигналов на достоверность
local function Init_Related_DI_Data (DI_Channel)
  -- отличия от функции отслеживания: 
--1. здесь смотрим на входы ПЛК, а не на теги! 
--2. Обрабатываем поле достоверности только для текущего входа, не парой - иначе всё вернётся в первоначальное состояние

	local InputName=string.gsub(DI_Channel[1], USO_ID, "")
				if DI_Signals[InputName]==nil then -- если сигнал в таблице не описан
						Core.addLogMsg("Опрос "..InputName..". Для данного DI входа отсутствует описание в таблице DI_Signals (Init_Related_DI_Data)") -- отправим сообщение об ошибке в логи
						return -- завершить работу функции Check_Related_DI_Data 
				else
						if not DI_Signals[InputName]["related_DI"] or string.len (DI_Signals[InputName]["related_DI"]) <2  --если связанный тег не определен или его длина меньше 2
						then return
						else
						    local Tag=USO_ID..InputName --имя входа присвоим
	 					    local TagValue=Core[Tag]--значение входа
							local RelatedDI=DI_Signals[InputName]["related_DI"]-- название связанного входа ПЛК
						    local RelatedTag=USO_ID..RelatedDI -- имя связанного входа
   						    local RelatedTagValue=Core[RelatedTag]--значение связанного входа
							local Tag_reliabilityField=Core[ObjID..DI_Signals[InputName]["Tag"]..".reliabilityField"] --получим поле достоверности сигнала
							 if TagValue==RelatedTagValue --если значения совпадают
							 then
								Tag_reliabilityField=bit32.bxor(Tag_reliabilityField,noValid.Rel) --добавим признак недостоверности по связанному тегу
							 end --	if TagValue==RelatedTagValue
	 							 Core[ObjID..DI_Signals[InputName]["Tag"]..".reliabilityField"]=Tag_reliabilityField --отправим в ядро поле достоверности сигнала
						end --if not DI_Signals[InputName]["related_DI"] or..					
 				end --DI_Signals[InputName]["Tag"]


end --local function Init_Related_DI_Data (DI_Channel)


--.....................................................main().......................................

--	!!!!		-- инициализация состояния модулей  
			for Slot, ChNum in pairs(RawDI)-- дискретных входных
			do 
				Init_DI_Module(Slot)
			end -- Slot, ChNum in pairs(RawDI)

			for Module, ChNum in pairs(RawDI)
			do 
				-- проверим достоверность парных входов
				for _, Ch in pairs(ChNum) 
				do
					local DI_Channel=USO_ID..PLC_Name..Module.."."..Ch -- сформируем полное имя канала
					--os.sleep(0.2)
					Init_Related_DI_Data ({DI_Channel}) -- вызовем инициализацию
				end --_, Ch
			end --for Module, ChNum 


			for Slot, ChNum in pairs(RawAI)-- аналоговых входных
			do 
				Init_AI_Module(Slot)		
			end -- Slot, ChNum in pairs(RawAI)
	

			for Slot, ChNum in pairs(RawDO)-- дискретных выходных
			do 
				Init_DO_Module(Slot)	
			end -- Slot, ChNum in pairs(RawDO)

--!!!!		-- отслеживаем исправность модулей  
			for Module, ChNum in pairs(RawDI)-- дискретных
			do 
				local Module_Fault=USO_ID..PLC_Name.."FAULT".. ".Slot"..Module -- сформируем полное переменной
				Core.onExtChange({Module_Fault}, add_DR_msg,{Module,Module_Fault})
						
			end --fModule, ChNum in pairs(RawDI)-- дискретных
			for Module, ChNum in pairs(RawAI)-- аналоговых
			do 
				local Module_Fault=USO_ID..PLC_Name.."FAULT".. ".Slot"..Module -- сформируем полное переменной
				Core.onExtChange({Module_Fault}, add_DR_msg,{Module,Module_Fault})
			end --Module, ChNum in pairs(RawAI)-- аналоговых

			--проверяем  исправность каналов модулей
			-- дискретных входов
			for Module, ChNum in pairs(RawDI)
			do 			
				for _, Ch in pairs(ChNum) 
				do
					local ChannelStatusTag=USO_ID..PLC_Name..Module.."."..Ch.."_status" -- сформируем название тега статуса канала
					Core.onExtChange({ChannelStatusTag}, CheckChannelStatus,{Module, Ch, ChannelStatusTag,"DI"}) --отслеживаем его состояние
				end --_, Ch in pairs(ChNum) 
			end--Module, ChNum in pairs(RawDI)
			--аналоговых входов
			for Module, ChNum in pairs(RawAI)
			do 			
				for _, Ch in pairs(ChNum) 
				do
					local ChannelStatusTag=USO_ID..PLC_Name..Module.."."..Ch.."_status" -- сформируем название тега статуса канала
					Core.onExtChange({ChannelStatusTag}, CheckChannelStatus,{Module, Ch, ChannelStatusTag,"AI"}) --отслеживаем его состояние
				end --_, Ch in pairs(ChNum) 
			end--Module, ChNum in pairs(RawAI)

			-- дискретных выходов

			for Module, _ in pairs(DO_Signals)
			do 			
					local Module_Num=string.gsub(Module,PLC_Name,"") -- номер канала
					local ModuleNum=string.sub(Module_Num,1,1) -- имя модуля
					local Ch=string.sub(Module,-1) -- номер канала
					local ChannelStatusTag=USO_ID..Module.."_status" -- сформируем название тега статуса канала
					Core.onExtChange({ChannelStatusTag}, CheckChannelStatus,{ModuleNum, Ch, ChannelStatusTag,"DO",Module}) --отслеживаем его состояние
					--Core.onExtChange({DO_ChannelStatusTag}, DO_CheckChannelStatus,{Module}) --отслеживаем его состояние

			end--Module, _ in pairs(DO_Signals)

	--//////////////////// проверка вывода оборудования в ремонт..........--------		
			for Module, ChNum in pairs(RawDI)--дискретных входов
			do 			
				for _, Ch in pairs(ChNum) 
				do
					DI_Channel=PLC_Name..Module.."."..Ch -- сформируем  имя канала
					RepaireTag=ObjID..DI_Signals[DI_Channel].Tag..".repaireFlag"-- сформируем имя переменной вывода в ремонт
					Core.onExtChange({RepaireTag}, SetRepaireMode,{DI_Channel,RepaireTag,"DI"}) 
					--Core.onExtChange({DI_Channel}, Check_Related_DI_Data,{DI_Channel}) 

				end --_, Ch
		end --for Module, ChNum 

	for Module, ChNum in pairs(RawAI)--аналоговых входов
			do 			
				for _, Ch in pairs(ChNum) 
				do
					AI_Channel=PLC_Name..Module.."."..Ch -- сформируем  имя канала
					RepaireTag=ObjID..AI_Signals[AI_Channel].Tag..".repaireFlag"-- сформируем имя переменной вывода в ремонт
					Core.onExtChange({RepaireTag}, SetRepaireMode,{AI_Channel,RepaireTag,"AI"}) 
				end --_, Ch
		end --for Module, ChNum 
		
		for Ch, _ in pairs(DO_Signals) --дискретных выходов
			do 
				local DO_Channel=DO_Signals[Ch]["Tag"]-- сформируем имя тега
				Core.onExtChange({ObjID..DO_Channel..".repaireFlag"}, SetRepaireMode,{Ch,ObjID..DO_Channel..".repaireFlag","DO"}) --проверим обновление флага вывода в ремонт
			end --for Ch, _ 

--- добавим сюда же проверку парных тегов
		for Module, ChNum in pairs(RawDI)
			do 
				-- проверим изменение входов
				for _, Ch in pairs(ChNum) 
				do
					local DI_Channel=USO_ID..PLC_Name..Module.."."..Ch -- сформируем полное имя канала
					--DI_Channel_status=USO_ID..PLC_Name..Module.."."..Ch.."_status" -- сформируем  имя статуса канала
					Core.onExtChange({DI_Channel}, Check_Related_DI_Data,{DI_Channel}) 
				--	Core.onExtChange({DI_Channel_status}, CheckChStatus,{"DI",DI_Channel}) 
					--Core.onExtChange({DI_Channel}, Init_DI_Data,{DI_Channel, true}) 	
				end --_, Ch
			end --for Module, ChNum 
Core.waitEvents( )