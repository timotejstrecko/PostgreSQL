/*
TASK: Player Performance Stats in a Specific Game

DESCRIPTION:
For a selected game, calculate the following statistics for each player:

--- SCORING METRICS ---
• points               - Total number of points scored by the player (includes Free Throws)
• 2PM                  - Two-point field goals made (counts the number of successful 2-point attempts)
• 3PM                  - Three-point field goals made (counts the number of successful 3-point attempts)
• missed shots         - Total number of missed shots (cannot distinguish 2pt vs 3pt missed)
• shooting percentage  - Accuracy on field goals (2PM + 3PM) / (2PM + 3PM + missed shots), rounded to 2 decimals

--- FREE THROW METRICS ---
• FTM                  - Free Throws Made
• missed free throws   - Free Throws Missed
• FT percentage        - Free Throw shooting percentage: FTM / (FTM + missed), rounded to 2 decimals

--- PLAYER INFORMATION ---
• player_id            - ID of the player
• first_name           - Player's first name
• last_name            - Player's last name

NOTES:
- Only events relevant to scoring, missed field goals, and free throws should be used:
  • 'FIELD GOAL MADE'
  • 'FIELD GOAL MISSED'
  • 'FREE THROW' (differentiate made vs missed)
- Two-point vs three-point made field goals must be distinguished (assumed to be indicated in event subtype).
- Missed shots cannot be classified as 2 or 3 points — just counted as "missed".
- Free throw success can be determined using an indicator such as `score_margin` or `event_action_type`.

ORDERING:
- Primary: points DESC (highest scorers first)
- Secondary: shooting percentage DESC
- Tertiary: FT percentage DESC
- Lastly: player_id ASC
*/


WITH play_records_with_prev AS (
	SELECT main.*,
           COALESCE(
               CAST(NULLIF(LAG(main.score_margin) OVER (PARTITION BY main.game_id ORDER BY main.event_number), 'TIE') AS INTEGER), 0
           ) AS prev_score_margin 
    FROM play_records as main
    WHERE main.game_id = 21701185 AND main.score_margin IS NOT NULL
),

missed_shots AS (
    SELECT main.player1_id,
		COUNT(*) FILTER (
		    WHERE main.event_msg_type = 'FREE_THROW' AND main.score_margin IS NULL
		) AS missed_free,
		
		COUNT(*) FILTER (
		    WHERE main.event_msg_type = 'FIELD_GOAL_MISSED'
		) AS missed_shots

    FROM play_records as main
    WHERE main.game_id = 21701185 and main.player1_id is not null
    GROUP BY main.player1_id
)

SELECT 
    main.player1_id,
    p.first_name,
    p.last_name,

    COALESCE(SUM(CASE
        WHEN pr.event_msg_type = 'FIELD_GOAL_MADE'
             AND ABS(COALESCE(CAST(NULLIF(pr.score_margin, 'TIE') AS INTEGER), 0) - pr.prev_score_margin) = 3 THEN 3
        WHEN pr.event_msg_type = 'FIELD_GOAL_MADE'
             AND ABS(COALESCE(CAST(NULLIF(pr.score_margin, 'TIE') AS INTEGER), 0) - pr.prev_score_margin) = 2 THEN 2
        WHEN pr.event_msg_type = 'FREE_THROW' THEN 1
        ELSE 0
    END), 0) AS points,

    COUNT(*) FILTER (
        WHERE pr.event_msg_type = 'FIELD_GOAL_MADE'
          AND ABS(COALESCE(CAST(NULLIF(pr.score_margin, 'TIE') AS INTEGER), 0) - pr.prev_score_margin) = 2
    ) AS "2PM",

    COUNT(*) FILTER (
        WHERE pr.event_msg_type = 'FIELD_GOAL_MADE'
          AND ABS(COALESCE(CAST(NULLIF(pr.score_margin, 'TIE') AS INTEGER), 0) - pr.prev_score_margin) = 3
    ) AS "3PM",

    COALESCE(main.missed_shots, 0) AS missed_shots,

    COALESCE(ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE pr.event_msg_type = 'FIELD_GOAL_MADE'
              AND ABS(COALESCE(CAST(NULLIF(pr.score_margin, 'TIE') AS INTEGER), 0) - pr.prev_score_margin) IN (2, 3)
        )
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE pr.event_msg_type = 'FIELD_GOAL_MADE'
                  AND ABS(COALESCE(CAST(NULLIF(pr.score_margin, 'TIE') AS INTEGER), 0) - pr.prev_score_margin) IN (2, 3)
            ) + COALESCE(main.missed_shots, 0), 0
        ), 2), 00.00) AS shooting_percentage,

    COUNT(*) FILTER (WHERE pr.event_msg_type = 'FREE_THROW') AS FTM,

    COALESCE(main.missed_free, 0) AS missed_free_throws,

    COALESCE(ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE pr.event_msg_type = 'FREE_THROW'
              AND pr.score_margin IS NOT NULL
        )
        /
        NULLIF(
            COUNT(*) FILTER (WHERE pr.event_msg_type = 'FREE_THROW') + COALESCE(main.missed_free, 0), 0
        ), 2), 00.00) AS FT_percentage

FROM missed_shots as main
LEFT JOIN play_records_with_prev as  pr ON main.player1_id = pr.player1_id
LEFT JOIN players as p ON main.player1_id = p.id
GROUP BY main.player1_id, p.first_name, p.last_name, main.missed_shots, main.missed_free
ORDER BY points DESC, shooting_percentage DESC, FT_percentage DESC, main.player1_id;












