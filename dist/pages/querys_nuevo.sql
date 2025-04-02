--Revisar cantidad total de ciclos diferentes.
select count(DISTINCT(CICLO)) from calificaciones;

--Revisar cantidad de registros diferentes por ciclo, ordenando por ciclo.
select CICLO AS Ciclo, count(*) AS Registros from calificaciones GROUP BY CICLO ORDER BY CICLO;

--Revisar cantidad de registros diferentes por ciclo, ordenando de menor a mayor cantidad de registros.
select CICLO AS Ciclo, count(*) AS Registros from calificaciones GROUP BY CICLO ORDER BY Registros;

-- Revisar cantidad de alumnos diferentes por ciclo, ordenando de menor a mayor cantidad de alumnos.
SELECT CICLO AS Ciclo, count(DISTINCT(ALUMNO)) AS Alumnos FROM calificaciones GROUP BY CICLO ORDER BY Alumnos;

--Asignar prioridad a cada forma de evaluar calificaciones. 0 para final, 1 para extra, 2 para regula, 3 para reval
UPDATE calif_alum SET TIPASPRIO = CASE
    WHEN TIPAS='FINAL' THEN 0
    WHEN TIPAS='EXTRA' THEN 1
    WHEN TIPAS='REGULA' THEN 2
    WHEN TIPAS='REVAL' THEN 3
    ELSE '4'
END;

--Mostrar todos los alumnos que tienen registro de calificaciones para cada uno de los ciclos.
SELECT CICLO, ALUMNO FROM pruebaAlumno GROUP BY CICLO, ALUMNO ORDER BY CICLO;

--Obtener una sola calificacion de cada materia durante un ciclo especifico de un alumno especifico
SELECT CICLO,ALUMNO,DESCRIP,CALIF FROM (
    SELECT * FROM pruebaAlumno WHERE CICLO='09/10 SS' AND ALUMNO='0000437X' ORDER BY TIPASPRIO DESC
    ) 
AS calificaciones_alumno GROUP BY CICLO,ALUMNO,DESCRIP,CALIF;




--Vista para obtener todas las calificaciones de un alumno especifico en un ciclo especifico
CREATE VIEW calif_alum AS SELECT * FROM pruebaAlumno WHERE CICLO='09/10 SS' AND ALUMNO='0000437X';
--Mostrar las calificaciones finales de cada materia a partir de la vista anterior
SELECT * FROM calif_alum WHERE (MATERIA, TIPASPRIO) IN (SELECT MATERIA, MAX(TIPASPRIO) FROM calif_alum GROUP BY MATERIA);

--
CREATE VIEW califImp AS SELECT * FROM calif_alum WHERE (MATERIA, TIPASPRIO) IN (SELECT MATERIA, MAX(TIPASPRIO) FROM calif_alum GROUP BY MATERIA);
SELECT ALUMNO AS Alumno, CICLO AS Ciclo, ( SUM(CALIF) / COUNT(*) ) AS Promedio FROM califImp GROUP BY ALUMNO, CICLO;

--Vista para 
CREATE VIEW alumnoMasMatri AS (SELECT Alumno FROM (SELECT ALUMNO as Alumno, COUNT(*) AS Cant FROM
(SELECT MATRI,ALUMNO FROM calificaciones GROUP BY MATRI,ALUMNO) as grupo GROUP BY ALUMNO) AS cantidades WHERE Cant>1);
--
SELECT alumnoMasMatri.Alumno, calificaciones.MATRI FROM alumnoMasMatri CROSS JOIN calificaciones ON alumnoMasMatri.Alumno=calificaciones.ALUMNO GROUP BY Alumno, MATRI ORDER BY Alumno;

Lista de Cosas por Revisar
- Revisar coherencia de ciclo con fecha en tabla de calificaciones
- Descartar columnas que tienen información irrelevante 
- Implementar APIs, scripts y código en servidor web para consultar información específica 
- Crear tablas/vistas/consultas/uniones que contengan la información con la que vamos a trabajar 
- Hacer consultas finales a partir de las relaciones del punto previo



