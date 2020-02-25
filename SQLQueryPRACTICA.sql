--CREATE DATABASE ALUMNOCURSA

CREATE TABLE ALUMNO (
	matricula int primary key,
	nombre varchar(30)
)

CREATE TABLE CARRERA (
	id int primary key,
	nombre varchar(30)
)

CREATE TABLE CURSA (
	alumnoMatricula int foreign key references ALUMNO(matricula),
	carreraId int foreign key references CARRERA(id),
	CONSTRAINT PK_Cursa PRIMARY KEY (alumnoMatricula,carreraId)
)

--todos los alumnos
SELECT * FROM ALUMNO

--todas las carreras 
SELECT * FROM CARRERA 

--todos los alumnos cursando una carrera
SELECT * FROM CURSA

--que alumno cursa que carrera 
SELECT ALUMNO.nombre, CARRERA.nombre
FROM ALUMNO JOIN CURSA ON matricula = alumnoMatricula JOIN CARRERA ON id = carreraId

--insert en tabla de alumnos
INSERT INTO ALUMNO VALUES (1000,'Alejo')
INSERT INTO ALUMNO VALUES (2000,'Alejandra')
INSERT INTO ALUMNO VALUES (3000,'Martin')
INSERT INTO ALUMNO VALUES (4000,'Pablo')
INSERT INTO ALUMNO VALUES (5000,'Federica')
INSERT INTO ALUMNO VALUES (6000,'Amalia')
INSERT INTO ALUMNO VALUES (7000,'Brian')

--insert en tabla de carrera
INSERT INTO CARRERA VALUES (1,'INGENIERIA')
INSERT INTO CARRERA VALUES (2,'ABOGACIA')
INSERT INTO CARRERA VALUES (3,'MEDICINA')
INSERT INTO CARRERA VALUES (4,'ECONOMIA')
INSERT INTO CARRERA VALUES (0,'PENDIENTE')

--insert en tabla de cursa
INSERT INTO CURSA VALUES (1000,1)
INSERT INTO CURSA VALUES (2000,2)
INSERT INTO CURSA VALUES (3000,3)
INSERT INTO CURSA VALUES (4000,4)
INSERT INTO CURSA VALUES (5000,1)
INSERT INTO CURSA VALUES (6000,2)
INSERT INTO CURSA VALUES (7000,1)

--funcion que devuelve la cantidad de alumnos que cursan una carrera. recibe el nombre de la carrera
CREATE FUNCTION cuenta_alumnos (@nombre_carrera varchar(30))
RETURNS int
AS 
BEGIN
	declare @cantAlumnos int 
	SET @cantAlumnos = (SELECT COUNT(ALUMNO.nombre)
						FROM ALUMNO JOIN CURSA ON matricula = alumnoMatricula JOIN CARRERA ON id = carreraId
						WHERE CARRERA.nombre = @nombre_carrera) 
	RETURN @cantAlumnos
END

--ejecucion de la funcion
SELECT dbo.cuenta_alumnos('ingenieria') AS CANTIDAD_ALUMNOS
SELECT dbo.cuenta_alumnos('economia') AS CANTIDAD_ALUMNOS
SELECT dbo.cuenta_alumnos('medicina') AS CANTIDAD_ALUMNOS
SELECT dbo.cuenta_alumnos('abogacia') AS CANTIDAD_ALUMNOS
SELECT dbo.cuenta_alumnos('pendiente') AS CANTIDAD_ALUMNOS

--stored procedure que devuelve el nombre del alumno y la carrera que cursa ese alumno. recibe la matricula
CREATE PROC nombre_alumno_cursando_carrera (@matriculaAlum int) AS
BEGIN
	SELECT ALUMNO.nombre, CARRERA.nombre
	FROM ALUMNO JOIN CURSA ON matricula = alumnoMatricula JOIN CARRERA ON id = carreraId
	WHERE matricula = @matriculaAlum
END

--ejecucion del procedure
EXEC nombre_alumno_cursando_carrera 1000
EXEC nombre_alumno_cursando_carrera 2000
EXEC nombre_alumno_cursando_carrera 3000
EXEC nombre_alumno_cursando_carrera 4000
EXEC nombre_alumno_cursando_carrera 5000
EXEC nombre_alumno_cursando_carrera 6000
EXEC nombre_alumno_cursando_carrera 7000
EXEC nombre_alumno_cursando_carrera 8000
EXEC nombre_alumno_cursando_carrera 9000

--inserto un nuevo alumno y lo hago cursar dos carreras
INSERT INTO ALUMNO VALUES (8000,'Miguel')

INSERT INTO CURSA VALUES (8000,3)
INSERT INTO CURSA VALUES (8000,4)

--creo un trigger para que, al eliminar un alumno, se elimine tambien 
CREATE TRIGGER elimina_cursa ON ALUMNO INSTEAD OF DELETE AS
BEGIN
	DELETE
	FROM CURSA 
	WHERE alumnoMatricula in ( 
								select matricula 
								from deleted	
							 )

	DELETE
	FROM ALUMNO
	WHERE matricula in ( 
								select matricula 
								from deleted	
							 )
END

--elimino un alumno para probar el trigger
DELETE 
FROM ALUMNO
WHERE matricula = 8000

--creo un trigger para insertar una tupla en cursa cuando inserto un alumno
CREATE TRIGGER insertar_cursa ON ALUMNO FOR INSERT AS
BEGIN
	declare @matriculaIn int 
	SET @matriculaIn = (SELECT matricula FROM inserted)
	INSERT INTO CURSA VALUES (@matriculaIn,0)
