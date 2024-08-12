USE master
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'BDProyectoWeb')
DROP DATABASE BDProyectoWeb
GO

CREATE DATABASE BDProyectoWeb
GO

USE BDProyectoWeb
GO
ALTER AUTHORIZATION ON DATABASE::BDProyectoWeb TO sa
SET DATEFORMAT dmy
SET LANGUAGE spanish

GO

-- Tablas --

CREATE TABLE Categorias (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL UNIQUE,
    descripcion NVARCHAR(100) NOT NULL
);

CREATE TABLE Productos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
	id_categoria INT,
    nombre NVARCHAR(100) NOT NULL UNIQUE,
    descripcion NVARCHAR(MAX),
    precio_producto DECIMAL(18, 2) NOT NULL,
    fecha_agregado DATETIME DEFAULT GETDATE() NOT NULL,
	cantidad INT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    cedula INT NOT NULL UNIQUE,
    nombre NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE() NOT NULL
);

CREATE TABLE Sesiones (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    sesion NVARCHAR(MAX) NOT NULL,
    usuario INT NOT NULL, 
    origen NVARCHAR(MAX) NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_final DATETIME NULL,
    estado INT NOT NULL,
    fecha_actualizacion DATETIME NOT NULL,
    FOREIGN KEY (usuario) REFERENCES Usuarios(id_usuario) 
);

CREATE TABLE Carrito (
    id_carrito INT IDENTITY(1,1) PRIMARY KEY,
	id_usuario INT NOT NULL,
	id_producto INT NOT NULL,
	FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);


CREATE TABLE Tarjetas (
    id_tarjeta INT IDENTITY(1,1) PRIMARY KEY,
    numero_tarjeta INT NOT NULL UNIQUE, 
    fecha_expiracion DATE NOT NULL,
	CVV INT NOT NULL UNIQUE,
	id_usuario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
);

CREATE TABLE Compra (
    id_compra INT IDENTITY(1,1) PRIMARY KEY,  
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    precio_total DECIMAL(18, 2) NOT NULL,
	id_usuario INT NOT NULL,
	id_producto INT NOT NULL,
	id_tarjeta INT NOT NULL,
	--foreign keys
	FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
	FOREIGN KEY (id_tarjeta) REFERENCES Tarjetas(id_tarjeta)
);

CREATE TABLE EncabezadoFactura (
   id_encabezadoFactura INT IDENTITY(1,1) PRIMARY KEY, 
   fecha DATETIME DEFAULT GETDATE() NOT NULL,
   --
   id_usuario INT NOT NULL,
   id_compra INT NOT NULL,
   --
   FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
   FOREIGN KEY (id_compra) REFERENCES Compra(id_compra),
);

CREATE TABLE DetalleFactura (
   id_detalleFactura INT IDENTITY(1,1) PRIMARY KEY,
   --
   id_encabezadoFactura INT NOT NULL,
   id_producto INT NOT NULL,
   id_compra INT NOT NULL,
   FOREIGN KEY (id_encabezadoFactura) REFERENCES encabezadoFactura(id_encabezadoFactura),
   FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
   FOREIGN KEY (id_compra) REFERENCES Compra(id_compra),
);

CREATE TABLE Factura (
   id_factura INT IDENTITY(1,1) PRIMARY KEY, 
   --
   id_detalleFactura  INT NOT NULL,
   id_encabezadoFactura  INT NOT NULL,
   FOREIGN KEY (id_encabezadoFactura) REFERENCES EncabezadoFactura(id_encabezadoFactura),
   FOREIGN KEY (id_detalleFactura) REFERENCES DetalleFactura(id_detalleFactura),
);

