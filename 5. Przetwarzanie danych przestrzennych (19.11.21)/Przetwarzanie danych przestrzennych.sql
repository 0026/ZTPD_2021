--zad1 a
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
    'FIGURY',
    'KSZTALT',
MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 1, 8, 0.1),
        MDSYS.SDO_DIM_ELEMENT('Y', 1, 7, 0.1)
    ),
    NULL
);
--zad1 b
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000,8192,10,2) 
FROM dual;

--zad1 c
create index figury_ksztalt_idx
on figury(ksztalt)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2; 

--zad1 d
SELECT id
FROM figury
WHERE SDO_FILTER(KSZTALT,
SDO_GEOMETRY(2001,null,
    SDO_POINT_TYPE(3,3,null),
    null,null)) = 'TRUE';

--zad1 e
select ID
from FIGURY
where SDO_RELATE(KSZTALT,
    SDO_GEOMETRY(2001,null,
    SDO_POINT_TYPE(3,3,null),
    null,null),
    'mask=ANYINTERACT') = 'TRUE';

--zad2 a
SELECT CITY_NAME, cor.x, cor.y 
FROM MAJOR_CITIES, TABLE(SDO_UTIL.GETVERTICES(MAJOR_CITIES.geom)) cor
WHERE CITY_NAME = 'Warsaw';

SELECT city_name,sdo_nn_distance(1) distance
FROM major_cities
WHERE   sdo_nn(geom, mdsys.sdo_geometry(2001, 8307, NULL, 
            mdsys.sdo_elem_info_array(1, 1, 1),
            mdsys.sdo_ordinate_array(21.0118794, 52.2449452)),
            'sdo_num_res=10 unit=km', 1) = 'TRUE' AND
        city_name != 'Warsaw'
ORDER BY distance asc
FETCH FIRST 9 ROWS ONLY;

--zad 2 b 
select C.CITY_NAME
from MAJOR_CITIES C
where SDO_WITHIN_DISTANCE(C.GEOM,SDO_GEOMETRY(2001,8307,null,
        MDSYS.SDO_ELEM_INFO_ARRAY(1, 1, 1),
        MDSYS.SDO_ORDINATE_ARRAY(21.0118794, 52.2449452)),
        'distance=100 unit=km') = 'TRUE' AND 
        city_name != 'Warsaw';


--zad 2 c
select CITY_NAME,CNTRY_NAME
from MAJOR_CITIES
where SDO_RELATE(GEOM,(
            SELECT GEOM 
            FROM COUNTRY_BOUNDARIES 
            WHERE CNTRY_NAME='Slovakia'),
        'mask=ANYINTERACT') = 'TRUE';

--zad 2 d
select CNTRY_NAME, 
SDO_GEOM.SDO_DISTANCE(GEOM, (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Poland'), 1, 'unit=km')
from COUNTRY_BOUNDARIES
where SDO_RELATE(GEOM,(
        SELECT GEOM 
        FROM COUNTRY_BOUNDARIES 
        WHERE CNTRY_NAME='Poland'
        ),'mask=TOUCH') != 'TRUE' AND
    CNTRY_NAME!='Poland';

--zad 3 a
select cb2.CNTRY_NAME, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(cb1.GEOM, cb2.geom,1),2,'unit=KM') as dlugosc_w_km
from COUNTRY_BOUNDARIES cb1
left join COUNTRY_BOUNDARIES cb2 
ON SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(cb1.GEOM, cb2.geom,1),2)  >0
where cb1.CNTRY_NAME='Poland' AND
    cb2.CNTRY_NAME!='Poland';

--zad 3 b 
select CNTRY_NAME
from COUNTRY_BOUNDARIES 
order by SDO_GEOM.SDO_AREA(GEOM) desc
FETCH FIRST 1 ROWS ONLY;

---zad 3 c

select SDO_GEOM.SDO_AREA(
    SDO_GEOM.SDO_MBR(
    SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 1)), 1, 'unit=SQ_KM')
from MAJOR_CITIES A, MAJOR_CITIES B
where A.city_name = 'Warsaw'
and B.city_name = 'Lodz';

--zad 3 d
select CAST(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 1).GET_DIMS() as varchar(10))||
CAST(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 1).GET_LRS_DIM() as varchar(10)) ||
SUBSTR('000'||CAST(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 1).GET_GTYPE() as varchar(10)),-2)
as GTYPE
from COUNTRY_BOUNDARIES A, MAJOR_CITIES B
where B.city_name = 'Prague' and
A.cntry_name = 'Poland'

--zad 3 e
select mc.city_name, cb.cntry_name ,SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(cb.geom), mc.geom) as d
from COUNTRY_BOUNDARIES  cb
right join MAJOR_CITIES mc
on cb.cntry_name=mc.cntry_name
order by d asc
FETCH FIRST 1 ROWS ONLY;

--zad 3 f
select name, sum(f)
from(
    select r.name, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(c.geom, r.geom)) as f
    from COUNTRY_BOUNDARIES c
    cross join RIVERS r 
    where c.cntry_name='Poland' and
    SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(c.geom, r.geom),1,'unit=KM')>0
)
group by name
