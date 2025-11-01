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

#Verificar números enteros
is_integer(){
  [[ "$1" == +([0-9]) ]]
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
right_date(){
  local day=$1 
  local n_month=$2 
  local year=$3

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

  # Fecha correcta
  if (right_month "$n_month" && right_day "$day" && right_year "$year"); then 
    return 0
  else
    return 1 
  fi
}

### Solicitar fecha con formato correcto ###
ask_date () {
  printf "Día del vuelo: "
  read day
  printf "Mes del vuelo (numérico): "
  read n_month
  printf "Año del vuelo: "
  read year

  until right_date $day $n_month $year; do 
    echo "Introduce una fecha válida" >&2
    ask_date 
  done
}

### Convertir meses numéricos a texto ###
n2t_month () {
  local n_month=$1
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

  echo $month
}

#############################################
#         Gestión de los nombres            #
#############################################

### Comprobar si el nombre tiene formato correcto
right_name () {
  local name=$1
  if [[ "$name" =~ ^[[:alpha:][:space:]]+$ ]]; then
    return 0
  else
    return 1
  fi
}

### Pedir nombre hasta que el formato sea correcto
ask_name () {
  printf "Nombre y apellidos del pasajero: "
  read name
  until right_name "$name"; do 
    echo 'Solo puede contener letras y espacios' >&2
    ask_name 
  done
}

###########################################
#                                         #
#          Funciones del programa         #
#                                         #
###########################################



#############################################
#          Registrar pasajeros              #
#############################################

regPassenger () {
  ask_name 
  printf "Identificador del vuelo: "
  read flight
  ask_date
  printf "Destino: "
  read destination

  # Se guarda un archivo temporal para hacer una comprobación de que se ha pasado al registro
  echo $name'|'$flight'|'$day'|'$(n2t_month $n_month)'|'$year'|'$destination > ./temp.txt
  cat ./temp.txt >> ./registros.txt

  # Confirmación de pasajero añadido al registro
  # Al imprimir el END las variables mantienen el valor del último registro que almacenan
  # en este caso, el último añadido.
  if  [[ "$(tail -n 1 ./registros.txt)" == "$(cat ./temp.txt)" ]]
  then
    printf "\nRegistro completado con éxito\n"
    awk -F'|' 'BEGIN{printf "%-40s %-8s %-25s %-25s\n", "Nombre", "Vuelo", "Fecha", "Destino"}
    END{printf "%-40s %-8s %-2s de %-10s de %-5s %-25s\n",$1,$2,$3,$4,$5,$6}' ./registros.txt
    rm ./temp.txt
  else
    echo "Se ha producido un error" 
    return 1
  fi
}

##############################################
#       Listar pasajeros de un vuelo         #
##############################################
  
#	Buscar id vuelo e imprimir registros que coincidan.
#	Se puede añadir argumentos variables para 

list_flight () {
  local flight=$1

#  awk -F '|' -v flight="$flight" 'BEGIN{ printf "\nPasajeros del vuelo %s:\n", flight } 
#  $2 == flight { printf "- %-40s %-2s de %-10s de %-5s %-25s\n",$1,$3,$4,$5,$6 } ' ./registros.txt

awk -F '|' -v OFS='|  ' -v flight="$flight" 'BEGIN{ printf "\nPasajeros del vuelo %s:\n", flight } 
  $2 == flight { print $1,$3,$4 } ' ./registros.txt | column -t -s '|'

}

##############################################
#            Buscar pasarjero                #
##############################################
#		Pag. 169 bash.pdf
#	Se podría poner argumentos variables para buscar directamente con main.sh buscar nombre pasajero

search_psg () {
  local name=$*

#  awk -F '|' -v name="$name" 'BEGIN{ printf "\nResultados encontrados:\n" } 
#  tolower($1) ~ tolower(name) { printf "Pasajero: %-40s Vuelo: %-8s Fecha: %-2s de %-10s de %-8s Destino: %-25s\n",$1,$2,$3,$4,$5,$6 } ' ./registros.txt
  awk -F '|' -v name="$name" 'BEGIN{ printf "\nResultados encontrados:\n" } 
  tolower($1) ~ tolower(name) { printf "Pasajero: %s    Vuelo: %s    Fecha: %s    Destino: %s\n",$1,$2,$3,$4 } ' ./registros.txt | column -t -s '|'
}

##############################################
#            Eliminar pasajero               #
##############################################

del_by_num () {
  sed -i '' "$1d" ./registros.txt
}

del_pass () {
  local pass=$*
  local n_pass

  cat ./registros.txt | grep -ni "$pass" | column -t -s '|'
  echo 'Confirma el pasajero a eliminar introduciendo el número al principio de la línea'
  read n_pass 
  echo "Quieres borrar el pasajero: $(gsed -n ""$n_pass"p" ./registros.txt | column -t -s '|' )"
  read n_pass
  del_by_num $n_pass
}


##############################################
#            Modificar registro              #
##############################################

##############################################
#        Consultar próximos vuelos           #
##############################################
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

echo 'elige pasajero'
read pasajero
del_pass "$pasajero"
