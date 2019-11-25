--/**********************************/
--/		LANGUAGE	     /
--/**********************************/
create table languages(
	language_id serial primary key,
	language character varying(32) not null
);
insert into languages(language)
select distinct language from imdb_movielanguages;

alter table imdb_movielanguages
	add column language_id integer,
	add foreign key(language_id) references languages(language_id);

update imdb_movielanguages as language_
set language_id = (select language_id from languages where language = language_.language);

alter table imdb_movielanguages
	drop column extrainformation,
	drop column language,
	add constraint primary_language primary key (movieid, language_id);

--/**********************************/
--/		COUNTRY		     /
--/**********************************/
create table countries(
	country_id serial primary key,
	country character varying(32) not null
);
insert into countries(country)
select distinct country from imdb_moviecountries;

alter table imdb_moviecountries
	add column country_id integer,
	add foreign key(country_id) references countries(country_id)

update imdb_moviecountries as country_
set country_id = (select country_id from languages where language = language_.language);

alter table imdb_moviecountries
	drop column extrainformation,
	drop column country,
	add constraint primary_country primary key (movieid, country_id);



--/**********************************/
--/		GENRES		     /
--/**********************************/
create table genres(
	genre_id serial primary key,
	genre character varying(32) not null
);
insert into genres(genre)
select distinct genre from imdb_moviegenres;

alter table imdb_moviegenres
	add column genres_id integer,
	add foreign key(genre_id) references genres(genre_id)

update imdb_moviegenres as genre_
set genre_id = (select genre_id from genres where genre = genre_.genre);

alter table imdb_moviegenres
	drop column extrainformation,
	drop column genre,
	add constraint primary_genre primary key (movieid, genre_id);


