#!/bin/bash
shopt -s extglob

### Solicitar fecha ###
#Verificar números enteros
is_integer() {
  [[ $1 == +([0-9]) ]]
}

ask_date() {
printf "Día del vuelo: "
read day
printf "Mes del vuelo (numérico): "
read month
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
  if is_integer $day && (( $day > 0 && $day <= $(month_days "$month" "$year") )); then
    return 0
  else
    return 1 
  fi
}

# Mes correcto
right_month(){
  if is_integer $month && (( $month > 0 && $month <= 12 )); then
    return 0
  else
    return 1 
  fi
}

# Año correcto
right_year(){
  if is_integer $year && (( $year > 0 )); then
    return 0
  else
    return 1 
  fi
}

# Fecha válida
right_date(){
  if (right_month "$month" && right_day "$day" && right_year "$year"); then 
    return 0
  else
    return 1 
  fi
}


##############################
ask_date
until right_date; do 
  echo "Introduce una fecha válida"
  ask_date
done

echo $day" " $month" " $year
