#
# Prueba de cursor en esquema con FOR.
#
BEGIN
   FOR curolc IN
   (
      SELECT * FROM TP_OLC_LOG WHERE FECHATRANSACCION = '20210625'
   )
   LOOP
      DBMS_OUTPUT.PUT_LINE('Transacción: ' || curolc.CODIGOTRANSACCION || 
                               ',  Fecha: ' || TO_CHAR(TO_DATE(curolc.FECHATRANSACCION, 'YYYYMMDD'), 'DD/MM/YYYY'));
   END LOOP;
END;
/


#
# Ejemplo de cursor en esquema declarando un cursor y su variable tipo ROW (sin usar FOR LOOP).
# Ejemplo de uso de funcion TO_DATE para convertir un campo VARCHAR2 a DATE (indicando un formato de fecha).
# Ejemplo de uso de funcion TO_CHAR (indicando un formato de salida).
#
DECLARE
   -- Prueba de cursor sobre la tabla OLC Log.
   CURSOR curlog
   IS
      SELECT * FROM TP_OLC_LOG WHERE FECHATRANSACCION = '20210625';
   
   -- Variable que contendrá una fila de la tabla OLC Log.
   olcrow   TP_OLC_LOG%ROWTYPE;
BEGIN
   -- Abrimos el cursor.
   OPEN curlog;

   -- Itera a través del cursor.   
   LOOP
      FETCH curlog INTO olcrow;
      
      EXIT WHEN curlog%NOTFOUND;
      
      DBMS_OUTPUT.PUT_LINE('Transacción: ' || olcrow.CODIGOTRANSACCION || 
                               ',  Fecha: ' || TO_CHAR(TO_DATE(olcrow.FECHATRANSACCION, 'YYYYMMDD'), 'DD/MM/YYYY'));
   END LOOP;
   
   CLOSE curlog;
END;
/


# Otro ejemplo
DECLARE
   varcomer   VARCHAR2(15);
BEGIN
   /*
   * Consulta el código de comercio.
   */
   SELECT COMERCIO INTO varcomer FROM TP_OLC_LOG
   WHERE CODIGOTRANSACCION = '350000' AND FECHATRANSACCION = '20210712';

   -- Imprime el código de comercio.
   DBMS_OUTPUT.PUT_LINE('El código del comercio es: ' || varcomer);
END;
/


# Otro ejemplo
DECLARE
   varmonto   NUMBER(12,2);
BEGIN
   -- Captura el monto.
   SELECT monto INTO varmonto FROM TP_OLC_LOG
   WHERE FECHATRANSACCION = '20210712' AND HORATRANSACCION = '134230';
   
   -- Muestra el monto de la transacción.
   DBMS_OUTPUT.PUT_LINE('El monto de la transacción es: ' || varmonto);
END;
/


# Otro ejemplo
SELECT COUNT(*) TOTAL_TRX, SUM(MONTO) FROM TP_OLC_LOG
                                      WHERE TIPOMENSAJE = '200' AND CODIGORESPUESTA = '00' AND REVERSAL = 0 AND 
                                            (CODIGOTRANSACCION >= '940000' AND CODIGOTRANSACCION <= '959999') AND 
                                            (FECHATRANSACCION BETWEEN '20210625' AND '20210625') AND 
                                            BIN_ACREEDOR IN (0009);



#
# Ejemplo de uso de funcion de agregado y GROUP BY
#
SELECT FECHATRANSACCION, SUM(MONTO) SubTotal FROM TP_OLC_LOG GROUP BY FECHATRANSACCION ORDER BY FECHATRANSACCION DESC;


#
# Ejemplo de una variable consecutivo con relleno de ceros a la izquierda a traves de la funcion TO_CHAR.
# Ejemplo de uso de sentencia CASE WHEN en una consulta SQL y dentro de un bloque PL/SQL.
#
DECLARE
   secuencia   NUMBER := 1;
BEGIN
   FOR curOlc IN (SELECT FECHATRANSACCION, CODIGOTRANSACCION, 
                         (CASE CODIGO_RESPUESTA_EXT 
                          WHEN '56' THEN 'ES RECHAZO'
                          WHEN '402' THEN 'TIMEOUT'
                          ELSE 'NO IDENTIFICADO'
                          END) RESPUESTA
                  FROM TP_OLC_LOG)
   LOOP
      BEGIN
         CASE
         WHEN curOlc.FECHATRANSACCION = '20210615' THEN
            -- Usa la funcion TO_CHAR para rellenar con ceros a la izquierda de forma automatica.
            DBMS_OUTPUT.PUT_LINE('Secuencia: ' || TO_CHAR(secuencia, '00000000') || 
                                     ',   Transacción: ' || curOlc.CODIGOTRANSACCION || 
                                     ',   Fecha: ' || TO_DATE(curOlc.FECHATRANSACCION, 'YYYYMMDD') || 
                                     ',   Respuesta: ' || curOlc.RESPUESTA);
            secuencia := secuencia + 1;
         ELSE
            NULL;
         END CASE;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR!');
      END;
   END LOOP;
END;


#
# Ejemplo de funcion DECODE (tiene la misma funcionalidad del IF ELSE IF y ELSE)
#
SELECT CODIGOTRANSACCION, 
       FECHATRANSACCION, 
       HORATRANSACCION, 
       DECODE(CODIGOTRANSACCION,940000, 'PAGO', 
                                350000, 'CONSULTA', 
                                'NO EXISTE') TIPO 
FROM TP_OLC_LOG;


## Ejemplo de uso de Oracle SQL como calculadora (a través de la tabla dummy DUAL).
SELECT ((200 * 4) / 10) FROM DUAL;


## Ejemplo de la función Módulo de la división.
SELECT MOD(10, 4) FROM DUAL;


