--******************************************************************
--******************* РАЗДЕЛ ОПРЕДЕЛЕНИЯ ФУНКЦИЙ *******************
--******************************************************************

FirstIndex_m = 0				-- индекс массива первой записи архива 
LastIndex_m = 91				-- индекс массива последней записи архива 
LastIndex_t = 92				-- индекс таблицы последней записи архива
metnum = Core.MeterNumber_E		-- номер выбранного счётчика (начиная с 0)

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
-- metnum - номер выбранного счётчика

function ConvertEpochToDate()

epoch_to_date = {}	
    for i = 1, LastIndex_t do epoch_to_date[i] = os.date("%d.%m.%Y", Core.Meter_E[metnum].Archive_E[i-1].D[0]) end
end

--******************************************************************
-- формирование строки вида DD-MM-YYYY HH:mm для получасового архива

function WriteDateValueHHA()

-- преобразование времени epoch в формат времени DD-MM-YYYY (epoch_to_date[1-61])
ConvertEpochToDate() 

-- создание таблицы dt для хранения строки вида DD-MM-YYYY
dt = {}
local i
for i = 1, 48 do dt[i] = epoch_to_date[c+1] end -- инициализация всех полей таблицы dt значением одной и той же даты 

-- создание таблицы tod для хранения шаблона времён суток вида "00:00" .. "23:00"
tod = {"00:00","00:30","01:00","01:30","02:00","02:30","03:00","03:30","04:00","04:30","05:00","05:30","06:00","06:30","07:00","07:30",
"08:00","08:30","09:00","09:30","10:00","10:30","11:00","11:30","12:00","12:30","13:00","13:30","14:00","14:30","15:00",
"15:30","16:00","16:30","17:00","17:30","18:00","18:30","19:00","19:30","20:00","20:30","21:00","21:30","22:00","22:30","23:00","23:30"}

-- создание пустой таблицы dt_tod для хранения строки вида DD-MM-YYYY HH:mm для получасового архива
dt_tod = {} 
local i
for i = 1, 48 do dt_tod[i] = "" end

-- заполнение таблицы dt_tod строками вида DD-MM-YYYY HH:mm
for k,v in pairs(tod) do dt_tod[k] = dt[k] .. " " .. v end

local i

-- запись строк вида DD-MM-YYYY HH:mm в текстовые ячейки
for i = 1, 48 do Core.Date_E.Field_Text[i-1] = dt_tod[i] end 

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
"12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00"}

-- создание пустой таблицы dt_tod для хранения строки вида DD-MM-YYYY HH:mm для часового архива
local dt_tod = {} 
local i
for i = 1, 24 do dt_tod[i] = "" end

-- заполнение таблицы dt_tod строками вида DD-MM-YYYY HH:mm
for k,v in pairs(tod) do dt_tod[k] = dt[k] .. " " .. v end

local i

-- запись строк вида DD-MM-YYYY HH:mm в текстовые ячейки
for i = 1, 24 do Core.Date_E.Field_Text[i-1] = dt_tod[i] end 

end

--******************************************************************
-- формирование строк вида "01-01-1970" .. "31-01-1970" для суточного архива

function WriteDateValueDA()

ConvertEpochToDate()	-- преобразование времени epoch в формат времени DD-MM-YYYY (epoch_to_date[1-61])

dt = {}					-- создание таблицы dt для хранения строк вида "01-01-1970" .. "31-01-1970"

a = c 					-- c - глобальный индекс в Meter_E[c], а - локальный индекс (для предотвращения доступа к глобальной с)

	if a < LastIndex_t - 29 then		-- пока индекс с < 31 конструируем таблицу размером 31
		for i = 1, 31 do 
			table.insert(dt, epoch_to_date[a+1])
			a=a+1
			Core.Date_E.Field_Text[i-1] = dt[i]	-- запись строк вида "01-01-1970" .. "31-01-1970" в текстовые ячейки
		end 
--to do
--to do
	else size = LastIndex_t - a		-- если с >= 31 начинаем уменьшать число итераций добавления строк в таблицу dt из таблицы epoch_to_date{} 
									-- size - число итераций добавления строк в таблицу dt учитывающее оставшийся размер таблицы epoch_to_date{}
		for i = 1, size do 
			table.insert(dt, epoch_to_date[a+1])
			a=a+1
			Core.Date_E.Field_Text[i-1] = dt[i]  	-- запись строк вида "01-01-1970" .. "31-01-1970" в текстовые ячейки
		end
		for i = size+1, 31 do Core.Date_E.Field_Text[i-1] = "нет данных" end 
	end
end

--******************************************************************
-- формирование строки вида month - YYYY- для месячного архива

