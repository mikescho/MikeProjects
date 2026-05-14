select * from bakers_raw limit 5
;


-- get rid of letters in season --
select trim(regexp_replace(season, '[A-Za-z]','')) from bakers_raw;




create table bakers_edits as 
select trim(regexp_replace(season, '[A-Za-z]','')) as season,
baker, age, gender, notes from bakers_raw
;

select * from
bakers_edits
;

alter table bakers_edits
add column baker_cleaned text
;


-- get rid of spaces in baker --
update bakers_edits
set baker_cleaned = trim(baker)
where 1=1
;


select * from bakers_edits
;

alter table bakers_edits
drop baker;

select * from bakers_edits
;

select * from challenge_bakes_raw
;


create table challenge_bakes_edits as select * from challenge_bakes_raw;

select * from challenge_bakes_edits;

alter table challenge_bakes_edits
add column rank_edit text
;


-- remove letters from rank in technical --
update challenge_bakes_edits
set rank_edit = regexp_replace(rank_in_technical,'[A-Za-z]',"")
where 1=1
;


select * from challenge_bakes_edits;

alter table challenge_bakes_edits
drop column rank_in_technical
;


select distinct(rank_edit) from challenge_bakes_edits
;



select * from episodes_raw
;


create table episodes_edits as 
select * from episodes_raw
;

alter table episodes_edits
add column my_rating_edit text;


-- remove /10 from my_rating --
update episodes_edits
set my_rating_edit = replace(my_rating,"/10","")
where 1=1
;

alter table episodes_edits
drop column my_rating
;


select * from episodes_edits
;

select distinct(safe) from outcomes_raw;


drop table outcomes_edits;


create table outcomes_edits as 
select * from outcomes_raw
;

alter table outcomes_edits
add column safe_edits text
;


use st_522;
select * from outcomes_edits
;


-- change safe to be all 1s or 0s depending on True/False/y/n --
UPDATE outcomes_edits
SET safe_edits =
  CASE
    WHEN LOWER(TRIM(safe)) IN ('0', 'false', 'no', 'n') THEN 0
    WHEN LOWER(TRIM(safe)) IN ('1', 'true', 'yes', 'y') THEN 1
    ELSE NULL 
  END;

alter table outcomes_edits
drop column safe
;

select * from outcomes_edits;



alter table outcomes_edits
add column baker_edits text;


-- changing baker so it has a first capital and then lower case --
update outcomes_edits
set baker_edits = trim(concat(upper(left(baker,1)),lower(substring(baker,2))))
;


select * from outcomes_edits
;

alter table outcomes_edits
drop column baker;


alter table outcomes_edits
add column season_episode_edits text
;


-- setting all to lower for season_episode so we can compare them -- 
update outcomes_edits
set season_episode_edits = lower(season_episode)
;

select * from outcomes_edits;

alter table outcomes_edits
drop column season_episode
;

select distinct star_baker from outcomes_edits
;

alter table outcomes_edits
add column star_baker_edits text;


-- changing star_baker to be all 0s or 1s --
update outcomes_edits
set star_baker_edits = case when lower(trim(star_baker)) in ('0','false','n','no') then 0 when lower(trim(star_baker)) in ('1','y','yes','true') then 1 else null end;
;

select distinct star_baker, star_baker_edits
from outcomes_edits
;

alter table outcomes_edits
drop column star_baker;

select * from outcomes_edits;


select distinct eliminated from outcomes_edits
;

alter table outcomes_edits
add column eliminated_edits text;


-- changing eliminated to be all 0s or 1s -- 
update outcomes_edits
set eliminated_edits = case when trim(lower(eliminated)) in ('0','false','n','no') then 0 when trim(lower(eliminated)) in ('1','y','true','yes') then 1 else null end;

select distinct eliminated, eliminated_edits
from outcomes_edits;

alter table outcomes_edits
drop eliminated;

select * from outcomes_edits
;

select distinct did_well from outcomes_edits
;

alter table outcomes_edits
add column did_well_edits text
;


-- cleaning up did_well to be all 1s or 0s --
update outcomes_edits
set did_well_edits = case when trim(lower(did_well)) in ('1','yes','true','y') then 1 when trim(lower(did_well)) in ('0','no','n','false') then 0 else null end;

select distinct did_well, did_well_edits from outcomes_edits
;

alter table outcomes_edits
drop column did_well
;

select * from outcomes_edits
;

