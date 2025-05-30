/* 
Find the titles of all the films directed by Steven Spielberg.
*/

SELECT 
    movies.title AS "Title"
FROM 
    movies
WHERE
    director = 'Steven Spielberg';

/* 
Find all the years in which at least one film was rated 4 or 5 
and rank them in ascending order.
*/

SELECT DISTINCT
    movies.year AS "Year"
FROM
    movies
INNER JOIN 
    ratings ON ratings.mid = movies.mid
WHERE
    ratings.stars >= 4
ORDER BY
    movies.year;

/* 
Find the titles of all movies that have no ratings.
*/

SELECT
    movies.title AS "Title"
FROM
    movies
LEFT JOIN 
    ratings ON ratings.mid = movies.mid
WHERE
    ratings.mid IS NULL;



/* 
Some reviewers did not provide a date in their reviews. 
Find the names of all reviewers who have reviews with a NULL value for the review date.
*/

SELECT
    reviewers.name as "Name of reviewer"
FROM
    reviewers
INNER JOIN 
    ratings ON ratings.rid = reviewers.rid
WHERE 
    ratings.ratingdate IS NULL;

/* 
Write a query that returns the rating data in a clearer format: 
the reviewer’s name, the film title, the number of stars, and the date of the rating. 
Also sort the results first by reviewer name, then by movie title, and finally by number of stars.
*/

Select 
    reviewers.name AS "Name of reviewer",
    movies.title AS "Movie",
    ratings.stars AS "Stars",
    ratings.ratingdate AS "Date"
FROM
    reviewers
INNER JOIN 
    ratings ON ratings.rid = reviewers.rid
INNER JOIN
    movies on movies.mid = ratings.mid
ORDER BY
    reviewers.name, movies.title, ratings.stars DESC;

/* 
In cases where the same reviewer has rated the same film twice 
and gave a higher rating the second time, please return the reviewer’s name and the title of the film.
*/

SELECT DISTINCT
    reviewers.name AS "Name of reviewer",
    movies.title AS "Movie"
FROM
    reviewers
INNER JOIN 
    ratings AS r1 on r1.rid = reviewers.rid
INNER JOIN
    ratings AS r2 on r1.rid = r2.rid
    AND r1.mid = r2.mid
    AND r1.ratingdate < r2.ratingdate
    AND r1.stars < r2.stars
INNER JOIN 
    movies ON movies.mid = r1.mid
WHERE
    (SELECT
        COUNT(r3.rid)
    FROM
        ratings AS r3
    WHERE r3.rid = r1.rid AND r3.mid = r1.mid) = 2;

/* 
For each film that has at least one rating, find the highest number of stars the film has received. 
Return the name of the film and the number of stars. Sort the results by the title of the film.
*/

Select DISTINCT ON (movies.title)
    movies.title AS "Movie",
    ratings.stars AS "Stars"
FROM
    movies
INNER JOIN
    ratings ON ratings.mid = movies.mid
ORDER BY
    movies.title, ratings.stars DESC;

/* 
For each film, return the title and the "rating difference", i.e. 
the difference between the highest and lowest rating that the film received. 
Sort first by the rating difference from highest to lowest, and then by the title of the film.
*/

WITH MAX_RATING AS (
    Select DISTINCT ON (movies.title)
    movies.title AS title,
    ratings.stars  AS stars
FROM 
    movies
INNER JOIN 
    ratings on ratings.mid = movies.mid

ORDER BY
    movies.title, ratings.stars DESC
),

MIN_RATINGS AS (
    Select DISTINCT ON (movies.title)
    movies.title AS title,
    ratings.stars AS stars
FROM 
    movies
INNER JOIN 
    ratings on ratings.mid = movies.mid
ORDER BY
    movies.title, ratings.stars
)
Select 
    MX.title AS "Movie",
    MX.stars - MN.stars AS "Stars difference"
FROM
    MAX_RATING AS MX
INNER JOIN
    MIN_RATINGS AS MN on MN.title = MX.title;

/* 
Find the names of all the reviewers who rated the movie "Gone with the Wind".
*/

SELECT DISTINCT
    reviewers.name AS "Name of reviewer"
FROM 
    reviewers
INNER JOIN
    ratings ON reviewers.rid = ratings.rid
