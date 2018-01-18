
	local fdHour_1;		-- дескриптор файла часового архива теплового ввода 1
	local fdDate_1;		-- дескриптор файла суточного архива теплового ввода 1
	local fdMonth_1;	-- дескриптор файла месячного архива теплового ввода 1

	local fdHour_2;		-- дескриптор файла часового архива теплового ввода 2
	local fdDate_2;		-- дескриптор файла суточного архива теплового ввода 2
	local fdMonth_2;	-- дескриптор файла месячного архива теплового ввода 2

	--local pathHour_1 = "C:/!Projects/Energy_Accounting_T_v4/ArchiveFiles/HourArchive_1.txt";
	--local pathDate_1 = "C:/!Projects/Energy_Accounting_T_v4/ArchiveFiles/DateArchive_1.txt";
	--local pathMonth_1 = "C:/!Projects/Energy_Accounting_T_v4/ArchiveFiles/MonthArchive_1.txt";
	
	--local pathHour_2 = "C:/!Projects/Energy_Accounting_T_v4/ArchiveFiles/HourArchive_2.txt";
	--local pathDate_2 = "C:/!Projects/Energy_Accounting_T_v4/ArchiveFiles/DateArchive_2.txt";
	--local pathMonth_2 = "C:/!Projects/Energy_Accounting_T_v4/ArchiveFiles/MonthArchive_2.txt";
	
	local pathHour_1 = "C:/SPT943_ArchiveFiles/HourArchive_1.txt";
	local pathDate_1 = "C:/SPT943_ArchiveFiles/DateArchive_1.txt";
	local pathMonth_1 = "C:/SPT943_ArchiveFiles/MonthArchive_1.txt";
	
	local pathHour_2 = "C:/SPT943_ArchiveFiles/HourArchive_2.txt";
	local pathDate_2 = "C:/SPT943_ArchiveFiles/DateArchive_2.txt";
	local pathMonth_2 = "C:/SPT943_ArchiveFiles/MonthArchive_2.txt";
	
	local userDate;
	local buttonPressed = "";

--[[--------------------------------------------------------------------------------------------------------------
	@brief	- вычисление суммы значений массива
	@param	- t		table	массив
	@return	- summ	number	сумма значений массива
--------------------------------------------------------------------------------------------------------------]]--
function mathsum( t)
	local sum = 0;
		for k,v in pairs( t) do
			sum = sum + v;
		end
	return sum;
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	
	@param	
--------------------------------------------------------------------------------------------------------------]]--
function hndQuarter2( fd, pos, dateStart, str, tQuarter)
	-- обработка данных 2-го квартала
	-- перемеcтить указатель текущей позиции выше
	fd:seek( "set", pos - 50);
	-- поиск заданной даты --
	while ( 1) do 
		if dateStart == str then
			break;									-- дата найдена ==>> к ОБРАБОТКЕ
		end
		str = tonumber(fd:read( "*l"));
	end
	-- заполнение таблицы данными тепловой энергии
	tHeat = {};										-- очистить массив
	for i = 1, 91 do
		tHeat[i] = tonumber(fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 2 квартал
		fd:read( "*l");                       -- "пустое" чтение времени
	end
	-- вычисление суммы  
	table.insert(tQuarter, mathsum( tHeat));
	-- вычисление текущей позиции в файле
	pos = fd:seek();
return pos;
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	
	@param	
--------------------------------------------------------------------------------------------------------------]]--
function hndQuarter3( fd, pos, dateStart, str, tQuarter)				
		-- обработка данных 3-го квартала
		-- перемеcтить указатель текущей позиции выше
		fd:seek( "set", pos - 50);
		-- поиск заданной даты --
		while ( 1) do 
			if dateStart == str then
				break;									-- дата найдена ==>> к ОБРАБОТКЕ
			end
			str = tonumber(fd:read( "*l"));
		end
		-- заполнение таблицы данными тепловой энергии
		tHeat = {};										-- очистить массив
		for i = 1, 92 do
			tHeat[i] = tonumber(fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 3 квартал
			fd:read( "*l");                       -- "пустое" чтение времени
		end
		-- вычисление суммы  
		table.insert(tQuarter, mathsum( tHeat));
		-- вычисление текущей позиции в файле
		pos = fd:seek();	
	return pos;
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	
	@param	
--------------------------------------------------------------------------------------------------------------]]--
function hndQuarter4( fd, pos, dateStart, str, tQuarter)
		-- обработка данных 4-го квартала
		-- перемеcтить указатель текущей позиции выше
		fd:seek( "set", pos - 50);
		-- поиск заданной даты --
		while ( 1) do 
			if dateStart == str then
				break;									-- дата найдена ==>> к ОБРАБОТКЕ
			end
			str = tonumber(fd:read( "*l"));
		end
		-- заполнение таблицы данными тепловой энергии
		tHeat = {};										-- очистить массив
		for i = 1, 92 do
			tHeat[i] = tonumber(fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 4 квартал
			fd:read( "*l");                       -- "пустое" чтение времени
		end
		-- вычисление суммы  
		table.insert(tQuarter, mathsum( tHeat));
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	
	@param	
--------------------------------------------------------------------------------------------------------------]]--
function checkInYear( fd, t, year)
-- определение даты первой записи архива    
			fd:seek( "set");
			str = fd:read( "*l");
			t = os.date( "*t", str);
			yearStart = t.year;			-- извлечь год из даты первой записи архива
			strYearStart = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);
			
-- определение даты последней записи архива      		
			pos = fd:seek( "end");
			pos = fd:seek( "set", pos - 3);
 			for i = 1, 50 do
				pos = fd:seek( "set", pos - 1);
				str = fd:read( "*L");
				if str == "\n" then 
					  pos = fd:seek( "set", pos - 11);
					  str = fd:read( "*l");
					  break;
				end
			end
			t = os.date( "*t", str);
			yearEnd = t.year;			-- извлечь год из даты последней записи архива
			strYearEnd = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);
-- проверка года, введённого пользователем на вхождение в архив
			if year < yearStart or yearEnd < year then
				--Core.WarningMessageVisible = true;
				--Core.WarningMessage = "Выбранный пользователем год - " .. year .. " находится за пределами архива!\n" .. "Начало архива: " .. strYearStart .. ", конец архива: " .. strYearEnd .. ".";
				Core.addLogMsg( "Выбранный пользователем год - " .. year .. " находится за пределами архива!");
				Core.addLogMsg( "Начало архива: " .. strYearStart .. ", конец архива: " .. strYearEnd .. ".");
				fd:close();				-- закрыть дескриптор файла
				return 1;
			end	
			strEndDeteArch = tonumber(str);
return strEndDeteArch;	-- последняя дата архива
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	
	@param	
--------------------------------------------------------------------------------------------------------------]]--
function init()

	if Core.DateSelect_GUI == nil then
		Core.addLogMsg( "Введите начальную дату!");
		return -1;
	end

	--Core.InputDateSelector = 1503090000; -- задать дату начала часового архива - Human time (your time zone): суббота, 19 августа 2017 г., 00:00:00 GMT+03:00
	--Core.InputDateSelector = str - 10800;
	Core.InputDateSelector = 1502938800 - 10800;
	userDate = 1502938800;
	Core.HourButtonPressed = true
	Core.DateButtonFontBold = false		-- задание жирности шрифта кнопок
	Core.MonthButtonFontBold = false
	Core.HourButtonFontBold = true
	Core.QuarterButtonFontBold = false
	Core.YearButtonFontBold = false
	
	buttonPressed = "h";
	
	-- ПРИМЕЧАНИЕ: дата выбранная пользователем из GUI поступает в формате epoch виде дробного числа: 0123456789.0
	-- десятую долю необходимо отрезать: 0123456789
	--userDate = tostring( Core.DateSelect_GUI - 10800);		------------->> 00:00
	--userDate = tonumber( string.sub(userDate, 1, 10));
	--userDate = tostring( Core.DateSelect_GUI);					------------->> 03:00 <<----- ОТВЕТ СЧЁТЧИКА
	--userDate = tonumber( string.sub(userDate, 1, 10));

	extractData( buttonPressed, userDate);
	Core.Header_Text = "Часовой отчёт c " .. Core.Date.Field_Text[0] .. " по " .. Core.Date.Field_Text[23];
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	- запись данных в табло при выборе даты "календаря"
	@param	- date	DateSelect_GUI			выбрана начальная дата архива
	@param	- bool	HourButtonPressed		нажата кнопка "Часовой архив"
	@param	- bool	DateButtonPressed		нажата кнопка "Суточный архив"
	@param	- bool	MonthButtonPressed		нажата кнопка "Месячный архив"
	@param	- bool	QuarterButtonPressed	нажата кнопка "Квартальный архив"
	@param	- bool	YearButtonPressed		нажата кнопка "Годовой архив"