select distinct at_risk from outcomes_edits
;

alter table outcomes_edits
add column at_risk_edits text
;

-- updating at_risk to be all 0s or 1s -- 
update outcomes_edits
set at_risk_edits = case when trim(lower(at_risk)) in ('0','n','no','false') then 0 when trim(lower(at_risk)) in ('1','y','yes','true') then 1 else null end;

select distinct at_risk, at_risk_edits
from outcomes_edits
;

alter table outcomes_edits
drop column at_risk
;

select distinct handshake from outcomes_edits
;

alter table outcomes_edits
add column handshake_edits text;


-- changing handshake to be either 0 or 1 only -- 
update outcomes_edits
set handshake_edits = case when trim(lower(handshake)) in ('0','n','no','false') then 0 when trim(lower(handshake)) in ('1','y','yes','true') then 1 else null end;

select distinct handshake, handshake_edits
from outcomes_edits
;

alter table outcomes_edits
drop handshake
;

select * from outcomes_edits
where absent = '0'
;

-------- ask about the absent one bc I can't tell what it's supposed to be ------- 

select *
from outcomes_edits
where absent = ''
;


-- drop absent column -- 
alter table outcomes_edits
drop absent;

-- rename columns and change types to int -- 

select * from
outcomes_edits
;

alter table outcomes_edits
change safe_edits safe int ;

alter table outcomes_edits
change star_baker_edits star_baker int
;

alter table outcomes_edits
change baker_edits baker text;

alter table outcomes_edits
change season_episode_edits season_episode text;


alter table outcomes_edits
change eliminated_edits eliminated int;

select * from outcomes_edits;

alter table outcomes_edits
change did_well_edits did_well int;

alter table outcomes_edits 
change at_risk_edits at_risk int
;

alter table outcomes_edits
change handshake_edits handshake int
;


-- break up season and episode in case we need it later -- 
alter table outcomes_edits
add column season int,
add column episode int;

select * from outcomes_edits;



UPDATE outcomes_edits
SET 
    season = CAST(SUBSTRING_INDEX(SUBSTRING(season_episode, 2), 'e', 1) AS UNSIGNED),
    episode = CAST(SUBSTRING_INDEX(season_episode, 'e', -1) AS UNSIGNED);


alter table outcomes_edits
rename to outcomes;


select * from outcomes;

-- DONE WITH OUTCOMES !!! --

-- changing age in bakers so it's an int and remove letters but leave nulls in because age might not be important -- 

select * from bakers_edits
;

alter table bakers_edits
add column age_cleaned int null;


update bakers_edits
set age_cleaned = case when age = '' then null else regexp_replace(age,'[A-Za-z]','') end;

select distinct notes from bakers_edits
;


-- changing notes so it's a zero or 1 (defaulted blanks to 0) -- 

alter table bakers_edits
add column notes_edits int null;

update bakers_edits
set notes_edits = case when trim(lower(notes)) in ('no','n', '') then 0 when trim(lower(notes)) in ('yes','y') then 1 else null end;

select distinct notes_edits,
notes from bakers_edits
;


select distinct gender from bakers_edits
;

alter table bakers_edits
add column gender_edits text;

-- change gender to all be M/F not different things -- 

update bakers_edits
set gender_edits = case when lower(gender) in ('male','m') then 'M' else 'F' end;

select * 
from bakers_edits
;

alter table bakers_edits
drop column age,
drop column gender,
drop column notes
;

alter table bakers_edits
change baker_cleaned baker text;

alter table bakers_edits
change age_cleaned age int;

alter table bakers_edits
change notes_edits notes int;

alter table bakers_edits
change gender_edits gender text;


alter table bakers_edits
rename to bakers;

select * from bakers
;

-- DONE WITH BAKERS -- 

select * from challenge_bakes_edits
;

alter table challenge_bakes_edits
add column baker_edits text;


-- update bakers to first initial capital then all lower to match the rest -- 
update challenge_bakes_edits
set baker_edits = 
trim(concat(upper(left(baker,1)), lower(substring(baker,2))))
;


-- make season_episode be lowercase to match others and convert when it says 9-10 to s9e10 for example-- 
alter table challenge_bakes_edits
add column season_episode_edits text;

update challenge_bakes_edits
set season_episode_edits =
trim(lower(season_episode));


select distinct season_episode_edits from challenge_bakes_edits
where season_episode_edits not like 's%'
;


alter table challenge_bakes_edits
add column season_episode_edits_2 text;

update challenge_bakes_edits
set season_episode_edits_2 = 
case when season_episode_edits like 's%' then season_episode_edits
else concat('s',substring_index(season_episode_edits,'-',1),'e',substring_index(season_episode_edits,'-',-1)) end
;

select distinct season_episode_edits_2
from challenge_bakes_edits
;

select * from challenge_bakes_edits
;


alter table challenge_bakes_edits
drop season_episode_edits
;

-- altering status so they're all the same -- 
select distinct status from challenge_bakes_edits
;

alter table challenge_bakes_edits
add column status_edits text;

update challenge_bakes_edits
set status_edits = 
case when 
status = 'Did well' then 'Did well'
when status = 'Eliminated' then 'Eliminated'
when status = 'Safe' then 'Safe'
when status = 'At risk' then 'At risk'
when status = 'Star-Baker' then 'Star Baker'
when status = 'elim.' then 'Eliminated'
when status = 'S' then 'Safe'
when status = 'Atrisk' then 'At risk'
when status = 'Star Baker' then 'Star Baker'
when status = 'Safe ' then 'Safe'
when status = 'Winner' then 'Winner'
when status = 'Runner-up' then 'Runner Up'
when status = 'Elim' then 'Eliminated'
when status = 'Didwell' then 'Did well'
when status = 'Runner up' then 'Runner Up'
else 'did not find match' end
;

select distinct status_edits from challenge_bakes_edits
;

select * from challenge_bakes_edits
;

alter table challenge_bakes_edits
drop column baker;

alter table challenge_bakes_edits
drop column season_episode;

alter table challenge_bakes_edits
drop column status;


select * from challenge_bakes_edits
;

alter table challenge_bakes_edits
modify episode int,
modify season int;

alter table challenge_bakes_edits
change rank_edit rank_in_technical int;

alter table challenge_bakes_edits
change baker_edits baker text;

alter table challenge_bakes_edits
change season_episode_edits_2 season_episode text;

alter table challenge_bakes_edits
change status_edits status text;


-- changeing all blanks to nulls in showstopper and signature -- 
alter table challenge_bakes_edits
add column showstopper_blank text,
add column signature_blank text;

update challenge_bakes_edits
set showstopper_blank = case when showstopper = '' then null else showstopper end;

update challenge_bakes_edits
set signature_blank = case when signature = '' then null else signature end;

select * from challenge_bakes_edits
;

alter table challenge_bakes_edits
drop column showstopper, drop column signature;

alter table challenge_bakes_edits
change showstopper_blank showstopper text,
change signature_blank signature text
;

select * from challenge_bakes_edits
;



-- done with challenge bakes -- 

alter table challenge_bakes_edits
rename challenge_bakes
;

-- seasons and episodes left -- 

select * from seasons_raw
;

-- seasons -- 

create table seasons_edits
as select * from seasons_raw
;

select * from seasons_edits
;

-- change network so that it is all the same rather than BBC2 and BBC two -- 

select distinct network from seasons_edits
;

alter table seasons_edits
add column network_edits text
;

update seasons_edits
set network_edits = case when network =
'BBC Two' then 'BBC Two'
when network = 'BBC Two ' then 'BBC Two'
when network = 'BBC 2' then 'BBC Two'
when network = 'BBC 1' then 'BBC One'
when network = 'bbc one' then 'BBC One'
when network = 'Channel 4' then 'Channel 4'
when network = 'Ch4' then 'Channel 4' when network =
'Channel4' then 'Channel 4' else 'not found' end
;

alter table seasons_edits
add column winner_edits text;

select * from seasons_edits;
-- change name of winner to first initial capital, all others lower to match other tables --


update seasons_edits
set winner_edits = concat(upper(left(trim(winner),1)),lower(substring(trim(winner),2)))
;


-- update locations to all match since some left out UK
select distinct location from seasons_edits
;

alter table seasons_edits
add column location_edits text;



select location,substring_index(location,',',-1)
from seasons_edits
;

update seasons_edits
set location_edits = case when substring_index(location,',',-1) = 'UK' then location
else concat(location, ', UK') end
;

update seasons_edits
set location_edits = 
concat(substring_index(location,', UK',1),', UK')
;

select distinct
location_edits
from seasons_edits
;

alter table seasons_edits
drop column location
;

alter table seasons_edits
change location_edits location text;


