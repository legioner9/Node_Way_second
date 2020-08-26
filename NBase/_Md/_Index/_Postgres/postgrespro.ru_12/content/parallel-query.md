https://postgrespro.ru/docs/postgrespro/12/parallel-query

Глава 
# 15. Параллельный запрос
Содержание

15.1. Как работают параллельно выполняемые запросы
15.2. Когда может применяться распараллеливание запросов?
15.3. Параллельные планы
15.3.1. Параллельные сканирования
15.3.2. Параллельные соединения
15.3.3. Параллельное агрегирование
15.3.4. Параллельное присоединение
15.3.5. Советы по параллельным планам
15.4. Безопасность распараллеливания
Postgres Pro может вырабатывать такие планы запросов, которые будут задействовать несколько CPU, чтобы получить ответ на запросы быстрее. Эта возможность называется распараллеливанием запросов. Для многих запросов параллельное выполнение не даёт никакого выигрыша, либо из-за ограничений текущей реализации, либо из-за принципиальной невозможности построить параллельный план, который был бы быстрее последовательного. Однако для запросов, в которых это может быть полезно, распараллеливание часто даёт очень значительное ускорение. Многие такие запросы могут выполняться в параллельном режиме как минимум двое быстрее, а некоторые — быстрее в четыре и даже более раз. Обычно наибольший выигрыш можно получить с запросами, обрабатывающими большой объём данных, но возвращающими пользователю всего несколько строк. В этой главе достаточно подробно рассказывается, как работают параллельные запросы и в каких ситуациях их можно использовать, чтобы пользователи, желающие применять их, понимали, чего ожидать.

## 15.1. Как работают параллельно выполняемые запросы
Когда оптимизатор определяет, что параллельное выполнение будет наилучшей стратегией для конкретного запроса, он создаёт план запроса, включающий узел Gather (Сбор) или Gather Merge (Сбор со слиянием). Взгляните на простой пример:

    EXPLAIN SELECT * FROM pgbench_accounts WHERE filler LIKE '%x%';
                                        QUERY PLAN                                      
    -------------------------------------------------------------------------------------
    Gather  (cost=1000.00..217018.43 rows=1 width=97)
    Workers Planned: 2
    ->  Parallel Seq Scan on pgbench_accounts  (cost=0.00..216018.33 rows=1 width=97)
            Filter: (filler ~~ '%x%'::text)
    (4 rows)
Во всех случаях узел Gather или Gather Merge будет иметь ровно один дочерний план, представляющий часть общего плана, выполняемую в параллельном режиме. Если узел Gather или Gather Merge располагается на самом верху дерева плана, в параллельном режиме будет выполняться весь запрос. Если он находится где-то в другом месте плана, параллельно будет выполняться только часть плана ниже него. В приведённом выше примере запрос обращается только к одной таблице, так что помимо узла Gather есть только ещё один узел плана; и так как этот узел является потомком узла Gather, он будет выполняться в параллельном режиме.

Используя EXPLAIN, вы можете узнать количество исполнителей, выбранное планировщиком для данного запроса. Когда при выполнении запроса достигается узел Gather, процесс, обслуживающий сеанс пользователя, запрашивает фоновые рабочие процессы в этом количестве. Количество исполнителей, которое может попытаться задействовать планировщик, ограничивается значением max_parallel_workers_per_gather. Общее число фоновых рабочих процессов, которые могут существовать одновременно, ограничивается параметрами max_worker_processes и max_parallel_workers. Таким образом, вполне возможно, что параллельный запрос будет выполняться меньшим числом рабочих процессов, чем планировалось, либо вообще без дополнительных рабочих процессов. Оптимальность плана может зависеть от числа доступных рабочих процессов, так что их нехватка может повлечь значительное снижение производительности. Если это наблюдается часто, имеет смысл увеличить max_worker_processes и max_parallel_workers, чтобы одновременно могло работать больше процессов, либо наоборот уменьшить max_parallel_workers_per_gather, чтобы планировщик запрашивал их в меньшем количестве.

