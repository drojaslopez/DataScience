-- Reemplaza el LOOP anterior por este nuevo flujo basado en tabla
DECLARE
    -- Definimos un cursor para leer solo los registros pendientes (documentoRescatado = 0)
    -- Usamos FOR UPDATE para bloquear las filas mientras las procesamos (evita colisiones)
    CURSOR c_pendientes IS
        SELECT rut, folio, ROWID as fila_id
        FROM   LOG_PROCESAMIENTO_DOCS
        WHERE  documentoRescatado = 0;

BEGIN
    -- El FOR LOOP abre, itera y cierra el cursor automáticamente
    FOR r_pendiente IN c_pendientes LOOP
        
        -- Asignamos los valores de la tabla a tus variables existentes
        -- to_char asegura compatibilidad si tus variables v_rut y v_folio son VARCHAR2
        v_rut   := TO_CHAR(r_pendiente.rut);
        v_folio := TO_CHAR(r_pendiente.folio);

        DBMS_OUTPUT.PUT_LINE('Procesando desde tabla - RUT: ' || v_rut || ' | Folio: ' || v_folio);
        
        -- Inicializar variables de control por cada iteración
        v_blob := NULL;
        v_len  := 0;

        -- =========================================================================
        -- PASO 1: CONSULTAR EL BLOB EN LA BASE DE DATOS
        -- =========================================================================
        BEGIN
            SELECT ei.DOCUMENTOELECTRONICO AS PDF_FIRMADO
            INTO   v_blob
            FROM   ADMECO.wave w,
                   ADMECO.RUTWAVEINDEX r,
                   ADMECO.ECODOCELECTRONICOINDEX ei
            WHERE  w.ECOWAVEID  = r.WAVEID
            AND    ei.ECOID     = w.ECOID
            AND    w.STATUS     = 'Closed'
            AND    r.RUTCONECTADO = TO_NUMBER(v_rut)
            AND    REPLACE(SUBSTR(ei.codigodocumento, INSTR(ei.CODIGODOCUMENTO, ',', 1) + 1, 10), ']') = TO_NUMBER(v_folio);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('No encontrado en BD: ' || v_rut || ' - ' || v_folio);
                -- Opcional: Aquí podrías actualizar la tabla a un estado de error (ej: 9) si no existe el PDF
                CONTINUE; 
                
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error inesperado en consulta para RUT ' || v_rut || ': ' || SQLERRM);
                CONTINUE;
        END;

        -- =========================================================================
        -- PASO 2: VALIDACIONES DEL BLOB
        -- =========================================================================
        IF v_blob IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('BLOB vacío: ' || v_rut || ' - ' || v_folio);
            CONTINUE;
        END IF;

        v_len := DBMS_LOB.GETLENGTH(v_blob);

        IF v_len = 0 THEN
            DBMS_OUTPUT.PUT_LINE('BLOB sin datos (0 bytes): ' || v_rut || ' - ' || v_folio);
            CONTINUE;
        END IF;

        -- =========================================================================
        -- PASO 3: CREAR ARCHIVO FÍSICO DE SALIDA (PDF)
        -- =========================================================================
        BEGIN
            v_filename := v_rut || ' - ' || v_folio || '.pdf';
            
            -- Abrir archivo en modo Escritura Binaria
            v_file_out := UTL_FILE.FOPEN('TMP_DIR', v_filename, 'wb');
            
            v_pos := 1;
            WHILE v_pos <= v_len LOOP
                DBMS_LOB.READ(v_blob, v_amount, v_pos, v_buffer);
                UTL_FILE.PUT_RAW(v_file_out, v_buffer, TRUE);
                v_pos := v_pos + v_amount;
            END LOOP;

            UTL_FILE.FCLOSE(v_file_out);
            DBMS_OUTPUT.PUT_LINE('Generado exitosamente: ' || v_filename);

            -- =====================================================================
            -- PASO 4: ACTUALIZAR ESTADO EN LA TABLA (ÉXITO)
            -- =====================================================================
            -- Usamos el ROWID (fila_id) porque es la forma más rápida y directa de actualizar en Oracle
            UPDATE LOG_PROCESAMIENTO_DOCS
            SET    documentoRescatado = 1
            WHERE  ROWID = r_pendiente.fila_id;
            
            -- Confirmamos la transacción de este registro y liberamos el bloqueo de la fila
            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error al escribir archivo PDF o actualizar tabla para ' || v_filename || ': ' || SQLERRM);
                
                -- Si falla la escritura, deshacemos los cambios de esta iteración (libera el bloqueo)
                ROLLBACK; 
                
                IF UTL_FILE.IS_OPEN(v_file_out) THEN
                    UTL_FILE.FCLOSE(v_file_out);
                END IF;
        END;

    END LOOP;
END;
/