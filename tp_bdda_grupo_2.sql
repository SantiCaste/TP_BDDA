/*ENUNCIADO
Luego de decidirse por un motor de base de datos relacional (le recomendamos SQL Server para
aplicar lo que se verá en la unidad 3, pero pueden escoger otro siempre que sea relacional si lo
desean), llegó el momento de generar la base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle las
configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos, etc.)
en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar un
archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”. Genere esquemas para
organizar de forma lógica los componentes del sistema y aplique esto en la creación de objetos.
NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha de
entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Se presenta un modelo de base de datos a implementar por el hospital Cure SA, para la reserva
de turnos médicos y la visualización de estudios clínicos realizados (ver archivo Clinica Cure
SA.png).
Para facilitar la lectura del diagrama se informa la identificación de la cardinalidad en las
relaciones
Aclaraciones:
El modelo es el esquema inicial, en caso de ser necesario agregue las relaciones/entidades que
sean convenientes.
Los turnos para estudios clínicos no se encuentran dentro del alcance del desarrollo del
sistema actual.
Los estudios clínicos son ingresados al sistema por el técnico encargado de realizar el estudio,
una vez finalizado el estudio (en el caso de las imágenes) y en el caso de los laboratorios cuando
el mismo se encuentre terminado.
Los turnos para atención médica tienen como estado inicial disponible, según el médico, la
especialidad y la sede.
Los prestadores están conformador por Obras Sociales y Prepagas con las cuales se establece
una alianza comercial. Dicha alianza puede finalizar en cualquier momento, por lo cual debe
poder ser actualizable de forma inmediata si el contrato no está vigente. En caso de no estar
vigente el contrato, deben ser anulados todos los turnos de pacientes que se encuentren
vinculados a esa prestadora y pasar a estado disponible.
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o
solo un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía
el código del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está
autorizado o no y el importe a facturarle al paciente.
Los roles establecidos al inicio del proyecto son:
• Paciente
• Medico
• Personal Administrativo
• Personal Técnico clínico
• Administrador General
El usuario web se define utilizando el DNI.
*/

/*
FECHA DE ENTREGA: 10/10/2023
NÚMERO DE GRUPO: 2
NOMBRE DE LA MATERIA: BASES DE DATOS APLICADAS
NOMBRE Y DNI DE PARTICIPANTES:
	CASTELLANI SANTIAGO, 43.316.372
	COLANTONIO BRUNO, 43.863.195
	COULLERI FLAVIO, 44.183.677
	KOWALSKI FRANCO, 41.893.248
	
/*VARIABLE DE RUTA DE LOS ARCHIVOS:*/
DECLARE @path_medicos varchar(max) = 'C:\datasets\Medicos.csv'
DECLARE @path_pacientes varchar(max) = 'C:\datasets\Pacientes.csv'
DECLARE @path_prestadores varchar(max) = 'C:\datasets\Prestador.csv'
DECLARE @path_sedes varchar(max) = 'C:\datasets\Sedes.csv'
DECLARE @path_autorizados varchar(max) = 'C:\datasets\Dataset\Centro_Autorizaciones.Estudios clinicos.json'


--DROP DATABASE TP_GRUPO_2_ENTREGABLE

/*CREACION DE LA BASE DE DATOS:*/
CREATE DATABASE TP_GRUPO_2_ENTREGABLE--TP_GRUPO_2
GO
 
USE TP_GRUPO_2_ENTREGABLE
GO

/*CREACION DE ESQUEMAS*/
CREATE SCHEMA funciones
GO
CREATE SCHEMA datos_usuario 
GO
CREATE SCHEMA datos_turno
GO
CREATE SCHEMA datos_sede
GO

SET DATEFORMAT dmy
GO


/*CREACIÓN DE TABLAS*/


--CREACION DE TABLAS:

--DOMICILIO:
CREATE TABLE datos_usuario.Domicilio(
id int IDENTITY (1,1),
calle nvarchar(50),
numero int,
piso int,
departamento int,
cod_postal int,
pais nvarchar(50),
provincia nvarchar(50),
localidad nvarchar(50),
CONSTRAINT PK_Domicilio PRIMARY KEY(id)
)
GO

--PACIENTE:
CREATE TABLE datos_usuario.Paciente (
ID_HIST_CLINICA INT IDENTITY(1,1),
nombre NVARCHAR(50),
apellido nvarchar(50),
ape_materno nvarchar(50),
fecha_nacim date,
tipo_doc char(5),
num_doc int,
id_domicilio int,
sexo varchar(9),
genero varchar(10),
nacionalidad nvarchar(30),
foto_perfil varchar(max),
mail nvarchar(100),
tel_fijo varchar(15),
tel_contacto varchar(15),
tel_laboral varchar(15),
fecha_registro date,
fecha_actualizacion datetime,
usuario_actualizacion varchar(50),

CONSTRAINT PK_Paciente PRIMARY KEY (ID_HIST_CLINICA),
CONSTRAINT FK_Domicilio FOREIGN KEY (id_domicilio) REFERENCES  datos_usuario.Domicilio (id)
)
GO

--Usuario:
CREATE TABLE datos_usuario.Usuario (
id nvarchar(30),
contrasena nvarchar(30),
fecha_creacion datetime,
id_hist_clinica int UNIQUE, --para que no haya una historia clinica con 2 usuarios.
CONSTRAINT PK_Usuario PRIMARY KEY (id, contrasena),
CONSTRAINT FK_Usuario_HC FOREIGN KEY (id_hist_clinica) REFERENCES datos_usuario.Paciente(id_hist_clinica)
)
GO

CREATE TABLE datos_usuario.Estudio(
id_estudio int,
id_hist_clinica int,
fecha date,
nombre nvarchar(80),
autorizado char,
documento_resu varchar(max),
imagen_resu varchar(max),
CONSTRAINT PK_Estudio PRIMARY KEY (id_estudio),
CONSTRAINT FK_Estudio_HC FOREIGN KEY (id_hist_clinica) REFERENCES datos_usuario.Paciente(id_hist_clinica),
CONSTRAINT CK_autorizado CHECK (autorizado IN ('S', 'N'))
)
GO

CREATE TABLE datos_usuario.Prestador(
id_prestador int IDENTITY(1,1),
nombre nvarchar(50),
plan_prestador nvarchar(50),
CONSTRAINT PK_Prestador PRIMARY KEY(id_prestador),
)
GO

CREATE TABLE datos_usuario.Cobertura(
id_cobertura int,
id_hist_clinica int,
imagen_credencial varchar(max), 
nro_socio int,
fecha_registro date,
id_prestador int,
CONSTRAINT PK_Cobertura PRIMARY KEY(id_cobertura,id_prestador),
CONSTRAINT FK_Cobertura_HC FOREIGN KEY (id_hist_clinica) REFERENCES datos_usuario.Paciente(id_hist_clinica),
CONSTRAINT FK_Cobertura_Prestador FOREIGN KEY (id_prestador) REFERENCES datos_usuario.Prestador(id_prestador)
)
GO

CREATE TABLE datos_turno.Estado_Turno(
id int,
nombre varchar(9),
CONSTRAINT PK_Estado_Turno PRIMARY KEY(id),
CONSTRAINT CK_Estado_Turno CHECK (nombre IN('Atendido', 'Ausente', 'Cancelado'))
)
GO

CREATE TABLE datos_turno.Tipo_Turno(
id int,
nombre varchar(10),
CONSTRAINT PK_Tipo_Turno PRIMARY KEY(id),
CONSTRAINT CK_Tipo_Turno CHECK (nombre IN('Presencial', 'Virtual'))
)
GO

CREATE TABLE datos_turno.Reserva(
id_turno int,
fecha date,
hora time,
id_medico int,
id_especialidad int,
id_direccion int,
id_estado_turno int,
id_tipo_turno int,
id_hist_clinica int,
CONSTRAINT PK_Reserva PRIMARY KEY(id_turno),
CONSTRAINT FK_Reserva_Estado FOREIGN KEY(id_estado_turno) REFERENCES datos_turno.Estado_Turno(id),
CONSTRAINT FK_Reserva_Tipo FOREIGN KEY(id_tipo_turno) REFERENCES datos_turno.Tipo_Turno(id),
CONSTRAINT FK_Reserva_PAC FOREIGN KEY(id_hist_clinica) REFERENCES datos_usuario.Paciente(id_hist_clinica)
)
GO

