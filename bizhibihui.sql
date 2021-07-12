-- MySQL 必知必会第3章
SHOW  DATABASES;

SHOW  tables;

-- SHOW COLUMNS要求给出一个表名（这个例子中的FROMcustomers），
-- 它对每个字段返回一行，行中包含字段名、数据类型、是否允许NULL、键信息、默认值以及其他信息
-- DESCRIBE 为快捷语句
DESC customers;

-- 进一步了解SHOW请在mysql命令行实用程序中，执行命令HELP SHOW；显示允许的SHOW语句。


-- 第4章 检索数据
-- 检索一列，如无必要，不应使用select *，效率较低
SELECT prod_name FROM products;

-- SELECT DISTINCT vend_id告诉MySQL只返回不同（唯一）的vend_id行，
-- DISTINCT 必须直接放在列名的前面。
-- 不能部分使用DISTINCT DISTINCT关键字应用于所有列而不仅是前置它的列。
-- 如果给出SELECT DISTINCT vend_id, prod_price，
-- 除非指定的两个列都不同，否则所有行都将被检索出来。
SELECT DISTINCT vend_id FROM vendors;

-- SELECT语句返回所有匹配的行，它们可能是指定表中的每个行。
-- 为了返回第一行或前几行，可使用LIMIT子句。
SELECT DISTINCT vend_id FROM vendors LIMIT 2;

--当 limit和offset组合使用的时候，limit后面只能有一个参数，表示要取的的数量
-- offset表示要跳过的数量。
SELECT DISTINCT vend_id FROM vendors LIMIT 2 OFFSET 1;


-- 第5章 排序检索数据
SELECT prod_name FROM products ORDER BY prod_name;

-- 多个列排序时，排序完全按所规定的顺序进行。
-- 换句话说，对于上述例子中的输出，
-- 仅在多个行具有相同的prod_price值时才对产品按prod_name进行排序。
-- 如果prod_price列中所有的值都是唯一的，则不会按prod_name排序。
SELECT prod_id, prod_name, prod_price
FROM products
ORDER BY prod_price, prod_name;

-- 指定排序方向
-- DESC关键字只应用到直接位于其前面的列名。如下，
-- 只对prod_price列指定DESC，对prod_name列不指定。
-- 因此，prod_price列以降序排序，
-- 而prod_name列（在每个价格内）仍然按标准的升序排序。
SELECT prod_id, prod_name, prod_price
FROM products
ORDER BY prod_price DESC, prod_name;


-- 第6章 过滤数据
-- 使用where子句过滤数据
-- where支持的基本操作符包括=, !=, >, <, BETWEEN...AND(包括边界)
SELECT prod_id, prod_name, prod_price
FROM products
WHERE prod_price > 30
ORDER BY prod_price DESC, prod_name;

-- 空值NULL
-- 在通过过滤选择出不具有特定值的行时，
-- 你可能希望返回具有NULL值的行。但是，不行。因为未知具有特殊的含义，
-- 数据库不知道它们是否匹配，所以在匹配过滤或不匹配过滤时不返回它们。
SELECT cust_id, cust_name, cust_email
FROM customers
WHERE cust_email IS NULL;
-- WHERE cust_email is NOT NULL;


-- 第7章 WHERE组合语句
-- MySQL允许给出多个WHERE子句。这些子句可以两种方式使用：
-- 以AND子句的方式或OR子句的方式使用。
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE prod_price > 30 or vend_id = 1001
ORDER BY prod_price DESC, prod_name;

-- IN操作符用来指定条件范围，范围中的每个条件都可以进行匹配。
-- IN取合法值的由逗号分隔的清单，全都括在圆括号中
-- 可以配合not使用
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE vend_id NOT IN (1001, 1003)
ORDER BY prod_price DESC, prod_name;


-- 第8章 使用通配符进行过滤
-- 通配符本身实际是SQL的WHERE子句中有特殊含义的字符，SQL支持几种通配符。
-- 为在搜索子句中使用通配符，必须使用LIKE操作符。