INNER JOIN
    movies ON movies.mid = ratings.mid
WHERE
    movies.title = 'Gone with the Wind';

/* 
For each review where the reviewer is also the director of the film, -> of that FILM or just any FILM ??
return the name of the reviewer, the title of the film and the number of stars.
*/

-- 1. that film
Select
    reviewers.name AS "Name of reviewer",
    movies.title AS "Movie",
    ratings.stars AS "Stars"
FROM
    reviewers
INNER JOIN
    ratings ON ratings.rid = reviewers.rid
INNER JOIN 
    movies ON movies.mid = ratings.mid
WHERE
    reviewers.name = movies.director;

-- 2. director of any film
Select 
    reviewers.name AS "Name of reviewer",
    movies.title AS "Movie",
    ratings.stars AS "Stars"
From 
    reviewers
INNER JOIN
    ratings ON ratings.rid = reviewers.rid
INNER JOIN 
    movies ON movies.mid = ratings.mid
WHERE
    reviewers.name IN ( SELECT
                            movies.director
                        FROM 
                            movies );

/* 
Return all the reviewers’ names and film titles in one list, alphabetized. 
(Sorting by the first name of the reviewer and the first word in the movie title is sufficient; 
there is no need to specifically handle surnames or remove "The".)
*/

SELECT
    reviewers.name AS "Name of reviewer",
    movies.title AS "Movie"
FROM
    reviewers
INNER JOIN
    ratings ON ratings.rid = reviewers.rid
INNER JOIN 
    movies ON movies.mid = ratings.mid
ORDER BY
    SPLIT_PART(reviewers.name, ' ', 1), SPLIT_PART(movies.title, ' ', 1);



/* 
Find the titles of all the films not rated by Chris Jackson.
*/

Select
    movies.title AS "Movie"
FROM 
    movies
INNER JOIN
    ratings ON ratings.mid = movies.mid
INNER JOIN
    reviewers ON ratings.rid = reviewers.rid
WHERE
    reviewers.name <> 'Chris Jackson';

/* 
For any pairs of reviewers who both gave ratings to the same film, 
please return the names of both reviewers. Remove duplicates, do not pair a reviewer with themselves, 
and include each pair only once. For each pair, return the names in alphabetical order.
*/

Select DISTINCT
    rev1.name AS "Reviewer 1 name",
    rev2.name AS "Reviewer 2 name"
FROM
    reviewers AS rev1
INNER JOIN
    ratings AS r1 ON r1.rid = rev1.rid
INNER JOIN
    ratings AS r2 ON r1.mid = r2.mid
    AND r1.rid < r2.rid
INNER JOIN
    reviewers AS rev2 ON rev2.rid = r2.rid

/* 
For each review that is currently the lowest (has the fewest stars) in the database, 
return the reviewer’s name, the title of the film, and the number of stars.
*/

WITH lowest_rank AS (
    SELECT
        ratings.stars AS stars
    FROM 
        ratings
    ORDER BY
        ratings.stars
    LIMIT 
        1
)
Select 
    reviewers.name AS "Name of reviewer",
    movies.title AS "Movie",
    ratings.stars AS "Stars"
FROM
    reviewers
INNER JOIN
    ratings ON ratings.rid = reviewers.rid
INNER JOIN 
    movies ON movies.mid = ratings.mid
INNER JOIN
    lowest_rank ON lowest_rank.stars = ratings.stars;


/* 
Rank the movie titles and average ratings, from best rated to worst rated. 
If two or more films have the same average rating, sort them alphabetically.
*/

--                                         I wanted to do it without GROUP BY and WF, but it seems they wanted us to use it, so nevermid ...              --

SELECT
    movies.title AS "Movie",
    ROUND(AVG(ratings.stars), 2) AS "Average Rating"
From 
    movies
INNER JOIN
    ratings on ratings.mid = movies.mid
GROUP BY
    movies.title
ORDER BY
    "Average Rating" DESC, movies.title;

/* 
Find the names of all reviewers who contributed three or more reviews. 
(As an extra challenge, try writing the query without using HAVING or COUNT.)
*/

-- 1.
SELECT 
    reviewers.name AS "Name Of Reviewer",
    COUNT(ratings.rid) AS "Ratings Count"
