-- zad 1
CREATE TYPE samochod AS OBJECT (
marka VARCHAR2(20),
model VARCHAR2(20),
kilometry NUMBER,
data_produkcji DATE,
cena NUMBER(10,2)
)

CREATE TABLE samochody OF samochod

INSERT INTO samochody VALUES(samochod('FIAT','BRAVA',60000, DATE '1999-11-30',25000));
INSERT INTO samochody VALUES(NEW samochod('FORD','MONDEO',80000,DATE '1997-05-10',45000));
INSERT INTO samochody VALUES(NEW samochod('MAZDA','323',12000,DATE '2000-09-22',52000));

-- zad 2 
CREATE TABLE WLASCICIELE (
IMIE VARCHAR2(100),
NAZWISKO VARCHAR2(100),
AUTO SAMOCHOD
)
INSERT INTO WLASCICIELE VALUES('JAN','KOWALSKI',NEW samochod('FIAT', 'SEICENTO', 30000, DATE '1999-11-30', 19500));
INSERT INTO WLASCICIELE VALUES('ADAM','NOWAK',NEW samochod('OPEL', 'ASTRA', 34000, DATE '1997-10-05', 33700));

desc samochod
select * from samochody

ALTER TYPE samochod REPLACE AS OBJECT (
marka VARCHAR2(20),
model VARCHAR2(20),
kilometry NUMBER,
data_produkcji DATE,
cena NUMBER(10,2),
MEMBER FUNCTION wartosc RETURN NUMBER
);

-- zad 3
CREATE OR REPLACE TYPE BODY samochod AS
MEMBER FUNCTION wartosc RETURN NUMBER IS
BEGIN
RETURN POWER(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji))*cena;
END wartosc;
END;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;

-- zad 4 
ALTER TYPE samochod ADD MAP MEMBER FUNCTION odwzoruj
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY samochod AS
    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN ROUND(kilometry/10000,0) + (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji));
    END odwzoruj;
END;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

-- zad 5

ALTER TYPE SAMOCHOD ADD MAP MEMBER FUNCTION odwzoruj
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
       RETURN POWER(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji))*cena;
    END wartosc;
    
   MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS 
   BEGIN
       RETURN (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji))+ kilometry/10000;
   END odwzoruj;
END;


CREATE TYPE wlasciciel AS OBJECT (
imie VARCHAR2(20),
nazwisko VARCHAR2(20)
)

ALTER TYPE SAMOCHOD add ATTRIBUTE (wlas REF WLASCICIEL)
CASCADE INCLUDING TABLE DATA

CREATE TABLE wlascicieleObj OF WLASCICIEL

insert into wlascicieleObj values 
(NEW WLASCICIEL('Jan','Kowalski'));

UPDATE samochody s SET s.wlas = 
(SELECT ref(a) from wlascicieleobj a where a.imie = 'Jan')

-- zad 7

--SET SERVEROUTPUT ON;

DECLARE 
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
    moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    moje_ksiazki(1) := 'harry potter';
    moje_ksiazki.EXTEND(9);
    FOR i IN 2..9 LOOP
        moje_ksiazki(i) := 'ksiazka_' || i;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
    --moje_przedmioty.EXTEND(10);
    --moje_ksiazki(10) := 'tak';
    moje_ksiazki.TRIM(5);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
    moje_ksiazki.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
END;

-- zad 9

DECLARE 
    TYPE t_miesiac IS TABLE OF VARCHAR2(12);
    m_miesiace t_miesiac := t_miesiac();
BEGIN
    m_miesiace.EXTEND(5);
    
    FOR i IN 1..5 LOOP
        m_miesiace(i) := 'styczen_' || i;
    END LOOP;

    m_miesiace(5) := 'styczen_6';
    m_miesiace.DELETE(4);
    m_miesiace.DELETE(5);
    
    if (m_miesiace.EXISTS(5)) then
         DBMS_OUTPUT.PUT_LINE('istnieje ');
    else 
        DBMS_OUTPUT.PUT_LINE('nie istnieje ');
    end if;
    
    FOR i IN m_miesiace.FIRST()..m_miesiace.LAST() LOOP
        IF m_miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(m_miesiace(i));
        END IF;
    END LOOP;
END;

-- zad 11

CREATE TYPE KOSZYK_PRODUKTOW AS TABLE OF VARCHAR2(20);

