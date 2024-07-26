------------------------------------------CONSULTAS---------------------------------------------------


----------------------------5 CONSULTS SIMPLES DE UNA SOLA TABLA-----------------------------



---------TABLA INCIDENCIAS -------


--Obtener el número de expediente y el número de incidencias asociadas a cada expediente, ordenado por el ----número de incidencias de forma descendente:

SELECT N_EXPEDIENTE, COUNT(N_INCIDENCIA) AS NUM_INCIDENCIAS 
FROM INCIDENCIAS 
GROUP BY N_EXPEDIENTE 
ORDER BY NUM_INCIDENCIAS DESC;


--Mostrar el número de incidencias asociadas a cada expediente y el número total de incidencias en la tabla, --junto con el porcentaje que representa el número de incidencias por expediente respecto al total:

SELECT N_EXPEDIENTE, COUNT(N_INCIDENCIA) AS NUM_INCIDENCIAS, 
  (COUNT(N_INCIDENCIA) / (SELECT COUNT(*) FROM INCIDENCIAS)) * 100 AS PORCENTAJE_TOTAL
FROM INCIDENCIAS 
GROUP BY N_EXPEDIENTE;



--------TABLA ABRIR-------

--Todas las incidencias de Maria junto con las demas excepto las que hallan ocurrido mas tarde de las 14:00:

SELECT *
FROM ABRIR
WHERE NOM_RESP = 'María Gómez' OR (NOM_RESP <> 'María Gómez' AND HORA < '14:00');


--Obtener la hora, el trabajador responsable y el tipo de daños de todas las incidencias en la tabla 'ABRIR' --que están relacionadas con expedientes que empiezan con 'EXP00' en la tabla 'INCIDENCIAS', y donde el tipo 
--de personal ('TIP_PERSONAL') es igual a 2222. Ordenar los resultados por hora de forma ascendente.



SELECT HORA, QUIEN, DANOS
FROM ABRIR
WHERE N_INCIDENCIA IN (
    SELECT N_INCIDENCIA
    FROM INCIDENCIAS
    WHERE N_EXPEDIENTE LIKE 'EXP00%'
)
AND TIP_PERSONAL = 2222
ORDER BY HORA ASC;


--Todas las incidencias cuyo número de incidencia sea menor o igual a 2222 y las ordena de forma descendente 
--según el número de incidencia.



SELECT A1.HORA, A1.DANOS, A1.NOM_RESP, A1.QUIEN, A1.TIP_PERSONAL, A1.N_INCIDENCIA
FROM ABRIR A1
WHERE A1.N_INCIDENCIA IN (
    SELECT A2.N_INCIDENCIA
    FROM ABRIR A2
    WHERE A2.N_INCIDENCIA <= 2222
)
ORDER BY A1.N_INCIDENCIA DESC;





----------------------------------DOS ACTUALIZACIONES Y BORRADOS--------------------------------------



-----------TABLA OPERARIOS ENTREGAS----------

--Actualización 1: Cambiar el turno y la pausa del tractor con matrícula 'ABC123'.


UPDATE OPERARIO_ENTREGAS
SET TURNO = 'Tarde', PAUSA = 'No'
WHERE MATRICULA = 'ABC123';


--Actualización 2: Cambiar el número del tractor y la matrícula del tractor con TIP_OPERARIOENTREGAS = 3333.

UPDATE OPERARIO_ENTREGAS
SET N_TRACTOR = 'Tractor 6', MATRICULA = 'PQR678'
WHERE TIP_OPERARIOENTREGAS = 3333;


--Borrado 1 :Esta consulta DELETE eliminará los registros en la tabla OPERARIO_ENTREGAS que cumplan las 
--siguientes condiciones:

--El TIP_OPERARIOENTREGAS debe corresponder al TIP_PERSONAL de la tabla ABRIR.

--La incidencia (N_INCIDENCIA) en la tabla ABRIR debe ocurrir entre las horas 10:00 y 14:00.

--El turno en la tabla OPERARIO_ENTREGAS debe ser 'Mañana'.


DELETE FROM OPERARIO_ENTREGAS
WHERE TIP_OPERARIOENTREGAS IN (
    SELECT A.TIP_PERSONAL
    FROM ABRIR A
    WHERE A.N_INCIDENCIA IN (
        SELECT DISTINCT N_INCIDENCIA
        FROM ABRIR
        WHERE HORA BETWEEN '10:00' AND '14:00'
        AND TURNO = 'Mañana'
    )
);