## Ejemplo de la función Potencia.
SELECT POWER(2,10) kilobyte, POWER(2,20) megabyte, POWER(2,30) gigabyte, POWER(2,40) terabyte FROM DUAL;


## Ejemplo de la función Logarítmo: LOG(m, n) donde m es la base y n el exponente.
SELECT LOG(10, 100) FROM DUAL;


## Ejemplo de la función trigonométrica SENO (las funciones trigonométricas asumen que el valor está en radianes!).
## Por tal motivo,primero hay que convertirlo a grados usando la relación,
##
##                                                                        Radianes = Grados * (Pi / 180)
## Oracle no posee una función que devuelva el valor de Pi.
## Pero podemos simularlo usando la función Arco-coseno pasandole como argumento -1. 
SELECT SIN(30 * (ACOS(-1) / 180)) FROM DUAL;


## Ejemplo de las funciones de redondeo (por arriba y por abajo) y de Truncamiento.
SELECT CEIL(72.445), FLOOR(72.445), ROUND(72.49999), ROUND(72.5), ROUND(72.50001), TRUNC(72.0909, 1), TRUNC(72.0909, 2) FROM DUAL;


## Ejemplo de cálculo de funciones Promedio, Media, Moda y Desviación Estándar.
SELECT AVG(MONTO) AS PROMEDIO, MEDIAN(MONTO) AS MEDIA, STATS_MODE(MONTO) AS MODA, STDDEV(MONTO) AS DESV_ESTANDAR FROM TP_OLC_LOG;


## Simulando la función Promedio usando solo las funciones SUM y COUNT.
SELECT AVG(MONTO) AS PROMEDIO_1, (SUM(MONTO) / COUNT(*)) AS PROMEDIO_2 FROM TP_OLC_LOG;


## Dos formas de hacer una concatenación: usando la función CONCAT y luego usando '||'.
SELECT CONCAT(CONCAT(NOM_CONEXION, ' '), HOST_NAME) AS FULL_NAME FROM CIERREADM.TP_CONEXION;

SELECT (NOM_CONEXION || ' ' || HOST_NAME) AS FULL_NAME FROM CIERREADM.TP_CONEXION;


-- Extraer un substring de un string.
SUBSTR(<variable o nombre de columna de una tabla>, 5, 2)


/*
 * Ejemplo de uso de la función SUBSTR para extraer una parte de un string (en este caso se usa para añadir los ":" a la hora.
 */
DECLARE
   conta DECIMAL(10) := 1;
BEGIN
   FOR curOlc IN (SELECT * FROM TP_OLC_LOG WHERE FECHATRANSACCION = '20210625' ORDER BY FECHATRANSACCION ASC, HORATRANSACCION ASC)
   LOOP
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(conta, '0000000000') || ',   ' || curOlc.CODIGOTRANSACCION || ',   ' || TO_CHAR(TO_DATE(curOlc.FECHATRANSACCION, 'YYYYMMDD'), 'DD-MM-YYYY') || ',   ' || SUBSTR(curOlc.HORATRANSACCION, 1, 2) || ':' || SUBSTR(curOlc.HORATRANSACCION, 3, 2) || ':' || SUBSTR(curOlc.HORATRANSACCION, 5, 2));

      conta := conta + 1;
   END LOOP;
END;


#
# Otro ejemplo de cursor incluyendo las funciones DECODE y TO_DATE dentro de la consulta.
#
DECLARE
   CURSOR   curOlc IS SELECT CODIGOTRANSACCION, TO_DATE(FECHATRANSACCION, 'YYYYMMDD') AS FECHA, DECODE(CODIGOTRANSACCION, 940000, 'PAGO', 350000, 'CONSULTA', 'ERROR') AS OPERACION FROM TP_OLC_LOG ORDER BY FECHA DESC;
   
   curRow   curOlc%ROWTYPE;
BEGIN
   OPEN curOlc;
   
   LOOP
      FETCH curOlc INTO curRow;
      
      EXIT WHEN curOlc%NOTFOUND;
      
      DBMS_OUTPUT.PUT_LINE('Transacción: ' || curRow.CODIGOTRANSACCION || ',   Fecha: ' || TO_CHAR(curRow.FECHA, 'DD-MM-YYYY') || ',   Tipo de operación: ' || curRow.OPERACION);
   END LOOP;
   
   CLOSE curOlc;
END;


/*
 * Ejemplo de manejo de tipo de datos TIMESTAMP. Ejemplo de uso de la función EXTRACT para extraer componentes 
 * de la Fecha Hora.
 */
DECLARE
   finici  NUMBER(10,2);
   ffinal  NUMBER(10,2);
   difere  NUMBER(10,2);
   fecha   TIMESTAMP := SYSDATE;
BEGIN
   finici := EXTRACT(SECOND FROM SYSTIMESTAMP);
   FOR contador IN 1..1000
   LOOP
      DBMS_OUTPUT.PUT_LINE(' ');
      DBMS_OUTPUT.PUT_LINE('Fecha: ' || TO_CHAR(fecha, 'DD') || ' de ' || TO_CHAR(fecha, 'Month') || TO_CHAR(fecha, 'YYYY'));
      DBMS_OUTPUT.PUT_LINE('Hora: ' || TO_CHAR(fecha, 'HH:MM:SSSSSSS'));
   END LOOP;

   ffinal:= EXTRACT(SECOND FROM SYSTIMESTAMP);
   difere := ffinal - finici;

   DBMS_OUTPUT.PUT_LINE('finici: ' || finici);
   DBMS_OUTPUT.PUT_LINE('ffinal: ' || ffinal);
   DBMS_OUTPUT.PUT_LINE('Diferencia: ' || difere);
END;