function WriteDateValueMA()
ConvertEpochToDate();	-- преобразование времени epoch в формат времени DD-MM-YYYY (epoch_to_date[1-..])
month = {}; 			-- создать таблицу month
a = c;
size = LastIndex_m - a;								-- вычислить оставшийся размер архивных записей
 
	while size >= 32 do								-- пока оставшийся размер архивных записей больше 32 (32 - смещение для получения "следующего месяца")
		table.insert(month, epoch_to_date[a+1]);	-- заполнить таблицу записями дат
		a=a+33;										-- увеличить "с" на смещение 32
		size = LastIndex_m - a;						-- вычислить оставшийся размер архивных записей
		i = 0;
		i = i + 1;									-- посчитать количество отработанных циклов while (количество записей в таблице month)
	end

	for x = 0, i do
		--Core.Date_E.Field_Text[x] = month[x+1];  	-- записать содержимое таблицы month в текстовые поля
		Core.Date_E.Field_Text[x] = os.date("%B - %Y", tonumber(month[x+1]));  	-- записать содержимое таблицы month в текстовые поля
	end

	for x = i + 1, 11 do
		Core.Date_E.Field_Text[x] = "нет данных";  	-- вместо отсутствующих данных записать "нет данных"
	end
end

--******************************************************************
-- формирование строки вида "I(II,III,IV) квартал - 2017" для квартального архива

function WriteDateValueQA()

-- создание таблицы quarter для хранения шаблона времён суток вида I,II,III,IV
quarter = {"I квартал - ","II квартал - ","III квартал - ","IV квартал - "}

	for i = 1, 4 do Core.Date_E.Field_Text[i-1] = quarter[i] .. os.date("%Y", Core.DateSelect) end 

end

--******************************************************************
-- формирование строки вида "2017" для годового архива

function WriteDateValueYA()

	Core.Date_E.Field_Text[0] = os.date("%Y", Core.DateSelect)

end

--******************************************************************
-- заполнение текстовых ячеек данными (получасовой архив)

-- metnum 	- номер выбранного счётчика (начиная с 0)
-- c		- индекс архива возвращённый функцией выбора даты
-- i		- количество циклов записи

function WriteDataValueInTextFieldHHA()
	if c <= LastIndex_m then
		for i = 0, 47 do
			Core.Ea_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Ea_Receive[i])
			Core.Er_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Er_Receive[i])
			Core.Pa_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Pa_Receive[i])
			Core.Ea_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Ea_Return[i])
			Core.Er_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Er_Return[i])
			Core.Pa_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Pa_Return[i])
		end
	end
end

--******************************************************************
-- заполнение текстовых ячеек данными (часовой архив)

function WriteDataValueInTextFieldHA()
	if c <= LastIndex_m then
		for i = 0, 23 do
			Core.Ea_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Ea_Receive[i])
			Core.Er_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Er_Receive[i])
			Core.Pa_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Pa_Receive[i])
			Core.Ea_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Ea_Return[i])
			Core.Er_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Er_Return[i])
			Core.Pa_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Pa_Return[i])
		end
	end
end

--******************************************************************
-- заполнение текстовых ячеек данными (суточный архив)

function WriteDataValueInTextFieldDA()
	if c <= LastIndex_m then
		for i = 0, 30 do
			Core.Ea_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Ea_Receive[i])
			Core.Er_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Er_Receive[i])
			Core.Pa_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Pa_Receive[i])
			Core.Ea_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Ea_Return[i])
			Core.Er_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Er_Return[i])
			Core.Pa_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Pa_Return[i])
		end
	end
end

--******************************************************************
-- заполнение текстовых ячеек данными (месячный архив)

function WriteDataValueInTextFieldMA()
	if c <= LastIndex_m then
		for i = 0, 11 do
			Core.Ea_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Ea_Receive[i])
			Core.Er_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Er_Receive[i])
			Core.Pa_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Pa_Receive[i])
			Core.Ea_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Ea_Return[i])
			Core.Er_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Er_Return[i])
			Core.Pa_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Pa_Return[i])
		end
	end
end

--******************************************************************
-- заполнение текстовых ячеек данными (квартальный архив)

function WriteDataValueInTextFieldQA()
	if c <= LastIndex_m then
		for i = 0, 3 do
			Core.Ea_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Ea_Receive[i])
			Core.Er_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Er_Receive[i])
			Core.Pa_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Pa_Receive[i])
			Core.Ea_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Ea_Return[i])
			Core.Er_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Er_Return[i])
			Core.Pa_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Pa_Return[i])
		end
	end
end

--******************************************************************
-- заполнение текстовых ячеек данными (годовой архив)

function WriteDataValueInTextFieldYA()
	if c <= LastIndex_m then
		for i = 0, 0 do
			Core.Ea_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Ea_Receive[i])
			Core.Er_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Er_Receive[i])
			Core.Pa_Receive.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Pa_Receive[i])
			Core.Ea_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Ea_Return[i])
			Core.Er_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Er_Return[i])
			Core.Pa_Return.IO_Field_Text[i] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Pa_Return[i])
		end
	end
end

--******************************************************************
-- управление поведением текстовых ячеек (получасовой архив)

function ChangeBehaviorTextFieldHHA()
    for i = 0, 47 do
	    Core.Date_E.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = true	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = true
        Core.Pa_Receive.IO_Field_Visible[i] = true
        Core.Ea_Return.IO_Field_Visible[i] = true
        Core.Er_Return.IO_Field_Visible[i] = true
        Core.Pa_Return.IO_Field_Visible[i] = true
   end 
	 y = 868
		Core.Date_E.Total_Text_Pos[0] = y				-- изменение координаты "у" текстовых полей "Сумма", "Среднее", "Минимум", "Максимум"
		Core.Ea_Receive.IO_Field_Button_Pos[0] = y	
		Core.Er_Receive.IO_Field_Button_Pos[0] = y
		Core.Pa_Receive.IO_Field_Button_Pos[0] = y
		Core.Ea_Return.IO_Field_Button_Pos[0] = y
		Core.Er_Return.IO_Field_Button_Pos[0] = y
		Core.Pa_Return.IO_Field_Button_Pos[0] = y
end


--******************************************************************
-- управление поведением текстовых ячеек (часовой архив)

function ChangeBehaviorTextFieldHA()
    for i = 0, 23 do
	    Core.Date_E.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = true	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = true
        Core.Pa_Receive.IO_Field_Visible[i] = true
        Core.Ea_Return.IO_Field_Visible[i] = true
        Core.Er_Return.IO_Field_Visible[i] = true
        Core.Pa_Return.IO_Field_Visible[i] = true
       end 
    for i = 24, 47 do
	    Core.Date_E.Field_Visible[i] = false			-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = false		-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = false
        Core.Pa_Receive.IO_Field_Visible[i] = false
        Core.Ea_Return.IO_Field_Visible[i] = false
        Core.Er_Return.IO_Field_Visible[i] = false
        Core.Pa_Return.IO_Field_Visible[i] = false
        end 
	 y = 436
		Core.Date_E.Total_Text_Pos[0] = y				-- изменение координаты "у" текстовых полей "Сумма", "Среднее", "Минимум", "Максимум"
		Core.Ea_Receive.IO_Field_Button_Pos[0] = y	
		Core.Er_Receive.IO_Field_Button_Pos[0] = y
		Core.Pa_Receive.IO_Field_Button_Pos[0] = y
		Core.Ea_Return.IO_Field_Button_Pos[0] = y
		Core.Er_Return.IO_Field_Button_Pos[0] = y
		Core.Pa_Return.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- управление поведением текстовых ячеек (суточный архив)

function ChangeBehaviorTextFieldDA()
    for i = 0, 30 do
		Core.Date_E.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = true	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = true
        Core.Pa_Receive.IO_Field_Visible[i] = true
        Core.Ea_Return.IO_Field_Visible[i] = true
        Core.Er_Return.IO_Field_Visible[i] = true
        Core.Pa_Return.IO_Field_Visible[i] = true
		end
    for i = 31, 47 do
	    Core.Date_E.Field_Visible[i] = false			-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = false		-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = false
        Core.Pa_Receive.IO_Field_Visible[i] = false
        Core.Ea_Return.IO_Field_Visible[i] = false
        Core.Er_Return.IO_Field_Visible[i] = false
        Core.Pa_Return.IO_Field_Visible[i] = false
    end 
	 y = 562
		Core.Date_E.Total_Text_Pos[0] = y				-- изменение координаты "у" тексотвых полей "Сумма", "Среднее", "Минимум", "Максимум"
		Core.Ea_Receive.IO_Field_Button_Pos[0] = y	
		Core.Er_Receive.IO_Field_Button_Pos[0] = y
		Core.Pa_Receive.IO_Field_Button_Pos[0] = y
		Core.Ea_Return.IO_Field_Button_Pos[0] = y
		Core.Er_Return.IO_Field_Button_Pos[0] = y
		Core.Pa_Return.IO_Field_Button_Pos[0] = y
end
--******************************************************************
-- управление поведением текстовых ячеек (месячный архив)

function ChangeBehaviorTextFieldMA()

    for i = 0, 11 do
	    Core.Date_E.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = true	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = true
        Core.Pa_Receive.IO_Field_Visible[i] = true
        Core.Ea_Return.IO_Field_Visible[i] = true
        Core.Er_Return.IO_Field_Visible[i] = true
        Core.Pa_Return.IO_Field_Visible[i] = true
       end 
    for i = 12, 47 do
	    Core.Date_E.Field_Visible[i] = false		-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = false	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = false
        Core.Pa_Receive.IO_Field_Visible[i] = false
        Core.Ea_Return.IO_Field_Visible[i] = false
        Core.Er_Return.IO_Field_Visible[i] = false
        Core.Pa_Return.IO_Field_Visible[i] = false
        end 
	 y = 220
		Core.Date_E.Total_Text_Pos[0] = y				-- изменение координаты "у" тексотвых полей "Сумма", "Среднее", "Минимум", "Максимум"
		Core.Ea_Receive.IO_Field_Button_Pos[0] = y	
		Core.Er_Receive.IO_Field_Button_Pos[0] = y
		Core.Pa_Receive.IO_Field_Button_Pos[0] = y
		Core.Ea_Return.IO_Field_Button_Pos[0] = y
		Core.Er_Return.IO_Field_Button_Pos[0] = y
		Core.Pa_Return.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- управление поведением текстовых ячеек (квартальный архив)

