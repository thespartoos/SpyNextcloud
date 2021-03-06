#!/bin/bash

#Author Alejandro Ruiz (Thespartoos)

# Colores

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# PASSWORDS --> MODIFICAR

#[!] IMPORTANTE MISMO ORDEN DE ARRIBA A ABAJO QUE http://IP/nextcloud/index.php/settings/users
#SI TIENE MAS NÚMERO DE USUARIO AGREGE NUEVA VARIALE COMO LAS DE ARRIBA

declare -r Adminuser='Administrador' # MOD
declare -r Adminpass='Calat10!' # MOD 
declare -r user1pass='alejandro123$!' # MOD
declare -r user2pass='david123$!' # MOD
declare -r user3pass='juan1234$!' # MOD
declare -r user4pass='Calat10!12' # MOD
declare -r user5pass='sagrario123$!' # MOD
declare -r user6pass='vicente123$!' # MOD

function urldecode(){
    sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b"
}

function ctrl_c(){
    echo -e "\n${redColour}[!] Saliendo...${endColour}\n"
    tput cnorm; exit 0
}

trap ctrl_c INT

function helpPanel(){
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Uso: ./nextcloud.sh${blueColour} [-s, -c]${endColour}${grayColour} http://site.com/nextcloud${endColour}${blueColour} [--more] [-h]${endColour}\n"
    echo -e "\t${purpleColour}s)${endColour}${yellowColour} SharedMode${endColour}\n\t\t${grayColour}Share all items of nextcloud' s users to Admin Example: http://localhost/nextcloud${endColour}\n"
    echo -e "\t${purpleColour}c)${endColour}${yellowColour} CopyMode${endColour}\n\t\t${grayColour}Copy all items of all nextcloud' s users to Admin Example: http://172.16.254.14/nextcloud${endColour}\n"
    echo -e "\t${purpleColour}h)${endColour}${yellowColour} Show help panel${endColour}\n"
    exit 0
}

function dependencies(){
    tput civis
    clear; dependencias=(curl xmllint unzip html2text)
    echo -e "${yellowColour}[*]${endColour}${grayColour} Comprobando programas necesarios...${endColour}"
    sleep 2

    for programa in "${dependencias[@]}"; do 
        echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Herramienta${endColour}${purpleColour} $programa${endColour}${blueColour}...${endColour} "
        test -f /usr/bin/$programa

        if [ "$(echo $?)" == "0" ]; then
            echo -e "${greenColour}(V)${endColour}"
        else
            echo -e "${redColour}(X)${endColour}"
            echo -e "${yellowColour}[*]${endColour}${grayColour} Instalando herramienta${endColour}${blueColour}$programa${endColour}${yellowColour}...${endColour}\n"
            yum install $programa -y > /dev/null 2>&1
        fi; sleep 2
    done

}

