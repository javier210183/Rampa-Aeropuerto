


--El trigger valida_cantidad_personal se dispara antes de realizar una operación de inserción o actualización en la tabla PERSONAL. Su objetivo es verificar la cantidad total de registros en la tabla y compararla con un límite máximo establecido (en este caso, 10). Si la cantidad total de registros es igual o superior al límite máximo, el trigger genera un error personalizado que indica que no se puede agregar más personal debido a que se ha alcanzado el límite máximo establecido. En resumen, el trigger evita que se agreguen más registros a la tabla PERSONAL una vez que se ha alcanzado el límite máximo especificado.


CREATE OR REPLACE TRIGGER valida_cantidad_personal
BEFORE INSERT OR UPDATE ON PERSONAL
FOR EACH ROW
DECLARE
  total_personal NUMBER;
  limite_maximo CONSTANT NUMBER := 10; -- Establecer el límite máximo deseado
BEGIN
  SELECT COUNT(*) INTO total_personal FROM PERSONAL;
  
  IF total_personal >= limite_maximo THEN
    RAISE_APPLICATION_ERROR(-20001, 'No se puede agregar más personal. Se ha alcanzado el límite máximo.');
  END IF;
END;
/

