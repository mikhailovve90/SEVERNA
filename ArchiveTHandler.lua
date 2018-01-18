
--******************************************************************
--******************* РАЗДЕЛ ОПРЕДЕЛЕНИЯ ФУНКЦИЙ *******************
--******************************************************************

FirstIndex_m = 0		-- индекс массива первой записи архива 
LastIndex_m = 91		-- индекс массива последней записи архива 
LastIndex_t = 92		-- индекс таблицы последней записи архива
DateFirst = nil
DateLast = nil

--******************************************************************
-- создание таблицы с датами epoch ([k]-->[v] и таблицы обратной epoch [v]-->[k)

function ConvertDateToEpoch()

-- создание таблицы с датами в формате epoch (время из таблицы конвертируется во время epoch, ключ[k]-значение(время)[v]
epoch = {}
    for i = 1, 31 do epoch[i] = os.time{year=2017, month=5, day=i} end 		-- май 2017
    for i = 32, 61 do epoch[i] = os.time{year=2017, month=6, day=i-31} end 	-- июнь 2017
    for i = 62, 92 do epoch[i] = os.time{year=2017, month=7, day=i-61} end 	-- июль 2017
-- создание таблицы обратной таблице epoch, значение(время)[v] - ключ[k]
revepoch = {}
    for k,v in pairs(epoch) do revepoch[v] = k end
end

--******************************************************************
-- преобразование времени epoch в формат времени DD-MM-YYYY

function ConvertEpochToDate()

epoch_to_date = {}
    for i = 1, LastIndex_t do epoch_to_date[i] = os.date("%d.%m.%Y", Core.Archive_T[i-1].D[0]) end
end


--******************************************************************
-- формирование строки вида DD-MM-YYYY HH:mm для часового архива

function WriteDateValueHA()

-- преобразование времени epoch в формат времени DD-MM-YYYY (epoch_to_date[1-61])
ConvertEpochToDate() 

-- создание таблицы dt для хранения строки вида DD-MM-YYYY
local dt = {}
local i
for i = 1, 24 do dt[i] = epoch_to_date[c+1] end -- инициализация всех полей таблицы dt значением одной и той же даты 

-- создание таблицы tod для хранения шаблона времён суток вида "00:00" .. "23:00"
tod = {"00:00","01:00","02:00","03:00","04:00","05:00","06:00","07:00","08:00","09:00","10:00","11:00",
"12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00",}

-- создание пустой таблицы dt_tod для хранения строки вида DD-MM-YYYY HH:mm для часового архива
local dt_tod = {} 
local i
for i = 1, 24 do dt_tod[i] = "" end

-- заполнение таблицы dt_tod строками вида DD-MM-YYYY HH:mm
for k,v in pairs(tod) do dt_tod[k] = dt[k] .. " " .. v end

local i

-- запись строк вида DD-MM-YYYY HH:mm в текстовые ячейки
for i = 1, 24 do Core.Date_T.Field_Text[i-1] = dt_tod[i] end 

end

--******************************************************************
-- формирование строк вида "01-01-1970" .. "31-01-1970" для суточного архива

function WriteDateValueDA()

-- преобразование времени epoch в формат времени DD-MM-YYYY (epoch_to_date[1-61])
ConvertEpochToDate()

-- создание таблицы dt для хранения строк вида "01-01-1970" .. "31-01-1970"
dt = {}

a = c 		-- c - глобальный индекс в Archive_T[c], а - локальный индекс (для предотвращения доступа к глобальной с)

	if a < LastIndex_t - 29 then		-- пока индекс с < 31 конструируем таблицу размером 31
		for i = 1, 31 do 
			table.insert(dt, epoch_to_date[a+1])
			a=a+1
			Core.Date_T.Field_Text[i-1] = dt[i]	-- запись строк вида "01-01-1970" .. "31-01-1970" в текстовые ячейки
		end
--to do
--to do
	else size = LastIndex_t - a		-- если с >= 31 начинаем уменьшать число итераций добавления строк в таблицу dt из таблицы epoch_to_date{} 
									-- size - число итераций добавления строк в таблицу dt учитывающее оставшийся размер таблицы epoch_to_date{}
		for i = 1, size do 
			table.insert(dt, epoch_to_date[a+1])
			a=a+1
			Core.Date_T.Field_Text[i-1] = dt[i]  	-- запись строк вида "01-01-1970" .. "31-01-1970" в текстовые ячейки
		end
		for i = size+1, 31 do Core.Date_T.Field_Text[i-1] = "нет данных" end 
	end
end

--******************************************************************
-- формирование строки вида YYYY-month для месячного архива

function WriteDateValueMA()
ConvertEpochToDate();	-- преобразование времени epoch в формат времени DD-MM-YYYY (epoch_to_date[1-..])
month = {}; 			-- создать таблицу month
a = c;
size = LastIndex_m - a;								-- вычислить оставшуюся глубину архивных записей

	while size >= 32 do								-- пока оставшаяся глубина архивных записей больше 32 (32 - смещение для получения "следующего месяца")
		table.insert(month, epoch_to_date[a+1]);	-- заполнить таблицу записями 
		a=a+32;										-- увеличить "с" на смещение 32
		size = LastIndex_m - a;						-- вычислить оставшуюся глубину архивных записей
		i = 0;
		i = i + 1;									-- посчитать количество отработанных циклов while (количество записей в таблице month)
	end

	for x = 0, i do
		Core.Date_T.Field_Text[x] = month[x+1];  	-- записать содержимое таблицы month в текстовые поля
		--Core.Date_E.Field_Text[x] = os.date("%B", tonumber(month[x+1]));  	-- записать содержимое таблицы month в текстовые поля
	end

	for x = i + 1, 11 do
		Core.Date_T.Field_Text[x] = "нет данных";  	-- вместо отсутствующих данных записать "нет данных"
	end
end

--******************************************************************
-- формирование строки вида "I(II,III,IV) квартал - 2017" для квартального архива

function WriteDateValueQA()

-- создание таблицы quarter для хранения шаблона времён суток вида I,II,III,IV
quarter = {"I квартал - ","II квартал - ","III квартал - ","IV квартал - "}

	for i = 1, 4 do Core.Date_T.Field_Text[i-1] = quarter[i] .. os.date("%Y", Core.DateSelect) end 

end

--******************************************************************
-- формирование строки вида "2017" для годового архива

function WriteDateValueYA()

	Core.Date_T.Field_Text[0] = os.date("%Y", Core.DateSelect)

end
--******************************************************************
-- заполнение текстовых ячеек данными (часовой архив)

function WriteDataValueInTextFieldHA()
t = {"92.5", "92.0", "92.0", "92.1", "92.3", "92.0", "89.8", "89.9", "90.0", "91.5", "91.6", "92.0", "91.9",
 "92.5", "89.8", "90.0", "91.6", "92.0", "92.1", "92.0", "91.9", "92.5", "92.5", "91.5"}
	if c <= LastIndex_m then
		for i = 0, 23 do
			Core.Heat.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Q[i])
			Core.Gas.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Gas[i])
			Core.WaterA1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_A1[i])
			Core.WaterA2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_A2[i])
			Core.WaterA3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_A3[i])
			Core.WaterA4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_A4[i])
			Core.WaterObj1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_Obj1[i])
			Core.WaterObj2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_Obj2[i])
			Core.WaterObj3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_Obj3[i])
			Core.WaterObj4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_Obj4[i])
			Core.KPD.IO_Field_Text[i] = t[i+1]
		end
	end
