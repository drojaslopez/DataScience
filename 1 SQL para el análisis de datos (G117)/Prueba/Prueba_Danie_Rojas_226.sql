--Prueba SQL
--Daniel Rojas Lopez

--Pregunta 1 a la 3

/* 
1. Revisa el tipo de relación y crea el modelo correspondiente. Respeta las claves
primarias, foráneas y tipos de datos.
(1 punto)
2. Inserta 5 películas y 5 tags; la primera película debe tener 3 tags asociados, la
segunda película debe tener 2 tags asociados.
(1 punto)
3. Cuenta la cantidad de tags que tiene cada película. Si una película no tiene tags debe
mostrar 0. */

CREATE TABLE Peliculas (
    id_Peliculas SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    anno INTEGER NOT NULL
);

CREATE TABLE Tags (
    id_Tag SERIAL PRIMARY KEY,
    tag VARCHAR(32) NOT NULL
);

CREATE TABLE Pelicula_Tags (
    pelicula_id BIGINT,
    tag_id BIGINT,
    CONSTRAINT fk_pelicula
        FOREIGN KEY(pelicula_id) 
        REFERENCES Peliculas(id_Peliculas)
        ON DELETE CASCADE,
    CONSTRAINT fk_tag
        FOREIGN KEY(tag_id) 
        REFERENCES Tags(id_Tag)
        ON DELETE CASCADE   
);


INSERT INTO Peliculas (nombre, anno) 
VALUES  ('Jurassic Park', 1993),
        ('Inception', 2010),
        ('Blade Runner', 1982),
        ('Dune', 2021),
        ('Interstellar', 2014);


INSERT INTO Tags (tag) 
VALUES  ('Ciencia Ficción'),
        ('Dinosaurios'),
        ('Futurista'),
        ('Viajes en el Espacio'),
        ('Sueños');



INSERT INTO Pelicula_Tags (pelicula_id, tag_id) 
VALUES (1, 1),(1, 2),(1, 3),(2, 1),(2, 5),(3, 3),(4, 1),(4, 4);


SELECT
  pe.nombre  nombre,
  COUNT(pt.tag_id) AS cantidad_tags
FROM
  Peliculas pe
LEFT JOIN
  Pelicula_Tags pt ON pe.id_Peliculas = pt.pelicula_id
GROUP BY
  pe.id_Peliculas, pe.nombre
ORDER BY
  pe.id_Peliculas;


--Pregunta 4 al 10

/* Crea las tablas correspondientes respetando los nombres, tipos, claves primarias y
foráneas y tipos de datos.
(1 punto)*/

CREATE TABLE Preguntas (
  id_pregunta SERIAL PRIMARY KEY,
  pregunta VARCHAR(255) NOT NULL,
  respuesta_correcta VARCHAR NOT NULL
);


CREATE TABLE Usuarios (
  id_Usuario SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  edad INTEGER NOT NULL
);

CREATE TABLE Respuestas (
  id_Respuesta SERIAL PRIMARY KEY,    
  nombre VARCHAR(255) NOT NULL,
  usuario_id BIGINT,
  pregunta_id BIGINT,

  CONSTRAINT fk_usuario
      FOREIGN KEY(usuario_id) 
      REFERENCES Usuarios(id_usuario)
      ON DELETE CASCADE,
  CONSTRAINT fk_pregunta
      FOREIGN KEY(pregunta_id) 
      REFERENCES Preguntas(id_pregunta)
      ON DELETE CASCADE   
);

/*5. Agrega 5 usuarios y 5 preguntas.*/

INSERT INTO Usuarios (nombre ,edad) 
VALUES  ('Elena', 1),
        ('Carolina', 36),
        ('Daniel', 36),
        ('Coni', 13),
        ('Renato', 5);


