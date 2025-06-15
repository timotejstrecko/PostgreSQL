Select * From cd.facilities;

SELECT 
    starttime
FROM 
    bookings
Inner JOIN
    members ON members.memid = bookings.memid
WHERE 
    firstname || ' ' || surname = 'David Farrell';



SELECT 
    starttime,
    name
FROM 
    cd.bookings
INNER JOIN
    cd.facilities ON cd.facilities.facid = cd.bookings.facid
WHERE
    name ILIKE 'Tennis Court _' AND starttime::DATE = '2012-09-21'
ORDER BY
    1;


SELECT DISTINCT
    m2.firstname,
    m2.surname
From
    cd.members
INNER JOIN
    cd.members AS m2 ON m2.memid = cd.members.recommendedby
WHERE
    cd.members.recommendedby IS NOT NULL
ORDER BY 
    2,
    1;

SELECT 
    m1.firstname,
    m1.surname,
    m2.firstname,
    m2.surname
FROM
    cd.members AS m1
LEFT OUTER JOIN
    cd.members AS m2 ON m2.memid = m1.recommendedby
ORDER BY
    2,
    1;

SELECT DISTINCT
    m1.firstname || ' ' || m1.surname AS member_name,
    fac.name AS facility
FROM
    cd.members AS m1
INNER JOIN
    cd.bookings AS b ON b.memid = m1.memid
INNER JOIN
    cd.facilities AS fac ON fac.facid = b.facid
WHERE 
    fac.name ILIKE 'Tennis Court _'
ORDER BY
    member_name,
    facility;


SELECT
    mem.firstname || ' ' || mem.surname,
    fac.name,
    CASE
        WHEN mem.memid = 0 THEN book.slots * fac.guestcost 
        ELSE book.slots * fac.membercost 
        END
    AS "Cost"
From
    cd.bookings as book
INNER JOIN
    cd.facilities AS fac ON fac.facid = book.facid
INNER JOIN
    cd.members AS mem ON mem.memid = book.memid
WHERE
    book.starttime::DATE = '2012-09-14' AND ((mem.memid = 0 AND book.slots * fac.guestcost > 30) OR (mem.memid != 0 AND book.slots * fac.membercost > 30))
ORDER BY
    "Cost" DESC;


SELECT DISTINCT
    m1.firstname || ' ' || m1.surname, 
    (
        SELECT 
            m2.firstname || ' ' || m2.surname
        FROM 
            cd.members AS m2
        WHERE
            m2.memid = m1.recommendedby
    ) AS sub
FROM
    cd.members AS m1
ORDER BY
    m1.firstname || ' ' || m1.surname;

SELECT
    *
FROM
    (
        SELECT
            mem.firstname || ' ' || mem.surname,
            fac.name,
            CASE
                WHEN mem.memid = 0 THEN book.slots * fac.guestcost
                ELSE book.slots * fac.membercost
            END AS cost
        FROM
            cd.members AS mem
        INNER JOIN
            cd.bookings AS book ON book.memid = mem.memid
        INNER JOIN
            cd.facilities AS fac ON fac.facid = book.facid
        WHERE
            starttime::DATE = '2012-09-14'
    )
WHERE
    cost > 30
ORDER BY
    cost;


SELECT
    Count(cd.facilities.facid)
FROM
    cd.facilities

SELECT
    COUNT(cd.facilities.facid)
FROM
    cd.facilities
WHERE
    guestcost > 10;


SELECT
    recommendedby,
    COUNT(recommendedby)
FROM
    cd.members
WHERE
    recommendedby IS NOT NULL
GROUP BY
    recommendedby
ORDER BY
    recommendedby;

SELECT
    fac.facid,
    SUM(cd.bookings.slots)
FROM
    cd.bookings
INNER JOIN
    cd.facilities AS fac ON fac.facid = cd.bookings.facid
GROUP BY
    fac.facid
ORDER BY
    fac.facid;


SELECT
    fac.facid,
    SUM(book.slots) AS slots
FROM 
    cd.facilities AS fac
INNER JOIN
    cd.bookings AS book ON book.facid = fac.facid
WHERE
    book.starttime::DATE BETWEEN '2012-09-01' AND '2012-09-30'
GROUP BY
    fac.facid
ORDER BY
    slots;

SELECT
    fac.facid,
    EXTRACT(MONTH FROM book.starttime) AS month,
    SUM(book.slots) AS slots
FROM 
    cd.facilities AS fac
INNER JOIN
    cd.bookings AS book ON book.facid = fac.facid
WHERE
    EXTRACT(YEAR FROM book.starttime) = 2012
