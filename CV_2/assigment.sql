----------------------------------------------------  Movies

/*
1. For cases where the same reviewer has rated the same film twice
   and the later review has a higher star rating than the previous one,
   return the reviewer’s name and the film title.
   Use a window function to compare consecutive ratings for the same film
   by the same reviewer.
*/


SELECT 
    reviewers.name AS "Name",
    movies.title AS "Movie"
FROM 
(
    SELECT
        ratings.rid,
        ratings.mid,
        ratings.stars,
        LAG(ratings.stars) OVER (partition by 
                                    ratings.rid, 
                                    ratings.mid
                                ORDER BY 
                                    ratings.rid,
                                    ratings.mid,
                                    ratings.ratingdate)
                                AS previous
    FROM
        ratings
) AS Subquery
INNER JOIN
    reviewers ON reviewers.rid = Subquery.rid
INNER JOIN 
    movies ON movies.mid = Subquery.mid
WHERE
    previous < stars AND (
        SELECT
            COUNT(ratings.rid)
        FROM
            ratings
        WHERE ratings.rid = Subquery.rid
    ) = 2;


/*
2. For each film that has at least one rating, return the film title
   along with the highest number of stars it received.
   Use a window function to rank the ratings per film and select the top one.
*/

SELECT 
    subquery.title,
    subquery.stars,
    DENSE_RANK() OVER (ORDER BY
                        subquery.stars DESC
                    ) AS Ranking
FROM 
(
    SELECT DISTINCT ON (ratings.mid)
        ratings.mid,
        movies.title,
        ratings.stars
    FROM
        ratings
    INNER JOIN 
        movies ON movies.mid = ratings.mid
    ORDER BY
        ratings.mid,
        ratings.stars DESC
) AS subquery;


SELECT DISTINCT
    *
FROM
(
SELECT 
    movies.title,
    ratings.stars,
    DENSE_RANK() OVER (PARTITION BY 
    ratings.mid
    ORDER BY
        ratings.stars DESC) AS ranking
FROM
    ratings
INNER JOIN 
    movies ON movies.mid = ratings.mid
)
WHERE
    ranking = 1;

/*
3. Return the review details (reviewer name, film title, and stars)
   for each review that has the minimum star rating in the database.
   Use a window function to assign a rank based on the stars
   and filter for the lowest ranked reviews.
*/

SELECT DISTINCT
    *
FROM
    (SELECT 
        reviewers.name,
        movies.title,
        ratings.stars,
        DENSE_RANK() OVER (ORDER BY ratings.stars) AS ranking
    FROM
        ratings
    INNER JOIN
        movies ON movies.mid = ratings.mid
    INNER JOIN
        reviewers ON reviewers.rid = ratings.rid
)
WHERE 
    ranking = 1;

/*
4. Return the names of all reviewers who have contributed
   three or more reviews.
   Use a window function to count the number of reviews per reviewer
   instead of using HAVING.
*/

SELECT
    COUNT(ratings.rid) AS review_count,
    reviewers.name
FROM 
    reviewers
INNER JOIN
    ratings ON ratings.rid = reviewers.rid
GROUP BY
    reviewers.rid,
    reviewers.name
HAVING
    COUNT(ratings.rid) >= 3;


SELECT 
    *
FROM
(   SELECT 
        reviewers.name,
        COUNT(ratings.rid) OVER (PARTITION BY ratings.rid) as review_count
    FROM
        reviewers
    INNER JOIN
        ratings ON ratings.rid = reviewers.rid
)
WHERE
    review_count >= 3;

/*
5. Find the film or films with the highest average rating.
   Use a window function to rank films by their average rating
   and return the one that is 5th in the leaderboard.
*/

SELECT 
    *
FROM
(
    SELECT 
        *,
        RANK() OVER (ORDER BY avg_stars DESC) AS ranking
    FROM 
    (   SELECT DISTINCT
            movies.title,
            ROUND(AVG(ratings.stars) OVER (PARTITION BY movies.title), 2) as avg_stars
        FROM
            movies
        INNER JOIN 
            ratings ON ratings.mid = movies.mid
    )
)
WHERE
    ranking = 5;