--------------------------------------------------------------------------------------------------------------]]--

function cbDateSelector()

	if Core.DateSelect_GUI == nil then
		Core.addLogMsg( "Введите начальную дату!");
		return -1;
	end
	
	userDate = tostring( Core.DateSelect_GUI - 10800);
	userDate = tonumber( string.sub(userDate, 1, 10));
	--userDate = tostring( Core.DateSelect_GUI);
	--userDate = tonumber( string.sub(userDate, 1, 10));
	
	if 	Core.DateSelectorPressed == true then 
		if Core.HourButtonPressed == true then				-- изменена дата "календаря" и ранее нажата кнопка "Часовой архив"
			-- обработка часового архива --------------------------------------------------------------------------------------------------------
				buttonPressed = "h";           
			elseif Core.DateButtonPressed  == true then		-- изменена дата "календаря" и ранее нажата кнопка "Суточный архив"
			-- обработка суточного архива --------------------------------------------------------------------------------------------------------
				buttonPressed = "d";           
			elseif Core.MonthButtonPressed  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Месячный архив"
			-- обработка месячного архива --------------------------------------------------------------------------------------------------------
				buttonPressed = "m";           
			elseif Core.QuarterButtonPressed  == true then	-- изменена дата "календаря" и ранее нажата кнопка "Квартальный архив"
			-- обработка квартального архива --------------------------------------------------------------------------------------------------------
				buttonPressed = "q";           
			elseif Core.YearButtonPressed  == true then		-- изменена дата "календаря" и ранее нажата кнопка "Годовой архив"
			-- обработка квартального архива --------------------------------------------------------------------------------------------------------
				buttonPressed = "y";
		end
	end
	extractData( buttonPressed, userDate);	
end

