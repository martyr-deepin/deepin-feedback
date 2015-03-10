#!/bin/bash

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street, Fifth
# Floor, Boston, MA 02110-1301, USA.

###* Basic Configuration
LC_ALL=C

app_file="${0}"
app_name="$(basename $0)"

real_home="${HOME}"
if [ "${SUDO_USER}" ]; then
    real_home="/home/${SUDO_USER}"
fi

opt_sliceinfo_func_list=("sliceinfo_basic")
opt_syslog_include=()

###* Help Functions
msg() {
  local mesg=${1}; shift
  printf "${GREEN}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "${@}" >&2
}

msg2() {
  local mesg=${1}; shift
  printf "${BLUE}  ->${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "${@}" >&2
}

warning() {
  local mesg=${1}; shift
  printf "${YELLOW}==> $(gettext "WARNING:")${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "${@}" >&2
}

msg_title() {
    local msg="${1}"; shift
    printf "\n# ${msg}\n\n" ${@}
}

msg_code() {
    printf "%s" "${@}" | sed 's/^/    /'
    printf "\n"
}

setup_color_message() {
  unset ALL_OFF BOLD BLUE GREEN RED YELLOW
  if [[ -t 2 && $USE_COLOR != "n" ]]; then
      # prefer terminal safe colored and bold text when tput is supported
      if tput setaf 0 &>/dev/null; then
          ALL_OFF="$(tput sgr0)"
          BOLD="$(tput bold)"
          BLUE="${BOLD}$(tput setaf 4)"
          GREEN="${BOLD}$(tput setaf 2)"
          RED="${BOLD}$(tput setaf 1)"
          YELLOW="${BOLD}$(tput setaf 3)"
      else
        ALL_OFF="\e[0m"
        BOLD="\e[1m"
        BLUE="${BOLD}\e[34m"
        GREEN="${BOLD}\e[32m"
        RED="${BOLD}\e[31m"
        YELLOW="${BOLD}\e[33m"
      fi
  fi
}
setup_color_message

get_self_funcs() {
    grep -o "^${1}.*()" "${app_file}" | sed "s/^\(.*\)()/\1/" | sort
}

get_category_funcs() {
    get_self_funcs "category_" | sed 's/category_/        /g'
}

get_sliceinfo_funcs() {
    get_self_funcs "sliceinfo_" | sed 's/sliceinfo_/        /g'
}

grep_block() {
    local keyword="$1"; shift
    local files=$@
    awk -v keyword="${keyword}" 'BEGIN{RS="\n\n"; n=0} $0 ~ keyword{print ""; print; n++} END{print n, "of", NR, "matched", keyword}' $files
}

# collect_file <category> <files...>
collect_file() {
    local category="${1}"; shift
    for f in ${@}; do
        do_collect_file "${category}" "${f}"
    done
}
do_collect_file() {
    local category="${1}"; shift
    local child_dest_dir="${dest_dir}/${category}/$(dirname "${1}")"
    mkdir -p "${child_dest_dir}"
    cp -fR -t "${child_dest_dir}" "$(echo "${1}" | sed "s#^~#${real_home}#")"
}

