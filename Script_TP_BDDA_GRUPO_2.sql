--CREACION DE LA BASE DE DATOS:
CREATE DATABASE TP_GRUPO_2
go
USE TP_GRUPO_2
go


--CREACION DE ESQUEMAS:
CREATE SCHEMA datos_usuario
GO
CREATE SCHEMA datos_turno
GO
CREATE SCHEMA datos_sede
GO


--CREACION DE TABLAS:
--PACIENTE:
CREATE TABLE datos_usuario.paciente (
ID_HIST_CLINICA INT,
nombre NVARCHAR(50),
apellido nvarchar(50),
ape_materno nvarchar(50),
fecha_nacim date,
tipo_doc char(5),
num_doc int,
sexo varchar(9),
genero varchar(10),
nacionalidad nvarchar(30),
foto_perfil varchar(max), --?????????????????????????????????????????????????????????????????????????
mail nvarchar(100),
tel_fijo varchar(15),
tel_contacto varchar(15),
tel_laboral varchar(15),
fecha_registro date,
fecha_actualizacion datetime,
usuario_actualizacion varchar(50),

CONSTRAINT PK_Paciente PRIMARY KEY (ID_HIST_CLINICA)
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
nombre nvarchar(50),
autorizado char,
documento_resu varchar(max), --?????????????????????????????????????????????????????????????????????????
imagen_resu varchar(max), --?????????????????????????????????????????????????????????????????????????
CONSTRAINT PK_Estudio PRIMARY KEY (id_estudio), --o tambien id_hist_clinica
CONSTRAINT FK_Estudio_HC FOREIGN KEY (id_hist_clinica) REFERENCES datos_usuario.Paciente(id_hist_clinica),
CONSTRAINT CK_autorizado CHECK (autorizado IN ('S', 'N')) --así?
)
GO

CREATE TABLE datos_usuario.Cobertura(
id_cobertura int,
id_hist_clinica int,
imagen_credencial varchar(max), --????????????????????????????????????????
nro_socio int,
fecha_registro date,
CONSTRAINT PK_Cobertura PRIMARY KEY(id_cobertura),
CONSTRAINT FK_Cobertura_HC FOREIGN KEY (id_hist_clinica) REFERENCES datos_usuario.Paciente(id_hist_clinica)
)
GO

CREATE TABLE datos_usuario.Prestador(
id_prestador int,
nombre nvarchar(50),
plan_prestador nvarchar(50),
id_cobertura int,
CONSTRAINT PK_Prestador PRIMARY KEY(id_prestador),
CONSTRAINT FK_Prestador_Cob FOREIGN KEY(id_cobertura) REFERENCES datos_usuario.Cobertura(id_cobertura)
)
GO

CREATE TABLE datos_usuario.Domicilio(
id int,
calle nvarchar(50),
numero int,
piso int,
departamento int,
cod_postal int,
pais nvarchar(50),
provincia nvarchar(50),
localidad nvarchar(50),
id_hist_clinica int,
CONSTRAINT PK_Domicilio PRIMARY KEY(ID),
CONSTRAINT FK_Domicilio_HC FOREIGN KEY (id_hist_clinica) REFERENCES datos_usuario.Paciente(id_hist_clinica)
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
id int,
nombre varchar(50),
CONSTRAINT PK_Especialidad PRIMARY KEY(id)
)
GO

CREATE TABLE datos_sede.Medico(
id int,
nombre nvarchar(50),
apellido nvarchar(50),
nro_mat int,
id_especialidad int,
CONSTRAINT PK_Medico PRIMARY KEY(id),
CONSTRAINT FK_Medico_ESP FOREIGN KEY(id_especialidad) REFERENCES datos_sede.Especialidad(id)
)
GO

CREATE TABLE datos_sede.Sede(
id int,
nombre nvarchar(50),
direccion nvarchar(50),
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
CREATE OR ALTER PROC datos_usuario.INSERTAR_PACIENTE 
(
    @ID_HIST_CLINICA INT,
    @nombre NVARCHAR(50),
    @apellido NVARCHAR(50),
    @ape_materno NVARCHAR(50),
    @fecha_nacim DATE,
    @tipo_doc CHAR(5),
    @num_doc INT,
    @sexo VARCHAR(9),
    @genero VARCHAR(10),
    @nacionalidad NVARCHAR(30),
    @foto_perfil VARCHAR(MAX),
    @mail NVARCHAR(100),
    @tel_fijo VARCHAR(15),
    @tel_contacto VARCHAR(15),
    @tel_laboral VARCHAR(15),
    @fecha_registro DATE,
    @fecha_actualizacion DATETIME,
    @usuario_actualizacion VARCHAR(50)
)
AS
BEGIN
    INSERT INTO datos_usuario.paciente
    (
        ID_HIST_CLINICA,
        nombre,
        apellido,
        ape_materno,
        fecha_nacim,
        tipo_doc,
        num_doc,
        sexo,
        genero,
        nacionalidad,
        foto_perfil,
        mail,
        tel_fijo,
        tel_contacto,
        tel_laboral,
        fecha_registro,
        fecha_actualizacion,
        usuario_actualizacion
    )
    VALUES
    (
        @ID_HIST_CLINICA,
        @nombre,
        @apellido,
        @ape_materno,
        @fecha_nacim,
        @tipo_doc,
        @num_doc,
        @sexo,
        @genero,
        @nacionalidad,
        @foto_perfil,
        @mail,
        @tel_fijo,
        @tel_contacto,
        @tel_laboral,
        @fecha_registro,
        @fecha_actualizacion,
        @usuario_actualizacion
    )
END;
GO

--el resto haganlo ustedes manga de kokemones



/*
Los prestadores están conformador por Obras Sociales y Prepagas con las cuales se establece
una alianza comercial. Dicha alianza puede finalizar en cualquier momento, por lo cual debe
poder ser actualizable de forma inmediata si el contrato no está vigente. En caso de no estar
vigente el contrato, deben ser anulados todos los turnos de pacientes que se encuentren
vinculados a esa prestadora y pasar a estado disponible.
*/
CREATE OR ALTER PROC datos_turno.ANULAR_TURNOS @id_prestador int AS --falta probar
BEGIN
	UPDATE	datos_turno.Reserva
	SET		id_estado_turno = (select id from datos_turno.Estado_Turno where nombre IN ('disponible', 'Disponible'))
	FROM	datos_turno.Reserva r INNER JOIN datos_usuario.Cobertura c ON r.ID_HIST_CLINICA = c.id_hist_clinica
	INNER JOIN datos_usuario.Prestador p ON c.id_cobertura = p.id_cobertura
	WHERE	p.id_prestador = @id_prestador
END
GO

/* esto parece falopa con alguna API que todavía no explicaron, PREGUNTAR EL MIÉRCOLES.
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o
solo un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía
el código del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está
autorizado o no y el importe a facturarle al paciente.
*/

/* esto todavía no vimos, debe ser cosa de seguridad. 
Los roles establecidos al inicio del proyecto son:
• Paciente
• Medico
• Personal Administrativo
• Personal Técnico clínico
• Administrador General
El usuario web se define utilizando el DNI.
*/

--traer datos de CSV Medicos.csv:
CREATE OR ALTER PROC datos_turno.CSV_CARGAR_PACIENTES @path varchar(max) AS
BEGIN
/* NO SE PUEDE USAR UNA TABLA VARIABLE PARA HACER EL INSERT.
	declare @csv_aux table(nombre nvarchar(50),apellido nvarchar(50),fnac date,tipo_doc varchar(10),nro_doc int,sexo varchar(10),genero varchar(10),
		telefono varchar(15),nacionalidad nvarchar(30),mail nvarchar(50),calle nvarchar(50))
*/

	create table #csv_aux(
		nombre nvarchar(50),
		apellido nvarchar(50),
		fnac varchar(50), --PREGUNTAR POR QUE NO PUEDO USAR DATETIME NI DATE.
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

	declare @sql varchar(max) = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + '65001' + ''')'--, DATAFILETYPE = ''' + 'WIDECHAR'+ ''')'
	 	
	exec (@sql)
	/* no se puede hacer esto porque el path es variable y no se puede poner el from variable, hay que usar SQL dinámicock.
	BULK INSERT #csv_aux
	FROM [@path]
	WITH
	(
		FIELDTERMINATOR = ',',  -- Delimitador de campo
		ROWTERMINATOR = '\n',   -- Delimitador de fila
		FIRSTROW = 2            -- La primera fila que se debe cargar (útil si tu archivo tiene encabezados)
	)
	*/

	
	declare @i int = 0
	declare @cant int = (select count(*) from #csv_aux)

	declare @nombre nvarchar(50), @apellido nvarchar(50), @fnac varchar(50), @tipo_doc varchar(10), @nro_doc int,@sexo varchar(10),@genero varchar(10),
		@telefono nvarchar(15),@nacionalidad nvarchar(30),@mail nvarchar(50),@calle nvarchar(50),@localidad varchar(50),@provincia varchar(50)

	WHILE @i < @cant
	BEGIN
		SELECT @nombre = nombre, @apellido = apellido, @fnac = fnac, @tipo_doc = tipo_doc, @nro_doc = nro_doc, @sexo = sexo, @genero = genero,
				@telefono = telefono, @nacionalidad = nacionalidad, @mail = mail, @calle = calle, @localidad = localidad, @provincia = provincia
		FROM #csv_aux
		OFFSET @i ROWS
		FETCH NEXT 1 ROW ONLY;

		set @i = @i + 1



	END

	/*ESTO DEBERÍA SER
	insert into tabla_final
	SELECT	validar_nombre(nombre), validar_apellido(apellido)... validar_provincia(provincia)
	FROM	#csv_aux
	*/
	
	--select	*
	--from	#csv_aux

	--drop table #csv_aux POR QUE NO EXISTE? POR CREARLA DENTRO DEL SP? 'SERÁ QUE LA SESIÓN ES EL STORED PROCEDURE' FRANCO - 2023
END

--GRANT ADMINISTER DATABASE BULK OPERATIONS TO [SANTIAGO\caste];

--exec datos_turno.CSV_CARGAR_PACIENTES 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Pacientes.csv'
GO


CREATE OR ALTER PROC datos_turno.CSV_CARGAR_MEDICOS @path varchar(max) AS
BEGIN

	create table #csv_aux(
		nombre varchar(50),
		apellidos varchar(50),
		especialidad varchar(50),
		nro_coleg int
	)

	--declare @sql varchar(max) = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + 'RAW' + ''' )'
	declare @sql varchar(max) = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + '65001' + ''')'
	
	exec (@sql)

	select	*
	from	#csv_aux
END
GO
--exec datos_turno.CSV_CARGAR_MEDICOS 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Medicos.csv'


CREATE OR ALTER PROC datos_turno.CSV_CARGAR_PRESTADORES @path varchar(max) AS
BEGIN

	create table #csv_aux(
		prestador varchar(50),
		plan_pres varchar(50),
		aux varchar(10),
		aux2 varchar(10)
	)

	declare @sql varchar(max) = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + '65001' + ''')'
	
	exec (@sql)

	select	*
	from	#csv_aux
END
GO

exec datos_turno.CSV_CARGAR_PRESTADORES 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Prestador.csv' --este tiene 2 ; de más.
GO

CREATE OR ALTER PROC datos_turno.CSV_CARGAR_SEDES @path varchar(max) AS
BEGIN

	create table #csv_aux(
		sede nvarchar(50),
		deireccion nvarchar(50),
		localidad nvarchar(50),
		provincia nvarchar(50)
	)

	declare @sql varchar(max) = 'BULK INSERT #csv_aux FROM ''' + @path + ''' WITH (FIELDTERMINATOR = ''' + ';' + ''',	ROWTERMINATOR = ''' + '\n' + ''', FIRSTROW = 2, CODEPAGE = ''' + '65001' + ''')'
	
	exec (@sql)

	select	*
	from	#csv_aux
END
GO

exec datos_turno.CSV_CARGAR_SEDES 'F:\UNLaM\2023 2C\Bases de Datos Aplicadas\TP BDDA\Dataset\Sedes.csv' --este tiene 2 ; de más.
GO

--hasta acá llegamos 10/09/2023