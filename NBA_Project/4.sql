/*
TASK: Triple Double Detection and Longest Streak Analysis

DESCRIPTION:
Identify all players who achieved a **triple double** during a selected season.
A triple double is defined as achieving **double-digit (10 or more)** stats in **three** of the following categories within a single game:
1. Points
2. Assists
3. Rebounds

STAT CATEGORIES & RULES:
- Count points from:
  • 'FIELD GOAL MADE' (assume 2 points per basket regardless of type)
  • 'FREE THROW' (only successful ones)
- Count assists from their respective event type (if stored separately)
- Count rebounds using the 'REBOUND' event type
- Distinguish made vs missed free throws
- Only these event types should be considered:
  • 'FIELD GOAL MADE'
  • 'FREE THROW'
  • 'REBOUND'

STREAK REQUIREMENT:
- For each qualifying player, compute their **longest consecutive triple double streak** within the season.
- A streak is continuous if the player gets a triple double in back-to-back games.
- If the player fails to reach triple double in a game, the streak resets.

ADDITIONAL OUTPUT:
- Return only the player ID and the value of their longest triple double streak.

OUTPUT COLUMNS:
• player_id         - ID of the player
• longest_streak    - Maximal length of uninterrupted triple double games

ORDERING:
- Primary: longest_streak DESC (highest streaks first)
- Secondary: player_id ASC (in case of ties)

NOTES:
- Average assists or games per team are not required in the final output.
- The logic must be scoped to a single specified season.
*/


WITH points_rebounds_assists AS (
    SELECT
        main.player1_id AS player_id,
        gs.id AS game_id,

        SUM(CASE 
            WHEN main.event_msg_type = 'FIELD_GOAL_MADE' THEN 2
            WHEN main.event_msg_type = 'FREE_THROW' AND main.score_margin IS NOT NULL THEN 1
            ELSE 0
        END) AS points,

        COUNT(*) FILTER (
            WHERE 
                main.event_msg_type = 'REBOUND'
        ) AS rebounds
        
    FROM 
        play_records AS main
    INNER JOIN
        games AS gs ON main.game_id = gs.id
    WHERE 
        gs.season_id = '22018' AND main.event_msg_type IN ('FIELD_GOAL_MADE', 'FREE_THROW', 'REBOUND')
    GROUP BY 
        main.player1_id,
        gs.id
),

assists AS (
    SELECT
        main.player2_id AS player_id,
        gs.id AS game_id,

        COUNT(*) FILTER (
            WHERE main.event_msg_type = 'FIELD_GOAL_MADE'
        ) AS assists

    FROM 
        play_records AS main
    INNER JOIN 
        games AS gs ON main.game_id = gs.id
    WHERE 
        gs.season_id = '22018'
        AND main.event_msg_type = 'FIELD_GOAL_MADE'
        AND main.player2_id IS NOT NULL
    GROUP BY
        main.player2_id, 
        gs.id
),
merge_points_rebound_assists AS (
    SELECT
        COALESCE(main.player_id, a.player_id) AS player_id,
        COALESCE(main.game_id, a.game_id) AS game_id,
        COALESCE(main.points, 0) AS points,
        COALESCE(a.assists, 0) AS assists,
        COALESCE(main.rebounds, 0) AS rebounds,
        CASE 
            WHEN COALESCE(main.points, 0) >= 10 
             AND COALESCE(a.assists, 0) >= 10 
             AND COALESCE(main.rebounds, 0) >= 10
            THEN 1 ELSE 0
        END AS is_triple_double
    FROM 
        points_rebounds_assists main
    FULL OUTER JOIN
        assists as a ON main.player_id = a.player_id AND main.game_id = a.game_id
),

numbered AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY game_id) AS row_num,
        ROW_NUMBER() OVER (PARTITION BY player_id, is_triple_double ORDER BY game_id) AS row_num_triple_double
    FROM 
        merge_points_rebound_assists
),

streaks AS (
    SELECT 
        *,
        row_num - row_num_triple_double AS streak_group
    FROM 
        numbered
    WHERE
        is_triple_double = 1
),

longest_streak AS (
    SELECT 
        player_id,
        COUNT(*) AS streak_length
    FROM 
        streaks
    GROUP BY 
        player_id, 
        streak_group
),
final_query AS (
    SELECT 
        player_id,
        MAX(streak_length) AS max_streak
    FROM 
        longest_streak
    GROUP BY 
        player_id
)
SELECT 
    *
FROM 
    final_query
ORDER BY
    max_streak DESC, 
    player_id;
