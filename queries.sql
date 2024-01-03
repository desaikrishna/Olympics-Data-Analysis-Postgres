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


'10. Find the Ratio of male and female athletes participated in all olympic games.
Problem Statement: Write a SQL query to get the ratio of male and female participants'

with male_count as(
select count(sex) as male 
from olympics_history
where sex='M'),
female_count as(
select count(sex) as female
from olympics_history
where sex='F'),
final_ratio as (
select a.male::FLOAT/b.female as ratio
from male_count a, female_count b)
select 1, ratio from final_ratio

'11. Fetch the top 5 athletes who have won the most gold medals.
Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals'

select * from olympics_history limit 5

with gold_count as(
select athlete_name, count(medal) as medal_count
from olympics_history
where medal='Gold'
group by athlete_name
order by count(medal) desc),
dense_ranking as(
SELECT
	*,
	DENSE_RANK() OVER (ORDER BY medal_count DESC) as ranking
	from gold_count
)
select athlete_name,medal_count
from dense_ranking
where ranking <=5

'12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).'

with gold_count as(
select athlete_name, count(medal) as medal_count
from olympics_history
where medal='Gold' or medal='Silver' or medal='Bronze'
group by athlete_name
order by count(medal) desc),
dense_ranking as(
SELECT
	*,
	DENSE_RANK() OVER (ORDER BY medal_count DESC) as ranking
	from gold_count
)
select athlete_name,medal_count
from dense_ranking
where ranking <=5

'13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).'
with country_medal_country as(
select b.region, count(medal) as medal_count from olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
where medal != 'NA'
group by b.region
order by count(medal) desc),
dense_ranking as(
SELECT
	*,
	DENSE_RANK() OVER (ORDER BY medal_count DESC) as ranking
	from country_medal_country
)
select region, medal_count
from dense_ranking
where ranking<=5


'14. List down total gold, silver and bronze medals won by each country.

Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country.'

select b.region, medal,count(medal) as medal_count from olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
where medal <> 'NA'
group by b.region, medal
order by b.region, medal

select country,coalesce(gold,0) as gold,
coalesce(silver,0) as silver,
coalesce(bronze,0) as bronze
from crosstab('select b.region, medal,count(medal) as medal_count from olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
where medal <> ''NA''
group by b.region, medal
order by b.region, medal',
'values (''Bronze''),(''Gold''),(''Silver'')')  
as result (country varchar, bronze bigint, gold bigint,silver bigint)
order by gold desc, silver desc, bronze desc

'If we dont write values wrong values will be assigned to medal name columns like botswana or burundi'


'15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.'

select games, b.region, medal, count(medal) as medal_count from olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
where medal <> 'NA'
group by games,b.region, medal
order by games,b.region, medal

select games,country,coalesce(gold,0) as gold,
coalesce(silver,0) as silver,
coalesce(bronze,0) as bronze
from crosstab('select games,b.region, medal,count(medal) as medal_count from olympics_history a
join olympics_history_noc_regions b
on a.noc = b.noc
where medal <> ''NA''
group by games,b.region, medal
order by games, medal',
'values (''Bronze''),(''Gold''),(''Silver'')')  
as result (games varchar, country varchar, bronze bigint, gold bigint, silver bigint)
order by gold desc, silver desc, bronze desc


SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
                , medal
                , count(1) as total_medals
                FROM olympics_history oh
                JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
                where medal <> ''NA''
                GROUP BY games,nr.region,medal
                order BY games,medal',
            'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);
