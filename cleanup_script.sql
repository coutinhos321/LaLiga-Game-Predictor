-- standardize the column values across the tables
update laliga_matches 
set HomeTeam = 'Athletico Madrid'
where HomeTeam = 'Athletic Madrid';
update laliga_matches 
set HomeTeam = 'Athletic Club'
where HomeTeam = 'Ath Bilbao';
update laliga_matches 
set HomeTeam = 'Real Betis'
where HomeTeam = 'Betis';
update laliga_matches 
set HomeTeam = 'Celta Vigo'
where HomeTeam = 'Celta';
update laliga_matches 
set HomeTeam = 'Real Sociedad'
where HomeTeam = 'Sociedad';
update laliga_matches 
set HomeTeam = 'Rayo Vallecano'
where HomeTeam = 'Vallecano';

update laliga_matches 
set AwayTeam = 'Athletico Madrid'
where AwayTeam = 'Ath Madrid';
update laliga_matches 
set AwayTeam = 'Athletic Club'
where AwayTeam = 'Ath Bilbao';
update laliga_matches 
set AwayTeam = 'Real Betis'
where AwayTeam = 'Betis';
update laliga_matches 
set AwayTeam = 'Celta Vigo'
where AwayTeam = 'Celta';
update laliga_matches 
set AwayTeam = 'Real Sociedad'
where AwayTeam = 'Sociedad';
update laliga_matches 
set AwayTeam = 'Rayo Vallecano'
where AwayTeam = 'Vallecano';

-- create the new table for the final data
create table final_data as
select lm.HomeTeam, lm.AwayTeam, lm.Date, lm.FTHG, lm.FTAG
from laliga_matches lm
left join laliga_matches_23_24 lm2 on lm.HomeTeam = lm2.`Home Team` and lm.AwayTeam = lm2.`Away Team` and lm.`Date` = lm2.`UTC Time`;

alter table final_data
add column result varchar(10)

update final_data 
set result = case 
	when FTHG > FTAG then 'Win'
	when FTHG < FTAG then 'Loss'
	else 'Draw'
end

alter table final_data 
drop column home_total_goals

alter table final_data 
drop column away_total_goals

alter table final_data 
add column home_total_goals_for_year int 

alter table final_data 
add column away_total_goals_for_year int

-- total number of away goals the away team has scored for the year
update final_data as fd
join
(
	select AwayTeam, sum(FTAG) as away_goals_for_year
	from final_data where year(`Date`) = 2023
	group by AwayTeam 

) as t on fd.AwayTeam = t.AwayTeam and year(fd.`Date`) = 2023
set fd.away_total_goals_for_year = t.away_goals_for_year


alter table final_data 
add column Head_To_Head_Win_Percentage float;

-- Update Head_To_Head_Win_Percentage in final_data table (total head-to-head)
UPDATE final_data AS fd
JOIN (
    SELECT 
        HomeTeam, 
        AwayTeam, 
        SUM(CASE WHEN FTHG > FTAG THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Head_To_Head_Win_Percentage
    FROM final_data
    GROUP BY HomeTeam, AwayTeam
) AS subquery
ON fd.HomeTeam = subquery.HomeTeam 
AND fd.AwayTeam = subquery.AwayTeam
SET fd.Head_To_Head_Win_Percentage = subquery.Head_To_Head_Win_Percentage;