END

--inserto un alumno para probar el trigger
INSERT INTO ALUMNO VALUES (9000,'Mario')

--stored procedure para saber que alumno cursa cual carrera
CREATE PROC alumno_cursa_carrera AS
BEGIN
	SELECT ALUMNO.nombre, CARRERA.nombre
	FROM ALUMNO JOIN CURSA ON matricula = alumnoMatricula JOIN CARRERA ON id = carreraId
END

--ejecucion del procedure
EXEC alumno_cursa_carrera

--creo una nueva tabla
CREATE TABLE MATERIA(
	codigo_materia int,
	nombre_materia varchar(30),
	matricula_Alumno int FOREIGN KEY REFERENCES ALUMNO(matricula),
	id_Carrera int FOREIGN KEY REFERENCES CARRERA(id),
	nota int,
	CONSTRAINT PK_MA PRIMARY KEY (codigo_materia,matricula_Alumno,id_Carrera)
)

--selecciono todo lo de materia aprobada
SELECT * FROM MATERIA

--inserto materias aprobadas para alumnos
INSERT INTO MATERIA VALUES (1023,'Analisis Matematico 1',1000,1,7)
INSERT INTO MATERIA VALUES (1024,'Elementos de Programacion',1000,1,9)
INSERT INTO MATERIA VALUES (1025,'Sistemas de representacion',1000,1,8)
INSERT INTO MATERIA VALUES (1026,'Tecno Ingen y Sociedad',1000,1,10)
INSERT INTO MATERIA VALUES (1027,'Algebra y Geometria 1',1000,1,8)
INSERT INTO MATERIA VALUES (1028,'Matematica Discreta',1000,1,7)
INSERT INTO MATERIA VALUES (1029,'Quimica General',1000,1,8)
INSERT INTO MATERIA VALUES (1030,'Fundamentos de TICs',1000,1,9)
INSERT INTO MATERIA VALUES (1028,'Matematica Discreta',5000,1,8)
INSERT INTO MATERIA VALUES (1029,'Quimica General',5000,1,9)
INSERT INTO MATERIA VALUES (1024,'Elementos de Programacion',5000,1,10)
INSERT INTO MATERIA VALUES (1025,'Sistemas de representacion',5000,1,10)
INSERT INTO MATERIA VALUES (1026,'Tecno Ingen y Sociedad',5000,1,10)

--stored procedure para ver el nombre del alumno, la carrera que cursa y las materias aprobadas con sus notas
CREATE PROC materias_alumno (@matriculaAlumn int) AS
BEGIN
	SELECT ALUMNO.nombre, CARRERA.nombre, MATERIA.nombre_materia, MATERIA.nota
	FROM MATERIA JOIN ALUMNO ON matricula = matricula_Alumno JOIN CARRERA ON id = id_Carrera
	WHERE matricula_Alumno = @matriculaAlumn
END

--ejecucion del procedure
EXEC materias_alumno 1000
EXEC materias_alumno 5000

--funcion para conocer la cantidad de materias aprobadas de un alumno. recibe el numero de matricula
CREATE FUNCTION cant_materias_aprobadas_alumno (@matriculaAlumno int)
RETURNS INT AS
BEGIN
	declare @cantidad int
	SET @cantidad = (
						SELECT COUNT(codigo_materia)
						FROM MATERIA
						WHERE matricula_Alumno = @matriculaAlumno	
					)
	RETURN @cantidad
END

--ejecucion de la funcion
SELECT dbo.cant_materias_aprobadas_alumno(1000) as CANTIDAD
SELECT dbo.cant_materias_aprobadas_alumno(5000) as CANTIDAD

--funcion para conocer las materias aprobadas por un alumno, recibe la matricula del alumno
CREATE FUNCTION materias_aprobadas (@matriculaAlumno int)
RETURNS @materias TABLE (
	codigo int,
	nombre varchar(30),
	nota int) AS
BEGIN
	INSERT @materias
	SELECT codigo_materia, nombre_materia, nota
	FROM MATERIA
	WHERE matricula_Alumno=@matriculaAlumno
	
	RETURN
END

-- ejecucion de la funcion
SELECT * 
FROM materias_aprobadas(1000)

SELECT * 
FROM materias_aprobadas(5000)

--creo una tabla llamada profesor
CREATE TABLE PROFESOR (
	legajo int,
	nombre varchar(30),
	CONSTRAINT PK_PROF PRIMARY KEY (legajo)
)

--creo una funcion para contar la cantidad de profesores
CREATE FUNCTION cuenta_profesores (@legajo int)
RETURNS INT 
AS 
BEGIN 
	declare @cantidad int
	SET @cantidad= (SELECT COUNT(legajo) as CANT
					FROM PROFESOR)
	RETURN @cantidad
END

--ejecucion de la funcion
SELECT dbo.cuenta_profesores(1) as CANTIDAD_PROFESORES

--creo un stored procedure para insertar valores en profesores, pasando solo el nombre
CREATE PROC insertar_profesor (@nombre varchar(30)) AS
BEGIN
	declare @cantidad int
	SET @cantidad = (SELECT dbo.cuenta_profesores(0)) + 1
	INSERT INTO PROFESOR VALUES (@cantidad,@nombre)
END

--ejecucion del procedure 
EXEC insertar_profesor 'Fernandez Martin'
EXEC insertar_profesor 'Laprida Maria'

--otro procedure para que me devuelva los profesores
CREATE PROC dame_profesores AS
BEGIN
	SELECT * FROM PROFESOR
END

--ejecucion del procedure
EXEC dame_profesores