CREATE TABLE datos_sede.Especialidad(
id int IDENTITY(1,1),
nombre varchar(50),
CONSTRAINT PK_Especialidad PRIMARY KEY(id)
)
GO

CREATE TABLE datos_sede.Medico(
id int IDENTITY (1,1),
nombre nvarchar(50),
apellido nvarchar(50),
nro_mat int,
id_especialidad int,
CONSTRAINT PK_Medico PRIMARY KEY(id),
CONSTRAINT FK_Medico_ESP FOREIGN KEY(id_especialidad) REFERENCES datos_sede.Especialidad(id)
)
GO

CREATE TABLE datos_sede.Sede(
id int IDENTITY(1,1),
nombre nvarchar(50),
direccion nvarchar(50),
localidad nvarchar(50),
CONSTRAINT PK_Sede PRIMARY KEY(id)
)
GO

CREATE TABLE datos_sede.Dias_por_sede(
id_sede int,
id_medico int,
dia varchar(10),
hora_inicio time,
id_turno int,
CONSTRAINT PK_Dias_por_sede PRIMARY KEY(id_sede, id_medico),
CONSTRAINT FK_Dias_por_sede_RES FOREIGN KEY(id_turno) REFERENCES datos_turno.Reserva(id_turno),
CONSTRAINT FK_Dias_por_sede_MED FOREIGN KEY(id_medico) REFERENCES datos_sede.Medico(id),
CONSTRAINT FK_Dias_por_sede_SED FOREIGN KEY(id_sede) REFERENCES datos_sede.Sede(id)
)
GO

--STORED PROCEDURES PARA CREACIÓN, MODIFICACIÓN Y BORRADO:
CREATE OR ALTER PROC datos_usuario.INSERTAR_PACIENTE --fecha_registro y actualizacion se obtienen con getdate() y actualización usuario se mantiene en null hasta no haber usuario
(
    @nombre NVARCHAR(50) = NULL,
    @apellido NVARCHAR(50)= NULL,
    @ape_materno NVARCHAR(50) = NULL,
    @fecha_nacim DATE = NULL,
    @tipo_doc CHAR(5) = NULL,
    @num_doc INT = NULL,
    @sexo VARCHAR(9) = NULL,
	@id_domicilio INT,
    @genero VARCHAR(10) = NULL,
    @nacionalidad NVARCHAR(30) = NULL,
    @foto_perfil VARCHAR(MAX) = NULL,
    @mail NVARCHAR(100) = NULL,
    @tel_fijo VARCHAR(15) = NULL,
    @tel_contacto VARCHAR(15) = NULL,
    @tel_laboral VARCHAR(15) = NULL

    /*@fecha_registro DATE,
    @fecha_actualizacion DATETIME,				
    @usuario_actualizacion VARCHAR(50)*/	
)
AS
BEGIN
    INSERT INTO datos_usuario.Paciente
    (
        nombre,
        apellido,
        ape_materno,
        fecha_nacim,
        tipo_doc,
        num_doc,
		id_domicilio,
        sexo,
        genero,
        nacionalidad,
        foto_perfil,
        mail,
        tel_fijo,
        tel_contacto,
        tel_laboral,
        fecha_registro,
		fecha_actualizacion
    )
    VALUES
    (
        @nombre,
        @apellido,
        @ape_materno,
        @fecha_nacim,
        @tipo_doc,
        @num_doc,
		@id_domicilio,
        @sexo,
        @genero,
        @nacionalidad,
        @foto_perfil,
        @mail,
        @tel_fijo,
        @tel_contacto,
        @tel_laboral,
        GETDATE(),
        GETDATE()
    )
END;
GO

--LISTO, SIN PROBAR
CREATE OR ALTER PROC datos_usuario.MODIFICAR_PACIENTE 
(
	@ID_HIST_CLINICA_pk INT,
    @nombre_arg NVARCHAR(50) = NULL,
    @apellido_arg NVARCHAR(50) = NULL,
    @ape_materno_arg NVARCHAR(50) = NULL,
    @fecha_nacim_arg DATE = NULL,
    @tipo_doc_arg CHAR(5) = NULL,
    @num_doc_arg INT = NULL,
	@id_domicilio_arg INT = NULL,
    @sexo_arg VARCHAR(9) = NULL,
    @genero_arg VARCHAR(10) = NULL,
    @nacionalidad_arg NVARCHAR(30) = NULL,
    @foto_perfil_arg VARCHAR(MAX) = NULL,
    @mail_arg NVARCHAR(100) = NULL,
    @tel_fijo_arg VARCHAR(15) = NULL,
    @tel_contacto_arg VARCHAR(15) = NULL,
    @tel_laboral_arg VARCHAR(15) = NULL
)
AS
BEGIN
	DECLARE	 @nombre NVARCHAR(50),
			 @apellido NVARCHAR(50),
			 @ape_materno NVARCHAR(50),
			 @fecha_nacim DATE,
			 @tipo_doc CHAR(5),
			 @num_doc INT,
			 @id_domicilio INT,
			 @sexo VARCHAR(9),
			 @genero VARCHAR(10),
			 @nacionalidad NVARCHAR(30),
			 @foto_perfil VARCHAR(MAX),
			 @mail NVARCHAR(100),
			 @tel_fijo VARCHAR(15),
			 @tel_contacto VARCHAR(15),
			 @tel_laboral VARCHAR(15)

	SELECT	@nombre = nombre,
			@apellido = apellido,
			@ape_materno = ape_materno,
			@fecha_nacim = fecha_nacim,
			@tipo_doc = tipo_doc,
			@num_doc = num_doc,
			@id_domicilio = id_domicilio,
			@sexo = sexo,
			@genero = genero,
			@nacionalidad = nacionalidad,
			@foto_perfil = foto_perfil,
			@mail = mail,
			@tel_fijo = tel_fijo,
			@tel_contacto = tel_contacto,
			@tel_laboral = tel_laboral

	FROM datos_usuario.Paciente
	WHERE ID_HIST_CLINICA = @ID_HIST_CLINICA_pk

	UPDATE datos_usuario.Paciente
	SET	nombre = ISNULL(@nombre_arg,@nombre),
		apellido = ISNULL(@apellido_arg,@apellido),
		ape_materno = ISNULL(@ape_materno_arg,@ape_materno),
		fecha_nacim = ISNULL(@fecha_nacim_arg,@fecha_nacim),
		tipo_doc = ISNULL(@tipo_doc_arg,@tipo_doc),
		num_doc = ISNULL(@num_doc_arg,@num_doc),
		id_domicilio = ISNULL(@id_domicilio_arg, @id_domicilio),
		sexo = ISNULL(@sexo_arg,@sexo),
		genero = ISNULL(@genero_arg,@genero),
		nacionalidad = ISNULL(@nacionalidad_arg,@nacionalidad),
		foto_perfil = ISNULL(@foto_perfil_arg,@foto_perfil),
		mail = ISNULL(@mail_arg,@mail),
		tel_fijo = ISNULL(@tel_fijo_arg,@tel_fijo),
		tel_contacto = ISNULL(@tel_contacto_arg,@tel_contacto),
		tel_laboral = ISNULL(@tel_laboral_arg,@tel_laboral),
		fecha_actualizacion = GETDATE()

	WHERE ID_HIST_CLINICA = @ID_HIST_CLINICA_pk
END;
GO

--LISTO
CREATE OR ALTER PROC datos_usuario.ELIMINAR_PACIENTE 
(@ID_HIST_CLINICA_pk INT)
AS
BEGIN
	DELETE FROM datos_usuario.Paciente 
	WHERE ID_HIST_CLINICA = @ID_HIST_CLINICA_pk
END;
GO

--LISTO
CREATE OR ALTER PROC datos_usuario.INSERTAR_USUARIO
(
	@id nvarchar(30),
	@contrasena nvarchar(30),
	@id_hist_clinica int
)
AS
BEGIN
	INSERT INTO datos_usuario.Usuario
	(
		id,
		contrasena,
		fecha_creacion,
		id_hist_clinica
	)
	VALUES
	(
		@id,
		@contrasena,
		GETDATE(),
		@id_hist_clinica
	)
	-- actualizo campo de actualización del usuario dentro de la tabla Paciente
	UPDATE datos_usuario.Paciente
	SET usuario_actualizacion = GETDATE()
	WHERE ID_HIST_CLINICA = @id_hist_clinica