Каждый фоновый рабочий процесс, успешно запущенный для данного параллельного запроса, будет выполнять параллельную часть плана. Ведущий процесс также будет выполнять эту часть плана, но он несёт дополнительную ответственность: он должен также прочитать все кортежи, выданные рабочими процессами. Когда параллельная часть плана выдаёт лишь небольшое количество кортежей, ведущий часто ведёт себя просто как один из рабочих процессов, ускоряя выполнение запроса. И напротив, когда параллельная часть плана выдаёт множество кортежей, ведущий может быть почти всё время занят чтением кортежей, выдаваемых другими рабочими процессами, и выполнять другие шаги обработки, связанные с узлами плана выше узла Gather или Gather Merge. В таких случаях ведущий процесс может вносить лишь минимальный вклад в выполнение параллельной части плана.

Когда над параллельной частью плана оказывается узел Gather Merge, а не Gather, это означает, что все процессы, выполняющие части параллельного плана, выдают кортежи в отсортированном порядке, и что ведущий процесс выполняет слияние с сохранением порядка. Узел же Gather, напротив, получает кортежи от подчинённых процессов в произвольном удобном ему порядке, нарушая порядок сортировки, который мог существовать.

## 15.2. Когда может применяться распараллеливание запросов?
Планировщик запросов может отказаться от построения параллельных планов запросов в любом случае под влиянием нескольких параметров. Чтобы он строил параллельные планы запросов при каких-бы то ни было условиях, описанные далее параметры необходимо настроить указанным образом.

max_parallel_workers_per_gather должен иметь значение, большее нуля. Это особый вариант более общего ограничения на суммарное число используемых рабочих процессов, задаваемого параметром max_parallel_workers_per_gather.

В дополнение к этому, система должна работать не в однопользовательском режиме. Так как в этом режиме вся СУБД работает в одном процессе, фоновые рабочие процессы в нём недоступны.

Даже если принципиально возможно построить параллельные планы выполнения, планировщик не будет строить такой план для определённого запроса, если имеет место одно из следующих обстоятельств:

- Запрос выполняет запись данных или блокирует строки в базе данных. Если запрос содержит операцию, изменяющую данные либо на верхнем уровне, либо внутри CTE, для такого запроса не будут строиться параллельные планы. Исключение составляют команды CREATE TABLE ... AS, SELECT INTO и CREATE MATERIALIZED VIEW, которые создают новую таблицу и наполняют её, и при этом могут использовать параллельный план.

- Запрос может быть приостановлен в процессе выполнения. В ситуациях, когда система решает, что может иметь место частичное или дополнительное выполнение, план параллельного выполнения не строится. Например, курсор, созданный предложением DECLARE CURSOR, никогда не будет использовать параллельный план. Подобным образом, цикл PL/pgSQL вида FOR x IN query LOOP .. END LOOP никогда не будет использовать параллельный план, так как система параллельных запросов не сможет определить, может ли безопасно выполняться код внутри цикла во время параллельного выполнения запроса.

- В запросе используются функции, помеченные как PARALLEL UNSAFE. Большинство системных функций безопасны для параллельного выполнения (PARALLEL SAFE), но пользовательские функции по умолчанию помечаются как небезопасные (PARALLEL UNSAFE). Эта характеристика функции рассматривается в Разделе 15.4.

- Запрос работает внутри другого запроса, уже параллельного. Например, если функция, вызываемая в параллельном запросе, сама выполняет SQL-запрос, последний запрос никогда не будет выполняться параллельно. Это ограничение текущей реализации, но убирать его вряд ли следует, так как это может привести к использованию одним запросом чрезмерного количества процессов.

Даже когда для определённого запроса построен параллельный план, возможны различные обстоятельства, при которых этот план нельзя будет выполнить в параллельном режиме. В этих случаях ведущий процесс выполнит часть плана ниже узла Gather полностью самостоятельно, как если бы узла Gather вовсе не было. Это произойдёт только при выполнении одного из следующих условий:

- Невозможно получить ни одного фонового рабочего процесса из-за ограничения общего числа этих процессов значением max_worker_processes.

- Невозможно получить ни одного фонового рабочего процесса из-за ограничения общего числа таких процессов для параллельного выполнения значением max_parallel_workers.

- Клиент передаёт сообщение Execute с ненулевым количеством выбираемых кортежей. За подробностями обратитесь к описанию протокола расширенных запросов. Так как libpq в настоящее время не позволяет передавать такие сообщения, это возможно только с клиентом, задействующим не libpq. Если это происходит часто, имеет смысл установить в max_parallel_workers_per_gather 0 в сеансах, для которых это актуально, чтобы система не пыталась строить планы, которые могут быть неэффективны при последовательном выполнении.

