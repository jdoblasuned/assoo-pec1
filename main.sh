#! /bin/bash

###########################################
#                                         #
#          Funciones auxiliares           #
#                                         #
###########################################


###### Imprimir el menú de la aplicación #####

# ToDo:
#	Recibir input.----- Nota: Añadir en el programa principal
#	Añadir variable de selección ---- Nota: Igual que el punto anterior
#	Crear switch para cada opción ---- Nota: Igual que el punto anterior
#	Posibilidad de cambiar el switch por un select

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

#############################################
#         Gestión de las fechas             #
#############################################

# TODO: Explicar extglob
shopt -s extglob

### Solicitar fecha ###
#Verificar números enteros
is_integer(){
  [[ "$1" == +([0-9]) ]]
}

ask_date() {
  printf "Día del vuelo: "
  read day
  printf "Mes del vuelo (numérico): "
  read n_month
  printf "Año del vuelo: "
  read year
}

### Función para comprobar si un año es bisiesto ###
leap_year() {
  # Utilizamos el primer argumento que se pase a la función
  local year=$1

  if (( (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) )); then
    # 0 se considera True
    return 0
  else
    # 1 se considera False
    return 1
  fi
}

### Función para comprobar los días que tiene el mes ###
# Primer argumento: Mes
# Segundo argumento: Año
month_days() {
  local month=$1
  local year=$2
  local max_days

  case "$month" in
    1|3|5|7|8|10|12) max_days=31;; 
    4|6|9|11) max_days=30;;
    2)if leap_year $year; then
        max_days=29
      else
        max_days=28
      fi;;
  esac

  echo $max_days
}


### Comprobar que la fecha es correcta ###
# Día correcto
right_day(){
  if is_integer "$day" && (( $day > 0 && $day <= $(month_days "$n_month" "$year") )); then
    return 0
  else
    return 1 
  fi
}

# Mes correcto
right_month(){
  if is_integer "$n_month" && (( $n_month > 0 && $n_month <= 12 )); then
    return 0
  else
    return 1 
  fi
}

# Año correcto
right_year(){
  if is_integer "$year" && (( $year > 0 )); then
    return 0
  else
    return 1 
  fi
}

# Fecha válida
right_date(){
  if (right_month "$n_month" && right_day "$day" && right_year "$year"); then 
    return 0
  else
    return 1 
  fi
}

### Convertir meses numéricos a texto ###
n2t_month () {
  case $n_month in 
    1) month='enero';;
    2) month='febrero';;
    3) month='marzo';;
    4) month='abril';;
    5) month='mayo';;
    6) month='junio';;
    7) month='julio';;
    8) month='agosto';;
    9) month='septiembre';;
    10) month='octubre';;
    11) month='noviembre';;
    12) month='diciembre';;
  esac
}


##### Registrar pasajeros #####
# Operaciones con cadenas (concatenar)
regPassenger () {
  printf "Nombre y apellidos del pasajero: "
  # TODO: Cambiar read por función de formato correcto
  read name
  printf "Identificador del vuelo: "
  read flight
  ask_date
  until right_date; do 
    echo "Introduce una fecha válida"
    ask_date
  done
  printf "Destino: "
  read destination

  n2t_month 

  echo $name"|"$flight"|"$day" de "$month" de "$year"|"$destination > ./temp.txt
  cat ./temp.txt >> ./registros.txt

  if  [[ "$(tail -n 1 ./registros.txt)" == "$(cat ./temp.txt)" ]]
  then
    echo "=================================================================================="
    echo "Registro completado con éxito"
    awk -F"|" 'BEGIN{printf "%-40s %-8s %-25s %-25s\n", "Nombre", "Vuelo", "Fecha", "Destino"} END {printf "%-40s %-8s %-25s %-25s\n",$1,$2,$3,$4}' ./registros.txt
    rm ./temp.txt
  else
    echo "Se ha producido un error" 
    return 1
  fi
}

##### Listar pasajeros de un vuelo #####
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

list_flight () {
  local flight=$1
  echo $flight

  awk -F "|" -v flight="$flight" 'BEGIN{ printf "Pasajeros del vuelo %s:\n", flight } $2 == flight { printf "- %-40s %-25s %-25s\n",$1,$3,$4 } ' ./registros.txt
}

##### Eliminar pasajero #####

##### Modificar registro #####

##### Consultar próximos vuelos #####
# Consulta de procesos activos y gestión de información sobre ellos.
# ToDo: 
#	Explicar -A -c -m -o 
next_flights () {
echo "Próximos vuelos: " 
ps -Acmo pid,command,pmem,pcpu | head -n 6
}


###########################################
#                                         #
#          Programa principal             #
#                                         #
###########################################

echo "Código del vuelo a listar:"
read vuelo
list_flight $vuelo
