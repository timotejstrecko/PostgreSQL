----------------------------------------------------------------------------------                                            1.

-- 1 Hrac Nikdy za zivot nehral hru alebo nemal team

SELECT 
    players.id AS "Player_ID",
    players.first_name,
    players.last_name
FROM
    players
WHERE
    NOT EXISTS (
        SELECT 
            1
        FROM
            player_records AS pr
        INNER JOIN
            game_records AS gr ON gr.player_record_id = pr.id
        Where 
            pr.player_id = players.id
    )
ORDER BY
    players.last_name DESC,
    players.first_name DESC;


SELECT 
    players.id AS "Player_ID",
    players.first_name AS "First Name",
    players.last_name AS "Last Name"
FROM
    players
LEFT JOIN
    player_records AS pr ON pr.player_id = players.id
LEFT JOIN 
    game_records AS gr ON gr.player_record_id = pr.id
GROUP BY
    players.id
HAVING
    COUNT(1) FILTER (WHERE gr.id IS NOT NULL) = 0
ORDER BY
    "Last Name" DESC,
    "First Name" DESC;


-- Hrac niekedy nemal team alebo nehral hru

SELECT DISTINCT
    players.id AS "Player_ID",
    players.first_name AS "First Name",
    players.last_name AS "Last Name"
FROM
    players
LEFT JOIN
    player_records AS pr ON pr.player_id = players.id
LEFT JOIN 
    game_records AS gr ON gr.player_record_id = pr.id
WHERE 
    gr.id IS NULL
ORDER BY
    "Last Name" DESC,
    "First Name" DESC;


----------------------------------------------------------------------------------                                            2. + game_count

SELECT 
    pl.id AS "Player ID",
    pl.first_name AS "First Name",
    pl.last_name AS "Last Name",
    teams.name AS "Team",
    teams.id as "Team ID",
    ROW_NUMBER() OVER (ORDER BY pr.valid_from) AS "Team_rank",
    COUNT(1) FILTER (WHERE gr.event_type = 'goal') as "Goals",
    COUNT(DISTINCT gr.game_id) AS "Game Count",
    COALESCE(COUNT(1) FILTER (WHERE gr.event_type = 'goal') - LAG(COUNT(1) FILTER (WHERE gr.event_type = 'goal')) OVER (ORDER BY pr.valid_from), 0) AS "Goal diff"
FROM 
    players AS pl
INNER JOIN
    player_records AS pr ON pr.player_id = pl.id
INNER JOIN 
    teams ON teams.id = pr.team_id
LEFT JOIN
    games ON games.team_home_id = teams.id OR games.team_away_id = teams.id
LEFT JOIN 
    game_records AS gr ON gr.game_id = games.id AND gr.player_record_id = pr.id
Where 
    pl.id = 10
GROUP BY
    pl.id,
    teams.id,
    pr.valid_from;




----------------------------------------------------------------------------------                                            3.

WITH total_goals_rank AS (
    SELECT
        pl.id AS "Player ID",
        COUNT(1) FILTER (WHERE gr.event_type = 'goal') AS "Total Goals",
        ROW_NUMBER() OVER (ORDER BY COUNT(1) FILTER (WHERE gr.event_type = 'goal') DESC) AS "Total Goal Rank"
    FROM
        players AS pl
    INNER JOIN
        player_records AS pr ON pr.player_id = pl.id
    INNER JOIN 
        game_records AS gr ON gr.player_record_id = pr.id
    GROUP BY
        pl.id
),
top_3_matches AS (
    SELECT
        pl.id AS "Player ID",
        pl.first_name || ' ' || pl.last_name AS "Player Name",
        gr.game_id AS "Game ID",
        COUNT(1) FILTER (WHERE gr.event_type = 'goal') AS "Goals",
        ROW_NUMBER() OVER (PARTITION BY pl.id ORDER BY COUNT(1) FILTER (WHERE gr.event_type = 'goal') DESC, gr.game_id) AS "Match Goal Rank"
    FROM 
        players AS pl
    INNER JOIN
        player_records AS pr ON pr.player_id = pl.id
    INNER JOIN
        game_records AS gr ON gr.player_record_id = pr.id
    GROUP BY 
        pl.id,
        gr.game_id
)
SELECT
    t3.*,
    tgr."Total Goals",
    tgr."Total Goal Rank"
FROM
    top_3_matches AS t3
INNER JOIN
    total_goals_rank AS tgr ON tgr."Player ID" = t3."Player ID"
WHERE
    t3."Match Goal Rank" <= 3 AND tgr."Total Goal Rank" <= 5
ORDER BY
    tgr."Total Goal Rank",
    t3."Match Goal Rank",
    t3."Game ID";


----------------------------------------------------------------------------------                                            4.

WITH goals AS (
    SELECT 
        pl.id AS "Player ID",
        pl.first_name || ' ' || pl.last_name AS "Player Name",
        games.date AS "Date", 
        COUNT(1) FILTER (WHERE event_type = 'goal') > 0 AS goal,
        ROW_NUMBER() OVER (PARTITION BY pl.id ORDER BY games.date) AS row_num
    FROM
        players AS pl
    INNER JOIN 
        player_records AS pr ON pr.player_id = pl.id
    INNER JOIN 
        teams ON teams.id = pr.team_id
    INNER JOIN 
        games ON games.team_home_id = teams.id OR games.team_away_id = teams.id
    INNER JOIN 
        game_records AS gr ON gr.player_record_id = pr.id AND games.id = gr.game_id
    WHERE
        season = '2022'
    GROUP BY
        pl.id,
        games.id
),
group_create AS (
    SELECT
        *,
        SUM(CASE WHEN goal IS FALSE THEN 1 ELSE 0 END)
            OVER (PARTITION BY "Player ID" ORDER BY "Date" ROWS UNBOUNDED PRECEDING)
        AS streak_group
    FROM 
        goals
),
streak_group_forming AS (
    SELECT
        "Player ID",
        "Player Name",
        COUNT(1) AS "Streak Length"
    FROM
        group_create
    WHERE
        goal IS true
    GROUP BY 
        "Player ID", 
        "Player Name",
        streak_group
)
SELECT DISTINCT ON ("Player ID")
    *
FROM
    streak_group_forming 
ORDER BY
    "Player ID",
    "Streak Length"