-- changing netflix_collection to be null if not available -- 
select distinct netflix_collection from seasons_edits
;

alter table seasons_edits
add column netflix_collection_edits text;

update seasons_edits
set netflix_collection_edits = case when netflix_collection like 'Coll%' then netflix_collection
else null end;


select * from seasons_edits
;


-- changing pbs_season to be nulls when blank -- 

select distinct pbs_season
from seasons_edits
;

alter table seasons_edits
add column pbs_season_edits text
;

update seasons_edits
set pbs_season_edits = case when pbs_season like 'Season%' then pbs_season
else null end
;

select * from seasons_edits
;

-- changing roku season to null when not available -- 

alter table seasons_edits
add column roku_season_edits text;

select distinct roku_season from seasons_edits;


update seasons_edits
set roku_season_edits = case when roku_season like 'Seas%' then roku_season
else null end;

select * from seasons_edits
;

alter table seasons_edits
drop column network, drop column winner, drop column netflix_collection, drop column pbs_season, drop column roku_season
;

select * from seasons_edits
;

alter table seasons_edits
change network_edits network text;

alter table seasons_edits
change winner_edits winner text;

alter table seasons_edits
change netflix_collection_edits netflix_collection text;

alter table seasons_edits
change pbs_season_edits pbs_season text;

alter table seasons_edits change roku_season_edits roku_season text;

select * from seasons_edits
;

alter table seasons_edits
change season season int;



-- done with season -- 



alter table seasons_edits
rename  seasons;


-- have to fix date to all match -- 

select * from episodes_edits;

alter table episodes_edits
add column airdate_edits date;

update episodes_edits
set airdate_edits = 
 CASE
    WHEN airdate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      THEN STR_TO_DATE(airdate, '%Y-%m-%d')

    WHEN airdate REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
      THEN STR_TO_DATE(airdate, '%d/%m/%Y')

    WHEN airdate REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
      THEN STR_TO_DATE(airdate, '%d-%m-%Y')

    WHEN airdate REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$'
      THEN STR_TO_DATE(airdate, '%M %d, %Y')

    ELSE NULL end
;

select distinct episode from episodes_edits
;

-- have to fix episode to not have letters in it -- 

alter table episodes_edits
add column episode_edits int;

select episode,
regexp_replace(episode,"[A-Za-z]+","")
from episodes_edits
;

update episodes_edits
set episode_edits = 
regexp_replace(episode,'[A-Za-z]+',"")
;

select * from episodes_edits
;

-- have to change blanks to null for theme -- 
select distinct theme from episodes_edits
;

alter table episodes_edits
add column theme_edits text
;

update episodes_edits
set theme_edits = 
case when trim(theme) = '' then null else theme end;

select distinct theme_edits
from episodes_edits
;

-- have to change signature time min to no negatives (obviously) and remove all letters --

select signature_time_min,
replace(regexp_replace(signature_time_min,"[A-Za-z]+",""),"-","")
from episodes_edits
;

alter table episodes_edits
add column signature_time_min_edits int;

update episodes_edits
set signature_time_min_edits = 
replace(regexp_replace(signature_time_min,"[A-Za-z]+",""),"-","");

select signature_time_min_edits
from episodes_edits
;


-- have to fix creme brulee since it was messed up in technical_challenge --
select distinct technical_challenge from episodes_edits
;

alter table episodes_edits
add column technical_challenge_edits text;


select distinct technical_challenge 
from episodes_edits
where technical_challenge like '%©%'
;


update episodes_edits
set technical_challenge_edits = 
case when technical_challenge like '%©%' then 'Creme Brulee' else technical_challenge end
;

select distinct technical_challenge_edits
from episodes_edits
;


-- have to remove M and m from my_viewership to add/subtract --

alter table episodes_edits
modify my_viewership_edits decimal(15,2);


UPDATE episodes_edits
SET my_viewership_edits = CAST(
    TRIM(REGEXP_REPLACE(my_viewership, '[^0-9.]', '')) AS DECIMAL(15,2)
)
WHERE my_viewership IS NOT NULL;


select * from episodes_edits
;

alter table episodes_edits
drop column airdate, drop column episode, drop column theme, drop column signature_time_min, drop column technical_challenge, drop column my_viewership
;

alter table episodes_edits
rename column my_rating_edit to my_rating,
rename column airdate_edits to airdate,
rename column episode_edits to episode,
rename column theme_edits to theme,
rename column signature_time_min_edits to signature_time_min,
rename column technical_challenge_edits to technical_challenge,
rename column my_viewership_edits to my_viewership;