function ShareAdmin(){
    main_url="$1"
    clear
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Almacenando usuarios en una variable...${endColour}\n"
    declare -r usernames=$(curl -s -u "$Adminuser:$Adminpass" -X GET $main_url/ocs/v1.php/cloud/users -H "OCS-APIRequest: true" | grep -oP '<element(.*?)</element>' | sed 's/>/> /g' | sed 's/</ </g' | awk '{print $2}' | xargs)
    
    users=($usernames)
    passwords=($Adminpass $user1pass $user2pass $user3pass $user4pass $user5pass $user6pass) # MOD
    
    # CREAR CARPETAS ADMINISTRADOR
    sleep 1 && clear
    echo -e "\n${redColour}[!]${endColour}${grayColour} Creando las carpetas de los usuarios en ${endColour}${redColour}Admin${endColour} ${turquoiseColour}Nextcloud${endColour}"
    curl -s -u $Adminuser:$Adminpass -X PROPFIND $main_url/remote.php/dav/files/$Adminuser/ > prueba.xml
    xmllint --format prueba.xml | grep -oP '<d:href>(.*?)</d:href>' | sed 's/>/> /g' | sed 's/</ </g' | awk '{print $2}' | grep -v "/nextcloud/remote.php/dav/files/$Adminuser/$" >> user.txt
    
    if [ "$(cat user.txt | urldecode | awk 'NR==1')" == "/nextcloud/remote.php/dav/files/$Adminuser/$Adminuser/" ]; then
        
        echo -e "${greenColour}\n[+]${endColour}${grayColour} Las carpetas ya existen\n${endColour}"
        sleep 3; rm -rf user.txt 2>/dev/null && clear
    
    else
        
        for user in "${users[@]}"; do
            curl -s -u $Adminuser:$Adminpass -H "OCS-APIRequest: true" -X MKCOL $main_url/remote.php/dav/files/$Adminuser/$user
        done
        echo -e "\n${greenColour}[+]${endColour}${grayColour} Las carpetas se ha creado correctamente${endColour}"
        sleep 2
    fi

    number=0

    # CONSEGUIR DIRECTORIOS Y ARCHIVOS DE TODOS LOS USUARIOS
    for user in "${users[@]}"; do
        
        for pass in "${passwords[$number]}"; do
            
            curl -s -u $user:$pass -X PROPFIND $main_url/remote.php/dav/files/$user/ > prueba.xml
            clear; echo -e "\n${yellowColour}[+]${endColour}${grayColour} Almacenando recursos del usuario $user...${endColour}" && sleep 2
            echo -e "$user:" >> folders.txt
            for line in $(xmllint --format prueba.xml | grep -oP '<d:href>(.*?)</d:href>' | sed 's/>/> /g' | sed 's/</ </g' | awk '{print $2}' | grep -v "/nextcloud/remote.php/dav/files/$user/$"); do
                
                echo -e "$line" >> folders.txt
                
            done
            let number=number+=1
            break
        done
    done
    
    sleep 2; clear && clear

    # COMPARTIENDO CARPETAS Y FICHEROS A ADMINISTRADOR
    number=0

    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Compartiendo y Moviendo archivos a Administrador...${endColour}\n"
    for user in "${users[@]}"; do
        cat folders.txt | grep -v "$Adminuser"| grep "$user" | grep -v "$user:" > test.txt
        for pass in "${passwords[$number]}"; do
            cat test.txt | sed 's/\//\/ /g' | cut -d '/' -f 7 | sed 's/ //' | while read line; do
                curl -s -u $user:$pass -H "OCS-APIRequest: true" -X POST $main_url/ocs/v2.php/apps/files_sharing/api/v1/shares -d path=/$line -d shareType=0 -d permissions=15 -d shareWith=$Adminuser > /dev/null 2>/dev/null
                curl -s -u "$Adminuser:$Adminpass" -X MOVE "$main_url/remote.php/dav/files/$Adminuser/$line" -H "Destination: $main_url/remote.php/dav/files/$Adminuser/$user/$line" > /dev/null 2>/dev/null
            done
            let number=number+=1
            break
        done
    done

    echo -e "\n${greenColour}[+]${endColour}${grayColour} La operación ha sido completada correctamente${endColour}\n"
}