From 
    reviewers
INNER JOIN
    ratings ON ratings.rid = reviewers.rid
GROUP BY
    reviewers.name
Having 
    COUNT(ratings.rid) > 2
ORDER BY
    "Ratings Count" DESC, "Name Of Reviewer";

-- 2
SELECT *
FROM (
    SELECT DISTINCT
        reviewers.name AS "Name Of Reviewer",
        SUM(1) OVER (PARTITION BY reviewers.rid) AS "Ratings Count"
    FROM 
        reviewers
    INNER JOIN
         ratings ON ratings.rid = reviewers.rid
) sub
WHERE 
    "Ratings Count" > 2
ORDER BY 
    "Ratings Count" DESC, "Name Of Reviewer";


/* 
Some directors have directed more than one film. For all such directors, 
return the titles of all the films they have directed, together with the name of the director. 
Sort by the name of the director, then by the name of the film. 
(As an extra challenge, try writing the query with and without COUNT.)
*/

-- 1
WITH movie_count AS (
    SELECT
        movies.director AS "Director"
    FROM
        movies
    WHERE 
        movies.director IS NOT NULL
    GROUP BY
        movies.director
    Having 
        COUNT(movies.director) > 1
)
SELECT DISTINCT
    mc."Director",
    movies.title AS "Movie"
FROM
    movie_count AS mc
INNER JOIN 
    movies ON movies.director = mc."Director"
ORDER BY
    mc."Director";

-- 2
WITH movie_count AS (
    SELECT
        movies.director AS "Director",
        SUM(1) OVER (PARTITION BY movies.director) AS movie_count
    FROM
        movies
    WHERE 
        movies.director IS NOT NULL 
)
SELECT DISTINCT
    mc."Director",
    movies.title AS "Movie"
FROM
    movie_count AS mc
INNER JOIN
    movies ON movies.director = mc."Director"
WHERE
    mc.movie_count > 1

SELECT 
    m1.director,
    m1.title
FROM 
    movies AS m1
WHERE EXISTS (
    SELECT
        1
    FROM 
        movies m2
    WHERE 
        m2.director = m1.director
      AND m2.mid <> m1.mid  -- aspoň jeden iný film
)
ORDER BY
    m1.director,
    m1.title;

/* 
Find the film(s) with the highest average rating. 
Return the title(s) of the film and the average rating.
*/

WITH average_rating AS (
    SELECT
        movies.title AS "Movie",
        ROUND(AVG(ratings.stars), 2) AS "Average Rating"
    FROM 
        movies
    INNER JOIN
        ratings ON ratings.mid = movies.mid
    GROUP BY
        movies.title
),
max_rating AS (
    SELECT
        MAX(ar."Average Rating") as "Rating"
    FROM
        average_rating AS ar
)
SELECT
    ar."Movie",
    mr."Rating"
From 
    average_rating AS ar
INNER JOIN
    max_rating AS mr On mr."Rating" = ar."Average Rating"


/* 
Find the film(s) with the lowest average rating. 
Return the title(s) of the film and the average rating.
*/

WITH average_ratings AS (
    SELECT
        movies.title AS "Movie",
        ROUND(AVG(ratings.stars), 2) as "Average Rating"
    FROM
        movies
    INNER JOIN
        ratings ON ratings.mid = movies.mid
    GROUP BY
        movies.title
),
lowest_rating AS (
    SELECT
        MIN(ar."Average Rating") AS "Rating"
    FROM
        average_ratings AS ar
)
SELECT
    ar."Movie",
    lr."Rating"
FROM
    average_ratings AS ar
INNER JOIN
    lowest_rating AS lr on lr."Rating" = ar."Average Rating";

/* 
Find the difference between the average rating of movies released before 1980 
and the average rating of movies released after 1980. 
(Be sure to calculate the average rating for each movie first, 
and then average these averages for movies released before 1980 and for movies released after 1980. 
Don’t just calculate the overall average rating before and after 1980.)
*/

