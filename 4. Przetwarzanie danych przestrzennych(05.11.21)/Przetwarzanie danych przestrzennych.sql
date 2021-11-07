--zad1 a
CREATE TABLE FIGURY (
    id number primary key,
    KSZTALT MDSYS.SDO_GEOMETRY
)
--zad1 b
insert into figury
values(1, SDO_GEOMETRY(2003, null,null,
    SDO_ELEM_INFO_ARRAY(1, 1003, 4),
    SDO_ORDINATE_ARRAY(5,7,7,5,5,3))
);

insert into figury
values(2, SDO_GEOMETRY(2003, null,null,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(1,1,5,5))
);

insert into figury
values(3, SDO_GEOMETRY(2002, null,null,
    SDO_ELEM_INFO_ARRAY(1,4,2,1,2,1,5,2,2),
    SDO_ORDINATE_ARRAY(3,2 ,6,2, 7,3 ,8,2 ,7,1))
);

--zad1 c

insert into figury
values(4, SDO_GEOMETRY(2003, null,null,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(5,5,1,1,15,84,63,1))
);

insert into figury
values(4, SDO_GEOMETRY(2003, null,null,
    SDO_ELEM_INFO_ARRAY(1, 1003, 4),
    SDO_ORDINATE_ARRAY(1,1,2,2,7,7))
);

--zad1 d
select id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.01)
from figury;

--zad1 e
DELETE FROM figury WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.01)!='TRUE';

--zad1 f
commit;