select * from episodes_edits
;

alter table episodes_edits
modify column season int,
modify column technical_time_min int,
modify column showstopper_time_min int,
modify column my_rating decimal(10,2),
modify column episode int,
modify column signature_time_min int,
modify column my_viewership decimal(10,2)
;

use st_522;

alter table episodes_edits
rename to episodes
;




select column_name, table_name, data_type from information_schema.columns
where table_schema = 'st_522' and table_name not like '%raw%'
order by column_name asc, table_name asc;


select season
from bakers;

alter table bakers
modify column season int;

select year from seasons
;

use st_522;
select column_name, table_name, data_type from information_schema.columns
where table_schema = 'st_522' and table_name not like '%raw%'
order by column_name asc, table_name asc;


select distinct column_name, data_type
from information_schema.columns 
where table_schema = 'st_522' and table_name not like '%raw%'
;


select * from 
episodes e 
left join 
challenge_bakes cb
on e.episode = cb.episode
and e.season = cb.season
limit 5
;


use st_522;



drop temporary table rank_lag;


create temporary table rank_lag as 
select episode, season, baker, difference from(
select episode, season, rank_in_technical, baker,
lag(rank_in_technical) over (partition by baker,season order by episode asc ) as prior_rank_ep,
-1 * (rank_in_technical - lag(rank_in_technical) over (partition by baker,season order by episode asc )) as difference
 from challenge_bakes
 order by baker,
 season, episode) c
;


select * from rank_lag;




create temporary table season_avg_diff_rank as (
select season, baker, avg(difference) as season_avg_baker from rank_lag
group by 1,2) ;







with t as (
select r.episode, r.season, r.baker, r.difference, o.eliminated, sa.season_avg_baker from rank_lag r
left join outcomes o
on o.episode = r.episode and o.season = r.season and o.baker = r.baker
left join season_avg_diff_rank sa on r.season = sa.season and r.baker = sa.baker
where eliminated = 1
order by r.baker, r.episode, r.season) 
select sum(case when t.difference < 0 then 1 else 0 end) as total_declining,
sum(case when t.difference > 0 then 1 else 0 end) as total_increasing,
sum(case when t.difference = 0 then 1 else 0 end) as total_same from t;

with t as (
select r.episode, r.season, r.baker, r.difference, o.eliminated, sa.season_avg_baker from rank_lag r
left join outcomes o
on o.episode = r.episode and o.season = r.season and o.baker = r.baker
left join season_avg_diff_rank sa on r.season = sa.season and r.baker = sa.baker
where eliminated = 1
order by r.baker, r.episode, r.season) 
select sum(case when t.difference < t.season_avg_baker then 1 else 0 end) as less_than_season_avg,
sum(case when t.difference > t.season_avg_baker then 1 else 0 end) as more_than_season_avg,
sum(case when t.difference = t.season_avg_baker then 1 else 0 end) as total_same_as_season_avg from t;


select cb.season, cb.episode, status, cb.baker, difference, b.age, b.gender from challenge_bakes cb
join rank_lag r on cb.baker = r.baker and cb.season = r.season and cb.episode = r.episode
join bakers b on cb.baker = b.baker
where status in ('Winner');

create temporary table season_final_ep as 
with t as (
select distinct season, episode, ranking_ from (
select season, episode, dense_rank() over (partition by season order by episode asc) as ranking_ from challenge_bakes) a
)
select season, max(ranking_)
from t
group by 1
;



select * from season_final_ep;

ALTER TABLE season_final_ep
RENAME COLUMN `max(ranking_)` TO max_ep;

with t as (
select r.episode, r.season, r.baker, r.difference, o.eliminated, sa.season_avg_baker from rank_lag r
left join season_final_ep sf on r.episode = sf.max_ep
and r.season = sf.season
left join outcomes o
on o.episode = r.episode and o.season = r.season and o.baker = r.baker
left join season_avg_diff_rank sa on r.season = sa.season and r.baker = sa.baker
where r.episode = sf.max_ep and r.season = sf.season
order by r.baker, r.episode, r.season) 
select sum(case when t.difference < 0 then 1 else 0 end) as total_declining,
sum(case when t.difference > 0 then 1 else 0 end) as total_increasing,
sum(case when t.difference = 0 then 1 else 0 end) as total_same from t;


