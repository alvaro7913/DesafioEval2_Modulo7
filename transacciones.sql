transacciones.sql


-- CREATE DATABASE transacciones;
-- \c transacciones
-- Apagamos el autocommit en la base de datos
\set AUTOCOMMIT off

-- Utilizando el siguiente comando en la terminal, recuperamos la base de datos desde el archivo unidad2.sql
-- psql -U alvaro transacciones < unidad2.sql

-- Visualizamos las tablas cargadas
-- \d
-- 2. El cliente usuario01 ha realizado la siguiente compra:
-- ● producto: producto9.
-- ● cantidad: 5.
-- ● fecha: fecha del sistema.
BEGIN TRANSACTION;
    -- Agregamos la cabecera de la compra
    INSERT INTO compra (cliente_id, fecha)
    VALUES (1, current_date);
    -- Agregamos el detalle de la compra 
    INSERT INTO detalle_compra (producto_id, compra_id, cantidad)
    VALUES(9, (SELECT id FROM compra WHERE cliente_id = 1 AND fecha = current_date LIMIT 1), 5);
    -- Actualizamos la tabla de productos con sus stocks 
    UPDATE producto SET stock = stock - 5 WHERE id = 9;
    -- Control de las tablas para validar las transacciones
    SELECT
        x.nombre,
        c.fecha,
        dc.cantidad,
        p.descripcion,
        p.stock
    FROM
        cliente AS x LEFT OUTER JOIN
        compra AS c ON c.cliente_id = x.id LEFT OUTER JOIN
        detalle_compra AS dc ON dc.compra_id = c.id LEFT OUTER JOIN
        producto AS p ON p.id = dc.producto_id
    WHERE
        x.id = 1 and c.fecha = current_date;
COMMIT TRANSACTION;
-- La transaccion se completa ya que existe el stock necesario en la tabla producto

-- 3. El cliente usuario02 ha realizado la siguiente compra:
-- ● producto: producto1, producto 2, producto 8.
-- ● cantidad: 3 de cada producto.
-- ● fecha: fecha del sistema.
BEGIN TRANSACTION;
    -- Agregamos la cabecera de la compra
    INSERT INTO compra (cliente_id, fecha)
    VALUES (2, current_date);

    -- Agregamos el detalle de la compra 
    INSERT INTO detalle_compra (producto_id, compra_id, cantidad)
    VALUES(1, (SELECT id FROM compra WHERE cliente_id = 2 AND fecha = current_date LIMIT 1), 3);
    INSERT INTO detalle_compra (producto_id, compra_id, cantidad)
    VALUES(2, (SELECT id FROM compra WHERE cliente_id = 2 AND fecha = current_date LIMIT 1), 3);
    INSERT INTO detalle_compra (producto_id, compra_id, cantidad)
    VALUES(8, (SELECT id FROM compra WHERE cliente_id = 2 AND fecha = current_date LIMIT 1), 3);

    -- Actualizamos la tabla de productos con sus stocks 
    UPDATE producto SET stock = stock - 3 WHERE id=1;
    UPDATE producto SET stock = stock - 3 WHERE id=2;
    UPDATE producto SET stock = stock - 3 WHERE id=8;

    -- Control de las tablas para validar las transacciones
    SELECT
        x.nombre,
        c.fecha,
        dc.cantidad,
        p.descripcion,
        p.stock
    FROM
        cliente AS x LEFT OUTER JOIN
        compra AS c ON c.cliente_id = x.id LEFT OUTER JOIN
        detalle_compra AS dc ON dc.compra_id = c.id LEFT OUTER JOIN
        producto AS p ON p.id = dc.producto_id
    WHERE
        x.id = 2 and c.fecha = current_date;
COMMIT TRANSACTION;
-- No se realiza la transacción ya que el stock del producto 8 es insuficiente 
-- 4. Realizar las siguientes consultas (2 Puntos):
-- a. Deshabilitar el AUTOCOMMIT .
\set AUTOCOMMIT off
-- Creamos un punto de restauración 
BEGIN TRANSACTION;
SAVEPOINT before_insert;
-- b. Insertar un nuevo cliente.

BEGIN TRANSACTION;
    INSERT INTO cliente(nombre, email)
    VALUES ('Pantomima', 'pantomima@correo.com');
    -- c. Confirmar que fue agregado en la tabla cliente.
    SELECT * FROM cliente ORDER BY id DESC LIMIT 1;
    -- d. Realizar un ROLLBACK.
ROLLBACK TO before_insert;

-- e. Confirmar que se restauró la información, sin considerar la inserción del
-- punto b.
SELECT * FROM cliente ORDER BY id DESC LIMIT 1;
-- f. Habilitar de nuevo el AUTOCOMMIT.
\set AUTOCOMMIT on

-- Realizamos un respaldo de la base de datos en la terminal (no psql)
-- pg_dump -U alvaro transacciones > steve_gate.sql
