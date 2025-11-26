
BEGIN TRANSACTION;
savepoint before_insert;

-- rollback to before_insert;

create table cre (
    movie_id int,
    person_id int,
    credit char
);
\copy cre (movie_id, person_id, credit)
FROM '\your path\cre.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'utf8');

create table per (
    person_id int,
    first_name varchar(30),
    surname varchar(30),
    born int,
    died int,
    gender char
);
\copy per (person_id, first_name, surname, born, died, gender)
FROM '\your path\per.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'utf8');

create table mov (
    movie_id int,
    title varchar(100),
    original_title varchar(100),
    countries char(2),
    year_release int,
    runtime int
);
\copy mov (movie_id, title, original_title, countries, year_release, runtime)
FROM '\your path\mov.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'utf8');


SELECT COALESCE(MAX(movies.movieid), 0) + 1 FROM movies;

CREATE SEQUENCE movieid_seq START WITH 9205 INCREMENT BY 1 OWNED BY public.movies.movieid;

insert into movies ( movieid, title, country, year_released, runtime )
select distinct on ( mov.title, mov.countries, mov.year_release )
    nextval('movieid_seq'),
    mov.title,
    case
        when mov.countries = 'es' then 'sp'
        else mov.countries
    end,
    mov.year_release,
    mov.runtime
from mov
left outer join public.movies m
on  mov.title = m.title
    and mov.countries = m.country
    and mov.year_release = m.year_released
where m.movieid is null and mov.countries is not null;


SELECT COALESCE(MAX(alt_titles.titleid), 0) + 1 FROM alt_titles;

CREATE SEQUENCE titleid_seq START WITH 3366 INCREMENT BY 1 OWNED BY public.alt_titles.titleid;

insert into alt_titles ( titleid, movieid, title )
select distinct on ( mov.title, mov.countries, mov.year_release )
    nextval('titleid_seq'),
    m.movieid,
    mov.original_title
from mov
join public.movies m
on  mov.title = m.title
    and mov.countries = m.country
    and mov.year_release = m.year_released
    and mov.title != mov.original_title and mov.original_title != '';


SELECT COALESCE(MAX(public.people.peopleid), 0) + 1 FROM people;

CREATE SEQUENCE peopleid_seq START WITH 16490 INCREMENT BY 1 OWNED BY public.people.peopleid;

insert into people ( peopleid, first_name, surname, born, died, gender )
select distinct on ( per.first_name, per.surname, per.born, per.gender )
    nextval('peopleid_seq'),
    per.first_name,
    per.surname,
    per.born,
    per.died,
    coalesce(per.gender,'?')
from per
left outer join public.people p
on  per.first_name = p.first_name
    and per.surname = p.surname
where p.peopleid is null and per.born is not null;


insert into credits ( movieid, peopleid, credited_as )
select distinct
    m.movieid,
    p.peopleid,
    cre.credit
from cre
join public.mov on cre.movie_id = mov.movie_id
join public.movies m
    on ( mov.title, mov.countries, mov.year_release ) = ( m.title, m.country, m.year_released )
join public.per on cre.person_id = per.person_id
join public.people p
    on ( per.first_name, per.surname ) = ( p.first_name, p.surname )
left outer join credits c
    on ( m.movieid, p.peopleid, cre.credit ) = ( c.movieid, c.peopleid, c.credited_as )
where c.movieid is null;

drop table cre;
drop table mov;
drop table per;

commit;

select count(*) from credits;
