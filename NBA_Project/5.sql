/*
TASK: Home and Away Match Statistics by Team Identity and Historical Name

DESCRIPTION:
For each NBA team (based on historical team names and activity periods), calculate:
- The number of games played as the home team
- The number of games played as the away team
- The total number of games
- The percentage of home and away games

Special attention must be given to team identity based on:
1. `team_id` – Team's unique identifier
2. `team_name` – Historical name of the team, which may change over time

NAME VALIDITY LOGIC:
- Use columns `year_founded` and `year_active_till` from the team name history
- If `year_active_till = 2019`, consider the name still active
- Otherwise:
  • A team's name is valid from **July 1st** of `year_founded`
  • Until **June 30th** of `year_active_till`
- Only count games that fall within this date range to associate the correct team name

OUTPUT COLUMNS:
• team_id                   - ID of the team
• team_name                - Historical name of the team
• number_away_matches      - Total number of away games
• percentage_away_matches  - Away games as a percentage of total, rounded to 2 decimals
• number_home_matches      - Total number of home games
• percentage_home_matches  - Home games as a percentage of total, rounded to 2 decimals
• total_games              - Total number of games played (home + away)

ORDERING:
- Primary: team_id ASC
- Secondary: team_name ASC
*/


WITH team_games AS (
    SELECT
        main.team_id AS team_id,
        main.city || ' ' || main.nickname AS team_name,
        g.id AS game_id,
        g.home_team_id,
        g.away_team_id,
        g.game_date,
        'home' AS team_role
    FROM team_history as main
    JOIN games as g ON main.team_id = g.home_team_id
    WHERE g.game_date >= TO_DATE(main.year_founded || '-07-01', 'YYYY-MM-DD')
      AND (main.year_active_till = 2019 OR g.game_date <= TO_DATE(main.year_active_till || '-06-30', 'YYYY-MM-DD'))

    UNION ALL

    SELECT
        main.team_id AS team_id,
        main.city || ' ' || main.nickname AS team_name,
        g.id AS game_id,
        g.home_team_id,
        g.away_team_id,
        g.game_date,
        'away' AS team_role
    FROM team_history as main
    JOIN games as g ON main.team_id = g.away_team_id
    WHERE g.game_date >= TO_DATE(main.year_founded || '-07-01', 'YYYY-MM-DD')
      AND (main.year_active_till = 2019 OR g.game_date <= TO_DATE(main.year_active_till || '-06-30', 'YYYY-MM-DD'))
)
SELECT
    main.team_id,
    main.team_name,

    COUNT(*) FILTER (WHERE main.team_role = 'away') AS number_away_matches,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE main.team_role = 'away') / COUNT(*), 2
    ) AS percentage_away_matches,

    COUNT(*) FILTER (WHERE main.team_role = 'home') AS number_home_matches,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE main.team_role = 'home') / COUNT(*), 2
    ) AS percentage_home_matches,

    COUNT(*) AS total_games

FROM team_games AS main
GROUP BY main.team_id, main.team_name
ORDER BY main.team_id, main.team_name;
