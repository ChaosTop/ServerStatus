#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: ServerStatus client + server
#	Version: 1.0.15
#	Author: Toyo
#	Blog: https://doub.io/shell-jc3/
#=================================================

sh_ver="1.0.15"
filepath=$(cd "$(dirname "$0")"; pwd)
file_1=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
file="/usr/local/ServerStatus"
web_file="/usr/local/ServerStatus/web"
server_file="/usr/local/ServerStatus/server"
server_conf="/usr/local/ServerStatus/server/config.json"
server_conf_1="/usr/local/ServerStatus/server/config.conf"
client_file="/usr/local/ServerStatus/client"
client_log_file="/tmp/serverstatus_client.log"
server_log_file="/tmp/serverstatus_server.log"
jq_file="${file}/jq"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[��Ϣ]${Font_color_suffix}"
Error="${Red_font_prefix}[����]${Font_color_suffix}"
Tip="${Green_font_prefix}[ע��]${Font_color_suffix}"

#���ϵͳ
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}
check_installed_server_status(){
	[[ ! -e "${server_file}/sergate" ]] && echo -e "${Error} ServerStatus �����û�а�װ������ !" && exit 1
}
check_installed_client_status(){
	if [[ ! -e "${client_file}/status-client.py" ]]; then
		if [[ ! -e "${file}/status-client.py" ]]; then
			echo -e "${Error} ServerStatus �ͻ���û�а�װ������ !" && exit 1
		fi
	fi
}
check_pid_server(){
	PID=`ps -ef| grep "sergate"| grep -v grep| grep -v ".sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}'`
}
check_pid_client(){
	PID=`ps -ef| grep "status-client.py"| grep -v grep| grep -v ".sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}'`
}
Download_Server_Status_server(){
	cd "/tmp"
	wget -N --no-check-certificate "https://github.com/ImYrS/ServerStatu/archive/master.zip"
	[[ ! -e "master.zip" ]] && echo -e "${Error} ServerStatus ���������ʧ�� !" && exit 1
	unzip master.zip
	rm -rf master.zip
	[[ ! -e "/tmp/ServerStatus-Toyo-master" ]] && echo -e "${Error} ServerStatus ����˽�ѹʧ�� !" && exit 1
	cd "/tmp/ServerStatus-Toyo-master/server"
	make
	[[ ! -e "sergate" ]] && echo -e "${Error} ServerStatus ����˱���ʧ�� !" && cd "${file_1}" && rm -rf "/tmp/ServerStatus-Toyo-master" && exit 1
	cd "${file_1}"
	[[ ! -e "${file}" ]] && mkdir "${file}"
	if [[ ! -e "${server_file}" ]]; then
		mkdir "${server_file}"
		mv "/tmp/ServerStatus-Toyo-master/server/sergate" "${server_file}/sergate"
		mv "/tmp/ServerStatus-Toyo-master/web" "${web_file}"
	else
		if [[ -e "${server_file}/sergate" ]]; then
			mv "${server_file}/sergate" "${server_file}/sergate1"
			mv "/tmp/ServerStatus-Toyo-master/server/sergate" "${server_file}/sergate"
		else
			mv "/tmp/ServerStatus-Toyo-master/server/sergate" "${server_file}/sergate"
			mv "/tmp/ServerStatus-Toyo-master/web" "${web_file}"
		fi
	fi
	if [[ ! -e "${server_file}/sergate" ]]; then
		echo -e "${Error} ServerStatus ������ƶ�������ʧ�� !"
		[[ -e "${server_file}/sergate1" ]] && mv "${server_file}/sergate1" "${server_file}/sergate"
		rm -rf "/tmp/ServerStatus-Toyo-master"
		exit 1
	else
		[[ -e "${server_file}/sergate1" ]] && rm -rf "${server_file}/sergate1"
		rm -rf "/tmp/ServerStatus-Toyo-master"
	fi
}
Download_Server_Status_client(){
	cd "/tmp"
	wget -N --no-check-certificate "https://raw.githubusercontent.com/ImYrS/ServerStatus/master/clients/status-client.py"
	[[ ! -e "status-client.py" ]] && echo -e "${Error} ServerStatus �ͻ�������ʧ�� !" && exit 1
	cd "${file_1}"
	[[ ! -e "${file}" ]] && mkdir "${file}"
	if [[ ! -e "${client_file}" ]]; then
		mkdir "${client_file}"
		mv "/tmp/status-client.py" "${client_file}/status-client.py"
	else
		if [[ -e "${client_file}/status-client.py" ]]; then
			mv "${client_file}/status-client.py" "${client_file}/status-client1.py"
			mv "/tmp/status-client.py" "${client_file}/status-client.py"
		else
			mv "/tmp/status-client.py" "${client_file}/status-client.py"
		fi
	fi
	if [[ ! -e "${client_file}/status-client.py" ]]; then
		echo -e "${Error} ServerStatus �ͻ����ƶ�ʧ�� !"
		[[ -e "${client_file}/status-client1.py" ]] && mv "${client_file}/status-client1.py" "${client_file}/status-client.py"
		rm -rf "/tmp/status-client.py"
		exit 1
	else
		[[ -e "${client_file}/status-client1.py" ]] && rm -rf "${client_file}/status-client1.py"
		rm -rf "/tmp/status-client.py"
	fi
}
Service_Server_Status_server(){
	if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate "https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/service/server_status_server_centos" -O /etc/init.d/status-server; then
			echo -e "${Error} ServerStatus ����˷������ű�����ʧ�� !" && exit 1
		fi
		chmod +x /etc/init.d/status-server
		chkconfig --add status-server
		chkconfig status-server on
	else
		if ! wget --no-check-certificate "https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/service/server_status_server_debian" -O /etc/init.d/status-server; then
			echo -e "${Error} ServerStatus ����˷������ű�����ʧ�� !" && exit 1
		fi
		chmod +x /etc/init.d/status-server
		update-rc.d -f status-server defaults
	fi
	echo -e "${Info} ServerStatus ����˷������ű�������� !"
}
Service_Server_Status_client(){
	if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate "https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/service/server_status_client_centos" -O /etc/init.d/status-client; then
			echo -e "${Error} ServerStatus �ͻ��˷������ű�����ʧ�� !" && exit 1
		fi
		chmod +x /etc/init.d/status-client
		chkconfig --add status-client
		chkconfig status-client on
	else
		if ! wget --no-check-certificate "https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/service/server_status_client_debian" -O /etc/init.d/status-client; then
			echo -e "${Error} ServerStatus �ͻ��˷������ű�����ʧ�� !" && exit 1
		fi
		chmod +x /etc/init.d/status-client
		update-rc.d -f status-client defaults
	fi
	echo -e "${Info} ServerStatus �ͻ��˷������ű�������� !"
}
Installation_dependency(){
	mode=$1
	[[ -z ${mode} ]] && mode="server"
	if [[ ${mode} == "server" ]]; then
		python_status=$(python --help)
		if [[ ${release} == "centos" ]]; then
			yum update
			if [[ -z ${python_status} ]]; then
				yum install -y python unzip vim make
				yum groupinstall "Development Tools" -y
			else
				yum install -y unzip vim make
				yum groupinstall "Development Tools" -y
			fi
		else
			apt-get update
			if [[ -z ${python_status} ]]; then
				apt-get install -y python unzip vim build-essential make
			else
				apt-get install -y unzip vim build-essential make
			fi
		fi
	else
		python_status=$(python --help)
		if [[ ${release} == "centos" ]]; then
			if [[ -z ${python_status} ]]; then
				yum update
				yum install -y python
			fi
		else
			if [[ -z ${python_status} ]]; then
				apt-get update
				apt-get install -y python
			fi
		fi
	fi
}
Write_server_config(){
	cat > ${server_conf}<<-EOF
{"servers":
 [
  {
   "username": "username01",
   "password": "password",
   "name": "Server 01",
   "type": "KVM",
   "host": "",
   "location": "Hong Kong",
   "disabled": false
  }
 ]
}
EOF
}
Write_server_config_conf(){
	cat > ${server_conf_1}<<-EOF
PORT = ${server_port_s}
EOF
}
Read_config_client(){
	if [[ ! -e "${client_file}/status-client.py" ]]; then
		if [[ ! -e "${file}/status-client.py" ]]; then
			echo -e "${Error} ServerStatus �ͻ����ļ������� !" && exit 1
		else
			client_text="$(cat "${file}/status-client.py"|sed 's/\"//g;s/,//g;s/ //g')"
			rm -rf "${file}/status-client.py"
		fi
	else
		client_text="$(cat "${client_file}/status-client.py"|sed 's/\"//g;s/,//g;s/ //g')"
	fi
	client_server="$(echo -e "${client_text}"|grep "SERVER="|awk -F "=" '{print $2}')"
	client_port="$(echo -e "${client_text}"|grep "PORT="|awk -F "=" '{print $2}')"
	client_user="$(echo -e "${client_text}"|grep "USER="|awk -F "=" '{print $2}')"
	client_password="$(echo -e "${client_text}"|grep "PASSWORD="|awk -F "=" '{print $2}')"
}
Read_config_server(){
	if [[ ! -e "${server_conf_1}" ]]; then
		server_port_s="35601"
		Write_server_config_conf
		server_port="35601"
	else
		server_port="$(cat "${server_conf_1}"|grep "PORT = "|awk '{print $3}')"
	fi
}
Set_server(){
	mode=$1
	[[ -z ${mode} ]] && mode="server"
	if [[ ${mode} == "server" ]]; then
		echo -e "������ ServerStatus ���������վҪ���õ� ����[server]
Ĭ��Ϊ����IPΪ��������������: toyoo.pw �����Ҫʹ�ñ���IP��������ֱ�ӻس�"
		read -e -p "(Ĭ��: ����IP):" server_s
		[[ -z "$server_s" ]] && server_s=""
	else
		echo -e "������ ServerStatus ����˵� IP/����[server]"
		read -e -p "(Ĭ��: 127.0.0.1):" server_s
		[[ -z "$server_s" ]] && server_s="127.0.0.1"
	fi
	
	echo && echo "	================================================"
	echo -e "	IP/����[server]: ${Red_background_prefix} ${server_s} ${Font_color_suffix}"
	echo "	================================================" && echo
}
Set_server_http_port(){
	while true
		do
		echo -e "������ ServerStatus ���������վҪ���õ� ����/IP�Ķ˿�[1-65535]������������Ļ���һ���� 80 �˿ڣ�"
		read -e -p "(Ĭ��: 8888):" server_http_port_s
		[[ -z "$server_http_port_s" ]] && server_http_port_s="8888"
		echo $((${server_http_port_s}+0)) &>/dev/null
		if [[ $? -eq 0 ]]; then
			if [[ ${server_http_port_s} -ge 1 ]] && [[ ${server_http_port_s} -le 65535 ]]; then
				echo && echo "	================================================"
				echo -e "	�˿�: ${Red_background_prefix} ${server_http_port_s} ${Font_color_suffix}"
				echo "	================================================" && echo
				break
			else
				echo "�������, ��������ȷ�Ķ˿ڡ�"
			fi
		else
			echo "�������, ��������ȷ�Ķ˿ڡ�"
		fi
	done
}
Set_server_port(){
	while true
		do
		echo -e "������ ServerStatus ����˼����Ķ˿�[1-65535]�����ڷ���˽��տͻ�����Ϣ�Ķ˿ڣ��ͻ���Ҫ��д����˿ڣ�"
		read -e -p "(Ĭ��: 35601):" server_port_s
		[[ -z "$server_port_s" ]] && server_port_s="35601"
		echo $((${server_port_s}+0)) &>/dev/null
		if [[ $? -eq 0 ]]; then
			if [[ ${server_port_s} -ge 1 ]] && [[ ${server_port_s} -le 65535 ]]; then
				echo && echo "	================================================"
				echo -e "	�˿�: ${Red_background_prefix} ${server_port_s} ${Font_color_suffix}"
				echo "	================================================" && echo
				break
			else
				echo "�������, ��������ȷ�Ķ˿ڡ�"
			fi
		else
			echo "�������, ��������ȷ�Ķ˿ڡ�"
		fi
	done
}
Set_username(){
	mode=$1
	[[ -z ${mode} ]] && mode="server"
	if [[ ${mode} == "server" ]]; then
		echo -e "������ ServerStatus �����Ҫ���õ��û���[username]����ĸ/���֣������������˺��ظ���"
	else
		echo -e "������ ServerStatus ������ж�Ӧ���õ��û���[username]����ĸ/���֣������������˺��ظ���"
	fi
	read -e -p "(Ĭ��: ȡ��):" username_s
	[[ -z "$username_s" ]] && echo "��ȡ��..." && exit 0
	echo && echo "	================================================"
	echo -e "	�˺�[username]: ${Red_background_prefix} ${username_s} ${Font_color_suffix}"
	echo "	================================================" && echo
}
Set_password(){
	mode=$1
	[[ -z ${mode} ]] && mode="server"
	if [[ ${mode} == "server" ]]; then
		echo -e "������ ServerStatus �����Ҫ���õ�����[password]����ĸ/���֣����ظ���"
	else
		echo -e "������ ServerStatus ������ж�Ӧ���õ�����[password]����ĸ/���֣�"
	fi
	read -e -p "(Ĭ��: doub.io):" password_s
	[[ -z "$password_s" ]] && password_s="doub.io"
	echo && echo "	================================================"
	echo -e "	����[password]: ${Red_background_prefix} ${password_s} ${Font_color_suffix}"
	echo "	================================================" && echo
}
Set_name(){
	echo -e "������ ServerStatus �����Ҫ���õĽڵ�����[name]��֧�����ģ�ǰ�������ϵͳ��SSH����֧���������룬�����Ǹ����֣�"
	read -e -p "(Ĭ��: Server 01):" name_s
	[[ -z "$name_s" ]] && name_s="Server 01"
	echo && echo "	================================================"
	echo -e "	�ڵ�����[name]: ${Red_background_prefix} ${name_s} ${Font_color_suffix}"
	echo "	================================================" && echo
}
Set_type(){
	echo -e "������ ServerStatus �����Ҫ���õĽڵ����⻯����[type]������ OpenVZ / KVM��"
	read -e -p "(Ĭ��: KVM):" type_s
	[[ -z "$type_s" ]] && type_s="KVM"
	echo && echo "	================================================"
	echo -e "	���⻯����[type]: ${Red_background_prefix} ${type_s} ${Font_color_suffix}"
	echo "	================================================" && echo
}
Set_location(){
	echo -e "������ ServerStatus �����Ҫ���õĽڵ�λ��[location]��֧�����ģ�ǰ�������ϵͳ��SSH����֧���������룩"
	read -e -p "(Ĭ��: Hong Kong):" location_s
	[[ -z "$location_s" ]] && location_s="Hong Kong"
	echo && echo "	================================================"
	echo -e "	�ڵ�λ��[location]: ${Red_background_prefix} ${location_s} ${Font_color_suffix}"
	echo "	================================================" && echo
}
Set_config_server(){
	Set_username "server"
	Set_password "server"
	Set_name
	Set_type
	Set_location
}
Set_config_client(){
	Set_server "client"
	Set_server_port
	Set_username "client"
	Set_password "client"
}
Set_ServerStatus_server(){
	check_installed_server_status
	echo && echo -e " ��Ҫ��ʲô��
	
 ${Green_font_prefix} 1.${Font_color_suffix} ��� �ڵ�����
 ${Green_font_prefix} 2.${Font_color_suffix} ɾ�� �ڵ�����
����������������
 ${Green_font_prefix} 3.${Font_color_suffix} �޸� �ڵ����� - �ڵ��û���
 ${Green_font_prefix} 4.${Font_color_suffix} �޸� �ڵ����� - �ڵ�����
 ${Green_font_prefix} 5.${Font_color_suffix} �޸� �ڵ����� - �ڵ�����
 ${Green_font_prefix} 6.${Font_color_suffix} �޸� �ڵ����� - �ڵ����⻯
 ${Green_font_prefix} 7.${Font_color_suffix} �޸� �ڵ����� - �ڵ�λ��
 ${Green_font_prefix} 8.${Font_color_suffix} �޸� �ڵ����� - ȫ������
����������������
 ${Green_font_prefix} 9.${Font_color_suffix} ����/���� �ڵ�����
����������������
 ${Green_font_prefix}10.${Font_color_suffix} �޸� ����˼����˿�" && echo
	read -e -p "(Ĭ��: ȡ��):" server_num
	[[ -z "${server_num}" ]] && echo "��ȡ��..." && exit 1
	if [[ ${server_num} == "1" ]]; then
		Add_ServerStatus_server
	elif [[ ${server_num} == "2" ]]; then
		Del_ServerStatus_server
	elif [[ ${server_num} == "3" ]]; then
		Modify_ServerStatus_server_username
	elif [[ ${server_num} == "4" ]]; then
		Modify_ServerStatus_server_password
	elif [[ ${server_num} == "5" ]]; then
		Modify_ServerStatus_server_name
	elif [[ ${server_num} == "6" ]]; then
		Modify_ServerStatus_server_type
	elif [[ ${server_num} == "7" ]]; then
		Modify_ServerStatus_server_location
	elif [[ ${server_num} == "8" ]]; then
		Modify_ServerStatus_server_all
	elif [[ ${server_num} == "9" ]]; then
		Modify_ServerStatus_server_disabled
	elif [[ ${server_num} == "10" ]]; then
		Read_config_server
		Del_iptables "${server_port}"
		Set_server_port
		Write_server_config_conf
		Add_iptables "${server_port_s}"
	else
		echo -e "${Error} ��������ȷ������[1-10]" && exit 1
	fi
	Restart_ServerStatus_server
}
List_ServerStatus_server(){
	conf_text=$(${jq_file} '.servers' ${server_conf}|${jq_file} ".[]|.username"|sed 's/\"//g')
	conf_text_total=$(echo -e "${conf_text}"|wc -l)
	[[ ${conf_text_total} = "0" ]] && echo -e "${Error} û�з��� һ���ڵ����ã����� !" && exit 1
	conf_text_total_a=$(echo $((${conf_text_total}-1)))
	conf_list_all=""
	for((integer = 0; integer <= ${conf_text_total_a}; integer++))
	do
		now_text=$(${jq_file} '.servers' ${server_conf}|${jq_file} ".[${integer}]"|sed 's/\"//g;s/,$//g'|sed '$d;1d')
		now_text_username=$(echo -e "${now_text}"|grep "username"|awk -F ": " '{print $2}')
		now_text_password=$(echo -e "${now_text}"|grep "password"|awk -F ": " '{print $2}')
		now_text_name=$(echo -e "${now_text}"|grep "name"|grep -v "username"|awk -F ": " '{print $2}')
		now_text_type=$(echo -e "${now_text}"|grep "type"|awk -F ": " '{print $2}')
		now_text_location=$(echo -e "${now_text}"|grep "location"|awk -F ": " '{print $2}')
		now_text_disabled=$(echo -e "${now_text}"|grep "disabled"|awk -F ": " '{print $2}')
		if [[ ${now_text_disabled} == "false" ]]; then
			now_text_disabled_status="${Green_font_prefix}����${Font_color_suffix}"
		else
			now_text_disabled_status="${Red_font_prefix}����${Font_color_suffix}"
		fi
		conf_list_all=${conf_list_all}"�û���: ${Green_font_prefix}"${now_text_username}"${Font_color_suffix} ����: ${Green_font_prefix}"${now_text_password}"${Font_color_suffix} �ڵ���: ${Green_font_prefix}"${now_text_name}"${Font_color_suffix} ����: ${Green_font_prefix}"${now_text_type}"${Font_color_suffix} λ��: ${Green_font_prefix}"${now_text_location}"${Font_color_suffix} ״̬: ${Green_font_prefix}"${now_text_disabled_status}"${Font_color_suffix}\n"
	done
	echo && echo -e "�ڵ����� ${Green_font_prefix}"${conf_text_total}"${Font_color_suffix}"
	echo -e ${conf_list_all}
}
Add_ServerStatus_server(){
	Set_config_server
	Set_username_ch=$(cat ${server_conf}|grep '"username": "'"${username_s}"'"')
	[[ ! -z "${Set_username_ch}" ]] && echo -e "${Error} �û����ѱ�ʹ�� !" && exit 1
	sed -i '3i\  },' ${server_conf}
	sed -i '3i\   "disabled": false' ${server_conf}
	sed -i '3i\   "location": "'"${location_s}"'",' ${server_conf}
	sed -i '3i\   "host": "'"None"'",' ${server_conf}
	sed -i '3i\   "type": "'"${type_s}"'",' ${server_conf}
	sed -i '3i\   "name": "'"${name_s}"'",' ${server_conf}
	sed -i '3i\   "password": "'"${password_s}"'",' ${server_conf}
	sed -i '3i\   "username": "'"${username_s}"'",' ${server_conf}
	sed -i '3i\  {' ${server_conf}
	echo -e "${Info} ��ӽڵ�ɹ� ${Green_font_prefix}[ �ڵ�����: ${name_s}, �ڵ��û���: ${username_s}, �ڵ�����: ${password_s} ]${Font_color_suffix} !"
}
Del_ServerStatus_server(){
	List_ServerStatus_server
	[[ "${conf_text_total}" = "1" ]] && echo -e "${Error} �ڵ����ý�ʣ 1��������ɾ�� !" && exit 1
	echo -e "������Ҫɾ���Ľڵ��û���"
	read -e -p "(Ĭ��: ȡ��):" del_server_username
	[[ -z "${del_server_username}" ]] && echo -e "��ȡ��..." && exit 1
	del_username=`cat -n ${server_conf}|grep '"username": "'"${del_server_username}"'"'|awk '{print $1}'`
	if [[ ! -z ${del_username} ]]; then
		del_username_min=$(echo $((${del_username}-1)))
		del_username_max=$(echo $((${del_username}+7)))
		del_username_max_text=$(sed -n "${del_username_max}p" ${server_conf})
		del_username_max_text_last=`echo ${del_username_max_text:((${#del_username_max_text} - 1))}`
		if [[ ${del_username_max_text_last} != "," ]]; then
			del_list_num=$(echo $((${del_username_min}-1)))
			sed -i "${del_list_num}s/,$//g" ${server_conf}
		fi
		sed -i "${del_username_min},${del_username_max}d" ${server_conf}
		echo -e "${Info} �ڵ�ɾ���ɹ� ${Green_font_prefix}[ �ڵ��û���: ${del_server_username} ]${Font_color_suffix} "
	else
		echo -e "${Error} ��������ȷ�Ľڵ��û��� !" && exit 1
	fi
}
Modify_ServerStatus_server_username(){
	List_ServerStatus_server
	echo -e "������Ҫ�޸ĵĽڵ��û���"
	read -e -p "(Ĭ��: ȡ��):" manually_username
	[[ -z "${manually_username}" ]] && echo -e "��ȡ��..." && exit 1
	Set_username_num=$(cat -n ${server_conf}|grep '"username": "'"${manually_username}"'"'|awk '{print $1}')
	if [[ ! -z ${Set_username_num} ]]; then
		Set_username
		Set_username_ch=$(cat ${server_conf}|grep '"username": "'"${username_s}"'"')
		[[ ! -z "${Set_username_ch}" ]] && echo -e "${Error} �û����ѱ�ʹ�� !" && exit 1
		sed -i "${Set_username_num}"'s/"username": "'"${manually_username}"'"/"username": "'"${username_s}"'"/g' ${server_conf}
		echo -e "${Info} �޸ĳɹ� [ ԭ�ڵ��û���: ${manually_username}, �½ڵ��û���: ${username_s} ]"
	else
		echo -e "${Error} ��������ȷ�Ľڵ��û��� !" && exit 1
	fi
}
Modify_ServerStatus_server_password(){
	List_ServerStatus_server
	echo -e "������Ҫ�޸ĵĽڵ��û���"
	read -e -p "(Ĭ��: ȡ��):" manually_username
	[[ -z "${manually_username}" ]] && echo -e "��ȡ��..." && exit 1
	Set_username_num=$(cat -n ${server_conf}|grep '"username": "'"${manually_username}"'"'|awk '{print $1}')
	if [[ ! -z ${Set_username_num} ]]; then
		Set_password
		Set_password_num_a=$(echo $((${Set_username_num}+1)))
		Set_password_num_text=$(sed -n "${Set_password_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		sed -i "${Set_password_num_a}"'s/"password": "'"${Set_password_num_text}"'"/"password": "'"${password_s}"'"/g' ${server_conf}
		echo -e "${Info} �޸ĳɹ� [ ԭ�ڵ�����: ${Set_password_num_text}, �½ڵ�����: ${password_s} ]"
	else
		echo -e "${Error} ��������ȷ�Ľڵ��û��� !" && exit 1
	fi
}
Modify_ServerStatus_server_name(){
	List_ServerStatus_server
	echo -e "������Ҫ�޸ĵĽڵ��û���"
	read -e -p "(Ĭ��: ȡ��):" manually_username
	[[ -z "${manually_username}" ]] && echo -e "��ȡ��..." && exit 1
	Set_username_num=$(cat -n ${server_conf}|grep '"username": "'"${manually_username}"'"'|awk '{print $1}')
	if [[ ! -z ${Set_username_num} ]]; then
		Set_name
		Set_name_num_a=$(echo $((${Set_username_num}+2)))
		Set_name_num_a_text=$(sed -n "${Set_name_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		sed -i "${Set_name_num_a}"'s/"name": "'"${Set_name_num_a_text}"'"/"name": "'"${name_s}"'"/g' ${server_conf}
		echo -e "${Info} �޸ĳɹ� [ ԭ�ڵ�����: ${Set_name_num_a_text}, �½ڵ�����: ${name_s} ]"
	else
		echo -e "${Error} ��������ȷ�Ľڵ��û��� !" && exit 1
	fi
}
Modify_ServerStatus_server_type(){
	List_ServerStatus_server
	echo -e "������Ҫ�޸ĵĽڵ��û���"
	read -e -p "(Ĭ��: ȡ��):" manually_username
	[[ -z "${manually_username}" ]] && echo -e "��ȡ��..." && exit 1
	Set_username_num=$(cat -n ${server_conf}|grep '"username": "'"${manually_username}"'"'|awk '{print $1}')
	if [[ ! -z ${Set_username_num} ]]; then
		Set_type
		Set_type_num_a=$(echo $((${Set_username_num}+3)))
		Set_type_num_a_text=$(sed -n "${Set_type_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		sed -i "${Set_type_num_a}"'s/"type": "'"${Set_type_num_a_text}"'"/"type": "'"${type_s}"'"/g' ${server_conf}
		echo -e "${Info} �޸ĳɹ� [ ԭ�ڵ����⻯: ${Set_type_num_a_text}, �½ڵ����⻯: ${type_s} ]"
	else
		echo -e "${Error} ��������ȷ�Ľڵ��û��� !" && exit 1
	fi
}
Modify_ServerStatus_server_location(){
	List_ServerStatus_server
	echo -e "������Ҫ�޸ĵĽڵ��û���"
	read -e -p "(Ĭ��: ȡ��):" manually_username
	[[ -z "${manually_username}" ]] && echo -e "��ȡ��..." && exit 1
	Set_username_num=$(cat -n ${server_conf}|grep '"username": "'"${manually_username}"'"'|awk '{print $1}')
	if [[ ! -z ${Set_username_num} ]]; then
		Set_location
		Set_location_num_a=$(echo $((${Set_username_num}+5)))
		Set_location_num_a_text=$(sed -n "${Set_location_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		sed -i "${Set_location_num_a}"'s/"location": "'"${Set_location_num_a_text}"'"/"location": "'"${location_s}"'"/g' ${server_conf}
		echo -e "${Info} �޸ĳɹ� [ ԭ�ڵ�λ��: ${Set_location_num_a_text}, �½ڵ�λ��: ${location_s} ]"
	else
		echo -e "${Error} ��������ȷ�Ľڵ��û��� !" && exit 1
	fi
}
Modify_ServerStatus_server_all(){
	List_ServerStatus_server
	echo -e "������Ҫ�޸ĵĽڵ��û���"
	read -e -p "(Ĭ��: ȡ��):" manually_username
	[[ -z "${manually_username}" ]] && echo -e "��ȡ��..." && exit 1
	Set_username_num=$(cat -n ${server_conf}|grep '"username": "'"${manually_username}"'"'|awk '{print $1}')
	if [[ ! -z ${Set_username_num} ]]; then
		Set_username
		Set_password
		Set_name
		Set_type
		Set_location
		sed -i "${Set_username_num}"'s/"username": "'"${manually_username}"'"/"username": "'"${username_s}"'"/g' ${server_conf}
		Set_password_num_a=$(echo $((${Set_username_num}+1)))
		Set_password_num_text=$(sed -n "${Set_password_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		sed -i "${Set_password_num_a}"'s/"password": "'"${Set_password_num_text}"'"/"password": "'"${password_s}"'"/g' ${server_conf}
		Set_name_num_a=$(echo $((${Set_username_num}+2)))
		Set_name_num_a_text=$(sed -n "${Set_name_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		sed -i "${Set_name_num_a}"'s/"name": "'"${Set_name_num_a_text}"'"/"name": "'"${name_s}"'"/g' ${server_conf}
		Set_type_num_a=$(echo $((${Set_username_num}+3)))
		Set_type_num_a_text=$(sed -n "${Set_type_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		sed -i "${Set_type_num_a}"'s/"type": "'"${Set_type_num_a_text}"'"/"type": "'"${type_s}"'"/g' ${server_conf}
		Set_location_num_a=$(echo $((${Set_username_num}+5)))
		Set_location_num_a_text=$(sed -n "${Set_location_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		sed -i "${Set_location_num_a}"'s/"location": "'"${Set_location_num_a_text}"'"/"location": "'"${location_s}"'"/g' ${server_conf}
		echo -e "${Info} �޸ĳɹ���"
	else
		echo -e "${Error} ��������ȷ�Ľڵ��û��� !" && exit 1
	fi
}
Modify_ServerStatus_server_disabled(){
	List_ServerStatus_server
	echo -e "������Ҫ�޸ĵĽڵ��û���"
	read -e -p "(Ĭ��: ȡ��):" manually_username
	[[ -z "${manually_username}" ]] && echo -e "��ȡ��..." && exit 1
	Set_username_num=$(cat -n ${server_conf}|grep '"username": "'"${manually_username}"'"'|awk '{print $1}')
	if [[ ! -z ${Set_username_num} ]]; then
		Set_disabled_num_a=$(echo $((${Set_username_num}+6)))
		Set_disabled_num_a_text=$(sed -n "${Set_disabled_num_a}p" ${server_conf}|sed 's/\"//g;s/,$//g'|awk -F ": " '{print $2}')
		if [[ ${Set_disabled_num_a_text} == "false" ]]; then
			disabled_s="true"
		else
			disabled_s="false"
		fi
		sed -i "${Set_disabled_num_a}"'s/"disabled": '"${Set_disabled_num_a_text}"'/"disabled": '"${disabled_s}"'/g' ${server_conf}
		echo -e "${Info} �޸ĳɹ� [ ԭ����״̬: ${Set_disabled_num_a_text}, �½���״̬: ${disabled_s} ]"
	else
		echo -e "${Error} ��������ȷ�Ľڵ��û��� !" && exit 1
	fi
}
Set_ServerStatus_client(){
	check_installed_client_status
	Set_config_client
	Read_config_client
	Del_iptables_OUT "${client_port}"
	Modify_config_client
	Add_iptables_OUT "${server_port_s}"
	Restart_ServerStatus_client
}
Modify_config_client(){
	sed -i 's/SERVER = "'"${client_server}"'"/SERVER = "'"${server_s}"'"/g' "${client_file}/status-client.py"
	sed -i "s/PORT = ${client_port}/PORT = ${server_port_s}/g" "${client_file}/status-client.py"
	sed -i 's/USER = "'"${client_user}"'"/USER = "'"${username_s}"'"/g' "${client_file}/status-client.py"
	sed -i 's/PASSWORD = "'"${client_password}"'"/PASSWORD = "'"${password_s}"'"/g' "${client_file}/status-client.py"
}
Install_jq(){
	if [[ ! -e ${jq_file} ]]; then
		if [[ ${bit} = "x86_64" ]]; then
			wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" -O ${jq_file}
		else
			wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux32" -O ${jq_file}
		fi
		[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ������ ����ʧ�ܣ����� !" && exit 1
		chmod +x ${jq_file}
		echo -e "${Info} JQ������ ��װ��ɣ�����..." 
	else
		echo -e "${Info} JQ������ �Ѱ�װ������..."
	fi
}
Install_caddy(){
	echo
	echo -e "${Info} �Ƿ��ɽű��Զ�����HTTP����(����˵����߼����վ)�����ѡ�� N������������HTTP������������վ��Ŀ¼Ϊ��${Green_font_prefix}${web_file}${Font_color_suffix} [Y/n]"
	read -e -p "(Ĭ��: Y �Զ�����):" caddy_yn
	[[ -z "$caddy_yn" ]] && caddy_yn="y"
	if [[ "${caddy_yn}" == [Yy] ]]; then
		Set_server "server"
		Set_server_http_port
		if [[ ! -e "/usr/local/caddy/caddy" ]]; then
			wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/caddy_install.sh
			chmod +x caddy_install.sh
			bash caddy_install.sh install
			rm -rf caddy_install.sh
			[[ ! -e "/usr/local/caddy/caddy" ]] && echo -e "${Error} Caddy��װʧ�ܣ����ֶ�����Web��ҳ�ļ�λ�ã�${Web_file}" && exit 1
		else
			echo -e "${Info} ����Caddy�Ѱ�װ����ʼ����..."
		fi
		if [[ ! -s "/usr/local/caddy/Caddyfile" ]]; then
			cat > "/usr/local/caddy/Caddyfile"<<-EOF
http://${server_s}:${server_http_port_s} {
 root ${web_file}
 timeouts none
 gzip
}
EOF
			/etc/init.d/caddy restart
		else
			echo -e "${Info} ���� Caddy �����ļ��ǿգ���ʼ׷�� ServerStatus ��վ�������ݵ��ļ����..."
			cat >> "/usr/local/caddy/Caddyfile"<<-EOF
http://${server_s}:${server_http_port_s} {
 root ${web_file}
 timeouts none
 gzip
}
EOF
			/etc/init.d/caddy restart
		fi
	else
		echo -e "${Info} ���� HTTP���������ֶ�����Web��ҳ�ļ�λ�ã�${web_file} �����λ�øı䣬��ע���޸ķ���ű��ļ� /etc/init.d/status-server �е� WEB_BIN ���� !"
	fi
}
Install_ServerStatus_server(){
	[[ -e "${server_file}/sergate" ]] && echo -e "${Error} ��⵽ ServerStatus ������Ѱ�װ !" && exit 1
	Set_server_port
	echo -e "${Info} ��ʼ��װ/���� ����..."
	Installation_dependency "server"
	Install_caddy
	echo -e "${Info} ��ʼ����/��װ..."
	Download_Server_Status_server
	Install_jq
	echo -e "${Info} ��ʼ����/��װ ����ű�(init)..."
	Service_Server_Status_server
	echo -e "${Info} ��ʼд�� �����ļ�..."
	Write_server_config
	Write_server_config_conf
	echo -e "${Info} ��ʼ���� iptables����ǽ..."
	Set_iptables
	echo -e "${Info} ��ʼ��� iptables����ǽ����..."
	Add_iptables "${server_port_s}"
	[[ ! -z "${server_http_port_s}" ]] && Add_iptables "${server_http_port_s}"
	echo -e "${Info} ��ʼ���� iptables����ǽ����..."
	Save_iptables
	echo -e "${Info} ���в��� ��װ��ϣ���ʼ����..."
	Start_ServerStatus_server
}
Install_ServerStatus_client(){
	[[ -e "${client_file}/status-client.py" ]] && echo -e "${Error} ��⵽ ServerStatus �ͻ����Ѱ�װ !" && exit 1
	check_sys
	if [[ ${release} == "centos" ]]; then
		cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
		if [[ $? != 0 ]]; then
			echo -e "${Info} ��⵽���ϵͳΪ CentOS6����ϵͳ�Դ��� Python2.6 �汾���ͣ��ᵼ���޷����пͻ��ˣ����������������Ϊ Python2.7����ô�����(���������ϵͳ)��[y/N]"
			read -e -p "(Ĭ��: N ������װ):" sys_centos6
			[[ -z "$sys_centos6" ]] && sys_centos6="n"
			if [[ "${sys_centos6}" == [Nn] ]]; then
				echo -e "\n${Info} ��ȡ��...\n"
				exit 1
			fi
		fi
	fi
	echo -e "${Info} ��ʼ���� �û�����..."
	Set_config_client
	echo -e "${Info} ��ʼ��װ/���� ����..."
	Installation_dependency "client"
	echo -e "${Info} ��ʼ����/��װ..."
	Download_Server_Status_client
	echo -e "${Info} ��ʼ����/��װ ����ű�(init)..."
	Service_Server_Status_client
	echo -e "${Info} ��ʼд�� ����..."
	Read_config_client
	Modify_config_client
	echo -e "${Info} ��ʼ���� iptables����ǽ..."
	Set_iptables
	echo -e "${Info} ��ʼ��� iptables����ǽ����..."
	Add_iptables_OUT "${server_port_s}"
	echo -e "${Info} ��ʼ���� iptables����ǽ����..."
	Save_iptables
	echo -e "${Info} ���в��� ��װ��ϣ���ʼ����..."
	Start_ServerStatus_client
}
Update_ServerStatus_server(){
	check_installed_server_status
	check_pid_server
	[[ ! -z ${PID} ]] && /etc/init.d/status-server stop
	Download_Server_Status_server
	rm -rf /etc/init.d/status-server
	Service_Server_Status_server
	Start_ServerStatus_server
}
Update_ServerStatus_client(){
	check_installed_client_status
	check_pid_client
	[[ ! -z ${PID} ]] && /etc/init.d/status-client stop
	if [[ ! -e "${client_file}/status-client.py" ]]; then
		if [[ ! -e "${file}/status-client.py" ]]; then
			echo -e "${Error} ServerStatus �ͻ����ļ������� !" && exit 1
		else
			client_text="$(cat "${file}/status-client.py"|sed 's/\"//g;s/,//g;s/ //g')"
			rm -rf "${file}/status-client.py"
		fi
	else
		client_text="$(cat "${client_file}/status-client.py"|sed 's/\"//g;s/,//g;s/ //g')"
	fi
	server_s="$(echo -e "${client_text}"|grep "SERVER="|awk -F "=" '{print $2}')"
	server_port_s="$(echo -e "${client_text}"|grep "PORT="|awk -F "=" '{print $2}')"
	username_s="$(echo -e "${client_text}"|grep "USER="|awk -F "=" '{print $2}')"
	password_s="$(echo -e "${client_text}"|grep "PASSWORD="|awk -F "=" '{print $2}')"
	Download_Server_Status_client
	Read_config_client
	Modify_config_client
	rm -rf /etc/init.d/status-client
	Service_Server_Status_client
	Start_ServerStatus_client
}
Start_ServerStatus_server(){
	check_installed_server_status
	check_pid_server
	[[ ! -z ${PID} ]] && echo -e "${Error} ServerStatus �������У����� !" && exit 1
	/etc/init.d/status-server start
}
Stop_ServerStatus_server(){
	check_installed_server_status
	check_pid_server
	[[ -z ${PID} ]] && echo -e "${Error} ServerStatus û�����У����� !" && exit 1
	/etc/init.d/status-server stop
}
Restart_ServerStatus_server(){
	check_installed_server_status
	check_pid_server
	[[ ! -z ${PID} ]] && /etc/init.d/status-server stop
	/etc/init.d/status-server start
}
Uninstall_ServerStatus_server(){
	check_installed_server_status
	echo "ȷ��Ҫж�� ServerStatus �����(���ͬʱ��װ�˿ͻ��ˣ���ֻ��ɾ�������) ? [y/N]"
	echo
	read -e -p "(Ĭ��: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		check_pid_server
		[[ ! -z $PID ]] && kill -9 ${PID}
		Read_config_server
		Del_iptables "${server_port}"
		Save_iptables
		if [[ -e "${client_file}/status-client.py" ]]; then
			rm -rf "${server_file}"
			rm -rf "${web_file}"
		else
			rm -rf "${file}"
		fi
		rm -rf "/etc/init.d/status-server"
		if [[ -e "/etc/init.d/caddy" ]]; then
			/etc/init.d/caddy stop
			wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/caddy_install.sh
			chmod +x caddy_install.sh
			bash caddy_install.sh uninstall
			rm -rf caddy_install.sh
		fi
		if [[ ${release} = "centos" ]]; then
			chkconfig --del status-server
		else
			update-rc.d -f status-server remove
		fi
		echo && echo "ServerStatus ж����� !" && echo
	else
		echo && echo "ж����ȡ��..." && echo
	fi
}
Start_ServerStatus_client(){
	check_installed_client_status
	check_pid_client
	[[ ! -z ${PID} ]] && echo -e "${Error} ServerStatus �������У����� !" && exit 1
	/etc/init.d/status-client start
}
Stop_ServerStatus_client(){
	check_installed_client_status
	check_pid_client
	[[ -z ${PID} ]] && echo -e "${Error} ServerStatus û�����У����� !" && exit 1
	/etc/init.d/status-client stop
}
Restart_ServerStatus_client(){
	check_installed_client_status
	check_pid_client
	[[ ! -z ${PID} ]] && /etc/init.d/status-client stop
	/etc/init.d/status-client start
}
Uninstall_ServerStatus_client(){
	check_installed_client_status
	echo "ȷ��Ҫж�� ServerStatus �ͻ���(���ͬʱ��װ�˷���ˣ���ֻ��ɾ���ͻ���) ? [y/N]"
	echo
	read -e -p "(Ĭ��: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		check_pid_client
		[[ ! -z $PID ]] && kill -9 ${PID}
		Read_config_client
		Del_iptables_OUT "${client_port}"
		Save_iptables
		if [[ -e "${server_file}/sergate" ]]; then
			rm -rf "${client_file}"
		else
			rm -rf "${file}"
		fi
		rm -rf /etc/init.d/status-client
		if [[ ${release} = "centos" ]]; then
			chkconfig --del status-client
		else
			update-rc.d -f status-client remove
		fi
		echo && echo "ServerStatus ж����� !" && echo
	else
		echo && echo "ж����ȡ��..." && echo
	fi
}
View_ServerStatus_client(){
	check_installed_client_status
	Read_config_client
	clear && echo "����������������������������������������" && echo
	echo -e "  ServerStatus �ͻ���������Ϣ��
 
  IP \t: ${Green_font_prefix}${client_server}${Font_color_suffix}
  �˿� \t: ${Green_font_prefix}${client_port}${Font_color_suffix}
  �˺� \t: ${Green_font_prefix}${client_user}${Font_color_suffix}
  ���� \t: ${Green_font_prefix}${client_password}${Font_color_suffix}
 
����������������������������������������"
}
View_client_Log(){
	[[ ! -e ${client_log_file} ]] && echo -e "${Error} û���ҵ���־�ļ� !" && exit 1
	echo && echo -e "${Tip} �� ${Red_font_prefix}Ctrl+C${Font_color_suffix} ��ֹ�鿴��־" && echo -e "�����Ҫ�鿴������־���ݣ����� ${Red_font_prefix}cat ${client_log_file}${Font_color_suffix} ���" && echo
	tail -f ${client_log_file}
}
View_server_Log(){
	[[ ! -e ${erver_log_file} ]] && echo -e "${Error} û���ҵ���־�ļ� !" && exit 1
	echo && echo -e "${Tip} �� ${Red_font_prefix}Ctrl+C${Font_color_suffix} ��ֹ�鿴��־" && echo -e "�����Ҫ�鿴������־���ݣ����� ${Red_font_prefix}cat ${erver_log_file}${Font_color_suffix} ���" && echo
	tail -f ${erver_log_file}
}
Add_iptables_OUT(){
	iptables_ADD_OUT_port=$1
	iptables -I OUTPUT -m state --state NEW -m tcp -p tcp --dport ${iptables_ADD_OUT_port} -j ACCEPT
	iptables -I OUTPUT -m state --state NEW -m udp -p udp --dport ${iptables_ADD_OUT_port} -j ACCEPT
}
Del_iptables_OUT(){
	iptables_DEL_OUT_port=$1
	iptables -D OUTPUT -m state --state NEW -m tcp -p tcp --dport ${iptables_DEL_OUT_port} -j ACCEPT
	iptables -D OUTPUT -m state --state NEW -m udp -p udp --dport ${iptables_DEL_OUT_port} -j ACCEPT
}
Add_iptables(){
	iptables_ADD_IN_port=$1
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${iptables_ADD_IN_port} -j ACCEPT
	iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${iptables_ADD_IN_port} -j ACCEPT
}
Del_iptables(){
	iptables_DEL_IN_port=$1
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${iptables_DEL_IN_port} -j ACCEPT
	iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${iptables_DEL_IN_port} -j ACCEPT
}
Save_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
	else
		iptables-save > /etc/iptables.up.rules
	fi
}
Set_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
		chkconfig --level 2345 iptables on
	else
		iptables-save > /etc/iptables.up.rules
		echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
		chmod +x /etc/network/if-pre-up.d/iptables
	fi
}
Update_Shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/status.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} �޷����ӵ� Github !" && exit 0
	if [[ -e "/etc/init.d/status-client" ]]; then
		rm -rf /etc/init.d/status-client
		Service_Server_Status_client
	fi
	if [[ -e "/etc/init.d/status-server" ]]; then
		rm -rf /etc/init.d/status-server
		Service_Server_Status_server
	fi
	wget -N --no-check-certificate "https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/status.sh" && chmod +x status.sh
	echo -e "�ű��Ѹ���Ϊ���°汾[ ${sh_new_ver} ] !(ע�⣺��Ϊ���·�ʽΪֱ�Ӹ��ǵ�ǰ���еĽű������Կ����������ʾһЩ�������Ӽ���)" && exit 0
}
menu_client(){
echo && echo -e "  ServerStatus һ����װ����ű� ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- Toyo | doub.io/shell-jc3 --
  
 ${Green_font_prefix} 0.${Font_color_suffix} �����ű�
 ������������������������
 ${Green_font_prefix} 1.${Font_color_suffix} ��װ �ͻ���
 ${Green_font_prefix} 2.${Font_color_suffix} ���� �ͻ���
 ${Green_font_prefix} 3.${Font_color_suffix} ж�� �ͻ���
������������������������
 ${Green_font_prefix} 4.${Font_color_suffix} ���� �ͻ���
 ${Green_font_prefix} 5.${Font_color_suffix} ֹͣ �ͻ���
 ${Green_font_prefix} 6.${Font_color_suffix} ���� �ͻ���
������������������������
 ${Green_font_prefix} 7.${Font_color_suffix} ���� �ͻ�������
 ${Green_font_prefix} 8.${Font_color_suffix} �鿴 �ͻ�����Ϣ
 ${Green_font_prefix} 9.${Font_color_suffix} �鿴 �ͻ�����־
������������������������
 ${Green_font_prefix}10.${Font_color_suffix} �л�Ϊ ����˲˵�" && echo
if [[ -e "${client_file}/status-client.py" ]]; then
	check_pid_client
	if [[ ! -z "${PID}" ]]; then
		echo -e " ��ǰ״̬: �ͻ��� ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} �� ${Green_font_prefix}������${Font_color_suffix}"
	else
		echo -e " ��ǰ״̬: �ͻ��� ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} �� ${Red_font_prefix}δ����${Font_color_suffix}"
	fi
else
	if [[ -e "${file}/status-client.py" ]]; then
		check_pid_client
		if [[ ! -z "${PID}" ]]; then
			echo -e " ��ǰ״̬: �ͻ��� ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} �� ${Green_font_prefix}������${Font_color_suffix}"
		else
			echo -e " ��ǰ״̬: �ͻ��� ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} �� ${Red_font_prefix}δ����${Font_color_suffix}"
		fi
	else
		echo -e " ��ǰ״̬: �ͻ��� ${Red_font_prefix}δ��װ${Font_color_suffix}"
	fi
fi
echo
read -e -p " ���������� [0-10]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	Install_ServerStatus_client
	;;
	2)
	Update_ServerStatus_client
	;;
	3)
	Uninstall_ServerStatus_client
	;;
	4)
	Start_ServerStatus_client
	;;
	5)
	Stop_ServerStatus_client
	;;
	6)
	Restart_ServerStatus_client
	;;
	7)
	Set_ServerStatus_client
	;;
	8)
	View_ServerStatus_client
	;;
	9)
	View_client_Log
	;;
	10)
	menu_server
	;;
	*)
	echo "��������ȷ���� [0-10]"
	;;
