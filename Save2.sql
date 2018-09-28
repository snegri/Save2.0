use retrosheet;

# get the initial  state of the saving pitcher for each game
SELECT e.game_ID as 'gID', ABS(g.AWAY_SCORE_CT - g.HOME_SCORE_CT) AS 'scoreDiff', e.INN_CT AS 'inning', e.OUTS_CT as 'Current Outs', e.BASE1_RUN_ID as 'onFirst', e.BASE2_RUN_ID as 'onSecond', e.BASE3_RUN_ID as 'onThird', e.pit_id as 'pID', concat(r.first_name_tx, ' ' , r.last_name_tx) as 'name'
FROM games g
left JOIN events e ON e.pit_id = g.save_pit_id AND e.game_ID = g.game_ID
left join rosters r on r.player_ID = g.save_pit_id;

# get last pitching sub from each team for each game    
select s.* from subs s
inner join (
	select GAME_ID, BAT_HOME_ID, max(EVENT_ID) EVENT_ID from subs
	where sub_fld_cd = 1 and removed_fld_cd = 1
    group by GAME_ID, BAT_HOME_ID
) sp on sp.GAME_ID = s.GAME_ID and sp.EVENT_ID = s.EVENT_ID
order by s.GAME_ID, s.BAT_HOME_ID;

# show all substituted pitchers
select s.* from subs s where sub_fld_cd = 1 and removed_fld_cd = 1 order by s.GAME_ID, s.BAT_HOME_ID;

# put it all together
select e.GAME_ID, e.EVENT_ID, e.INN_CT, g.INN_CT as TOTAL_INN, IF(e.BAT_HOME_ID = 0, 1, 0) as HOME_TEAM, IF(g.HOME_SCORE_CT > g.AWAY_SCORE_CT, 1, 0) as HOME_TEAM_WINS, e.OUTS_CT, e.HOME_SCORE_CT, e.AWAY_SCORE_CT, IF(BASE1_RUN_ID = '', 0, 1) AS RUNNER_FIRST, IF(BASE2_RUN_ID = '', 0, 1) AS RUNNER_SECOND, IF(BASE3_RUN_ID = '', 0, 1) AS RUNNER_THIRD, e.PIT_ID, IF(SAVE_PIT_ID = '', 'None', SAVE_PIT_ID) AS SAVE_PIT_ID, concat(r.first_name_tx, ' ', r.last_name_tx) as 'FULL_NAME' 
from events e
inner join (
	select s.GAME_ID, s.BAT_HOME_ID, s.EVENT_ID from subs s where sub_fld_cd = 1 and removed_fld_cd = 1 order by s.GAME_ID, s.BAT_HOME_ID
) s on s.game_id = e.game_id and s.event_id+1 = e.event_id
left join (
	select r.player_id, r.first_name_tx, r.LAST_NAME_TX from rosters r group by r.player_id, r.FIRST_NAME_TX, r.LAST_NAME_TX
) r on r.player_id = e.pit_id
left join games g on g.GAME_ID = e.GAME_ID and g.GAME_ID = s.GAME_ID
order by e.game_id, e.BAT_HOME_ID,e.event_id; 