end

--******************************************************************
-- заполнение текстовых ячеек данными (суточный архив)

function WriteDataValueInTextFieldDA()
t = {"92.0", "91.9", "92.5", "92.5", "92.0", "92.5", "91.5", "92.0", "92.1", "92.0", "92.1", "89.8", "89.9", "90.0", "91.5", "91.6", "92.0", "91.9",
 "92.5", "89.8", "90.0", "91.6", "92.3", "92.0", "91.9", "92.5", "92.5", "92.0", "92.5", "91.5", "92.0"}
	if c <= LastIndex_m then
		for i = 0, 30 do
			Core.Heat.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Q[i])
			Core.Gas.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Gas[i])
			Core.WaterA1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_A1[i])
			Core.WaterA2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_A2[i])
			Core.WaterA3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_A3[i])
			Core.WaterA4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_A4[i])
			Core.WaterObj1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_Obj1[i])
			Core.WaterObj2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_Obj2[i])
			Core.WaterObj3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_Obj3[i])
			Core.WaterObj4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_Obj4[i])
			Core.KPD.IO_Field_Text[i] = t[i+1]
		end
	end
end
--******************************************************************
-- заполнение текстовых ячеек данными (месячный архив)

function WriteDataValueInTextFieldMA()
t = {"89.8", "90.0", "91.6", "92.3", "92.0", "91.9", "92.5", "92.5", "92.0", "92.5", "91.5", "92.0"}
	if c <= LastIndex_m then
		for i = 0, 11 do
			Core.Heat.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Q[i])
			Core.Gas.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Gas[i])
			Core.WaterA1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_A1[i])
			Core.WaterA2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_A2[i])
			Core.WaterA3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_A3[i])
			Core.WaterA4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_A4[i])
			Core.WaterObj1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_Obj1[i])
			Core.WaterObj2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_Obj2[i])
			Core.WaterObj3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_Obj3[i])
			Core.WaterObj4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_Obj4[i])
			Core.KPD.IO_Field_Text[i] = t[i+1]
		end
	end
end
--******************************************************************
-- заполнение текстовых ячеек данными (квартальный архив)

function WriteDataValueInTextFieldQA()
t = {"92.0", "92.5", "91.5", "92.0"}
	if c <= LastIndex_m then
		for i = 0, 3 do
			Core.Heat.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Q[i])
			Core.Gas.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Gas[i])
			Core.WaterA1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_A1[i])
			Core.WaterA2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_A2[i])
			Core.WaterA3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_A3[i])
			Core.WaterA4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_A4[i])
			Core.WaterObj1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_Obj1[i])
			Core.WaterObj2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_Obj2[i])
			Core.WaterObj3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_Obj3[i])
			Core.WaterObj4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_Obj4[i])
			Core.KPD.IO_Field_Text[i] = t[i+1]
		end
	end
