CREATE OR REPLACE PACKAGE BODY PK_OPERARIOS AS

  PROCEDURE GRABAR (
    p_tip_operariohipodromo       NUMBER,
    p_tip_capatazhipodromo        NUMBER,
    p_pausa                       VARCHAR2,
    p_destinos_salida             VARCHAR2,
    p_turno                       VARCHAR2
  ) IS
    v_count                       NUMBER;
  BEGIN
    -- Insertar en CAPATAZ_HIPODROMO si no existe
    BEGIN
      INSERT INTO CAPATAZ_HIPODROMO (TURNO, TIP_CAPATAZHIPODROMO)
      SELECT p_turno, p_tip_capatazhipodromo
      FROM dual
      WHERE NOT EXISTS (
        SELECT 1
        FROM CAPATAZ_HIPODROMO
        WHERE TIP_CAPATAZHIPODROMO = p_tip_capatazhipodromo
      );
    EXCEPTION
      WHEN OTHERS THEN
        -- Captura cualquier error y muestra el mensaje
        RAISE_APPLICATION_ERROR(-20001, 'Error al insertar en CAPATAZ_HIPODROMO: ' || SQLERRM);
    END;

    -- Insertar en OPERARIOS_HIPODROMO si no existe o realizar actualización
    SELECT COUNT(*)
    INTO v_count
    FROM OPERARIOS_HIPODROMO
    WHERE TIP_OPERARIOHIPODROMO = p_tip_operariohipodromo
      AND TIP_CAPATAZHIPODROMO = p_tip_capatazhipodromo;

    IF v_count = 0 THEN
      BEGIN
        INSERT INTO OPERARIOS_HIPODROMO (PAUSA, DESTINOS_SALIDA, TIP_OPERARIOHIPODROMO, TIP_CAPATAZHIPODROMO)
        VALUES (p_pausa, p_destinos_salida, p_tip_operariohipodromo, p_tip_capatazhipodromo);
      EXCEPTION
        WHEN OTHERS THEN
          -- Captura cualquier error y muestra el mensaje
          RAISE_APPLICATION_ERROR(-20002, 'Error al insertar en OPERARIOS_HIPODROMO: ' || SQLERRM);
      END;
    ELSE
      BEGIN
        UPDATE OPERARIOS_HIPODROMO
        SET PAUSA = p_pausa,
            DESTINOS_SALIDA = p_destinos_salida
        WHERE TIP_OPERARIOHIPODROMO = p_tip_operariohipodromo
          AND TIP_CAPATAZHIPODROMO = p_tip_capatazhipodromo;
      EXCEPTION
        WHEN OTHERS THEN
          -- Captura cualquier error y muestra el mensaje
          RAISE_APPLICATION_ERROR(-20003, 'Error al actualizar en OPERARIOS_HIPODROMO: ' || SQLERRM);
      END;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20201, 'Error general en la transacción: ' || SQLCODE || ' - ' || SQLERRM);
  END GRABAR;

  PROCEDURE BORRAR (
    p_tip_operariohipodromo NUMBER,
    p_tip_capatazhipodromo NUMBER
  ) IS
    v_count NUMBER;
  BEGIN
    -- Borrar filas de OPERARIOS_HIPODROMO
    DELETE FROM OPERARIOS_HIPODROMO 
    WHERE TIP_OPERARIOHIPODROMO = p_tip_operariohipodromo
      AND TIP_CAPATAZHIPODROMO = p_tip_capatazhipodromo;

    -- Comprobar si existen otras filas en OPERARIOS_HIPODROMO para el mismo TIP_CAPATAZHIPODROMO
    SELECT COUNT(*)
    INTO v_count
    FROM OPERARIOS_HIPODROMO
    WHERE TIP_CAPATAZHIPODROMO = p_tip_capatazhipodromo;

    -- Si no existen, intentar borrar la fila correspondiente de CAPATAZ_HIPODROMO
    IF v_count = 0 THEN
      DELETE FROM CAPATAZ_HIPODROMO WHERE TIP_CAPATAZHIPODROMO = p_tip_capatazhipodromo;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20203, 'Error general en la transacción: ' || SQLCODE || ' - ' || SQLERRM);
  END BORRAR;

  PROCEDURE CONSULTAR (
    p_tip_operariohipodromo NUMBER
  ) AS
    v_pausa VARCHAR2(20);
    v_destinos_salida VARCHAR2(50);
    v_tip_capatazhipodromo NUMBER;
    v_turno VARCHAR2(20);
  BEGIN
    -- Obtener datos de OPERARIOS_HIPODROMO y CAPATAZ_HIPODROMO
    SELECT o.PAUSA, o.DESTINOS_SALIDA, o.TIP_CAPATAZHIPODROMO, c.TURNO
    INTO v_pausa, v_destinos_salida, v_tip_capatazhipodromo, v_turno
    FROM OPERARIOS_HIPODROMO o
    INNER JOIN CAPATAZ_HIPODROMO c ON o.TIP_CAPATAZHIPODROMO = c.TIP_CAPATAZHIPODROMO
    WHERE o.TIP_OPERARIOHIPODROMO = p_tip_operariohipodromo;

    -- Aquí puedes manejar los resultados. Por ejemplo, puedes imprimirlos:
    DBMS_OUTPUT.PUT_LINE('PAUSA: ' || v_pausa);
    DBMS_OUTPUT.PUT_LINE('DESTINOS_SALIDA: ' || v_destinos_salida);
    DBMS_OUTPUT.PUT_LINE('TIP_CAPATAZHIPODROMO: ' || v_tip_capatazhipodromo);
    DBMS_OUTPUT.PUT_LINE('TURNO: ' || v_turno);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No se encontró ningún operario con TIP_OPERARIOHIPODROMO = ' || p_tip_operariohipodromo);
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20202, 'Error general en la transacción: ' || SQLCODE || ' - ' || SQLERRM);
  END CONSULTAR;

  PROCEDURE MADRE (
    p_modo                       VARCHAR2,
    p_tip_operariohipodromo      NUMBER,
    p_tip_capatazhipodromo       NUMBER,
    p_pausa                      VARCHAR2,
    p_destinos_salida            VARCHAR2,
    p_turno                      VARCHAR2
  ) AS
    v_count NUMBER;
  BEGIN
    IF p_modo = 'LECTURA' THEN
      CONSULTAR(p_tip_operariohipodromo);
    ELSIF p_modo = 'ESCRITURA' THEN
      IF p_pausa IS NULL AND p_destinos_salida IS NULL AND p_turno IS NULL THEN
        BORRAR(p_tip_operariohipodromo, p_tip_capatazhipodromo);
      ELSE
        GRABAR(p_tip_operariohipodromo, p_tip_capatazhipodromo, p_pausa, p_destinos_salida, p_turno);
      END IF;
    ELSIF p_modo = 'BORRAR' THEN
      BORRAR(p_tip_operariohipodromo, p_tip_capatazhipodromo);
    ELSE
      RAISE_APPLICATION_ERROR(-20204, 'Modo inválido: ' || p_modo);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20205, 'Error general en la transacción: ' || SQLCODE || ' - ' || SQLERRM);
  END MADRE;

END PK_OPERARIOS;





