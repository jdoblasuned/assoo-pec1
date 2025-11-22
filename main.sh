#! /bin/bash
shopt -s extglob

###########################################
#                                         #
#          Funciones auxiliares           #
#                                         #
###########################################

###########################################
#         Gestión de las fechas           #
###########################################

# Verificar números enteros
is_integer(){
  [[ "$1" == +([0-9]) ]]
}

### Función para comprobar si un año es bisiesto ###
leap_year() {
  local year="$1"

 # El año es bisiesto cuando es múltiplo de 4 con excepción de los que son múltiplos de 100.
  # Salvo los que también lo son de 400 que serían también bisiestos.
  if (( (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) )); then
    return 0
  else
    return 1
  fi
}

### Función para comprobar los días que tiene el mes ###
month_days() {
  local month="$1"
  local year="$2"
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

### Comprobar que la fecha tiene un formato correcto ###
is_right_date(){
  local day="$1" 
  local n_month="$2" 
  local year="$3"

  # Día correcto
  # Comprueba si es un entero comprendido entre el número de días que tiene el mes
  #   de la fecha que se quiere registrar.
  right_day(){
    if is_integer "$day" && (( $day > 0 && $day <= $(month_days "$n_month" "$year") )); then
     return 0
   else
     return 1 
   fi  
  }

  # Mes correcto
  # Comprueba si es un entero entre 1 y 12
  right_month(){
    if is_integer "$n_month" && (( $n_month > 0 && $n_month <= 12 )); then
      return 0
    else
      return 1 
    fi
  }

  # Año correcto
  # Comprueba si es un entero mayor que 0
  right_year(){
    if is_integer "$year" && (( $year > 0 )); then
      return 0
    else
      return 1 
    fi
  }

  # Fecha correcta
  # Comprueba que los datos de día, mes y año tienen las características correctas.
  if (right_month "$n_month" && right_day "$day" && right_year "$year"); then 
    return 0
  else
    return 1 
  fi
}

### Solicitar fecha con formato correcto ###
# Volverá a solicitar datos hasta que tengan un formato correcto y la fecha sea una fecha válida
ask_date () {
  read -p "Día del vuelo: " day
  read -p "Mes del vuelo (numérico): " n_month
  read -p "Año del vuelo: " year

  until right_date $day $n_month $year; do 
    echo "Introduce una fecha válida"
    ask_date 
  done
}

## Convertir meses numéricos a texto ###
n2t_month () {
  local n_month="$1"
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

###########################################
#         Gestión de los nombres          #
###########################################

### Comprobar si el nombre tiene formato correcto ###
# Debe estar formado por solo por 1 o más letras o espacios
is_right_name () {
  local name="$1"
  if [[ "$name" == +([[:alpha:][:space:]]) ]]; then
    return 0
  else
    return 1
  fi
}

### Pedir nombre hasta que el formato sea correcto ###
ask_name () {
  read -p "Nombre y apellidos del pasajero: " name
  until right_name "$name"; do 
    echo 'Solo puede contener letras y espacios' 
    ask_name 
  done
}

###########################################
#      Gestionar datos del pasajero       #
###########################################

# Filtrar la información introducida.
# Si es correcta la guarda en un archivo temporal.
save_data () {
  local name="$1"
  local flight="$2"
  local day="$3"
  local month="$4"
  local year="$5"
  local destination="$6"

  if  ! is_right_name "$name" ; then
    echo 'El nombre solo puede contener letras y espacios'
    return 1
  elif  ! is_right_date $day $month $year ; then
    echo 'La fecha no es correcta'
    return 1
  fi

  # Almacenar los datos en archivo temporal
  echo $name'|'$flight'|'$day'|'$(n2t_month $month)'|'$year'|'$destination > $temp_log
}

# Guardar la información del archivo temporal en el archivo de registro
# Notificar si se ha guardado la información correctamente
# Eliminar el archivo temporal

save_passenger() {
  cat $temp_log >> $log

  # Confirmar que el pasajero ha pasado al registro 
  if  [[ "$(tail -n 1 $log)" == "$(cat $temp_log)" ]]; then
    echo
    echo 'Registro completado con éxito'
    awk -F '|' 'BEGIN{printf "Nombre|Vuelo|Fecha|Destino\n" }
    END{printf "%s   |%s   |%s de %s de %s   |%s\n",$1,$2,$3,$4,$5,$6}' $log | column -t -s '|'
    return 0
  else
    echo 'Se ha producido un error al guardar'
    return 1
  fi

  rm $temp_log
}


##########################################
#       Mostrar número de registro        # 
###########################################
# Busca una coincidencia de texto en los nombres del registro
# Los muestra por pantalla
# Añade el número de registro de cada coincidencia
reg_number() {
  local name="$*"
  local n_regs

awk -F '|' -v name="$name" 'tolower($1) ~ tolower(name) {print NR "|" $0} ' $log > $temp_log 
  n_regs=$(wc -l < "$temp_log")
  if [ "$n_regs" -eq 0 ]; then
    echo 'No hay ninguna coincidencia'
    sleep 1
    return 1
  else
    awk -F '|' -v name="$name" 'BEGIN{ printf "\nCoincidencias:\n" } 
    tolower($2) ~ tolower(name) { printf "\nNúmero de registro: %s    |Pasajero: %s    |Vuelo: %s    |Fecha: %s de %s de %s   |Destino: %s\n\n",$1,$2,$3,$4,$5,$6,$7 } ' $temp_log | column -t -s "|"
  fi
}

###########################################
#     Modificar datos de un registro      #
###########################################

# Se introduce el número de registro como argumento
modif_data (){
  local name flight day month year destination

  # Inicialmente asigna a las variables el valor que tiene actualmente el registro
  name="$(awk -F '|' -v num=$1 'NR==num{print $1}' $log)"
  flight="$(awk -F '|' -v num=$1 'NR==num{print $2}' $log)"
  day="$(awk -F '|' -v num=$1 'NR==num{print $3}' $log)"
  month="$(awk -F '|' -v num=$1 'NR==num{print $4}' $log)"
  year="$(awk -F '|' -v num=$1 'NR==num{print $5}' $log)"
  destination="$(awk -F '|' -v num=$1 'NR==num{print $6}' $log)"

  printf "\n***************\nDatos actuales:\n\nNombre: $name \nVuelo: $flight \nFecha: $day de $month de $year \nDestino: $destination \n\n"

  # Muestra las opciones:
  # Variables a cambiar, guardar datos, salir sin guardar
  # Comprueba que los datos tengan el formato correcto
  while true; do 
  echo '*****************'
  echo 'Elige una opción:'
    COLUMNS=1
    select option in "Modificar nombre" "Modificar vuelo" "Modificar fecha" "Modificar destino" "Guardar" "Salir sin guardar"
    do 
      case $REPLY in
        1) read -p "Nombre y apellidos: " n_name
           if is_right_name $n_name; then 
             name=$n_name
           else
             echo "El nombre solo puede contener letras y espacios"
             return 1 
           fi;;
        2) read -p "Vuelo: " flight;;
        3) read -p "Día: " n_day; read -p "Mes(numérico): " n_month; read -p "Año: " n_year
           if is_right_date $n_day $n_month $n_year; then
             day="$n_day"
             month="$(n2t_month $n_month)"
             year="$n_year"
           else
             echo "La fecha no es correcta"
             return 1
           fi;;
        4) read -p "Destino: " destination;;
        5) echo $name'|'$flight'|'$day'|'$month'|'$year'|'$destination > $temp_log
           sed -i "${n_pass}c$(cat $temp_log)" $log
           rm $temp_log
           break 2;;
        6) rm $temp_log
           break 2;;
       esac
         printf "\n***************\nDatos actuales:\n\nNombre: $name \nVuelo: $flight \nFecha: $day de $month de $year \nDestino: $destination \n\n"
         break
     done
   done
}


