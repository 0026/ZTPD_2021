

-- zad 1
create table movies(
ID NUMBER(12) PRIMARY KEY,
TITLE VARCHAR2(400) NOT NULL,
CATEGORY VARCHAR2(50),
YEAR CHAR(4),
CAST VARCHAR2(4000),
DIRECTOR VARCHAR2(4000),
STORY VARCHAR2(4000),
PRICE NUMBER(5,2),
COVER BLOB,
MIME_TYPE VARCHAR2(50)
)
-- zad 2
select * 
from DESCRIPTIONS

select * 
from COVERS

insert into movies (ID, TITLE, CATEGORY, YEAR, CAST, DIRECTOR, STORY, PRICE, COVER, MIME_TYPE)
SELECT d.id, d.title, d.category, CAST(d.year as CHAR(4)), d.cast, d.director, d.story, d.price, c.image, c.mime_type
from DESCRIPTIONS d
LEFT JOIN COVERS c
ON d.id = c.movie_id

-- zad 3
select id, title
from movies
where cover is null

--zad 4
select id, title, LENGTH(COVER)
from movies
where cover is not null

--zad 5
select id, title, LENGTH(COVER)
from movies
where cover is null

--zad6 
select *
from all_directories

--zad7
UPDATE movies
SET COVER=EMPTY_BLOB(), MIME_TYPE='image/jpeg'
WHERE id=66

--zad8
select id, title, LENGTH(COVER)
from movies
where cover is null or LENGTH(cover)=0
--zad9

declare
    lobd blob;
    fils BFILE := BFILENAME('ZSBD_DIR','escape.jpg');
begin
    SELECT COVER INTO lobd
    FROM movies where id=66
    FOR UPDATE;
    DBMS_LOB.fileopen(fils,DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils));
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
end;

--zad10
create table TEMP_COVERS(
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
)

--zad11
insert into temp_covers
values(65, BFILENAME('ZSBD_DIR','eagles.jpg'),'image/jpeg')

--zad12
select movie_id,  DBMS_LOB.GETLENGTH(image)
from temp_covers

--zad13
declare
    image BFILE;
    lobd BLOB;
    m_type VARCHAR2(50);
begin
    SELECT image, mime_type INTO image, m_type
    FROM temp_covers where movie_id=65
    FOR UPDATE;
    dbms_lob.createtemporary(lobd, TRUE);
    dbms_lob.fileopen(image, dbms_lob.file_readonly); 
    dbms_lob.loadfromfile(lobd, image, DBMS_LOB.getlength(image));
    UPDATE movies
    SET cover =lobd, mime_type=m_type
    where id=65;
    dbms_lob.fileclose(image);
    dbms_lob.freetemporary(lobd);
    COMMIT;
end;

--zad14
select id,DBMS_LOB.GETLENGTH(cover)
from movies

--zad15
drop table MOVIES;
drop table TEMP_COVERS;