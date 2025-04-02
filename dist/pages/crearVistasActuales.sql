-- Alumnos con cicloActual y que no son egresados
CREATE VIEW vAlumnosNoEgresados AS
SELECT matri.alumno, matri.ciclo, vCiclo.ciclo As cicloActual from matricula matri 
    join vCicloActual vCiclo where CICLOEGR = ''; 

--Calificaciones finales por ciclo para cada alumno en cada materia--
CREATE VIEW vCalifFinalCicloMateria AS SELECT * FROM calif
WHERE (MATERIA, REGIS) IN (SELECT MATERIA, MAX(REGIS) FROM calif GROUP BY MATERIA, ALUMNO, CICLO);

-- último ciclo registrado, se tomará como ciclo actual
CREATE VIEW vCicloActual AS 
 SELECT distinct(ciclo) from calif order by ciclo desc limit 1;

 -- Alumno, ciclo de ingreso, ciclo actual, semestre actual, creditos y promedio actual
CREATE VIEW vInfoAlumnoGeneral AS
SELECT vSemAcAlCi.*, matri.creditos, vProm.promedioFinal from vSemestreActualAlumnoCiclos vSemAcAlCi 
    join matricula matri on matri.alumno = vSemAcAlCi.alumno 
    JOIN vPromedioFinal vProm on vProm.Alumno = vSemAcAlCi.alumno; 

-- Alumno, ciclo de ingreso, ciclo de egreso, creditos, promedio final
CREATE VIEW vInfoAlumnoGeneralEgresado AS
SELECT matri.alumno, matri.ciclo, matri.cicloegr, matri.creditos, vProm.promedioFinal from matricula matri 
    join vPromedioFinal vProm on matri.ALUMNO = vProm.Alumno; 

--Promedios de cada ciclo para cada alumno
CREATE VIEW vPromedioCiclo AS SELECT ALUMNO AS Alumno, CICLO AS Ciclo, 
( SUM(CALIF) / COUNT(*) ) AS Promedio FROM vCalifFinalCicloMateria GROUP BY ALUMNO, CICLO;

-- Promedio final de cada alumno
CREATE VIEW vPromedioFinal AS
SELECT Alumno, ROUND(AVG(Promedio), 2) AS promedioFinal
FROM vPromedioCiclo GROUP BY Alumno;

-- Alumno, ciclo de ingreso, ciclo actual y cálculo del semestre actual
CREATE VIEW vSemestreActualAlumnoCiclos AS
SELECT vAlumNoEgr.*, (A.cicloSuma - B.cicloSuma) + 1 AS semestreActual FROM vAlumnosNoEgresados vAlumNoEgr 
    join vSumCicloIngresoB B ON B.alumno = vAlumNoEgr.alumno 
    join vSumCicloActualA A on A.alumno = vAlumNoEgr.alumno;

-- Suma de ciclo actual  Y + Z = A
CREATE VIEW vSumCicloActualA AS
SELECT vAlumNoEgr.alumno, (CAST(SUBSTRING_INDEX(cicloActual, '/', 1) AS UNSIGNED) + CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(cicloActual, '/', -1), ' ', 1) AS UNSIGNED)) AS cicloSuma
FROM vAlumnosNoEgresados vAlumNoEgr;    


-- Suma de ciclo de ingreso  W + X = B
CREATE VIEW vSumCicloIngresoB AS
SELECT vAlumNoEgr.alumno,(CAST(SUBSTRING_INDEX(ciclo, '/', 1) AS UNSIGNED) + CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ciclo, '/', -1), ' ', 1) AS UNSIGNED)) AS cicloSuma
FROM vAlumnosNoEgresados vAlumNoEgr;