END;
GO

--LISTO
CREATE OR ALTER PROC datos_usuario.MODIFICAR_USUARIO
(
	@id_pk nvarchar(30),
	@contrasena_pk nvarchar(30) = NULL,
	@id_arg nvarchar(30) = NULL,
	@contrasena_arg nvarchar(30) = NULL,
	@id_hist_clinica_arg int = NULL
)
AS
BEGIN
	DECLARE @id nvarchar(30),
			@contrasena nvarchar(30),
			@id_hist_clinica int
	
	SELECT  @id = id,
			@contrasena = contrasena,
			@id_hist_clinica = id_hist_clinica
	FROM datos_usuario.Usuario
	WHERE id = @id_pk AND contrasena = @contrasena_pk

	UPDATE datos_usuario.Usuario
	SET id = ISNULL(@id_arg,@id),
		contrasena = ISNULL(@contrasena_arg,@contrasena),
		id_hist_clinica = ISNULL(@id_hist_clinica_arg,@id_hist_clinica)
	WHERE id = @id_pk AND contrasena = @contrasena_pk

	UPDATE datos_usuario.Paciente
	SET usuario_actualizacion = GETDATE()
	WHERE ID_HIST_CLINICA = ISNULL(@id_hist_clinica_arg,@id_hist_clinica)

END;
GO

--LISTO
CREATE OR ALTER PROC datos_usuario.ELIMINAR_USUARIO
(
	@id_pk nvarchar(30),
	@contrasena_pk nvarchar(30)
)
AS
BEGIN
	DELETE FROM datos_usuario.Usuario 
	WHERE id = @id_pk AND contrasena = @contrasena_pk
END;
GO

--LISTO
CREATE OR ALTER PROC datos_usuario.INSERTAR_ESTUDIO
(
	@id_estudio int,
	@id_hist_clinica int,
	@fecha date = NULL,
	@nombre nvarchar(80) = NULL,
	@autorizado char,
	@documento_resu varchar(max) = NULL,
	@imagen_resu varchar(max) = NULL
)
AS
BEGIN
	INSERT INTO datos_usuario.Estudio
	(
		id_estudio,
		id_hist_clinica,
		fecha,
		nombre,
		autorizado,
		documento_resu,
		imagen_resu
	)
	VALUES
	(
		@id_estudio,
		@id_hist_clinica,
		@fecha,
		@nombre,
		@autorizado,
		@documento_resu,
		@imagen_resu
	)
END;
GO

CREATE OR ALTER PROC datos_usuario.MODIFICAR_ESTUDIO
(
	@id_estudio_pk int,
	@id_estudio_arg int = NULL,
	@id_hist_clinica_arg int = NULL,
	@fecha_arg date = NULL,
	@nombre_arg nvarchar(80) = NULL,
	@autorizado_arg char = NULL,
	@documento_resu_arg varchar(max) = NULL,
	@imagen_resu_arg varchar(max) = NULL
)
AS
BEGIN
	DECLARE @id_estudio int,
			@id_hist_clinica int,
			@fecha date,
			@nombre nvarchar(80),
			@autorizado char,
			@documento_resu varchar(max),
			@imagen_resu varchar(max)

	SELECT @id_estudio = id_estudio,
			@id_hist_clinica = id_hist_clinica,
			@fecha = fecha,
			@nombre = nombre,
			@autorizado = autorizado,
			@documento_resu = documento_resu,
			@imagen_resu = imagen_resu

	FROM datos_usuario.Estudio
	WHERE id_estudio = @id_estudio_pk

	UPDATE datos_usuario.Estudio
	SET id_estudio = ISNULL(@id_estudio_arg,@id_estudio),
		id_hist_clinica = ISNULL(@id_hist_clinica_arg,@id_hist_clinica),
		fecha = ISNULL(@fecha_arg,@fecha),
		nombre = ISNULL(@nombre_arg,@nombre),
		autorizado = ISNULL(@autorizado_arg,@autorizado),
		documento_resu = ISNULL(@documento_resu_arg,@documento_resu),
		imagen_resu = ISNULL(@imagen_resu_arg,@imagen_resu)

	WHERE id_estudio = @id_estudio_pk
	
END;
GO

CREATE OR ALTER PROC datos_usuario.ELIMINAR_ESTUDIO
(@id_estudio_pk int)
AS
BEGIN
	DELETE FROM datos_usuario.Estudio
	WHERE id_estudio = @id_estudio_pk
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_usuario.INSERTAR_COBERTURA
(
	@id_cobertura int,
	@id_hist_clinica int,
	@imagen_credencial varchar(max) = NULL,
	@nro_socio int,
	@id_prestador int
)
AS
BEGIN
	INSERT INTO datos_usuario.Cobertura
	(
		id_cobertura,
		id_hist_clinica,
		imagen_credencial,
		nro_socio,
		fecha_registro,
		id_prestador
	)
	VALUES
	(
		@id_cobertura,
		@id_hist_clinica,
		@imagen_credencial,
		@nro_socio,
		GETDATE(),
		@id_prestador
	)
END;
GO

--LISTO PROBAR
CREATE OR ALTER PROC datos_usuario.MODIFICAR_COBERTURA
(
	@id_cobertura_pk int,
	@id_hist_clinica_arg int = NULL,
	@imagen_credencial_arg varchar(max) = NULL,
	@nro_socio_arg int = NULL,
	@id_prestador_arg int = NULL
)
AS
BEGIN
	DECLARE @id_hist_clinica int,
			@imagen_credencial varchar(max),
			@nro_socio int,
			@id_prestador int

	SELECT	@id_hist_clinica = id_hist_clinica,
			@imagen_credencial = imagen_credencial,
			@nro_socio = nro_socio,
			@id_prestador = id_prestador

	FROM datos_usuario.Cobertura
	WHERE id_cobertura = @id_cobertura_pk

	UPDATE datos_usuario.Cobertura
	SET id_hist_clinica = ISNULL(@id_hist_clinica_arg,@id_hist_clinica),
		imagen_credencial = ISNULL(@imagen_credencial_arg,@imagen_credencial),
		nro_socio = ISNULL(@nro_socio_arg,@nro_socio),
		id_prestador = ISNULL(@id_prestador_arg, @id_prestador)

	WHERE id_cobertura = @id_cobertura_pk
	
END;
GO

CREATE OR ALTER PROC datos_usuario.ELIMINAR_COBERTURA
(@id_cobertura_pk int)
AS
BEGIN
	DELETE FROM datos_usuario.Cobertura
	WHERE id_cobertura = @id_cobertura_pk
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_usuario.INSERTAR_PRESTADOR
(
	@nombre int = NULL,
	@plan_prestador varchar(max) = NULL
)
AS
BEGIN
	INSERT INTO datos_usuario.Prestador
	(
		nombre,
		plan_prestador
	)
	VALUES
	(
		@nombre,
		@plan_prestador
	)
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_usuario.MODIFICAR_PRESTADOR
(
	@id_prestador_pk int,
	@nombre_arg int = NULL,
	@plan_prestador_arg varchar(max) = NULL,
	@id_cobertura_arg int = NULL
)
AS
BEGIN
	DECLARE @nombre int,
			@plan_prestador varchar(max),
			@id_cobertura int

	SELECT	@nombre = nombre,
			@plan_prestador = plan_prestador

	FROM datos_usuario.Prestador
	WHERE id_prestador = @id_prestador_pk

	UPDATE datos_usuario.Prestador
	SET nombre = ISNULL(@nombre_arg,@nombre),
		plan_prestador = ISNULL(@plan_prestador_arg,@plan_prestador)
	WHERE id_prestador = @id_prestador_pk
	
END;
GO

