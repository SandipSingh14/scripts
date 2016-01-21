#!/bin/bash
function getFQDNDetails(){
	hostname -f|egrep *.com >/dev/null 2>&1
	if [ $? == "0" ]; then
		echo "Cool, FQDN available ..."
	else		
		echo "Please set FQDN before installing send mail"
		exit 1
	fi
}
function installSendMail(){
	ls /etc/mail/ >/dev/null 2>&1
	if [ $? == "0" ]; then
		echo "Cool, sendmail Already configured ..."
	else		
		sudo apt-get install -y sendmail mailutils sendmail-bin
	fi
}
function createAuthFile(){
	ls /etc/mail/authinfo/ >/dev/null 2>&1
	if [ $? == "0" ]; then
		echo "Cool, auth directory available ..."
	else		
		mkdir -p -m 700 /etc/mail/authinfo/
	fi
	cd /etc/mail/authinfo/
	read -p "Please enter your Username of mailServer : " userName
	read -sp "Please enter your Password of mailServer : " password
	echo ""
	read -p "Please enter your Email-id : " emailId
	echo "AuthInfo: 'U:${userName}' 'I:${emailId}' 'P:${password}'" > gmail-auth
	makemap hash gmail-auth < gmail-auth
	cd - >/dev/null 2>&1
}
function configureSendMail(){
	cat /etc/mail/sendmail.mc |grep SMART_HOST >/dev/null 2>&1
	if [ $? == "0" ]; then
		echo "Cool, Send Mail Already configured ..."
	else		
		read -p "Please enter your Mail Server i.e. smtp.gmail.com : " mailServer
		read -p "Please enter your Mail Server port i.e. 587 : " mailServerPort
		printf "%s\n%s\n" "define('SMART_HOST','[${mailServer}]')dnl" "define('RELAY_MAILER_ARGS', 'TCP $h ${mailServerPort}')dnl" "define('ESMTP_MAILER_ARGS', 'TCP $h ${mailServerPort}')dnl" "define('confAUTH_OPTIONS', 'A p')dnl" "TRUST_AUTH_MECH('EXTERNAL DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl" "define('confAUTH_MECHANISMS', 'EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl" "FEATURE('authinfo','hash -o /etc/mail/authinfo/gmail-auth.db')dnl" >> /etc/mail/sendmail.mc
		cd /etc/mail
		make -C /etc/mail
		cd -
	fi
}
function reloadSendMailService(){
	/etc/init.d/sendmail reload
}
function main(){
	getFQDNDetails
	installSendMail
	createAuthFile
	configureSendMail
	reloadSendMailService
}
main
