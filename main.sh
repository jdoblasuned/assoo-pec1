#! /bin/bash


# Función para imprimir el menú de la aplicación.
# ToDo:
#	Recibir input.
#	Añadir variable de selección
#	Crear switch para cada opción

function printMenu {
	printf  "
============================================\n
  Sistema de Gestión - Aeropuerto Regional\n
============================================\n
	1. Registrar pasajero y vuelo\n
	2. Listar pasajeros de un vuelo\n
	3. Buscar pasajero\n
	4. Eliminar pasajero\n
	5. Modificar registro\n
	6. Consultar próximos vuelos\n
	7. Salir\n
	===========================================\n"
}

# Función para registrar pasajeros de un vuelo.
#	Pedir inputs y concatenar en una variable????
#	nombre, id vuelo, dia vuelo, mes vuelo, año vuelo, destino
#	Switch para interpretar meses.(1-enero,...)
#	Crear archivo de datos
#	$REGISTRO >> datos.txt
#	Normas de formato de datos (nombre y fechas)
#	Gestión de datos con AWK (repasar esto)
#		Guardar cada tipo de dato en variable de registro???
#		Pag 133 bash.pdf
#	Al registrar imprimir datos completos del registro

# Función para listar pasajeros de un vuelo.
#	Con AWK
#	Pedir input: id vuelo
#	Buscar id vuelo e imprimir registros que coincidan.

# Función para buscar pasajero
#	Con AWK
# 	Pedir input: nombre o parte
#	Buscar registros que coincidan
#	Imprimir por variables cada registro
#		Pag. 169 bash.pdf

# Función para eliminar pasajero

# Función para modificar registro

# Función para consultar próximos vuelos
# ToDo: 
#	añadir cabecera "Próximos vuelos"
#	ajustar comando ps para mostrar y ordenar por memoria 5 procesos
#	ps -Acmo ="pid, command, pmem, pcpu" - para imprimir las columnas
#					      ordenadas por pmem.
#       Buscar cómo sacar solo 5 procesos.
#	Explicar -A -c -m -o 
function nextFlights {
echo "Próximos vuelos: " 
ps -Acmo pid,command,pmem,pcpu | head -n 6
}

