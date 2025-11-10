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
is_right_date(){
  local day=$1 
  local n_month=$2 
  local year=$3

  # Día correcto
  right_day(){
    if is_integer "$day" && (( $day > 0 && $day <= $(month_days "$n_month" "$year") )); then
     return 0
   else
     return 1 
   fi  }

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
  local month

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
is_right_name () {
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


#############################################
#       Solicitar datos del pasajero        #
#############################################

ask_data () {
  read -r -p "Nombre y apellidos del pasajero: "   name
  read -r -p "Identificador del vuelo: "           flight
  read -r -p "Día del vuelo: "                     day
  read -r -p "Mes del vuelo (numérico): "          month
  read -r -p "Año del vuelo: "                     year
  read -r -p "Destino: "                           destination
}


#############################################
#        Mostrar número de registro         # 
#############################################

reg_number() {
  local name=$*

  awk -F '|' -v name="$name" 'tolower($1) ~ tolower(name) {print NR "|" $0} ' data > temp 
  awk -F '|' -v name="$name" 'BEGIN{ printf "\nCoincidencias:\n" } 
  tolower($2) ~ tolower(name) { printf "\nNúmero de registro: %s    |Pasajero: %s    |Vuelo: %s    |Fecha: %s de %s de %s   |Destino: %s\n\n",$1,$2,$3,$4,$5,$6,$7 } ' temp | column -t -s "|"
}


###########################################
#                                         #
#          Funciones del programa         #
#                                         #
###########################################



#############################################
#          Registrar pasajeros              #
#############################################
 

save_data () {
  local name=$1
  local flight=$2 
  local day=$3
  local month=$4 
  local year=$5 
  local destination=$6

  if  ! is_right_name "$name" ; then
    echo "El nombre solo puede contener letras y espacios"
    return 1
  elif  ! is_right_date $day $month $year ; then
    echo "Elige una fecha correcta" 
    return 1
  fi

  #Almacenar los datos en archivo temporal
  echo $name'|'$flight'|'$day'|'$month'|'$year'|'$destination > temp
}

save_passenger() {

  # Pasar los datos del archivo temporal al registro
  cat temp >> data

  # Confirmar que el pasajero ha pasado al registro 
  if  [[ "$(tail -n 1 data)" == "$(cat temp)" ]]; then
    printf "\nRegistro completado con éxito\n"
    awk -F'|' 'BEGIN{printf "Nombre|Vuelo|Fecha|Destino\n" }
    END{printf "%s   |%s   |%s de %s de %s   |%s\n",$1,$2,$3,$4,$5,$6}' data | column -t -s '|'
    return 0
  else
    echo "Se ha producido un error al guardar"  
    return 1
  fi

  rm temp
}

ask_passenger () {
  ask_data
  until save_data "$name" "$flight" $day $month $year "$destination"; do 
    ask_data 
  done
  save_passenger 
}


##############################################
#       Listar pasajeros de un vuelo         #
##############################################
  
#	Buscar id vuelo e imprimir registros que coincidan.
#	Se puede añadir argumentos variables para 

list_flight () {
  local flight=$1

#  awk -F '|' -v flight="$flight" 'BEGIN{ printf "\nPasajeros del vuelo %s:\n", flight } 
#  $2 == flight { printf "- %-40s %-2s de %-10s de %-5s %-25s\n",$1,$3,$4,$5,$6 } ' data

awk -F '|' -v flight="$flight" 'BEGIN{ printf "\nPasajeros del vuelo %s:\n", flight } 
$2 == flight { printf "- %s    |%s de %s de %s    |%s\n", $1,$3,$4,$5,$6 } ' data | column -t -s '|'

}


##############################################
#            Buscar pasarjero                #
##############################################
#		Pag. 169 bash.pdf
#	Se podría poner argumentos variables para buscar directamente con main.sh buscar nombre pasajero

search_psg () {
  local name=$*

#  awk -F '|' -v name="$name" 'BEGIN{ printf "\nResultados encontrados:\n" } 
#  tolower($1) ~ tolower(name) { printf "Pasajero: %-40s Vuelo: %-8s Fecha: %-2s de %-10s de %-8s Destino: %-25s\n",$1,$2,$3,$4,$5,$6 } ' data
  awk -F '|' -v name="$name" 'BEGIN{ printf "\nResultados encontrados:\n" } 
  tolower($1) ~ tolower(name) { printf "Pasajero: %s    |Vuelo: %s    |Fecha: %s de %s de %s   |Destino: %s\n",$1,$2,$3,$4,$5,$6 } ' data | column -t -s '|'
}


##############################################
#            Eliminar pasajero               #
##############################################

### Función de búsqueda adaptada a la eliminación de pasajero ###
# Se muestra el número de registro para poder elegir la coincidencia a eliminar

del_pass () {
  local name=$*
  local n_pass

  reg_number $name 

  echo 'Confirma el pasajero a eliminar introduciendo el número de registro'
  read n_pass 
   
  printf  "¿Quieres eliminar el registro: $(awk -F '|' -v num="$n_pass" 'NR==num {printf "%s  |%s  |%s de %s de %s  |%s\n", $1,$2,$3,$4,$5,$6}' data | column -t -s '|') ?\n"
  
  select option in "Sí" "No"
  do
    case $REPLY in
      1) gsed -i  ""$n_pass"d" data; break;;
      2) break;;
    esac
  done    
  rm temp 
}