-- 最常使用的通配符是百分号（%）。在搜索串中，%表示任何字符出现任意次数。
-- 重要的是要注意到，除了一个或多个字符外，%还能匹配0个字符。
-- %代表搜索模式中给定位置的0个、1个或多个字符。
-- 虽然似乎%通配符可以匹配任何东西，但有一个例外，即NULL。
-- 即使是WHERE prod_name LIKE'%’也不能匹配用值NULL作为产品名的行
-- 根据MySQL的配置方式，搜索可以是区分大小写的。
-- 如果区分大小写，'jet%’与JetPack 1000将不匹配。
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE prod_name LIKE 'jet%'
ORDER BY prod_price DESC, prod_name;

-- 另一个有用的通配符是下划线（_）。
-- 下划线的用途与%一样，但下划线只匹配单个字符而不是多个字符。
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE prod_name LIKE '_ ton anvil'
ORDER BY prod_price DESC, prod_name;


-- 第9章 使用正则表达式过滤数据
-- LIKE匹配整个列。如果被匹配的文本在列值中出现，
-- LIKE将不会找到它，相应的行也不被返回（除非使用通配符）。
-- 而REGEXP在列值内进行匹配，
-- 如果被匹配的文本在列值中出现，REGEXP将会找到它，相应的行将被返回。
-- 这是一个非常重要的差别。
-- 使用^和$，REGEXP就可以用来匹配整个列值（从而起与LIKE相同的作用）

-- 基本字符匹配，含有该字符的列都会返回
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE prod_name REGEXP 'ton anvil'
ORDER BY prod_price DESC, prod_name;

-- OR匹配(注意|左右两侧的空格)
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE prod_name REGEXP 'ton anvil|1000|2000'
ORDER BY prod_price DESC, prod_name;

-- 匹配几个字符之一
-- 可通过指定一组用[和]括起来的字符来完成
-- 字符集合也可以被否定，即，它们将匹配除指定字符外的任何东西。
-- 为否定一个字符集，在集合的开始处放置一个^即可。
-- 因此，尽管[123]匹配字符1、2或3，但[^123]却匹配除这些字符外的任何东西。
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE prod_name REGEXP 'ton anvil|[^13]000'
ORDER BY prod_price DESC, prod_name;

-- 匹配范围
-- [0123456789]为简化这种类型的集合，可使用-来定义一个范围。
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE prod_name REGEXP 'ton anvil|[1-3]000'
ORDER BY prod_price DESC, prod_name;

-- 匹配特殊字符
-- 为了匹配特殊字符，必须用\\为前导。\\-表示查找-, \\．表示查找．。
SELECT vend_id, prod_id, prod_name, prod_price
FROM products
WHERE prod_name REGEXP '\.'
ORDER BY prod_price DESC, prod_name;

-- 匹配多个实例
-- +，？，*，{n}等正则表达式用法，不再一一列举

-- 定位符$,^

-- 简单的正则表达式测试
-- 可以在不使用数据库表的情况下用SELECT来测试正则表达式。
-- REGEXP检查总是返回0（没有匹配）或1（匹配）。
-- 可以用带文字串的REGEXP来测试表达式，并试验它们。
SELECT  'hello' REGEXP '[a-f]';


-- 第10章 创建计算字段
-- 存储在表中的数据可能不是应用程序所需要的。
-- 我们需要直接从数据库中检索出转换、计算或格式化过的数据；
-- 而不是检索出数据，然后再在客户机应用程序或报告程序中重新格式化。
-- 这就是计算字段发挥作用的所在了。与前面各章介绍过的列不同，
-- 计算字段并不实际存在于数据库表中。
-- 计算字段是运行时在SELECT语句内创建的。

-- 使用拼接字段, 可以使用AS重命名
SELECT CONCAT(vend_name, '(', vend_country, ')') AS vend_title
FROM vendors
ORDER BY vend_name;

-- 执行算术计算
SELECT prod_id, quantity, item_price,
       quantity * item_price as total
FROM orderitems;

