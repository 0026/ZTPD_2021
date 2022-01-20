-- Operator CONTAINS - Podstawy
--1
create table CYTATY
as select * from ZSBD_TOOLS.CYTATY;

--2
select *
from CYTATY
where lower(tekst) like '%optymista%' and lower(tekst) like '%pesymista%';

--3
create index CYTATY_IDX on CYTATY(tekst)
indextype is CTXSYS.CONTEXT;

--4
select *
from CYTATY
where CONTAINS(tekst, 'optymista')>0 
AND CONTAINS(tekst, 'pesymista')>0

--5
select *
from CYTATY
where CONTAINS(tekst, 'optymista')=0 
AND CONTAINS(tekst, 'pesymista')>0

--6
select *
from CYTATY
WHERE CONTAINS(tekst, 'near((pesymista, optymista), 3, TRUE)')>0

--7
select *
from CYTATY
WHERE CONTAINS(tekst, 'near((pesymista, optymista), 10, TRUE)')>0

--8
select *
from CYTATY
WHERE CONTAINS(tekst, 'życi%')>0

--9
select ID, AUTOR, TEKST, SCORE(1)
from CYTATY
WHERE CONTAINS(tekst, 'życi%',1)>0

--10
select ID, AUTOR, TEKST, SCORE(1)
from CYTATY
WHERE CONTAINS(tekst, 'życi%',1)>0
ORDER BY SCORE(1) DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

--11
select *
from CYTATY
where CONTAINS(tekst, '!probelm')>0 

--12
insert into CYTATY
values (39,'Bertrand Russell', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.')
-----
commit

--13
select *
from CYTATY
where CONTAINS(tekst, 'głupcy')>0 
-- uzyskany wynik można wyjaśnić tym że nowo wstawiona wartość nie została ujęta w indeksie który został stworzony wczesniej
-- ewentualnie można zakładać że to sprawka kodowania gdyż słowo zawiera polski znak "ł"

--14
select *
from DR$CYTATY_IDX$I 

--15
drop index CYTATY_IDX
--
create index CYTATY_IDX on CYTATY(tekst)
indextype is CTXSYS.CONTEXT;
--
commit
--

--16
select *
from CYTATY
where CONTAINS(tekst, 'głupcy')>0 
-- zapytanie zwróciło poprawną wartość

--17
drop index CYTATY_IDX
--
drop table CYTATY
--
commit

--Zaawansowane indeksowanie i wyszukiwanie
--1
create table QUOTES
as select * from ZSBD_TOOLS.QUOTES;

--2
create index QUOTES_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT;

--3
select *
from QUOTES
where CONTAINS(text,'$work')>0;

select *
from QUOTES
where CONTAINS(text,'$work')>0;

select *
from QUOTES
where CONTAINS(text,'working')>0;

select *
from QUOTES
where CONTAINS(text,'$working')>0;

--4
select *
from QUOTES
where CONTAINS(text,'it')>0;
-- prawdopodobnie słowo to należy do listy stop wordsów których nie opłaca się idneksować

--5
select *
from CTX_STOPLISTS
-- uważam że została wykorzystana domyślna lista (DEFAULT_STOPLIST)

--6
select *
from CTX_STOPWORDS

--7
drop index QUOTES_IDX
--
commit
--
create index QUOTES_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT
parameters ('stoplist CTXSYS.EMPTY_STOPLIST')

--8
select *
from QUOTES
where CONTAINS(text,'it')>0;
-- tym razem zapytanie zwrócił rekordy

--9
select *
from QUOTES
where CONTAINS(text,'fool')>0 and CONTAINS(text,'humans')>0;

--10
select *
from QUOTES
where CONTAINS(text,'fool')>0 and CONTAINS(text,'computer')>0;

--11
select *
from QUOTES
where contains(text,'(fool and humans) within SENTENCE',1)>0;

--12
drop index QUOTES_IDX

--13
begin
 ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
 ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
 ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end; 

--14
create index QUOTES_IDX on QUOTES(TEXT)
 indextype is ctxsys.context
 parameters ('section group nullgroup');

--15
select *
from QUOTES
where contains(text,'(fool and humans) within SENTENCE',1)>0;

select *
from QUOTES
where contains(text,'(fool and computer) within SENTENCE',1)>0;
--oba polecenia wykonały się, pierwsze nie zwróciło żadnego rekordu natomiast drugie zwróciło rekord 

--16
select *
from QUOTES
where contains(text,'humans',1)>0;
--zapytanie zwróciło rekordy ze słowem non-humans, może być to spowodowane tym że oprogramowanie używa dodatkowego słownika którym się sugeruje

--17
drop index QUOTES_IDX

begin
 ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
 ctx_ddl.set_attribute('lex_z_m','printjoins', '_-');
 ctx_ddl.set_attribute ('lex_z_m','index_text', 'YES');
end;

create index QUOTES_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT
parameters ( 'LEXER lex_z_m' ); 

--18
select *
from QUOTES
where contains(text,'humans',1)>0;
-- tym razem w zbiorze rekordów nie znalazły się te ze słowem non-humans

--19
select *
from QUOTES
where contains(text,'non\-humans',1)>0;

--20
drop index QUOTES_IDX

drop table QUOTES

begin
ctx_ddl.drop_preference('lex_z_m');
end;