## 15.3. Параллельные планы
15.3.1. Параллельные сканирования
15.3.2. Параллельные соединения
15.3.3. Параллельное агрегирование
15.3.4. Параллельное присоединение
15.3.5. Советы по параллельным планам
Так как каждый рабочий процесс выполняет параллельную часть плана до конца, нельзя просто взять обычный план запроса и запустить его в нескольких исполнителях. В этом случае все исполнители выдавали бы полные копии выходного набора результатов, так что запрос выполнится не быстрее, чем обычно, а его результаты могут быть некорректными. Вместо этого параллельной частью плана должно быть то, что для оптимизатора представляется как частичный план; то есть такой план, при выполнении которого в отдельном процессе будет получено только подмножество выходных строк, а каждая требующаяся строка результата будет гарантированно выдана ровно одним из сотрудничающих процессов. Вообще говоря, это означает, что сканирование нижележащей таблицы запроса должно проводиться с учётом распараллеливания.

### 15.3.1. Параллельные сканирования
В настоящее время поддерживаются следующие виды сканирований таблицы, рассчитанные на параллельное выполнение.

При параллельном последовательном сканировании блоки таблицы будут разделены между взаимодействующими процессами. Блоки выдаются по очереди, так что доступ к таблице остаётся последовательным.

При параллельном сканировании кучи по битовой карте один процесс выбирается на роль ведущего. Этот процесс производит сканирование одного или нескольких индексов и строит битовую карту, показывающую, какие блоки таблицы нужно посетить. Затем эти блоки разделяются между взаимодействующими процессами как при параллельном последовательном сканировании. Другими словами, сканирование кучи выполняется в параллельном режиме, а сканирование нижележащего индекса — нет.

При параллельном сканировании по индексу или параллельном сканировании только индекса взаимодействующие процессы читают данные из индекса по очереди. В настоящее время параллельное сканирование индекса поддерживается только для индексов-B-деревьев. Каждый процесс будет выбирать один блок индекса с тем, чтобы просканировать и вернуть все кортежи, на которые он ссылается; другие процессы могут в то же время возвращать кортежи для другого блока индекса. Результаты параллельного сканирования B-дерева каждый рабочий процесс возвращает в отсортированном порядке.

В будущем может появиться поддержка параллельного выполнения и для других вариантов сканирования, например, сканирования индексов, отличных от B-дерева.

### 15.3.2. Параллельные соединения
Как и в непараллельном плане, целевая таблица может соединяться с одной или несколькими другими таблицами с использованием вложенных циклов, соединения по хешу или соединения слиянием. Внутренней стороной соединения может быть любой вид непараллельного плана, который в остальном поддерживается планировщиком, при условии, что он безопасен для выполнения в параллельном исполнителе. Внутренней стороной может быть и параллельный план, в зависимости от типа соединения.

В соединении с вложенным циклом внутренняя сторона всегда непараллельная. Хотя она выполняется полностью, это эффективно, если с внутренней стороны производится сканирование индекса, так как внешние кортежи, а значит и циклы, находящие значения в индексе, разделяются по параллельным процессам.

При соединении слиянием с внутренней стороны всегда будет непараллельный план и, таким образом, он будет выполняться полностью. Это может быть неэффективно, особенно если потребуется произвести сортировку, так как работа и конечные данные будут повторяться в каждом параллельном процессе.

При соединении по хешу (непараллельном, без префикса «parallel») внутреннее соединение выполняется полностью в каждом параллельном процессе, и в результате они строят одинаковые копии хеш-таблицы. Это может быть неэффективно при большой хеш-таблице или дорогостоящем плане. В параллельном соединении по хешу с внутренней стороны выполняется параллельное хеширование, при котором работа по построению общей хеш-таблицы разделяется между параллельными процессами.

### 15.3.3. Параллельное агрегирование
Postgres Pro поддерживает параллельное агрегирование, выполняя агрегирование в два этапа. Сначала каждый процесс, задействованный в параллельной части запроса, выполняет шаг агрегирования, выдавая частичный результат для каждой известной ему группы. В плане это отражает узел Partial Aggregate. Затем эти промежуточные результаты передаются ведущему через узел Gather или Gather Merge. И наконец, ведущий заново агрегирует результаты всех рабочих процессов, чтобы получить окончательный результат. Это отражает в плане узел Finalize Aggregate.