INSERT INTO Preguntas (pregunta, respuesta_correcta) 
VALUES  ('¿Cuál es la capital de Francia?', 'París'),
        ('¿En qué año comenzó la Segunda Guerra Mundial?', '1939'),
        ('¿Cuál es el elemento químico más abundante en la corteza terrestre?', 'Oxígeno'),
        ('¿Quién escribió "Cien años de soledad"?', 'Gabriel García Márquez'),
        ('¿Cuál es el océano más grande del mundo?', 'Pacífico');


/*a. La primera pregunta debe estar respondida correctamente dos veces, por dos
usuarios diferentes.*/
INSERT INTO Respuestas (nombre, usuario_id, pregunta_id) 
VALUES  ('París', 1, 1),
        ('París', 2, 1),
        ('1939', 3, 2),
        ('Berlín', 4, 3),
        ('Shakespeare', 5, 4);




/*b. La segunda pregunta debe estar contestada correctamente solo por un
usuario.*/INSERT INTO Respuestas (nombre, usuario_id, pregunta_id) 
VALUES  ('1939', 1, 2),
        ('Nitrógeno', 2, 3),
        ('Julio Cortázar', 3, 4),
        ('Atlántico', 4, 5);



/*c. Las otras dos preguntas deben tener respuestas incorrectas.
Contestada correctamente significa que la respuesta indicada en la tabla respuestas
es exactamente igual al texto indicado en la tabla de preguntas.
*/
INSERT INTO Respuestas (nombre, usuario_id, pregunta_id) 
VALUES  ('Roma', 5, 1),
        ('1945', 4, 2),
        ('Carbono', 3, 3),
        ('Jorge Luis Borges', 2, 4),
        ('Índico', 1, 5);



/*6. Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la
pregunta).
(1 punto)*/
SELECT
  u.nombre AS nombre_usuario,
  COUNT(r.id_Respuesta) AS respuestas_correctas_totales
FROM
  Usuarios u
JOIN
  Respuestas r ON u.id_Usuario = r.usuario_id
JOIN
  Preguntas p ON r.pregunta_id = p.id_pregunta
WHERE
  r.nombre = p.respuesta_correcta
GROUP BY
  u.id_Usuario, u.nombre
ORDER BY
  u.id_Usuario;


/*7. Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios respondieron
correctamente.
(1 punto)*/

SELECT
  p.pregunta,
  COUNT(DISTINCT r.usuario_id) AS usuarios_respondieron_correctamente
FROM
  Preguntas p
LEFT JOIN
  Respuestas r ON p.id_pregunta = r.pregunta_id AND p.respuesta_correcta = r.nombre
GROUP BY
  p.id_pregunta, p.pregunta
ORDER BY
  p.id_pregunta;



/*
8. Implementa un borrado en cascada de las respuestas al borrar un usuario. Prueba la
implementación borrando el primer usuario.
(1 punto)
*/

DELETE FROM Usuarios WHERE id_Usuario = 1;

/* 9. Crea una restricción que impida insertar usuarios menores de 18 años en la base de
datos.

*/

Select * from usuarios;
delete  from respuestas;
delete from usuarios;


ALTER TABLE Usuarios
ADD CONSTRAINT Usuarios_edad 
CHECK (edad >= 18);

--Caso que fallara por el nuevo check
INSERT INTO Usuarios (nombre ,edad) 
VALUES  ('Elena', 1)

--caso que volvera a pasar 
INSERT INTO Usuarios (nombre ,edad) 
VALUES  ('Elena', 19)


Select * from usuarios;

/*
10. Altera la tabla existente de usuarios agregando el campo email. Debe tener la
restricción de ser único.
 */
ALTER TABLE Usuarios
ADD COLUMN email VARCHAR(255) UNIQUE;

select * from usuarios;

INSERT INTO Usuarios (nombre ,edad,email) 
VALUES  ('Carolina', 36, 'PruebaCorreo@test.com');
INSERT INTO Usuarios (nombre ,edad, email) 
VALUES  ('Daniel', 36, 'PruebaCorreo@test.com')

INSERT INTO Usuarios (nombre ,edad, email) 
VALUES  ('Coni', 20, 'PruebaCorreo2@test.com')

