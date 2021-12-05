--zad1 a
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from   all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name 
    and prior t.owner = t.owner;
    
--zad1 b
select distinct m.method_name 
from all_type_methods m
where  m.type_name like 'ST_POLYGON' and m.owner = 'MDSYS'order by 1;

--zad1 c
create table MYST_MAJOR_CITIES(
FIPS_CNTRY VARCHAR2(2),
CITY_NAME VARCHAR2(40),
STGEOM ST_POINT
)
--zad1 d
insert into MYST_MAJOR_CITIES (FIPS_CNTRY,CITY_NAME,STGEOM)
select FIPS_CNTRY, CITY_NAME, TREAT(ST_POINT.FROM_SDO_GEOM(GEOM) AS ST_POINT)
from MAJOR_CITIES

--zad2 a
insert into MYST_MAJOR_CITIES (FIPS_CNTRY,CITY_NAME,STGEOM)
values('PL', 'Szczyrk', TREAT(ST_POINT.FROM_WKT('point (19.036107 49.718655)',8307) AS ST_POINT))

--zad2 b

select name, SDO_UTIL.TO_WKTGEOMETRY(geom) WKT
from RIVERS

--zad2 c

select XMLTYPE(SDO_UTIL.TO_GMLGEOMETRY(
c.stgeom.GET_SDO_GEOM()
))
from  MYST_MAJOR_CITIES c
where CITY_NAME = 'Szczyrk'

--zad 3 a
create table MYST_COUNTRY_BOUNDARIES(
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
)
--zad 3 b
insert into MYST_COUNTRY_BOUNDARIES (FIPS_CNTRY,CNTRY_NAME,STGEOM)
select c.FIPS_CNTRY, c.CNTRY_NAME, ST_MULTIPOLYGON(c.GEOM)
from COUNTRY_BOUNDARIES c

--zad 3 c
select s.stgeom.ST_GEOMETRYTYPE(), count(FIPS_CNTRY)
from MYST_COUNTRY_BOUNDARIES s
group by s.stgeom.ST_GEOMETRYTYPE() 

--zad 3 d
select s.stgeom.st_issimple()
from MYST_COUNTRY_BOUNDARIES s

--zad4 a
DELETE FROM MYST_MAJOR_CITIES a WHERE a.stgeom.st_srid() is null;

insert into MYST_MAJOR_CITIES (FIPS_CNTRY,CITY_NAME,STGEOM)
values('PL', 'Szczyrk', TREAT(ST_POINT.FROM_WKT('point (19.036107 49.718655)',8307) AS ST_POINT))

select B.CNTRY_NAME, count(*)
from MYST_COUNTRY_BOUNDARIES B,
 MYST_MAJOR_CITIES C
where B.STGEOM.ST_CONTAINS(C.STGEOM) = 1
group by B.CNTRY_NAME;

--zad4 b
select a.CNTRY_NAME, b.CNTRY_NAME
from MYST_COUNTRY_BOUNDARIES a, MYST_COUNTRY_BOUNDARIES b
where SDO_TOUCH(a.stgeom, b.stgeom)= 'TRUE'
and  a.cntry_name ='Czech Republic'

--zad4 c
select DISTINCT c.CNTRY_NAME, r.name 
from MYST_COUNTRY_BOUNDARIES c, RIVERS r
where SDO_RELATE( ST_LINESTRING(r.geom),c.stgeom, 'mask=OVERLAPBDYINTERSECT+OVERLAPBDYDISJOINT') = 'TRUE'
AND c.cntry_name ='Czech Republic'

--zad4 d
select b.stgeom.ST_AREA() +a.stgeom.ST_AREA()
from MYST_COUNTRY_BOUNDARIES a,  MYST_COUNTRY_BOUNDARIES b
where a.cntry_name ='Czech Republic' and b.cntry_name = 'Slovakia'


--zad4 e
select z.a, z.a.ST_GEOMETRYTYPE()
from(
    SELECT ST_MULTIPOLYGON(SDO_GEOM.SDO_DIFFERENCE(c.stgeom.GET_SDO_GEOM(),w.geom, 0.1)) as a
    FROM MYST_COUNTRY_BOUNDARIES c, WATER_BODIES w
    where w.name='Balaton' 
    and c.cntry_name = 'Hungary'
) z

-- zad5a
select B.CNTRY_NAME A_NAME, count(*)
from MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
where SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM,
'distance=100 unit=km') = 'TRUE'
and B.CNTRY_NAME = 'Poland'
group by B.CNTRY_NAME;

--zad5b
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
'COUNTRY_BOUNDARIES',
'GEOM',
MDSYS.SDO_DIM_ARRAY(
MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1) ),
8307
);
--zadd5c
create index MYST_MAJOR_CITIES_IDX on
MYST_MAJOR_CITIES(STGEOM)
indextype IS MDSYS.SPATIAL_INDEX;