function ChangeBehaviorTextFieldQA()

    for i = 0, 3 do
	    Core.Date_E.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = true	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = true
        Core.Pa_Receive.IO_Field_Visible[i] = true
        Core.Ea_Return.IO_Field_Visible[i] = true
        Core.Er_Return.IO_Field_Visible[i] = true
        Core.Pa_Return.IO_Field_Visible[i] = true
       end 
    for i = 4, 47 do
	    Core.Date_E.Field_Visible[i] = false		-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = false	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = false
        Core.Pa_Receive.IO_Field_Visible[i] = false
        Core.Ea_Return.IO_Field_Visible[i] = false
        Core.Er_Return.IO_Field_Visible[i] = false
        Core.Pa_Return.IO_Field_Visible[i] = false
        end 
	 y = 76
		Core.Date_E.Total_Text_Pos[0] = y				-- изменение координаты "у" тексотвых полей "Сумма", "Среднее", "Минимум", "Максимум"
		Core.Ea_Receive.IO_Field_Button_Pos[0] = y	
		Core.Er_Receive.IO_Field_Button_Pos[0] = y
		Core.Pa_Receive.IO_Field_Button_Pos[0] = y
		Core.Ea_Return.IO_Field_Button_Pos[0] = y
		Core.Er_Return.IO_Field_Button_Pos[0] = y
		Core.Pa_Return.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- управление поведением текстовых ячеек (годовой архив)

function ChangeBehaviorTextFieldYA()

    for i = 0, 0 do
	    Core.Date_E.Field_Visible[i] = true			-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = true	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = true
        Core.Pa_Receive.IO_Field_Visible[i] = true
        Core.Ea_Return.IO_Field_Visible[i] = true
        Core.Er_Return.IO_Field_Visible[i] = true
        Core.Pa_Return.IO_Field_Visible[i] = true
       end 
    for i = 1, 47 do
	    Core.Date_E.Field_Visible[i] = false		-- задание видимости текстовых ячеек с датами
        Core.Ea_Receive.IO_Field_Visible[i] = false	-- задание видимости текстовых ячеек с данными
        Core.Er_Receive.IO_Field_Visible[i] = false
        Core.Pa_Receive.IO_Field_Visible[i] = false
        Core.Ea_Return.IO_Field_Visible[i] = false
        Core.Er_Return.IO_Field_Visible[i] = false
        Core.Pa_Return.IO_Field_Visible[i] = false
        end 
	 y = 23
		Core.Date_E.Total_Text_Pos[0] = y				-- изменение координаты "у" тексотвых полей "Сумма", "Среднее", "Минимум", "Максимум"
		Core.Ea_Receive.IO_Field_Button_Pos[0] = y	
		Core.Er_Receive.IO_Field_Button_Pos[0] = y
		Core.Pa_Receive.IO_Field_Button_Pos[0] = y
		Core.Ea_Return.IO_Field_Button_Pos[0] = y
		Core.Er_Return.IO_Field_Button_Pos[0] = y
		Core.Pa_Return.IO_Field_Button_Pos[0] = y
end

--******************************************************************
-- вычисления суммы значений

function mathsum(t)
         sum = 0
        for k,v in pairs(t) do sum = sum + v end
    return sum
end

--******************************************************************
-- создание таблиц для вычисления суммарного, среднего, минимального и максимального значений

function CreateTotalTable()
    Ea_Receive = {}
    Er_Receive = {}
    Pa_Receive = {}
    Ea_Return = {}
    Er_Return = {}
    Pa_Return = {}
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (получасовой архив)

function WriteDataValueInTableHHA()
	
    for i = 0, 47 do
        Ea_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Ea_Receive[i])
        Er_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Er_Receive[i])
        Pa_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Pa_Receive[i])
        Ea_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Ea_Return[i])
        Er_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Er_Return[i])
        Pa_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HHA[0].Pa_Return[i])
	end
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (часовой архив)

function WriteDataValueInTableHA()
	
    for i = 0, 23 do
        Ea_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Ea_Receive[i])
        Er_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Er_Receive[i])
        Pa_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Pa_Receive[i])
        Ea_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Ea_Return[i])
        Er_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Er_Return[i])
        Pa_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].HA[0].Pa_Return[i])
	end
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (суточный архив)

function WriteDataValueInTableDA()

	for i = 0, 30 do
        Ea_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Ea_Receive[i])
        Er_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Er_Receive[i])
        Pa_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Pa_Receive[i])
        Ea_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Ea_Return[i])
        Er_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Er_Return[i])
        Pa_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].DA[0].Pa_Return[i])
	end
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (месячный архив)

function WriteDataValueInTableMA()
	
	for i = 0, 11 do
        Ea_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Ea_Receive[i])
        Er_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Er_Receive[i])
        Pa_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Pa_Receive[i])
        Ea_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Ea_Return[i])
        Er_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Er_Return[i])
        Pa_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].MA[0].Pa_Return[i])
	end
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (квартальный архив)

function WriteDataValueInTableQA()
	
	for i = 0, 3 do
        Ea_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Ea_Receive[i])
        Er_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Er_Receive[i])
        Pa_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Pa_Receive[i])
        Ea_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Ea_Return[i])
        Er_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Er_Return[i])
        Pa_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].QA[0].Pa_Return[i])
	end