end

--******************************************************************
-- заполнение текстовых ячеек данными (годовой архив)

function WriteDataValueInTextFieldYA()
t = {"92.5"}
	if c <= LastIndex_m then
		for i = 0, 0 do
			Core.Heat.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Q[i])
			Core.Gas.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Gas[i])
			Core.WaterA1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_A1[i])
			Core.WaterA2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_A2[i])
			Core.WaterA3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_A3[i])
			Core.WaterA4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_A4[i])
			Core.WaterObj1.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_Obj1[i])
			Core.WaterObj2.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_Obj2[i])
			Core.WaterObj3.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_Obj3[i])
			Core.WaterObj4.IO_Field_Text[i] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_Obj4[i])
			Core.KPD.IO_Field_Text[i] = t[i+1]
		end
	end
end
--******************************************************************
-- управление поведением текстовых ячеек (часовой архив)

function ChangeBehaviorTextFieldHA()
    for i = 0, 23 do
        Core.Date_T.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = true    	-- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = true
        Core.WaterA1.IO_Field_Visible[i] = true
        Core.WaterA2.IO_Field_Visible[i] = true
        Core.WaterA3.IO_Field_Visible[i] = true
        Core.WaterA4.IO_Field_Visible[i] = true
        Core.WaterObj1.IO_Field_Visible[i] = true
        Core.WaterObj2.IO_Field_Visible[i] = true
        Core.WaterObj3.IO_Field_Visible[i] = true
        Core.WaterObj4.IO_Field_Visible[i] = true
		Core.KPD.IO_Field_Visible[i] = true
    end
    for i = 24, 30 do
        Core.Date_T.Field_Visible[i] = false			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = false   	-- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = false
        Core.WaterA1.IO_Field_Visible[i] = false
        Core.WaterA2.IO_Field_Visible[i] = false
        Core.WaterA3.IO_Field_Visible[i] = false
        Core.WaterA4.IO_Field_Visible[i] = false
        Core.WaterObj1.IO_Field_Visible[i] = false
        Core.WaterObj2.IO_Field_Visible[i] = false
        Core.WaterObj3.IO_Field_Visible[i] = false
        Core.WaterObj4.IO_Field_Visible[i] = false
		Core.KPD.IO_Field_Visible[i] = false
    end

	y = 437
	Core.Date_T.Total_Text_Pos[0] = y					-- изменение координат "у" текстовых полей
    Core.Heat.IO_Field_Button_Pos[0] = y			
    Core.Gas.IO_Field_Button_Pos[0] = y
    Core.WaterA1.IO_Field_Button_Pos[0] = y
    Core.WaterA2.IO_Field_Button_Pos[0] = y
    Core.WaterA3.IO_Field_Button_Pos[0] = y
    Core.WaterA4.IO_Field_Button_Pos[0] = y
    Core.WaterObj1.IO_Field_Button_Pos[0] = y
    Core.WaterObj2.IO_Field_Button_Pos[0] = y
    Core.WaterObj3.IO_Field_Button_Pos[0] = y
    Core.WaterObj4.IO_Field_Button_Pos[0] = y
	Core.KPD.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- управление поведением текстовых ячеек (суточный архив)

function ChangeBehaviorTextFieldDA()
    for i = 0, 30 do
        Core.Date_T.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = true        -- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = true
        Core.WaterA1.IO_Field_Visible[i] = true
        Core.WaterA2.IO_Field_Visible[i] = true
        Core.WaterA3.IO_Field_Visible[i] = true
        Core.WaterA4.IO_Field_Visible[i] = true
        Core.WaterObj1.IO_Field_Visible[i] = true
        Core.WaterObj2.IO_Field_Visible[i] = true
        Core.WaterObj3.IO_Field_Visible[i] = true
        Core.WaterObj4.IO_Field_Visible[i] = true
		Core.KPD.IO_Field_Visible[i] = true
    end

	y = 564
	Core.Date_T.Total_Text_Pos[0] = y					-- изменение координат "у" текстовых полей
    Core.Heat.IO_Field_Button_Pos[0] = y
    Core.Gas.IO_Field_Button_Pos[0] = y
    Core.WaterA1.IO_Field_Button_Pos[0] = y
    Core.WaterA2.IO_Field_Button_Pos[0] = y
    Core.WaterA3.IO_Field_Button_Pos[0] = y
    Core.WaterA4.IO_Field_Button_Pos[0] = y
    Core.WaterObj1.IO_Field_Button_Pos[0] = y
    Core.WaterObj2.IO_Field_Button_Pos[0] = y
    Core.WaterObj3.IO_Field_Button_Pos[0] = y
    Core.WaterObj4.IO_Field_Button_Pos[0] = y
	Core.KPD.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- управление поведением текстовых ячеек (месячный архив)

