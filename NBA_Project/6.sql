/*
TASK: Shooting Stability per Season for a Given Player

DESCRIPTION:
Find all 'Regular Season' seasons for a specific player (identified by first and last name) 
in which the player played **at least 50 games**.

For these qualifying seasons, compute the **stability of field goal shooting**.
Stability is defined as the average absolute change in field goal percentage (FG%) 
between consecutive games within the season.

STEPS:
1. Use only the following event types:
   - 'FIELD GOAL MADE'
   - 'FIELD GOAL MISSED'

2. For each game:
   - Calculate the field goal percentage (FG%) = FGM / (FGM + FGA)
     where:
     - FGM = number of 'FIELD GOAL MADE'
     - FGA = total attempts = 'FIELD GOAL MADE' + 'FIELD GOAL MISSED'

3. For each season:
   - Order the games chronologically.
   - For the first game, change is 0.
   - For every next game, calculate the absolute difference in FG% compared to the previous game.
   - Compute the average of all these differences, including the initial 0%.

4. The final result includes:
   - season_id      - ID of the season
   - stability       - average absolute FG% difference across games, rounded appropriately

ORDERING:
- Primary: stability ASC (lowest = most stable)
- Secondary: season_id ASC
*/


WITH shooting_stats AS (
	    SELECT
	    g.season_id,
	    g.id AS game_id,
	    g.game_date,
	    COUNT(*) FILTER (WHERE pr.event_msg_type = 'FIELD_GOAL_MADE') AS field_goals_made,
	    COUNT(*) FILTER (WHERE pr.event_msg_type = 'FIELD_GOAL_MISSED') AS field_goals_missed
	FROM players AS main
	JOIN play_records AS pr ON main.id = pr.player1_id
	JOIN games AS g ON pr.game_id = g.id
	WHERE
	    main.first_name = 'LeBron'
	    AND main.last_name = 'James'
	    AND g.season_type = 'Regular Season'
	GROUP BY g.season_id, g.id, g.game_date
),

shoot_percentage AS (
    SELECT
        main.season_id,
        main.game_id,
        main.game_date,
        main.field_goals_made,
        main.field_goals_missed,
         ROUND(
            (main.field_goals_made * 100.0) / NULLIF(main.field_goals_made + main.field_goals_missed, 0),
        2) AS fg_percentage
    FROM shooting_stats AS main
),

fg_diff AS (
    SELECT
        main.season_id,
        main.game_id,
        main.game_date,
        main.fg_percentage,
        COALESCE(ABS(main.fg_percentage - LAG(main.fg_percentage) OVER (
            PARTITION BY main.season_id ORDER BY main.game_id
        )), 0) AS fg_change
    FROM shoot_percentage AS main
),

season_stability AS (
    SELECT
        main.season_id,
        ROUND(AVG(main.fg_change), 2) AS stability
    FROM fg_diff as main
    GROUP BY main.season_id
    HAVING COUNT(main.game_id) >= 50  -- Započíta len sezóny, kde odohral aspoň 50 zápasov
)
SELECT
    main.season_id,
    main.stability
FROM season_stability as main
ORDER BY stability ASC, season_id ASC;