end

--******************************************************************
-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений (годовой архив)

function WriteDataValueInTableYA()
	
	for i = 0, 0 do
        Ea_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Ea_Receive[i])
	    Er_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Er_Receive[i])
        Pa_Receive[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Pa_Receive[i])
        Ea_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Ea_Return[i])
        Er_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Er_Return[i])
        Pa_Return[i+1] = string.format("%.2f", Core.Meter_E[metnum].Archive_E[c].YA[0].Pa_Return[i])
	end
end

--******************************************************************
-- вычисления суммы, средних,  минимальных, максимальных значений

function CalcTotalValue()

    Core.Ea_Receive.IO_Field_Text[48] = mathsum(Ea_Receive) -- вычисления суммы значений
    Core.Er_Receive.IO_Field_Text[48] = mathsum(Er_Receive)
    Core.Pa_Receive.IO_Field_Text[48] = mathsum(Pa_Receive)
    Core.Ea_Return.IO_Field_Text[48] = mathsum(Ea_Return)
    Core.Er_Return.IO_Field_Text[48] = mathsum(Er_Return)
    Core.Pa_Return.IO_Field_Text[48] = mathsum(Pa_Return)

    Core.Ea_Receive.IO_Field_Text[49] = (math.max(table.unpack(Ea_Receive)) + math.min(table.unpack(Ea_Receive))) / 2 -- вычисления средних значений
    Core.Er_Receive.IO_Field_Text[49] = (math.max(table.unpack(Er_Receive)) + math.min(table.unpack(Er_Receive))) / 2
    Core.Pa_Receive.IO_Field_Text[49] = (math.max(table.unpack(Pa_Receive)) + math.min(table.unpack(Pa_Receive))) / 2
    Core.Ea_Return.IO_Field_Text[49] = (math.max(table.unpack(Ea_Return)) + math.min(table.unpack(Ea_Return))) / 2
    Core.Er_Return.IO_Field_Text[49] = (math.max(table.unpack(Er_Return)) + math.min(table.unpack(Er_Return))) / 2
    Core.Pa_Return.IO_Field_Text[49] = (math.max(table.unpack(Pa_Return)) + math.min(table.unpack(Pa_Return))) / 2

    Core.Ea_Receive.IO_Field_Text[50] = math.min(table.unpack(Ea_Receive)) -- вычисления минимальных значений
    Core.Er_Receive.IO_Field_Text[50] = math.min(table.unpack(Er_Receive))
    Core.Pa_Receive.IO_Field_Text[50] = math.min(table.unpack(Pa_Receive))
    Core.Ea_Return.IO_Field_Text[50] = math.min(table.unpack(Ea_Return))
    Core.Er_Return.IO_Field_Text[50] = math.min(table.unpack(Er_Return))
    Core.Pa_Return.IO_Field_Text[50] = math.min(table.unpack(Pa_Return))

    Core.Ea_Receive.IO_Field_Text[51] = math.max(table.unpack(Ea_Receive)) -- вычисления максимальных значений
    Core.Er_Receive.IO_Field_Text[51] = math.max(table.unpack(Er_Receive))
    Core.Pa_Receive.IO_Field_Text[51] = math.max(table.unpack(Pa_Receive))
    Core.Ea_Return.IO_Field_Text[51] = math.max(table.unpack(Ea_Return))
    Core.Er_Return.IO_Field_Text[51] = math.max(table.unpack(Er_Return))
    Core.Pa_Return.IO_Field_Text[51] = math.max(table.unpack(Pa_Return))
end

--******************************************************************
-- проверка события выбора счётчика и возврат номера выбранного счётчика (начиная с 0)

function CheckMeterSelected()
		if Core.NumberOfMeterChanged_E == true then	-- событие смены счётчика
			metnum = Core.MeterNumber_E				-- номер выбранного счётчика (начиная с 0)
		end
	return metnum
end

--******************************************************************
-- проверка вхождения введённой даты в диапазон дат и возврат индекса выбранной даты

function CheckDateSelected()
::redo::
        if Core.DateSelectorPressed_E == true then        -- событие смены даты пользователем в "календаре"

			Core.DateSelect = Core.DateSelect_GUI_E       -- DateSelect_GUI_E - дата выбранная
            if (Core.DateSelect >= Core.DateFirst) and (Core.DateSelect <= Core.DateLast) then	-- проверка вхождения выбранной даты в диапазон дат (в формате UNIX-epoch)
                --Core.DateInRange = true														-- ОК! выбранная дата в диапазоне
                c = (revepoch[Core.DateSelect]) - 1												-- получить индекс архива --> Arhive[c]
	            else
					Core.DateOutOfRange_E = false
                    Core.DateOutOfRange_E = true													-- ERROR! выбранная дата вне диапазона -> вызов окна "Предупреждение"
					Core.WarningMessage_E = string.format ("Выбранная дата вне диапазона дат архива.\nДата первой записи архива:      %s\nДата последней записи архива: %s\nПовторите ввод даты.", tostring(os.date("%d.%m.%Y", Core.DateFirst)), tostring(os.date("%d.%m.%Y", Core.DateLast)))	
					--error("error input")
					goto redo
			end
		end
	return c																					-- возвратить индекс архива --> Arhive[c]