CREATE OR ALTER PROC datos_usuario.ELIMINAR_PRESTADOR
(@id_prestador_pk int)
AS
BEGIN
	DELETE FROM datos_usuario.Prestador
	WHERE id_prestador = @id_prestador_pk
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_usuario.INSERTAR_DOMICILIO
(
	@calle nvarchar(50),
	@numero int,
	@piso int = NULL,
	@departamento int = NULL,
	@cod_postal int = NULL,
	@pais nvarchar(50) = NULL,
	@provincia nvarchar(50) = NULL,
	@localidad nvarchar(50) = NULL
)
AS
BEGIN
	INSERT INTO datos_usuario.Domicilio
	(
		calle,
		numero,
		piso,
		departamento,
		cod_postal,
		pais,
		provincia,
		localidad
	)
	VALUES
	(
		@calle,
		@numero,
		@piso,
		@departamento,
		@cod_postal,
		@pais,
		@provincia,
		@localidad
	)
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_usuario.MODIFICAR_DOMICILIO
(
	@id_pk int,
	@calle_arg nvarchar(50) = NULL,
	@numero_arg int = NULL,
	@piso_arg int = NULL,
	@departamento_arg int = NULL,
	@cod_postal_arg int = NULL,
	@pais_arg nvarchar(50) = NULL,
	@provincia_arg nvarchar(50) = NULL,
	@localidad_arg nvarchar(50) = NULL
)
AS
BEGIN
	DECLARE @calle nvarchar(50),
			@numero int,
			@piso int,
			@departamento int,
			@cod_postal int,
			@pais nvarchar(50),
			@provincia nvarchar(50),
			@localidad nvarchar(50)

	SELECT	@calle = calle,
			@numero = numero,
			@piso = piso,
			@departamento = departamento,
			@cod_postal = cod_postal,
			@pais = pais,
			@provincia = provincia,
			@localidad = localidad

	FROM datos_usuario.Domicilio
	WHERE id = @id_pk

	UPDATE datos_usuario.Domicilio
	SET calle = ISNULL(@calle_arg,@calle),
		numero = ISNULL(@numero_arg,@numero),
		piso = ISNULL(@piso_arg,@piso),
		departamento = ISNULL(@departamento_arg,@departamento),
		cod_postal = ISNULL(@cod_postal_arg,@cod_postal),
		pais = ISNULL(@pais_arg,@pais),
		provincia = ISNULL(@provincia_arg,@provincia),
		localidad = ISNULL(@localidad_arg,@localidad)

	WHERE id = @id_pk
	
END;
GO

CREATE OR ALTER PROC datos_usuario.ELIMINAR_DOMICILIO
(@id_pk int)
AS
BEGIN
	DELETE FROM datos_usuario.Domicilio
	WHERE id= @id_pk
END;
GO

CREATE OR ALTER PROC datos_turno.INSERTAR_ESTADO_TURNO
(
	@id int,
	@nombre varchar(9)
)
AS
BEGIN
	INSERT INTO datos_turno.Estado_Turno
	(
		id,
		nombre
	)
	VALUES
	(
		@id,
		@nombre
	)
END;
GO

CREATE OR ALTER PROC datos_turno.MODIFICAR_ESTADO_TURNO
(
	@id_pk int,
	@id_arg int = NULL,
	@nombre_arg varchar(9) = NULL
)
AS
BEGIN
	DECLARE @id int,
			@nombre varchar(9)

	SELECT	@id = id,
			@nombre = nombre

	FROM datos_turno.Estado_Turno
	WHERE id = @id_pk

	UPDATE datos_turno.Estado_Turno
	SET id = ISNULL(@id_arg,@id),
		nombre = ISNULL(@nombre_arg,@nombre)

	WHERE id = @id_pk
END;
GO

CREATE OR ALTER PROC datos_turno.ELIMINAR_ESTADO_TURNO
(@id_pk int)
AS
BEGIN
	DELETE FROM datos_turno.Estado_Turno
	WHERE id = @id_pk
END;
GO

CREATE OR ALTER PROC datos_turno.INSERTAR_TIPO_TURNO
(
	@id int,
	@nombre varchar(9)
)
AS
BEGIN
	INSERT INTO datos_turno.Tipo_Turno
	(
		id,
		nombre
	)
	VALUES
	(
		@id,
		@nombre
	)
END;
GO

CREATE OR ALTER PROC datos_turno.MODIFICAR_TIPO_TURNO
(
	@id_pk int,
	@id_arg int = NULL,
	@nombre_arg varchar(9) = NULL
)
AS
BEGIN
	DECLARE @id int,
			@nombre varchar(9)

	SELECT	@id = id,
			@nombre = nombre

	FROM datos_turno.Tipo_Turno
	WHERE id = @id_pk

	UPDATE datos_turno.Tipo_Turno
	SET id = ISNULL(@id_arg,@id),
		nombre = ISNULL(@nombre_arg,@nombre)

	WHERE id = @id_pk
END;
GO

CREATE OR ALTER PROC datos_turno.ELIMINAR_TIPO_TURNO
(@id_pk int)
AS
BEGIN
	DELETE FROM datos_turno.Tipo_Turno
	WHERE id = @id_pk
END;
GO

CREATE OR ALTER PROC datos_turno.INSERTAR_RESERVA
(
	@id_turno int,
	@fecha date = NULL,
	@hora time = NULL,
	@id_medico int = NULL,
	@id_especialidad int = NULL,
	@id_direccion int = NULL,
	@id_estado_turno int,
	@id_tipo_turno int,
	@id_hist_clinica int
)
AS
BEGIN
	INSERT INTO datos_turno.Reserva
	(
		id_turno,
		fecha,
		hora,
		id_medico,
		id_especialidad,
		id_direccion,
		id_estado_turno,
		id_tipo_turno,
		id_hist_clinica
	)
	VALUES
	(
		@id_turno,
		@fecha,
		@hora,
		@id_medico,
		@id_especialidad,
		@id_direccion,
		@id_estado_turno,
		@id_tipo_turno,
		@id_hist_clinica
	)
END;
GO

CREATE OR ALTER PROC datos_turno.MODIFICAR_RESERVA
(
	@id_turno_pk int,
	@id_turno_arg int = NULL,
	@fecha_arg date = NULL,
	@hora_arg time = NULL,
	@id_medico_arg int = NULL,
	@id_especialidad_arg int = NULL,
	@id_direccion_arg int = NULL,
	@id_estado_turno_arg int = NULL,
	@id_tipo_turno_arg int = NULL,
	@id_hist_clinica_arg int = NULL
)
AS
BEGIN
	DECLARE @id_turno int,
			@fecha date,
			@hora time,
			@id_medico int,
			@id_especialidad int,
			@id_direccion int,
			@id_estado_turno int,
			@id_tipo_turno int,
			@id_hist_clinica int

	SELECT	@id_turno = id_turno,
			@fecha = fecha,
			@hora = hora,
			@id_medico = id_medico,
			@id_especialidad = id_especialidad,
			@id_direccion = id_direccion,
			@id_estado_turno = id_estado_turno,
			@id_tipo_turno = id_tipo_turno,
			@id_hist_clinica = id_hist_clinica

	FROM datos_turno.Reserva
	WHERE id_turno = @id_turno_pk

	UPDATE datos_turno.Reserva
	SET id_turno = ISNULL(@id_turno_arg,@id_turno),
		fecha = ISNULL(@fecha_arg,@fecha),
		hora = ISNULL(@hora_arg,@hora),
		id_medico = ISNULL(@id_medico_arg,@id_medico),
		id_especialidad = ISNULL(@id_especialidad_arg,@id_especialidad),
		id_direccion = ISNULL(@id_direccion_arg,@id_direccion),
		id_estado_turno = ISNULL(@id_estado_turno_arg,@id_estado_turno),
		id_tipo_turno = ISNULL(@id_tipo_turno_arg,@id_tipo_turno),
		id_hist_clinica = ISNULL(@id_hist_clinica_arg,@id_hist_clinica)

	WHERE id_turno = @id_turno_pk
END;
GO

CREATE OR ALTER PROC datos_turno.ELIMINAR_RESERVA
(@id_turno_pk int)
AS
BEGIN
	DELETE FROM datos_turno.Reserva
	WHERE id_turno = @id_turno_pk
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_sede.INSERTAR_ESPECIALIDAD
(
	@nombre varchar(50)
)
AS
BEGIN
	INSERT INTO datos_sede.Especialidad
	(
		nombre
	)
	VALUES
	(
		@nombre
	)
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_sede.MODIFICAR_ESPECIALIDAD
(
	@id_pk int,
	@nombre_arg varchar(50) = NULL
)
AS
BEGIN
	DECLARE @nombre varchar(50)

	SELECT	@nombre = nombre

	FROM datos_sede.Especialidad
	WHERE id = @id_pk

	UPDATE datos_sede.Especialidad
	SET nombre = ISNULL(@nombre_arg,@nombre)

	WHERE id = @id_pk
