USE master
GO


IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'BDProyectoWeb')
DROP DATABASE BDProyectoWeb
GO

/** SE CREA LA BASE DE DATOS**/
CREATE DATABASE BDProyectoWeb
GO
/** SE SELECCIONA LA BASE DE DATOS CREADA**/
USE BDProyectoWeb
GO

/** INSTRUCCION QUE PERMITE CREAR LOS DIAGRAMAS**/
Alter authorization on database::BDProyectoWeb to sa 

/*Establece el formato de la fecha en dia/mes/año, 
cualquiera de las dos*/
SET DATEFORMAT dmy
SET LANGUAGE spanish
/*Instruccion que indica que la proxima consulta 
se ejecutará hasta que termine de ejecutarse la sentencia anterior*/
GO 
--tablas--

CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE() NOT NULL,
);

CREATE TABLE Categorias (
    id_categoria INT PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE Productos (
    id_producto INT PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

CREATE TABLE Inventario (
    id_inventario INT PRIMARY KEY,
    id_producto INT,
    cantidad INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE Compras (
    id_compra INT PRIMARY KEY,
    id_usuario INT,
    fecha_compra  DATETIME DEFAULT GETDATE(),
    total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE DetalleCompra (
    id_detalle_compra INT PRIMARY KEY,
    id_compra INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_compra) REFERENCES Compras(id_compra),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE Sesiones(
    id BIGINT IDENTITY(1,1) PRIMARY KEY, 
	id_usuario INT,
    sesion NVARCHAR(MAX) NOT NULL,  
    usuario BIGINT NOT NULL,  
    origen NVARCHAR(MAX) NULL,  
    fecha_inicio DATETIME NOT NULL,  
    fecha_final DATETIME NULL,  
    estado INT NOT NULL,  
    fecha_actualizacion DATETIME NOT NULL,
	FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);
GO

--STORED PROCEDURES
USE BDProyectoWeb
GO

CREATE PROCEDURE SP_INGRESAR_USUARIO
(
    @ID_USUARIO INT,
    @NOMBRE NVARCHAR(100),
    @EMAIL NVARCHAR(100),
    @PASSWORD VARCHAR(255),
    @IDRETURN INT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        -- Verificar si el correo electrónico ya está registrado
        IF EXISTS (SELECT 1 FROM Usuarios WHERE email = @EMAIL)
        BEGIN
            SET @IDRETURN = -1;
            SET @ERRORID = 1; -- Correo ya registrado
            SET @ERRORDESCRIPCION = 'ERROR DESDE BD: CORREO YA REGISTRADO';
        END
        ELSE
        BEGIN
            -- Insertar un nuevo usuario
            INSERT INTO Usuarios (id_usuario, nombre, email, password, fecha_registro)
            VALUES (@ID_USUARIO, @NOMBRE, @EMAIL, @PASSWORD, GETDATE());

            -- Retornar el ID del nuevo usuario
            SET @IDRETURN = @ID_USUARIO;
        END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @IDRETURN = -1;
        SET @ERRORID = ERROR_NUMBER();
        SET @ERRORDESCRIPCION = ERROR_MESSAGE();
    END CATCH
END
GO
--NO TOCAR

CREATE PROCEDURE SP_ELIMINAR_USUARIO
(
    @ID_USUARIO INT,
    @IDRETURN INT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        -- Verificar si el usuario existe
        IF EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = @ID_USUARIO)
        BEGIN
            -- Eliminar el usuario
            DELETE FROM Usuarios
            WHERE id_usuario = @ID_USUARIO;

            -- Retornar el ID del usuario eliminado
            SET @IDRETURN = @ID_USUARIO;
        END
        ELSE
        BEGIN
            -- Usuario no encontrado
            SET @IDRETURN = -1;
            SET @ERRORID = 2; -- Usuario no encontrado
            SET @ERRORDESCRIPCION = 'ERROR DESDE BD: USUARIO NO ENCONTRADO';
        END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @IDRETURN = -1;
        SET @ERRORID = ERROR_NUMBER();
        SET @ERRORDESCRIPCION = ERROR_MESSAGE();
    END CATCH
END
GO
--NO TOCAR
---------------------------------------------------------------------------------------
USE BDProyectoWeb
GO

CREATE PROCEDURE SP_LOGIN_USUARIO
(
    @EMAIL NVARCHAR(100),
    @PASSWORD VARCHAR(255),
    @SESION_ID BIGINT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        -- Inicializar valores de salida
        SET @SESION_ID = 0;
        SET @ERRORID = 0;
        SET @ERRORDESCRIPCION = '';

        -- Verificar si las credenciales son válidas
        IF EXISTS (
            SELECT 1
            FROM Usuarios
            WHERE email = @EMAIL AND password = @PASSWORD
        )
        BEGIN
            -- Insertar una nueva sesión
            INSERT INTO Sesiones 
                (sesion, usuario, origen, fecha_inicio, estado, fecha_actualizacion)
            VALUES 
                (NEWID(), (SELECT id_usuario FROM Usuarios WHERE email = @EMAIL), 'Web', GETDATE(), 1, GETDATE());

            -- Obtener el ID de la nueva sesión
            SET @SESION_ID = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- Credenciales inválidas
            SET @SESION_ID = -1;
            SET @ERRORID = 1;
            SET @ERRORDESCRIPCION = 'ERROR DESDE BD: CREDENCIALES INVÁLIDAS';
        END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @SESION_ID = -1;
        SET @ERRORID = ERROR_NUMBER();
        SET @ERRORDESCRIPCION = ERROR_MESSAGE();
    END CATCH
END
GO



USE BDProyectoWeb
GO
CREATE PROCEDURE SP_CERRAR_SESION
(
    @SESION_ID BIGINT
)
AS
BEGIN
    -- Actualizar el estado de la sesión a inactiva y registrar la fecha de cierre
    UPDATE Sesiones
    SET
        estado = 0,  -- Estado 0 indica que la sesión está cerrada
        fecha_final = GETUTCDATE(),  -- Fecha y hora en que se cerró la sesión
        fecha_actualizacion = GETUTCDATE()  -- Fecha y hora de la última actualización
    WHERE
        id = @SESION_ID;

    -- Opcionalmente, puedes agregar una verificación de si la sesión fue efectivamente cerrada
    IF @@ROWCOUNT = 0
    BEGIN
        -- Puedes manejar el caso en que no se encontró ninguna sesión para cerrar (opcional)
        PRINT 'No se encontró ninguna sesión activa para el ID especificado.';
    END
END
GO

--pruebas


--agregar usuario
DECLARE @IDRETURN INT;
DECLARE @ERRORID INT;
DECLARE @ERRORDESCRIPCION NVARCHAR(MAX);

-- Agregar un nuevo usuario
EXEC SP_INGRESAR_USUARIO
    @ID_USUARIO = 119320150,          -- ID del usuario (debe ser único)
    @NOMBRE = 'adrianaa',
    @EMAIL = 'adri@gmail.com',
    @PASSWORD = 'securepassword',
    @IDRETURN = @IDRETURN OUTPUT,
    @ERRORID = @ERRORID OUTPUT,
    @ERRORDESCRIPCION = @ERRORDESCRIPCION OUTPUT;

-- Verificar resultados
SELECT @IDRETURN AS IDRETURN, @ERRORID AS ERRORID, @ERRORDESCRIPCION AS ERRORDESCRIPCION;

------------------------------------------------------
--ELIMINAR USUARIO
DECLARE @IDRETURN INT;
DECLARE @ERRORID INT;
DECLARE @ERRORDESCRIPCION NVARCHAR(MAX);

-- Eliminar un usuario
EXEC SP_ELIMINAR_USUARIO
    @ID_USUARIO = 119320150,   -- ID del usuario a eliminar
    @IDRETURN = @IDRETURN OUTPUT,
    @ERRORID = @ERRORID OUTPUT,
    @ERRORDESCRIPCION = @ERRORDESCRIPCION OUTPUT;

-- Verificar resultados
SELECT @IDRETURN AS IDRETURN, @ERRORID AS ERRORID, @ERRORDESCRIPCION AS ERRORDESCRIPCION;

--------------------------------------------------
--INICIAR SESION
DECLARE @SESION_ID BIGINT;
DECLARE @ERRORID INT;
DECLARE @ERRORDESCRIPCION NVARCHAR(MAX);

-- Intentar iniciar sesión
EXEC SP_LOGIN_USUARIO
    @EMAIL = 'adri@gmail.com',
    @PASSWORD = 'securepassword',
    @SESION_ID = @SESION_ID OUTPUT,
    @ERRORID = @ERRORID OUTPUT,
    @ERRORDESCRIPCION = @ERRORDESCRIPCION OUTPUT;

-- Verificar resultados
SELECT @SESION_ID AS SESION_ID, @ERRORID AS ERRORID, @ERRORDESCRIPCION AS ERRORDESCRIPCION;


-------------------------------------------------------------
EXEC SP_CERRAR_SESION 
    @SESION_ID = 0;  -- Reemplaza con el ID de sesión obtenido al iniciar sesión
-------------------------------------------------------------------------------------
SELECT * FROM Sesiones;
SELECT * FROM Usuarios;