--STORED PROCEDURES
USE BDProyectoWeb
GO
CREATE PROCEDURE SP_INGRESAR_USUARIO
(
    @CEDULA INT,
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
            INSERT INTO Usuarios (cedula, nombre, email, password, fecha_registro)
            VALUES (@CEDULA, @NOMBRE, @EMAIL, @PASSWORD, GETDATE());

            -- Retornar la cédula del nuevo usuario
            SET @IDRETURN = @CEDULA;
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

--NO TOCAR FINAL
USE BDProyectoWeb
GO
CREATE PROCEDURE SP_ELIMINAR_USUARIO
(
    @CEDULA INT,
    @IDRETURN INT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        -- Verificar si el usuario existe
        IF EXISTS (SELECT 1 FROM Usuarios WHERE cedula = @CEDULA)
        BEGIN
            -- Eliminar el usuario
            DELETE FROM Usuarios
            WHERE cedula = @CEDULA;

            -- Retornar la cédula del usuario eliminado
            SET @IDRETURN = @CEDULA;
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

--NO TOCAR FINAL
USE BDProyectoWeb
GO
CREATE PROCEDURE SP_ACTUALIZAR_USUARIO
(
    @CEDULA INT,
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
        -- Verificar si el usuario existe
        IF EXISTS (SELECT 1 FROM Usuarios WHERE cedula = @CEDULA)
        BEGIN
            -- Actualizar los datos del usuario
            UPDATE Usuarios
            SET nombre = @NOMBRE,
                email = @EMAIL,
                password = @PASSWORD
            WHERE cedula = @CEDULA;

            -- Retornar la cédula del usuario actualizado
            SET @IDRETURN = @CEDULA;
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
--NO TOCAR FINAL
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
--NO TOCAR FINAL

USE BDProyectoWeb
GO

CREATE PROCEDURE SP_CERRAR_SESION
(
    @SESION_ID BIGINT,           -- Identificador de la sesión activa
    @IDRETURN INT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        -- Verificar si la sesión existe y está activa
        IF EXISTS (SELECT 1 FROM Sesiones WHERE id = @SESION_ID AND fecha_final IS NULL)
        BEGIN
            -- Actualizar la fecha final de la sesión para marcarla como cerrada
            UPDATE Sesiones
            SET fecha_final = GETDATE(),
                estado = 0,  -- Asumiendo que 0 indica una sesión cerrada
                fecha_actualizacion = GETDATE()
            WHERE id = @SESION_ID;

            -- Retornar el ID de la sesión cerrada
            SET @IDRETURN = @SESION_ID;
        END
        ELSE
        BEGIN
            -- Sesión no encontrada o ya cerrada
            SET @IDRETURN = -1;
            SET @ERRORID = 2; -- Sesión no encontrada o ya cerrada
            SET @ERRORDESCRIPCION = 'ERROR DESDE BD: SESIÓN NO ENCONTRADA O YA CERRADA';
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
--NO TOCAR FINAL
------------------------------------------------
USE BDProyectoWeb
GO
CREATE PROCEDURE SP_AGREGAR_PRODUCTO
(
    @nombre_categoria NVARCHAR(100),
    @nombre NVARCHAR(100),
    @descripcion NVARCHAR(MAX),
    @precio_producto DECIMAL(18, 2),
    @cantidad INT = NULL,  -- Parámetro opcional
    @IDRETURN INT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        -- Verificar si la categoría existe y obtener el ID
        DECLARE @id_categoria INT;

        SELECT @id_categoria = id_categoria
        FROM Categorias
        WHERE nombre = @nombre_categoria;

        IF @id_categoria IS NOT NULL
        BEGIN
            -- Insertar el nuevo producto
            INSERT INTO Productos 
            (
                id_categoria,
                nombre,
                descripcion,
                precio_producto,
                cantidad
            )
            VALUES
            (
                @id_categoria,
                @nombre,
                @descripcion,
                @precio_producto,
                @cantidad
            );

            -- Devolver el ID del nuevo producto
            SET @IDRETURN = SCOPE_IDENTITY();
            SET @ERRORID = 0;
            SET @ERRORDESCRIPCION = '';
        END
        ELSE
        BEGIN
            -- La categoría no existe, devolver error
            SET @IDRETURN = -1;
            SET @ERRORID = 1; -- Categoría no existe
            SET @ERRORDESCRIPCION = 'Categoría especificada no existe.';
        END
    END TRY
    BEGIN CATCH
        -- Capturar errores y devolver información sobre el error
        SET @IDRETURN = -1;
        SET @ERRORID = ERROR_NUMBER();
        SET @ERRORDESCRIPCION = ERROR_MESSAGE();
    END CATCH
END
GO
--NO TOCAR FINAL

USE BDProyectoWeb
GO
CREATE PROCEDURE SP_ELIMINAR_PRODUCTO
(
    @nombre NVARCHAR(100),
    @IDRETURN INT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        -- Verificar si el producto existe
        IF EXISTS (SELECT * FROM Productos WHERE nombre = @nombre)
        BEGIN
            -- Eliminar el producto
            DELETE FROM Productos
            WHERE nombre = @nombre;

            -- Devolver el ID del producto eliminado (si es necesario, si no se puede omitir)
            -- Aquí puedes usar un SELECT para obtener el ID del producto eliminado si es necesario
            SET @IDRETURN = 0; -- Indica éxito
            SET @ERRORID = 0;
            SET @ERRORDESCRIPCION = 'Producto eliminado exitosamente.';
        END
        ELSE
        BEGIN
            -- El producto no existe, devolver error
            SET @IDRETURN = -1;
            SET @ERRORID = 1; -- Producto no existe
            SET @ERRORDESCRIPCION = 'El producto especificado no existe.';
        END
    END TRY
    BEGIN CATCH
        -- Capturar errores y devolver información sobre el error
        SET @IDRETURN = -1;
        SET @ERRORID = ERROR_NUMBER();
        SET @ERRORDESCRIPCION = ERROR_MESSAGE();
    END CATCH
END
GO
--NO TOCAR FINAL

USE BDProyectoWeb
GO
CREATE PROCEDURE SP_ACTUALIZAR_PRODUCTO
(
    @nombre_actual NVARCHAR(100),  -- Nombre actual del producto a actualizar
    @nuevo_nombre NVARCHAR(100),   -- Nuevo nombre del producto
    @descripcion NVARCHAR(MAX),    -- Nueva descripción del producto
    @precio_producto DECIMAL(18, 2), -- Nuevo precio del producto
    @cantidad INT,                 -- Nueva cantidad del producto
    @nombre_categoria NVARCHAR(100), -- Nuevo nombre de la categoría
    @IDRETURN INT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        -- Obtener el id_categoria basado en el nombre de la categoría
        DECLARE @id_categoria INT;

        SELECT @id_categoria = id_categoria
        FROM Categorias
        WHERE nombre = @nombre_categoria;

        IF @id_categoria IS NULL
        BEGIN
            -- La categoría no existe, devolver error
            SET @IDRETURN = -1;
            SET @ERRORID = 1; -- Categoría no existe
            SET @ERRORDESCRIPCION = 'Categoría especificada no existe.';
            RETURN;
        END

        -- Verificar si el producto existe
        IF EXISTS (SELECT * FROM Productos WHERE nombre = @nombre_actual)
        BEGIN
            -- Actualizar el producto
            UPDATE Productos
            SET
                nombre = @nuevo_nombre,
                descripcion = @descripcion,
                precio_producto = @precio_producto,
                cantidad = @cantidad,
                id_categoria = @id_categoria
            WHERE nombre = @nombre_actual;

            -- Devolver éxito
            SET @IDRETURN = 0;
            SET @ERRORID = 0;
            SET @ERRORDESCRIPCION = 'Producto actualizado exitosamente.';
        END
        ELSE
        BEGIN
            -- El producto no existe, devolver error
            SET @IDRETURN = -1;
            SET @ERRORID = 2; -- Producto no existe
            SET @ERRORDESCRIPCION = 'El producto especificado no existe.';
        END
    END TRY
    BEGIN CATCH
        -- Capturar errores y devolver información sobre el error
        SET @IDRETURN = -1;
        SET @ERRORID = ERROR_NUMBER();
        SET @ERRORDESCRIPCION = ERROR_MESSAGE();
    END CATCH
END
GO
--NO TOCAR final

--------------------------------------------------------
USE BDProyectoWeb
GO
CREATE PROCEDURE SP_INSERTAR_CATEGORIA
(
    @NOMBRE NVARCHAR(100),
    @DESCRIPCION NVARCHAR(100),
    @IDRETURN INT OUTPUT,
    @ERRORID INT OUTPUT,
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Categorias (nombre, descripcion)
        VALUES (@NOMBRE, @DESCRIPCION);
        SET @IDRETURN = SCOPE_IDENTITY();
        SET @ERRORID = 0;
        SET @ERRORDESCRIPCION = 'Inserción exitosa';
    END TRY
    BEGIN CATCH
        SET @IDRETURN = -1;
        SET @ERRORID = ERROR_NUMBER();
        SET @ERRORDESCRIPCION = ERROR_MESSAGE();
    END CATCH
END
GO
--NO TOCAR final
USE BDProyectoWeb
GO
CREATE PROCEDURE ActualizarCategoria
    @NOMBRE NVARCHAR(100),            -- Nombre de la categoría que se va a actualizar
    @NUEVO_NOMBRE NVARCHAR(100),      -- Nuevo nombre de la categoría
    @NUEVA_DESCRIPCION NVARCHAR(100), -- Nueva descripción de la categoría
    @IDRETURN INT OUTPUT,             -- Salida del resultado del procedimiento
    @ERRORID INT OUTPUT,              -- Salida del código de error
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT -- Salida de la descripción del error
AS
BEGIN
    BEGIN TRY
        -- Actualizar la categoría con el nuevo nombre y descripción
        UPDATE Categorias
        SET nombre = @NUEVO_NOMBRE,
            descripcion = @NUEVA_DESCRIPCION
        WHERE nombre = @NOMBRE;
        
        -- Verificar si la actualización fue exitosa
        IF @@ROWCOUNT = 0
        BEGIN
            SET @IDRETURN = 0;
            SET @ERRORID = 1;
            SET @ERRORDESCRIPCION = 'Categoría no encontrada o no actualizada';
        END
        ELSE
        BEGIN
            SET @IDRETURN = 1;
            SET @ERRORID = 0;
            SET @ERRORDESCRIPCION = 'Actualización exitosa';
        END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @IDRETURN = 0;
        SET @ERRORID = ERROR_NUMBER();
        SET @ERRORDESCRIPCION = ERROR_MESSAGE();
    END CATCH
END;
GO
--NO TOCAR final

USE BDProyectoWeb
GO
CREATE PROCEDURE SP_ELIMINAR_CATEGORIA
(
    @NOMBRE NVARCHAR(100),         -- Nombre de la categoría que se va a eliminar
    @IDRETURN INT OUTPUT,          -- Salida del resultado del procedimiento
    @ERRORID INT OUTPUT,           -- Salida del código de error
    @ERRORDESCRIPCION NVARCHAR(MAX) OUTPUT -- Salida de la descripción del error
)
AS
BEGIN
    BEGIN TRY
        -- Verificar si la categoría existe
        IF EXISTS (SELECT 1 FROM Categorias WHERE nombre = @NOMBRE)
        BEGIN
            -- Eliminar la categoría
            DELETE FROM Categorias
            WHERE nombre = @NOMBRE;

            -- Retornar un valor de éxito
            SET @IDRETURN = 1;
            SET @ERRORID = 0;
            SET @ERRORDESCRIPCION = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            -- Categoría no encontrada
            SET @IDRETURN = -1;
            SET @ERRORID = 2; -- Categoría no encontrada
            SET @ERRORDESCRIPCION = 'ERROR DESDE BD: CATEGORÍA NO ENCONTRADA';
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
--NO TOCAR final
---------------------------------------------------------
--Compras
USE BDProyectoWeb
GO
SELECT 
    C.id_carrito,
    U.id_usuario,
    U.nombre AS nombre_usuario,
    P.id_producto,
    P.nombre AS nombre_producto,
    P.descripcion AS descripcion_producto,
    P.precio_producto,
    C.id_usuario,
    C.id_producto
FROM 
    Carrito C
FULL JOIN 
    Usuarios U ON C.id_usuario = U.id_usuario
FULL JOIN 
    Productos P ON C.id_producto = P.id_producto;
GO
