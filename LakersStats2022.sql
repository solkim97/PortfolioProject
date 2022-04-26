--Exploring NBA teams data from 2022
--Why were the Lakers so bad this season?


-- Let's find the ratings for each team in 2022
SELECT team Team, o_rtg OffensiveRating, d_rtg DefensiveRating, n_rtg as NetRating
FROM NBAstats.dbo.TeamSummaries
WHERE season = 2022
    AND team <> 'League Average'
--ORDER BY OffensiveRating DESC
--ORDER BY DefensiveRating
ORDER BY NetRating DESC

-- Lakers were 23rd in offensive rating
-- Lakers were 21st in defensive rating
-- Lakers were 22nd in net rating
-- YIKES, their ratings as a team were really bad

--Let's see how their offensive team stats reflect their ratings
SELECT stats.team Team,
       stats.pts_per_game PointsPerGame,
       stats.fg_percent FieldGoal_Percent,
       stats.x3p_percent ThreePoint_Percent,
       stats.ft_percent FreeThrow_Percent,
       summ.ts_percent TrueShooting_Percent,
       stats.ast_per_game AssistsPerGame,
       stats.tov_per_game TurnoversPerGame,
       summ.pace Pace,
       summ.w Wins
FROM NBAstats.dbo.TeamStatsPerGame stats
    JOIN NBAstats.dbo.TeamSummaries summ
    ON stats.seasonid = summ.seasonid
WHERE stats.season = 2022
    AND stats.team <> 'League Average'
ORDER BY Wins DESC

--Points Per Game: 11th
--Field Goal Percent: 10th
--3 Point Percent: 22nd
--Free Throw Percent: 29th
--True Shooting Percent: 17th
--Assists Per Game: 16th
--Turnovers Per Game (higher rank is worse): TIED FOR 4th
--Pace: 4th
--Wins: 23rd

-- Let's look at their defensive team stats
SELECT stats.team Team,
       stats.drb_per_game DefensiveReboundsPerGame,
       stats.stl_per_game StealsPerGame,
       stats.blk_per_game BlocksPerGame,
       opp.opp_pts_per_game PointsAllowedPerGame,
       opp.opp_tov_per_game ForcedTurnoversPerGame,
       opp.opp_fg_percent OpponentFgShooting,
       opp.opp_x3pa_per_game Opponent3PointAttempts,
       opp.opp_x3p_percent Opponent3PointShooting,
       opp.opp_fta_per_game OpponentFreeThrowAttempts
FROM NBAstats.dbo.TeamStatsPerGame stats
    JOIN NBAstats.dbo.OpponentStatsPerGame opp
    ON stats.seasonid = opp.seasonid
WHERE stats.season = 2022
    AND stats.team <> 'League Average'
ORDER BY Opponent3PointAttempts DESC

--Defensive Rebounding: 12th
--Steals Per Game: 14th
--Blocks Per Game: 7th
--Forcing Turnovers: TIED FOR 11th
--Points Allowed Per Game (higher is worse): 4th
--Opponent FG Shooting (higher is worse): TIED for 9th
--Opponent 3 Point Attempts (higher is worse): 12th
--Opponent 3 Point Shooting (higher is worse): 17th
--Opponent Free Throw Attempts (higher is worse): 5th


-- Let's break down their individual players excluding players who played less than 300 minutes
-- Creating a table with all relevant stats and advanced metrics
SELECT tot.player Player,
       tot.pos Position,
       tot.tm Team,
       tot.age Age,
       tot.experience YearInLeague,
       tot.g GamesPlayed, 
       tot.gs GamesStarted, 
       tot.mp MinutesPlayed, 
       tot.e_fg_percent EffectiveFG_Percent, 
       ROUND((CONVERT(float, tot.pts)/tot.g),1) PointsPerGame, 
       ROUND((CONVERT(float, tot.ast)/tot.g),1) AssistsPerGame, 
       ROUND((CONVERT(float, tot.trb)/tot.g),1) RebsPerGame, 
       ROUND((CONVERT(float, tot.stl)/tot.g),1) StealsPerGame,
       ROUND((CONVERT(float, tot.blk)/tot.g),1) BlocksPerGame,
       ROUND((CONVERT(float, tot.tov)/tot.g),1) TurnoversPerGame,
       adv.tov_percent TurnoverPercent,
       adv.usg_percent UsagePercent,
       adv.ws WinShares,
       adv.ws_48 WinSharesPer48,
       adv.obpm OffBoxPlusMinus,
       adv.dbpm DefBoxPlusMinus,
       adv.bpm BoxPlusMinus,
       adv.vorp ValueOverReplacement
FROM NBAstats.dbo.PlayerTotals tot
    JOIN NBAstats.dbo.Advanced adv
    ON tot.seas_id = adv.seas_id
WHERE tot.season = 2022
    AND tot.tm = 'LAL'
    AND tot.mp > 300
ORDER BY MinutesPlayed DESC

-- Creating a view to make querying this data more efficient
CREATE View Lakers2022 AS
SELECT tot.player Player,
       tot.pos Position,
       tot.tm Team,
       tot.age Age,
       tot.experience YearInLeague,
       tot.g GamesPlayed, 
       tot.gs GamesStarted, 
       tot.mp MinutesPlayed, 
       tot.e_fg_percent EffectiveFG_Percent, 
       ROUND((CONVERT(float, tot.pts)/tot.g),1) PointsPerGame, 
       ROUND((CONVERT(float, tot.ast)/tot.g),1) AssistsPerGame, 
       ROUND((CONVERT(float, tot.trb)/tot.g),1) RebsPerGame, 
       ROUND((CONVERT(float, tot.stl)/tot.g),1) StealsPerGame,
       ROUND((CONVERT(float, tot.blk)/tot.g),1) BlocksPerGame,
       ROUND((CONVERT(float, tot.tov)/tot.g),1) TurnoversPerGame,
       adv.tov_percent TurnoverPercent,
       adv.usg_percent UsagePercent,
       adv.ws WinShares,
       adv.ws_48 WinSharesPer48,
       adv.obpm OffBoxPlusMinus,
       adv.dbpm DefBoxPlusMinus,
       adv.bpm BoxPlusMinus,
       adv.vorp ValueOverReplacement
FROM NBAstats.dbo.PlayerTotals tot
    JOIN NBAstats.dbo.Advanced adv
    ON tot.seas_id = adv.seas_id
WHERE tot.season = 2022
    AND tot.tm = 'LAL'
    AND tot.mp > 300


-- Final chart for visualization
SELECT *
FROM NBAstats.dbo.Lakers2022
WHERE player <> 'DeAndre Jordan' --he was traded from the team in the middle of the season
ORDER BY MinutesPlayed DESC

