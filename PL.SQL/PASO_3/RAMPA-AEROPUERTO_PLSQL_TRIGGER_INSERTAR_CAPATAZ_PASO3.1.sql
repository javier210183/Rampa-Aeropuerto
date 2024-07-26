--Este disparador (trigger) en SQL se activa tras cada inserción en la tabla ABRIR. Su objetivo es asegurarse de que, si el tipo de personal (TIP_PERSONAL) de la nueva fila insertada en ABRIR no existe en la tabla CAPATACES, se añade una nueva entrada con ese tipo de personal en CAPATACES, tomando el DNI del jefe de turno de la tabla PERSONAL. En caso de no encontrar el tipo de personal en la tabla PERSONAL, lanza un error.









CREATE OR REPLACE TRIGGER INSERTAR_CAPATAZ_SI_NO_EXISTE
AFTER INSERT ON ABRIR
FOR EACH ROW
DECLARE
    v_existe_capataz NUMBER;
    v_dni_capataz VARCHAR2(20);
BEGIN
    -- Comprueba si ya existe el capataz en la tabla CAPATACES
    SELECT COUNT(*)
    INTO v_existe_capataz
    FROM CAPATACES
    WHERE TIP_CAPATAZ = :NEW.TIP_PERSONAL;
    
    -- Si no existe, inserta el nuevo capataz
    IF v_existe_capataz = 0 THEN
        SELECT DNI_JEFE_DE_TURNO
        INTO v_dni_capataz
        FROM PERSONAL
        WHERE TIP_PERSONAL = :NEW.TIP_PERSONAL;
        
        INSERT INTO CAPATACES (DNI_CAPATAZ, TIP_CAPATAZ)
        VALUES (v_dni_capataz, :NEW.TIP_PERSONAL);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se encontró personal con TIP_PERSONAL = ' || :NEW.TIP_PERSONAL);
END;
/




