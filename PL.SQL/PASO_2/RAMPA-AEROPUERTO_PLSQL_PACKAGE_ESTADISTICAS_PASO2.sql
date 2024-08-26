--PAQUETE ESTADISTICAS--


CREATE OR REPLACE PACKAGE Estadisticas AS
  PROCEDURE EstadisticaEquipajes;
  PROCEDURE BuscadorPersonal(p_tip_personal NUMBER DEFAULT NULL, p_pcp VARCHAR2 DEFAULT NULL, p_nombre VARCHAR2 DEFAULT NULL, p_apellido VARCHAR2 DEFAULT NULL);
  PROCEDURE EstadisticaIncidenciasParam(p_tip_personal NUMBER);
  PROCEDURE EstadisticaIncidenciasTotal;
  PROCEDURE EstadisticaIncidenciasDinamica(p_tip_personal IN NUMBER, p_total_incidencias OUT NUMBER);
END Estadisticas;
/

CREATE OR REPLACE PACKAGE BODY Estadisticas AS
  PROCEDURE EstadisticaEquipajes AS 
    v_equipaje EQUIPAJES%ROWTYPE;
    v_equipaje_especial EQUIPAJE_ESPECIAL%ROWTYPE;
    
    CURSOR c_equipajes IS
      SELECT *
      FROM EQUIPAJES;
    
    v_total_peso NUMBER := 0;

  BEGIN
    OPEN c_equipajes;

    LOOP
      FETCH c_equipajes INTO v_equipaje;
      EXIT WHEN c_equipajes%NOTFOUND;
    
      BEGIN
        SELECT TAMAÑO, CONTENIDO, PESO, BN
        INTO v_equipaje_especial
        FROM EQUIPAJE_ESPECIAL
        WHERE BN = v_equipaje.BN;

        v_total_peso := v_total_peso + v_equipaje.PESO + v_equipaje_especial.PESO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_total_peso := v_total_peso + v_equipaje.PESO;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20003, 'Error al procesar el equipaje con BN: ' || v_equipaje.BN || ', Error: ' || SQLERRM);
      END;
    END LOOP;
    
    CLOSE c_equipajes;
    
    IF v_total_peso = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'No se encontraron datos.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('El peso total de los equipajes es: ' || v_total_peso);
    END IF;
    
  EXCEPTION 
    WHEN OTHERS THEN 
      RAISE_APPLICATION_ERROR(-20002, 'Error inesperado: ' || SQLERRM);
  END EstadisticaEquipajes;

  PROCEDURE BuscadorPersonal(p_tip_personal NUMBER DEFAULT NULL, p_pcp VARCHAR2 DEFAULT NULL, p_nombre VARCHAR2 DEFAULT NULL, p_apellido VARCHAR2 DEFAULT NULL) IS
    CURSOR c_buscador IS
      SELECT TIP_PERSONAL, PCP, NOMBRE, APELLIDO
      FROM PERSONAL
      WHERE (TIP_PERSONAL = p_tip_personal OR p_tip_personal IS NULL)
        AND (PCP = p_pcp OR p_pcp IS NULL)
        AND (NOMBRE = p_nombre OR p_nombre IS NULL)
        AND (APELLIDO = p_apellido OR p_apellido IS NULL);
    
    v_row c_buscador%ROWTYPE;
    v_count NUMBER := 0;

  BEGIN
    OPEN c_buscador;
    
    LOOP
      FETCH c_buscador INTO v_row;
      EXIT WHEN c_buscador%NOTFOUND;
      
      v_count := v_count + 1;
      
      DBMS_OUTPUT.PUT_LINE('Resultado ' || v_count || ':');
      DBMS_OUTPUT.PUT_LINE('TIP_PERSONAL: ' || v_row.TIP_PERSONAL);
      DBMS_OUTPUT.PUT_LINE('PCP: ' || v_row.PCP);
      DBMS_OUTPUT.PUT_LINE('NOMBRE: ' || v_row.NOMBRE);
      DBMS_OUTPUT.PUT_LINE('APELLIDO: ' || v_row.APELLIDO);
    END LOOP;

    CLOSE c_buscador;

    IF v_count = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'No se encontraron resultados');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002, 'Error inesperado: ' || SQLERRM);
  END BuscadorPersonal;

  PROCEDURE EstadisticaIncidenciasParam(p_tip_personal NUMBER) AS 
    v_total_incidencias NUMBER := 0;
    
    CURSOR c_incidencias IS
      SELECT *
      FROM ABRIR
      WHERE TIP_PERSONAL = p_tip_personal;
    
  BEGIN
    FOR v_incidencia IN c_incidencias LOOP
      v_total_incidencias := v_total_incidencias + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('El total de incidencias para el TIP_PERSONAL ' || p_tip_personal || ' es: ' || v_total_incidencias);
  EXCEPTION 
    WHEN OTHERS THEN 
      RAISE_APPLICATION_ERROR(-20001, 'Error inesperado: ' || SQLERRM);
  END EstadisticaIncidenciasParam;

  PROCEDURE EstadisticaIncidenciasTotal AS 
    v_total_incidencias NUMBER := 0;
    v_tip_personal NUMBER;
    
    CURSOR c_tipos IS
      SELECT DISTINCT TIP_PERSONAL
      FROM PERSONAL;
      
    CURSOR c_incidencias(p_tip_personal NUMBER) IS
      SELECT *
      FROM ABRIR
      WHERE TIP_PERSONAL = p_tip_personal;

  BEGIN
    FOR v_tipo IN c_tipos LOOP
      FOR v_incidencia IN c_incidencias(v_tipo.TIP_PERSONAL) LOOP
        v_total_incidencias := v_total_incidencias + 1;
      END LOOP;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('El total de incidencias es: ' || v_total_incidencias);
  EXCEPTION 
    WHEN OTHERS THEN 
      RAISE_APPLICATION_ERROR(-20001, 'Error inesperado: ' || SQLERRM);
  END EstadisticaIncidenciasTotal;

  PROCEDURE EstadisticaIncidenciasDinamica(p_tip_personal IN NUMBER, p_total_incidencias OUT NUMBER) AS 
    v_sql VARCHAR2(1000);
  BEGIN
    -- Construyendo la consulta SQL de manera dinámica
    v_sql := 'SELECT COUNT(*) FROM ABRIR WHERE TIP_PERSONAL = :tip_personal';

    -- Ejecutando la consulta SQL de manera dinámica con EXECUTE IMMEDIATE
    EXECUTE IMMEDIATE v_sql INTO p_total_incidencias USING p_tip_personal;
  EXCEPTION 
    WHEN OTHERS THEN 
    RAISE_APPLICATION_ERROR(-20002, 'Error inesperado: ' || SQLERRM);
  END EstadisticaIncidenciasDinamica;

END Estadisticas;
/