--如何测试计算
-- SELECT提供了测试和试验函数与计算的一个很好的办法。
-- 虽然SELECT通常用来从表中检索数据，
-- 但可以省略FROM子句以便简单地访问和处理表达式。
-- 例如，SELECT 3*2；将返回6, SELECT Trim('abc')；将返回abc，
-- 而SELECT Now()利用Now()函数返回当前日期和时间。
-- 通过这些例子，可以明白如何根据需要使用SELECT进行试验。


-- 第11章 使用数据处理函数
-- 介绍了一些常见的字符串、时间、日期、数学函数的使用
-- 用到的时候可以查看官方网站


-- 第12章 汇总数据
-- 聚集函数（aggregate function） 运行在行组上，计算和返回单个值的函数。
-- 主要有5个常用的聚集函数：AVG, COUNT, MIN, MAX, SUM

-- 一些注意点
-- NULL值 AVG, MIN, MAX忽略列值为NULL的行。
-- 使用COUNT(*)对表中行的数目进行计数，不管表列中包含的是空值（NULL）还是非空值。
-- 使用COUNT(column)对特定列中具有值的行进行计数，忽略NULL值。

-- 使用DISTINCT聚集不同值
SELECT AVG(DISTINCT prod_price) AS avg_price
FROM products
WHERE vend_id = 1003;

-- 组合聚集函数
SELECT AVG(prod_price) AS avg_price,
       MIN(prod_price) AS min_price,
       MAX(prod_price) AS max_price
FROM products;


-- 第13章 分组数据
-- 分组允许把数据分为多个逻辑组，以便能对每个组进行聚集计算。
-- 分组是在SELECT语句的GROUP BY子句中建立的。
-- 配合HAVING可以进行类似WHERE的过滤
SELECT vend_id, COUNT(*) AS num
FROM products
GROUP BY vend_id WITH ROLLUP
HAVING num > 2;

--一些注意事项
-- HAVING和WHERE的差别
-- 这里有另一种理解方法，
-- WHERE在数据分组前进行过滤，HAVING在数据分组后进行过滤。
-- 这是一个重要的区别，WHERE排除的行不包括在分组中。
-- 这可能会改变计算值，从而影响HAVING子句中基于这些值过滤掉的分组。

-- GROUP BY子句规定。
-- 如果在GROUP BY子句中嵌套了分组，数据将在最后规定的分组上进行汇总,使用WITH ROLLUP。
-- GROUP BY子句中列出的每个列都必须是检索列或有效的表达式（但不能是聚集函数）。
-- 如果在SELECT中使用表达式，则必须在GROUP BY子句中指定相同的表达式。不能使用别名。
-- 除聚集计算语句外，SELECT语句中的每个列都必须在GROUP BY子句中给出。
-- 如果分组列中具有NULL值，则NULL将作为一个分组返回。如果列中有多行NULL值，它们将分为一组。
-- GROUP BY子句必须出现在WHERE子句之后，ORDERBY子句之前。
-- 根据下面的示例还可观察各子句的顺序
SELECT vend_id, vend_id + 5 AS testv, COUNT(*) AS num
FROM products
WHERE vend_id != 1002
GROUP BY vend_id, testv
HAVING num > 1
ORDER BY num DESC
LIMIT 4;


-- 第14章 使用子查询
-- WHERE 子句中使用子查询
-- 在SELECT语句中，子查询总是从内向外处理。
SELECT cust_name FROM customers
WHERE cust_id IN
    (SELECT cust_id FROM orders
    WHERE order_num IN
        (SELECT order_num FROM orderitems
        WHERE prod_id = 'TNT2'));


-- 作为计算字段使用子查询
SELECT cust_id, cust_name, (SELECT COUNT(*) FROM orders o
                            WHERE o.cust_id = c.cust_id)
                            AS order_count
FROM customers c;


-- 第15章 连接
-- 重要的是，要理解联结不是物理实体。换句话说，它在实际的数据库表中不存在。
-- 联结由MySQL根据需要建立，它存在于查询的执行当中。
-- 在使用关系表时，仅在关系列中插入合法的数据非常重要。
-- 回到这里的例子，如果在products表中插入拥有非法供应商ID
-- （即没有在vendors表中出现）的供应商生产的产品，则这些产品是不可访问的，
-- 因为它们没有关联到某个供应商。为防止这种情况发生，
-- 可指示MySQL只允许在products表的供应商ID列中出现合法值（即出现在vendors表中的供应商）。
-- 这就是维护引用完整性，它是通过在表的定义中指定主键和外键来实现的。
SELECT c.cust_name
FROM customers c
    JOIN orders o ON c.cust_id = o.cust_id
    JOIN orderitems oi ON o.order_num = oi.order_num
