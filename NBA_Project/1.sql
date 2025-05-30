-- Active: 1745233965939@@127.0.0.1@5432@NBA_Dataset

/*
TASK DESCRIPTION:

Find all events in which a player, within the same game, scores a field goal ("FIELD GOAL MADE") 
immediately after securing a rebound ("REBOUND") — with no other event in between.

Assumptions:
- The pass events (if any) between the rebound and field goal should be ignored.
- The scoring must directly follow the rebound without any other type of event in between.

For each such case, return the following attributes:
• player_id      - ID of the player
• first_name     - First name of the player
• last_name      - Last name of the player
• period         - Quarter number of the scoring event
• period_time    - Remaining time in the quarter when the scoring occurred

Ordering:
- Primary:    period (ascending)
- Secondary:  period_time (descending)
- Tertiary:   player_id (ascending)
*/

WITH results_with_lag AS (
    SELECT
        *,
        LAG(event_msg_type) OVER (ORDER BY event_number) AS previous_event,
        LAG(player1_id) OVER (ORDER BY event_number) AS previous_player1_id,
        LAG(event_number) OVER (ORDER BY event_number) AS previous_event_number
    FROM
        play_records
    INNER JOIN
        players ON players.id = player1_id
    Where 
        game_id = 22000529 AND event_msg_type IN ('REBOUND', 'FIELD_GOAL_MADE', 'FREE_THROW', 'FIELD_GOAL_MISSED')
)
SELECT
    player1_id,
    first_name,
    last_name,
    period,
    pctimestring
FROM
    results_with_lag AS rwl
WHERE
    event_msg_type = 'FIELD_GOAL_MADE' AND previous_event = 'REBOUND' AND player1_id = previous_player1_id 
    AND event_number = previous_event_number + 1
ORDER BY
    event_number,
    period,
    player1_id;