--Borrado 2: Eliminar todos los tractores con un número de tractor que termine en un número impar (considerando solo el último dígito del número del tractor).


DELETE FROM OPERARIO_ENTREGAS
WHERE SUBSTR(N_TRACTOR, -1, 1) IN ('1', '3', '5', '7', '9');




--------------------------------------------------3 CONSULTAS USANDO MAS DE UNA TABLA---------------------------------------


------TABLA CAPATAZHIPODROMO   Y   OPERARIOS_HIPODROMO-------

--Esta consulta SQL cruza las tablas CAPATAZ_HIPODROMO y OPERARIOS_HIPODROMO y ofrece información detallada 
--sobre los capataces y operarios en función de las siguientes características:

--El turno del capataz (TURNO).
--El identificador del capataz (TIP_CAPATAZHIPODROMO).
--El número total de operarios en cada grupo (NUM_OPERARIOS).
--La longitud promedio de las pausas para cada grupo (AVG_PAUSA_LENGTH).
--La cantidad de operarios con cada destino de salida (LBA_COUNT, STN_COUNT, LGW_COUNT, JFK_COUNT, --ORL_COUNT).
--Para lograr esto, la consulta cruza las tablas CAPATAZ_HIPODROMO (CH) y OPERARIOS_HIPODROMO (OH) utilizando 
--la clave foránea TIP_CAPATAZHIPODROMO, agrupa los resultados por TURNO y TIP_CAPATAZHIPODROMO, y luego 
--calcula las estadísticas mencionadas anteriormente para cada grupo. Finalmente, ordena los resultados por
--TIP_CAPATAZHIPODROMO en orden ascendente.


SELECT CH.TURNO,
       CH.TIP_CAPATAZHIPODROMO,
       COUNT(OH.PAUSA) AS NUM_OPERARIOS,
       AVG(LENGTH(OH.PAUSA)) AS AVG_PAUSA_LENGTH,
       SUM(DECODE(OH.DESTINOS_SALIDA, 'lba', 1, 0)) AS LBA_COUNT,
       SUM(DECODE(OH.DESTINOS_SALIDA, 'stn', 1, 0)) AS STN_COUNT,
       SUM(DECODE(OH.DESTINOS_SALIDA, 'lgw', 1, 0)) AS LGW_COUNT,
       SUM(DECODE(OH.DESTINOS_SALIDA, 'jfk', 1, 0)) AS JFK_COUNT,
       SUM(DECODE(OH.DESTINOS_SALIDA, 'orl', 1, 0)) AS ORL_COUNT
FROM CAPATAZ_HIPODROMO CH
JOIN OPERARIOS_HIPODROMO OH ON CH.TIP_CAPATAZHIPODROMO = OH.TIP_CAPATAZHIPODROMO
GROUP BY CH.TURNO, CH.TIP_CAPATAZHIPODROMO
ORDER BY CH.TIP_CAPATAZHIPODROMO ASC;


----------TABLAS ABRIR   Y  INCIDENCIAS-------------------

--Obtén una lista de todas las incidencias abiertas entre las 10:00 y las 14:00 horas,
--en las que el personal encargado de su apertura tenga el código '1111' y su nombre comience por la letra 'J' o 'M'.
--Además, muestra el número de expediente correspondiente a cada incidencia y ordena el resultado por la hora de apertura de la incidencia de forma ascendente

SELECT A.HORA, A.DANOS, A.NOM_RESP, A.QUIEN, I.N_EXPEDIENTE
FROM ABRIR A
INNER JOIN INCIDENCIAS I ON A.N_INCIDENCIA = I.N_INCIDENCIA
WHERE A.TIP_PERSONAL = 1111
AND A.HORA BETWEEN '10:00' AND '14:00'
AND (A.NOM_RESP LIKE 'J%' OR A.NOM_RESP LIKE 'M%')
ORDER BY A.HORA ASC;


------------------TABLAS GRUPO    Y     OPERARIO_PISTA--------------------

 --Obtenen la cantidad de miembros de cada grupo (CUANTOS), la información del vuelo (VUELOS), el tipo de grupo (TIP_GRUPO), el tipo de capataz de pista asociado 
 --(TIP_CAPATAZPISTA), la cantidad de bodegas (N_BODEGAS), la cinta (CINTA) y las matrículas (MATRICULAS) de los operarios de pista. Mostrar solo aquellos registros que
 --cumplan con una de las siguientes condiciones:

--La cantidad de miembros en el grupo es mayor a 10, la cantidad de bodegas del operario de pista es mayor a 3 y la longitud de las matrículas del operario de pista es 
--mayor a 20.

--La cantidad de miembros en el grupo es menor o igual a 10, la cantidad de bodegas del operario de pista es menor o igual a 3 y la longitud de las matrículas del --operario de pista es menor o igual a 20.

--Ordenar los resultados por el tipo de grupo en orden ascendente.


SELECT 
  G.CUANTOS,G.VUELOS,G.TIP_GRUPO,G.TIP_CAPATAZPISTA,OP.N_BODEGAS,OP.CINTA,OP.MATRICULAS
FROM 
  GRUPO G
JOIN 
  OPERARIO_PISTA OP ON G.TIP_GRUPO = OP.TIP_GRUPOPISTA
WHERE 
  (G.CUANTOS > 10 AND OP.N_BODEGAS > 3 AND LENGTH(OP.MATRICULAS) > 20)
  OR
  (G.CUANTOS <= 10 AND OP.N_BODEGAS <= 3 AND LENGTH(OP.MATRICULAS) <= 20)
ORDER BY 
  G.TIP_GRUPO ASC;




-------------------------------------------------------------3 CONSULTAS    CON OUTER JOIN------------------------------------------------


------------------TABLAS GRUPO    Y     OPERARIO_PISTA--------------------


--ESTA CONSULTA:

--Incluye los registros donde CUANTOS es mayor a 10, N_BODEGAS es mayor a 3 y la longitud de MATRICULAS es mayor a 20, pero TIP_CAPATAZPISTA es diferente de TIP_GRUPOPISTA.
--Incluye los registros donde CUANTOS es igual o menor a 10, N_BODEGAS es igual o menor a 3 y la longitud de MATRICULAS es igual o menor a 20, pero TIP_CAPATAZPISTA es igual a TIP_GRUPOPISTA.
--Incluye los registros donde CUANTOS es NULL y N_BODEGAS no es NULL, pero la longitud de MATRICULAS es mayor que la longitud de CINTA.
--Incluye los registros donde CUANTOS no es NULL y N_BODEGAS es NULL, pero la longitud de VUELOS es mayor que CUANTOS.
--Finalmente, ordena los resultados por TIP_GRUPO en orden ascendente.





SELECT 
    G.CUANTOS, G.VUELOS, G.TIP_GRUPO, G.TIP_CAPATAZPISTA,
    O.N_BODEGAS, O.CINTA, O.MATRICULAS, O.TIP_GRUPOPISTA
FROM
    GRUPO G
LEFT OUTER JOIN OPERARIO_PISTA O
    ON G.TIP_GRUPO = O.TIP_GRUPOPISTA 
    AND ((G.CUANTOS > 10 AND O.N_BODEGAS > 3 AND LENGTH(O.MATRICULAS) > 20 AND G.TIP_CAPATAZPISTA <> O.TIP_GRUPOPISTA)
    OR (G.CUANTOS <= 10 AND O.N_BODEGAS <= 3 AND LENGTH(O.MATRICULAS) <= 20 AND G.TIP_CAPATAZPISTA = O.TIP_GRUPOPISTA)
    OR (G.CUANTOS IS NULL AND O.N_BODEGAS IS NOT NULL AND LENGTH(O.MATRICULAS) > LENGTH(O.CINTA))
    OR (G.CUANTOS IS NOT NULL AND O.N_BODEGAS IS NULL AND LENGTH(G.VUELOS) > G.CUANTOS))
ORDER BY G.TIP_GRUPO ASC;






-------------------TABLAS PERSONAL   Y  CAPATACES---------------------


--Esta select obtiene:

--Las  filas donde la longitud del nombre es mayor a 4, la longitud del apellido es mayor a 6, el valor de la columna DNI_CAPATAZ no es NULL y la longitud del --DNI_CAPATAZ es mayor a 10.

--Incluye las filas donde la longitud del nombre es igual o menor a 4, la longitud del apellido es igual o menor a 6, el valor de la columna DNI_CAPATAZ no es NULL y --la longitud del DNI_CAPATAZ es igual o menor a 10.

--E incluye filas donde la longitud del nombre es NULL, y la longitud del apellido no es NULL.


SELECT 
    P.TIP_PERSONAL, P.PCP, P.NOMBRE, P.APELLIDO, P.DNI_JEFE_DE_TURNO, C.DNI_CAPATAZ, C.TIP_CAPATAZ
FROM
    PERSONAL P