WHERE oi.prod_id = 'TNT2';


-- 第16章 高级连接
-- 外部联结的类型 存在两种基本的外部联结形式：
-- 左外部联结和右外部联结。它们之间的唯一差别是所关联的表的顺序不同。
-- 换句话说，左外部联结可通过颠倒FROM或WHERE子句中表的顺序转换为右外部联结。
-- 因此，两种类型的外部联结可互换使用，而究竟使用哪一种纯粹是根据方便而定。
-- 与内部联结关联两个表中的行不同的是，外部联结还包括没有关联行的行。
-- 与内部联结关联两个表中的行不同的是，外部联结还包括没有关联行的行。
-- 在使用OUTER JOIN语法时，必须使用RIGHT或LEFT关键字指定包括其所有行的表
-- （RIGHT指出的是OUTER JOIN右边的表，而LEFT指出的是OUTER JOIN左边的表）。
SELECT c.cust_id, c.cust_name, o.order_date
FROM customers c
     LEFT JOIN orders o ON c.cust_id = o.cust_id



-- MySQL变量的使用
-- 在mysql文档中，mysql变量可分为两大类，即系统变量和用户变量。
-- 但根据实际应用又被细化为四种类型，即局部变量、用户变量、会话变量和全局变量。

-- 一、局部变量
-- mysql局部变量，只能用在begin/end语句块中，比如存储过程中的begin/end语句块。
-- 其作用域仅限于该语句块。

-- -- declare语句专门用于定义局部变量，可以使用default来说明默认值
-- declare age int default 0;

-- -- 局部变量的赋值方式一
-- set age=18;

-- -- 局部变量的赋值方式二
-- select StuAge
-- into age
-- from demo.student
-- where StuNo='A001';

-- 二、用户变量
-- mysql用户变量，mysql中用户变量不用提前申明，在用的时候直接用“@变量名”使用就可以了。
-- 其作用域为当前连接。

-- -- 第一种用法，使用set时可以用“=”或“:=”两种赋值符号赋值
-- set @age=19;
-- set @age:=20;

-- -- 第二种用法，使用select时必须用“:=”赋值符号赋值
-- select @age:=22;

-- select @age:=StuAge
-- from demo.student
-- where StuNo='A001';

-- 三、会话变量
-- mysql会话变量，服务器为每个连接的客户端维护一系列会话变量。
-- 其作用域仅限于当前连接，即每个连接中的会话变量是独立的。

-- -- 显示所有的会话变量
-- show session variables;

-- -- 设置会话变量的值的三种方式
-- set session auto_increment_increment=1;
-- set @@session.auto_increment_increment=2;
-- set auto_increment_increment=3;        -- 当省略session关键字时，默认缺省为session，即设置会话变量的值

-- -- 查询会话变量的值的三种方式
-- select @@auto_increment_increment;
-- select @@session.auto_increment_increment;
-- show session variables like '%auto_increment_increment%';        -- session关键字可省略

-- -- 关键字session也可用关键字local替代
-- set @@local.auto_increment_increment=1;
-- select @@local.auto_increment_increment;

-- 四、全局变量
-- mysql全局变量，全局变量影响服务器整体操作，当服务启动时，它将所有全局变量初始化为默认值。要想更改全局变量，必须具有super权限。
-- 其作用域为server的整个生命周期。

-- -- 显示所有的全局变量
-- show global variables;

-- -- 设置全局变量的值的两种方式
-- set global sql_warnings=ON;        -- global不能省略
-- set @@global.sql_warnings=OFF;

-- -- 查询全局变量的值的两种方式
-- select @@global.sql_warnings;
-- show global variables like '%sql_warnings%';