END;
GO

CREATE OR ALTER PROC datos_sede.ELIMINAR_ESPECIALIDAD
(@id_pk int)
AS
BEGIN
	DELETE FROM datos_sede.Especialidad
	WHERE id = @id_pk
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_sede.INSERTAR_MEDICO
(
	@nombre varchar(50),
	@apellido varchar(50),
	@nro_mat int = NULL,
	@id_especialidad int
)
AS
BEGIN
	INSERT INTO datos_sede.Medico
	(
		nombre,
		apellido,
		nro_mat,
		id_especialidad
	)
	VALUES
	(
		@nombre,
		@apellido,
		@nro_mat,
		@id_especialidad
	)
END;
GO

CREATE OR ALTER PROC datos_sede.MODIFICAR_MEDICO
(
	@id_pk int,
	@nombre_arg varchar(50) = NULL,
	@apellido_arg varchar(50) = NULL,
	@nro_mat_arg int = NULL,
	@id_especialidad_arg int = NULL
)
AS
BEGIN
	DECLARE @nombre varchar(50),
			@apellido varchar(50),
			@nro_mat int,
			@id_especialidad int

	SELECT	@nombre = nombre,
			@apellido = apellido,
			@nro_mat = nro_mat,
			@id_especialidad = id_especialidad

	FROM datos_sede.Medico
	WHERE id = @id_pk

	UPDATE datos_sede.Medico
	SET nombre = ISNULL(@nombre_arg,@nombre),
		apellido = ISNULL(@apellido_arg,@apellido),
		nro_mat = ISNULL(@nro_mat_arg,@nro_mat),
		id_especialidad = ISNULL(@id_especialidad_arg,@id_especialidad)

	WHERE id = @id_pk
END;
GO

CREATE OR ALTER PROC datos_sede.ELIMINAR_MEDICO
(@id_pk int)
AS
BEGIN
	DELETE FROM datos_sede.Medico
	WHERE id = @id_pk
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_sede.INSERTAR_SEDE
(
	@nombre varchar(50),
	@direccion varchar(50) = NULL,
	@localidad varchar(50) = NULL
)
AS
BEGIN
	INSERT INTO datos_sede.Sede
	(
		nombre,
		direccion
	)
	VALUES
	(
		@nombre,
		@direccion
	)
END;
GO

--LISTO, PROBAR
CREATE OR ALTER PROC datos_sede.MODIFICAR_SEDE
(
	@id_pk int,
	@nombre_arg varchar(50) = NULL,
	@direccion_arg varchar(50) = NULL
)
AS
BEGIN
	DECLARE @nombre varchar(50),
			@direccion varchar(50)

	SELECT	@nombre = nombre,
			@direccion = direccion

	FROM datos_sede.Sede
	WHERE id = @id_pk

	UPDATE datos_sede.Sede
	SET nombre = ISNULL(@nombre_arg,@nombre),
		direccion = ISNULL(@direccion_arg,@direccion)

	WHERE id = @id_pk
END;
GO

CREATE OR ALTER PROC datos_sede.ELIMINAR_SEDE
(@id_pk int)
AS
BEGIN
	DELETE FROM datos_sede.Sede
	WHERE id = @id_pk
END;
GO

CREATE OR ALTER PROC datos_sede.INSERTAR_DIAS_POR_SEDE
(
	@id_sede int,
	@id_medico int,
	@dia varchar(10),
	@hora_inicio time = NULL,
	@id_turno int
)
AS
BEGIN
	INSERT INTO datos_sede.Dias_por_sede
	(
		id_sede,
		id_medico,
		dia,
		hora_inicio,
		id_turno
	)
	VALUES
	(
		@id_sede,
		@id_medico,
		@dia,
		@hora_inicio,
		@id_turno
	)
END;
GO

CREATE OR ALTER PROC datos_sede.MODIFICAR_DIAS_POR_SEDE
(
	@id_sede_pk int,
	@id_medico_pk int,
	@id_sede_arg int = NULL,
	@id_medico_arg int = NULL,
	@dia_arg varchar(10) = NULL,
	@hora_inicio_arg time = NULL,
	@id_turno_arg int = NULL
)
AS
BEGIN
	DECLARE @id_sede int,
			@id_medico int,
			@dia varchar(10),
			@hora_inicio time,
			@id_turno int

	SELECT	@id_sede = id_sede,
			@id_medico = id_medico,
			@dia = dia,
			@hora_inicio = hora_inicio,
			@id_turno = id_turno

	FROM datos_sede.Dias_por_sede
	WHERE id_sede = @id_sede_pk AND id_medico = @id_medico_pk

	UPDATE datos_sede.Dias_por_sede
	SET id_sede = ISNULL(@id_sede_arg,@id_sede),
		id_medico = ISNULL(@id_medico_arg,@id_medico),
		dia = ISNULL(@dia_arg,@dia),
		hora_inicio = ISNULL(@hora_inicio_arg,@hora_inicio),
		id_turno = ISNULL(@id_turno_arg,@id_turno)
		

	WHERE id_sede = @id_sede_pk AND id_medico = @id_medico_pk
END;
GO

CREATE OR ALTER PROC datos_sede.ELIMINAR_DIAS_POR_SEDE
(
	@id_sede_pk int,
	@id_medico_pk int
)
AS
BEGIN
	DELETE FROM datos_sede.Dias_por_sede
	WHERE id_sede = @id_sede_pk AND id_medico = @id_medico_pk
END;
GO

/*FIN DE CREACIÓN DE TABLAS*/



/*CREACION DE FUNCIONES:*/

--creamos las funciones para validacion de datos
CREATE OR ALTER FUNCTION funciones.validar_fecha (@fecha_rec varchar(50)) RETURNS date AS
BEGIN
	DECLARE @fecha_valida date

	SET @fecha_valida = TRY_CONVERT(date,@fecha_rec)

	IF @fecha_valida IS NOT NULL
        RETURN @fecha_valida
	RETURN getdate()
END
GO

CREATE OR ALTER FUNCTION funciones.validar_dni_numero (@dni varchar(50)) RETURNS int AS
BEGIN
	DECLARE @dni_valido int
	
	SET @dni_valido = TRY_CONVERT(int,@dni)
	
	IF @dni_valido IS NULL
		RETURN 0

	IF @dni_valido >= 0
			RETURN @dni_valido
	RETURN -@dni_valido
END	
GO

CREATE OR ALTER FUNCTION funciones.validar_tipo_dni (@dni_tipo varchar(50)) RETURNS varchar(3) AS
BEGIN
	IF @dni_tipo = 'DNI' OR @dni_tipo = 'PASAPORTE'
		RETURN @dni_tipo
	
	RETURN 'DES'
END
GO

CREATE OR ALTER FUNCTION funciones.validar_sexo (@sexo varchar(50)) RETURNS Varchar(9) AS
BEGIN
	RETURN CASE UPPER(@sexo)
			WHEN 'MASCULINO' THEN 'Masculino'
			WHEN 'FEMENINO' THEN 'Femenino'
			ELSE 'Otro'
	END
END
GO

CREATE OR ALTER FUNCTION funciones.validar_telefono (@telefono varchar(50)) RETURNS Varchar(15) AS
BEGIN
	IF @telefono LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
		RETURN @telefono
	RETURN '(000) 000-0000'
END
GO

CREATE OR ALTER FUNCTION funciones.validar_mail (@mail varchar(50)) RETURNS Varchar(50) AS
BEGIN
	IF @mail LIKE '%_@%_.%'
		RETURN @mail
	RETURN 'null@null.com'
END
GO

