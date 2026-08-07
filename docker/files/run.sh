#!/bin/bash


if [ -n "$1" ]; then
    arg1=$(type -P $1)

    if [ -x "${arg1}" ]; then
        set -x
        exec $@
    fi
fi

msg() {
    echo -e "\033[42;30m\033[J>> $*\033[0m"
}

error() {
    local delay=${ERROR_DELAY:-3600}
    echo -e "\033[41;30m\033[JERROR: $*\nSLEEPING ${delay} SECONDS BEFORE EXIT.\033[0m"
    sleep ${delay}
    exit ${2:-100}
}

warning() {
    echo -e "\033[43;30m\033[JWARNING: $*\033[0m"
    echo -n "Pausing "
    for i in 5 4 3 2 1
    do
        echo -n "${i}..."
    done
    echo "continuing."
}

if [ ! -d "${HOME_DIR}/mysql" ]; then
    source /firstboot/functions
    core3_firstboot
fi

# core3_boot() {
#     if [ -f ${HOME_DIR}/.env ]; then
#         source ${HOME_DIR}/.env
#     else
#         env |
#         egrep -v '^SHELL=|^PWD=|^LOGNAME=|^HOME=|^LANG=|^LS_COLORS=|^TERM=|^USER=|^SHLVL=|^PATH=|^MAIL=|^OLDPWD=|^_=' |
#         sort |
#         sed -e "s/=\(.*\)$/='\1'/" -e 's/^/export /' > ${HOME_DIR}/.env
#         chown ${RUN_USER}:${RUN_USER} ${HOME_DIR}/.env
#     fi
# }

core3_boot() {
    if [ -f ${HOME_DIR}/.env ]; then
        source ${HOME_DIR}/.env
    else
        env |
        egrep -v '^SHELL=|^PWD=|^LOGNAME=|^HOME=|^LANG=|^LS_COLORS=|^TERM=|^USER=|^SHLVL=|^PATH=|^MAIL=|^OLDPWD=|^_=' |
        sort |
        sed -e "s/=\(.*\)$/='\1'/" -e 's/^/export /' > ${HOME_DIR}/.env
        chown ${RUN_USER}:${RUN_USER} ${HOME_DIR}/.env
    fi

    if [ "${DBHOST}" = "127.0.0.1" ]; then
        /etc/init.d/mariadb start
    fi
}

# # Ensure the persistent mysql directory exists
# mkdir -p "${HOME_DIR}/mysql"

# # If /var/lib/mysql isn't a symlink, replace it.
# if [ ! -L /var/lib/mysql ]; then
#     rm -rf /var/lib/mysql
#     ln -s "${HOME_DIR}/mysql" /var/lib/mysql
# fi

core3_boot

msg "Starting interactive shell..."

set -x

exec /bin/su - ${RUN_USER}