GROUP BY
    fac.facid,
    month
ORDER BY
    fac.facid;

SELECT
    COUNT(DISTINCT cd.members.memid)
FROM
    cd.members
INNER JOIN
    cd.bookings ON cd.bookings.memid = cd.members.memid


SELECT
    fac.facid,
    sum(book.slots)
FROM
    cd.facilities AS fac
INNER JOIN
    cd.bookings AS book ON book.facid = fac.facid
GROUP BY 
    fac.facid
HAVING
    sum(book.slots) > 1000
ORDER BY
    fac.facid;



WITH guest_cost AS 
(
    SELECT 
        fac.name,
        sum(book.slots * fac.guestcost) AS revenue
    FROM
        cd.facilities AS fac
    INNER JOIN
        cd.bookings AS book ON book.facid = fac.facid
    INNER JOIN
        cd.members AS mem ON mem.memid = book.memid
    WHERE
        mem.memid = 0
    GROUP BY
        fac.facid
),
members_cost AS
(
    SELECT
        fac.name,
        sum(book.slots * fac.membercost) AS revenue
    FROM
        cd.facilities AS fac
    INNER JOIN
        cd.bookings AS book ON book.facid = fac.facid
    INNER JOIN
        cd.members AS mem ON mem.memid = book.memid
    WHERE
        mem.memid <> 0
    GROUP BY
        fac.facid
)
SELECT
    members_cost.name,
    members_cost.revenue + guest_cost.revenue AS revenue
FROM
    guest_cost
INNER JOIN
    members_cost ON members_cost.name = guest_cost.name
ORDER BY
    revenue;

SELECT 
    fac.name,
    sum(
        book.slots * CASE WHEN mem.memid = 0 THEN fac.guestcost ELSE fac.membercost END
        ) AS revenue
FROM
    cd.facilities AS fac
INNER JOIN
    cd.bookings AS book ON book.facid = fac.facid
INNER JOIN
    cd.members AS mem ON mem.memid = book.memid
GROUP BY
    fac.facid
HAVING
    sum(
        book.slots * CASE WHEN mem.memid = 0 THEN fac.guestcost ELSE fac.membercost END
        ) < 1000
ORDER BY
    revenue;

Select
    fac.facid,
    sum(book.slots)
FROM
    cd.bookings AS book
INNER JOIN
    cd.facilities AS fac ON fac.facid = book.facid
GROUP BY
    fac.facid
ORDER BY
    2 DESC
LIMIT 
    1;

SELECT 
    fac.facid,
    SUM(book.slots) AS sum_slot
FROM
    cd.bookings AS book
INNER JOIN
    cd.facilities AS fac ON fac.facid = book.facid
GROUP BY
    fac.facid
HAVING
    SUM(book.slots) = (
        SELECT 
            MAX(total_slots)
        FROM (
            SELECT 
                facid,
                SUM(slots) AS total_slots
            FROM 
                cd.bookings
            GROUP BY 
                facid
        ) 
    )

WITH sum_slots AS 
(
    SELECT
        fac.facid,
        SUM(book.slots) AS "SUM"
    FROM
        cd.bookings AS book
    INNER JOIN
        cd.facilities AS fac ON fac.facid = book.facid
    GROUP BY
        fac.facid
)
SELECT
    *
FROM
    sum_slots 
WHERE
    "SUM" = (
        SELECT
            MAX("SUM")
        FROM
            sum_slots
    );


SELECT
    fac.facid,
    EXTRACT(MONTH FROM book.starttime) AS month,
    SUM(book.slots) AS slots
FROM
    cd.facilities AS fac
INNER JOIN
    cd.bookings AS book On book.facid = fac.facid
WHERE 
    EXTRACT(YEAR FROM book.starttime) = 2012
GROUP BY
    ROLLUP
    (
        fac.facid,
        month
    )
ORDER BY
    fac.facid,
    month;


SELECT
    fac.facid,
    fac.name,
    ROUND(SUM(book.slots) / 2.0, 2) AS slots
FROM
    cd.facilities AS fac
INNER JOIN
    cd.bookings AS book ON book.facid = fac.facid
GROUP BY
    fac.facid
ORDER BY
    fac.facid;

SELECT
    mem.surname,
    mem.firstname,
    mem.memid,
    MIN(book.starttime) AS starttime
FROM
    cd.members AS mem
INNER JOIN
    cd.bookings AS book ON book.memid = mem.memid
WHERE
    book.starttime::DATE >= '2012-09-01'
GROUP BY
    mem.memid
ORDER BY
    mem.memid;