LEFT OUTER JOIN CAPATACES C 
    ON P.TIP_PERSONAL = C.TIP_CAPATAZ
    AND ((LENGTH(P.NOMBRE) > 4 AND LENGTH(P.APELLIDO) > 6 AND C.DNI_CAPATAZ IS NOT NULL AND LENGTH(C.DNI_CAPATAZ) > 10)
    OR (LENGTH(P.NOMBRE) <= 4 AND LENGTH(P.APELLIDO) <= 6 AND C.DNI_CAPATAZ IS NOT NULL AND LENGTH(C.DNI_CAPATAZ) <= 10)
    OR (P.NOMBRE IS NULL AND P.APELLIDO IS NOT NULL AND C.DNI_CAPATAZ IS NULL)
    OR (P.NOMBRE IS NOT NULL AND P.APELLIDO IS NULL AND C.DNI_CAPATAZ IS NULL))
ORDER BY P.TIP_PERSONAL ASC;





--------------TABLAS   ABRIR   E  INCIDENCIAS------------------



--Esta consulta obtiene los datos de la tabla ABRIR y la tabla INCIDENCIAS, incluyendo las incidencias que no tengan ninguna apertura asociada. Muestra únicamente los 
--registros de apertura de incidencias en las que el responsable tenga nombre 'Juan Pérez' y la hora de apertura sea anterior a las 12:00 del mediodía. Ordena los 
--resultados por número de incidencia de forma descendente.


SELECT 
    a.HORA, a.DANOS, a.NOM_RESP, a.QUIEN, i.N_EXPEDIENTE
FROM
    ABRIR a 
LEFT OUTER JOIN INCIDENCIAS i 
    ON a.N_INCIDENCIA = i.N_INCIDENCIA AND a.NOM_RESP = 'Juan Pérez' AND a.HORA < '12:00:00'
ORDER BY a.N_INCIDENCIA DESC;







------------------------------------------------------3 CONSULTAS USANDO FUNCIONES-------------------------------------------------------------------------------------





--cuenta el número de incidencias distintas por expediente, obtiene la hora máxima y mínima en que se abrieron las incidencias,
--la suma y el promedio de los tipos de personal que se encargaron de las incidencias.

SELECT 
  COUNT(DISTINCT A.N_INCIDENCIA) AS NUM_INCIDENCIAS,
  I.N_EXPEDIENTE,
  MAX(A.HORA) AS HORA_MAXIMA,
  MIN(A.HORA) AS HORA_MINIMA,
  SUM(A.TIP_PERSONAL) AS SUMA_TIP_PERSONAL,
  AVG(A.TIP_PERSONAL) AS PROMEDIO_TIP_PERSONAL
FROM 
  ABRIR A 
  JOIN INCIDENCIAS I ON A.N_INCIDENCIA = I.N_INCIDENCIA
GROUP BY I.N_EXPEDIENTE;







--La consulta devuelve el número de incidencias y el mes/año en que ocurrieron las incidencias en la tabla ABRIR, en el formato 'YYYY-MM', que se repitieron más de una
--vez. La consulta utiliza una subconsulta para unir la tabla ABRIR consigo misma y formar la fecha completa de cada incidencia, luego utiliza la función TO_DATE para 
--convertir la cadena de texto en formato de fecha, y finalmente agrupa por mes/año y aplica la cláusula HAVING para filtrar aquellos meses/años con más de una
--incidencia repetida.

SELECT 
  COUNT(*) AS NUMERO_INCIDENCIAS, 
  TO_CHAR(FECHA_INCIDENCIA, 'YYYY-MM') AS MES_ANO
FROM (
  SELECT 
    A.N_INCIDENCIA, 
    TO_DATE(A.HORA, 'HH24:MI') AS FECHA_INCIDENCIA
  FROM ABRIR A
)
GROUP BY TO_CHAR(FECHA_INCIDENCIA, 'YYYY-MM')
HAVING COUNT(*) > 1
ORDER BY MES_ANO ASC;




--Esta consulta SELECT devuelve una lista de empleados (PERSONAL) y la información de sus jefes de turno (JEFE_DE_TURNO), incluyendo el tipo de personal (TIP_PERSONAL), 
--nombre, apellido, DNI del jefe de turno, cuántos empleados están a cargo del jefe y la antigüedad del jefe de turno.





SELECT P.TIP_PERSONAL, P.NOMBRE, P.APELLIDO, J.DNI, J.CUANTOS, J.ANTIGUEDAD
FROM PERSONAL P
JOIN JEFE_DE_TURNO J ON P.DNI_JEFE_DE_TURNO = J.DNI
WHERE LENGTH(P.NOMBRE) > 4
  AND J.ANTIGUEDAD > 2
  AND J.CUANTOS > 3