WITH average_ratings AS (
    SELECT
        movies.title AS "Movie",
        AVG(ratings.stars) AS "Average Rating",
        'AFTER' AS "1980"
    FROM
        movies
    INNER JOIN  
        ratings ON ratings.mid = movies.mid
    WHERE
        movies.year >= 1980
    GROUP BY
        movies.title 

    UNION ALL

    SELECT
        movies.title AS "Movie",
        AVG(ratings.stars) AS "Average Rating",
        'BEFORE' AS "1980"
    FROM
        movies
    INNER JOIN  
        ratings ON ratings.mid = movies.mid
    WHERE
        movies.year < 1980
    GROUP BY
        movies.title 
),
avg_all AS (
    SELECT 
        ar."1980",
        ROUND(AVG(ar."Average Rating"), 2) AS "Average Rating"
    FROM 
        average_ratings AS ar
    GROUP BY
        ar."1980"
)
SELECT
    MAX("Average Rating") FILTER (WHERE avg_all."1980" = 'BEFORE') AS "Average Rating Before 1980",
    MAX("Average Rating") FILTER (WHERE avg_all."1980" = 'AFTER') AS "Average Rating After 1980",
    MAX("Average Rating") FILTER (WHERE avg_all."1980" = 'BEFORE') - 
    MAX("Average Rating") FILTER (WHERE avg_all."1980" = 'AFTER') AS "Difference Of Averages"
FROM
    avg_all


--                                                       PROGRAMMERS Dataset

/*
Write query, which returns the names and registration dates of all programmers.
*/

SELECT 
    name,
    signed_in_at
FROM 
    programmers

/*
Write query to return the names and registration dates of all programmers whose names begin with the letter R.
*/

SELECT 
    name, 
    signed_in_at
FROM 
    programmers
WHERE 
    name LIKE 'R%';


/*
Type SELECT, which returns the name and registration date of the most recent programmer whose name begins with the letter R. Hint: limit.
*/

SELECT
    name,
    signed_in_at
FROM
    programmers
WHERE
    name LIKE 'R%'
ORDER BY
    signed_in_at DESC
LIMIT
    1;

/*
Write SELECT, which returns the names of all programmers who have a name shorter than 12 characters.
*/

SELECT 
    name
FROM 
    programmers
WHERE 
    LENGTH(name) < 12;


/*
Type SELECT, which will return the names of all programmers, with those who have a name longer than 12 characters having it truncated to 12 characters.
*/

SELECT 
    CASE 
        WHEN LENGTH(name) > 12 THEN SUBSTRING(name, 1, 12)
        ELSE name
    END AS "Truncated Name"
FROM programmers;


/*
Type SELECT, which returns the names of all programmers in reverse and in upper case.
*/

SELECT
    REVERSE(UPPER(name)) AS "Reversed UpperCase Name"
FROM
    programmers

/*
Write a SELECT that returns only the first word of the names of all programmers.
*/

SELECT 
    SPLIT_PART(name, ' ', 1)
FROM
    programmers

/*
Type SELECT to return the names and registration dates of all programmers who registered in 2016.
*/

SELECT
    name,
    signed_in_at
FROM
    programmers
WHERE
    EXTRACT(YEAR FROM signed_in_at) = 2016;

/*
Type SELECT to return the names and registration dates of all programmers who registered in February 2016.
*/

SELECT
    name,
    signed_in_at
FROM
    programmers
WHERE 
    signed_in_at BETWEEN '2016-02-01' AND '2016-02-29';


/*
Type SELECT to return the names of all programmers and the number of days between their registration date and the first of April 2016. Ordered from least to greatest.
*/

SELECT
    name, 
    ABS(DATE '2016-04-01' - signed_in_at) AS "Day Difference"
FROM
    programmers
ORDER BY
    "Day Difference"

/*
Write a SELECT that returns the label of all languages that have at least one project.
*/

SELECT DISTINCT
    label
FROM
    languages
INNER JOIN
    projects ON projects.language_id = languages.id;

/*
Write SELECT that returns the label of all languages that have at least one project that started in 2014.
*/

SELECT DISTINCT
    label
FROM
    languages
INNER JOIN
    projects ON projects.language_id = languages.id
WHERE
    EXTRACT(YEAR FROM projects.created_at) = 2014;


/*
Write a SELECT that returns the names of all projects that are programmed in ruby or python (Hint: IN).
*/

SELECT
    name
FROM
    projects
INNER JOIN 
    languages on languages.id = projects.language_id
WHERE
    languages.label IN ('ruby', 'python');

