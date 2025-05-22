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


-- PROGRAMERS 
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE TABLE languages (
id SERIAL NOT NULL PRIMARY KEY,
label VARCHAR(10) NOT NULL
);

CREATE TABLE projects (
id SERIAL NOT NULL PRIMARY KEY,
name VARCHAR(30) NOT NULL,
created_at DATE NOT NULL,
language_id BIGINT REFERENCES languages(id)
);

CREATE TABLE programmers (
id SERIAL NOT NULL PRIMARY KEY,
name VARCHAR(30),
signed_in_at DATE
);

CREATE TABLE projects_programmers (
id SERIAL NOT NULL PRIMARY KEY,
project_id BIGINT NOT NULL REFERENCES projects(id),
programmer_id BIGINT NOT NULL REFERENCES programmers(id),
owner BOOLEAN NOT NULL DEFAULT FALSE,
joined_at DATE
);

INSERT INTO programmers(name, signed_in_at) VALUES
('Digby Otis', '2014-06-01'),
('Tansy Hayley', '2014-06-05'),
('Harland Eldridge', '2014-08-12'),
('Tracey Tyson', '2015-02-22'),
('Raleigh Paterson', '2015-02-28'),
('Nancy Brook', '2015-03-05'),
('Ross Ness', '2015-04-12'),
('Addyson Frank', '2015-04-26'),
('Jackson Simms', '2015-05-07'),
('Elissa Seabrooke', '2015-05-07'),
('Fitzroy Randal', '2015-05-07'),
('Rosemarie Short', '2015-08-12'),
('Cleve London', '2015-09-01'),
('Liz Kynaston', '2015-09-30'),
('Richard Myles', '2015-11-12'),
('Annmarie Larson', '2015-12-02'),
('Dean Michael', '2016-01-15'),
('Davina Otis', '2016-02-20'),
('Inigo Watt', '2016-03-01'),
('Gabrielle Mottershead', '2016-03-03');

INSERT INTO languages(label) VALUES
('ruby'),
('python'),
('java'),
('c#'),
('C'),
('C++'),
('Javascript'),
('Go'),
('Haskell'),
('Scala'),
('Clojure');

INSERT INTO projects(name, created_at, language_id) VALUES
('Next Cloudy Proton','2014-09-01', 1),
('Quality Hammer','2014-10-11', 1),
('Red Moose','2015-12-01', 1),
('Solid Electron','2015-12-06', 2),
('Sliding Strawberry Iron','2015-12-24', 2),
('Husky Tiger','2016-02-07', 2),
('Rusty Finger','2016-02-11', 3),
('Red Eyelid','2016-03-05', 3),
('Brave Cloud','2016-03-05', 4),
('Frozen Dagger','2016-03-12', 5),
('Barbaric Coffin','2016-03-12', 6),
('Lobster Alien','2016-03-13', 10),
('Magenta Crystal','2016-03-13', 10);

INSERT INTO projects_programmers(project_id, programmer_id, owner, joined_at) VALUES
(1,1,TRUE,'2014-09-01'),
(2,2,TRUE,'2014-10-11'),
(3,3,TRUE,'2015-12-01'),
(4,4,TRUE,'2015-12-06'),
(5,5,TRUE,'2015-12-24'),
(6,6,TRUE,'2016-02-07'),
(7,7,TRUE,'2016-02-11'),
(8,8,TRUE,'2016-03-05'),
(9,9,TRUE,'2016-03-05'),
(10,10,TRUE,'2016-03-12'),
(11,11,TRUE,'2016-03-12'),
(1,12,FALSE,'2015-09-15'),
(2,13,FALSE,'2015-08-03'),
(3,14,FALSE,'2015-10-16'),
(4,15,FALSE,'2015-12-02'),
(5,16,FALSE,'2015-12-26'),
(6,17,FALSE,'2016-03-04'),
(7,18,FALSE,'2016-02-16'),
(8,19,FALSE,'2016-03-06'),
(9,20,FALSE,'2016-03-06'),
(1,14,FALSE,'2015-11-11'),
(3,14,FALSE,'2015-12-14'),
(6,5,FALSE,'2016-01-07'),
(12,15,TRUE,'2016-03-13'),
(13,16,TRUE,'2016-03-13');