CREATE OR ALTER FUNCTION funciones.obtener_domicilio (@domicilio varchar(50)) RETURNS Varchar(50) AS
BEGIN
	set @domicilio = REPLACE(@domicilio, ' Nº', '')
	set @domicilio = REPLACE(@domicilio, ' N°', '')
	set @domicilio = REPLACE(@domicilio, ' KM', '')

	declare @posPrimerNum int = PATINDEX('%[0123456789]%', @domicilio)
	declare @posSegundoNum int
	declare @substring varchar(50)

	IF @posPrimerNum > 0
	BEGIN
		SET @substring = SUBSTRING(@domicilio, @posPrimerNum + 1, len(@domicilio))
		SET @posSegundoNum = PATINDEX('% [0123456789]%', @substring)

		IF @posSegundoNum > 0
			RETURN SUBSTRING(@domicilio, 0, @posPrimerNum + @posSegundoNum)

		RETURN SUBSTRING(@domicilio, 0, @posPrimerNum)
	END

	return @domicilio
END
GO

CREATE OR ALTER FUNCTION funciones.obtener_num_domicilio (@domicilio varchar(50)) RETURNS int AS
BEGIN
	set @domicilio = REPLACE(@domicilio, ' Nº', '')
	set @domicilio = REPLACE(@domicilio, ' N°', '')
	set @domicilio = REPLACE(@domicilio, ' KM', '')

	declare @posPrimerNum int = PATINDEX('%[0123456789]%', @domicilio)
	declare @posSegundoNum int
	declare @substring varchar(50)

	IF @posPrimerNum > 0
	BEGIN
		SET @substring = SUBSTRING(@domicilio, @posPrimerNum + 1, len(@domicilio))
		SET @posSegundoNum = PATINDEX('% [0123456789]%', @substring)

		IF @posSegundoNum > 0
			RETURN TRY_CONVERT(INT, SUBSTRING(@substring, @posSegundoNum + 1, len(@domicilio)))

		RETURN TRY_CONVERT(INT, SUBSTRING(@domicilio, @posPrimerNum, len(@domicilio)))
	END

	return NULL
END
GO

CREATE OR ALTER FUNCTION funciones.obtener_segundo_apellido (@apellido varchar(50)) RETURNS Varchar(50) AS
BEGIN
	declare @substring varchar(50)
	declare @segundoApe varchar(50)
	declare @posIni int = (PATINDEX('%[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%', @apellido collate Modern_Spanish_CS_AS))
	declare @posSeg int

	IF @posIni > 0
	BEGIN
		set @substring = SUBSTRING(@apellido, @posIni + 1, len(@apellido)) 
		set @posSeg = PATINDEX('%[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%', @substring collate Modern_Spanish_CS_AS)
		
		IF @posSeg > 0
			return SUBSTRING(@apellido, patindex('% %',@substring collate Modern_Spanish_CS_AS) + @posIni + 1, len(@apellido))
	END

	return NULL
END
GO

CREATE OR ALTER FUNCTION funciones.obtener_primer_apellido (@apellido varchar(50)) RETURNS Varchar(50) AS
BEGIN
	declare @substring varchar(50)
	declare @segundoApe varchar(50)
	declare @posIni int = (PATINDEX('%[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%', @apellido collate Modern_Spanish_CS_AS))
	declare @posSeg int

	IF @posIni > 0
	BEGIN
		set @substring = SUBSTRING(@apellido, @posIni + 1, len(@apellido)) 
		set @posSeg = PATINDEX('%[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%', @substring collate Modern_Spanish_CS_AS)

		IF @posSeg > 0
			return SUBSTRING(@apellido, 0, patindex('% %',@substring collate Modern_Spanish_CS_AS) + @posIni)
	END

	return @apellido
END
GO

CREATE FUNCTION funciones.get_apellido_despues_de_punto(@str VARCHAR(255))
RETURNS VARCHAR(255) AS
BEGIN
    RETURN LTRIM(SUBSTRING(@str, CHARINDEX('.', @str) + 1, LEN(@str)))
END
GO

/*fin de funciones*/



/*
Los prestadores están conformador por Obras Sociales y Prepagas con las cuales se establece
una alianza comercial. Dicha alianza puede finalizar en cualquier momento, por lo cual debe
poder ser actualizable de forma inmediata si el contrato no está vigente. En caso de no estar
vigente el contrato, deben ser anulados todos los turnos de pacientes que se encuentren
vinculados a esa prestadora y pasar a estado disponible.
*/
GO
CREATE OR ALTER PROC datos_turno.ANULAR_TURNOS @id_prestador int AS --falta probar
BEGIN
	UPDATE	datos_turno.Reserva
	SET		id_estado_turno = (select id from datos_turno.Estado_Turno where nombre IN ('disponible', 'Disponible'))
	FROM	datos_turno.Reserva r INNER JOIN datos_usuario.Cobertura c ON r.ID_HIST_CLINICA = c.id_hist_clinica
	INNER JOIN datos_usuario.Prestador p ON c.id_prestador = p.id_prestador
	WHERE	p.id_prestador = @id_prestador
END
GO


/*LECTURA DE CSVs*/

--Cargar CSV de pacientes
CREATE OR ALTER PROC datos_usuario.CSV_CARGAR_PACIENTES @path varchar(max) AS
BEGIN
	set nocount on
	SET DATEFORMAT dmy
	declare @sql varchar(max)
	create table #csv_aux(
		nombre nvarchar(50),
		apellido nvarchar(50),
		fnac varchar(50),
		tipo_doc varchar(10),
		nro_doc int,
		sexo varchar(10),
		genero varchar(10),
		telefono nvarchar(15),
		nacionalidad nvarchar(30),
		mail nvarchar(50),
		calle nvarchar(50),
		localidad varchar(50),
		provincia varchar(50),
	)
	
	set @sql  = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + '65001' + ''')'--, DATAFILETYPE = ''' + 'WIDECHAR'+ ''')'
	exec (@sql)

	SELECT funciones.obtener_domicilio(calle) calle,funciones.obtener_num_domicilio(calle) numero,provincia,localidad
	INTO #dom_aux
	FROM #csv_aux

	INSERT INTO datos_usuario.Domicilio(calle,numero,provincia, localidad)
	SELECT DISTINCT *
	FROM #dom_aux d
	WHERE NOT EXISTS (SELECT 1 FROM datos_usuario.Domicilio dom WHERE ISNULL(d.calle,0)=ISNULL(dom.calle,0) AND ISNULL(dom.numero,0)=ISNULL(d.numero,0) AND dom.provincia=d.provincia AND dom.localidad=d.localidad 
						AND dom.piso IS NULL AND dom.departamento IS NULL AND dom.cod_postal IS NULL)

	SELECT nombre,funciones.obtener_primer_apellido(apellido) apellido ,funciones.obtener_segundo_apellido(apellido) ap_materno,funciones.validar_fecha(fnac) fnac,funciones.validar_tipo_dni(tipo_doc) tipo_doc,funciones.validar_dni_numero(nro_doc) nro_doc
	,funciones.validar_sexo(sexo) sexo,genero,nacionalidad,funciones.validar_mail(mail) mail,funciones.validar_telefono(telefono) telefono,GETDATE() time1,GETDATE() time2,funciones.obtener_domicilio(calle) calle,funciones.obtener_num_domicilio(calle) numero,provincia,localidad
	INTO #csv_aux2
	FROM #csv_aux aux
	WHERE NOT EXISTS (SELECT 1 FROM datos_usuario.Paciente pa WHERE aux.nombre=pa.nombre AND funciones.obtener_primer_apellido(aux.apellido)=pa.apellido AND 
	ISNULL(funciones.obtener_segundo_apellido(aux.apellido),'-')=ISNULL(pa.ape_materno,'-') AND funciones.validar_tipo_dni(aux.tipo_doc)=pa.tipo_doc AND funciones.validar_dni_numero(aux.nro_doc)=pa.num_doc AND
	aux.genero=pa.genero AND aux.nacionalidad=pa.nacionalidad)
	
	INSERT INTO datos_usuario.Paciente(nombre,apellido,ape_materno,fecha_nacim,tipo_doc,num_doc,sexo,genero,nacionalidad,mail,tel_fijo,fecha_registro,fecha_actualizacion,id_domicilio)
	SELECT nombre,apellido,ap_materno,fnac,tipo_doc,nro_doc,sexo,genero,nacionalidad,mail,telefono,time1,time2,d.id 
	FROM #csv_aux2 dom INNER JOIN datos_usuario.Domicilio d ON (ISNULL(d.calle,0)=ISNULL(dom.calle,0) AND ISNULL(dom.numero,0)=ISNULL(d.numero,0) AND dom.provincia=d.provincia AND dom.localidad=d.localidad 
		AND d.piso IS NULL AND d.departamento IS NULL AND d.cod_postal IS NULL)
END
GO 

/*PRUEBAS

DECLARE @path_medicos varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Medicos.csv'
DECLARE @path_pacientes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Pacientes.csv'
DECLARE @path_prestadores varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Prestador.csv'
DECLARE @path_sedes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Sedes.csv'
DECLARE @path_autorizados varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Centro_Autorizaciones.Estudios clinicos.json'

--Test del CSV de pacientes
select * from datos_usuario.Domicilio
select * from datos_usuario.Domicilio INNER JOIN datos_usuario.Paciente ON id_domicilio=id 
select * from datos_usuario.Paciente
--exec datos_turno.CSV_CARGAR_PACIENTES 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Pacientes.csv'
exec datos_usuario.CSV_CARGAR_PACIENTES @path_pacientes
GO
*/

--Cargar CSV de medicos
CREATE OR ALTER PROC datos_sede.CSV_CARGAR_MEDICOS @path varchar(max) AS
BEGIN
	set nocount on
	create table #csv_aux(
		nombre varchar(50),
		apellidos varchar(50), --se manejan cruzadas ya que el CSV tiene las columnas invertidas (en apellido tiene nombre y en nombre apellido).
		especialidad varchar(50),
		nro_coleg varchar(50)
	)

	declare @sql varchar(max) = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + '65001' + ''')'
	
	exec (@sql)

	SELECT Especialidad
	INTO #esp_aux
	FROM #csv_aux

	SELECT *
	INTO #csv_aux2
	FROM #csv_aux a
	WHERE NOT EXISTS (select 1 from datos_sede.Medico m INNER JOIN datos_sede.Especialidad e ON e.id=m.id_especialidad where ltrim(a.apellidos)=m.nombre AND funciones.get_apellido_despues_de_punto(a.nombre)=m.apellido AND e.nombre=a.especialidad)

	SELECT * FROM #csv_aux2

	INSERT INTO datos_sede.Especialidad(nombre)
	SELECT DISTINCT Especialidad
	FROM #esp_aux aux
	WHERE NOT EXISTS (select 1 from datos_sede.Especialidad es where es.nombre=aux.especialidad)

	Insert into datos_sede.Medico(nombre,apellido,nro_mat,id_especialidad) --como en el csv en apellido ponemos el nombre aca lo invertimos
	SELECT ltrim(a.apellidos),funciones.get_apellido_despues_de_punto(a.nombre),a.nro_coleg,e.id
	from #csv_aux2 a INNER JOIN datos_sede.Especialidad e ON a.especialidad=e.nombre