function ChangeBehaviorTextFieldMA()
    for i = 0, 11 do
        Core.Date_T.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = true        -- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = true
        Core.WaterA1.IO_Field_Visible[i] = true
        Core.WaterA2.IO_Field_Visible[i] = true
        Core.WaterA3.IO_Field_Visible[i] = true
        Core.WaterA4.IO_Field_Visible[i] = true
        Core.WaterObj1.IO_Field_Visible[i] = true
        Core.WaterObj2.IO_Field_Visible[i] = true
        Core.WaterObj3.IO_Field_Visible[i] = true
        Core.WaterObj4.IO_Field_Visible[i] = true
 		Core.KPD.IO_Field_Visible[i] = true
    end
    for i = 12, 30 do
        Core.Date_T.Field_Visible[i] = false			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = false       -- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = false
        Core.WaterA1.IO_Field_Visible[i] = false
        Core.WaterA2.IO_Field_Visible[i] = false
        Core.WaterA3.IO_Field_Visible[i] = false
        Core.WaterA4.IO_Field_Visible[i] = false
        Core.WaterObj1.IO_Field_Visible[i] = false
        Core.WaterObj2.IO_Field_Visible[i] = false
        Core.WaterObj3.IO_Field_Visible[i] = false
        Core.WaterObj4.IO_Field_Visible[i] = false
		Core.KPD.IO_Field_Visible[i] = false
    end

	y = 221
    Core.Heat.IO_Field_Button_Pos[0] = y			-- изменение координат "у" текстовых полей
    Core.Gas.IO_Field_Button_Pos[0] = y
    Core.WaterA1.IO_Field_Button_Pos[0] = y
    Core.WaterA2.IO_Field_Button_Pos[0] = y
    Core.WaterA3.IO_Field_Button_Pos[0] = y
    Core.WaterA4.IO_Field_Button_Pos[0] = y
    Core.WaterObj1.IO_Field_Button_Pos[0] = y
    Core.WaterObj2.IO_Field_Button_Pos[0] = y
    Core.WaterObj3.IO_Field_Button_Pos[0] = y
    Core.WaterObj4.IO_Field_Button_Pos[0] = y
	Core.Date_T.Total_Text_Pos[0] = y
	Core.KPD.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- управление поведением текстовых ячеек (квартальный архив)

function ChangeBehaviorTextFieldQA()
    for i = 0, 3 do
        Core.Date_T.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = true        -- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = true
        Core.WaterA1.IO_Field_Visible[i] = true
        Core.WaterA2.IO_Field_Visible[i] = true
        Core.WaterA3.IO_Field_Visible[i] = true
        Core.WaterA4.IO_Field_Visible[i] = true
        Core.WaterObj1.IO_Field_Visible[i] = true
        Core.WaterObj2.IO_Field_Visible[i] = true
        Core.WaterObj3.IO_Field_Visible[i] = true
        Core.WaterObj4.IO_Field_Visible[i] = true
 		Core.KPD.IO_Field_Visible[i] = true
    end
    for i = 4, 30 do
        Core.Date_T.Field_Visible[i] = false			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = false       -- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = false
        Core.WaterA1.IO_Field_Visible[i] = false
        Core.WaterA2.IO_Field_Visible[i] = false
        Core.WaterA3.IO_Field_Visible[i] = false
        Core.WaterA4.IO_Field_Visible[i] = false
        Core.WaterObj1.IO_Field_Visible[i] = false
        Core.WaterObj2.IO_Field_Visible[i] = false
        Core.WaterObj3.IO_Field_Visible[i] = false
        Core.WaterObj4.IO_Field_Visible[i] = false
 		Core.KPD.IO_Field_Visible[i] = false
    end

	y = 76
    Core.Heat.IO_Field_Button_Pos[0] = y			-- изменение координат "у" текстовых полей
    Core.Gas.IO_Field_Button_Pos[0] = y
    Core.WaterA1.IO_Field_Button_Pos[0] = y
    Core.WaterA2.IO_Field_Button_Pos[0] = y
    Core.WaterA3.IO_Field_Button_Pos[0] = y
    Core.WaterA4.IO_Field_Button_Pos[0] = y
    Core.WaterObj1.IO_Field_Button_Pos[0] = y
    Core.WaterObj2.IO_Field_Button_Pos[0] = y
    Core.WaterObj3.IO_Field_Button_Pos[0] = y
    Core.WaterObj4.IO_Field_Button_Pos[0] = y
	Core.Date_T.Total_Text_Pos[0] = y
	Core.KPD.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- управление поведением текстовых ячеек (годовой архив)