end

--******************************************************************
-- формирование текстовой строки для заголовка мнемосхемы

function HeaderTextGenerator()

t_object = {"[ЗРУ ВРК 10 кВ] ячейка 4 ВВ1", "[ЗРУ ВРК 10 кВ] ячейка 30 ВВ2", "[ПС Романово] ячейка 16 ВВ1"}
t_meter = {"Евроальфа", "Энергомера", "Нева МТ113"}

	for i = 0, 2 do 
		if (Core.HalfHourButtonPressed_E == true or Core.NumberOfMeterChanged_E == true) and metnum == i  then  -- нажата кнопка "Получасовой архив"
			Core.Header_Text_E = string.format ("Получасовой архив учёта электроэнергии, ОБЪЕКТ:  %s СЧЁТЧИК:  %s ", t_object[i+1], t_meter[i+1])
	
		elseif (Core.HourButtonPressed_E == true or Core.NumberOfMeterChanged_E == true) and metnum == i then  -- нажата кнопка "Часовой архив"
			Core.Header_Text_E = string.format ("Часовой архив учёта электроэнергии, ОБЪЕКТ:  %s СЧЁТЧИК:  %s ", t_object[i+1], t_meter[i+1])
	
		elseif (Core.DateButtonPressed_E == true or Core.NumberOfMeterChanged_E == true) and metnum == i then      -- нажата кнопка "Суточный архив"
			Core.Header_Text_E = string.format ("Суточный архив учёта электроэнергии, ОБЪЕКТ:  %s СЧЁТЧИК:  %s ", t_object[i+1], t_meter[i+1])
	
		elseif (Core.MonthButtonPressed_E == true or Core.NumberOfMeterChanged_E == true) and metnum == i then		-- нажата кнопка "Месячный архив"
			Core.Header_Text_E = string.format ("Месячный архив учёта электроэнергии, ОБЪЕКТ:  %s СЧЁТЧИК:  %s ", t_object[i+1], t_meter[i+1])

		elseif (Core.QuarterButtonPressed_E == true or Core.NumberOfMeterChanged_E == true) and metnum == i then		-- нажата кнопка "Квартальный архив"
			Core.Header_Text_E = string.format ("Квартальный архив учёта электроэнергии, ОБЪЕКТ:  %s СЧЁТЧИК:  %s ", t_object[i+1], t_meter[i+1])

		elseif (Core.YearButtonPressed_E == true or Core.NumberOfMeterChanged_E == true) and metnum == i then		-- нажата кнопка "Годовой архив"
			Core.Header_Text_E = string.format ("Годовой архив учёта электроэнергии, ОБЪЕКТ:  %s СЧЁТЧИК:  %s ", t_object[i+1], t_meter[i+1])

		end
	end
end

--******************************************************************
-- запись данных в текстовые ячейки от выпадающего списка 

function WriteDataFromMeterSelector()

	if Core.NumberOfMeterChanged_E == true and Core.HalfHourButtonPressed_E == true then	-- изменена дата "календаря" и ранее нажата кнопка "Получасовой архив"

-- обработка получасового архива
            WriteDateValueHHA()            	-- формирование строк вида "01.01.1970 00:00/00:30"
			WriteDataValueInTextFieldHHA()	-- заполнение текстовых ячеек данными
		    CreateTotalTable() 		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableHHA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif 	Core.NumberOfMeterChanged_E == true and Core.HourButtonPressed_E == true then	-- изменена дата "календаря" и ранее нажата кнопка "Часовой архив"

-- обработка часового архива
            WriteDateValueHA()            	-- формирование строк вида "01.01.1970 00:00"
			WriteDataValueInTextFieldHA()	-- заполнение текстовых ячеек данными
		    CreateTotalTable() 		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableHA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif	Core.NumberOfMeterChanged_E == true and Core.DateButtonPressed_E  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Суточный архив"

-- обработка суточного архива
            WriteDateValueDA()				-- формирование строк вида "01.01.1970" .. "31.01.1970"
			WriteDataValueInTextFieldDA()	-- заполнение текстовых ячеек данными
            CreateTotalTable() 		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableDA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif  Core.NumberOfMeterChanged_E == true and Core.MonthButtonPressed_E  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Месячный архив"

-- обработка месячного архива
			WriteDateValueMA()				-- формирование строк вида "Январь - 1970/Февраль - 1970/Март - 1970/..."
			WriteDataValueInTextFieldMA()	-- заполнение текстовых ячеек данными
			CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableMA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif  Core.NumberOfMeterChanged_E == true and Core.QuarterButtonPressed_E  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Квартальный архив"

-- обработка квартального архива
			WriteDateValueQA()				-- формирование строк вида "I квартал - 1970 .. IV квартал - 1970"
			WriteDataValueInTextFieldQA()	-- заполнение текстовых ячеек данными
			CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableQA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif  Core.NumberOfMeterChanged_E == true and Core.YearButtonPressed_E  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Годовой архив"