END
GO

/*PRUEBAS:

DECLARE @path_medicos varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Medicos.csv'
DECLARE @path_pacientes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Pacientes.csv'
DECLARE @path_prestadores varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Prestador.csv'
DECLARE @path_sedes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Sedes.csv'
DECLARE @path_autorizados varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Centro_Autorizaciones.Estudios clinicos.json'

--Testeamos cargar CSV medicos
select * FROM datos_sede.Medico a INNER JOIN datos_sede.Especialidad e ON a.id_especialidad=e.id ORDER BY a.apellido
SELECT * From datos_sede.Especialidad
DELETE FROM datos_sede.Medico
DELETE FROM datos_sede.Especialidad


--exec datos_turno.CSV_CARGAR_MEDICOS 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Medicos.csv'
exec datos_sede.CSV_CARGAR_MEDICOS @path_medicos --'C:\Users\admin\Desktop\BD_TP\BD_Aplicada\Datasets---Informacion-necesaria\Dataset\Medicos.csv' 
GO
*/

CREATE OR ALTER PROC datos_usuario.CSV_CARGAR_PRESTADORES @path varchar(max) AS
BEGIN
	set nocount on
	create table #csv_aux(
		prestador varchar(50),
		plan_pres varchar(50),
		aux varchar(10) --Agregamos este campo porque el formato tiene , de mas
	)

	declare @sql varchar(max) = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + '65001' + ''')'

	exec (@sql)

	INSERT datos_usuario.Prestador(nombre,plan_prestador)
	SELECT prestador,plan_pres
	FROM #csv_aux  aux
	WHERE NOT EXISTS (SELECT 1 FROM datos_usuario.Prestador pres WHERE aux.prestador=pres.nombre AND aux.plan_pres=pres.plan_prestador) 
END
GO

/*PRUEBAS
--Testeamos cargar CSV prestadores 

DECLARE @path_medicos varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Medicos.csv'
DECLARE @path_pacientes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Pacientes.csv'
DECLARE @path_prestadores varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Prestador.csv'
DECLARE @path_sedes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Sedes.csv'
DECLARE @path_autorizados varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Centro_Autorizaciones.Estudios clinicos.json'


select * from datos_usuario.Prestador

--exec datos_usuario.CSV_CARGAR_PRESTADORES 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Prestador.csv' --este tiene 2 ; de más.
exec datos_usuario.CSV_CARGAR_PRESTADORES @path_prestadores --'C:\Users\admin\Desktop\BD_TP\BD_Aplicada\Datasets---Informacion-necesaria\Dataset\Prestador.csv' 
GO
*/

CREATE OR ALTER PROC datos_sede.CSV_CARGAR_SEDES @path varchar(max) AS
BEGIN

	create table #csv_aux(
		sede nvarchar(50),
		direccion nvarchar(50),
		localidad nvarchar(50),
		provincia nvarchar(50)
	)

	declare @sql varchar(max) = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + '65001' + ''')'
	
	exec (@sql)

	INSERT INTO datos_sede.Sede(nombre,direccion,localidad)
	SELECT sede,direccion,localidad
	FROM #csv_aux aux
	WHERE NOT EXISTS (select 1 from datos_sede.Sede se WHERE se.nombre=aux.sede AND se.direccion=aux.direccion AND se.localidad=aux.localidad)
END
GO

/*PRUEBAS
--Probamos datos_sede.CSV_CARGAS_SEDES
SELECT * FROM datos_sede.Sede


DECLARE @path_medicos varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Medicos.csv'
DECLARE @path_pacientes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Pacientes.csv'
DECLARE @path_prestadores varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Prestador.csv'
DECLARE @path_sedes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Sedes.csv'
DECLARE @path_autorizados varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Centro_Autorizaciones.Estudios clinicos.json'



--exec datos_sede.CSV_CARGAR_SEDES 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Sedes.csv'
exec datos_sede.CSV_CARGAR_SEDES @path_sedes --'C:\Users\admin\Desktop\BD_TP\BD_Aplicada\Datasets---Informacion-necesaria\Dataset\Sedes.csv'
GO
*/

/*fin de lectura de CSVs*/


/*
Adicionalmente se requiere que el sistema sea capaz de generar un archivo XML detallando los 
turnos atendidos para informar a la Obra Social. El mismo debe constar de los datos del paciente 
(Apellido, nombre, DNI), nombre y matrícula del profesional que lo atendió, fecha, hora, 
especialidad. Los parámetros de entrada son el nombre de la obra social y un intervalo de fechas.
*/

CREATE OR ALTER PROC datos_turno.exportar_turnos @obra_social varchar(60), @fecha_ini date, @fecha_fin date AS
BEGIN
	SELECT	isnull(Paciente.apellido,'') + ' ' + isnull(Paciente.ape_materno,'') AS Apellido_paciente, Paciente.nombre Nombre_paciente, Paciente.tipo_doc Tipo_doc_paciente,
	Paciente.num_doc num_doc_paciente, Medico.apellido Apellido_profesional, Medico.nombre Nombre_profesional, Medico.nro_mat Matricula,
	E.nombre Especialidad, Reserva.fecha Fecha, Reserva.hora Hora
	FROM	datos_usuario.Prestador Prestador
	INNER JOIN datos_usuario.Cobertura Cobertura ON Prestador.id_prestador = Cobertura.id_prestador
	INNER JOIN datos_usuario.paciente Paciente ON Paciente.ID_HIST_CLINICA = Cobertura.id_hist_clinica
	INNER JOIN datos_turno.Reserva Reserva ON Paciente.ID_HIST_CLINICA = Reserva.id_hist_clinica
	INNER JOIN datos_sede.Dias_por_sede D ON Reserva.id_turno = D.id_turno
	INNER JOIN datos_sede.Medico Medico ON Medico.id = D.id_medico
	INNER JOIN datos_sede.Especialidad E ON Medico.id_especialidad = E.id
	WHERE	UPPER(Prestador.nombre) = UPPER(@obra_social) AND @fecha_ini <= Reserva.fecha AND Reserva.fecha <= @fecha_fin
	FOR XML AUTO, ROOT ('Turnos'), ELEMENTS XSINIL; 
