create database zomato_project;
use zomato_project;
select * from mytable;
alter table mytable rename zomato;
select * from zomato;
-- select count(*) from zomato;
desc zomato;

-- 1. Build a country Map Table
create table country_Map as select distinct countrycode from zomato;
select * from country_Map;
alter table country_Map add column country varchar(20);
desc country_Map;
-- # n = b +
set sql_safe_updates = 0;
set autocommit = 0;
 -- # n = b +
 -- 1. Build a country Map Table
update country_Map set country = case countrycode  when   1 then   "India"
						                          when  14 then   "Australia"
                                                  when  30 then   "Brazil"
                                                  when  37 then   "Canada"
                                                  when  94 then   "Indonesia"
                                                  when  148 then   "New zealand"
                                                  when  162 then   "Phillippines"
                                                  when  166 then   "Qatar"
                                                  when  184 then   "Singapore"
                                                  when  189 then   "South Africa"
                                                  when  191 then   "Srilanka"
                                                  when  208 then   "turkey"
                                                  when  214 then   "UAE"
                                                  when  215 then   "England"
                                                  when  216 then   "USA"
												  end;
select * from country_map;

-- 2. Build a Calendar Table using the Column Datekey
CREATE TABLE calendar_table (
    date DATE NOT NULL PRIMARY KEY,
    year SMALLINT NULL,
    monthno tinyint NULL,
    monthfullname VARCHAR(15) NULL,
    quarter VARCHAR(5) NULL,
    yearmonth VARCHAR(15) NULL,
    weekdayno tinyint NULL,
    Weekdayname VARCHAR(15) NULL,
    financial_month VARCHAR(5) NULL,
    financial_quarter VARCHAR(5) NULL);

CREATE TABLE ints ( i tinyint );

INSERT INTO ints VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

INSERT INTO calendar_table (date)
SELECT DATE('2010-01-01') + INTERVAL a.i*1000 + b.i*100 + c.i*10 + d.i DAY
FROM ints a JOIN ints b JOIN ints c JOIN ints d
WHERE (a.i*1000 + b.i*100 + c.i*10 + d.i) <= 3286
ORDER BY 1;
UPDATE calendar_table SET year = YEAR(date);
UPDATE calendar_table SET monthno = MONTH(date);
UPDATE calendar_table SET monthfullname = DATE_FORMAT(date, '%M');
UPDATE calendar_table SET quarter = concat('Q',quarter(date));
UPDATE calendar_table SET yearmonth = concat(YEAR(date),'-',DATE_FORMAT(date, '%b'));
UPDATE calendar_table SET weekdayno = DAYOFWEEK(date);
UPDATE calendar_table SET weekdayname = DATE_FORMAT(date, '%W');
UPDATE calendar_table SET financial_month = 
CASE 
    WHEN MONTH(date) >= 4 THEN 'FM1'
    WHEN MONTH(date) >= 1 THEN 'FM4'
END;
UPDATE calendar_table SET financial_quarter =
CASE 
    WHEN MONTH(date) BETWEEN 1 AND 3 THEN 'FQ4'
    WHEN MONTH(date) BETWEEN 4 AND 6 THEN 'FQ1'
    WHEN MONTH(date) BETWEEN 7 AND 9 THEN 'FQ2'
    WHEN MONTH(date) BETWEEN 10 AND 12 THEN'FQ3'
END;
select * from calendar_table;

-- 3.Find the Numbers of Resturants based on City and Country.
select country,city,count(RestaurantID) as No_of_Restaurants from country_map 
 join
zomato  using(countrycode) group by city,country;
-- 4.Numbers of Resturants opening based on Year , Quarter , Month
select count(restaurantid) as No_of_Restaurants,Year,Quarter,Monthfullname as Month from zomato
join
calendar_table on zomato.Datekey_Opening=calendar_table.date group by year,quarter,month;
-- 5. Count of Resturants based on Average Ratings
select  rating,count(RestaurantID) as No_of_restaurants from  zomato group by rating;
create table currency_table(
Currency varchar(30),
Exchange_rate double);
insert into currency_table values("Indian Rupees(Rs.)",0.012),("Dollar($)",1),
("Pounds(Œ£)",1.22),("NewZealand($)",0.63),("Emirati Diram(AED)",0.27),
("Brazilian Real(R$)",0.19),("Turkish Lira(TL)",0.053),("Qatari Rial(QR)",0.27),
("Rand(R)",0.054),("Botswana Pula(P)",0.076),("Sri Lankan Rupee(LKR)",0.003),
("Indonesian Rupiah(IDR)",0.000065);
select * from currency_table;

select * , (Average_Cost_for_two * Exchange_rate) as Cost_in_USD from zomato
join
currency_table using(currency);
-- 6. Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
create view buckets as select * , (Average_Cost_for_two * Exchange_rate) as Cost_in_USD,
case when (Average_Cost_for_two * Exchange_rate)>=0 and (Average_Cost_for_two * Exchange_rate) <=10 then '[0-10]'
when (Average_Cost_for_two * Exchange_rate)>10 and (Average_Cost_for_two * Exchange_rate) <=20 then '[11-20]'
when (Average_Cost_for_two * Exchange_rate)>20 and (Average_Cost_for_two * Exchange_rate) <=30 then '[21-30]'
when (Average_Cost_for_two * Exchange_rate)>30 and (Average_Cost_for_two * Exchange_rate) <=40 then '[31-40]'
when (Average_Cost_for_two * Exchange_rate)>40 and (Average_Cost_for_two * Exchange_rate) <=50 then '[41-50]'
else 'Above 50'
end as Cost_Bin
 from zomato
join
currency_table using(currency);
select count(restaurantid) as No_of_Restaurants,Cost_Bin from buckets group by Cost_Bin;
 -- # n = b +
-- 7.Percentage of Resturants based on "Has_Table_booking"
set @v1 = (select count(*) from zomato);
select @v1;
select Has_Table_booking,((count(Has_Table_booking)/@v1)*100) as percent_of_Table_booking  
from zomato group by Has_Table_booking;

-- 8.Percentage of Resturants based on "Has_Online_delivery"
select Has_Online_delivery,((count(Has_Online_delivery)/@v1)*100) as percent_of_Online_delivery
from zomato group by Has_Online_delivery;