GROUP BY P.TIP_PERSONAL, P.NOMBRE, P.APELLIDO, J.DNI, J.CUANTOS, J.ANTIGUEDAD
HAVING AVG(LENGTH(P.APELLIDO)) > 5
ORDER BY J.ANTIGUEDAD DESC, J.DNI ASC;




--Obtener el DNI y la antigüedad de cada jefe de turno, junto con la cantidad de empleados que tienen a su cargo, donde la antigüedad del jefe de turno es mayor a 2 
--años y el número de empleados a cargo es mayor a 3, o donde la longitud del nombre del empleado es mayor a 4 caracteres. Filtrar los resultados para incluir solo 
--aquellos grupos en los que el número de empleados asignados al jefe de turno sea igual o mayor a 1 y la longitud promedio del apellido del empleado sea mayor a 5 
--caracteres. Ordenar los resultados por antigüedad del jefe de turno en orden descendente y, en caso de empate, por DNI en orden ascendente



SELECT J.DNI, J.ANTIGUEDAD, COUNT(P.TIP_PERSONAL) AS NUM_PERSONAL
FROM JEFE_DE_TURNO J
JOIN PERSONAL P ON J.DNI = P.DNI_JEFE_DE_TURNO
GROUP BY J.DNI, J.ANTIGUEDAD
HAVING COUNT(P.TIP_PERSONAL) >= 1
  AND AVG(LENGTH(P.APELLIDO)) > 5
ORDER BY J.ANTIGUEDAD DESC, J.DNI ASC;





---------------------------------------------------------2 CONSULTAS USANDO SUBCONSULTAS-----------------------------------------------------------------


--Se Obtiene el número (BN), el nombre, el peso del equipaje, el contenido y el peso del equipaje especial de aquellos pasajeros cuyo nombre es 'Pablo Garramone', y cuyo peso del equipaje es mayor al 50% del promedio de peso de todos los equipajes, y cuyo total de equipajes es igual al mínimo total de equipajes de todos los registros cuyo nombre no sea 'Pablo Garramone' más 1 unidad.




SELECT E.BN, E.NOMBRE, E.PESO AS PESO_EQUIPAJE, EE.CONTENIDO, EE.PESO AS PESO_ESPECIAL
FROM EQUIPAJES E
JOIN EQUIPAJE_ESPECIAL EE ON E.BN = EE.BN
WHERE E.NOMBRE = 'Pablo Garramone'
  AND E.PESO > (
    SELECT AVG(PESO) * 0.5
    FROM EQUIPAJES
  )
  AND E.TOTAL = (
    SELECT MIN(TOTAL) + 1
    FROM EQUIPAJES
    WHERE NOMBRE != 'Pablo Garramone'
  );





--Obtener el TIP_PERSONAL, nombre, apellido, DNI del jefe de turno, antigüedad del jefe de turno, TIP_CAPATAZ y DNI del capataz para aquellos empleados que sean
--capataces y cuyos TIP_PERSONAL estén dentro de los primeros 3 registros de la siguiente subconsulta: seleccionar los empleados que tienen jefes de turno con más de 2 
--años de antigüedad y cuyo nombre tiene más de 4 caracteres, agruparlos por TIP_PERSONAL, y filtrar aquellos grupos en los que el número de jefes asignados al 
--empleado sea igual o mayor a 1 y la longitud promedio del apellido del empleado sea mayor a 5 caracteres. Ordenar los resultados por el número de jefes asignados en 
--orden descendente.



SELECT P.TIP_PERSONAL, P.NOMBRE, P.APELLIDO, J.DNI, J.ANTIGUEDAD, C.TIP_CAPATAZ, C.DNI_CAPATAZ
FROM PERSONAL P
JOIN JEFE_DE_TURNO J ON P.DNI_JEFE_DE_TURNO = J.DNI
JOIN CAPATACES C ON P.TIP_PERSONAL = C.TIP_CAPATAZ
WHERE P.TIP_PERSONAL IN (
  SELECT TIP_PERSONAL
  FROM (
    SELECT P.TIP_PERSONAL, COUNT(P.DNI_JEFE_DE_TURNO) AS NUM_JEFES
    FROM PERSONAL P
    JOIN JEFE_DE_TURNO J ON P.DNI_JEFE_DE_TURNO = J.DNI
    WHERE J.ANTIGUEDAD > 2 AND LENGTH(P.NOMBRE) > 4
    GROUP BY P.TIP_PERSONAL
    HAVING COUNT(P.DNI_JEFE_DE_TURNO) >= 1 AND AVG(LENGTH(P.APELLIDO)) > 5
    ORDER BY NUM_JEFES DESC
  )
  WHERE ROWNUM <= 3
);




