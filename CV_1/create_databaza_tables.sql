-- Active: 1745233965939@@127.0.0.1@5432@cv_1
DO $$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_database WHERE datname = 'cv_1'
   ) THEN
      CREATE DATABASE cv_1;
   END IF;
END
$$;

-- Movies dataset without constraints and reference integrity
create table movies(mID int, title text, year int, director text); 

create table reviewers(rID int, name text); 

create table ratings(rID int, mID int, stars int, ratingDate date); 

insert into movies values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into movies values(102, 'Star Wars', 1977, 'George Lucas');
insert into movies values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into movies values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into movies values(105, 'Titanic', 1997, 'James Cameron');
insert into movies values(106, 'Snow White', 1937, null);
insert into movies values(107, 'Avatar', 2009, 'James Cameron');
insert into movies values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into reviewers values(201, 'Sarah Martinez');
insert into reviewers values(202, 'Daniel Lewis');
insert into reviewers values(203, 'Brittany Harris');
insert into reviewers values(204, 'Mike Anderson');
insert into reviewers values(205, 'Chris Jackson');
insert into reviewers values(206, 'Elizabeth Thomas');
insert into reviewers values(207, 'James Cameron');
insert into reviewers values(208, 'Ashley White');

insert into ratings values(201, 101, 2, '2025-01-22');
insert into ratings values(201, 101, 4, '2025-01-27');
insert into ratings values(202, 106, 4, null);
insert into ratings values(203, 103, 2, '2025-01-20');
insert into ratings values(203, 108, 4, '2025-01-12');
insert into ratings values(203, 108, 2, '2025-01-30');
insert into ratings values(204, 101, 3, '2025-01-09');
insert into ratings values(205, 103, 3, '2025-01-27');
insert into ratings values(205, 104, 2, '2025-01-22');
insert into ratings values(205, 108, 4, null);
insert into ratings values(206, 107, 3, '2025-01-15');
insert into ratings values(206, 106, 5, '2025-01-19');
insert into ratings values(207, 107, 5, '2025-01-20');
insert into ratings values(208, 104, 3, '2025-01-02');