-- обработка годового архива
			WriteDateValueYA()				-- формирование строк вида "1970 .. 2017"
			WriteDataValueInTextFieldYA()	-- заполнение текстовых ячеек данными
			CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableYA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
	end

	HeaderTextGenerator()					-- формирование текстовой строки для заголовка мнемосхемы

end
--******************************************************************
-- запись данных в текстовые ячейки от "календаря"

function WriteDataFromDateSelector()

	if Core.DateSelectorPressed_E == true and Core.HalfHourButtonPressed_E == true then	-- изменена дата "календаря" и ранее нажата кнопка "Получасовой архив"

-- обработка получасового архива
            WriteDateValueHHA()            	-- формирование строк вида "01.01.1970 00:00/00:30"
			WriteDataValueInTextFieldHHA()	-- заполнение текстовых ячеек данными
		    CreateTotalTable() 		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableHHA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif 	Core.DateSelectorPressed_E == true and Core.HourButtonPressed_E == true then	-- изменена дата "календаря" и ранее нажата кнопка "Часовой архив"

-- обработка часового архива
            WriteDateValueHA()            	-- формирование строк вида "01.01.1970 00:00"
			WriteDataValueInTextFieldHA()	-- заполнение текстовых ячеек данными
		    CreateTotalTable() 		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableHA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif	Core.DateSelectorPressed_E == true and Core.DateButtonPressed_E  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Суточный архив"

-- обработка суточного архива
            WriteDateValueDA()				-- формирование строк вида "01.01.1970" .. "31.01.1970"
			WriteDataValueInTextFieldDA()	-- заполнение текстовых ячеек данными 
            CreateTotalTable() 		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableDA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений 
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif  Core.DateSelectorPressed_E == true and Core.MonthButtonPressed_E  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Месячный архив"

-- обработка месячного архива
			WriteDateValueMA()				-- формирование строк вида "Январь - 1970/Февраль - 1970/Март - 1970/..."
			WriteDataValueInTextFieldMA()	-- заполнение текстовых ячеек данными 
			CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableMA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif  Core.DateSelectorPressed_E == true and Core.QuarterButtonPressed_E  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Квартальный архив"

-- обработка квартального архива
			WriteDateValueQA()				-- формирование строк вида "I квартал - 1970 .. IV квартал - 1970"
			WriteDataValueInTextFieldQA()	-- заполнение текстовых ячеек данными 
			CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableQA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений

	elseif  Core.DateSelectorPressed_E == true and Core.YearButtonPressed_E  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Годовой архив"

-- обработка годового архива
			WriteDateValueYA()				-- формирование строк вида "1970 .. 2017"
			WriteDataValueInTextFieldYA()	-- заполнение текстовых ячеек данными 
			CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableYA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
			CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
	end
	os.sleep(0.5)
	Core.DateSelectorPressed_E = false
end

--******************************************************************
-- запись данных в текстовые ячейки от кнопок

function WriteDataFromButton()
	
	if Core.HalfHourButtonPressed_E == true then  -- нажата кнопка "Получасовой архив"

-- обработка получасового архива
	    Core.HalfHourButtonFontBold_E = true		-- задание жирности шрифта кнопок
	    Core.HourButtonFontBold_E = false
	    Core.DateButtonFontBold_E = false     
	    Core.MonthButtonFontBold_E = false
		Core.QuarterButtonFontBold_E = false
		Core.YearButtonFontBold_E = false

        WriteDateValueHHA()				-- формирование строк вида "01.01.1970 00:00/00:30"
	    ChangeBehaviorTextFieldHHA()	-- управление поведением текстовых ячеек
	    CreateTotalTable() 				-- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
		WriteDataValueInTableHHA()		-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
	    CalcTotalValue() 				-- вычисления суммы, средних,  минимальных, максимальных значений
        WriteDataValueInTextFieldHHA()	-- заполнение текстовых ячеек данными

	elseif Core.HourButtonPressed_E == true then  -- нажата кнопка "Часовой архив"

-- обработка часового архива
			Core.HalfHourButtonFontBold_E = false	-- задание жирности шрифта кнопок
		    Core.HourButtonFontBold_E = true
		    Core.DateButtonFontBold_E = false     
		    Core.MonthButtonFontBold_E = false
		  	Core.QuarterButtonFontBold_E = false
			Core.YearButtonFontBold_E = false
	
	        WriteDateValueHA()				-- формирование строк вида "01.01.1970 00:00"
		    ChangeBehaviorTextFieldHA()		-- управление поведением текстовых ячеек
		    CreateTotalTable() 				-- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableHA()		-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
		    CalcTotalValue() 				-- вычисления суммы, средних,  минимальных, максимальных значений
	        WriteDataValueInTextFieldHA()	-- заполнение текстовых ячеек данными

	elseif Core.DateButtonPressed_E == true then      -- нажата кнопка "Суточный архив"