SELECT 
    *
FROM 
(   SELECT DISTINCT
        movies.title,
        ROUND(AVG(ratings.stars), 2) as avg_count,
        RANK() OVER (ORDER BY ROUND(AVG(ratings.stars), 2) DESC) AS ranking
    FROM
        movies
    INNER JOIN 
        ratings ON ratings.mid = movies.mid
    GROUP BY
        movies.title
)
WHERE
    ranking = 5;


-----------------------------------------------------    Programmers

/*
6. Return the name(s) of the project(s) that have the most programmers
   working on them.
   Use a window function to rank projects by the number of programmers
   (and lexicographically by project name if there is a tie)
   and select the top project(s).
*/

WITH most_programmers AS (
    SELECT DISTINCT
        projects.name,
        COUNT(projects.id) OVER (PARTITION BY projects.id) AS programmer_count
    FROM
        projects
    INNER JOIN
        projects_programmers AS pp ON pp.project_id = projects.id
),
rank_the_projects AS (
    SELECT
        *,
        RANK() OVER (ORDER BY programmer_count DESC) AS ranking
    FROM
        most_programmers AS mp
)
SELECT
    *
FROM
    rank_the_projects AS rtp
WHERE
    rtp.ranking = 1
ORDER BY
    rtp.name;


WITH rank_the_most_programmers AS (
    SELECT
        projects.name,
        COUNT(projects.id) AS programmer_count,
        RANK() OVER (ORDER BY COUNT(projects.id) DESC) AS ranking
    FROM
       projects
    INNER JOIN
        projects_programmers AS pp ON pp.project_id = projects.id
    GROUP BY
        projects.name,
        projects.id
)
SELECT 
    *
FROM
    rank_the_most_programmers AS rtmp
WHERE 
    rtmp.ranking = 1
ORDER BY 
    rtmp.name;


WITH max_programmers AS (
    SELECT 
        projects.name,
        COUNT(projects.id) AS programmer_count
      FROM
       projects
    INNER JOIN
        projects_programmers AS pp ON pp.project_id = projects.id
    GROUP BY
        projects.name,
        projects.id
    ORDER BY
        2 DESC
),
maximum AS (
SELECT 
    *
FROM
    max_programmers
LIMIT 
    1
)
SELECT
    *
FROM
    max_programmers, maximum
WHERE 
    max_programmers.programmer_count = maximum.programmer_count

WITH max_programmers AS (
    SELECT 
        projects.name,
        COUNT(projects.id) AS programmer_count
      FROM
       projects
    INNER JOIN
        projects_programmers AS pp ON pp.project_id = projects.id
    GROUP BY
        projects.name,
        projects.id
    ORDER BY
        2 DESC
),
maximum AS (
SELECT 
    *
FROM
    max_programmers
LIMIT 
    1
)
SELECT
    *
FROM
    max_programmers
INNER JOIN
    maximum ON maximum.programmer_count = max_programmers.programmer_count


SELECT 
        projects.name,
        COUNT(projects.id) AS programmer_count
      FROM
       projects
    INNER JOIN
        projects_programmers AS pp ON pp.project_id = projects.id
    GROUP BY
        projects.name,
        projects.id
    HAVING 
    COUNT(projects.id) = (SELECT 
        COUNT(projects.id) AS panda
      FROM
       projects
    INNER JOIN
        projects_programmers AS pp ON pp.project_id = projects.id
    GROUP BY
        projects.name
    ORDER BY
        panda DESC
    LIMIT 
        1)


/*
7. For each programming language, return the language name along
   with the name of its oldest project.
   If a language has no project, return 'No project yet'.
   Use a window function to rank projects by creation date within each language.
*/

SELECT
    label,
    COALESCE(name, 'No Project yet')