with t as (
select r.episode, r.season, r.baker, r.difference, o.eliminated, sa.season_avg_baker, sf.max_ep, sf.season as finalseason from rank_lag r
left join season_final_ep sf on r.episode = sf.max_ep
and r.season = sf.season
left join outcomes o
on o.episode = r.episode and o.season = r.season and o.baker = r.baker
left join season_avg_diff_rank sa on r.season = sa.season and r.baker = sa.baker
order by r.baker, r.episode, r.season) 
select * from t;


select * from season_final_ep;





-- 1 A: Find lagged variable of rank_in_technical from prior episode if possible and compute difference -- 
create temporary table rank_lag as 
select episode, season, baker, difference from(
select episode, season, rank_in_technical, baker,
lag(rank_in_technical) over (partition by baker,season order by episode asc ) as prior_rank_ep,
-1 * (rank_in_technical - lag(rank_in_technical) over (partition by baker,season order by episode asc )) as difference
 from challenge_bakes
 order by baker,
 season, episode) c
;

select * from rank_lag;

-- 1 B -- 


-- step 1: create season average of lagged variable -- 
create temporary table season_avg_lag as 
select baker, season, avg(difference) as average_season_lag
from rank_lag
group by 1,2
;


select * from season_avg_lag;


-- step 3 : find all eliminations and get current incline/decline and season avg lag -- 

-- important: dropped out people that got knocked out the first episode, since this wasn't helpful since we couldn't compute any lagged variables anyway -- 

with t as (
select cb.episode, cb.season, cb.rank_in_technical, cb.baker, sal.average_season_lag as avg_season, rl.difference as episode_diff from challenge_bakes cb
left join season_avg_lag sal on cb.baker = sal.baker and cb.season = sal.season
left join rank_lag rl on rl.baker = cb.baker and cb.season = rl.season and cb.episode = rl.episode
where status = 'Eliminated' and cb.episode != 1
order by baker, season,episode
)
select sum(case when episode_diff < 0 then 1 end) as declining,
sum(case when episode_diff = 0 then 1 end) as no_prior_change,
sum(case when episode_diff > 0 then 1 end) as improving,
sum(case when episode_diff > avg_season then 1 end) as better_than_season_avg,
sum(case when episode_diff < avg_season then 1 end) as worse_than_season_avg,
sum(case when episode_diff = avg_season then 1 end) as same_as_season_avg
from t
;


-- part 4: find who made it to the final and if they were declining/increasing lagged var and their age + gender --



-- assume the last episode is the final -- 
create temporary table last_episode as
select season, max(episode) as last_ep from episodes
group by 1
;


drop table final_;


create temporary table final_ as 

select cb.episode, cb.season, cb.baker, cb.status, rl.difference, sal.average_season_lag, b.gender, b.age from challenge_bakes cb
left join rank_lag rl 
on cb.season = rl.season and cb.episode = rl.episode and cb.baker = rl.baker
join last_episode le
on le.last_ep = cb.episode 
and le.season = cb.season
left join season_avg_lag sal
on cb.baker = sal.baker and cb.season = sal.season
left join bakers b
on cb.baker = b.baker and cb.season = b.season
;


-- reused this code a lot -- 

with t as (
select count(*) as count,
gender,
age,
case when difference > 0 then 'increasing' when difference < 0 then 'decreasing' when difference = 0 then 'same as last ep' else null end as changes,
case when average_season_lag > 0 then 'positive' when average_season_lag < 0 then 'negative' when average_season_lag = 0 then 'zero' else null end as season_avg
 from final_
 group by 2,3,4,5)
select sum(count),
gender
from t
group by 2
 ;
 

select count(*) as count,
case when difference < average_season_lag then 'less than season avg' when difference > average_season_lag then 'gt season avg' else 'equal to season avg' end as comp
from final_
group by 2
;


select * from final_
order by baker, season, episode
;


use st_522;

create temporary table age_look as (
with t as (
select baker, season, max(episode) as max_episode from challenge_bakes
group by 1,2)
select t.baker, t.season, t.max_episode, case when t.max_episode = l.last_ep then 1 else 0 end as last_ep_check, b.age, b.gender
from t
left join last_episode l on t.season = l.season and l.last_ep = t.max_episode
left join bakers b on t.baker = b.baker and t.season = b.season
where age is not null
)
;


