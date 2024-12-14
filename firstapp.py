import mysql.connector
from tkinter import messagebox
import tkinter as tk

class BibliotecaDigital:
    def __init__(self, host, user, password, database):
        """Inicializa la conexión a la base de datos MySQL."""
        try:
            self.db = mysql.connector.connect(
                host=host,
                user=user,
                password='',
                database=database
            )
            self.cursor = self.db.cursor()
        except mysql.connector.Error as e:
            messagebox.showerror("Error de Conexión", f"No se pudo conectar a la base de datos: {str(e)}")

    # Procedimiento almacenado 1: Gestión de préstamos digitales
    def gestionar_prestamos(self, id_usuario, id_libro, fecha_prestamo):
        try:
            # Verificar que el usuario y libro existen
            self.cursor.execute("SELECT * FROM usuarios WHERE id_usuario = %s", (id_usuario,))
            usuario = self.cursor.fetchone()
            self.cursor.execute("SELECT * FROM libros WHERE id_libro = %s", (id_libro,))
            libro = self.cursor.fetchone()

            if usuario and libro:
                # Registrar el préstamo
                self.cursor.execute(
                    "INSERT INTO prestamos (usuario_id, libro_id, fecha_prestamo) VALUES (%s, %s, %s)",
                    (id_usuario, id_libro, fecha_prestamo)
                )
                self.db.commit()
                messagebox.showinfo("Éxito", "Préstamo registrado correctamente.")
            else:
                messagebox.showerror("Error", "Usuario o libro no encontrados.")
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error: {str(e)}")

    # Procedimiento almacenado 2: Control de suscripciones
    def controlar_suscripciones(self, id_usuario, estado_suscripcion):
        try:
            # Cambiar estado de la suscripción (usando 1 para activada y 0 para desactivada)
            self.cursor.execute("UPDATE usuarios SET suscripcion = %s WHERE id_usuario = %s",
                                (estado_suscripcion, id_usuario))
            self.db.commit()
            estado = "activada" if estado_suscripcion == 1 else "desactivada"
            messagebox.showinfo("Éxito", f"La suscripción del usuario ha sido {estado} correctamente.")
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error: {str(e)}")

    # Procedimiento almacenado 3: Sistema de búsqueda avanzada
    def buscar_libros(self, titulo=None, autor=None, popularidad_min=0):
        try:
            query = "SELECT * FROM libros WHERE (titulo LIKE %s AND autor LIKE %s AND popularidad >= %s)"
            self.cursor.execute(query, (f"%{titulo}%" if titulo else "%", f"%{autor}%" if autor else "%", popularidad_min))
            resultados = self.cursor.fetchall()

            if resultados:
                resultados_str = "\n".join([f"{libro[1]} de {libro[2]}" for libro in resultados])
                messagebox.showinfo("Resultados de Búsqueda", resultados_str)
            else:
                messagebox.showinfo("Búsqueda", "No se encontraron resultados.")
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error: {str(e)}")

    # Procedimiento almacenado 4: Gestión de recomendaciones
    def gestionar_recomendaciones(self, id_libro, popularidad_incremento=1):
        try:
            self.cursor.execute("UPDATE libros SET popularidad = popularidad + %s WHERE id_libro = %s",
                                (popularidad_incremento, id_libro))
            self.db.commit()
            messagebox.showinfo("Éxito", "Recomendación gestionada correctamente.")
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error: {str(e)}")

    # Métodos para agregar libros y usuarios
    def agregar_libro(self, id_libro, titulo, autor):
        try:
            self.cursor.execute(
                "INSERT INTO libros (id_libro, titulo, autor, popularidad) VALUES (%s, %s, %s, %s)",
                (id_libro, titulo, autor, 0)
            )
            self.db.commit()
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error al agregar el libro: {str(e)}")

    def agregar_usuario(self, id_usuario, nombre, suscripcion):
        try:
            self.cursor.execute(
                "INSERT INTO usuarios (id_usuario, nombre, suscripcion) VALUES (%s, %s, %s)",
                (id_usuario, nombre, suscripcion)
            )
            self.db.commit()
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error al agregar el usuario: {str(e)}")