-----------------------------------------------------------2 CONSULTAS CON SUBCONSULTAS EN EL WHERE Y EN EL HAVING -------------------------------------


--Obten los vuelos que han sido atendidos por el capataz de pista que trabaja en la bodega con mayor número de operarios.Agrupa por vuelo y  filtra aquellos que han sido atendidos por al menos la misma cantidad de grupos que el promedio de grupos atendidos por vuelo.



SELECT VUELOS, COUNT(*) AS TOTAL_GRUPOS
FROM GRUPO
WHERE TIP_CAPATAZPISTA = 
  (SELECT TIP_CAPATAZPISTA 
   FROM OPERARIO_PISTA 
   WHERE N_BODEGAS = 
     (SELECT MAX(N_BODEGAS) 
      FROM OPERARIO_PISTA))
GROUP BY VUELOS
HAVING COUNT(*) >= 
  (SELECT AVG(TOTAL_GRUPOS) 
   FROM 
     (SELECT VUELOS, COUNT(*) AS TOTAL_GRUPOS 
      FROM GRUPO 
      GROUP BY VUELOS));




--Esta consulta selecciona el nombre de los responsables de las incidencias (almacenado en la columna NOM_RESP) y cuenta el número total de incidencias para cada uno
--de ellos (usando COUNT(*)). Se filtra por aquellas incidencias cuyo número (almacenado en la columna N_INCIDENCIA) se encuentre en un conjunto de incidencias cuyos 
--números de expediente se encuentran en una lista predefinida. Luego, se agrupan los resultados por el nombre de los responsables y se filtra para mostrar solo 
--aquellos que tienen un número total de incidencias mayor o igual al promedio del número total de incidencias para todos los responsables.



SELECT A.NOM_RESP, COUNT(*) AS TOTAL_INCIDENCIAS
FROM ABRIR A
WHERE A.N_INCIDENCIA IN
(SELECT I.N_INCIDENCIA
FROM INCIDENCIAS I
WHERE I.N_EXPEDIENTE IN ('EXP001', 'EXP002', 'EXP003', 'EXP004', 'EXP005'))
GROUP BY A.NOM_RESP
HAVING COUNT(*) >=
(SELECT AVG(TOTAL_INCIDENCIAS)
FROM
(SELECT COUNT(*) AS TOTAL_INCIDENCIAS
FROM ABRIR
WHERE N_INCIDENCIA IN
(SELECT N_INCIDENCIA
FROM INCIDENCIAS
WHERE N_EXPEDIENTE IN ('EXP001', 'EXP002', 'EXP003', 'EXP004', 'EXP005'))
GROUP BY NOM_RESP));





----------------------------------------- 3 ACTUALIZACIONES USANDO SUBCONSULTAS EN EL WHERE Y EN EL SET----------------------------------------------------



--Actualiza la columna "CUANTOS" de la tabla "GRUPO" con el número de registros correspondientes a cada grupo en la tabla "OPERARIO_PISTA".
-- Solo se deben actualizar :
--las filas de "GRUPO" que tengan registros relacionados en "OPERARIO_PISTA



UPDATE GRUPO
SET CUANTOS = (SELECT COUNT(*) FROM OPERARIO_PISTA WHERE TIP_GRUPOPISTA = GRUPO.TIP_GRUPO)
WHERE EXISTS (SELECT 1 FROM OPERARIO_PISTA WHERE TIP_GRUPOPISTA = GRUPO.TIP_GRUPO);



--La consulta actualiza la columna PAUSA en la tabla OPERARIOS_HIPODROMO en función del valor de la columna TURNO en la tabla CAPATAZ_HIPODROMO, y solo para aquellos
--registros que tienen un turno 'Mañana', 'Tarde' o 'Noche'.