select a.baker, a.season, a.max_episode, a.last_ep_check, a.age, a.gender, cb.status from age_look a
left join (select * from challenge_bakes) cb
on a.season = cb.season and a.max_episode = cb.episode and cb.baker = a.baker
;


select *
from challenge_bakes
limit 5;

select status, episode, season, baker
from challenge_bakes
;






select baker, season, max(episode) as max_episode from challenge_bakes
group by 1,2;

-- Check duplicates in bakers
select *
from bakers
where baker = 'David'
;

-- fixing David issue --
create table bakers_fixed as 
select distinct * from bakers
;

drop table bakers
;

alter table bakers_fixed
rename to bakers;





select * from challenge_bakes
where status = 'Eliminated'
and episode != 1
;



select * from challenge_bakes
where baker = 'Tim'
;



use st_522;

select distinct season from bakers_raw;







select distinct my_rating from episodes_og_csv
;



-- chad's code for analysis: NOTE he used postgreSQL so things may be a bit different -- 
/* GBBO ANALYSIS SCRIPT
   Task: Investigating the impact of Star Baker timing on winning the competition.
*/

---------------------------------------------------------
-- 1. WEIGHTED STAR BAKER RANKINGS
---------------------------------------------------------
WITH SeasonMax AS (
    SELECT season, MAX(episode) as total_eps
    FROM outcomes
    GROUP BY season
),
WeightedWins AS (
    SELECT 
        o.season, 
        o.baker, 
        o.episode,
        CAST(o.episode AS FLOAT) / sm.total_eps AS win_weight
    FROM outcomes o
    JOIN SeasonMax sm ON o.season = sm.season
    WHERE o.star_baker = 1
),
BakerAggregates AS (
    SELECT 
        season, 
        baker, 
        SUM(win_weight) as total_weighted_score,
        COUNT(*) as total_wins
    FROM WeightedWins
    GROUP BY season, baker
)
SELECT 
    season, 
    baker, 
    ROUND(CAST(total_weighted_score AS NUMERIC), 3) as weighted_score,
    total_wins,
    RANK() OVER(PARTITION BY season ORDER BY total_weighted_score DESC) as sb_rank
FROM BakerAggregates
ORDER BY season, sb_rank;


---------------------------------------------------------
-- 2. FINALIST PROPORTIONS (EARLY VS LATE WINNERS)
---------------------------------------------------------
WITH SeasonFinals AS (
    SELECT season, MAX(episode) as final_ep FROM outcomes GROUP BY season
),
BakerStats AS (
    SELECT 
        o.baker, 
        o.season,
        MAX(CASE WHEN o.episode = sf.final_ep THEN 1 ELSE 0 END) as reached_final,
        MAX(CASE WHEN o.star_baker = 1 AND (CAST(o.episode AS FLOAT)/sf.final_ep) <= 0.5 THEN 1 ELSE 0 END) as won_early,
        MAX(CASE WHEN o.star_baker = 1 AND (CAST(o.episode AS FLOAT)/sf.final_ep) > 0.5 THEN 1 ELSE 0 END) as won_late
    FROM outcomes o
    JOIN SeasonFinals sf ON o.season = sf.season
    GROUP BY o.baker, o.season
)
SELECT 
    CASE 
        WHEN won_early = 1 AND won_late = 1 THEN 'Both Early & Late'
        WHEN won_early = 1 THEN 'Early Only'
        WHEN won_late = 1 THEN 'Late Only'
    END as win_timing,
    COUNT(*) as total_bakers,
    SUM(reached_final) as reached_final_count,
    ROUND(AVG(reached_final) * 100, 2) || '%' as final_reach_rate
FROM BakerStats bs
JOIN bakers b ON bs.baker = b.baker AND bs.season = b.season
WHERE won_early = 1 OR won_late = 1
GROUP BY 1;


---------------------------------------------------------
-- 3. WINNERS WITH ZERO STAR BAKER WINS
---------------------------------------------------------
WITH SeasonWinner AS (
    SELECT DISTINCT season, baker
    FROM challenge_bakes
    WHERE status = 'Winner'
),
StarBakerTotals AS (
    SELECT season, baker, SUM(star_baker) as sb_wins
    FROM outcomes
    GROUP BY season, baker
),
SeasonMetadata AS (
    SELECT season, year, network, STRING_AGG(DISTINCT judge, ' & ') as judges
    FROM seasons
    GROUP BY season, year, network
)
SELECT 
    sw.season, 
    sw.baker as winner_name, 
    sm.year, 
    sm.network, 
    sm.judges
