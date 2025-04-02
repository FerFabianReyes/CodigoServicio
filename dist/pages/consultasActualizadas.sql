-- CONSULTAS NECESARIAS ---------------------

--Calificaciones finales por ciclo para cada alumno en cada materia--
CREATE VIEW vCalifFinalCicloMateria AS SELECT * FROM calif
WHERE (MATERIA, REGIS) IN (SELECT MATERIA, MAX(REGIS) FROM calif GROUP BY MATERIA, ALUMNO, CICLO);

--Promedios de cada ciclo para cada alumno
CREATE VIEW vPromedioCiclo AS SELECT ALUMNO AS Alumno, CICLO AS Ciclo, 
( SUM(CALIF) / COUNT(*) ) AS Promedio FROM vCalifFinalCicloMateria GROUP BY ALUMNO, CICLO;

-- Promedio final de cada alumno
CREATE VIEW vPromedioFinal AS
SELECT Alumno, ROUND(AVG(Promedio), 2) AS promedioFinal
FROM vPromedioCiclo GROUP BY Alumno;
    

--Obtener calificaciones acreditadas--
CREATE VIEW vCalifAcred AS select * from calificaciones where ACRED='S';

--Creditos en cada ciclo de cada materia de los alumnos
CREATE VIEW vCrediCicloMateria AS SELECT ALUMNO, CICLO, MATERIA, creditos FROM (
    SELECT califAcred.ALUMNO, califAcred.CICLO, califAcred.MATERIA, materias.creditos FROM 
    califAcred INNER JOIN materias ON califAcred.MATERIA=materias.cve_ce
    ) AS credCiclo
GROUP BY ALUMNO, CICLO, MATERIA, creditos;

-- Creditos de cada ciclo
CREATE VIEW vCreditCiclo AS SELECT ALUMNO AS Alumno, CICLO AS Ciclo, SUM(creditos) AS Creditos FROM crediCicloMateria GROUP BY ALUMNO, CICLO;

-- mostar el total de creditos aprobados de cada alumno
Select alumno, sum(creditos) as creditAprobTotal from creditCiclo group by alumno;

-- mostar el total de creditos aprobados de cada alumno dela tabla de matricula
Select alumno, creditos from matricula;

-- Alumno, ciclo de ingreso, ciclo actual y cálculo del semestre actual
CREATE VIEW vSemestreActualAlumnoCiclos AS
SELECT vAlumNoEgr.*, (A.cicloSuma - B.cicloSuma) + 1 AS semestreActual FROM vAlumnosNoEgresados vAlumNoEgr 
    join vSumCicloIngresoB B ON B.alumno = vAlumNoEgr.alumno 
    join vSumCicloActualA A on A.alumno = vAlumNoEgr.alumno;

-- Alumno, ciclo de ingreso, ciclo actual, semestre actual, creditos y promedio actual
CREATE VIEW vInfoAlumnoGeneral AS
SELECT vSemAcAlCi.*, matri.creditos, vProm.promedioFinal from vSemestreActualAlumnoCiclos vSemAcAlCi 
    join matricula matri on matri.alumno = vSemAcAlCi.alumno 
    JOIN vPromedioFinal vProm on vProm.Alumno = vSemAcAlCi.alumno; 


-- Alumno, ciclo de ingreso, ciclo de egreso, creditos, promedio final
CREATE VIEW vInfoAlumnoGeneralEgresado AS
SELECT matri.alumno, matri.ciclo, matri.cicloegr, matri.creditos, vProm.promedioFinal from matricula matri 
    join vPromedioFinal vProm on matri.ALUMNO = vProm.Alumno; 


-- CONSULTAS AUXILIARES --------------------

--Revisar cantidad total de ciclos diferentes.
select count(DISTINCT(CICLO)) from calif;

--Revisar cantidad de registros diferentes por ciclo, ordenando por ciclo.
select CICLO AS Ciclo, count(*) AS Registros from calif GROUP BY CICLO ORDER BY CICLO;

