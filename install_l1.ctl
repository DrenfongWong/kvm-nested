#! /usr/bin/expect 
####################################################################################################################################
#
#
#proc 
#
#
#####################################################################################################################################
#
#Login use SSH
#
proc SSH { Password }  {  set timeout 180
	expect {
		"*yes/no*" { send "yes\r";exp_continue }
		"*assword*" { send "$Password\r";exp_continue }
		"*#*" { send_user "\r\r\r\r\rLogin Success\r\r\r\r\r" }
		timeout { send_user "\r\r\r\r\rLogin Timeout\r\r\r\r\r";exit 1 }
	}

}
#
#login by Telnet
#
proc Telnet { User Password }  { set timeout 180
	expect {
                                          "*login*" { send "$User\r";exp_continue }
                                          "*assword*" { send "$Password\r";exp_continue }
                                          "*#*" { send_user "\r\r\r\r\rLogin Success\r\r\r\r\r" }
                                          timeout { send_user "\r\r\r\r\rLogin Timeout\r\r\r\r\r";exit 1 }
                               }
                                   
}
set HostIP $argv
set vm "/usr/libexec/qemu-kvm \
        -name rhel \
        -M q35 \
        -cpu max \
        -m 4096  \
        -smp 4,sockets=4,cores=1,threads=1 \
        -kernel /home/test/vmlinuz \
        -initrd /home/test/initrd.img \
        -append \"inst.repo=http://download.eng.pek2.redhat.com/nightly/latest-RHEL-8/compose/BaseOS/x86_64/os/ inst.text console=ttyS0\" \
        -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0,addr=0x5 \
        -drive file=/home/test/nested,format=qcow2,if=none,id=drive-scsi0-0-0 \
        -device scsi-hd,drive=drive-scsi0-0-0,id=scsi0-0-0 \
        -netdev tap,id=hostnet0,vhost=on \
        -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:b3:35:b3,bus=pcie.0,addr=0x6 \
        -nographic "
set timeout -1
spawn scp -r /nested root@$HostIP:/
SSH "redhat"
spawn ssh root@$HostIP
SSH "redhat"
send "cd /nested&&./preinstall.sh\r"
send "rm -rf /home/test&&mkdir /home/test&&cd /home/test/&&wget http://download.eng.pek2.redhat.com/nightly/latest-RHEL-8/compose/BaseOS/x86_64/os/isolinux/initrd.img http://download.eng.pek2.redhat.com/nightly/latest-RHEL-8/compose/BaseOS/x86_64/os/isolinux/vmlinuz&&qemu-img create -f qcow2 nested 40G\r"
expect "*#*"
send "$vm \r"
expect "refresh]: "
send "2\r"
expect ": "
send "2\r"
expect ": "
send "1\r"
expect ": "
send "2\r"
expect "Press ENTER to continue: "
send "\r"
expect ": "
send "64\r"
expect ": "
send "5\r"
expect ": "
send "c\r"
expect ": "
send "c\r"
expect ": "
send "c\r"
expect ": "
send "8\r"
expect "Password: "
send "redhat\r"
expect "Password (confirm): "
send "redhat\r"
expect "Please respond 'yes' or 'no': "
send "yes\r"
expect ": "
sleep 10
send "r\r"
expect ": "
send "b\r"
expect "Installation complete. Press ENTER to quit:"
send "\003"