##############################################
#             Modificar registro             #
##############################################

modif_psgr () {
  local name=$*
  local n_pass

  reg_number $name
  read -r -p "Confirma el registro a modificar con el número de registro: " n_pass
  
  
  printf  "Registro: $(awk -F '|' -v num="$n_pass" 'NR==num {printf "%s  |%s  |%s de %s de %s  |%s\n", $1,$2,$3,$4,$5,$6}' data | column -t -s '|')\n"
  echo '#################'
  echo '¿Quieres modificarlo?'
  echo '#################'
  select option in "Sí" "No"
  do
    case $REPLY in 
      1) modif_data $n_pass
         break;;
      2) break;;
    esac
  done
}

modif_data (){
  local name flight day month year destination

  name="$(awk -F '|' -v num=$1 'NR==num{print $1}' data)"
  flight="$(awk -F '|' -v num=$1 'NR==num{print $2}' data)"
  day="$(awk -F '|' -v num=$1 'NR==num{print $3}' data)"
  month="$(awk -F '|' -v num=$1 'NR==num{print $4}' data)"
  year="$(awk -F '|' -v num=$1 'NR==num{print $5}' data)"
  destination="$(awk -F '|' -v num=$1 'NR==num{print $6}' data)"

  printf "\n***************\nDatos actuales:\n***************\n\nNombre: $name \nVuelo: $flight \nFecha: $day de $month de $year \nDestino: $destination \n\n"

  # Explicar petición a chatgpt para que me vuelva a imprimir el menú cada vez, sobre todo el break 2
  while true; do 
  echo '#################'
  echo 'Elige una opción:'
  echo '#################'
    COLUMNS=1
    select option in "Modificar nombre" "Modificar vuelo" "Modificar fecha" "Modificar destino" "Guardar" "Salir sin guardar"
    do 
      case $REPLY in
        1) read -r -p "Nombre y apellidos: " n_name
           if is_right_name $n_name; then 
             name=$n_name
           else
             echo "El nombre solo puede contener letras y espacios"
             return 1 
           fi;;
        2) read -r -p "Vuelo: " flight;;
        3) read -r -p "Día: " n_day; read -r -p "Mes(numérico): " n_month; read -r -p "Año: " n_year
           if is_right_date $n_day $n_month $n_year; then
             day=$n_day
             month=$(n2t_month $n_month)
             year=$n_year
           else
             echo "La fecha no es correcta"
             return 1
           fi;;
        4) read -r -p "Destino: " destination;;
        5) echo $name'|'$flight'|'$day'|'$month'|'$year'|'$destination > temp
           gsed -i "${n_pass}c$(cat temp)" data
           rm temp
           break 2;;
        6) break 2;;
       esac
         printf "\n***************\nDatos actuales:\n***************\n\nNombre: $name \nVuelo: $flight \nFecha: $day de $month de $year \nDestino: $destination \n\n"
         break
     done
   done
}

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
read -r -p "dame nombre" nombre 
modif_psgr $nombre
