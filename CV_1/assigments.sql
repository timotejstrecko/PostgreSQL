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