esac
}
menu_server(){
echo && echo -e "  ServerStatus һ����װ����ű� ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- Toyo | doub.io/shell-jc3 --
  
 ${Green_font_prefix} 0.${Font_color_suffix} �����ű�
 ������������������������
 ${Green_font_prefix} 1.${Font_color_suffix} ��װ �����
 ${Green_font_prefix} 2.${Font_color_suffix} ���� �����
 ${Green_font_prefix} 3.${Font_color_suffix} ж�� �����
������������������������
 ${Green_font_prefix} 4.${Font_color_suffix} ���� �����
 ${Green_font_prefix} 5.${Font_color_suffix} ֹͣ �����
 ${Green_font_prefix} 6.${Font_color_suffix} ���� �����
������������������������
 ${Green_font_prefix} 7.${Font_color_suffix} ���� ���������
 ${Green_font_prefix} 8.${Font_color_suffix} �鿴 �������Ϣ
 ${Green_font_prefix} 9.${Font_color_suffix} �鿴 �������־
������������������������
 ${Green_font_prefix}10.${Font_color_suffix} �л�Ϊ �ͻ��˲˵�" && echo
if [[ -e "${server_file}/sergate" ]]; then
	check_pid_server
	if [[ ! -z "${PID}" ]]; then
		echo -e " ��ǰ״̬: ����� ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} �� ${Green_font_prefix}������${Font_color_suffix}"
	else
		echo -e " ��ǰ״̬: ����� ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} �� ${Red_font_prefix}δ����${Font_color_suffix}"
	fi
else
	echo -e " ��ǰ״̬: ����� ${Red_font_prefix}δ��װ${Font_color_suffix}"
fi
echo
read -e -p " ���������� [0-10]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	Install_ServerStatus_server
	;;
	2)
	Update_ServerStatus_server
	;;
	3)
	Uninstall_ServerStatus_server
	;;
	4)
	Start_ServerStatus_server
	;;
	5)
	Stop_ServerStatus_server
	;;
	6)
	Restart_ServerStatus_server
	;;
	7)
	Set_ServerStatus_server
	;;
	8)
	List_ServerStatus_server
	;;
	9)
	View_server_Log
	;;
	10)
	menu_client
	;;
	*)
	echo "��������ȷ���� [0-10]"
	;;
esac
}
check_sys
action=$1
if [[ ! -z $action ]]; then
	if [[ $action = "s" ]]; then
		menu_server
	elif [[ $action = "c" ]]; then
		menu_client
	fi
else
	menu_server
fi