UPDATE OPERARIOS_HIPODROMO
SET PAUSA = (
SELECT CASE
WHEN CH.TURNO = 'Mañana' THEN '25 minutos'
WHEN CH.TURNO = 'Tarde' THEN '35 minutos'
WHEN CH.TURNO = 'Noche' THEN '45 minutos'
ELSE '15 minutos'
END
FROM CAPATAZ_HIPODROMO CH
WHERE CH.TIP_CAPATAZHIPODROMO = OPERARIOS_HIPODROMO.TIP_CAPATAZHIPODROMO
)
WHERE TIP_CAPATAZHIPODROMO IN (
SELECT TIP_CAPATAZHIPODROMO
FROM CAPATAZ_HIPODROMO
WHERE TURNO IN ('Mañana', 'Tarde', 'Noche')
);





--Esta consulta actualiza la columna DESTINOS_SALIDA en la tabla OPERARIOS_HIPODROMO en función del valor de la columna TURNO en la tabla CAPATAZ_HIPODROMO, y solo 
--para aquellos registros que tienen un turno 'Mañana', 'Tarde' o 'Noche'. 
--CH.TIP_CAPATAZHIPODROMO = OPERARIOS_HIPODROMO.TIP_CAPATAZHIPODROMO.







UPDATE OPERARIOS_HIPODROMO
SET DESTINOS_SALIDA = (
  SELECT CASE
           WHEN CH.TURNO = 'Mañana' THEN 'ams'
           WHEN CH.TURNO = 'Tarde' THEN 'cdg'
           WHEN CH.TURNO = 'Noche' THEN 'hnd'
           ELSE 'mia'
         END
  FROM CAPATAZ_HIPODROMO CH
  WHERE CH.TIP_CAPATAZHIPODROMO = OPERARIOS_HIPODROMO.TIP_CAPATAZHIPODROMO
)
WHERE TIP_CAPATAZHIPODROMO IN (
  SELECT TIP_CAPATAZHIPODROMO
  FROM CAPATAZ_HIPODROMO
  WHERE TURNO IN ('Mañana', 'Tarde', 'Noche')
);



--------------------------------------------------2 CONSULTAS  USANDO  OPERADORES DE CONJUNTOS---------------------------------------------------------------------



--Esta consulta devuelve los pares de empleados y capataces que tienen apellidos diferentes. Utiliza la operación UNION ALL para combinar los resultados de las 
--consultas de empleados y capataces.



SELECT E1.NOMBRE || ' ' || E1.APELLIDO AS PERSONA1, 'Empleado' AS TIPO1,
       E2.NOMBRE || ' ' || E2.APELLIDO AS PERSONA2, 'Empleado' AS TIPO2
FROM PERSONAL E1, PERSONAL E2
WHERE E1.APELLIDO <> E2.APELLIDO
  AND E1.TIP_PERSONAL NOT IN (SELECT TIP_CAPATAZ FROM CAPATACES)
  AND E2.TIP_PERSONAL NOT IN (SELECT TIP_CAPATAZ FROM CAPATACES)
UNION ALL
SELECT C1.NOMBRE || ' ' || C1.APELLIDO AS PERSONA1, 'Capataz' AS TIPO1,
       C2.NOMBRE || ' ' || C2.APELLIDO AS PERSONA2, 'Capataz' AS TIPO2
FROM PERSONAL C1, PERSONAL C2, CAPATACES CA1, CAPATACES CA2
WHERE C1.APELLIDO <> C2.APELLIDO
  AND C1.TIP_PERSONAL = CA1.TIP_CAPATAZ
  AND C2.TIP_PERSONAL = CA2.TIP_CAPATAZ;



--Esta consulta devuelve los nombres y apellidos de las personas que son capataces. La primera parte de la consulta utiliza INTERSECT para mostrar solo aquellos 
--empleados que también son capataces, y luego utiliza MINUS para eliminar los empleados que no son capataces.



SELECT E1.NOMBRE || ' ' || E1.APELLIDO AS PERSONA
FROM PERSONAL E1
WHERE E1.TIP_PERSONAL IN (SELECT TIP_CAPATAZ FROM CAPATACES)
INTERSECT
SELECT E2.NOMBRE || ' ' || E2.APELLIDO AS PERSONA
FROM PERSONAL E2
WHERE E2.TIP_PERSONAL IN (SELECT TIP_CAPATAZ FROM CAPATACES)
MINUS
SELECT E3.NOMBRE || ' ' || E3.APELLIDO AS PERSONA
FROM PERSONAL E3
WHERE E3.TIP_PERSONAL NOT IN (SELECT TIP_CAPATAZ FROM CAPATACES);




------------------------------------------------------------         2 VISTAS         ----------------------------------------------------------------------------


--La vista VISTACOMPUESTA10 hace lo siguiente:

--Selecciona las columnas NOMBRE, APELLIDO, CONTRATO, EMISORA, FURGONETA y TIPO_FURGO de las tablas relacionadas.

--Une la tabla PERSONAL con la tabla OPERARIOS utilizando la columna TIP_PERSONAL.

--Une la tabla PERSONAL con la tabla CAPATACES utilizando la columna TIP_PERSONAL y TIP_CAPATAZ.

--Une la tabla CAPATACES con la tabla CAPATAZ_PISTA utilizando la columna TIP_CAPATAZ y TIP_CAPATAZPISTA.

--Aplica condiciones en la cláusula WHERE para filtrar los datos:

--Excluye a las personas cuyo nombre sea 'Juan'.
--Excluye a las personas cuyo apellido sea 'Martinez' o 'Gonzalez'.
--Incluye solamente a los operarios con contrato de tipo 'Indefinido'.
--Excluye las filas donde la columna EMISORA comience con 'Emisora 4'.
--Excluye las filas donde la columna TIPO_FURGO sea 'Tipo 2' o 'Tipo 4'.

--La vista VISTACOMPUESTA10, por lo tanto, muestra una lista de empleados (nombre y apellido) con contratos indefinidos y que no sean 'Juan', 'Martinez' o 'Gonzalez',
--junto con información relacionada sobre la emisora, la furgoneta y el tipo de furgoneta utilizada en la pista. Estos datos se obtienen de las tablas PERSONAL, 
--OPERARIOS, CAPATACES y CAPATAZ_PISTA, aplicando todas las condiciones mencionadas.





CREATE VIEW VISTACOMPUESTA10 AS
SELECT 
    P.NOMBRE,
    P.APELLIDO,
    O.CONTRATO,
    CP.EMISORA,
    CP.FURGONETA,
    CP.TIPO_FURGO
FROM 
    PERSONAL P
JOIN 
    OPERARIOS O ON P.TIP_PERSONAL = O.TIP_PERSONAL
JOIN 
    CAPATACES C ON P.TIP_PERSONAL = C.TIP_CAPATAZ
JOIN 
    CAPATAZ_PISTA CP ON C.TIP_CAPATAZ = CP.TIP_CAPATAZPISTA
WHERE
    P.NOMBRE <> 'Juan'
    AND CP.FURGONETA <> 'Furgoneta 1'
    AND P.APELLIDO <> 'Martinez'
    AND P.APELLIDO <> 'Gonzalez'
    AND O.CONTRATO = 'Indefinido'
    AND CP.EMISORA NOT LIKE 'Emisora 4%'
    AND CP.TIPO_FURGO NOT IN ('Tipo 2', 'Tipo 4');
    
    

--PARA VER LA VISTA


    SELECT * FROM VISTACOMPUESTA10;


--La vista vista llamada VISTACOMPLEJA_EQUIPAJES  muestra el peso del equipaje, el BN, el nombre del pasajero, el total de equipajes, el tamaño del equipaje especial, el contenido del equipaje especial y el peso del equipaje especial.
--La vista cumple con las siguientes condiciones en el WHERE:

--El peso del equipaje en la tabla EQUIPAJES debe estar entre 10 y 20.
--El total de equipajes en la tabla EQUIPAJES debe ser mayor que 0.
--El tamaño del equipaje especial en la tabla EQUIPAJE_ESPECIAL debe ser 'Grande' o el peso del equipaje especial debe ser mayor o igual a 15.
--La longitud del contenido del equipaje especial en la tabla EQUIPAJE_ESPECIAL debe ser mayor que 10.
--El contenido del equipaje especial en la tabla EQUIPAJE_ESPECIAL no debe contener la palabra 'deportivo'.





CREATE VIEW VISTA_EQUIPAJES AS
SELECT
  E.PESO AS PESO_EQUIPAJE,
  E.BN,
  E.NOMBRE,
  E.TOTAL,
  ES.TAMAÑO,
  ES.CONTENIDO,
  ES.PESO AS PESO_ESPECIAL
FROM
  EQUIPAJES E
  INNER JOIN EQUIPAJE_ESPECIAL ES ON E.BN = ES.BN
WHERE
  E.PESO BETWEEN 10 AND 20
  AND E.TOTAL > 0
  AND (ES.TAMAÑO = 'Grande' OR ES.PESO >= 15)
  AND LENGTH(ES.CONTENIDO) > 10
  AND ES.CONTENIDO NOT LIKE '%deportivo%';





    SELECT * FROM VISTA_EQUIPAJES;