function ChangeBehaviorTextFieldYA()
    for i = 0, 0 do
        Core.Date_T.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = true        -- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = true
        Core.WaterA1.IO_Field_Visible[i] = true
        Core.WaterA2.IO_Field_Visible[i] = true
        Core.WaterA3.IO_Field_Visible[i] = true
        Core.WaterA4.IO_Field_Visible[i] = true
        Core.WaterObj1.IO_Field_Visible[i] = true
        Core.WaterObj2.IO_Field_Visible[i] = true
        Core.WaterObj3.IO_Field_Visible[i] = true
        Core.WaterObj4.IO_Field_Visible[i] = true
 		Core.KPD.IO_Field_Visible[i] = true
    end
    for i = 1, 30 do
        Core.Date_T.Field_Visible[i] = false			-- задание видимости текстовых ячеек с датами
        Core.Heat.IO_Field_Visible[i] = false       -- задание видимости текстовых ячеек
        Core.Gas.IO_Field_Visible[i] = false
        Core.WaterA1.IO_Field_Visible[i] = false
        Core.WaterA2.IO_Field_Visible[i] = false
        Core.WaterA3.IO_Field_Visible[i] = false
        Core.WaterA4.IO_Field_Visible[i] = false
        Core.WaterObj1.IO_Field_Visible[i] = false
        Core.WaterObj2.IO_Field_Visible[i] = false
        Core.WaterObj3.IO_Field_Visible[i] = false
        Core.WaterObj4.IO_Field_Visible[i] = false
 		Core.KPD.IO_Field_Visible[i] = false
    end

	y = 23
    Core.Heat.IO_Field_Button_Pos[0] = y			-- изменение координат "у" текстовых полей
    Core.Gas.IO_Field_Button_Pos[0] = y
    Core.WaterA1.IO_Field_Button_Pos[0] = y
    Core.WaterA2.IO_Field_Button_Pos[0] = y
    Core.WaterA3.IO_Field_Button_Pos[0] = y
    Core.WaterA4.IO_Field_Button_Pos[0] = y
    Core.WaterObj1.IO_Field_Button_Pos[0] = y
    Core.WaterObj2.IO_Field_Button_Pos[0] = y
    Core.WaterObj3.IO_Field_Button_Pos[0] = y
    Core.WaterObj4.IO_Field_Button_Pos[0] = y
	Core.Date_T.Total_Text_Pos[0] = y
	Core.KPD.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- вычисления суммы значений

function mathsum(t)
        local sum = 0
        for k,v in pairs(t) do sum = sum + v end
    return sum
end

--******************************************************************
-- создание таблиц для вычисления суммарного, среднего, минимального и максимального значений

function CreateTotalTable()
    Heat = {}
    Gas = {}
    WaterA1 = {}
    WaterA2 = {}
    WaterA3 = {}
    WaterA4 = {}
    WaterObj1 = {}
    WaterObj2 = {}
    WaterObj3 = {}
    WaterObj4 = {}
    KPD = {}
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (часовой архив)

function WriteDataValueInTableHA()
t1 = {"92.5", "92.0", "92.0", "92.1", "92.3", "92.0", "89.8", "89.9", "90.0", "91.5", "91.6", "92.0", "91.9",
 "92.5", "89.8", "90.0", "91.6", "92.0", "92.1", "92.0", "91.9", "92.5", "92.5", "91.5"}
    for i = 0, 23 do
        Heat[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Q[i])
        Gas[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Gas[i])
        WaterA1[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_A1[i])
        WaterA2[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_A2[i])
        WaterA3[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_A3[i])
        WaterA4[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_A4[i])
        WaterObj1[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_Obj1[i])
        WaterObj2[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_Obj2[i])
        WaterObj3[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_Obj3[i])
        WaterObj4[i+1] = string.format("%.2f", Core.Archive_T[c].HA[0].Water_Obj4[i])
		KPD[i+1] = t1[i+1]
	end
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (суточный архив)

function WriteDataValueInTableDA()
t2 = {"92.0", "91.9", "92.5", "92.5", "92.0", "92.5", "91.5", "92.0", "92.1", "92.0", "92.1", "89.8", "89.9", "90.0", "91.5", "91.6", "92.0", "91.9",
 "92.5", "89.8", "90.0", "91.6", "92.3", "92.0", "91.9", "92.5", "92.5", "92.0", "92.5", "91.5", "92.0"}
	for i = 0, 30 do
        Heat[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Q[i])
        Gas[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Gas[i])
        WaterA1[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_A1[i])
        WaterA2[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_A2[i])
        WaterA3[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_A3[i])
        WaterA4[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_A4[i])
        WaterObj1[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_Obj1[i])
        WaterObj2[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_Obj2[i])
        WaterObj3[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_Obj3[i])
        WaterObj4[i+1] = string.format("%.2f", Core.Archive_T[c].DA[0].Water_Obj4[i])
		KPD[i+1] = t2[i+1]
	end
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (месячный архив)

function WriteDataValueInTableMA()
t3 = {"89.8", "90.0", "91.6", "92.3", "92.0", "91.9", "92.5", "92.5", "92.0", "92.5", "91.5", "92.0"}
	for i = 0, 11 do
        Heat[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Q[i])
        Gas[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Gas[i])
        WaterA1[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_A1[i])
        WaterA2[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_A2[i])
        WaterA3[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_A3[i])
        WaterA4[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_A4[i])
        WaterObj1[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_Obj1[i])
        WaterObj2[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_Obj2[i])
        WaterObj3[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_Obj3[i])
        WaterObj4[i+1] = string.format("%.2f", Core.Archive_T[c].MA[0].Water_Obj4[i])
		KPD[i+1] = t3[i+1]
	end
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (квартальный архив)

