'Create table'

create table olympics_history
(
	athlete_id int,
	athlete_name varchar,
	sex varchar,
	age varchar,
	height varchar,
	weight varchar,
	team varchar,
	noc varchar,
	games varchar,
	olympics_year varchar,
	season varchar,
	city varchar,
	sport varchar,
	sport_category varchar,
	medal varchar
);

create table olympics_history_noc_regions
(
	noc varchar,
	region varchar,
	notes varchar
);


/*3. Mention the total no of nations who participated in each olympics 
game?
Problem Statement: SQL query to fetch total no of countries participated 
in each olympic games.*/

select a.games, count(distinct(b.region)) as countOfCountries from 
olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
group by a.games;

/*--------------------------------------------------------------------------------------------------*/

/*4. Which year saw the highest and lowest no of countries participating 
in olympics
Problem Statement: Write a SQL query to return the Olympic Games which had 
the highest participating countries and the lowest participating 
countries.
*/
WITH CountryCounts AS (
    select a.games, count(distinct(b.region)) as countOfCountries from 
olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
group by a.games
)
SELECT games,countOfCountries 
from CountryCounts
where countOfCountries = (select min(countOfCountries)
						 from CountryCounts)

/*5. Which nation has participated in all of the olympic games

Problem Statement: SQL query to return the list of countries who have been 
part of every Olympics games.*/

select count(distinct(a.games)), b.region from olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
group by b.region
having count(distinct(a.games)) = (
select count(distinct(games)) from olympics_history)

with country_tot_part as(
select count(distinct(a.games)) as country_tot_part, b.region from 
olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
group by b.region
),
	tot_olm as (
	select count(distinct(games)) as tot_olm from olympics_history
)
select a.region, a.country_tot_part from country_tot_part a
join tot_olm b
on b.tot_olm = a.country_tot_part

select * from olympics_history limit 5;

/*6. Identify the sport which was played in all summer olympics.

Problem Statement: SQL query to fetch the list of all sports which have 
been part of every olympics
*/
with sport_count as (
select sport,count(distinct (games)) as counting
from olympics_history 
where season = 'Summer'
group by sport)
select sport,counting 
from sport_count where counting = (select max(counting) from sport_count )


/*7. Which Sports were just played only once in the olympics.

Problem Statement: Using SQL query, Identify the sport which were just 
played once in all of olympics.
*/
select sport,count(distinct (games)) as counting
from olympics_history 
group by sport
having count(distinct (games)) = 1
/*8. Fetch the total no of sports played in each olympic games.

Problem Statement: Write SQL query to fetch the total no of sports played 
in each olympics.
*/
select games,count(distinct(sport))
from olympics_history 
group by games

/*9. Fetch oldest athletes to win a gold medal

Problem Statement: SQL Query to fetch the details of the oldest athletes 
to win a gold medal at the olympics.
*/
with max_age as(
select athlete_name,
CASE 
	When max(age) = 'NA' then '0'
	else max(age)
end as age
from olympics_history
group by athlete_name
)
select athlete_name,age from olympics_history 
where age = (select max(age) from max_age)

select
CASE 
	When age = 'NA' then 0
	else age::INTEGER
end as age
from olympics_history
order by age desc

select * from olympics_history limit 20

select age from olympics_history where age>'50' and age < '60'