Так как узел Finalize Aggregate выполняется в ведущем процессе, запросы, выдающие достаточно большое количество групп по отношению к числу входных строк, будут расцениваться планировщиком как менее предпочтительные. Например, в худшем случае количество групп, выявленных узлом Finalize Aggregate, может равняться числу входных строк, обработанных всеми рабочими процессами на этапе Partial Aggregate. Очевидно, что в такой ситуации использование параллельного агрегирования не даст никакого выигрыша производительности. Планировщик запросов учитывает это в процессе планирования, так что выбор параллельного агрегирования в подобных случаях очень маловероятен.

Параллельное агрегирование поддерживается не во всех случаях. Чтобы оно поддерживалось, агрегатная функция должна быть безопасной для распараллеливания и должна иметь комбинирующую функцию. Если переходное состояние агрегатной функции имеет тип internal, она должна также иметь функции сериализации и десериализации. За подробностями обратитесь к CREATE AGGREGATE. Параллельное агрегирование не поддерживается, если вызов агрегатной функции содержит предложение DISTINCT или ORDER BY. Также оно не поддерживается для сортирующих агрегатов или когда запрос включает предложение GROUPING SETS. Оно может использоваться только когда все соединения, задействованные в запросе, также входят в параллельную часть плана.

### 15.3.4. Параллельное присоединение
Когда требуется объединить строки из различных источников в единый набор результатов, в Postgres Pro используются узлы плана Append или MergeAppend. Это обычно происходит при реализации UNION ALL или при сканировании секционированной таблицы. Данные узлы могут применяться как в параллельных, так и в обычных планах. Однако в параллельных планах планировщик может заменить их на узел Parallel Append.

Если в параллельном плане используется узел Append, все задействованные процессы выполняют очередной дочерний план совместно, пока он не будет завершён, и лишь затем, примерно в одно время, переходят к выполнению следующего дочернего плана. Когда же применяется Parallel Append, исполнитель старается равномерно распределить между задействованными процессами все дочерние планы, чтобы они выполнялись параллельно. Это позволяет избежать конкуренции и не тратить ресурсы на запуск дочернего плана для тех процессов, которые не будут его выполнять.

Кроме того, в отличие от обычного узла Append, использование которого внутри параллельного плана допускается только для частичных дочерних планов, узел Parallel Append может обрабатывать как частичные, так и не частичные дочерние планы. Для сканирования не частичного плана будет использоваться только один процесс, поскольку его многократное сканирование приведёт лишь к дублированию результатов. Таким образом, для планов, объединяющих несколько наборов результатов, можно достичь параллельного выполнения на высоком уровне, даже когда эффективные частичные планы отсутствуют. Например, рассмотрим запрос к секционированной таблице, который может быть эффективно реализован только с помощью индекса, не поддерживающего параллельное сканирование. Планировщик может выбрать узел Parallel Append для параллельного объединения нескольких обычных планов Index Scan; в этом случае каждое сканирование индекса будет выполняться до полного завершения одним процессом, но при этом разные сканирования будут осуществляться параллельно.

Отключить данную функциональность можно с помощью enable_parallel_append.

### 15.3.5. Советы по параллельным планам
Если для запроса ожидается параллельный план, но такой план не строится, можно попытаться уменьшить parallel_setup_cost или parallel_tuple_cost. Разумеется, этот план может оказаться медленнее последовательного плана, предпочитаемого планировщиком, но не всегда. Если вы не получаете параллельный план даже с очень маленькими значениями этих параметров (например, сбросив оба их в ноль), может быть какая-то веская причина тому, что планировщик запросов не может построить параллельный план для вашего запроса. За информацией о возможных причинах обратитесь к Разделу 15.2 и Разделу 15.4.

Когда выполняется параллельный план, вы можете применить EXPLAIN (ANALYZE, VERBOSE), чтобы просмотреть статистику по каждому узлу плана в разрезе рабочих процессов. Это может помочь определить, равномерно ли распределяется работа между всеми узлами плана, и на более общем уровне понимать характеристики производительности плана.