function WriteDataValueInTableQA()
t4 = {"92.0", "92.5", "91.5", "92.0"}
	for i = 0, 3 do
        Heat[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Q[i])
        Gas[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Gas[i])
        WaterA1[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_A1[i])
        WaterA2[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_A2[i])
        WaterA3[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_A3[i])
        WaterA4[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_A4[i])
        WaterObj1[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_Obj1[i])
        WaterObj2[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_Obj2[i])
        WaterObj3[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_Obj3[i])
        WaterObj4[i+1] = string.format("%.2f", Core.Archive_T[c].QA[0].Water_Obj4[i])
		KPD[i+1] = t4[i+1]
	end
end
--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (годовой архив)

function WriteDataValueInTableYA()
t5 = {"92.5"}
	for i = 0, 0 do
        Heat[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Q[i])
        Gas[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Gas[i])
        WaterA1[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_A1[i])
        WaterA2[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_A2[i])
        WaterA3[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_A3[i])
        WaterA4[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_A4[i])
        WaterObj1[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_Obj1[i])
        WaterObj2[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_Obj2[i])
        WaterObj3[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_Obj3[i])
        WaterObj4[i+1] = string.format("%.2f", Core.Archive_T[c].YA[0].Water_Obj4[i])
		KPD[i+1] = t5[i+1]
	end
end
--******************************************************************
-- вычисления суммы, средних,  минимальных, максимальных значений

function CalcTotalValue()

    Core.Heat.IO_Field_Text[31] = mathsum(Heat) -- вычисления суммы значений
    Core.Gas.IO_Field_Text[31] = mathsum(Gas)
    Core.WaterA1.IO_Field_Text[31] = mathsum(WaterA1)
    Core.WaterA2.IO_Field_Text[31] = mathsum(WaterA2)
    Core.WaterA3.IO_Field_Text[31] = mathsum(WaterA3)
    Core.WaterA4.IO_Field_Text[31] = mathsum(WaterA4)
    Core.WaterObj1.IO_Field_Text[31] = mathsum(WaterObj1)
    Core.WaterObj2.IO_Field_Text[31] = mathsum(WaterObj2)
    Core.WaterObj3.IO_Field_Text[31] = mathsum(WaterObj3)
    Core.WaterObj4.IO_Field_Text[31] = mathsum(WaterObj4)
    Core.KPD.IO_Field_Text[31] = mathsum(KPD)

    Core.Heat.IO_Field_Text[32] = (math.max(table.unpack(Heat)) + math.min(table.unpack(Heat))) / 2 -- вычисления средних значений
    Core.Gas.IO_Field_Text[32] = (math.max(table.unpack(Gas)) + math.min(table.unpack(Gas))) / 2
    Core.WaterA1.IO_Field_Text[32] = (math.max(table.unpack(WaterA1)) + math.min(table.unpack(WaterA1))) / 2
    Core.WaterA2.IO_Field_Text[32] = (math.max(table.unpack(WaterA2)) + math.min(table.unpack(WaterA2))) / 2
    Core.WaterA3.IO_Field_Text[32] = (math.max(table.unpack(WaterA3)) + math.min(table.unpack(WaterA3))) / 2
    Core.WaterA4.IO_Field_Text[32] = (math.max(table.unpack(WaterA4)) + math.min(table.unpack(WaterA4))) / 2
    Core.WaterObj1.IO_Field_Text[32] = (math.max(table.unpack(WaterObj1)) + math.min(table.unpack(WaterObj1))) / 2
    Core.WaterObj2.IO_Field_Text[32] = (math.max(table.unpack(WaterObj2)) + math.min(table.unpack(WaterObj2))) / 2
    Core.WaterObj3.IO_Field_Text[32] = (math.max(table.unpack(WaterObj3)) + math.min(table.unpack(WaterObj3))) / 2
    Core.WaterObj4.IO_Field_Text[32] = (math.max(table.unpack(WaterObj4)) + math.min(table.unpack(WaterObj4))) / 2
    Core.KPD.IO_Field_Text[32] = (math.max(table.unpack(KPD)) + math.min(table.unpack(KPD))) / 2

    Core.Heat.IO_Field_Text[33] = math.min(table.unpack(Heat)) -- вычисления минимальных значений
    Core.Gas.IO_Field_Text[33] = math.min(table.unpack(Gas))
    Core.WaterA1.IO_Field_Text[33] = math.min(table.unpack(WaterA1))
    Core.WaterA2.IO_Field_Text[33] = math.min(table.unpack(WaterA2))
    Core.WaterA3.IO_Field_Text[33] = math.min(table.unpack(WaterA3))
    Core.WaterA4.IO_Field_Text[33] = math.min(table.unpack(WaterA4))
    Core.WaterObj1.IO_Field_Text[33] = math.min(table.unpack(WaterObj1))
    Core.WaterObj2.IO_Field_Text[33] = math.min(table.unpack(WaterObj2))
    Core.WaterObj3.IO_Field_Text[33] = math.min(table.unpack(WaterObj3))
    Core.WaterObj4.IO_Field_Text[33] = math.min(table.unpack(WaterObj4))
	Core.KPD.IO_Field_Text[33] =  math.min(table.unpack(KPD))

    Core.Heat.IO_Field_Text[34] = math.max(table.unpack(Heat)) -- вычисления максимальных значений
    Core.Gas.IO_Field_Text[34] = math.max(table.unpack(Gas))
    Core.WaterA1.IO_Field_Text[34] = math.max(table.unpack(WaterA1))
    Core.WaterA2.IO_Field_Text[34] = math.max(table.unpack(WaterA2))
    Core.WaterA3.IO_Field_Text[34] = math.max(table.unpack(WaterA3))
    Core.WaterA4.IO_Field_Text[34] = math.max(table.unpack(WaterA4))
    Core.WaterObj1.IO_Field_Text[34] = math.max(table.unpack(WaterObj1))
    Core.WaterObj2.IO_Field_Text[34] = math.max(table.unpack(WaterObj2))
    Core.WaterObj3.IO_Field_Text[34] = math.max(table.unpack(WaterObj3))
    Core.WaterObj4.IO_Field_Text[34] = math.max(table.unpack(WaterObj4))
	Core.KPD.IO_Field_Text[34] =  math.max(table.unpack(KPD))