-- обработка суточного архива
			Core.HalfHourButtonFontBold_E = false		-- задание жирности шрифта кнопок
	        Core.HourButtonFontBold_E = false         
	        Core.DateButtonFontBold_E = true
	        Core.MonthButtonFontBold_E = false
			Core.QuarterButtonFontBold_E = false
			Core.YearButtonFontBold_E = false
			
			WriteDateValueDA()				-- формирование строк вида "01.01.1970" .. "31.01.1970"
			ChangeBehaviorTextFieldDA()		-- управление поведением текстовых ячеек
		    CreateTotalTable() 				-- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableDA()		-- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
			CalcTotalValue() 				-- вычисления суммы, средних,  минимальных, максимальных значений
			WriteDataValueInTextFieldDA()	-- заполнение текстовых ячеек данными 

	elseif Core.MonthButtonPressed_E == true then		-- нажата кнопка "Месячный архив"

-- обработка месячного архива
			Core.HalfHourButtonFontBold_E = false		-- задание жирности шрифта кнопок
	        Core.HourButtonFontBold_E = false            
	        Core.DateButtonFontBold_E = false
	        Core.MonthButtonFontBold_E = true
			Core.QuarterButtonFontBold_E = false
			Core.YearButtonFontBold_E = false

			WriteDateValueMA()				-- формирование строк вида "Январь - 1970/Февраль - 1970/Март - 1970/..."
		    ChangeBehaviorTextFieldMA()		-- управление поведением текстовых ячеек
		    CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableMA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
			WriteDataValueInTextFieldMA()	-- заполнение текстовых ячеек данными

	elseif Core.QuarterButtonPressed_E == true then		-- нажата кнопка "Квартальный архив"

-- обработка квартального архива	
			Core.HalfHourButtonFontBold_E = false		-- задание жирности шрифта кнопок
	        Core.HourButtonFontBold_E = false            
	        Core.DateButtonFontBold_E = false
	        Core.MonthButtonFontBold_E = false	
			Core.QuarterButtonFontBold_E = true
			Core.YearButtonFontBold_E = false	

			WriteDateValueQA()				-- заполнение полей дат
			ChangeBehaviorTextFieldQA()		-- управление поведением текстовых ячеек
		    CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableQA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
			WriteDataValueInTextFieldQA()	-- заполнение текстовых ячеек данными

	elseif Core.YearButtonPressed_E == true then		-- нажата кнопка "Годовой архив"	

-- обработка годового архива	
			Core.HalfHourButtonFontBold_E = false		-- задание жирности шрифта кнопок
	        Core.HourButtonFontBold_E = false            
	        Core.DateButtonFontBold_E = false
	        Core.MonthButtonFontBold_E = false	
			Core.QuarterButtonFontBold_E = false
			Core.YearButtonFontBold_E = true

			WriteDateValueYA()				-- формирование строк вида "1970 .. 2017"
			ChangeBehaviorTextFieldYA()		-- управление поведением текстовых ячеек
		    CreateTotalTable()		        -- создание таблиц для поиска суммарного, среднего, минимального и максимального значений
			WriteDataValueInTableYA()	    -- заполнение таблиц данными для поиска суммарного, среднего, минимального и максимального значений
		    CalcTotalValue() 		        -- вычисления суммы, средних,  минимальных, максимальных значений
			WriteDataValueInTextFieldYA()	-- заполнение текстовых ячеек данными
	end

	HeaderTextGenerator() 					-- формирование текстовой строки для заголовка мнемосхемы

end
	
--******************************************************************
--*********************** РАЗДЕЛ ИСПОЛНЕНИЯ ************************
--******************************************************************
Core.InitScreenE = true
--dofile("f:\\!Projects\\Energy_Accounting_ET\\Design\\InitE.lua") -- иницилизация переменных (имитация реальных данных)
dofile("InitE.lua")
CheckMeterSelected()			-- проверка события выбора счётчика
CheckDateSelected() 		    -- проверка вхождения введённой даты в диапазон дат
WriteDataFromMeterSelector()	-- обработка события выбора счётчика
WriteDataFromDateSelector()		-- обработка события изменения даты
WriteDataFromButton()			-- обработка событий нажатия кнопок

Core.onExtChange({"NumberOfMeterChanged_E"}, CheckMeterSelected) 	-- обработчик события выбора счётчика
Core.onExtChange({"DateSelectorPressed_E"}, CheckDateSelected)		-- обработчик события выбора даты

Core.onExtChange(				-- обработчик события 
{"NumberOfMeterChanged_E", 
"HalfHourButtonPressed_E", 
"HourButtonPressed_E", 
"DateButtonPressed_E", 
"MonthButtonPressed_E",
"QuarterButtonPressed_E",
"YearButtonPressed_E"}, 
WriteDataFromMeterSelector)

Core.onExtChange(
{"DateSelectorPressed_E", 
"HalfHourButtonPressed_E", 
"HourButtonPressed_E", 
"DateButtonPressed_E", 
"MonthButtonPressed_E",
"QuarterButtonPressed_E",
"YearButtonPressed_E"}, 
WriteDataFromDateSelector)

Core.onExtChange(
{"HalfHourButtonPressed_E", 
"HourButtonPressed_E", 
"DateButtonPressed_E", 
"MonthButtonPressed_E", 
"QuarterButtonPressed_E", 
"YearButtonPressed_E"}, 
WriteDataFromButton)

Core.waitEvents()