## 15.4. Безопасность распараллеливания
### 15.4.1. Пометки параллельности для функций и агрегатов
Планировщик классифицирует операции, вовлечённые в выполнение запроса, как либо безопасные для распараллеливания, либо ограниченно распараллеливаемые, либо небезопасные для распараллеливания. Безопасной для распараллеливания операцией считается такая, которая не мешает параллельному выполнению запроса. Ограниченно распараллеливаемой операцией считается такая, которая не может выполняться в параллельном рабочем процессе, но может выполняться в ведущем процессе, когда запрос выполняется параллельно. Таким образом, ограниченно параллельные операции никогда не могут оказаться ниже узла Gather или Gather Merge, но могут встречаться в других местах плана, содержащего такой узел. Небезопасные для распараллеливания операции не могут выполняться в параллельных запросах, даже в ведущем процессе. Когда запрос содержит что-либо небезопасное для распараллеливания, параллельное выполнение для такого запроса полностью исключается.

Ограниченно распараллеливаемыми всегда считаются следующие операции.

- Сканирование общих табличных выражений (CTE).

- Сканирование временных таблиц.

- Сканирование сторонних таблиц, если только обёртка сторонних данных не предоставляет функцию IsForeignScanParallelSafe, которая допускает распараллеливание.

- Узлы плана, к которым присоединён узел InitPlan.

- Узлы плана, которые ссылаются на связанный SubPlan.

### 15.4.1. Пометки параллельности для функций и агрегатов
Планировщик не может автоматически определить, является ли пользовательская обычная или агрегатная функция безопасной для распараллеливания, так как это потребовало бы предсказания действия каждой операции, которую могла бы выполнять функция. В общем случае это равнозначно решению проблемы остановки, а значит, невозможно. Даже для простых функций, где это в принципе возможно, мы не пытаемся это делать, так как это будет слишком дорогой и потенциально неточной процедурой. Вместо этого, все определяемые пользователем функции полагаются небезопасными для распараллеливания, если явно не отмечено обратное. Когда используется CREATE FUNCTION или ALTER FUNCTION, функции можно назначить отметку PARALLEL SAFE, PARALLEL RESTRICTED или PARALLEL UNSAFE, отражающую её характер. В команде CREATE AGGREGATE для параметра PARALLEL можно задать SAFE, RESTRICTED или UNSAFE в виде соответствующего значения.

Обычные и агрегатные функции должны помечаться небезопасными для распараллеливания (PARALLEL UNSAFE), если они пишут в базу данных, обращаются к последовательностям, изменяют состояние транзакции, даже временно (как, например, функция PL/pgSQL, устанавливающая блок EXCEPTION для перехвата ошибок), либо производят постоянные изменения параметров. Подобным образом, функции должны помечаться как ограниченно распараллеливаемые (PARALLEL RESTRICTED), если они обращаются к временным таблицам, состоянию клиентского подключения, курсорам, подготовленным операторам или разнообразному локальному состоянию обслуживающего процесса, которое система не может синхронизировать между рабочими процессами. Например, по этой причине ограниченно параллельными являются функции setseed и random.

В целом, если функция помечена как безопасная, когда на самом деле она небезопасна или ограниченно безопасна, или если она помечена как ограниченно безопасная, когда на самом деле она небезопасная, такая функция может выдавать ошибки или возвращать неправильные ответы при использовании в параллельном запросе. Функции на языке C могут теоретически проявлять полностью неопределённое появление при некорректной пометке, так как система никаким образом не может защитить себя от произвольного кода C, но чаще всего результат будет не хуже, чем с любой другой функцией. В случае сомнений, вероятно, лучше всего будет помечать функции как небезопасные (UNSAFE).

Если функция, выполняемая в параллельном рабочем процессе, затребует блокировки, которыми не владеет ведущий, например, обращаясь к таблице, не упомянутой в запросе, эти блокировки будут освобождены по завершении процесса, а не в конце транзакции. Если вы разрабатываете функцию с таким поведением, и эта особенность выполнения оказывается критичной, пометьте такую функцию как PARALLEL RESTRICTED, чтобы она выполнялась только в ведущем процессе.

Заметьте, что планировщик запросов не рассматривает возможность отложенного выполнения ограниченно распараллеливаемых обычных или агрегатных функций, задействованных в запросе, для получения лучшего плана. Поэтому, например, если предложение WHERE, применяемое к конкретной таблице, является ограниченно параллельным, планировщик запросов исключит возможность сканирования этой таблицы в параллельной части плана. В некоторых случаях возможно (и, вероятно, более эффективно) включить сканирование этой таблицы в параллельную часть запроса и отложить вычисление предложения WHERE, чтобы оно происходило над узлом Gather, но планировщик этого не делает.
