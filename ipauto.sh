#!/bin/bash

# Función para imprimir el banner con colores
print_banner() {
  echo -e "\e[1;36m"
  echo "*****************************************************"
  echo "*                                                   *"
  echo "*     IPTABLES AUTOMATION WITH BASH                 *"
  echo "*                                                   *"
  echo "*..................................By Josh.....v1.0.*"
  echo "*****************************************************"
  echo -e "\e[0m"
}

# Verificar si iptables está instalado y ofrecer instalarlo si no lo está
check_iptables() {
  if ! command -v iptables >/dev/null 2>&1; then  # Corrected syntax error
    echo -e "\e[1;31m¡iptables no está instalado!"
    read -p "¿Desea instalar iptables? (y/n): " install_iptables
    if [ "$install_iptables" == "y" ]; then
      sudo apt-get update
      sudo apt-get install iptables
    else
      echo "Saliendo..."
      exit 1
    fi
  fi
}

# Función para mostrar el menú
show_menu() {
  echo "Seleccione una opción:"
  echo "1. Bloquear tráfico por un puerto"
  echo "2. Desbloquear tráfico por un puerto"
  echo "3. Bloquear todas las conexiones entrantes excepto un puerto"
  echo "4. Mostrar reglas iptables"
  echo "5. Limpiar todas las reglas iptables"
  echo "7. Permitir tráfico por un rango de puertos"
  echo "8. Bloquear una dirección IP"
  echo "9. Desbloquear una dirección IP"
  echo "10. Guardar reglas de iptables"
  echo "11. Restaurar reglas de iptables"
  echo "6. Salir"
}

# Función para bloquear tráfico por un puerto
block_traffic() {
  read -p "Ingrese el número de puerto que desea bloquear (o 'm' para regresar al menú): " port
  if [ "$port" == "m" ]; then
    return
  fi
  iptables -A INPUT -p tcp --dport $port -j DROP
  echo "El tráfico en el puerto $port ha sido bloqueado."
}

# Función para desbloquear tráfico por un puerto
unblock_traffic() {
  read -p "Ingrese el número de puerto que desea desbloquear (o 'm' para regresar al menú): " port
  if [ "$port" == "m" ]; then
    return
  fi
  iptables -D INPUT -p tcp --dport $port -j DROP
  echo "El tráfico en el puerto $port ha sido desbloqueado."
}

# Función para bloquear todas las conexiones entrantes excepto un puerto
block_all_except_port() {
  read -p "Ingrese el número de puerto que desea permitir (o 'm' para regresar al menú): " port
  if [ "$port" == "m" ]; then
    return
  fi
  iptables -A INPUT -p tcp --dport $port -j ACCEPT
  iptables -A INPUT -p tcp --dport 0:65535 -j DROP
  echo "Se han bloqueado todas las conexiones entrantes excepto en el puerto $port."
}

# Función para mostrar reglas iptables
show_rules() {
  echo "Reglas actuales de iptables:"
  iptables -L
}

# Función para limpiar todas las reglas iptables
flush_rules() {
  iptables -F
  echo "Se han limpiado todas las reglas iptables."
}

# Función para permitir tráfico por un rango de puertos
allow_port_range() {
  read -p "Ingrese el rango de puertos que desea permitir (p. ej., 80-88): " port_range
  if [ "$port_range" == "m" ]; then
    return
  fi
  iptables -A INPUT -p tcp --dport $port_range -j ACCEPT
  echo "Se ha permitido el tráfico en el rango de puertos $port_range."
}

# Función para bloquear una dirección IP
block_ip() {
  read -p "Ingrese la dirección IP que desea bloquear (o 'm' para regresar al menú): " ip_address
  if [ "$ip_address" == "m" ]; then
    return
  fi
  iptables -A INPUT -s $ip_address -j DROP
  echo "La dirección IP $ip_address ha sido bloqueada."
}

# Función para desbloquear una dirección IP
unblock_ip() {
  read -p "Ingrese la dirección IP que desea desbloquear (o 'm' para regresar al menú): " ip_address
  if [ "$ip_address" == "m" ]; then
    return
  fi
  iptables -D INPUT -s $ip_address -j DROP
  echo "La dirección IP $ip_address ha sido desbloqueada."
}

# Función para guardar reglas de iptables
save_rules() {
  iptables-save > /etc/iptables.rules
  echo "Las reglas de iptables se han guardado en /etc/iptables.rules."
}

# Función para restaurar reglas de iptables
restore_rules() {
  iptables-restore < /etc/iptables.rules
  echo "Las reglas de iptables se han restaurado desde /etc/iptables.rules."
}

# Manejo de Ctrl+C
trap ctrl_c SIGINT

function ctrl_c() {
  echo -e "\nSaliendo..."
  exit 0
}

# Bucle principal del programa
while true; do
  clear
  print_banner
  show_menu

  read -p "Opción: " option

  case $option in
    1)
      block_traffic
      ;;
    2)
      unblock_traffic
      ;;
    3)
      block_all_except_port
      ;;
    4)
      show_rules
      ;;
    5)
      flush_rules
      ;;
    6)
      echo "Saliendo..."
      exit 0
      ;;
    7)
      allow_port_range
      ;;
    8)
      block_ip
      ;;
    9)
      unblock_ip
      ;;
    10)
      save_rules
      ;;
    11)
      restore_rules
      ;;
    q)
      echo "Saliendo..."
      exit 0
      ;;
    *)
      echo "Opción inválida. Por favor, seleccione una opción válida."
      ;;
  esac

  read -p "Presione Enter para continuar..."
done
