--Pregunta 1
/*USUARIOS*/
CREATE TABLE Usuarios (
    id_Usuario SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    rol VARCHAR(255) NOT NULL
);

INSERT INTO Usuarios(id_Usuario, email, nombre, rol)
values
  (1,'juan.perez@example.com', 'Juan Perez', 'administrador'),
  (2,'maria.gomez@example.com', 'Maria Gomez', 'usuario'),
  (3,'carlos.lopez@example.com','Carlos Lopez','usuario'),
  (4,'ana.martinez@example.com','Ana Martinez','usuario'),
  (5,'luis.sanchez@example.com', 'Luis Sanchez','administrador');

Select * from Usuarios;


/*POSTS*/
CREATE TABLE Posts (
  id_Post SERIAL PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  contenido TEXT NOT NULL,
  fecha_creacion TIMESTAMP ,
  fecha_actualizacion TIMESTAMP ,
  destacado BOOLEAN DEFAULT FALSE,
  usuario_id BIGINT ,
  CONSTRAINT fk_usuario
      FOREIGN KEY(usuario_id) 
      REFERENCES Usuarios(id_Usuario)
      ON DELETE CASCADE
);



INSERT INTO Posts (titulo, contenido, fecha_creacion, fecha_actualizacion, destacado, usuario_id) VALUES
('Primeros pasos con Spring Boot', 'En esta guía, exploraremos cómo iniciar un proyecto con Spring Boot...', '2024-07-01 10:00:00', '2024-07-01 10:00:00', TRUE, 1),
('Despliegue de Node.js con Docker', 'Aprende a contenerizar tu aplicación de Node.js usando Docker y Docker Compose.', '2024-07-05 14:30:00', '2024-07-06 09:15:00', TRUE, 2),
('Diseño de APIs REST: Principios clave', 'Un vistazo a los principios SOLID aplicados al diseño de APIs RESTful.', '2024-07-10 18:00:00', '2024-07-10 18:00:00', FALSE, 1),
('Gestión de dependencias en proyectos Java', 'Una comparativa entre Maven y Gradle para gestionar dependencias.', '2024-07-15 08:45:00', '2024-07-15 08:45:00', FALSE, 3),
('Debugging en TypeScript', 'Consejos y herramientas para depurar tu código de TypeScript de manera eficiente.', '2024-07-20 21:20:00', '2024-07-21 11:00:00', FALSE, NULL);


select * from posts;


/*COMENTARIOS*/
CREATE TABLE Comentarios (
    id_Comentario SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT,
    post_id BIGINT,
    CONSTRAINT fk_usuario
        FOREIGN KEY(usuario_id) 
        REFERENCES Usuarios(id_Usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_post
        FOREIGN KEY(post_id) 
        REFERENCES Posts(id_Post)
        ON DELETE CASCADE
);

INSERT INTO Comentarios (contenido, fecha_creacion, usuario_id, post_id) VALUES
('Excelente artículo, ¡me ayudó a configurar mi primer proyecto de Spring Boot rápidamente!', '2025-07-01 12:30:00', 1, 1),
('El tema de despliegue con Docker es crucial, ¿podrías profundizar en el uso de Docker Compose?', '2025-07-06 10:15:00', 2, 1),
('Muy buen resumen de los principios SOLID. ¡Justo lo que necesitaba!', '2025-07-11 19:45:00', 3, 1),
('Me gusta más Gradle por su flexibilidad, pero Maven sigue siendo un estándar. Gran comparativa.', '2025-07-16 09:00:00', 1, 2),
('¡Estos trucos para debugging en TypeScript son un salvavidas! Gracias.', '2025-07-22 13:50:00', 2, 2);


Select * from Usuarios;
select * from posts;
select * from Comentarios;




--Pregunta 2
--Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas:
--nombre y email del usuario junto al título y contenido del post.
SELECT 
  U.nombre NOMBRE,
  U.email EMAIL,
  p.titulo,
  p.contenido
FROM
  usuarios U,
  posts p
WHERE 
  u.id_usuario = p.usuario_id
;
--Pregunta 3
--Muestra el id, título y contenido de los posts de los administradores.
--a. El administrador puede ser cualquier id
SELECT
p.id_post ID,
p.titulo titulo,
p.contenido contenido
FROM
usuarios U,
posts P
WHERE
u.id_usuario = p.usuario_id
and u.rol = 'administrador'
;

--Pregunta 4
--Cuenta la cantidad de posts de cada usuario.
--a. La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario


SELECT 
u.id_usuario usuario,
u.email email,
count(id_post) cantidad_post
FROM
usuarios U,
posts P
WHERE
u.id_usuario = p.usuario_id
GROUP by id_usuario
ORDER BY id_usuario;

--Pregunta 5
/*Muestra el email del usuario que ha creado más posts.
a. Aquí la tabla resultante tiene un único registro y muestra solo el email. */
SELECT
  u.email
FROM
  usuarios u,
  posts p
where 
u.id_usuario = p.usuario_id

GROUP BY
  u.id_usuario, u.email
ORDER BY
  COUNT(p.id_post) DESC
LIMIT 1; 

--Pregunta 6
/*Muestra la fecha del último post de cada usuario.*/
SELECT
  u.id_usuario Usuario,
  u.nombre Nombre,
  MAX(p.fecha_creacion) ultima_fecha_post
FROM
  usuarios u,
  posts p
WHERE
u.id_usuario = p.usuario_id
GROUP BY
  u.id_usuario, u.nombre
ORDER BY
  u.id_usuario;



--Pregunta 7
/*Muestra el título y contenido del post (artículo) con más comentarios.*/SELECT
  p.titulo,
  p.contenido
FROM
  posts p,
  comentarios c 
WHERE 
p.id_post = c.post_id
GROUP BY
  p.id_post, p.titulo, p.contenido
ORDER BY
  COUNT(c.id_comentario) DESC
LIMIT 1;


--Pregunta 8
/*Muestra en una tabla el título de cada post, el contenido de cada post y el contenido
de cada comentario asociado a los posts mostrados, junto con el email del usuario
que lo escribió*/
SELECT
  p.titulo titulo_post,
  p.contenido contenido_post,
  c.contenido contenido_comentario,
  u.email email_usuario_comentario
FROM
  posts p,
  comentarios c,
  usuarios u
WHERE 
    p.id_post = c.post_id
and c.usuario_id = u.id_usuario

ORDER BY
  p.id_post, c.fecha_creacion;


--Pregunta 9
/*Muestra el contenido del último comentario de cada usuario.*/SELECT
  c.contenido  ultimo_comentario,
  u.email  email_usuario
FROM
  comentarios c
JOIN
  usuarios u ON c.usuario_id = u.id_usuario
WHERE
  (c.usuario_id, c.fecha_creacion) IN (
    SELECT
      usuario_id,
      MAX(fecha_creacion)
    FROM
      comentarios
    GROUP BY
      usuario_id
  )
ORDER BY
  u.id_usuario;









--Pregunta 10
/*Muestra los emails de los usuarios que no han escrito ningún comentario*/
SELECT
  u.email
FROM
  usuarios u
LEFT JOIN
  comentarios c 
ON u.id_usuario = c.usuario_id
WHERE
  c.id_comentario IS NULL;






drop Table Usuarios;
DROP Table posts;
drop Table Comentarios;