END
GO

/*PRUEBAS
select	*
from	datos_usuario.Prestador


declare @Obra varchar(60) = 'OSPOCE'
declare @fecha_ini date = DATEADD(MONTH,-1,GETDATE())
declare @fecha_fin date = GETDATE()

exec datos_turno.exportar_turnos @obra, @fecha_ini, @fecha_fin
*/

/*DATOS DE PRUEBA*/

/*PRUEBAS

DECLARE @path_medicos varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Medicos.csv'
DECLARE @path_pacientes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Pacientes.csv'
DECLARE @path_prestadores varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Prestador.csv'
DECLARE @path_sedes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Sedes.csv'
DECLARE @path_autorizados varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Centro_Autorizaciones.Estudios clinicos.json'



insert into datos_turno.Tipo_Turno (id, nombre) values (1, 'Presencial'), (2, 'Virtual')
insert into datos_turno.estado_turno (id, nombre) values (1,'Atendido'),(2,'Ausente'),(3,'Cancelado'),(4,'Disponible')
insert into datos_turno.Reserva (id_turno, id_estado_turno, id_tipo_turno, id_hist_clinica) values (1,4,1,1),(2,4,1,1),(3,4,2,1),(4,4,1,1),(5,4,2,1),(6,4,1,1)

UPDATE	datos_turno.Reserva
SET		fecha = DATEADD(DAY,-5,GETDATE())
WHERE	id_turno = 6

insert into datos_sede.Especialidad(id, nombre) values(1, 'CARDIOLOGIA'),(2,'MEDICINA FAMILIAR'),(3,'DERMATOLOGIA')
insert into datos_sede.Medico(id, id_especialidad, nombre) values(1,1,'Richarlison'),(2,3,'Dermarlison'),(3,2,'Familiarlison')
insert into datos_sede.Sede(id,nombre) values (1, 'Sede1'),(2, 'Sede2')

insert into datos_sede.Dias_por_sede (id_sede, id_medico, id_turno) values(1,1,1),(1,2,2),(2,3,3),(1,2,4)
*/

/*FIN*/

/*
Los prestadores están conformador por Obras Sociales y Prepagas con las cuales se establece 
una alianza comercial. Dicha alianza puede finalizar en cualquier momento, por lo cual debe 
poder ser actualizable de forma inmediata si el contrato no está vigente. En caso de no estar 
vigente el contrato, deben ser anulados todos los turnos de pacientes que se encuentren 
vinculados a esa prestadora y pasar a estado disponible.
*/
CREATE OR ALTER PROC datos_usuario.ANULAR_TURNOS @id_prestador int AS
BEGIN --REVISAR, CREO QUE ESTÁ BIEN.
	declare @id_disponible int = (select id from datos_turno.Estado_Turno where UPPER(nombre) like 'DISPONIBLE')
	UPDATE	datos_turno.Reserva
	SET		id_estado_turno = @id_disponible
	FROM	datos_usuario.paciente P
	INNER JOIN datos_usuario.Cobertura C ON P.ID_HIST_CLINICA = C.id_hist_clinica
	INNER JOIN datos_usuario.Prestador PR ON PR.id_prestador = C.id_prestador
	INNER JOIN datos_turno.Reserva R ON P.ID_HIST_CLINICA = R.id_hist_clinica
	WHERE	PR.id_prestador = @id_prestador
END

GO

/*
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o 
solo un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía 
el código del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está 
autorizado o no y el importe a facturarle al paciente.
*/

--el campo $oid dificultó la búsqueda ya que se tuvo que obtener buscando $."$oid"
--además, los campos con espacios se debieron indicar con comillas dobles luego del $.
CREATE OR ALTER PROC datos_usuario.autorizar_estudio @id_estudio int, @dni int, @nombre_plan varchar(60), @path nvarchar(max), @resultado varchar(100) output AS
BEGIN
	set nocount on
	create table #json (txt NVARCHAR(MAX))
	declare @sql varchar(max) = 'BULK INSERT #json FROM ''' + @path + ''' WITH (CODEPAGE = ''' + '65001' + ''')'
	exec (@sql)
	declare @json nvarchar(max) = (SELECT TOP 1 txt FROM #json)


	declare @id_hist_clinica int = (select id_hist_clinica from datos_usuario.paciente where num_doc = @dni)

	declare @autorizado char
	declare @nombre_estudio nvarchar(100) 
	select @nombre_estudio = nombre, @autorizado = autorizado
	from datos_usuario.Estudio
	where id_estudio = @id_estudio AND id_hist_clinica = @id_hist_clinica


	declare @importe	decimal(10,2)
	declare @requiere_autorizacion char(5)

	select	@importe = porcentaje_cobertura * costo / 100 , @requiere_autorizacion = Requiere_autorizacion 
	from openjson(@json)
	WITH( 
	Area NVARCHAR(50) '$.Area' ,
	Estudio NVARCHAR(100) '$.Estudio',
	Prestador NVARCHAR(50) '$.Prestador',
	Nombre_plan NVARCHAR(50) '$.Plan',
	Porcentaje_cobertura int '$."Porcentaje Cobertura"',
	Costo int '$.Costo',
	Requiere_autorizacion varchar(20) '$."Requiere autorizacion"',
	subjson nvarchar(MAX)  '$._id' AS JSON)
		CROSS APPLY OPENJSON(subjson) WITH (
			id VARCHAR(20) '$."$oid"')
	where	Estudio = @nombre_estudio AND Nombre_plan = @nombre_plan

	IF @requiere_autorizacion = 'true' AND @autorizado = 'N'
	begin
		set @resultado = 'No se puede cubrir el Estudio ya que requiere autorización y aún no fue autorizado.'
		return
	end

	set @resultado = 'El importe final es $' + convert(varchar(20),isnull(@importe,0))
END
GO
/*******************************************/

/*PRUEBAS

DECLARE @path_medicos varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Medicos.csv'
DECLARE @path_pacientes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Pacientes.csv'
DECLARE @path_prestadores varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Prestador.csv'
DECLARE @path_sedes varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Sedes.csv'
DECLARE @path_autorizados varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Centro_Autorizaciones.Estudios clinicos.json'


DECLARE	@path varchar(max) = 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Centro_Autorizaciones.Estudios clinicos.json'
DECLARE	@ID_ESTUDIO int = 11
DECLARE	@nombre_plan varchar(60) = 'Plan 600 OSPOCE Integral'
DECLARE	@DNI INT = 1
declare @resultado varchar(100)
EXEC	datos_usuario.autorizar_estudio @id_estudio, @dni, @nombre_plan, @path_autorizados, @resultado output
print @resultado

select	*
from	datos_usuario.paciente

--INSERT INTO datos_usuario.paciente (num_doc, nombre, apellido) values (1, 'Claudio', 'McTestEstudio')
INSERT INTO datos_usuario.Estudio (id_estudio, id_hist_clinica, fecha, nombre, autorizado) values (10, 1, getdate(), 'ECOCARDIOGRAMA CON STRESS CON RESERVA DE FLUJO CORONARIO', 'N')
INSERT INTO datos_usuario.Prestador (nombre, plan_prestador) values ('OSPOCE', 'Plan 600 OSPOCE Integral')
INSERT INTO datos_usuario.Cobertura (id_hist_clinica, id_cobertura, id_prestador, nro_socio, fecha_registro) values (1, 1, 1, 1, getdate())

--estudio autorizado
INSERT INTO datos_usuario.Estudio (id_estudio, id_hist_clinica, fecha, nombre, autorizado) values (11, 1, getdate(), 'ECOCARDIOGRAMA CON STRESS CON RESERVA DE FLUJO CORONARIO', 'S')


select	*
from	datos_usuario.Estudio

GO
--fin de test del SP version 2
*/
/*******************************************/


