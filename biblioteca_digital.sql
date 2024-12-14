-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 14-12-2024 a las 02:11:49
-- Versión del servidor: 10.4.24-MariaDB
-- Versión de PHP: 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `biblioteca_digital`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_libros` (IN `titulo` VARCHAR(255), IN `autor` VARCHAR(255), IN `popularidad_min` INT)   BEGIN
    -- Realizar búsqueda avanzada con los parámetros proporcionados
    SELECT id_libro, titulo, autor, popularidad
    FROM libros
    WHERE (titulo LIKE CONCAT('%', titulo, '%') OR titulo IS NULL)
    AND (autor LIKE CONCAT('%', autor, '%') OR autor IS NULL)
    AND popularidad >= IFNULL(popularidad_min, 0);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_libros_avanzada` (IN `p_titulo` VARCHAR(255), IN `p_autor` VARCHAR(255), IN `p_popularidad_min` INT)   BEGIN
    DECLARE v_resultados_found INT;

    -- Buscar libros que coincidan con los parámetros proporcionados
    SELECT COUNT(*) INTO v_resultados_found
    FROM libros
    WHERE (titulo LIKE CONCAT('%', p_titulo, '%') OR p_titulo IS NULL)
      AND (autor LIKE CONCAT('%', p_autor, '%') OR p_autor IS NULL)
      AND (popularidad >= p_popularidad_min);

    -- Si se encuentran resultados, mostrar los libros
    IF v_resultados_found > 0 THEN
        SELECT id_libro, titulo, autor, popularidad
        FROM libros
        WHERE (titulo LIKE CONCAT('%', p_titulo, '%') OR p_titulo IS NULL)
          AND (autor LIKE CONCAT('%', p_autor, '%') OR p_autor IS NULL)
          AND (popularidad >= p_popularidad_min);
    ELSE
        -- Si no se encuentran resultados
        SELECT 'No se encontraron libros que coincidan con los criterios.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `controlar_suscripcion` (IN `p_id_usuario` INT, IN `p_estado_suscripcion` BOOLEAN)   BEGIN
    DECLARE v_usuario_existente INT;

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_usuario_existente
    FROM usuarios
    WHERE id_usuario = p_id_usuario;

    IF v_usuario_existente > 0 THEN
        -- Actualizar el estado de suscripción del usuario
        UPDATE usuarios
        SET suscripcion = p_estado_suscripcion
        WHERE id_usuario = p_id_usuario;

        IF p_estado_suscripcion THEN
            SELECT 'Suscripción activada correctamente.' AS mensaje;
        ELSE
            SELECT 'Suscripción desactivada correctamente.' AS mensaje;
        END IF;
    ELSE
        -- Si el usuario no existe, mostrar un mensaje de error
        SELECT 'Error: Usuario no encontrado.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gestionar_prestamo` (IN `p_id_usuario` INT, IN `p_id_libro` INT, IN `p_fecha_prestamo` DATE)   BEGIN
    DECLARE v_usuario_existente INT;
    DECLARE v_libro_existente INT;

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_usuario_existente
    FROM usuarios
    WHERE id_usuario = p_id_usuario;

    -- Verificar si el libro existe
    SELECT COUNT(*) INTO v_libro_existente
    FROM libros
    WHERE id_libro = p_id_libro;

    -- Si el usuario y el libro existen, registrar el préstamo
    IF v_usuario_existente > 0 AND v_libro_existente > 0 THEN
        INSERT INTO prestamos (usuario_id, libro_id, fecha_prestamo)
        VALUES (p_id_usuario, p_id_libro, p_fecha_prestamo);

        SELECT 'Préstamo registrado correctamente.' AS mensaje;
    ELSE
        -- Si el usuario o el libro no existen, mostrar un mensaje de error
        SELECT 'Error: Usuario o libro no encontrados.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gestionar_prestamo_digital` (IN `p_usuario_id` INT, IN `p_libro_id` INT, IN `p_fecha_prestamo` DATE)   BEGIN
    -- Declarar variables
    DECLARE v_usuario_existente INT;
    DECLARE v_libro_existente INT;

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_usuario_existente
    FROM usuarios
    WHERE id_usuario = p_usuario_id;

    -- Verificar si el libro existe
    SELECT COUNT(*) INTO v_libro_existente
    FROM libros
    WHERE id_libro = p_libro_id;

    -- Si el usuario y el libro existen, registrar el préstamo
    IF v_usuario_existente > 0 AND v_libro_existente > 0 THEN
        INSERT INTO prestamos (usuario_id, libro_id, fecha_prestamo)
        VALUES (p_usuario_id, p_libro_id, p_fecha_prestamo);
    ELSE
        -- Si el usuario o el libro no existen, mostrar mensaje de error
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario o libro no encontrados.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gestionar_recomendaciones` (IN `p_id_libro` INT, IN `p_incremento_popularidad` INT)   BEGIN
    DECLARE v_libro_existente INT;

    -- Verificar si el libro existe
    SELECT COUNT(*) INTO v_libro_existente
    FROM libros
    WHERE id_libro = p_id_libro;

    IF v_libro_existente > 0 THEN
        -- Incrementar la popularidad del libro
        UPDATE libros
        SET popularidad = popularidad + p_incremento_popularidad
        WHERE id_libro = p_id_libro;

        SELECT 'Popularidad incrementada correctamente.' AS mensaje;
    ELSE
        -- Si el libro no existe, mostrar un mensaje de error
        SELECT 'Error: Libro no encontrado.' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libros`
--

CREATE TABLE `libros` (
  `id_libro` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `autor` varchar(255) NOT NULL,
  `popularidad` int(11) NOT NULL DEFAULT 0,
  `fecha_publicacion` date DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `libros`
--

INSERT INTO `libros` (`id_libro`, `titulo`, `autor`, `popularidad`, `fecha_publicacion`, `fecha_registro`) VALUES
(1, 'Pep Guardiola', 'Pep', 7, '2024-12-13', '2024-12-14 00:13:49'),
(2, 'Megan Fox', 'Messi', 5, '2024-12-13', '2024-12-14 00:13:49');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamos`
--

CREATE TABLE `prestamos` (
  `id_prestamo` int(11) NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `libro_id` int(11) DEFAULT NULL,
  `fecha_prestamo` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `prestamos`
--

INSERT INTO `prestamos` (`id_prestamo`, `usuario_id`, `libro_id`, `fecha_prestamo`) VALUES
(1, 1, 1, '2024-12-13'),
(2, 1, 1, '2024-12-13'),
(3, 1, 1, '2024-12-13');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `suscripcion` tinyint(1) NOT NULL DEFAULT 1,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `suscripcion`, `fecha_registro`) VALUES
(1, 'Santiago', 1, '2024-12-14 00:14:44'),
(2, 'Raquel', 1, '2024-12-14 00:14:44');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `libros`
--
ALTER TABLE `libros`
  ADD PRIMARY KEY (`id_libro`);

--
-- Indices de la tabla `prestamos`
--
ALTER TABLE `prestamos`
  ADD PRIMARY KEY (`id_prestamo`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `libro_id` (`libro_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `libros`
--
ALTER TABLE `libros`
  MODIFY `id_libro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `prestamos`
--
ALTER TABLE `prestamos`
  MODIFY `id_prestamo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `prestamos`
--
ALTER TABLE `prestamos`
  ADD CONSTRAINT `prestamos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `prestamos_ibfk_2` FOREIGN KEY (`libro_id`) REFERENCES `libros` (`id_libro`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