###########################################
#                                         #
#          Funciones del programa         #
#                                         #
###########################################



###########################################
#          Registrar pasajeros            #
###########################################

# Función para el menú o invocar la opción desde shell pero sin argumentos
menu_register() {
  local name flight day month year destination 

  read -p "Nombre y apellidos del pasajero: "   name
  read -p "Identificador del vuelo: "           flight
  read -p "Día del vuelo: "                     day
  read -p "Mes del vuelo (numérico): "          month
  read -p "Año del vuelo: "                     year
  read -p "Destino: "                           destination

  register_passenger "$name" "$flight" "$day" "$month" "$year" "$destination"
}

# Regsitrar pasajeros y vuelos con los datos introducidos como argumentos
register_passenger () {
  if save_data "$1" "$2" "$3" "$4" "$5" "$6"; then
    save_passenger
  else
    echo "Error en los datos"
    return 1
  fi
}

############################################
#      Listar pasajeros de un vuelo        #
############################################
  
# Función para el menú o invocar la opción desde shell pero sin argumentos
menu_list () {
  local flight
  read -p "Ingrese el identificador del vuelo: " flight
  list_flight "$flight"
}

# Listar los pasajeros del vuelo que se le pasa como argumento
list_flight () {
  local flight="$1"

awk -F '|' -v flight="$flight" 'BEGIN{ printf "\nPasajeros del vuelo %s:\n", flight } 
$2 == flight { printf "- %s    |%s de %s de %s    |%s\n", $1,$3,$4,$5,$6 } ' $log | column -t -s '|'

}


###########################################
#            Buscar pasarjero             #
###########################################

# Función para el menú o invocar la opción desde shell pero sin argumentos
menu_search () {
  local name
  read -p "Ingrese nombre o parte del nombre: " name

  search_passenger "$name"
}

# Buscar los pasajeros cuyo nombre coincida con todo o parte del texto introducido como argumento
search_passenger () {
  local name="$*"

  awk -F '|' -v name="$name" 'BEGIN{ printf "\nResultados encontrados:\n" } 
  tolower($1) ~ tolower(name) { printf "Pasajero: %s    |Vuelo: %s    |Fecha: %s de %s de %s   |Destino: %s\n",$1,$2,$3,$4,$5,$6 } ' $log | column -t -s '|'
}