end

--******************************************************************
-- проверка вхождения введённой даты в диапазон дат

function CheckDateSelected()
::redo::
        if Core.DateSelectorPressed_T == true then        -- событие смены даты пользователем в "календаре"

			Core.DateSelect = Core.DateSelect_GUI_T       -- DateSelect_GUI_T - дата выбранная
            if (Core.DateSelect >= Core.DateFirst) and (Core.DateSelect <= Core.DateLast) then	-- проверка вхождения выбранной даты в диапазон дат (в формате UNIX-epoch)
                --Core.DateInRange = true														-- ОК! выбранная дата в диапазоне
                c = (revepoch[Core.DateSelect]) - 1												-- получить индекс архива --> Arhive[c]
	            else
					Core.DateOutOfRange_T = false
                    Core.DateOutOfRange_T = true													-- ERROR! выбранная дата вне диапазона -> вызов окна "Предупреждение"
					Core.WarningMessage_T = string.format ("Выбранная дата вне диапазона дат архива.\nДата первой записи архива:      %s\nДата последней записи архива: %s\nПовторите ввод даты.", tostring(os.date("%d.%m.%Y", Core.DateFirst)), tostring(os.date("%d.%m.%Y", Core.DateLast)))	
					--error("error input")
					goto redo
			end
		end
	return c																					-- возвратить индекс архива --> Arhive[c]
end

--******************************************************************
-- запись данных в текстовые ячейки от "календаря"

function WriteDataFromDateSelector()

	if 	Core.DateSelectorPressed_T and Core.HourButtonPressed_T == true then	-- изменена дата "календаря" и ранее нажата кнопка "Часовой архив"
-- обработка часового архива
            WriteDateValueHA()            	-- формирование строки вида DD-MM-YYYY HH:mm для часового архива
			WriteDataValueInTextFieldHA()	-- заполнение текстовых ячеек данными (часовой архив)
		    CreateTotalTable() 		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableHA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (часовой архив)
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
		elseif
			Core.DateSelectorPressed_T and Core.DateButtonPressed_T  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Суточный архив"
-- обработка суточного архива
            WriteDateValueDA()				-- формирование строк вида "01-01-1970" .. "31-01-1970" для суточного архива
			WriteDataValueInTextFieldDA()	-- заполнение текстовых ячеек данными (суточный архив)
            CreateTotalTable() 		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableDA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (суточный архив)
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
		elseif
			Core.DateSelectorPressed_T and Core.MonthButtonPressed_T  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Месячный архив"
-- обработка месячного архива
			WriteDateValueMA()				-- формирование строки вида YYYY-month для месячного архива
			WriteDataValueInTextFieldMA()	-- заполнение текстовых ячеек данными (месячный архив)
			CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableMA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (месячный архив)
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
		end
	os.sleep(0.5)
	Core.DateSelectorPressed_T = false
end

--******************************************************************
-- запись данных в текстовые ячейки от кнопок

function WriteDataFromButton()

	if Core.HourButtonPressed_T == true then  	-- нажата кнопка "Часовой архив"
-- обработка часового архива

	    Core.HourButtonFontBold_T = true		-- задание жирности шрифта кнопок
	    Core.DateButtonFontBold_T = false     
	    Core.MonthButtonFontBold_T = false
		Core.QuarterButtonFontBold_T = false
		Core.YearButtonFontBold_T = false

		Core.Header_Text_T = "Часовой архив выработки тепловой энергии, расхода топливного газа, добычи и потребления воды (приращения за час)"
        WriteDateValueHA()				-- формирование строки вида DD-MM-YYYY HH:mm для часового архива
	    ChangeBehaviorTextFieldHA()		-- управление поведением текстовых ячеек
	    CreateTotalTable() 				-- создание таблиц для поиска суммарного, среднего, минимального и максимального значений (часовой архив)
		WriteDataValueInTableHA()		-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (часовой архив)
	    CalcTotalValue() 				-- вычисления суммы, средних,  минимальных, максимальных значений (часовой архив)
        WriteDataValueInTextFieldHA()	-- заполнение текстовых ячеек данными (часовой архив)

	elseif Core.DateButtonPressed_T == true then      -- нажата кнопка "Суточный архив"
