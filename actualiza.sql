--/**********************************/
--/		LANGUAGE	     /
--/**********************************/
create table languages(
	language_id serial primary key,
	language_str character varying(32) not null
);
insert into languages(language_str)
select distinct language from imdb_movielanguages;

alter table imdb_movielanguages
	add column langid integer,
	add foreign key(langid) references languages(language_id);

update imdb_movielanguages as language_
set langid = (select language_id from languages where language_str = language_.language);

alter table imdb_movielanguages
	drop column language,
	add constraint primary_language primary key (movieid, langid);

--/**********************************/
--/		COUNTRY		     /
--/**********************************/
create table countries(
	country_id serial primary key,
	country_str character varying(32) not null
);
insert into countries(country_str)
select distinct country from imdb_moviecountries;

alter table imdb_moviecountries
	add column countrid integer,
	add foreign key(countrid) references countries(country_id);

update imdb_moviecountries as country_
set countrid = (select country_id from countries where country_str = country_.country);

alter table imdb_moviecountries
	drop column country,
	add constraint primary_country primary key (movieid, countrid);



--/**********************************/
--/		GENRES		     /
--/**********************************/
create table genres(
	genre_id serial primary key,
	genre_str character varying(32) not null
);
insert into genres(genre_str)
select distinct genre from imdb_moviegenres;

alter table imdb_moviegenres
	add column genrid integer,
	add foreign key(genrid) references genres(genre_id);

update imdb_moviegenres as genre_
set genrid = (select genre_id from genres where genre_str = genre_.genre);

alter table imdb_moviegenres
	drop column genre,
	add constraint primary_genre primary key (movieid, genrid);