###########################################
#           Eliminar pasajero             #
###########################################


# Función para el menú o invocar la opción desde shell pero sin argumentos
menu_del () {
  local name

  read -p "Ingrese nombre o parte del nombre: " name

  del_passenger "$name"
}


# Busca coincidencias de texto 
# Se muestra el número de registro para poder elegir la coincidencia a eliminar
del_passenger () {
  local name="$*"
  local n_pass

  if reg_number "$name" ; then
    read -p 'Confirma el pasajero a eliminar introduciendo el número de registro: ' n_pass
    echo 
    printf  "¿Quieres eliminar el registro: $(awk -F '|' -v num="$n_pass" 'NR==num {printf "%s  |%s  |%s de %s de %s  |%s\n", $1,$2,$3,$4,$5,$6}' $log | column -t -s '|') ?\n"
  
    select option in "Sí" "No"
    do
      case $REPLY in
        1) sed -i  ""$n_pass"d" $log; break;;
        2) break;;
      esac
    done    
  fi 
  rm $temp_log 
}

###########################################
#            Modificar registro           #
###########################################

# Función para el menú o invocar la opción desde shell pero sin argumentos
menu_modif () {
  local name

  read -p "Ingrese nombre o parte del nombre: " name

  modif_passenger "$name"
}

# Busca coincidencias de texto
# Se muestra el número de registro para poder elegir la coincidencia a modificar 
modif_passenger () {
  local name="$*"
  local n_pass

  if reg_number "$name" ; then 
    read -p "Confirma el registro a modificar introduciendo el número de registro: " n_pass
  
    printf  "Registro: $(awk -F '|' -v num="$n_pass" 'NR==num {printf "%s  |%s  |%s de %s de %s  |%s\n", $1,$2,$3,$4,$5,$6}' $log | column -t -s '|')\n"

    echo 
    echo '¿Quieres modificarlo?'

    select option in "Sí" "No"
    do
      case $REPLY in 
        1) modif_data $n_pass
           break;;
        2) break;;
      esac
    done
  fi
  rm $temp_log
}

###########################################
#        Consultar próximos vuelos        #
###########################################
# Procesos con mayor uso de memoria
next_flights () {
echo "Próximos vuelos: " 
ps -eo pid,comm,pmem,pcpu --sort=-pmem | head -n 6
}

###########################################
#                                         #
# ######### PROGRAMA PRINCIPAL ########## #
#                                         #
###########################################


###########################################
#         Archivos de registros           #
###########################################

# Crea el archivo de registro de datos en caso de que no exista
# Establece las variables para las direcciones del registro y archivo temporal auxiliar
init_storage () {
  if [ ! -e ~/aeropuerto/data ]; then
    if [ ! -e ~/aeropuerto ]; then 
      mkdir ~/aeropuerto
      touch ~/aeropuerto/data
    else
      touch ~/aeropuerto/data
    fi 
  fi

  log=~/aeropuerto/data
  temp_log=~/aeropuerto/temp
}

###########################################
#                 Menú                    #
###########################################
menu () { 
  while true; do
      clear
      echo "=============================================="
      echo "   Sistema de Gestión - Aeropuerto Regional   "
      echo "=============================================="
      echo "         1. Registrar pasajero y vuelo"
      echo "         2. Listar pasajeros de un vuelo"
      echo "         3. Buscar pasajero"
      echo "         4. Eliminar pasajero"
      echo "         5. Modificar registro"
      echo "         6. Consultar próximos vuelos"
      echo "         7. Salir"
      echo "         =============================================="
      read -p "Seleccione una opción [1-7]: " opcion


    case $opcion in
      1) menu_register;;
      2) menu_list;;
      3) menu_search;;
      4) menu_del;;
      5) menu_modif;;
      6) next_flights;;
      7) echo "Saliendo del programa"
         rm $temp_log
         sleep 1
         break;;
      *) echo "Opción inválida"
         sleep 1;;
    esac

      echo
      read -p "Presione Enter para continuar..."
  done
}

###########################################
#                 MAIN                    #
###########################################

main () {
  init_storage
  local option="${1:-}"
  case $option in
    registrar) shift; if [ -z "${1:-}" ]; then menu_register; else register_passenger "$@"; fi ;;
    listar) shift; if [ -z "${1:-}" ]; then menu_list ; else list_flight "$@" ; fi  ;;
    buscar) shift ; if [ -z "${1:-}" ]; then menu_search ; else search_passenger "$@" ; fi ;;
    eliminar) shift ; if [ -z "${1:-}" ]; then menu_del ; else del_passenger "$@" ; fi ;;
    modificar) shift ; if [ -z "${1:-}" ]; then menu_modif ; else modif_passenger "$@" ; fi ;;
    consultar) next_flights ;;
    "") menu ;;
    *) echo "Opción no válida";;
  esac
}


main "$@"