FROM SeasonWinner sw
JOIN StarBakerTotals sbt ON sw.season = sbt.season AND sw.baker = sbt.baker
JOIN SeasonMetadata sm ON sw.season = sm.season
WHERE sbt.sb_wins = 0;

/* GBBO ANALYSIS SCRIPT
   Task: The Era Divide - Viewership & Ratings by Network
   Deliverable: Comparing external BARB viewership data across BBC Two, BBC One, and Channel 4.
*/

WITH CorrectedNetworks AS (
    SELECT 
        series,
        episode,
        viewers_7day,
        viewers_28day,
        -- Bypassing the faulty Seasons table to ensure historical accuracy
        CASE 
            WHEN series BETWEEN 1 AND 4 THEN 'BBC Two'
            WHEN series BETWEEN 5 AND 7 THEN 'BBC One'
            WHEN series >= 8 THEN 'Channel 4'
        END AS fixed_network
    FROM ratings_seasons
)
SELECT 
    fixed_network AS network,
    COUNT(DISTINCT series) AS total_seasons_aired,
    COUNT(episode) AS total_episodes_aired,
    ROUND(AVG(viewers_7day), 2) AS avg_7_day_viewers_millions,
    ROUND(AVG(viewers_28day), 2) AS avg_28_day_viewers_millions,
    MAX(viewers_7day) AS peak_7_day_viewers_millions
FROM CorrectedNetworks
GROUP BY fixed_network
ORDER BY 
    CASE 
        WHEN fixed_network = 'BBC Two' THEN 1
        WHEN fixed_network = 'BBC One' THEN 2
        WHEN fixed_network = 'Channel 4' THEN 3
    END;
    
   /* GBBO ANALYSIS SCRIPT
   Task: The Era Divide (BBC vs Channel 4)
   Deliverable: Comparing viewership and competition patterns across eras.
*/

---------------------------------------------------------
-- 1. DEFINING THE ERAS (CTE used across queries)
---------------------------------------------------------
-- The Seasons table contains multiple rows per season if hosts/judges change.
-- We use DISTINCT to safely get one era label per season.
CREATE OR REPLACE VIEW era_mapping AS
SELECT DISTINCT 
    season, 
    CASE 
        WHEN network LIKE '%BBC%' THEN 'BBC Era'
        ELSE 'Channel 4 Era' 
    END AS broadcast_era
FROM seasons;


---------------------------------------------------------
-- 2. EXTERNAL DATA: The Commercial Impact of the Era Switch
---------------------------------------------------------
-- Did the network change hurt the ratings?
SELECT 
    e.broadcast_era,
    COUNT(DISTINCT r.series) AS total_seasons_aired,
    COUNT(r.episode) AS total_episodes_aired,
    ROUND(AVG(r.viewers_7day), 2) AS avg_7_day_viewers_millions,
    MAX(r.viewers_7day) AS peak_viewership_millions
FROM ratings_seasons r
JOIN era_mapping e ON r.series = e.season
GROUP BY e.broadcast_era
ORDER BY avg_7_day_viewers_millions DESC;


---------------------------------------------------------
-- 3. COMPETITION PATTERNS: Does winning Star Baker matter more in C4?
---------------------------------------------------------
-- Are Channel 4 judges stricter? Do C4 winners dominate more than BBC winners?
WITH SeasonWinners AS (
    -- Find the ultimate winner of each season
    SELECT DISTINCT season, baker
    FROM challenge_bakes
    WHERE status = 'Winner'
),
WinnerStarBakers AS (
    -- Count how many Star Baker awards the ultimate winner received during their season
    SELECT 
        w.season, 
        w.baker, 
        COALESCE(SUM(o.star_baker), 0) as star_baker_wins
    FROM SeasonWinners w
    LEFT JOIN outcomes o ON w.season = o.season AND w.baker = o.baker
    GROUP BY w.season, w.baker
)
SELECT 
    e.broadcast_era,
    COUNT(w.season) as seasons_in_data,
    ROUND(AVG(w.star_baker_wins), 2) as avg_star_bakers_for_ultimate_winner,
    MIN(w.star_baker_wins) as fewest_sb_wins_by_a_champion,
    MAX(w.star_baker_wins) as most_sb_wins_by_a_champion
FROM WinnerStarBakers w
JOIN era_mapping e ON w.season = e.season
GROUP BY e.broadcast_era; 
    
    