function cbButton()

	if Core.DateSelect_GUI == nil then
		Core.addLogMsg( "Введите начальную дату!");
		return -1;
	end

	if Core.HourButtonPressed == true then
			Core.InputDateSelector = 1503090000; -- задать дату начала часового архива - Human time (your time zone): суббота, 19 августа 2017 г., 00:00:00 GMT+03:00
			--userDate = Core.DateSelect_GUI - 10800;
			--Core.InputDateSelector = 1502938800 - 10800;
			userDate = 1502938800;
			buttonPressed = "h";
			changeBehaviorTextFieldHA();
			Core.HourButtonFontBold = true;
			Core.DateButtonFontBold = false;
			Core.MonthButtonFontBold = false;
			Core.QuarterButtonFontBold = false;
			Core.YearButtonFontBold = false;
			extractData( buttonPressed, userDate);
		elseif 
			Core.DateButtonPressed == true then
			Core.InputDateSelector = 1475701200; -- задать дату начала суточного архива - Human time (your time zone): четверг, 6 октября 2016 г., 00:00:00 GMT+03:00
			--userDate = Core.DateSelect_GUI - 10800;
			--Core.InputDateSelector = 1475614800 - 10800;
			userDate = 1475614800;
			buttonPressed = "d";
			changeBehaviorTextFieldDA();
			Core.HourButtonFontBold = false;
			Core.DateButtonFontBold = true;
			Core.MonthButtonFontBold = false;
			Core.QuarterButtonFontBold = false;
			Core.YearButtonFontBold = false;			
			extractData( buttonPressed, userDate);
		elseif
			Core.MonthButtonPressed == true then
			Core.InputDateSelector = 1451595600; -- задать дату начала месячного архива - Your time zone: пятница, 1 января 2016 г., 00:00:00 GMT+03:00
			--userDate = Core.DateSelect_GUI - 10800;
			--Core.InputDateSelector = 1451509200 - 10800;
			userDate = 1451509200;
			buttonPressed = "m";
			changeBehaviorTextFieldMA();
			Core.HourButtonFontBold = false;
			Core.DateButtonFontBold = false;
			Core.MonthButtonFontBold = true;
			Core.QuarterButtonFontBold = false;
			Core.YearButtonFontBold = false;			
			extractData( buttonPressed, userDate);
		elseif
			Core.QuarterButtonPressed == true then
			buttonPressed = "q";
			changeBehaviorTextFieldQA();
			Core.HourButtonFontBold = false;
			Core.DateButtonFontBold = false;
			Core.MonthButtonFontBold = false;
			Core.QuarterButtonFontBold = true;
			Core.YearButtonFontBold = false;			
			extractData( buttonPressed, userDate);
			Core.Header_Text = "Квартальный отчёт c " .. Core.Date.Field_Text[0] .. " по " .. Core.Date.Field_Text[3];
		elseif
			Core.YearButtonPressed == true then
			buttonPressed = "y";
			--changeBehaviorTextFieldYA(); вызвать с аргументами 
			Core.HourButtonFontBold = false;
			Core.DateButtonFontBold = false;
			Core.MonthButtonFontBold = false;
			Core.QuarterButtonFontBold = false;
			Core.YearButtonFontBold = true;			
			extractData( buttonPressed, userDate);
			Core.Header_Text = "Годовой отчёт c " .. Core.Date.Field_Text[0] .. " по " .. Core.Date.Field_Text[2];
	end
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	- управление поведением текстовых ячеек (часовой архив)
--------------------------------------------------------------------------------------------------------------]]--  
function changeBehaviorTextFieldHA()
	for i = 0, 23 do
		Core.Date.Field_Visible[i] = true;
		Core.Heat[0].IO_Field_Visible[i] = true;
		Core.Heat[1].IO_Field_Visible[i] = true;
		Core.KPD.IO_Field_Visible[i] = true;
		Core.Gas.IO_Field_Visible[i] = true;
		Core.WaterA1.IO_Field_Visible[i] = true;
		Core.WaterA2.IO_Field_Visible[i] = true;
		Core.WaterA3.IO_Field_Visible[i] = true;
		Core.WaterA4.IO_Field_Visible[i] = true;
		Core.WaterObj1.IO_Field_Visible[i] = true;
		Core.WaterObj2.IO_Field_Visible[i] = true;
		Core.WaterObj3.IO_Field_Visible[i] = true;
		Core.WaterObj4.IO_Field_Visible[i] = true;
	end

	for i = 24, 30 do
		Core.Date.Field_Visible[i] = false;
		Core.Heat[0].IO_Field_Visible[i] = false;
		Core.Heat[1].IO_Field_Visible[i] = false;
		Core.KPD.IO_Field_Visible[i] = false;
		Core.Gas.IO_Field_Visible[i] = false;
		Core.WaterA1.IO_Field_Visible[i] = false;
		Core.WaterA2.IO_Field_Visible[i] = false;
		Core.WaterA3.IO_Field_Visible[i] = false;
		Core.WaterA4.IO_Field_Visible[i] = false;
		Core.WaterObj1.IO_Field_Visible[i] = false;
		Core.WaterObj2.IO_Field_Visible[i] = false;
		Core.WaterObj3.IO_Field_Visible[i] = false;
		Core.WaterObj4.IO_Field_Visible[i] = false;
	end

	local y = 437
	Core.Date.Total_Text_Pos[0] = y;
	Core.Heat[0].IO_Field_Button_Pos[0] = y;
	Core.Heat[1].IO_Field_Button_Pos[0] = y;
	Core.KPD.IO_Field_Button_Pos[0] = y; 
	Core.Gas.IO_Field_Button_Pos[0] = y;
	Core.WaterA1.IO_Field_Button_Pos[0] = y;
	Core.WaterA2.IO_Field_Button_Pos[0] = y;
	Core.WaterA3.IO_Field_Button_Pos[0] = y;
	Core.WaterA4.IO_Field_Button_Pos[0] = y;
	Core.WaterObj1.IO_Field_Button_Pos[0] = y;
	Core.WaterObj2.IO_Field_Button_Pos[0] = y;
	Core.WaterObj3.IO_Field_Button_Pos[0] = y;
	Core.WaterObj4.IO_Field_Button_Pos[0] = y;
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	- управление поведением текстовых ячеек (суточный архив)
--------------------------------------------------------------------------------------------------------------]]--  
function changeBehaviorTextFieldDA()
	for i = 0, 30 do
		Core.Date.Field_Visible[i] = true;
		Core.Heat[0].IO_Field_Visible[i] = true;
		Core.Heat[1].IO_Field_Visible[i] = true;
		Core.KPD.IO_Field_Visible[i] = true;
		Core.Gas.IO_Field_Visible[i] = true;
		Core.WaterA1.IO_Field_Visible[i] = true;
		Core.WaterA2.IO_Field_Visible[i] = true;
		Core.WaterA3.IO_Field_Visible[i] = true;
		Core.WaterA4.IO_Field_Visible[i] = true;
		Core.WaterObj1.IO_Field_Visible[i] = true;
		Core.WaterObj2.IO_Field_Visible[i] = true;
		Core.WaterObj3.IO_Field_Visible[i] = true;
		Core.WaterObj4.IO_Field_Visible[i] = true;
	end

	local y = 564
	Core.Date.Total_Text_Pos[0] = y;
	Core.Heat[0].IO_Field_Button_Pos[0] = y;
	Core.Heat[1].IO_Field_Button_Pos[0] = y;
	Core.KPD.IO_Field_Button_Pos[0] = y;
	Core.Gas.IO_Field_Button_Pos[0] = y;
	Core.WaterA1.IO_Field_Button_Pos[0] = y;
	Core.WaterA2.IO_Field_Button_Pos[0] = y;
	Core.WaterA3.IO_Field_Button_Pos[0] = y;
	Core.WaterA4.IO_Field_Button_Pos[0] = y;
	Core.WaterObj1.IO_Field_Button_Pos[0] = y;
	Core.WaterObj2.IO_Field_Button_Pos[0] = y;
	Core.WaterObj3.IO_Field_Button_Pos[0] = y;
	Core.WaterObj4.IO_Field_Button_Pos[0] = y;
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	- управление поведением текстовых ячеек (месячный архив)
--------------------------------------------------------------------------------------------------------------]]-- 
function changeBehaviorTextFieldMA()
	for i = 0, 11 do
		Core.Date.Field_Visible[i] = true;
		Core.Heat[0].IO_Field_Visible[i] = true;
		Core.Heat[1].IO_Field_Visible[i] = true;
		Core.KPD.IO_Field_Visible[i] = true;
		Core.Gas.IO_Field_Visible[i] = true;
		Core.WaterA1.IO_Field_Visible[i] = true;
		Core.WaterA2.IO_Field_Visible[i] = true;
		Core.WaterA3.IO_Field_Visible[i] = true;
		Core.WaterA4.IO_Field_Visible[i] = true;
		Core.WaterObj1.IO_Field_Visible[i] = true;
		Core.WaterObj2.IO_Field_Visible[i] = true;
		Core.WaterObj3.IO_Field_Visible[i] = true;
		Core.WaterObj4.IO_Field_Visible[i] = true;
	end
	for i = 12, 30 do
		Core.Date.Field_Visible[i] = false;
		Core.Heat[0].IO_Field_Visible[i] = false;
		Core.Heat[1].IO_Field_Visible[i] = false;
		Core.KPD.IO_Field_Visible[i] = false;
		Core.Gas.IO_Field_Visible[i] = false;
		Core.WaterA1.IO_Field_Visible[i] = false;
		Core.WaterA2.IO_Field_Visible[i] = false;
		Core.WaterA3.IO_Field_Visible[i] = false;
		Core.WaterA4.IO_Field_Visible[i] = false;
		Core.WaterObj1.IO_Field_Visible[i] = false;
		Core.WaterObj2.IO_Field_Visible[i] = false;
		Core.WaterObj3.IO_Field_Visible[i] = false;
		Core.WaterObj4.IO_Field_Visible[i] = false;
	end
	local y = 221
	Core.Date.Total_Text_Pos[0] = y;
	Core.Heat[0].IO_Field_Button_Pos[0] = y;
	Core.Heat[1].IO_Field_Button_Pos[0] = y;
	Core.KPD.IO_Field_Button_Pos[0] = y;
	Core.Gas.IO_Field_Button_Pos[0] = y;
	Core.WaterA1.IO_Field_Button_Pos[0] = y;
	Core.WaterA2.IO_Field_Button_Pos[0] = y;
	Core.WaterA3.IO_Field_Button_Pos[0] = y;
	Core.WaterA4.IO_Field_Button_Pos[0] = y;
	Core.WaterObj1.IO_Field_Button_Pos[0] = y;
	Core.WaterObj2.IO_Field_Button_Pos[0] = y;
	Core.WaterObj3.IO_Field_Button_Pos[0] = y;
	Core.WaterObj4.IO_Field_Button_Pos[0] = y;
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	- управление поведением текстовых ячеек (квартальный архив)
--------------------------------------------------------------------------------------------------------------]]-- 

	function changeBehaviorTextFieldQA()
		for i = 0, 3 do
			Core.Date.Field_Visible[i] = true;
			Core.Heat[0].IO_Field_Visible[i] = true;
			Core.Heat[1].IO_Field_Visible[i] = true;
			Core.KPD.IO_Field_Visible[i] = true;
			Core.Gas.IO_Field_Visible[i] = true;
			Core.WaterA1.IO_Field_Visible[i] = true;
			Core.WaterA2.IO_Field_Visible[i] = true;
			Core.WaterA3.IO_Field_Visible[i] = true;
			Core.WaterA4.IO_Field_Visible[i] = true;
			Core.WaterObj1.IO_Field_Visible[i] = true;
			Core.WaterObj2.IO_Field_Visible[i] = true;
			Core.WaterObj3.IO_Field_Visible[i] = true;
			Core.WaterObj4.IO_Field_Visible[i] = true;
		end
		for i = 4, 30 do
			Core.Date.Field_Visible[i] = false;
			Core.Heat[0].IO_Field_Visible[i] = false;
			Core.Heat[1].IO_Field_Visible[i] = false;
			Core.KPD.IO_Field_Visible[i] = false;
			Core.Gas.IO_Field_Visible[i] = false;
			Core.WaterA1.IO_Field_Visible[i] = false;
			Core.WaterA2.IO_Field_Visible[i] = false;
			Core.WaterA3.IO_Field_Visible[i] = false;
			Core.WaterA4.IO_Field_Visible[i] = false;
			Core.WaterObj1.IO_Field_Visible[i] = false;
			Core.WaterObj2.IO_Field_Visible[i] = false;
			Core.WaterObj3.IO_Field_Visible[i] = false;
			Core.WaterObj4.IO_Field_Visible[i] = false;
		end

		y = 76;
		Core.Date.Total_Text_Pos[0] = y;
		Core.Heat[0].IO_Field_Button_Pos[0] = y;
		Core.Heat[1].IO_Field_Button_Pos[0] = y;
		Core.KPD.IO_Field_Button_Pos[0] = y;
		Core.Gas.IO_Field_Button_Pos[0] = y;
		Core.WaterA1.IO_Field_Button_Pos[0] = y;
		Core.WaterA2.IO_Field_Button_Pos[0] = y;
		Core.WaterA3.IO_Field_Button_Pos[0] = y;
		Core.WaterA4.IO_Field_Button_Pos[0] = y;
		Core.WaterObj1.IO_Field_Button_Pos[0] = y;
		Core.WaterObj2.IO_Field_Button_Pos[0] = y;
		Core.WaterObj3.IO_Field_Button_Pos[0] = y;
		Core.WaterObj4.IO_Field_Button_Pos[0] = y;
	end

	--[[--------------------------------------------------------------------------------------------------------------
	@brief	- управление поведением текстовых ячеек (годовой архив)
--------------------------------------------------------------------------------------------------------------]]--

function changeBehaviorTextFieldYA( cond)
    for i = 0, cond - 1 do
        Core.Date.Field_Visible[i] = true;
        Core.Heat[0].IO_Field_Visible[i] = true;
        Core.Heat[1].IO_Field_Visible[i] = true;
		Core.KPD.IO_Field_Visible[i] = true;
        Core.Gas.IO_Field_Visible[i] = true;
        Core.WaterA1.IO_Field_Visible[i] = true;
        Core.WaterA2.IO_Field_Visible[i] = true;
        Core.WaterA3.IO_Field_Visible[i] = true;
        Core.WaterA4.IO_Field_Visible[i] = true;
        Core.WaterObj1.IO_Field_Visible[i] = true;
        Core.WaterObj2.IO_Field_Visible[i] = true;
        Core.WaterObj3.IO_Field_Visible[i] = true;
        Core.WaterObj4.IO_Field_Visible[i] = true;
    end
    for i = cond, 30 do
        Core.Date.Field_Visible[i] = false;
        Core.Heat[0].IO_Field_Visible[i] = false;
		Core.Heat[1].IO_Field_Visible[i] = false;
		Core.KPD.IO_Field_Visible[i] = false;
        Core.Gas.IO_Field_Visible[i] = false;
        Core.WaterA1.IO_Field_Visible[i] = false;
        Core.WaterA2.IO_Field_Visible[i] = false;
        Core.WaterA3.IO_Field_Visible[i] = false;
        Core.WaterA4.IO_Field_Visible[i] = false;
        Core.WaterObj1.IO_Field_Visible[i] = false;
        Core.WaterObj2.IO_Field_Visible[i] = false;
        Core.WaterObj3.IO_Field_Visible[i] = false;
        Core.WaterObj4.IO_Field_Visible[i] = false;
    end

	local y;
	--local t = {} в таблице прописать координаты - 30 шт.
	--y = t[cond];
	y = 63;
	Core.Date.Total_Text_Pos[0] = y;
    Core.Heat[0].IO_Field_Button_Pos[0] = y;
	Core.Heat[1].IO_Field_Button_Pos[0] = y;
	Core.KPD.IO_Field_Button_Pos[0] = y;
    Core.Gas.IO_Field_Button_Pos[0] = y;
    Core.WaterA1.IO_Field_Button_Pos[0] = y;
    Core.WaterA2.IO_Field_Button_Pos[0] = y;
    Core.WaterA3.IO_Field_Button_Pos[0] = y;
    Core.WaterA4.IO_Field_Button_Pos[0] = y;
    Core.WaterObj1.IO_Field_Button_Pos[0] = y;
    Core.WaterObj2.IO_Field_Button_Pos[0] = y;
    Core.WaterObj3.IO_Field_Button_Pos[0] = y;
    Core.WaterObj4.IO_Field_Button_Pos[0] = y;
end

--[[--------------------------------------------------------------------------------------------------------------
	@brief	- вычисление суммы значений массива
	@param	- t		table	массив
	@return	- summ	number	сумма значений массива
--------------------------------------------------------------------------------------------------------------]]--
function f1( fd, str)
			t = os.date( "*t", str);
			local tempYear = t.year;	-- запомнить дату
			local c = 1;
			local tHeat = {};
			while ( 1) do
				tHeat[c] = tonumber(fd:read( "*l"));	-- записать значение тепловой энергии
				str = fd:read( "*l");					-- прочесть дату
				t = os.date( "*t", str);
				year = t.year;
				if tempYear ~= year or tHeat[c] == nil then
					break;
				end
				c = c + 1;
			end
			-- вычисление суммы  
			local sum = mathsum( tHeat);
	return sum, str;
end			

--[[--------------------------------------------------------------------------------------------------------------
	@brief				- обработка и извлечение данных (дата и тепловая энергия) из архивных файлов и запись их в табло мнемосхемы,
							используется в функции extractData( buttonPressed, userDate)
	@param	- fd		- дескриптор файла часового архива теплового ввода 1(2)
	@param	- userDate	- начальная дата выборки данных, выбирается пользователем  
	@param	- par		- параметр цикла for
	@param	- cond		- условие прекращения цикла for
	@param	- but		- кнопка выбора типа архива (часовой, суточный, месячный...), выбирается пользователем
	@return - (-1)		- в архиве отсутствуют данные
	@return - (-2)		- выбранная пользователем дата отсутствует в архиве
--------------------------------------------------------------------------------------------------------------]]--

	function hnd( fd, userDate, par, cond, but)

		local tDate = {}; 	-- буфер для хранения времени (number)
		local tHeat = {}; 	-- буфер для хранения значений тепловой энергии (number)
		local ind;			-- индекс табло
		
		if fd == fdHour_1 or fd == fdDate_1 or fd == fdMonth_1 then
			ind = 0;
			elseif fd == fdHour_2 or fd == fdDate_2 or fd == fdMonth_2 then
			ind = 1;
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------
		-- ПРОВЕРКА НАЛИЧИЯ ДАННЫХ В АХИВЕ:
		local str = fd:read( "*l"); 
	--------------------------------------------------------------------------------------------------------------------------------------------------
			-- в архиве теплового ввода 1(2) ПРИСУТСТВУЮТ данные, поиск введённой пользователем даты:
			if str ~= nil then
			Core.addLogMsg("в архиве теплового ввода 1(2) ПРИСУТСТВУЮТ данные, поиск введённой пользователем даты")
				while ( 1) do 
					if userDate == str then
						Core.addLogMsg("введённая пользователем дата найдена ==>> к ОБРАБОТКЕ")
						goto hndlr;						-- введённая пользователем дата найдена ==>> к ОБРАБОТКЕ
					end

					str = fd:read( "*l");

					if str == nil then					-- достигли конца архива - введённая пользователем дата НЕ найдена ==>> ВЫХОД
						local t = {};
						t = os.date( "*t", userDate);
						local strH = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);	-- сформировать строку вида: 01.09.2017 00:00

						--Core.WarningMessageVisible = true;
						--Core.WarningMessage = "Выбранная дата " .. strH .. " отсутствует в архиве.";
						Core.addLogMsg( "hnd: выбранная дата " .. strH .. " отсутствует в архиве.");
						
						for i = par, cond do
							tDate[i] = "нет данных";	-- заполнить массив дат строкой "нет данных"
							Core.Date.Field_Text[i-1] = tDate[i];
						end

						for i = par, cond do					
							tHeat[i] = "нет данных";	-- заполнить массив данных строкой "нет данных"
							Core.Heat[ind].IO_Field_Text[i-1] = tHeat[i];
						end				

						Core.Heat[ind].IO_Field_Text[31] = "нет данных";
						Core.Heat[ind].IO_Field_Text[32] = "нет данных";
						Core.Heat[ind].IO_Field_Text[33] = "нет данных";
						Core.Heat[ind].IO_Field_Text[34] = "нет данных";

						return -2;
					end
				end
			end 
	--------------------------------------------------------------------------------------------------------------------------------------------------
		-- в архиве теплового ввода 1(2) ОТСУТСТВУЮТ данные
			if str == nil then
				for i = par, cond do
					tDate[i] = "нет данных";			-- заполнить массив дат строкой "нет данных"
					Core.Date.Field_Text[i-1] = tDate[i];
				end

				for i = par, cond do					
					tHeat[i] = "нет данных";			-- заполнить массив данных строкой "нет данных"
					Core.Heat[ind].IO_Field_Text[i-1] = tHeat[i];
				end

				Core.Heat[ind].IO_Field_Text[31] = "нет данных";
				Core.Heat[ind].IO_Field_Text[32] = "нет данных";
				Core.Heat[ind].IO_Field_Text[33] = "нет данных";
				Core.Heat[ind].IO_Field_Text[34] = "нет данных";

				return -1;
			end

	::hndlr::	
	--------------------------------------------------------------------------------------------------------------------------------------------------
		-- ЧТЕНИЕ ДАННЫХ ИЗ АРХИВНЫХ ФАЙЛОВ И ЗАПИСЬ ИХ В БУФЕРЫ:
		tDate[1] = userDate;			-- записать в буфер дату выбранную пользователем
		local e = fd:read( "*l");		-- прочесть вторую строку архива - с тепловой энергией
		tHeat[1] = tonumber( e);		-- записать в буфер вторую строку архива - с тепловой энергией

		for i = 2, cond do
			local d = fd:read( "*l");	-- прочесть третью строку архива - дату
			tDate[i] = tonumber( d);	-- записать в буфер третью строку архива
			e = fd:read( "*l");			-- прочесть четвёртую строку архива - с тепловой энергией
			tHeat[i] = tonumber( e);	-- записать в буфер четвёртую строку архива
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------
		-- ЗАПИСЬ ЗНАЧЕНИЙ ТЕПЛОВОЙ ЭНЕРГИИИ ИЗ БУФЕРА tHeat[i] В ТАБЛО:

		for i = par, cond do
			if tHeat[i] == nil then	
				Core.Heat[ind].IO_Field_Text[i-1] = "нет данных";
			end
		end	
		
		for i = par, cond do
			if tHeat[i] ~= nil then
				Core.Heat[ind].IO_Field_Text[i-1] = tHeat[i];														-- значения тепловой энергии (number) ==>> ЗАПИСАТЬ В ТАБЛО
			end
		end
		Core.Heat[ind].IO_Field_Text[31] = mathsum( tHeat);															-- вычисление средних значений
		Core.Heat[ind].IO_Field_Text[32] = (math.max(table.unpack( tHeat)) + math.min(table.unpack( tHeat))) / 2;	-- вычисление средних значений
		Core.Heat[ind].IO_Field_Text[33] = math.min(table.unpack( tHeat));											-- вычисление минимальных значений
		Core.Heat[ind].IO_Field_Text[34] = math.max(table.unpack( tHeat));											-- вычисление максимальных значений
		
	----------------------------------------------------------------------------------------------------------	
		-- ЗАПИСЬ ДАТ(ВРЕМЕНИ) ИЗ БУФЕРА tDate[i] В ТАБЛО:

		local tStr = {};				-- буфер для хранения времени (string)

		for i = par, cond do
			if tDate[i] == nil then
				tStr[i] = "нет данных";
			else
				local t = os.date( "*t", tDate[i]);
				if but == "h" then
						str = string.format( "%02d.%02d.", t.day, t.month) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);	 -- формирование строки вида: 01.09.2017 00:00
						tStr[i] = str;
					elseif but == "d" then
						str = string.format("%02d.%02d.", t.day, t.month) .. t.year;	-- формирование строки вида: 01.09.2017
						tStr[i] = str;	
					elseif but == "m" then
						str = string.format("%02d.", t.month) .. t.year;				-- формирование строки вида: 09.2017
						tStr[i] = str;
				end
			end
		end
	----------------------------------------------------------------------------------------------------------
		for i = par, cond do			
			Core.Date.Field_Text[i-1] = tStr[i];	-- время (string) ==>> ЗАПИСАТЬ В ТАБЛО
		end
		str = "";
		return 0;
	end

--[[--------------------------------------------------------------------------------------------------------------
	@brief					- извлекает данные (дата и тепловая энергия) из архивных файлов для отображения на мнемосхеме
	@param	- buttonPressed - кнопка выбора типа архива (часовой, суточный, месячный...), выбирается пользователем
	@param	- userDate		- начальная дата выборки данных, выбирается пользователем  
--------------------------------------------------------------------------------------------------------------]]--	
	function extractData( buttonPressed, userDate)

		userDate = tostring( userDate);		-- время в строку
		local par;
		local cond;
		local but;
		local err;
		local ret;
	-------------------------------------------------------------------------------------------------------------
		if buttonPressed == "h" then		-- выбран часовой архив

			par = 1;
			cond = 24;
			but = "h";

			fdHour_1, err = io.open( pathHour_1, "r");					-- открыть файл часового архива ТВ1 в режиме чтения
			if fdHour_1 then
					ret = hnd( fdHour_1, userDate, par, cond, but);		-- записать время и значения тепловой энергии в ТАБЛО
					Core.Header_Text = "Часовой отчёт c " .. Core.Date.Field_Text[0] .. " по " .. Core.Date.Field_Text[23];
					if	ret == -2 then									-- достигли конца архива ТВ1 - введённая пользователем дата НЕ найдена ==>>
						goto next1;										-->> переход к обработке архива ТВ2
					end 
				else 
					Core.WarningMessageVisible = true;
					Core.WarningMessage = "Ошибка открытия файла часового архива ТВ1!";
					Core.addLogMsg( "extractData: ошибка открытия файла часового архива ТВ1!");
					--io.write( err);
			end
	::next1::
			fdHour_2, err = io.open( pathHour_2, "r");					-- открыть файл часового архива ТВ2 в режиме чтения
			if fdHour_2 then
					ret = hnd( fdHour_2, userDate, par, cond, but);		-- записать время и значения тепловой энергии в ТАБЛО
					if ret == -2 then								
						return;											-- достигли конца архива ТВ2 - введённая пользователем дата НЕ найдена ==>> ВЫХОД
					end
				else 
					Core.WarningMessageVisible = true;
					Core.WarningMessage = "Ошибка открытия файла часового архива ТВ1!";				
					Core.addLogMsg( "extractData: ошибка открытия файла часового архива ТВ2!");
					--io.write( err);
			end
		end
	-------------------------------------------------------------------------------------------------------------
		if buttonPressed == "d" then	-- выбран суточный архив

			par = 1;
			cond = 31;
			but = "d";

			fdDate_1, err = io.open( pathDate_1, "r");					-- открыть файл суточного архива ТВ1 в режиме чтения
			if fdDate_1 then
					ret = hnd( fdDate_1, userDate, par, cond, but);		-- записать время и значения тепловой энергии в ТАБЛО
					Core.Header_Text = "Суточный отчёт c " .. Core.Date.Field_Text[0] .. " по " .. Core.Date.Field_Text[30];
					if ret == -2 then									-- достигли конца архива ТВ1 - введённая пользователем дата НЕ найдена ==>>
						goto next2;										-->> переход к обработке архива ТВ2
					end
				else 
					Core.WarningMessageVisible = true;
					Core.WarningMessage = "Ошибка открытия файла суточного архива ТВ1!";
					Core.addLogMsg( "extractData: ошибка открытия файла суточного архива ТВ1!");
					--io.write( err);
			end
	::next2::
			fdDate_2, err = io.open( pathDate_2, "r");					-- открыть файл суточного архива ТВ2 в режиме чтения
			if fdDate_2 then
					ret = hnd( fdDate_2, userDate, par, cond, but);		-- записать время и значения тепловой энергии в ТАБЛО
					if ret == -2 then
						return;											-- достигли конца архива ТВ2 - введённая пользователем дата НЕ найдена ==>> ВЫХОД
					end
				else 
					Core.WarningMessageVisible = true;
					Core.WarningMessage = "Ошибка открытия файла суточного архива ТВ2!";
					Core.addLogMsg( "extractData: ошибка открытия файла суточного архива ТВ2!");
					--io.write( err);
			end
		end
	-------------------------------------------------------------------------------------------------------------
		if buttonPressed == "m" then	-- выбран месячный архив

			par = 1;
			cond = 12;
			but = "m";

			fdMonth_1, err = io.open( pathMonth_1, "r");				-- открыть файл месячного архива ТВ1 в режиме чтения
			if fdMonth_1 then
					ret = hnd( fdMonth_1, userDate, par, cond, but);	-- записать время и значения тепловой энергии в ТАБЛО
					Core.Header_Text = "Месячный отчёт c " .. Core.Date.Field_Text[0] .. " по " .. Core.Date.Field_Text[11];
					if ret == -2 then									-- достигли конца архива ТВ1 - введённая пользователем дата НЕ найдена ==>>
						goto next3;										-->> переход к обработке архива ТВ2
					end
				else 
					Core.WarningMessageVisible = true;
					Core.WarningMessage = "Ошибка открытия файла месячного архива ТВ1!";
					Core.addLogMsg( "extractData: ошибка открытия файла месячного архива ТВ1!");
					--io.write( err);
			end
	::next3::
			fdMonth_2, err = io.open( pathMonth_2, "r");				-- открыть файл месячного архива ТВ2 в режиме чтения
			if fdMonth_2 then
					ret = hnd( fdMonth_2, userDate, par, cond, but);	-- записать время и значения тепловой энергии в ТАБЛО
					if ret == -2 then									
						return;											-- достигли конца архива ТВ2 - введённая пользователем дата НЕ найдена ==>> ВЫХОД
					end
				else 
					Core.WarningMessageVisible = true;
					Core.WarningMessage = "Ошибка открытия файла месячного архива ТВ2!";
					Core.addLogMsg( "extractData: ошибка открытия файла месячного архива ТВ2!");
					--io.write( err);
			end
		end
	-------------------------------------------------------------------------------------------------------------
		if buttonPressed == "q" then	-- выбран квартальный архив

			--local years = { 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030};
			local tHeat = {}; 		-- таблица для хранения данных тепловой энергии
			local tQuarter = {};	-- таблица с суммарными значениями данных тепловой энергии (4 квартала)
			local year;
			local DT;
			local str;
			local quarterDateStart;
			local delta;
			local amountDays;
			local pos;
			local fd;
			local t;
			local yearStart;
			local yearEnd;
			local strYearStart;
			local strYearEnd;
			local dateStart;
			local ret;
			local strEndDeteArch;
			
-- извлечь год из даты выбранной пользователем
			DT = os.date( "*t", userDate);
			year = DT.year;						

			Core.Date.Field_Text[0] = "I квартал " .. year .. " г.";
			Core.Date.Field_Text[1] = "II квартал " .. year .. " г.";
			Core.Date.Field_Text[2] = "III квартал " .. year .. " г.";
			Core.Date.Field_Text[3] = "IV квартал " .. year .. " г.";
			
			local firstQuarterDateStart = ( os.time{ year = year, month = 1, day = 1, hour = 0}) - 10800; -- задать дату 01.01.2017 (начало 1 квартала)
			local secondQuarterDateStart = ( os.time{ year = year, month = 4, day = 1, hour = 0}) - 10800; -- задать дату 01.04.2017 (начало 2 квартала)
			local firthQuarterDateStart = ( os.time{ year = year, month = 7, day = 1, hour = 0}) - 10800; -- задать дату 01.07.2017 (начало 3 квартала)
			local fourQuarterDateStart = ( os.time{ year = year, month = 10, day = 1, hour = 0}) - 10800; -- задать дату 01.10.2017 (начало 4 квартала)
			local fourQuarterDateEnd = ( os.time{ year = year, month = 12, day = 31, hour = 0}) - 10800; -- задать дату 31.12.2017 (конец 4 квартала)

			fd = io.open( pathDate_1, "r");					-- открыть файл суточного архива ТВ1 на чтение
			if fd == nil then								-- проверка открытия файла часового архива ТВ1
				Core.WarningMessageVisible = true;
				Core.WarningMessage = "Ошибка открытия файла суточного архива ТВ1!";
				Core.addLogMsg( "extractData: ошибка открытия файла суточного архива ТВ1!");
				goto TV2;
			end
-- проверка наличия данных в суточном архиве ТВ1			
			str = fd:read( "*l");
			if str == nil then
				Core.WarningMessageVisible = true;
				Core.WarningMessage = "В суточном архиве ТВ1 нет данных!";
				Core.addLogMsg( "extractData: в суточном архиве ТВ1 нет данных!");
				for i = 0, 3 do
					Core.Heat[0].IO_Field_Text[i] = "нет данных";
				end
				fd:close();
				goto TV2;
			end
-- проверка года, введённого пользователем на вхождение в архив
			ret = checkInYear( fd, t, year);
			if ret == 1 then
				return;
			end

			fd:seek( "set");
			str = tonumber( fd:read( "*l"));
			fd:seek( "set");
-- 1кв ----- ТВ1 -- первая дата суточного архива лежит выше даты начала 1 квартала -----------------------------------------------------------------			
			if str < firstQuarterDateStart then			
					-- поиск заданной даты -- 
					while ( 1) do 
						if firstQuarterDateStart == str then
							break;									-- дата найдена ==>> к ОБРАБОТКЕ
						end
						str = tonumber(fd:read( "*l"));
					end
					-- вычислить количество дней от даты начала 1-го квартала до даты начала 2-го квартала
					amountDays = (secondQuarterDateStart - firstQuarterDateStart) / 86400;
					-- заполнение таблицы данными тепловой энергии
					for i = 1, amountDays do
						tHeat[i] = tonumber(fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 1 квартал
						fd:read( "*l");                       -- "пустое" чтение времени
					end
					-- вычисление суммы  
					table.insert( tQuarter, mathsum( tHeat));
					-- вычисление текущей позиции в файле
					pos = fd:seek();
-- 2кв --------
					dateStart = secondQuarterDateStart;
					pos = hndQuarter2( fd, pos, dateStart, str, tQuarter);
-- 3кв --------	
					dateStart = firthQuarterDateStart;
					pos = hndQuarter3( fd, pos, dateStart, str, tQuarter);
-- 4кв --------					
					dateStart = fourQuarterDateStart;
					hndQuarter4( fd, pos, dateStart, str, tQuarter);				

					Core.Heat[0].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[0].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[0].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[0].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove (tQuarter, i);
						end
					end
					Core.Heat[0].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[0].IO_Field_Text[32] = ( math.max( table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[0].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[0].IO_Field_Text[34] = math.max( table.unpack( tQuarter));											-- вычисление максимальных значений	
			
-- 1кв ----- ТВ1 -- первая дата суточного архива лежит в пределах 1 квартала -----------------------------------------------------------------
				elseif str >= firstQuarterDateStart and str < secondQuarterDateStart then
					fd:seek("set")       						-- перемеcтить указатель текущей позиции в начало файла
					-- вычислить количество дней от первой даты суточного архива до даты начала 2-го квартала
					amountDays = ( secondQuarterDateStart - str) / 86400;
					-- заполнение таблицы данными тепловой энергии
					for i = 1, amountDays do
						local s = fd:read( "*l");                       -- "пустое" чтение времени
						tHeat[i] = tonumber(fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 1 квартал
					end
					-- вычисление суммы  
					table.insert( tQuarter, mathsum( tHeat));
					-- вычисление текущей позиции в файле
					pos = fd:seek();
-- 2кв --------
					dateStart = secondQuarterDateStart;
					pos = hndQuarter2( fd, pos, dateStart, str, tQuarter);
-- 3кв --------	
					dateStart = firthQuarterDateStart;
					pos = hndQuarter3( fd, pos, dateStart, str, tQuarter);
-- 4кв --------					
					dateStart = fourQuarterDateStart;
					hndQuarter4( fd, pos, dateStart, str, tQuarter);				
					
					Core.Heat[0].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[0].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[0].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[0].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove (tQuarter, i);
						end
					end
					Core.Heat[0].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[0].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[0].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[0].IO_Field_Text[34] = math.max( table.unpack( tQuarter));											-- вычисление максимальных значений	
					
-- 2кв ----- ТВ1 -- первая дата суточного архива лежит в пределах 2 квартала -----------------------------------------------------------------
				elseif str >= secondQuarterDateStart and str < firthQuarterDateStart then
					fd:seek("set")       						-- перемеcтить указатель текущей позиции в начало файла
					table.insert(tQuarter, "нет данных");
					-- вычислить количество дней от первой даты суточного архива до даты начала 3-го квартала
					amountDays = ( firthQuarterDateStart - str) / 86400;
					-- заполнение таблицы данными тепловой энергии
					tHeat = {};										-- очистить массив
					for i = 1, amountDays do
						fd:read( "*l");                       -- "пустое" чтение времени
						tHeat[i] = tonumber( fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 2 квартал
					end
					-- вычисление суммы  
					table.insert( tQuarter, mathsum( tHeat));
					-- вычисление текущей позиции в файле
					pos = fd:seek();
-- 3кв --------	
					dateStart = firthQuarterDateStart;
					pos = hndQuarter3( fd, pos, dateStart, str, tQuarter);
-- 4кв --------					
					dateStart = fourQuarterDateStart;
					hndQuarter4( fd, pos, dateStart, str, tQuarter);				
					
					Core.Heat[0].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[0].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[0].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[0].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove (tQuarter, i);
						end
					end
					Core.Heat[0].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[0].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[0].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[0].IO_Field_Text[34] = math.max( table.unpack( tQuarter));												-- вычисление максимальных значений	
					
-- 3кв ----- ТВ1 -- первая дата суточного архива лежит в пределах 3 квартала -----------------------------------------------------------------
				elseif str >= firthQuarterDateStart and str < fourQuarterDateStart then
					fd:seek("set")       						-- перемеcтить указатель текущей позиции в начало файла
					table.insert( tQuarter, "нет данных");
					table.insert( tQuarter, "нет данных");
					-- вычислить количество дней от первой даты суточного архива до даты начала 4-го квартала
					amountDays = ( fourQuarterDateStart - str) / 86400;
					-- заполнение таблицы данными тепловой энергии			
					tHeat = {};										-- очистить массив
					for i = 1, amountDays do
						fd:read( "*l");                       -- "пустое" чтение времени
						tHeat[i] = tonumber(fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 3 квартал
					end
					-- вычисление суммы
					table.insert(tQuarter, mathsum( tHeat));
					-- вычисление текущей позиции в файле
					pos = fd:seek();
-- 4кв --------					
					dateStart = fourQuarterDateStart;
					hndQuarter4( fd, pos, dateStart, str, tQuarter);				
					
					Core.Heat[0].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[0].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[0].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[0].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove (tQuarter, i);
						end
					end
					Core.Heat[0].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[0].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[0].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[0].IO_Field_Text[34] = math.max( table.unpack( tQuarter));	
				
-- 4кв ----- ТВ1 -- первая дата суточного архива лежит в пределах 4 квартала -----------------------------------------------------------------				
				elseif str >= fourQuarterDateStart and str < fourQuarterDateEnd then
					fd:seek( "set")       					-- перемеcтить указатель текущей позиции в начало файла
					table.insert( tQuarter, "нет данных");
					table.insert( tQuarter, "нет данных");
					table.insert( tQuarter, "нет данных");
					-- вычислить количество дней от первой даты суточного архива до даты конца 4-го квартала
					amountDays = ((fourQuarterDateEnd + 86400) - str) / 86400;
					-- заполнение таблицы данными тепловой энергии
					tHeat = {};										-- очистить массив	
					for i = 1, amountDays do
						fd:read( "*l");                       -- "пустое" чтение времени
						tHeat[i] = tonumber( fd:read( "*l"));	-- заполняем таблицу данными тепловой энергии за 4 квартал
					end
					-- вычисление суммы
					table.insert( tQuarter, mathsum( tHeat));
					
					Core.Heat[0].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[0].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[0].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[0].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove (tQuarter, i);
						end
					end
					Core.Heat[0].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[0].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[0].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[0].IO_Field_Text[34] = math.max( table.unpack( tQuarter));											-- вычисление максимальных значений
			end
fd:close();
::TV2::      
			fd = io.open( pathDate_2, "r");					-- открыть файл суточного архива ТВ2 на чтение
			if fd == nil then												-- проверка открытия файла часового архива ТВ2
				Core.WarningMessageVisible = true;
				Core.WarningMessage = "Ошибка открытия файла суточного архива ТВ2!";
				Core.addLogMsg( "extractData: ошибка открытия файла суточного архива ТВ2!");
				return -1;
			end
-- проверка наличия данных в суточном архиве ТВ2			
			str = fd:read( "*l");
			if str == nil then
				Core.WarningMessageVisible = true;
				Core.WarningMessage = "В суточном архиве ТВ2 нет данных!";
				Core.addLogMsg( "extractData: в суточном архиве ТВ2 нет данных!");
				for i = 0, 3 do
					Core.Heat[1].IO_Field_Text[i] = "нет данных";
				end
				fd:close();				
				return;
			end
-- проверка года, введённого пользователем на вхождение в архив
			ret = checkInYear( fd, t, year);
			if ret == 1 then
				return;
			end

			fd:seek( "set");
			str = tonumber(	fd:read( "*l"));
			fd:seek( "set");
			tQuarter ={};	-- очистить корзину
-- 1кв ----- ТВ1 -- первая дата суточного архива лежит выше даты начала 1 квартала -----------------------------------------------------------------			
			if str < firstQuarterDateStart then			
					-- поиск заданной даты -- 
					while ( 1) do 
						if firstQuarterDateStart == str then
							break;									-- дата найдена ==>> к ОБРАБОТКЕ
						end
						str = tonumber(fd:read( "*l"));
					end
					-- вычислить количество дней от даты начала 1-го квартала до даты начала 2-го квартала
					amountDays = (secondQuarterDateStart - firstQuarterDateStart) / 86400;
					-- заполнение таблицы данными тепловой энергии
					for i = 1, amountDays do
						tHeat[i] = tonumber(fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 1 квартал
						fd:read( "*l");                       -- "пустое" чтение времени
					end
					-- вычисление суммы  
					table.insert(tQuarter, mathsum( tHeat));
					-- вычисление текущей позиции в файле
					pos = fd:seek();
-- 2кв --------
					dateStart = secondQuarterDateStart;
					pos = hndQuarter2( fd, pos, dateStart, str, tQuarter);
-- 3кв --------	
					dateStart = firthQuarterDateStart;
					pos = hndQuarter3( fd, pos, dateStart, str, tQuarter);
-- 4кв --------					
					dateStart = fourQuarterDateStart;
					hndQuarter4( fd, pos, dateStart, str, tQuarter);				
					
					Core.Heat[1].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[1].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[1].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[1].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove ( tQuarter, i);
						end
					end
					Core.Heat[1].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[1].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[1].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[1].IO_Field_Text[34] = math.max( table.unpack( tQuarter));											-- вычисление максимальных значений	
			
-- 1кв ----- ТВ1 -- первая дата суточного архива лежит в пределах 1 квартала -----------------------------------------------------------------
				elseif str >= firstQuarterDateStart and str < secondQuarterDateStart then
					fd:seek("set")       						-- перемеcтить указатель текущей позиции в начало файла
					-- вычислить количество дней от первой даты суточного архива до даты начала 2-го квартала
					amountDays = (secondQuarterDateStart - str) / 86400;
					-- заполнение таблицы данными тепловой энергии
					for i = 1, amountDays do
						fd:read( "*l");                       -- "пустое" чтение времени
						tHeat[i] = tonumber(fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 1 квартал
					end
					-- вычисление суммы  
					table.insert(tQuarter, mathsum( tHeat));
					-- вычисление текущей позиции в файле
					pos = fd:seek();
-- 2кв --------
					dateStart = secondQuarterDateStart;
					pos = hndQuarter2( fd, pos, dateStart, str, tQuarter);
-- 3кв --------	
					dateStart = firthQuarterDateStart;
					pos = hndQuarter3( fd, pos, dateStart, str, tQuarter);
-- 4кв --------					
					dateStart = fourQuarterDateStart;
					hndQuarter4( fd, pos, dateStart, str, tQuarter);				
					
					Core.Heat[1].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[1].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[1].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[1].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove (tQuarter, i);
						end
					end
					Core.Heat[1].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[1].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[1].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[1].IO_Field_Text[34] = math.max( table.unpack( tQuarter));											-- вычисление максимальных значений	
					
-- 2кв ----- ТВ1 -- первая дата суточного архива лежит в пределах 2 квартала -----------------------------------------------------------------
				elseif str >= secondQuarterDateStart and str < firthQuarterDateStart then
					fd:seek("set")       						-- перемеcтить указатель текущей позиции в начало файла
					table.insert( tQuarter, "нет данных");
					-- вычислить количество дней от первой даты суточного архива до даты начала 3-го квартала
					amountDays = ( firthQuarterDateStart - str) / 86400;
					-- заполнение таблицы данными тепловой энергии
					tHeat = {};										-- очистить массив
					for i = 1, amountDays do
						fd:read( "*l");                       -- "пустое" чтение времени
						tHeat[i] = tonumber( fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 2 квартал
					end
					-- вычисление суммы  
					table.insert( tQuarter, mathsum( tHeat));
					-- вычисление текущей позиции в файле
					pos = fd:seek();					
-- 3кв --------	
					dateStart = firthQuarterDateStart;
					pos = hndQuarter3( fd, pos, dateStart, str, tQuarter);
-- 4кв --------					
					dateStart = fourQuarterDateStart;
					hndQuarter4( fd, pos, dateStart, str, tQuarter);				
					
					Core.Heat[1].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[1].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[1].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[1].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove (tQuarter, i);
						end
					end
					Core.Heat[1].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[1].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[1].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[1].IO_Field_Text[34] = math.max( table.unpack( tQuarter));											-- вычисление максимальных значений	
					
-- 3кв ----- ТВ1 -- первая дата суточного архива лежит в пределах 3 квартала -----------------------------------------------------------------
				elseif str >= firthQuarterDateStart and str < fourQuarterDateStart then
					fd:seek("set")       						-- перемеcтить указатель текущей позиции в начало файла
					table.insert( tQuarter, "нет данных");
					table.insert( tQuarter, "нет данных");
					-- вычислить количество дней от первой даты суточного архива до даты начала 4-го квартала
					amountDays = ( fourQuarterDateStart - str) / 86400;
					-- заполнение таблицы данными тепловой энергии			
					tHeat = {};										-- очистить массив
					for i = 1, amountDays do
						fd:read( "*l");                       -- "пустое" чтение времени
						tHeat[i] = tonumber( fd:read( "*l"));  -- заполняем таблицу данными тепловой энергии за 3 квартал
					end
					-- вычисление суммы
					table.insert( tQuarter, mathsum( tHeat));
					-- вычисление текущей позиции в файле
					pos = fd:seek();
-- 4кв --------					
					dateStart = fourQuarterDateStart;
					hndQuarter4( fd, pos, dateStart, str, tQuarter);				
					
					Core.Heat[1].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[1].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[1].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[1].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove ( tQuarter, i);
						end
					end
					Core.Heat[1].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[1].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[1].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[1].IO_Field_Text[34] = math.max( table.unpack( tQuarter));	
				
-- 4кв ----- ТВ1 -- первая дата суточного архива лежит в пределах 4 квартала -----------------------------------------------------------------				
				elseif str >= fourQuarterDateStart and str < fourQuarterDateEnd then
					fd:seek( "set")       					-- перемеcтить указатель текущей позиции в начало файла
					table.insert( tQuarter, "нет данных");
					table.insert( tQuarter, "нет данных");
					table.insert( tQuarter, "нет данных");
					-- вычислить количество дней от первой даты суточного архива до даты конца 4-го квартала
					amountDays = ( (fourQuarterDateEnd + 86400) - str) / 86400;
					-- заполнение таблицы данными тепловой энергии
					tHeat = {};										-- очистить массив	
					for i = 1, amountDays do
						fd:read( "*l");                       -- "пустое" чтение времени
						tHeat[i] = tonumber( fd:read( "*l"));	-- заполняем таблицу данными тепловой энергии за 4 квартал
					end
					-- вычисление суммы
					table.insert( tQuarter, mathsum( tHeat));
					
					Core.Heat[1].IO_Field_Text[0] = tQuarter[1];
					Core.Heat[1].IO_Field_Text[1] = tQuarter[2];
					Core.Heat[1].IO_Field_Text[2] = tQuarter[3];
					Core.Heat[1].IO_Field_Text[3] = tQuarter[4];
					for i = 4, 1, -1 do
						if tQuarter[i] == "нет данных" then
							table.remove (tQuarter, i);
						end
					end
					Core.Heat[1].IO_Field_Text[31] = mathsum( tQuarter);															-- вычисление суммы значений
					Core.Heat[1].IO_Field_Text[32] = ( math.max(table.unpack( tQuarter)) + math.min( table.unpack( tQuarter))) / 2;	-- вычисление средних значений
					Core.Heat[1].IO_Field_Text[33] = math.min( table.unpack( tQuarter));											-- вычисление минимальных значений
					Core.Heat[1].IO_Field_Text[34] = math.max( table.unpack( tQuarter));											-- вычисление максимальных значений
			end			
fd:close();				-- закрыть дескриптор файла
end
		
	-------------------------------------------------------------------------------------------------------------
		if buttonPressed == "y" then	-- выбран годовой архив

					local tHeat = {}; 	-- таблица для хранения данных тепловой энергии
					local tYear = {};	-- таблица с суммарными значениями данных тепловой энергии
					local year;
					local str;
					local pos;
					local fd;
					local t;
					local yearStart;
					local yearEnd;
					local strYearStart;
					local strYearEnd;
					local nYears;
					local sum;
					
		-- проверка открытия файла месячного архива ТВ1
					fd = io.open( pathMonth_1, "r");
					if fd == nil then									
						Core.WarningMessageVisible = true;
						Core.WarningMessage = "Ошибка открытия файла месячного архива ТВ1!";
						Core.addLogMsg( "extractData: ошибка открытия файла месячного архива ТВ1!");
						goto TV2;
					end
		-- проверка наличия данных в месячном архиве ТВ1			
					str = fd:read( "*l");
					if str == nil then
						Core.WarningMessageVisible = true;
						Core.WarningMessage = "В месячном архиве ТВ1 нет данных!";
						Core.addLogMsg( "extractData: в месячном архиве ТВ1 нет данных!");
						for i = 0, 30 do
							Core.Heat[0].IO_Field_Text[i] = "нет данных";
						end
						fd:close();				
						goto TV2;
					end

					fd:seek( "set");			-- перейти в начало файла
					str = fd:read( "*l");		-- прочесть дату
					t = os.date( "*t", str);
					yearStart = t.year;			-- извлечь год из даты первой строки архива
					strYearStart = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);
		-- определение даты последней строки архива      		
					pos = fd:seek( "end");
					pos = fd:seek( "set", pos - 3);
					for i = 1, 50 do
						pos = fd:seek( "set", pos - 1);
						str = fd:read( "*L");
						if str == "\n" then 
							  pos = fd:seek( "set", pos - 11);
							  str = fd:read( "*l");
							  break;
						end
					end
					t = os.date( "*t", str);
					yearEnd = t.year;			-- извлечь год из даты предпоследней строки архива
					strYearEnd = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);			
		-- вычислить количество лет представленных в архиве
					nYears = ( yearEnd - yearStart) + 1;
		-- изменить видимость строк табло			
					changeBehaviorTextFieldYA( nYears);
		-- печать годов в табло
					year = yearStart;
					for i = 0, nYears - 1 do
						Core.Date.Field_Text[i] = year .. " г.";
						year = year + 1;
					end
			
					fd:seek( "set");			-- перейти в начало файла
					str = fd:read( "*l");		-- прочесть дату
					for i = 1, nYears do
						sum, str = f1( fd, str);
						table.insert( tYear, sum);
						Core.Heat[0].IO_Field_Text[i-1] = tYear[i];
					end
					Core.Heat[0].IO_Field_Text[31] = mathsum( tYear);															-- вычисление суммы значений
					Core.Heat[0].IO_Field_Text[32] = ( math.max(table.unpack( tYear)) + math.min( table.unpack( tYear))) / 2;	-- вычисление средних значений
					Core.Heat[0].IO_Field_Text[33] = math.min( table.unpack( tYear));											-- вычисление минимальных значений
					Core.Heat[0].IO_Field_Text[34] = math.max( table.unpack( tYear));											-- вычисление максимальных значений	
			
		fd:close();
		::TV2::
		-- проверка открытия файла месячного архива ТВ2
					fd = io.open( pathMonth_2, "r");
					if fd == nil then									
						Core.WarningMessageVisible = true;
						Core.WarningMessage = "Ошибка открытия файла месячного архива ТВ2!";
						Core.addLogMsg( "extractData: ошибка открытия файла месячного архива ТВ2!");
						return;
					end
		-- проверка наличия данных в месячном архиве ТВ2			
					str = fd:read( "*l");
					if str == nil then
						Core.WarningMessageVisible = true;
						Core.WarningMessage = "В месячном архиве ТВ2 нет данных!";
						Core.addLogMsg( "extractData: в месячном архиве ТВ2 нет данных!");
						for i = 0, 30 do
							Core.Heat[1].IO_Field_Text[i] = "нет данных";
						end
						fd:close();				
						return;
					end

					fd:seek( "set");			-- перейти в начало файла
					str = fd:read( "*l");		-- прочесть дату
					t = os.date( "*t", str);
					yearStart = t.year;			-- извлечь год из даты первой строки архива
					strYearStart = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);
		-- определение даты последней строки архива      		
					pos = fd:seek( "end");
					pos = fd:seek( "set", pos - 3);
					for i = 1, 50 do
						pos = fd:seek( "set", pos - 1);
						str = fd:read( "*L");
						if str == "\n" then 
							  pos = fd:seek( "set", pos - 11);
							  str = fd:read( "*l");
							  break;
						end
					end
					t = os.date( "*t", str);
					yearEnd = t.year;			-- извлечь год из даты предпоследней строки архива
					strYearEnd = string.format( "%02d.%02d.", t.day, t.month ) .. t.year .. " " .. string.format( "%02d:%02d", t.hour, t.min);			
		-- вычислить количество лет представленных в архиве
					nYears = ( yearEnd - yearStart) + 1;
		-- изменить видимость строк табло			
					changeBehaviorTextFieldYA( nYears);
		-- печать годов в табло
					year = yearStart;
					for i = 0, nYears - 1 do
						Core.Date.Field_Text[i] = year .. " г.";
						year = year + 1;
					end
					tYear = {};
					fd:seek( "set");			-- перейти в начало файла
					str = fd:read( "*l");		-- прочесть дату
					for i = 1, nYears do
						sum, str = f1( fd, str);
						table.insert( tYear, sum);
						Core.Heat[1].IO_Field_Text[i-1] = tYear[i];
					end
					Core.Heat[1].IO_Field_Text[31] = mathsum( tYear);															-- вычисление суммы значений
					Core.Heat[1].IO_Field_Text[32] = ( math.max(table.unpack( tYear)) + math.min( table.unpack( tYear))) / 2;	-- вычисление средних значений
					Core.Heat[1].IO_Field_Text[33] = math.min( table.unpack( tYear));											-- вычисление минимальных значений
					Core.Heat[1].IO_Field_Text[34] = math.max( table.unpack( tYear));											-- вычисление максимальных значений	
			fd:close();
		end
end

	function cbComboBox()
		if Core.ReportGazChanged == true then
			for i = 0, 7 do
				if Core.ReportGazIndex == i then
					Core.ReportsGas[i] = true;
				end
			end
		end
	end
--**********************************************************
--********************	  ENTRY	  **************************
--**********************************************************

changeBehaviorTextFieldHA();

local ret;
ret = init();
if ret == -1 then
	goto exit;
end 

Core.onExtChange( {"ReportGazChanged"}, cbComboBox);
Core.onExtChange( {"HourButtonPressed", "DateButtonPressed", "MonthButtonPressed", "QuarterButtonPressed", "YearButtonPressed"}, cbButton);
Core.onExtChange( {"DateSelectorPressed", "HourButtonPressed", "DateButtonPressed", "MonthButtonPressed", "QuarterButtonPressed", "YearButtonPressed"}, cbDateSelector);
Core.waitEvents();
::exit::

--**********************************************************
--********************	  EXIT	  **************************
--**********************************************************