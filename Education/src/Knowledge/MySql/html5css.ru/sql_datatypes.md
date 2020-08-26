﻿<a href="https://html5css.ru/sql/sql_datatypes.php" target="_blank">https://html5css.ru/sql/sql_datatypes.php</a>

<!-- Start Document Outline -->

* [Типы данных SQL](#типы-данных-sql)
	* [Типы данных MySQL](#типы-данных-mysql)
		* [Текстовые типы данных:](#текстовые-типы-данных)
			* [CHAR(size)](#charsize)
			* [VARCHAR(size)](#varcharsize)
			* [TINYTEXT](#tinytext)
			* [TEXT](#text)
			* [BLOB](#blob)
			* [MEDIUMTEXT](#mediumtext)
			* [MEDIUMBLOB](#mediumblob)
			* [LONGTEXT](#longtext)
			* [ENUM(x,y,z,etc.)](#enumxyzetc)
			* [SET](#set)
		* [Типы данных чисел:](#типы-данных-чисел)
			* [TINYINT(size)](#tinyintsize)
			* [SMALLINT(size)](#smallintsize)
			* [MEDIUMINT(size)](#mediumintsize)
			* [INT(size)](#intsize)
			* [BIGINT(size)](#bigintsize)
			* [FLOAT(size,d)](#floatsized)
			* [DOUBLE(size,d)](#doublesized)
			* [DECIMAL(size,d)](#decimalsized)
		* [Типы данных дат:](#типы-данных-дат)
			* [DATE()](#date)
			* [DATETIME()](#datetime)
			* [TIMESTAMP()](#timestamp)
			* [TIME()](#time)
			* [YEAR()](#year)
		* [Типы строковых данных:](#типы-строковых-данных)
			* [char(n)](#charn)
			* [varchar(n)](#varcharn)
			* [varchar(max)](#varcharmax)
			* [text](#text-1)
			* [nchar](#nchar)
			* [nvarchar](#nvarchar)
			* [nvarchar(max)](#nvarcharmax)
			* [ntext](#ntext)
			* [binary(n)](#binaryn)
			* [varbinary](#varbinary)
			* [varbinary(max)](#varbinarymax)
			* [image](#image)
		* [Типы данных чисел:](#типы-данных-чисел-1)
			* [bit](#bit)
			* [tinyint](#tinyint)
			* [smallint](#smallint)
			* [int](#int)
			* [bigint](#bigint)
			* [decimal(p,s)](#decimalps)
			* [smallmoney](#smallmoney)
			* [float(n)](#floatn)
			* [real](#real)
		* [Типы данных дат:](#типы-данных-дат-1)
			* [datetime](#datetime-1)
			* [datetime2](#datetime2)
			* [smalldatetime](#smalldatetime)
			* [date](#date-1)
			* [time](#time-1)
			* [datetimeoffset](#datetimeoffset)
			* [timestamp](#timestamp-1)
		* [Другие типы данных:](#другие-типы-данных)
			* [sql_variant](#sql_variant)
			* [uniqueidentifier](#uniqueidentifier)
			* [xml](#xml)
			* [cursor](#cursor)
			* [table](#table)
	* [Типы данных Microsoft Access](#типы-данных-microsoft-access)
		* [Text](#text-2)
		* [Memo](#memo)
		* [Byte](#byte)
		* [Integer](#integer)
		* [Long](#long)
		* [Single](#single)
		* [Double](#double)
		* [Currency](#currency)
		* [AutoNumber](#autonumber)
		* [Date/Time](#datetime-2)
		* [Yes/No](#yesno)
		* [Ole Object](#ole-object)
		* [Hyperlink](#hyperlink)
		* [Lookup Wizard](#lookup-wizard)

<!-- End Document Outline -->

# Типы данных SQL
Каждый столбец в таблице базы данных должен иметь имя и тип данных.

Разработчик SQL должен решить, какой тип данных будет храниться в каждом столбце при создании таблицы. Тип данных является ориентиром для SQL, чтобы понять, какой тип данных ожидается внутри каждого столбца, и он также определяет, как SQL будет взаимодействовать с хранимыми данными.

> Примечание: Типы данных могут иметь разные имена в разных базах данных. И даже если имя такое же, размер и другие детали могут быть разными! Всегда проверяйте документацию!

## Типы данных MySQL
В MySQL есть три основных типа данных: текст, число и дата.

### Текстовые типы данных:
Тип данных	Описание
#### CHAR(size)	
Содержит строку фиксированной длины (может содержать буквы, цифры и специальные символы). Фиксированный размер указывается в скобках. Может хранить до 255 символов
#### VARCHAR(size)
Содержит строку переменной длины (может содержать буквы, цифры и специальные символы). Максимальный размер указывается в скобках. Может хранить до 255 символов. Примечание: Если поместить большее значение, чем 255, оно будет преобразовано в текстовый тип
#### TINYTEXT
Содержит строку с максимальной длиной 255 символов
#### TEXT
Содержит строку с максимальной длиной 65 535 символов
#### BLOB
Для BLOB-объектов (двоичные большие объекты). Удерживает до 65 535 байт данных
#### MEDIUMTEXT
Содержит строку с максимальной длиной 16 777 215 символов
#### MEDIUMBLOB
Для BLOB-объектов (двоичные большие объекты). Удерживает до 16 777 215 байт данных
#### LONGTEXT
Содержит строку с максимальной длиной 4 294 967 295 символов
LONGBLOB	Для BLOB-объектов (двоичные большие объекты). Удерживает до 4 294 967 295 байт данных
#### ENUM(x,y,z,etc.)
Позволяет ввести список возможных значений. В списке Enum можно вывести до 65535 значений. Если вставленное значение отсутствует в списке, будет вставлено пустое значение.
> Примечание: Значения сортируются в порядке их ввода.

Вы вводите возможные значения в этом формате: Enum (' X ', ' Y ', ' Z ')
#### SET
Аналогично Enum, за исключением того, что набор может содержать до 64 элементов списка и может хранить более одного выбора
### Типы данных чисел:
Тип данных	Описание
#### TINYINT(size)
-128 до 127 нормальный. 0 до 255 неподписанный *. Максимальное количество цифр может быть указано в скобках
#### SMALLINT(size)
-32768 до 32767 нормальный. 0 до 65535 неподписанный *. Максимальное количество цифр может быть указано в скобках
#### MEDIUMINT(size)
-8388608 до 8388607 нормальный. 0 до 16777215 неподписанный *. Максимальное количество цифр может быть указано в скобках
#### INT(size)
-2147483648 до 2147483647 нормальный. 0 до 4294967295 неподписанный *. Максимальное количество цифр может быть указано в скобках
#### BIGINT(size)
-9223372036854775808 до 9223372036854775807 в норме. 0 для 18446744073709551615 неподписанных *. Максимальное количество цифр может быть указано в скобках
#### FLOAT(size,d)
Небольшое число с плавающей запятой. Максимальное количество цифр может быть указано в параметре size. Максимальное число цифр справа от десятичной запятой указано в параметре d
#### DOUBLE(size,d)
Большое число с плавающей запятой. Максимальное количество цифр может быть указано в параметре size. Максимальное число цифр справа от десятичной запятой указано в параметре d
#### DECIMAL(size,d)
Значение типа Double, хранящееся в виде строки и допускающее фиксированную десятичную точку. Максимальное количество цифр может быть указано в параметре size. Максимальное число цифр справа от десятичной запятой указано в параметре d

> целочисленные типы имеют дополнительный параметр, называемый неподписанным. Как правило, целое число переходит от отрицательного к положительному значению. Добавление неподписанного атрибута будет перемещаться, что диапазон вверх, поэтому он начинается с нуля, а не отрицательное число.

### Типы данных дат:
Тип данных	Описание
#### DATE()
Свидание. Формат: гггг-мм-DD
Примечание: Поддерживаемый диапазон от ' 1000-01-01 ' до ' 9999-12-31 '

#### DATETIME()	
комбинация даты и времени. Формат: гггг-мм-DD HH: MI: SS
> Примечание: Поддерживаемый диапазон от ' 1000-01-01 00:00:00 ' до ' 9999-12-31 23:59:59 '

#### TIMESTAMP()
Временная метка. Значения timestamp хранятся в виде количества секунд со времени Unix (' 1970-01-01 00:00:00 ' UTC). Формат: гггг-мм-DD HH: MI: SS
> Примечание: Поддерживаемый диапазон от ' 1970-01-01 00:00:01 ' UTC до ' 2038-01-09 03:14:07 ' UTC

#### TIME()
Время. Формат: HH: MI: SS
>Примечание: Поддерживаемый диапазон от '-838:59:59 ' до ' 838:59:59 '

#### YEAR()
Год в формате с двумя или четырьмя цифрами.

> Примечание: Допустимые значения в формате четырех цифр: 1901 до 2155. Допустимые значения в формате с двумя цифрами: 70 до 69, представляющие годы с 1970 по 2069

> даже если DateTime и timestamp возвращаются в том же формате, они работают очень по-разному. В запросе INSERT или Update временная метка автоматически устанавливает текущую дату и время. TIMESTAMP также принимает различные форматы, такие как ииииммддххмисс, ииммддххмисс, ГГГГММДД или YYMMDD.

Типы данных SQL Server
### Типы строковых данных:
Тип данных	Описание	Максимальный размер	Хранения
#### char(n)
Фиксированная ширина символьной строки	8,000 Символов	Определенная ширина
#### varchar(n)
Переменная ширина символьная строка	8,000 Символов	2 байта + количество символов
#### varchar(max)
Переменная ширина символьная строка	1,073,741,824 Символов	2 байта + количество символов
#### text
Переменная ширина символьная строка	2GB of text data	4 байта + количество символов
#### nchar
Фиксированная ширина строки Юникода	4,000 Символов	Определенная ширина x 2
#### nvarchar
Переменная ширина Юникод строка	4,000 Символов	 
#### nvarchar(max)
Переменная ширина Юникод строка	536,870,912 Символов	 
#### ntext
Переменная ширина Юникод строка	2GB of text data	 
#### binary(n)
Фиксированная ширина двоичной строки	8,000 bytes	 
#### varbinary
Переменная ширина двоичная строка	8,000 bytes	 
#### varbinary(max)
Переменная ширина двоичная строка	2GB	 
#### image
Переменная ширина двоичная строка	2GB	 
### Типы данных чисел:
Тип данных	Описание	Хранения
#### bit
Целое число, которое может быть 0, 1 или null	 
#### tinyint
Позволяет целые числа от 0 до 255	1 byte
#### smallint
Позволяет целые числа между -32 768 и 32 767	2 bytes
#### int
Позволяет целые числа между -2 147 483 648 и 2 147 483 647	4 bytes
#### bigint
Позволяет целые числа между -9223372036854775808 и 9 223 372 036 854 775 807	8 bytes
#### decimal(p,s)
Fixed precision and scale numbers.
Разрешает числа от-10 ^ 38 + 1 до 10 ^ 38 – 1.

Параметр p указывает максимальное общее количество цифр, которые могут быть сохранены (как слева, так и справа от десятичной запятой). p должно быть значением от 1 до 38. Значение по умолчанию — 18.

Параметр s указывает максимальное число цифр, хранящихся справа от десятичной запятой. s должно быть значением от 0 до p. значение по умолчанию 0

5-17 bytes
numeric(p,s)	Фиксированные значения точности и масштаба.
Разрешает числа от-10 ^ 38 + 1 до 10 ^ 38 – 1.

Параметр p указывает максимальное общее количество цифр, которые могут быть сохранены (как слева, так и справа от десятичной запятой). p должно быть значением от 1 до 38. Значение по умолчанию — 18.

Параметр s указывает максимальное число цифр, хранящихся справа от десятичной запятой. s должно быть значением от 0 до p. значение по умолчанию 0

5-17 bytes
#### smallmoney
Денежные данные от-214 748,3648 до 214 748,3647	4 bytes
money	Денежные данные от-922 337 203 685 477,5808 до 922 337 203 685 477,5807	8 bytes
#### float(n)
Плавающая точность данных чисел от-1.79 e + 308 до 1.79 e + 308.
Параметр n указывает, должно ли поле содержать 4 или 8 байт. float (24) содержит 4-байтное поле и float (53) содержит 8-байтное поле. Значение по умолчанию n — 53.

4 or 8 bytes
#### real
Плавающие данные о точности чисел от-38 e +	4 bytes
### Типы данных дат:
Тип данных	Описание	Хранения
#### datetime
С 1 января 1753 по 31 декабря 9999 с точностью 3,33 миллисекунд	8 bytes
#### datetime2
С 1 января 0001 по 31 декабря 9999 с точностью 100.	6-8 bytes
#### smalldatetime
С 1 января 1900 по 6 июня 2079 с точностью до 1 минуты	4 bytes
#### date
Хранить только дату. С 1 января 0001 по 31 декабря 9999	3 bytes
#### time
Хранить время только для точности 100-ти секунд	3-5 bytes
#### datetimeoffset
Так же, как datetime2 с добавлением смещения часового пояса	8-10 bytes
#### timestamp
Хранит уникальный номер, который обновляется каждый раз при создании или изменении строки. Значение timestamp основывается на внутренних часах и не соответствует реальному времени. Каждая таблица может иметь только одну переменную timestamp	 
### Другие типы данных:
Тип данных	Описание
#### sql_variant
Хранит до 8 000 байт данных различных типов данных, за исключением текста, ntext и отметки времени
#### uniqueidentifier
Хранит глобальный уникальный идентификатор (GUID)
#### xml
Хранит XML-форматированные данные. Максимум 2 ГБ
#### cursor
Хранит ссылку на курсор, используемый для операций с базой данных
#### table
Хранит результирующий набор для последующей обработки

## Типы данных Microsoft Access
Тип данных	Описание	Хранения
#### Text
Используется для текста или комбинаций текста и чисел. 255 символов максимум	 
#### Memo
MEMO используется для больших объемов текста. Хранит до 65 536 символов. 
> Примечание: Поле MEMO нельзя сортировать. Тем не менее, они доступны для поиска	 

#### Byte
Позволяет целые числа от 0 до 255	1 byte
#### Integer
Позволяет целые числа между-32 768 и 32 767	2 bytes
#### Long
Позволяет целые числа между-2 147 483 648 и 2 147 483 647	4 bytes
#### Single
Одинарная точность с плавающей запятой. Будет обрабатывать большинство десятичных знаков	4 bytes
#### Double
Двойная точность с плавающей запятой. Будет обрабатывать большинство десятичных знаков	8 bytes
#### Currency
Использовать для валюты. Вмещает до 15 цифр целых долларов, плюс 4 десятичных знака. Совет: Вы можете выбрать валюту страны для использования	8 bytes
#### AutoNumber
Поля автонумерации автоматически дают каждой записи свой номер, обычно начиная с 1	4 bytes
#### Date/Time
Использовать для дат и времени	8 bytes
#### Yes/No
Логическое поле может отображаться как Yes/No, true/false или вкл/выкл. В коде используйте Константы true и false (эквивалентно-1 и 0). Примечание: Значения NULL не разрешены в полях "да/нет"	1 bit
#### Ole Object
Может хранить изображения, аудио, видео, или другие BLOB-объекты (двоичные больших объектов)	up to 1GB
#### Hyperlink
Содержать ссылки на другие файлы, включая веб-страницы	 
#### Lookup Wizard
Позволяет ввести список опций, которые затем можно выбрать из раскрывающегося списка	4 bytes