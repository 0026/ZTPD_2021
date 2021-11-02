--zad1
create table DOKUMENTY (
ID NUMBER(12) PRIMARY KEY,
DOKUMENT CLOB
)

--zad2
declare
    dane CLOB;
begin
    for i in 1..1000
    loop
        dane:=dane || 'Oto tekst.';
    end loop;
    insert into DOKUMENTY
    values(1,dane);
end;

--zad3
--a
select * from DOKUMENTY
--b
select upper(DOKUMENT) from DOKUMENTY
--c
select LENGTH(DOKUMENT) from DOKUMENTY
--d
select DBMS_LOB.GETLENGTH(DOKUMENT) from DOKUMENTY
--e
select SUBSTR(DOKUMENT,5,1000) from DOKUMENTY
--f
select dbms_lob.substr(DOKUMENT,1000, 5) from DOKUMENTY
--zad4
insert into dokumenty
values(2, EMPTY_CLOB())
--zad5
insert into dokumenty
values(3, NULL)
commit
--zad6
--a
select * from DOKUMENTY
--b
select upper(DOKUMENT) from DOKUMENTY
--c
select LENGTH(DOKUMENT) from DOKUMENTY
--d
select DBMS_LOB.GETLENGTH(DOKUMENT) from DOKUMENTY
--e
select SUBSTR(DOKUMENT,5,1000) from DOKUMENTY
--f
select dbms_lob.substr(DOKUMENT,1000, 5) from DOKUMENTY
--zad7
select *
from all_directories

--zad8
declare
    lobd clob;
    fils BFILE:=BFILENAME('ZSBD_DIR','dokument.txt');
    doffset integer:=1;
    soffset integer:=1;
    langctx integer:=0;
    warn integer:=null;
begin
    SELECT dokument INTO lobd
    FROM dokumenty
    WHERE id=2
    FOR UPDATE;
    DBMS_LOB.fileopen(fils,DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(lobd,fils,DBMS_LOB.LOBMAXSIZE,doffset,soffset,873,langctx,warn);--873toutf-8
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji:'||warn);
end;

--zad9
UPDATE DOKUMENTY
set dokument=TO_CLOB(BFILENAME('ZSBD_DIR','dokument.txt'))
where id =3
--zad10
select * from dokumenty
--zad11
select LENGTH(DOKUMENT) from DOKUMENTY
--zad12
drop table dokumenty
--zad13
create or replace
procedure CLOB_CENSOR( 
    p_lob in out clob,
    p_what in varchar2
    )
as
n number;
p_with varchar2(256);
begin
    for i in 1..LENGTH(p_what) loop
        p_with:=p_with||'*';
    end loop;
    loop
        n := dbms_lob.instr(p_lob, p_what);
        if ( nvl(n,0) > 0 ) then
            dbms_lob.write(p_lob,LENGTH(p_what),n, p_with);
        else
            exit;
        end if;
    end loop;
    
end;

--zad14
create table copy_table as 
select * from ZSBD_TOOLS.BIOGRAPHIES;

declare
    p_lob clob;
begin
    select bio into p_lob
    from copy_table
    where id =1
    for update;
    DBMS_OUTPUT.PUT_LINE(p_lob);
    CLOB_CENSOR(p_lob,'Cimrman');
    DBMS_OUTPUT.PUT_LINE(p_lob);
    commit;
end;

--zad15
drop table copy_table;