###* Functions to Get Certain System Information
sliceinfo_basic() {
    msg_title "Computer Model"
    msg_code "$(do_sliceinfo_basic_computer_model)"

    msg_title "Linux Release"
    msg_code "$(lsb_release -a 2>&1)"

    msg_title "Linux Kernel"
    msg_code "$(uname -a)"

    msg_title "Installed Deepin Packages"
    msg_code "$(dpkg -l | grep -i -e 'deepin-' -e 'dde-')"
}
do_sliceinfo_basic_computer_model() {
    # need root permission
    for f in /sys/class/dmi/id/*; do
        if [ -f "${f}" -a -r "${f}" ]; then
            printf "%s:\t%s\n" $f "$(cat $f)";
        fi
    done
}

sliceinfo_service() {
    initctl list | column -t
}

sliceinfo_env() {
    env
}

sliceinfo_package() {
    dpkg -l
}

sliceinfo_device() {
    msg_title "CPU"
    msg_code "$(cat /proc/cpuinfo)"

    msg_title "Memory"
    msg_code "$(free -t -h)"
    msg_code "$(cat /proc/meminfo)"

    msg_title "USB Devices"
    msg_code "$(lsusb)"

    msg_title "PCI Devices"
    msg_code "$(lspci -vvnn)"

    # need root permission
    msg_title "Hardware Lister(lshw)"
    msg_code "$(lshw 2>/dev/null)"
}

sliceinfo_driver() {
    msg_title "Loaded Drivers"
    msg_code "$(lsmod)"

    msg_title "Driver Modules File"
    msg_code "$(cat /etc/modules)"

    msg_title "Driver Blacklist File"
    msg_code "$(do_sliceinfo_driver_blacklist)"

    msg_title "Installed Driver Packages"
    msg_code "$(dpkg -l | grep -e driver -e catalyst -e nvidia)"
}
do_sliceinfo_driver_blacklist() {
    for f in /etc/modprobe.d/*; do
        printf "${f}\n"
    done
    printf "\n\n"
    for f in /etc/modprobe.d/*; do
        printf "\n## ${f}\n"
        cat "${f}"
    done
}

sliceinfo_kernel() {
    cat /var/log/dmesg
}

sliceinfo_video() {
    msg_title "Video Devices"
    msg_code "$(lspci -vvnn | grep_block 'VGA ')"

    msg_title "Video Driver Packages"
    msg_code "$(dpkg -l | grep -e xorg-video -e catalyst -e nvidia)"
}

sliceinfo_network() {
    msg_title "Network Devices"
    if ! is_sliceinfo_device_will_run; then
        msg_code "$(lshw -C network 2>/dev/null)"
    fi
    msg_code "$(lspci -vvnn | grep_block '[nN]etwork|[eE]thernet')"
    msg_code "$(lsusb -v 2>/dev/null | grep_block '[nN]et|[eE]thernet')"

    msg_title "Network Status"
    msg_code "$(ifconfig -v -a)"
    msg_code "$(iwconfig 2>/dev/null)"

    msg_title "NetworkManager State"
    msg_code "$(nmcli nm status)"
    msg_code "$(nmcli con list)"
    msg_code "$(nm-tool)"

    msg_title "ModemManager State"
    msg_code "$(mmcli -L)"

    msg_title "Wireless Device Switches(rfkill)"
    msg_code "$(rfkill list all)"

    msg_title "Wireless Access Points"
    msg_code "$(iwlist scan 2>/dev/null)"

    msg_title "Network Interface File"
    msg_code "$(cat /etc/network/interfaces)"

    msg_title "DNS Configuration(resolv.conf)"
    msg_code "$(cat /etc/resolv.conf)"

    msg_title "Route Table"
    msg_code "$(route)"
}

sliceinfo_bluetooth() {
    msg_title "Bluetooth Devices"
    msg_code "$(hciconfig -a)"
    msg_code "$(lspci -vvnn | grep_block '[bB]luetooth')"
    msg_code "$(lsusb | grep -i bluetooth)"

    msg_title "Loaded Bluetooth Drivers"
    msg_code "$(lsmod | grep -e btusb -e bluetooth -e hidp -e rfcomm)"

    msg_title "Wireless Device Switches(rfkill)"
    msg_code "$(rfkill list all)"
}

sliceinfo_bootmgr() {
    msg_title "Boot Files"
    msg_code "$(find /boot)"
    if [ -d "/sys/firmware/efi" ]; then
        msg_title "EFI Information"
        msg_code "$(efibootmgr -v)"
    fi
}

sliceinfo_disk() {
    # need root permission
    if ! is_sliceinfo_device_will_run; then
        msg_title "Disk Devices"
        msg_code "$(lshw -C disk -C storage 2>/dev/null)"
    fi

    msg_title "Disk Partition Table"
    msg_code "$(lsblk)"
}

sliceinfo_aptlog() {
    zcat /var/log/apt/history.log.1.gz 2>/dev/null
    cat /var/log/apt/history.log 2>/dev/null
}

sliceinfo_apttermlog() {
    zcat /var/log/apt/term.log.1.gz 2>/dev/null
    cat /var/log/apt/term.log 2>/dev/null
}

sliceinfo_syslog() {
    if [ ${#opt_syslog_include[@]} -gt 0 ]; then
        cat /var/log/syslog{.1,} 2>/dev/null | grep -i ${opt_syslog_include[@]}
    else
        cat /var/log/syslog{.1,} 2>/dev/null
    fi
}
include_syslog_keyword() {
    local len=${#opt_syslog_include[@]}
    opt_syslog_include[$len]="-e"
    ((len++))
    opt_syslog_include[$len]="${1}"
}

include_sliceinfo() {
    local len=${#opt_sliceinfo_func_list[@]}
    opt_sliceinfo_func_list[$len]="sliceinfo_${1}"
}
is_sliceinfo_device_will_run() {
    for f in ${opt_sliceinfo_func_list[@]}; do
        if [ "${f}" = "sliceinfo_device" ]; then
            return 0
        fi
    done
    return 1
}
exec_sliceinfo_funcs() {
    for f in ${opt_sliceinfo_func_list[@]}; do
        msg2 "executing ${f}..."
        case "${f}" in
            "sliceinfo_service") "${f}" >> "${file_service}";;
            "sliceinfo_env")     "${f}" >> "${file_env}";;
            "sliceinfo_package") "${f}" >> "${file_package}";;
            "sliceinfo_bootmgr") "${f}" >> "${file_bootmgr}";;
            "sliceinfo_device")  "${f}" >> "${file_device}";;
            "sliceinfo_driver")  "${f}" >> "${file_driver}";;
            "sliceinfo_kernel")  "${f}" >> "${file_kernel}";;
            "sliceinfo_aptlog")  "${f}" >> "${file_aptlog}";;
            "sliceinfo_apttermlog")  "${f}" >> "${file_apttermlog}";;
            "sliceinfo_syslog")  "${f}" >> "${file_syslog}";;
            *)              "${f}" >> "${file_master}";;
        esac
    done
}

###* Categories
category_all() {
    # clean predefined options and execute all functions that could
    # get system information
    for f in $(get_category_funcs); do
        if [ "${f}" != "all" ]; then
            category_"${f}"
        fi
    done

    opt_sliceinfo_func_list=()
    for f in $(get_sliceinfo_funcs); do
        include_sliceinfo "${f}"
    done
}

category_background() {
    include_sliceinfo "syslog"
    include_syslog_keyword "com.deepin.SessionManager"
    include_syslog_keyword "com.deepin.daemon.ThemeManager"
    msg_title "GSettings Key-Values for Background" >> "${file_gsettings}"
    msg_code "$(gsettings list-recursively com.deepin.dde.personalization)"  >> "${file_gsettings}"
}

category_bluetooth() {
    include_sliceinfo "bluetooth"
    include_sliceinfo "kernel"
    include_sliceinfo "driver"
    include_sliceinfo "syslog"
    include_syslog_keyword "com.deepin.daemon.Bluetooth"
    include_syslog_keyword "bluetooth"
    collect_file "bluetooth" "~/.config/deepin/bluetooth.json"
}

category_bootmgr() {
    include_sliceinfo "bootmgr"
    include_sliceinfo "disk"
    include_sliceinfo "syslog"
    include_syslog_keyword "com.deepin.daemon.Grub2"
    include_syslog_keyword "com.deepin.daemon.Grub2Ext"
    collect_file "bootmgr" /boot/grub/grub.cfg
    collect_file "bootmgr" /etc/default/grub
    collect_file "bootmgr" /var/cache/deepin/grub2.json
}

category_display() {
    include_sliceinfo "video"
    include_sliceinfo "syslog"
    include_syslog_keyword "com.deepin.SessionManager"
    include_syslog_keyword "com.deepin.daemon.Display"
    collect_file "display" "~/.config/deepin_monitors.json"
}

category_desktop() {
    collect_file "desktop" "/tmp/dde-desktop.log"
}

category_dock() {
    include_sliceinfo "syslog"
    include_syslog_keyword "com.deepin.daemon.Dock"
    collect_file "dock" "/tmp/dde-dock.log"
}

category_launcher() {
    include_sliceinfo "syslog"
    include_syslog_keyword "dde-daemon/launcher-daemon"
    collect_file "launcher" "/tmp/dde-launcher.log"
}

category_login() {
    include_sliceinfo "syslog"
    include_syslog_keyword "com.deepin.SessionManager"
    include_syslog_keyword "com.deepin.daemon.Display"
    collect_file "login" "~/.xsession-errors"
    collect_file "login" "/var/log/lightdm" # need root permission
}

category_network() {
    include_sliceinfo "network"
    include_sliceinfo "driver"
    include_sliceinfo "syslog"
    include_sliceinfo "env"
    include_syslog_keyword "com.deepin.daemon.Network"
    include_syslog_keyword "NetworkManager"
    include_syslog_keyword "ModemManager"
    include_syslog_keyword "wpa_supplicant"
    include_syslog_keyword "dhclient"
    include_syslog_keyword "dnsmasq"
    include_syslog_keyword "avahi-daemon"
    collect_file "network" "~/.config/deepin/network.json"
}

###* Main
arg_category="all"              # if no arguments, just execute rules in category_all()
arg_sliceinfo_type=
arg_complete_opt=
arg_outputfile=
arg_maxsize=5242880             # 5MB
arg_help=

show_usage() {
    cat <<EOF
${app_name} [-d <sliceinfo>] [-o <filename>] [-m <maxsize>] [-h] [<category>]
Options:
    -d, --dump, print system slice information, the type coulde be:
$(get_sliceinfo_funcs)
    -o, --output, customize the output file
    -m, --maxsize, set single archive file's maximize size
    -h, --help, show this message

    If there is no other arguments, ${app_name} will collect debug
    information for special category and save it to archive file in
    current directory, the category could be (default: all):
$(get_category_funcs)
EOF
    exit 1
}

# dispatch arguments
while [ ${#} -gt 0 ]; do
    case ${1} in
        -d|--dump) arg_sliceinfo_type="${2}"; arg_category=""; shift; shift; break;;
        -o|--output) arg_outputfile="${2}"; shift; shift;;
        -m|--maxsize) arg_maxsize="${2}"; shift; shift;;
        -h|--help) arg_help=t; break;;
        -C|--complete) arg_complete_opt="${2}"; shift; shift; break;;
        *)  arg_category="${1}"; shift; break;;
    esac
done

if [ "${arg_help}" ]; then
    show_usage
fi

if [ "${arg_complete_opt}" ]; then
    case "${arg_complete_opt}" in
        -p) get_sliceinfo_funcs;;
        *)  get_category_funcs;;
    esac
    exit
fi

if [ "${arg_sliceinfo_type}" ]; then
    case "${arg_sliceinfo_type}" in
        syslog)
            for a in ${@}; do
                include_syslog_keyword "${a}"
            done;;
    esac
    sliceinfo_"${arg_sliceinfo_type}"
    exit
fi

if [ "${arg_category}" ]; then
    # ensure this script running as root
    if [ ! "${UID}" -eq 0 ]; then
        printf "please run ${app_name} as root, just use: sudo ${app_name}"
        exit 1
    fi

    # global variables
    result_tag="${app_name}-results-${arg_category}-$(date "+%Y%m%d-%s")"
    dest_dir="/tmp/${result_tag}"
    result_archive="${arg_outputfile:-${result_tag}.tar.gz}"
    file_master="${dest_dir}/sysinfo.md"
    file_aptlog="${dest_dir}/aptlog"
    file_apttermlog="${dest_dir}/apttermlog"
    file_syslog="${dest_dir}/syslog"
    file_service="${dest_dir}/services"
    file_env="${dest_dir}/env"
    file_package="${dest_dir}/packages"
    file_bootmgr="${dest_dir}/bootmgr.md"
    file_device="${dest_dir}/devices.md"
    file_driver="${dest_dir}/drivers.md"
    file_kernel="${dest_dir}/dmesg"
    file_gsettings="${dest_dir}/gsettings.md"

    msg "Collecting system information and this will take several seconds..."

    # prepare
    msg "Preparing temporary folder ${dest_dir}..."
    rm -rf "${dest_dir}"
    mkdir -p "${dest_dir}"

    # execute rules of category
    msg "Execute rules of category '${arg_category}'..."
    if ! category_"${arg_category}"; then
        exit 1
    fi
    exec_sliceinfo_funcs

    # archive files
    msg "Archive files..."
    dest_files=$(ls -1 "${dest_dir}" | tr "\n" " ")
    tar -cvzf "${result_archive}" -C "${dest_dir}" ${dest_files}

    # split archive file if need
    archive_size="$(stat -c "%s" "${result_archive}")"
    if [ "${archive_size}" -ge "${arg_maxsize}" ]; then
        msg "Split archive file..."
        rm -vf "${result_archive}".part.*
        split -b "${arg_maxsize}" -d "${result_archive}" "${result_archive}".part.
        rm -f "${result_archive}"
    fi

    msg "Finished, please report a bug to Deepin team with ${result_archive} in current folder as an attachment:"
    msg2 "http://www.linuxdeepin.com/mantis/bug_report_page.php"
    exit
fi



# Local Variables:
# mode: sh
# mode: orgstruct
# orgstruct-heading-prefix-regexp: "^\s*###"
# End:
