


--El trigger valida_cantidad_personal se dispara antes de realizar una operaci�n de inserci�n o actualizaci�n en la tabla PERSONAL. Su objetivo es verificar la cantidad total de registros en la tabla y compararla con un l�mite m�ximo establecido (en este caso, 10). Si la cantidad total de registros es igual o superior al l�mite m�ximo, el trigger genera un error personalizado que indica que no se puede agregar m�s personal debido a que se ha alcanzado el l�mite m�ximo establecido. En resumen, el trigger evita que se agreguen m�s registros a la tabla PERSONAL una vez que se ha alcanzado el l�mite m�ximo especificado.


CREATE OR REPLACE TRIGGER valida_cantidad_personal
BEFORE INSERT OR UPDATE ON PERSONAL
FOR EACH ROW
DECLARE
  total_personal NUMBER;
  limite_maximo CONSTANT NUMBER := 10; -- Establecer el l�mite m�ximo deseado
BEGIN
  SELECT COUNT(*) INTO total_personal FROM PERSONAL;
  
  IF total_personal >= limite_maximo THEN
    RAISE_APPLICATION_ERROR(-20001, 'No se puede agregar m�s personal. Se ha alcanzado el l�mite m�ximo.');
  END IF;
END;
/