FROM
    (SELECT 
        languages.label,
        projects.name,
        RANK() OVER (PARTITION BY languages.label ORDER BY projects.created_at) AS ranking
    FROM
        languages
    LEFT JOIN
        projects ON projects.language_id = languages.id
    )
WHERE
    ranking = 1;


SELECT DISTINCT ON (languages.label)
    languages.label,
    COALESCE(projects.name, 'No Project yet')
FROM
    languages
LEFT JOIN 
    projects ON projects.language_id = languages.id
ORDER BY
    languages.label,
    projects.created_at;

/*
8. Write a SELECT that returns the name of each programming language
   along with the name of the oldest project for that programming language.
   For those languages that have no project,
   have written in project column 'No project yet'.
*/

-- LoL it's the same I did up there with disticnt on
SELECT DISTINCT ON (languages.label)
    languages.label,
    COALESCE(projects.name, 'No Project yet')
FROM
    languages
LEFT JOIN 
    projects ON projects.language_id = languages.id
ORDER BY
    languages.label,
    projects.created_at;


WITH oldest AS (
    SELECT
        languages.id AS language_id,
        MIN(projects.created_at) AS oldest_date
    FROM 
        languages
    LEFT JOIN
        projects ON projects.language_id = languages.id    
    GROUP BY
        languages.id
)
SELECT
    languages.label AS language_name,
    COALESCE(projects.name, 'No Project Yet') AS oldest_project
FROM
    languages
INNER JOIN 
    oldest ON oldest.language_id = languages.id
LEFT JOIN 
    projects ON projects.language_id = languages.id AND projects.created_at = oldest.oldest_date
ORDER BY
    languages.label;

/*
9. Return the name and registration date of the most recent programmer
   whose name starts with the letter 'R'.
   Use a window function to rank programmers by their registration date
   in descending order and select the top one.
*/

SELECT 
    *
FROM
(   SELECT
        programmers.name,
        RANK() OVER (ORDER BY programmers.signed_in_at DESC) AS ranking
    FROM
        programmers
    WHERE
        programmers.name ILIKE 'r%'
)
WHERE
    ranking = 1;

/*
10. Return the name of the city that shows the most stable temperature
    (i.e. the smallest standard deviation of temperatures).
    Use a window function to rank cities by their temperature standard deviation.
*/

SELECT
    city_name,
    stddev_temperature
FROM (
    SELECT
        Cities.name AS city_name,
        ROUND(STDDEV_POP(Measurements.temperature), 2) AS stddev_temperature,
        RANK() OVER (ORDER BY STDDEV_POP(Measurements.temperature)) AS ranking
    FROM
        Cities
    INNER JOIN 
        Sensors ON Sensors.city_id = Cities.id
    INNER JOIN 
        Measurements ON Measurements.sensor_id = Sensors.id
    GROUP BY
        Cities.name
)
WHERE
    ranking = 1;

/*
11. For each region, return the names of the top three cities where
    the highest temperature was recorded, along with that temperature.
    Use a window function to rank cities within each region
    by their maximum recorded temperature.
*/

SELECT
    *
FROM
(   SELECT
        Cities.name AS city,
        Regions.name AS region,
        MAX(Measurements.temperature) AS temperature,
        RANK() OVER (PARTITION BY Regions.id ORDER BY MAX(Measurements.temperature) DESC) AS ranking
    FROM
        Cities
    INNER JOIN
        Regions ON Regions.id = Cities.region_id
    INNER JOIN
        Sensors On Sensors.city_id = Cities.id
    INNER JOIN
        Measurements ON Measurements.sensor_id = Sensors.id
    GROUP BY
        Cities.id,
        Cities.name,
        Regions.id,
        Regions.name
)
WHERE
    ranking <= 3;


---- ANTI JOIN
SELECT
    languages.label
FROM
    languages
WHERE NOT EXISTS (
    SELECT 
        1
    FROM 
        projects
    WHERE 
        projects.language_id = languages.id
);