/*
Write a SELECT that returns the names of all python programmers.
*/

SELECT DISTINCT
    programmers.name
FROM
    programmers
INNER JOIN
    projects_programmers AS pp ON pp.programmer_id = programmers.id
INNER JOIN
    projects ON pp.project_id = projects.id
INNER JOIN
    languages ON languages.id = projects.language_id
WHERE
    languages.label = 'python'

/*
Write a SELECT that returns the names of all python programmers who are owners (even non-python) of the project.
*/

SELECT DISTINCT
    programmers.name
FROM
    programmers
INNER JOIN
    projects_programmers AS pp ON pp.programmer_id = programmers.id
INNER JOIN
    projects ON pp.project_id = projects.id
INNER JOIN
    languages ON languages.id = projects.language_id
WHERE
    languages.label = 'python' AND EXISTS (Select 
                                                1
                                            FROM
                                                projects_programmers AS pp2
                                            INNER JOIN
                                                programmers AS p2 ON pp2.programmer_id = p2.id 
                                            WHERE pp2.owner = TRUE and p2.id = programmers.id);

/*
Write a SELECT that returns the average number of days (rounded to integers) that all programmers are registered in our database.
*/

SELECT
    CAST(AVG(DATE(NOW()) - signed_in_at) AS INTEGER) AS "Average Days Of Programmers"
FROM
    programmers

/*
Type SELECT to return the total number of days that ruby programmers are registered in our database.
*/

SELECT DISTINCT
    SUM(DATE(NOW()) - signed_in_at)
FROM
    programmers
INNER JOIN
    projects_programmers AS pp ON pp.programmer_id = programmers.id
INNER JOIN
    projects ON pp.project_id = projects.id
INNER JOIN
    languages ON languages.id = projects.language_id
WHERE
    languages.label = 'ruby'

/*
Type SELECT to return the name of the project and the number of programmers working on it.
*/

SELECT
    projects.name AS project_name,
    COUNT(pp.programmer_id) AS "Number Of Programmers"
FROM
    projects
JOIN
    projects_programmers pp ON pp.project_id = projects.id
GROUP BY
    projects.name;


/*
Type SELECT, which returns the name of the project and the total number of days the
 programmers have worked on it (assume they have been working on the project every day since they joined).
*/

-- Didn'subquery understad, did the the time for every programmer from the very beggining of the project
WITH programmer_count AS (
    SELECT
    projects.name AS "Name",
    COUNT(pp.programmer_id) AS "Programmers"
FROM
    projects
INNER JOIN
    projects_programmers AS pp ON pp.project_id = projects.id
GROUP BY
    projects.name
)
SELECT
    pc."Name",
    pc."Programmers" * (DATE(NOW()) - projects.created_at)
FROM
    projects
INNER JOIN
    programmer_count AS pc ON pc."Name" = projects.name


SELECT
    projects.name AS "Name",
    SUM(DATE(NOW()) - DATE(pp.joined_at))
FROM
    projects
INNER JOIN
    projects_programmers AS pp ON pp.project_id = projects.id
GROUP BY
    projects.name;

/*
Type SELECT, which returns the name of the project on which the most programmers are working.
 If there are more than one such project, apply lexicographic sorting and list the first one.
*/


    SELECT
        projects.name,
        COUNT(pp.programmer_id) AS "Count"
    FROM
        projects
    INNER JOIN
        projects_programmers AS pp ON pp.project_id = projects.id
    GROUP BY
        projects.name
    ORDER BY
        COUNT(pp.programmer_id) DESC,
         projects.name
    LIMIT
        1;


/*
Type SELECT, which returns the name of the project on which the most programmers are working. 
If there are more such projects, list the names of all.
*/

WITH programmers_count AS (
    SELECT
        projects.name AS "Name",
        COUNT(pp.programmer_id) AS "Count"
    FROM
        projects
    INNER JOIN
        projects_programmers AS pp ON pp.project_id = projects.id
    GROUP BY
        projects.name
),
max_count AS (
    SELECT
        MAX("Count") AS "Max Count"
    FROM
        programmers_count
)
SELECT
    pc."Name",
    pc."Count"
FROM
    programmers_count AS pc
INNER JOIN
    max_count AS mc ON mc."Max Count" = pc."Count";

