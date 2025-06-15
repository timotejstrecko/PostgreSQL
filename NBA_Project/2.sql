/*
TASK: Team Changes and Player Performance Analysis for a Given Season

DESCRIPTION:
For a given NBA season, identify all players who changed teams during that season.
A team change is defined as a player appearing for multiple different teams in events of types:
  • 'FREE THROW'
  • 'FIELD GOAL MADE'
  • 'FIELD GOAL MISSED'
  • 'REBOUND'

A player is considered to have changed teams if their ID appears in columns `player1_id` or `player2_id` 
in the `play_records` table for the specified event types, across different team IDs.

GOAL:
1. Count how many times each player changed teams in the season.
2. From these, select the top 5 players with the **most team changes**.
   - If there's a tie, sort by:
     a. Active status (`is_active = true` comes first)
     b. Last name ascending
     c. First name ascending

3. For these top 5 players:
   - For each team they played for during the season, compute:
     • `PPG`: Average points per game (2 points per 'FIELD GOAL MADE', ignore 3-pointers)
     • `APG`: Average assists per game (using `player2_id` as assist giver on 'FIELD GOAL MADE')
     • `games`: Number of distinct games played for that team

REQUIRED OUTPUT COLUMNS:
• player_id    - Player’s ID
• first_name   - Player’s first name
• last_name    - Player’s last name
• team_id      - Team ID the player played for
• team_name    - Full name of the team
• PPG          - Average points per game (rounded to 2 decimal places)
• APG          - Average assists per game (rounded to 2 decimal places)
• games        - Number of games played for that team

ORDERING:
- Final result should be ordered by:
  1. player_id ascending
  2. team_id ascending
*/

WITH player_teams AS (
SELECT DISTINCT
    main.player1_id AS player_id,
    main.player1_team_id AS team_id,
    t.full_name AS team_name
FROM 
    play_records main
INNER JOIN 
    teams AS t ON main.player1_team_id = t.id
INNER JOIN 
    games AS g ON main.game_id = g.id
WHERE 
    g.season_id = '22017' AND main.event_msg_type IN ('FIELD_GOAL_MADE', 'FIELD_GOAL_MISSED', 'FREE_THROW', 'REBOUND')

UNION

SELECT DISTINCT
    main.player2_id AS player_id,
    main.player2_team_id AS team_id,
    t.full_name AS team_name
FROM 
    play_records AS main
INNER JOIN 
    teams AS t ON main.player2_team_id = t.id
INNER JOIN 
    games AS g ON main.game_id = g.id
WHERE 
    g.season_id = '22017' AND main.event_msg_type IN ('FIELD_GOAL_MADE', 'FIELD_GOAL_MISSED', 'FREE_THROW', 'REBOUND')
),
team_changes AS ( --camel lol 
SELECT
    main.player_id,
    COUNT(DISTINCT main.team_id) - 1 AS transfer_count
FROM 
    player_teams AS main
GROUP BY 
    main.player_id
HAVING 
    COUNT(DISTINCT main.team_id) > 1
),
top5 AS (
    SELECT 
        main.player_id
    FROM 
        team_changes AS  main
    INNER JOIN 
        players AS p ON main.player_id = p.id
    ORDER BY 
        main.transfer_count DESC, 
        p.last_name ASC, 
        p.first_name ASC
    LIMIT 
        5
),
gameChoose AS (
SELECT
    main.game_id,
    main.player1_id AS player_id,
    main.player1_team_id AS team_id
FROM 
    play_records main
JOIN 
    games AS g ON main.game_id = g.id
WHERE 
    g.season_id = '22017' AND main.event_msg_type IN ('FIELD_GOAL_MADE', 'FIELD_GOAL_MISSED', 'FREE_THROW', 'REBOUND')

UNION

SELECT
    main.game_id,
    main.player2_id AS player_id,
    main.player2_team_id AS team_id
FROM 
    play_records main
INNER JOIN 
    games AS g ON main.game_id = g.id 
WHERE 
    g.season_id = '22017' AND main.event_msg_type IN ('FIELD_GOAL_MADE', 'FIELD_GOAL_MISSED', 'FREE_THROW', 'REBOUND')
),
aggregate_games AS (
SELECT
    main.player_id,
    main.team_id,
    COUNT(DISTINCT main.game_id) AS games
FROM 
    gameChoose AS main
GROUP BY 
    main.player_id, 
    main.team_id
),
Points AS (
SELECT
    main.player1_id AS player_id,
    main.player1_team_id AS team_id,
    COUNT(*) FILTER (WHERE main.event_msg_type = 'FIELD_GOAL_MADE') * 2 +
    COUNT(*) FILTER (WHERE main.event_msg_type = 'FREE_THROW' AND main.score_margin IS NOT NULL) AS total_points
FROM 
    play_records AS main
INNER JOIN 
    games AS g ON main.game_id = g.id
WHERE 
    g.season_id = '22017'
GROUP BY 
    main.player1_id, 
    main.player1_team_id
),
Assists AS (
SELECT
    main.player2_id AS player_id,
    main.player2_team_id AS team_id,
    COUNT(*) FILTER (WHERE main.event_msg_type = 'FIELD_GOAL_MADE') AS total_assists
FROM 
    play_records main
INNER JOIN 
    games AS g ON main.game_id = g.id
WHERE 
    g.season_id = '22017' AND main.player2_id IS NOT NULL
GROUP BY 
    main.player2_id, 
    main.player2_team_id
),
final_statistics AS (
SELECT
    main.player_id,
    main.team_id,
    main.games,
    COALESCE(p.total_points, 0) AS total_points,
    COALESCE(s.total_assists, 0) AS total_assists
FROM 
    aggregate_games AS main
LEFT JOIN 
    Points p ON main.player_id = p.player_id AND main.team_id = p.team_id
LEFT JOIN 
    Assists s ON main.player_id = s.player_id AND main.team_id = s.team_id
)
SELECT
    main.player_id,
    pl.first_name,
    pl.last_name,
    main.team_id,
    tm.full_name AS team_name,
    ROUND(main.total_points::NUMERIC / NULLIF(main.games, 0), 2) AS PPG,
    ROUND(main.total_assists::NUMERIC / NULLIF(main.games, 0), 2) AS APG,
    main.games
FROM 
    final_statistics AS main
INNER JOIN 
    top5 as tp ON main.player_id = tp.player_id
INNER JOIN 
    players as pl ON main.player_id = pl.id
INNER JOIN 
    teams as tm ON main.team_id = tm.id
ORDER BY 
    main.player_id ASC, 
    main.team_id ASC;