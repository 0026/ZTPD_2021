--zad1a
create table A6_LRS(
GEOM SDO_GEOMETRY
);

--zad1b

insert into A6_LRS
select b.geom
from MYST_MAJOR_CITIES c, STREETS_AND_RAILROADS b
where c.city_name like 'Koszalin' and
SDO_WITHIN_DISTANCE(C.stgeom, b.geom,'distance=10 unit=km') = 'TRUE'

--zad1c
select SDO_GEOM.SDO_LENGTH(GEOM, 1, 'unit=km') DISTANCE, ST_LINESTRING(GEOM).ST_NUMPOINTS() ST_NUMPOINTS
from A6_LRS

--zad1d
update A6_LRS
set GEOM = SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 276.681)

--zad1e
INSERT INTO USER_SDO_GEOM_METADATA
VALUES ('A6_LRS','GEOM',
MDSYS.SDO_DIM_ARRAY(
MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),
MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1) ),
8307);

--zad1f
CREATE INDEX lrs_routes_idx ON A6_LRS(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

--zad2a
select SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500
from A6_LRS;

--zad2b
select SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT
from A6_LRS;

--zad2c
select SDO_LRS.LOCATE_PT(GEOM, 150, 0) KM150
from A6_LRS;

--zad2d
select SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160) CLIPED 
from A6_LRS;


--zad2e
select SDO_LRS.GET_NEXT_SHAPE_PT(A6.GEOM, SDO_LRS.PROJECT_PT(A6.GEOM, C.GEOM)) WJAZD_NA_A6
from A6_LRS A6, MAJOR_CITIES C where C.CITY_NAME = 'Slupsk';

--zad2f
select 
SDO_LRS.GEOM_SEGMENT_LENGTH(
SDO_LRS.OFFSET_GEOM_SEGMENT(A6.GEOM, M.DIMINFO, 50, 200, 50,
 'unit=m arc_tolerance=1')
 )/1000
 gazociag
from A6_LRS A6, USER_SDO_GEOM_METADATA M
where M.TABLE_NAME = 'A6_LRS' and M.COLUMN_NAME = 'GEOM'