/*
Write a SELECT that returns the name of each programming language along with the number of programmers who use it. Sorted from largest to smallest.
*/
SELECT
    languages.label,
    COUNT(DISTINCT pp.programmer_id) AS "Programmers Count"
FROM
    languages
INNER JOIN 
    projects ON projects.language_id = languages.id
INNER JOIN
    projects_programmers AS pp ON pp.project_id = projects.id
GROUP BY
    languages.label
ORDER BY
    "Programmers Count" DESC;

/*
Write a SELECT that returns the name of each programming language along with the name of the oldest
 project for that programming language. For those languages that have no project, have written in project column ’No project yet’.
*/


SELECT
    languages.label AS "Language",
    COALESCE(
        (
            SELECT 
                projects.name
            FROM 
                projects 
            WHERE 
                projects.language_id = languages.id
            ORDER BY
                projects.created_at ASC
            LIMIT
                1
        ),
        'No project yet'
    ) AS "The Oldest Project"
FROM
    languages;

/*
Write a SELECT that returns the name of each programming language along with the number of projects
 in which the language is used. Ordered from largest to smallest, let the languages be sorted lexicographically
  if the number of projects is equal. Try using the column index instead of the column name in the sorting.
*/

SELECT
    languages.label AS "Language",
    COUNT(projects.id) AS "Number Of Projects"
FROM 
    languages
LEFT JOIN
    projects ON projects.language_id = languages.id
GROUP BY
    languages.label
ORDER BY
    2 DESC, 1;


--                                               Movies Dataset


/*
Write a SELECT that returns the number of the month of the year and the average temperature
for that month (two decimal places) for the months of 2015, arranged by month in ascending order.
*/

SELECT
    TO_CHAR(meas.measured_at, 'Month') AS "Month",
    ROUND(AVG(meas.temperature), 2) AS "Temperature"
FROM
    Measurements AS meas
WHERE
    EXTRACT(YEAR FROM meas.measured_at) = 2015
GROUP BY
    "Month",
    EXTRACT(MONTH FROM meas.measured_at)
ORDER BY
    EXTRACT(MONTH FROM meas.measured_at);


/*
Write a SELECT that returns the numbers of those months in which the average temperature was
greater than the overall average temperature. Sorted in ascending order.
Also list the temperature, rounded to two decimal places.

Notes: Depending on your understanding of the problem, you may want to consider the year distinction
or a simpler approach in general for the months.
*/

-- general approach
-- 1.
WITH overall_temp AS (
    SELECT
        ROUND(AVG(meas.temperature), 2) AS "Average Temp"
    FROM
        Measurements AS meas
),
months_avg AS (
    SELECT
        ROUND(AVG(meas.temperature), 2) AS "Average Temp",
        EXTRACT(MONTH FROM meas.measured_at) AS "Month"
    FROM 
        Measurements AS meas
    GROUP BY
        "Month"
)
SELECT
    ma."Month",
    ma."Average Temp"
FROM
    months_avg AS ma
INNER JOIN
    overall_temp ON overall_temp."Average Temp" < ma."Average Temp"
ORDER BY
    "Month";

-- 2.
SELECT
    EXTRACT(MONTH FROM meas.measured_at) AS "Month",
    ROUND(AVG(temperature), 2) AS "Average Month Temp"
FROM 
    Measurements AS meas
GROUP BY
    "Month"
HAVING ROUND(AVG(temperature), 2) > (
    SELECT
        AVG(temperature)
    FROM
        Measurements
    )
ORDER BY
    "Month";

-- year aprroach  (I just realized there is only year 2015 after I done it -.-) (I manually added just 1 line of code, so idk what is it gonna do :D)

SELECT
    *
FROM (
    SELECT
        EXTRACT(YEAR FROM meas.measured_at) AS "Year",
        EXTRACT(MONTH FROM meas.measured_at) AS "Month",
        ROUND(AVG(meas.temperature), 2) AS "Average Month Temp"
    FROM
        Measurements AS meas
    GROUP BY
        EXTRACT(YEAR FROM meas.measured_at),
        EXTRACT(MONTH FROM meas.measured_at)
) subquery
WHERE
    subquery."Average Month Temp" >= (
        SELECT
            AVG(meas2.temperature)
        FROM
            Measurements AS meas2
        WHERE
            EXTRACT(YEAR FROM meas2.measured_at) = subquery."Year"
        GROUP BY
            EXTRACT(YEAR FROM meas2.measured_at)
    )