SELECT
    (
        SELECT
            COUNT(DISTINCT mem.memid)
        FROM
            CD.members as mem
    ) AS "Count",
    mem.firstname,
    mem.surname
FROM
    cd.members AS mem
GROUP BY
    mem.memid -- In Case of more guests
ORDER BY
    mem.joindate

SELECT
    COUNT(mem.memid) OVER () AS "Count",
    mem.firstname,
    mem.surname
FROM
    cd.members AS mem
ORDER BY
    mem.joindate

SELECT
    ROW_NUMBER() OVER (ORDER BY mem.joindate),
    mem.firstname,
    mem.surname
FROM
    cd.members AS mem
ORDER BY
    1;

SELECT
    fac.facid,
    SUM(book.slots) AS slots
FROM
    cd.facilities AS fac
INNER JOIN
    cd.bookings AS book ON book.facid = fac.facid
GROUP BY
    fac.facid
HAVING
    SUM(slots) = (
            SELECT 
                MAX(total_slots)
            FROM
                (
                    SELECT 
                        SUM(book.slots) AS total_slots
                    FROM
                        cd.bookings AS book
                    INNER JOIN
                        cd.facilities AS fac ON fac.facid = book.facid
                    GROUP BY
                        fac.facid
                )
        );

WITH ranked_facilities AS (
    SELECT
        fac.facid,
        SUM(book.slots) AS slots,
        RANK() OVER (ORDER BY SUM(book.slots) DESC) AS ranking
    FROM
        cd.bookings AS book
    INNER JOIN 
        cd.facilities AS fac ON fac.facid = book.facid
    GROUP BY
        fac.facid
)
SELECT 
    facid,
    slots
FROM 
    ranked_facilities
WHERE 
    ranking = 1
ORDER BY 
    facid;

SELECT
    mem.firstname,
    mem.surname,
    ROUND(SUM(book.slots) / 2.0, -1) AS "hours",
    RANK() OVER (ORDER BY ROUND(SUM(book.slots) / 2.0, -1) DESC) AS "rank"
FROM
    cd.members AS mem
INNER JOIN
    cd.bookings AS book ON book.memid = mem.memid
GROUP BY
    mem.memid
ORDER BY
    "rank",
    mem.surname,
    mem.firstname;





WITH guest_rev AS 
(
    SELECT 
        fac.name,
        fac.guestcost * SUM(book.slots) AS revenue
    FROM
        cd.facilities AS fac
    INNER JOIN
        cd.bookings AS book ON book.facid = fac.facid
    INNER JOIN
        cd.members AS mem ON mem.memid = book.memid
    WHERE 
        mem.memid = 0
    GROUP BY
        fac.facid

),
member_rev AS
(
    SELECT
        fac.name,
        fac.membercost * SUM(book.slots) AS revenue
    FROM
        cd.facilities AS fac
    INNER JOIN
        cd.bookings AS book ON book.facid = fac.facid
    INNER JOIN
        cd.members AS mem ON mem.memid = book.memid
    WHERE 
        mem.memid <> 0
    GROUP BY
        fac.facid
),
ranked AS 
(
    SELECT
        mr.name,
        mr.revenue + gr.revenue AS total,
        RANK() OVER (ORDER BY mr.revenue + gr.revenue DESC) AS rank
    FROM
        member_rev AS mr
    INNER JOIN
        guest_rev AS gr ON gr.name = mr.name
    
)
SELECT 
    *
FROM
    ranked
WHERE
    rank <= 3
ORDER BY
    rank;



WITH facility_revenue AS (
    SELECT
        fac.name,

        SUM(
            CASE
                WHEN mem.memid = 0 THEN book.slots * fac.guestcost
                ELSE book.slots * fac.membercost
            END
        ) AS revenue,

        RANK() OVER 
        (
            ORDER BY SUM
            (
                CASE
                    WHEN mem.memid = 0 THEN book.slots * fac.guestcost
                    ELSE book.slots * fac.membercost
                END
            ) DESC
        ) AS rank

    FROM
        cd.bookings AS book
    INNER JOIN
        cd.facilities AS fac ON fac.facid = book.facid
    INNER JOIN 
        cd.members AS mem ON mem.memid = book.memid
    GROUP BY
        fac.facid
)
SELECT
    name,
    rank
FROM
    facility_revenue
WHERE
    rank <= 3
ORDER BY
    rank,
    name;


