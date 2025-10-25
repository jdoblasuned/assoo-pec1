#! /bin/bash


# Función para imprimir el menú de la aplicación.
# ToDo:
#	Recibir input.----- Nota: Añadir en el programa principal
#	Añadir variable de selección ---- Nota: Igual que el punto anterior
#	Crear switch para cada opción ---- Nota: Igual que el punto anterior

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

# Función para convertir los meses numéricos a texto.
# Se podría considera condicional múltiple.

function numToMonth {
  case $n_month in 
    1)
      month='enero';;
    2) 
      month='febrero';;
    3)
      month='marzo';;
    4) 
      month='abril';;
    5)
      month='mayo';;
    6) 
      month='junio';;
    7)
      month='julio';;
    8) 
      month='agosto';;
    9)
      month='septiembre';;
    10) 
      month='octubre';;
    11)
      month='noviembre';;
    12) 
      month='diciembre';;
  esac
}

# Función para registrar pasajeros de un vuelo.
#	Normas de formato de datos (nombre y fechas)
#	Mostrar mensajes por pantalla
# Operaciones con cadenas (concatenar)
# Mostrar por pantalla reesultados obtenidos a partir operar sobre argumentos o entradas de teclado
# Manejo de archivos (crear y eliminar, almacenar información)
function regPassenger {
  printf "Nombre y apellidos del pasajero: "
  read name
  printf "Identificador del vuelo: "
  read flight
  printf "Día del vuelo: "
  read day 
  printf "Mes del vuelo: "
  read n_month
  numToMonth;
  printf "Año del vuelo: "
  read year
  printf "Destino: "
  read destination
  echo $name:$flight:$day" de "$month" de "$year:$destination > ./temp.txt
  echo ./temp.txt >> ./registros.txt
  printf "Registro completado con éxito\n"
  awk -F: 'BEGIN{printf "%-40s %-8s %-25s %-25s\n", "Nombre", "Vuelo", "Fecha", "Destino"} {printf "%-40s %-8s %-25s %-25s\n", $1,$2,$3,$4}' ./temp.txt
  rm ./temp.txt
}

# Función para listar pasajeros de un vuelo.
# Lectura línea a línea de archivo.
#	Con AWK
#	Pedir input: id vuelo
#	Buscar id vuelo e imprimir registros que coincidan.
#	Se puede añadir argumentos variables para 

# Función para buscar pasajero
#	Con AWK
# 	Pedir input: nombre o parte
#	Buscar registros que coincidan
#	Imprimir por variables cada registro
#		Pag. 169 bash.pdf
#	Se podría poner argumentos variables para buscar directamente con main.sh buscar nombre pasajero

# Función para eliminar pasajero

# Función para modificar registro

# Función para consultar próximos vuelos
# Consulta de procesos activos y gestión de información sobre ellos.
# ToDo: 
#	Explicar -A -c -m -o 
function nextFlights {
echo "Próximos vuelos: " 
ps -Acmo pid,command,pmem,pcpu | head -n 6
}

regPassenger;
