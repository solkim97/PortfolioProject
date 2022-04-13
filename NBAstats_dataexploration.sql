--Using SQL to explore our NBA Stats Database

--Looking for average age of players on each team in the 2021 season
SELECT tm, ROUND(AVG(CAST(age as float)),1) avg_age
FROM NBAstats.dbo.player_totals
WHERE SEASON = 2021
    AND tm <> 'TOT'
GROUP BY tm
ORDER BY avg_age DESC


--Looking for best scorers in 2021
SELECT TOP 10
    player, tm, ROUND((CAST(pts AS FLOAT)/CAST(g AS float)),1) pts_per_game, pts, g 
FROM NBAstats.dbo.player_totals
WHERE season = 2021
ORDER BY pts_per_game DESC


--Looking for best 3-point shooters min. 300 shot attempts in 2021
SELECT TOP 10 
    player, CONVERT(float,(x3p_percent*100)) x3p_percent, x3pa
FROM NBAstats.dbo.player_totals
WHERE season = 2021
    AND x3pa >= 300
ORDER BY x3p_percent DESC

--Looking for Lebron James' season by season & career stats
--Using Partition to add career totals season by season
SELECT 
season, 
tm, 
ROUND((CAST(pts AS FLOAT)/CAST(g AS float)),1) pts_per_game, 
ROUND((CAST(ast AS FLOAT)/CAST(g AS float)),1) ast_per_game,
ROUND((CAST(trb AS FLOAT)/CAST(g AS float)),1) reb_per_game,
pts,
ast,
trb reb,
g games,
SUM(pts) OVER (PARTITION BY player ORDER BY season) career_pts,
SUM(ast) OVER (PARTITION BY player ORDER BY season) career_ast,
SUM(trb) OVER (PARTITION BY player ORDER BY season) career_reb,
SUM(g) OVER (PARTITION BY player ORDER BY season) career_games
FROM NBAstats.dbo.player_totals
WHERE player = 'Lebron James'


--Looking for best corner 3-point shooters min. 100 attempts in 2021
--Using a join to do calculations with 2 different tables in the database
SELECT TOP 10
    tot.player, 
    CONVERT(float,(shoot.corner_3_point_percent*100)) c3p_percent, 
    FLOOR(tot.x3pa * shoot.percent_corner_3s_of_3pa) c3pa
FROM NBAstats.dbo.player_totals tot 
FULL OUTER JOIN NBAstats.dbo.player_shooting shoot
    ON tot.seas_id = shoot.seas_id
WHERE tot.season = 2021
    AND (tot.x3pa * shoot.percent_corner_3s_of_3pa) >= 100
ORDER BY c3p_percent DESC


--Looking for best mid-range shooters min. 150 attempts in 2021
--USING CTE to use new calculation as a filter for our WHERE statement
WITH mid_range (player, team, mid_range_fg_percent, mid_range_fga)
AS
(
SELECT 
tot.player, 
tot.tm, 
(shoot.fg_percent_from_x10_16_range*100), 
(tot.fga * shoot.percent_fga_from_x10_16_range)
FROM NBAstats.dbo.player_totals tot 
FULL OUTER JOIN NBAstats.dbo.player_shooting shoot
    ON tot.seas_id = shoot.seas_id
WHERE tot.season = 2021
)
SELECT TOP 10
player,
team,
CAST((mid_range_fg_percent)AS decimal(3,1)) mid_range_fg_percent,
FLOOR(mid_range_fga) mid_range_fga
FROM mid_range
WHERE mid_range_fga >= 150
ORDER BY mid_range_fg_percent DESC


--Same objective as above query but using a TEMP TABLE
DROP TABLE IF EXISTS #mid_range
CREATE TABLE #mid_range
(
player VARCHAR(24), 
team VARCHAR(3), 
mid_range_fg_percent FLOAT, 
mid_range_fga INT
)
INSERT INTO #mid_range
SELECT 
tot.player, 
tot.tm, 
(shoot.fg_percent_from_x10_16_range*100) x10_16_fg_percent, 
(tot.fga * shoot.percent_fga_from_x10_16_range) x10_16_fga
FROM NBAstats.dbo.player_totals tot 
FULL OUTER JOIN NBAstats.dbo.player_shooting shoot
    ON tot.seas_id = shoot.seas_id
WHERE tot.season = 2021

SELECT TOP 10 *
FROM #mid_range
WHERE mid_range_fga >= 150
ORDER BY mid_range_fg_percent DESC


--Creating view to store data for visualizations (chart for Lebron James' career stats)
CREATE View LebronJames AS
SELECT 
season, 
tm, 
ROUND((CAST(pts AS FLOAT)/CAST(g AS float)),1) pts_per_game, 
ROUND((CAST(ast AS FLOAT)/CAST(g AS float)),1) ast_per_game,
ROUND((CAST(trb AS FLOAT)/CAST(g AS float)),1) reb_per_game,
pts,
ast,
trb reb,
g games,
SUM(pts) OVER (PARTITION BY player ORDER BY season) career_pts,
SUM(ast) OVER (PARTITION BY player ORDER BY season) career_ast,
SUM(trb) OVER (PARTITION BY player ORDER BY season) career_reb,
SUM(g) OVER (PARTITION BY player ORDER BY season) career_games
FROM NBAstats.dbo.player_totals
WHERE player = 'Lebron James'

SELECT *
FROM LebronJames
--Wow, he is the ONLY player in NBA history with over 30K points, 10K rebounds, and 10K assists!