CREATE TYPE zakup AS OBJECT (
 klient_id NUMBER,
 imie VARCHAR2(30),
 koszyk KOSZYK_PRODUKTOW );

CREATE OR REPLACE TABLE ZAKUPY OF zakup
NESTED TABLE koszyk STORE AS tab_koszyk;

INSERT INTO ZAKUPY VALUES
(zakup(1,'Jan',KOSZYK_PRODUKTOW('chleb','jajka','ziemniaki')));

INSERT INTO ZAKUPY VALUES
(zakup(2,'Filip', KOSZYK_PRODUKTOW('jajka','marchew')));

SELECT * FROM ZAKUPY;

SELECT z.imie, tk.*
FROM ZAKUPY z, TABLE(z.koszyk) tk;

DELETE FROM TABLE (
SELECT z.koszyk
FROM ZAKUPY z, TABLE(z.koszyk) tk
WHERE tk.column_value = 'marchew'
) e
WHERE e.column_value = 'marchew';

-- zad 23

ALTER TYPE AUTO NOT FINAL CASCADE;

CREATE TYPE auto_osobowe UNDER AUTO (
 liczba_miejsc number,
 klimatyzacja VARCHAR2(5),
 OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
)

CREATE TYPE BODY auto_osobowe AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
    BEGIN
        if (klimatyzacja= 'tak') then
            RETURN cena*1.5;
        else
            RETURN cena;
        end if;
    END WARTOSC;
END;


CREATE TYPE auto_ciezarowe UNDER AUTO (
 ladownosc number,
 OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
)

CREATE TYPE BODY auto_ciezarowe AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
    BEGIN
        if (ladownosc>10) then
            RETURN cena*2;
        else
            RETURN cena;
        end if;
    END WARTOSC;
END;

-- inconsistent datatypes: expected %s got %s
INSERT INTO AUTA VALUES (new Auto_osobowe('FIAT1','BRAVA',60000,DATE '1999-11-30',25000,4,'tak'));
INSERT INTO AUTA VALUES (new Auto_osobowe('FIAT2','BRAVA',60000,DATE '1999-11-30',25000,4,'nie'));
INSERT INTO AUTA VALUES (new auto_ciezarowe('FIAT3','BRAVA',60000,DATE '1999-11-30',25000,8));
INSERT INTO AUTA VALUES (new auto_ciezarowe('FIAT4','BRAVA',60000,DATE '1999-11-30',25000,12));

SELECT a.MARKA, a.WARTOSC() FROM AUTA a;



-- zad 22

CREATE TYPE KSIAZKA_type AS OBJECT(
    ID_KSIAZKI NUMBER PRIMARY KEY,
    ID_PISARZA NUMBER NOT NULL REFERENCES PISARZE,
    TYTUL VARCHAR2(50),
    DATA_WYDANIE DATE,
    MEMBER FUNCTION wiek RETURN NUMBER
)

CREATE OR REPLACE TYPE BODY KSIAZKA_type AS
    MEMBER FUNCTION wiek RETURN NUMBER IS
    BEGIN
        RETURN(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM DATA_WYDANIE));
    END wiek;
END;

CREATE OR REPLACE VIEW KSIAZKA_view OF KSIAZKA
WITH OBJECT IDENTIFIER(ID_KSIAZKI)
AS SELECT ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIE FROM KSIAZKA;

CREATE TYPE ksiazkiTab AS TABLE OF ksiazki;

CREATE TYPE pisarz_type AS OBJECT (
    ID_PISARZA NUMBER,
    NAZWISKO VARCHAR2(20),
    DATA_UR DATE,
    dziela ksiazkiTab,
    MEMBER FUNCTION ILE_ksiazek RETURN NUMBER 
);

CREATE OR REPLACE TYPE BODY pisarz_type AS
    MEMBER FUNCTION ILE_ksiazek RETURN NUMBER IS
    BEGIN
        RETURN ksiazkiTab.COUNT();
    END ILE_ksiazek;
END;

CREATE OR REPLACE VIEW pisarze_view OF pisarz_type
WITH OBJECT OID(ID_PISARZA) AS
SELECT p.ID_PISARZA, p.NAZWISKO, p.DATA_UR CAST( MULTISET(
    SELECT NEW KSIAZKA_type(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIE)
    FROM KSIAZKI WHERE ID_PISARZA = p.ID_PISARZA) AS dziela)
FROM PISARZE p;