-- обработка суточного архива

	        Core.HourButtonFontBold_T = false         -- задание жирности шрифта кнопок
	        Core.DateButtonFontBold_T = true
	        Core.MonthButtonFontBold_T = false
			Core.QuarterButtonFontBold_T = false
			Core.YearButtonFontBold_T = false

			Core.Header_Text_T = "Суточный архив выработки тепловой энергии, расхода топливного газа, добычи и потребления воды (приращения за сутки)"
			WriteDateValueDA()				-- формирование строк вида "01-01-1970" .. "31-01-1970" для суточного архива
			ChangeBehaviorTextFieldDA()		-- управление поведением текстовых ячеек
		    CreateTotalTable() 				-- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableDA()		-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (суточный архив)
			CalcTotalValue() 				-- вычисления суммы, средних,  минимальных, максимальных значений
			WriteDataValueInTextFieldDA()	-- заполнение текстовых ячеек данными (суточный архив)

	elseif Core.MonthButtonPressed_T == true then         -- нажата кнопка "Месячный архив"
-- обработка месячного архива

	        Core.HourButtonFontBold_T = false             -- задание жирности шрифта кнопок
	        Core.DateButtonFontBold_T = false
	        Core.MonthButtonFontBold_T = true
			Core.QuarterButtonFontBold_T = false
			Core.YearButtonFontBold_T = false

			Core.Header_Text_T = "Месячный архив выработки тепловой энергии, расхода топливного газа, добычи и потребления воды (приращения за месяц)"
			WriteDateValueMA()				-- формирование строки вида YYYY-month для месячного архива
		    ChangeBehaviorTextFieldMA()		-- управление поведением текстовых ячеек
		    CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableMA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (месячный архив)
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
			WriteDataValueInTextFieldMA()	-- заполнение текстовых ячеек данными (месячный архив)

	elseif Core.QuarterButtonPressed_T == true then         -- нажата кнопка "Квартальный архив"
-- обработка квартального архива

	        Core.HourButtonFontBold_T = false             -- задание жирности шрифта кнопок
	        Core.DateButtonFontBold_T = false
	        Core.MonthButtonFontBold_T = false
			Core.QuarterButtonFontBold_T = true
			Core.YearButtonFontBold_T = false

			Core.Header_Text_T = "Квартальный архив выработки тепловой энергии, расхода топливного газа, добычи и потребления воды (приращения за квартал)"
			WriteDateValueQA()				-- запись дат
			ChangeBehaviorTextFieldQA()		-- управление поведением текстовых ячеек
			CreateTotalTable()				-- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableQA()		-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (квартальный архив)
			CalcTotalValue() 				-- вычисления суммы, средних,  минимальных, максимальных значений
			WriteDataValueInTextFieldQA()	-- заполнение текстовых ячеек данными (квартальный архив)

	elseif Core.YearButtonPressed_T == true then         -- нажата кнопка "Годовой архив"
-- обработка годового архива

	        Core.HourButtonFontBold_T = false             -- задание жирности шрифта кнопок
	        Core.DateButtonFontBold_T = false
	        Core.MonthButtonFontBold_T = false
			Core.QuarterButtonFontBold_T = false
			Core.YearButtonFontBold_T = true

			Core.Header_Text_T = "Годовой архив выработки тепловой энергии, расхода топливного газа, добычи и потребления воды (приращения за год)"
			WriteDateValueYA()				-- запись дат
			ChangeBehaviorTextFieldYA()		-- управление поведением текстовых ячеек
			CreateTotalTable()				-- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableYA()		-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (годовой архив)
			CalcTotalValue() 				-- вычисления суммы, средних,  минимальных, максимальных значений
			WriteDataValueInTextFieldYA()	-- заполнение текстовых ячеек данными (годовой архив)
	end
end

--******************************************************************
--*********************** РАЗДЕЛ ИСПОЛНЕНИЯ ************************
--******************************************************************

--dofile("f:\\!Projects\\Energy_Accounting_ET\\Design\\InitT.lua") -- иницилизация переменных (имитация реальных данных)
dofile("InitT.lua")
CheckDateSelected() 		    -- проверка вхождения введённой даты в диапазон дат
WriteDataFromDateSelector(c)	-- обработка события при вводе даты от "календаря"
WriteDataFromButton(c)			-- обработка событий при нажатии кнопок

Core.onExtChange({"DateSelectorPressed_T"},CheckDateSelected)
Core.onExtChange({"DateSelectorPressed_T","HourButtonPressed_T","DateButtonPressed_T","MonthButtonPressed_T"},WriteDataFromDateSelector)
Core.onExtChange({"HourButtonPressed_T","DateButtonPressed_T","MonthButtonPressed_T", "QuarterButtonPressed_T", "YearButtonPressed_T"},WriteDataFromButton)
Core.waitEvents()