function CopyMode(){
    main_url="$1"
    mkdir folder 2>/dev/null && clear
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Almacenando usuarios en una variable...${endColour}\n"
    declare -r usernames=$(curl -s -u "$Adminuser:$Adminpass" -X GET $main_url/ocs/v1.php/cloud/users -H "OCS-APIRequest: true" | grep -oP '<element(.*?)</element>' | sed 's/>/> /g' | sed 's/</ </g' | awk '{print $2}' | xargs)
    
    users=($usernames)
    passwords=($Adminpass $user1pass $user2pass $user3pass $user4pass $user5pass $user6pass) # MOD
    
    # CREAR CARPETAS ADMINISTRADOR
    sleep 1 && clear
    echo -e "\n${redColour}[!]${endColour}${grayColour} Creando las carpetas de los usuarios en ${endColour}${redColour}Admin${endColour} ${turquoiseColour}Nextcloud${endColour}"
    curl -s -u $Adminuser:$Adminpass -X PROPFIND $main_url/remote.php/dav/files/$Adminuser/ > prueba.xml
    xmllint --format prueba.xml | grep -oP '<d:href>(.*?)</d:href>' | sed 's/>/> /g' | sed 's/</ </g' | awk '{print $2}' | grep -v "/nextcloud/remote.php/dav/files/Administrador/$" >> user.txt
    
    if [ "$(cat user.txt | urldecode | awk 'NR==1')" == "/nextcloud/remote.php/dav/files/$Adminuser/$Adminuser/" ]; then
        
        echo -e "${greenColour}\n[+]${endColour}${grayColour} Las carpetas ya existen\n${endColour}"
        sleep 3; rm -rf user.txt 2>/dev/null && clear
    
    else
        
        for user in "${users[@]}"; do
            curl -s -u $Adminuser:$Adminpass -H "OCS-APIRequest: true" -X MKCOL $main_url/remote.php/dav/files/$Adminuser/$user
        done
        echo -e "\n${greenColour}[+]${endColour}${grayColour} Las carpetas se ha creado correctamente${endColour}"
        sleep 2
    fi

    number=0

    # CONSEGUIR DIRECTORIOS Y ARCHIVOS DE TODOS LOS USUARIOS
    for user in "${users[@]}"; do
        
        for pass in "${passwords[$number]}"; do
            
            curl -s -u $user:$pass -X PROPFIND $main_url/remote.php/dav/files/$user/ > prueba.xml
            clear; echo -e "\n${yellowColour}[+]${endColour}${grayColour} Almacenando recursos del usuario $user...${endColour}" && sleep 2
            echo -e "$user:" >> folders.txt
            
            for line in $(xmllint --format prueba.xml | grep -oP '<d:href>(.*?)</d:href>' | sed 's/>/> /g' | sed 's/</ </g' | awk '{print $2}' | grep -v "/nextcloud/remote.php/dav/files/$user/$"); do
                
                echo -e "$line" >> folders.txt
                
            done
            let number=number+=1
            break
        done
    done

    # COPIAR DIRECTORIOS Y FICHEROS A ADMINISTRADOR
    sleep 1; clear && clear
    number=0

    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Compartiendo y Moviendo archivos a Administrador...${endColour}\n"
    count=1
    for user in "${users[@]}"; do
        for pass in "${passwords[$number]}"; do
            
            curl -s -u $user:$pass -X PROPFIND $main_url/remote.php/dav/files/$user/ > test.xml
            xmllint --format test.xml | grep -oP '<d:href>(.*?)</d:href>' | sed 's/>/> /g' | sed 's/</ </g' | awk '{print $2}' | grep -v "/nextcloud/remote.php/dav/files/$user/$" > test.txt
            folder=$(cat test.txt | grep "$user" | sed 's/\//\/ /g' | cut -d '/' -f 7 | sed 's/\/ /\//' | tr -d ' ' | grep -v "\.")
            curl -s -u $user:$pass -X GET "$main_url/index.php/apps/files/ajax/download.php?dir=%2F&files=$folder" --output ./folder/$folder.zip >/dev/null 2>/dev/null
            curl -s -u $Adminuser:$Adminpass -X PUT "$main_url/remote.php/dav/files/$Adminuser/$user/$folder.zip" -T "./folder/$folder.zip" >/dev/null 2>/dev/null
            curl -s -u $user:$pass -X PROPFIND $main_url/remote.php/dav/files/$user/ > test.xml
            xmllint --format test.xml | grep -oP '<d:href>(.*?)</d:href>' | sed 's/>/> /g' | sed 's/</ </g' | awk '{print $2}' | grep -v "/nextcloud/remote.php/dav/files/$user/$" > test.txt
            
            for file in $(cat test.txt | grep "$user" | sed 's/\//\/ /g' | cut -d '/' -f 7 | sed 's/\/ /\//' | tr -d ' ' | grep "\." ); do
                curl -s -u $user:$pass -H "OCS-APIRequest: true" -X GET $main_url/remote.php/dav/files/$user/$file --output folder/$file >/dev/null 2>/dev/null
                curl -s -u $Adminuser:$Adminpass -X PUT $main_url/remote.php/dav/files/$Adminuser/$user/$file -T ./folder/$file >/dev/null 2>/dev/null
            done
            let number=number+=1
            break    
        done
    done

    echo -e "\n${greenColour}[+]${endColour}${grayColour} La operacion ha sido completada correctamente${endColour}\n"
}

# Ejecucion Programa

declare -i parameter_counter=0; while getopts "s:c:h" arg; do
    case $arg in
        s) main_url=$OPTARG; let parameter_counter+=1;;
        c) main_url=$OPTARG; let parameter_counter+=2;;
        h) helpPanel;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
    dependencies
    ShareAdmin "$main_url"
    rm -rf folder/* 2>/dev/null
    tput cnorm; rm -rf folders.txt 2>/dev/null
elif [ $parameter_counter -eq 2 ]; then
    dependencies
    CopyMode "$main_url"
    tput cnorm; rm -rf folders.txt 2>/dev/null
else
    helpPanel
fi