--Revisar cantidad de registros diferentes por ciclo, ordenando de menor a mayor cantidad de registros.
select CICLO AS Ciclo, count(*) AS Registros from calif GROUP BY CICLO ORDER BY Registros;

-- Podría ayudar para ver cual es la demanda de cada materia 
-- Revisar cantidad de alumnos diferentes por ciclo, ordenando de menor a mayor cantidad de alumnos.
SELECT CICLO AS Ciclo, count(DISTINCT(ALUMNO)) AS Alumnos FROM calif GROUP BY CICLO ORDER BY Alumnos;

-- Antes erea pruebaAlumno pero la cambié por  calif
--Mostrar todos los alumnos que tienen registro de calificaciones para cada uno de los ciclos.
SELECT CICLO, ALUMNO FROM calif GROUP BY CICLO, ALUMNO ORDER BY CICLO;

-- Está aquí por que probablemente está mal
-- Alumno, ciclo, promedio, creditos
CREATE VIEW vAlumnoCicloPromCredit AS 
-- tomamos alumno y ciclo de p y si en promedio o créditos no hay datos, va a ser 0
SELECT  p.Alumno AS Alumno,  p.Ciclo AS Ciclo, 
    IFNULL(p.Promedio, 0) AS Promedio, 
    IFNULL(c.Creditos, 0) AS Creditos
FROM promedioCiclo p
LEFT JOIN  creditCiclo c ON p.Alumno = c.Alumno AND p.Ciclo = c.Ciclo

UNION
-- y lo mismo para los créditos
SELECT c.Alumno AS Alumno, c.Ciclo AS Ciclo, 
    IFNULL(p.Promedio, 0) AS Promedio, 
    IFNULL(c.Creditos, 0) AS Creditos
FROM  
    creditCiclo c
LEFT JOIN 
    promedioCiclo p ON c.Alumno = p.Alumno AND c.Ciclo = p.Ciclo;

-- mostrar los alumnos sin creditos en cada ciclo pero sólo los que no sean del plestud 403
SELECT a.* FROM alumnoCicloPromCredit a JOIN matricula m ON a.alumno = m.alumno 
WHERE a.creditos = 0 AND a.promedio != 0 AND m.plestud != 403;

-- mostrar los registros que no coinciden con la fecha de registro y el     ciclo
SELECT alumno, ciclo, fecha FROM calif WHERE STR_TO_DATE(fecha, '%d/%m/%Y') NOT BETWEEN 
      STR_TO_DATE(CONCAT('01/01/20', LEFT(ciclo, 2)), '%d/%m/%Y') 
      AND 
      STR_TO_DATE(CONCAT('31/12/20', SUBSTRING(ciclo, 4, 2)), '%d/%m/%Y');

-- último ciclo registrado, se tomará como ciclo actual
CREATE VIEW vCicloActual AS 
 SELECT distinct(ciclo) from calif order by ciclo desc limit 1;

-- Alumnos que tienen fecha de egreso
SELECT ALUMNO FROM matricula WHERE NOT CICLOEGR = '';




-- Alumnos con cicloActual y que no son egresados
CREATE VIEW vAlumnosNoEgresados AS
SELECT matri.alumno, matri.ciclo, vCiclo.ciclo As cicloActual from matricula matri 
    join vCicloActual vCiclo where CICLOEGR = ''; 

-- Suma de ciclo de ingreso  W + X = B
CREATE VIEW vSumCicloIngresoB AS
SELECT vAlumNoEgr.alumno,(CAST(SUBSTRING_INDEX(ciclo, '/', 1) AS UNSIGNED) + CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ciclo, '/', -1), ' ', 1) AS UNSIGNED)) AS cicloSuma
FROM vAlumnosNoEgresados vAlumNoEgr;

-- Suma de ciclo actual  Y + Z = A
CREATE VIEW vSumCicloActualA AS
SELECT vAlumNoEgr.alumno, (CAST(SUBSTRING_INDEX(cicloActual, '/', 1) AS UNSIGNED) + CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(cicloActual, '/', -1), ' ', 1) AS UNSIGNED)) AS cicloSuma
FROM vAlumnosNoEgresados vAlumNoEgr;
















 