--Calificaciones finales por ciclo para cada alumno en cada materia--
CREATE VIEW calificaciones_finales2 AS SELECT * FROM calificaciones 
WHERE (MATERIA, REGIS) IN (SELECT MATERIA, MAX(REGIS) FROM calificaciones GROUP BY MATERIA, ALUMNO, CICLO);

--Promedios para cada alumno en cada ciclo
CREATE VIEW promedios_ciclos2 AS SELECT ALUMNO AS Alumno, CICLO AS Ciclo, 
( SUM(CALIF) / COUNT(*) ) AS Promedio FROM calificaciones_finales2 GROUP BY ALUMNO, CICLO;

--Obtener registros de calificaciones acreditadas--
CREATE VIEW califAcred AS select * from calificaciones where ACRED='S';

--Vista para ver los creditos conseguidos por cada alumno en cada materia para cada ciclo--
CREATE VIEW creditos_finales AS SELECT ALUMNO, CICLO, MATERIA, creditos FROM (
    SELECT califAcred.ALUMNO, califAcred.CICLO, califAcred.MATERIA, materias.creditos FROM 
    califAcred INNER JOIN materias ON califAcred.MATERIA=materias.cve_ce
    ) AS credCiclo
GROUP BY ALUMNO, CICLO, MATERIA, creditos;

--Vista para mostrar los creditos totales de cada alumno en cada ciclo--
CREATE VIEW creditos_ciclos AS SELECT ALUMNO AS Alumno, CICLO AS Ciclo, SUM(creditos) AS Creditos FROM creditos_finales GROUP BY ALUMNO, CICLO;






-- Vista de una union para mostrar alumno, creditos, ciclo, promedio
CREATE VIEW alumno_ciclo_prom_credit AS 
-- tomamos alumno y ciclo de p y si en promedio o créditos no hay datos, va a ser 0
SELECT  p.Alumno AS Alumno,  p.Ciclo AS Ciclo, 
    IFNULL(p.Promedio, 0) AS Promedio, 
    IFNULL(c.Creditos, 0) AS Creditos
FROM promedios_ciclos2 p
LEFT JOIN  creditos_ciclos c ON p.Alumno = c.Alumno AND p.Ciclo = c.Ciclo

UNION
-- y lo mismo para los créditos
SELECT c.Alumno AS Alumno, c.Ciclo AS Ciclo, 
    IFNULL(p.Promedio, 0) AS Promedio, 
    IFNULL(c.Creditos, 0) AS Creditos
FROM  
    creditos_ciclos c
LEFT JOIN 
    promedios_ciclos2 p ON c.Alumno = p.Alumno AND c.Ciclo = p.Ciclo;

-- mostar el total de creditos aprobados de cada alumno
Select alumno, sum(creditos) as credit_aprob from creditos_ciclos group by alumno;

-- mostar el total de creditos aprobados de cada alumno dela tabla de matricula
Select alumno, creditos from matricula;

-- mostrar los alumnos sin creditos en cada ciclo pero sólo los que no sean del plestud 403
SELECT a.* FROM alumno_ciclo_prom_credit a JOIN matricula m ON a.alumno = m.alumno 
WHERE a.creditos = 0 AND a.promedio != 0 AND m.plestud != 403;

-- mostrar los registros que no coinciden con la fecha de registro y el ciclo
SELECT alumno, ciclo, fecha FROM calif WHERE STR_TO_DATE(fecha, '%d/%m/%Y') NOT BETWEEN 
      STR_TO_DATE(CONCAT('01/01/20', LEFT(ciclo, 2)), '%d/%m/%Y') 
      AND 
      STR_TO_DATE(CONCAT('31/12/20', SUBSTRING(ciclo, 4, 2)), '%d/%m/%Y');