ORDER BY
    subquery."Year",
    subquery."Month";


/*
Type SELECT, which returns the name of the region along with the number of sensors in that
region, sorted in descending order by number.
*/

SELECT
    reg.name AS "Region Name",
    COUNT(reg.name) AS "Sensor Count"
FROM
    Regions AS reg
INNER JOIN 
    Cities ON Cities.region_id = reg.id
INNER JOIN
    Sensors ON sensors.city_id = Cities.id
GROUP BY
    reg.name
ORDER BY
    "Sensor Count" DESC;

/*
Type SELECT to return the name of the city with the most stable temperature
(lowest standard deviation).
*/

SELECT
    Cities.name AS "City",
    ROUND(STDDEV(meas.temperature), 2) AS "Temperature Stddev"
FROM
    Measurements meas
INNER JOIN
    Sensors ON meas.sensor_id = Sensors.id
INNER JOIN 
    Cities ON Sensors.city_id = Cities.id
GROUP BY
    Cities.name
ORDER BY
    "Temperature Stddev"
LIMIT
    1;


/*
Type SELECT, which returns the name of the city along with the number of sensors in that city,
sorted in descending order.
*/

SELECT
    Cities.name AS "City",
    COUNT(Sensors.city_id) AS "Sensor Count"
FROM
    Cities
INNER JOIN 
    Sensors ON Sensors.city_id = Cities.id
GROUP BY
    "City"
ORDER BY
    "Sensor Count" DESC;

/*
Type SELECT, which for each region returns the name of the city where the highest temperature
was measured (let that temperature be in the output). Sorted by region name in descending order.

Hint: 1 subselect + DISTINCT ON combo with ORDER BY.
*/

SELECT DISTINCT ON (Regions.name)
    Regions.name AS "Name",
    Cities.name AS "City",
    Measurements.temperature AS "Temperature"
FROM 
    Regions
INNER JOIN
    Cities ON Cities.region_id = Regions.id
INNER JOIN 
    Sensors ON Sensors.city_id = Cities.id
INNER JOIN
    Measurements ON Measurements.sensor_id = Sensors.id
ORDER BY
    "Name" DESC,
    "Temperature" DESC,
    "City";

/*
Write SELECT, which for each region returns the names of the three places where the highest
temperature was measured (let the temperature be in the output). Sorted by temperature in descending order.
*/

SELECT
    *
FROM (
    SELECT 
        *
    FROM (
        SELECT DISTINCT ON (Cities.name)
            Cities.name AS city,
            Measurements.temperature AS temperature,
            Regions.name AS region
        FROM
            Cities
        INNER JOIN 
            Regions ON Regions.id = Cities.region_id
        INNER JOIN 
            Sensors ON Sensors.city_id = Cities.id
        INNER JOIN 
            Measurements ON Measurements.sensor_id = Sensors.id
        WHERE 
            Regions.name = 'Západ'
        ORDER BY 
            Cities.name,
            Measurements.temperature DESC
    ) AS hottest_in_cities_in_zapad
    ORDER BY 
        temperature DESC
    LIMIT 
        3
) AS top_zapad

UNION ALL

SELECT
    *
FROM (
    SELECT 
        *
    FROM (
        SELECT DISTINCT ON (Cities.name)
            Cities.name AS city,
            Measurements.temperature AS temperature,
            Regions.name AS region
        FROM
            Cities
        INNER JOIN 
            Regions ON Regions.id = Cities.region_id
        INNER JOIN 
            Sensors ON Sensors.city_id = Cities.id
        INNER JOIN 
            Measurements ON Measurements.sensor_id = Sensors.id
        WHERE 
            Regions.name = 'Stred'
        ORDER BY 
            Cities.name,
            Measurements.temperature DESC
    ) AS hottest_in_cities_in_stred
    ORDER BY 
        temperature DESC
    LIMIT 
        3
) AS top_stred

UNION ALL

SELECT
    *