WITH revenue_rank AS 
(
    SELECT
        fac.name,
        NTILE(3) OVER 
        (
            ORDER BY SUM
            ( 
                CASE
                    WHEN mem.memid = 0 THEN book.slots * fac.guestcost
                    ELSE book.slots * membercost
                END 
            ) DESC
        ) AS revenue
    FROM
        cd.bookings AS book
    INNER JOIN
        cd.facilities AS fac ON fac.facid = book.facid
    INNER JOIN
        cd.members AS mem ON mem.memid = book.memid
    GROUP BY
        fac.facid
)
SELECT 
    name,
    CASE 
        WHEN revenue = 1 THEN 'high'
        WHEN revenue = 2 THEN 'average'
        ELSE 'low'
    END AS "Revenue"
FROM
    revenue_rank
ORDER BY
    revenue,
    name;


SELECT
    fac.name,
    fac.initialoutlay / (
        SUM(CASE 
                WHEN mem.memid = 0 THEN book.slots * fac.guestcost
                ELSE book.slots * fac.membercost 
            END
        ) - (3 * fac.monthlymaintenance)
    ) * 3 AS time_to_repay
FROM
    cd.bookings AS book
INNER JOIN
    cd.facilities AS fac ON fac.facid = book.facid
INNER JOIN
    cd.members AS mem On mem.memid = book.memid
GROUP BY
    fac.facid
ORDER BY
    fac.name

WITH idk_why_calculate_for_august_and_taking_into_account_july AS (
    SELECT
        book.starttime::DATE,
        AVG(SUM(CASE
                WHEN mem.memid = 0 THEN book.slots * fac.guestcost
                ELSE book.slots * fac.membercost
                END)) OVER (ORDER BY book.starttime::DATE
                    ROWS 14 PRECEDING) AS average
    FROM    
        cd.bookings AS book
    INNER JOIN
        cd.facilities AS fac ON fac.facid = book.facid
    INNER JOIN
        cd.members AS mem ON mem.memid = book.memid
    WHERE
        book.starttime::DATE BETWEEN '2012-07-17' AND '2012-08-31'
    GROUP BY
        book.starttime::DATE

)
SELECT 
    *
FROM
    idk_why_calculate_for_august_and_taking_into_account_july
WHERE
    EXTRACT(MONTH FROM starttime) = 8

WITH all_days AS (
    SELECT
        generate_series(
            DATE '2012-08-01' - INTERVAL '15 days',
            DATE '2012-08-31',
            INTERVAL '1 day'
        )::DATE AS "day"
),
daily_rev AS (
    SELECT
        book.starttime::DATE AS "date",
        SUM(
            CASE
                WHEN mem.memid = 0 THEN book.slots * fac.guestcost
                ELSE book.slots * fac.membercost
                END
        ) AS day_rev
    FROM
        cd.bookings AS book
    INNER JOIN
        cd.facilities AS fac ON fac.facid = book.facid
    INNER JOIN
        cd.members AS mem ON mem.memid = book.memid
    GROUP BY
        book.starttime::DATE
),
day_merge AS (
    SELECT
        all_days."day",
        AVG(COALESCE(daily_rev.day_rev, 0)) OVER (
                                                    ORDER BY "day"
                                                    ROWS 14 PRECEDING
                                                    ) AS avg_rev
    FROM
        all_days
    LEFT OUTER JOIN
        daily_rev ON daily_rev."date" = all_days."day"
)
SELECT
    *
FROM
    day_merge
WHERE
    EXTRACT(MONTH FROM "day") = 8;


INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES(9, 'SPA', 20, 30, 100000, 800)

SELECT
    TIMESTAMP '2012-08-31 01:00:00';

SELECT
    TIMESTAMP '2012-08-31 01:00:00' - TIMESTAMP '2012-07-30 01:00:00' AS "Interval";

SELECT
    generate_series(
        TIMESTAMP '2012-10-01 00:00:00',
        TIMESTAMP '2012-10-31 00:00:00',
        INTERVAL '1 day'
    ) AS "October Days";

SELECT
    EXTRACT(MONTH FROM subfrom."month") AS month,
    ("month" + INTERVAL '1 month') - "month" AS num_days
FROM
    (
        SELECT
            generate_series(
                DATE '2012-01-01',
                DATE '2012-12-31',
                INTERVAL '1 month'
            ) AS "month"
    ) AS subfrom

with recursive recommenders(recommender) as (
	select recommendedby from cd.members where memid = 27
	union all
	select mems.recommendedby
		from recommenders recs
		inner join cd.members mems
			on mems.memid = recs.recommender
)
select recs.recommender, mems.firstname, mems.surname
	from recommenders recs
	inner join cd.members mems
		on recs.recommender = mems.memid
order by memid desc  