class InterfazBiblioteca:
    def __init__(self, root, biblioteca):
        self.root = root
        self.root.title("Biblioteca Digital")
        self.biblioteca = biblioteca

        # Ajustar el tamaño de la ventana y hacerla no redimensionable
        self.root.geometry("500x420")  
        self.root.resizable(False, False)

        # Etiqueta y campos de entrada
        self.usuario_id_label = tk.Label(root, text="ID del Usuario:")
        self.usuario_id_label.grid(row=0, column=0, padx=20, pady=10, sticky="w")
        self.usuario_id_entry = tk.Entry(root)
        self.usuario_id_entry.grid(row=0, column=1, padx=20, pady=10, ipadx=10)

        self.libro_id_label = tk.Label(root, text="ID del Libro:")
        self.libro_id_label.grid(row=1, column=0, padx=20, pady=10, sticky="w")
        self.libro_id_entry = tk.Entry(root)
        self.libro_id_entry.grid(row=1, column=1, padx=20, pady=10, ipadx=10)

        self.fecha_label = tk.Label(root, text="Fecha (YYYY-MM-DD):")
        self.fecha_label.grid(row=2, column=0, padx=20, pady=10, sticky="w")
        self.fecha_entry = tk.Entry(root)
        self.fecha_entry.grid(row=2, column=1, padx=20, pady=10, ipadx=10)

        self.suscripcion_label = tk.Label(root, text="Estado de Suscripción (1=Activada, 0=Desactivada):")
        self.suscripcion_label.grid(row=3, column=0, padx=20, pady=10, sticky="w")
        self.suscripcion_entry = tk.Entry(root)
        self.suscripcion_entry.grid(row=3, column=1, padx=20, pady=10, ipadx=10)

        # Botones
        self.prestamo_button = tk.Button(root, text="Gestionar Préstamo Digital", command=self.gestionar_prestamo)
        self.prestamo_button.grid(row=4, column=0, columnspan=2, pady=20)

        self.suscripcion_button = tk.Button(root, text="Controlar Suscripción", command=self.controlar_suscripcion)
        self.suscripcion_button.grid(row=5, column=0, columnspan=2, pady=20)

        self.busqueda_button = tk.Button(root, text="Búsqueda Avanzada", command=self.buscar_libros)
        self.busqueda_button.grid(row=6, column=0, columnspan=2, pady=20)

        self.recomendacion_button = tk.Button(root, text="Gestionar Recomendaciones", command=self.gestionar_recomendaciones)
        self.recomendacion_button.grid(row=7, column=0, columnspan=2, pady=20)


    def gestionar_prestamo(self):
        try:
            usuario_id = int(self.usuario_id_entry.get())
            libro_id = int(self.libro_id_entry.get())
            fecha = self.fecha_entry.get()
            self.biblioteca.gestionar_prestamos(usuario_id, libro_id, fecha)
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error: {str(e)}")

    def controlar_suscripcion(self):
        try:
            usuario_id = int(self.usuario_id_entry.get())
            estado_suscripcion = int(self.suscripcion_entry.get())  # Cambiar a valor entero
            if estado_suscripcion not in [0, 1]:
                messagebox.showerror("Error", "El valor de suscripción debe ser 1 o 0.")
                return
            self.biblioteca.controlar_suscripciones(usuario_id, estado_suscripcion)
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error: {str(e)}")

    def buscar_libros(self):
        try:
            titulo = self.libro_id_entry.get() or None
            autor = self.usuario_id_entry.get() or None
            self.biblioteca.buscar_libros(titulo=titulo, autor=autor)
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error: {str(e)}")

    def gestionar_recomendaciones(self):
        try:
            libro_id = int(self.libro_id_entry.get())
            self.biblioteca.gestionar_recomendaciones(libro_id)
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error: {str(e)}")


def main():
    # Definir los datos de conexión a la base de datos
    host = "localhost"
    user = "root"
    password = ""
    database = "biblioteca_digital"

    # Crear la instancia de la biblioteca digital
    biblioteca = BibliotecaDigital(host, user, password, database)

    root = tk.Tk()
    interfaz = InterfazBiblioteca(root, biblioteca)
    root.mainloop()


if __name__ == '__main__':
    main()