FROM (
    SELECT 
        *
    FROM (
        SELECT DISTINCT ON (Cities.name)
            Cities.name AS city,
            Measurements.temperature AS temperature,
            Regions.name AS region
        FROM
            Cities
        INNER JOIN 
            Regions ON Regions.id = Cities.region_id
        INNER JOIN 
            Sensors ON Sensors.city_id = Cities.id
        INNER JOIN 
            Measurements ON Measurements.sensor_id = Sensors.id
        WHERE 
            Regions.name = 'Východ'
        ORDER BY 
            Cities.name,
            Measurements.temperature DESC
    ) AS hottest_in_cities_in_vychod
    ORDER BY 
        temperature DESC
    LIMIT 
        3
) AS top_vychod;

-- More readable version

WITH hottest_in_cities_in_zapad AS (
    SELECT DISTINCT ON (Cities.name)
        Cities.name AS city,
        Measurements.temperature AS temperature,
        Regions.name AS region
    FROM
        Cities
    INNER JOIN 
        Regions ON Regions.id = Cities.region_id
    INNER JOIN 
        Sensors ON Sensors.city_id = Cities.id
    INNER JOIN 
        Measurements ON Measurements.sensor_id = Sensors.id
    WHERE 
        Regions.name = 'Západ'
    ORDER BY 
        Cities.name,
        Measurements.temperature DESC
),
top_zapad AS (
    SELECT 
        *
    FROM 
        hottest_in_cities_in_zapad
    ORDER BY 
        temperature DESC
    LIMIT 
        3
),
hottest_in_cities_in_stred AS (
    SELECT DISTINCT ON (Cities.name)
        Cities.name AS city,
        Measurements.temperature AS temperature,
        Regions.name AS region
    FROM
        Cities
    INNER JOIN 
        Regions ON Regions.id = Cities.region_id
    INNER JOIN 
        Sensors ON Sensors.city_id = Cities.id
    INNER JOIN 
        Measurements ON Measurements.sensor_id = Sensors.id
    WHERE 
        Regions.name = 'Stred'
    ORDER BY 
        Cities.name,
        Measurements.temperature DESC
),
top_stred AS (
    SELECT 
        *
    FROM 
        hottest_in_cities_in_stred
    ORDER BY 
        temperature DESC
    LIMIT 
        3
),
hottest_in_cities_in_vychod AS (
    SELECT DISTINCT ON (Cities.name)
        Cities.name AS city,
        Measurements.temperature AS temperature,
        Regions.name AS region
    FROM
        Cities
    INNER JOIN 
        Regions ON Regions.id = Cities.region_id
    INNER JOIN 
        Sensors ON Sensors.city_id = Cities.id
    INNER JOIN 
        Measurements ON Measurements.sensor_id = Sensors.id
    WHERE 
        Regions.name = 'Východ'
    ORDER BY 
        Cities.name,
        Measurements.temperature DESC
),
top_vychod AS (
    SELECT 
        *
    FROM 
        hottest_in_cities_in_vychod
    ORDER BY 
        temperature DESC
    LIMIT 
        3
)
SELECT * FROM top_zapad
UNION ALL
SELECT * FROM top_stred
UNION ALL
SELECT * FROM top_vychod;

/*
Write a SELECT that pairs the regions in which there is the largest difference in average temperature.
Let the resulting two columns be ordered lexicographically.

Hint: LEAST and GREATEST.
*/

WITH region_avg AS (
    SELECT
        Regions.name AS "Region",
        ROUND(AVG(Measurements.temperature), 2) AS "Avg Temp"
    FROM
        Regions
    INNER JOIN 
        Cities ON Cities.region_id = Regions.id
    INNER JOIN 
        Sensors ON Sensors.city_id = Cities.id
    INNER JOIN 
        Measurements ON Measurements.sensor_id = Sensors.id
    GROUP BY 
        Regions.name
)   
    SELECT
        LEAST(r1."Region", r2."Region") AS "Region 1",
        GREATEST(r1."Region", r2."Region") AS "Region 2",
        ABS(r1."Avg Temp" - r2."Avg Temp") AS "Temp Diff"
    FROM 
        region_avg AS r1
    INNER JOIN
     region_avg AS r2 ON r1."Region" <> r2."Region"
ORDER BY 
    "Temp Diff" DESC
LIMIT 
    1;