#HIIIIII
#!/bin/bash

# Set variables
username="root"
passwd="test@123"
count=50

# Start the expect script and redirect output to a log file
expect -c "
set timeout 43200 
spawn netopeer2-cli
expect \">\" {
    send \"disconnect\r\"
    expect \">\"
    send \"listen --timeout 10 --login $username\r\"
    expect {
        \"timeout elapsed.\" {
            exit 1
        }
        \"failed.\" {
	    exit 1
	}
        \"Are you sure you want to continue connecting (yes/no)?\" {
            send \"yes\r\"
            exp_continue
        }
        \"password:\" {
            send \"$passwd\r\"
            exp_continue
        }
        \">\"
    }
    send \"status\r\"
    expect -re {\r\n>}
    send \"subscribe --filter-xpath '/o-ran-performance-management:* | /o-ran-file-management:* | /o-ran-fm:* | /o-ran-sync:*'\r\"
    expect -re {\r\n>}
    send \"edit-config --target running --config=/home/vvsa/M_PLANE_QA/PM_XML/pm_tx_rx_act.xml --defop replace --rpc-timeout 60\r\"
    expect -re {\r\n>}
    send \"get --filter-xpath /o-ran-operations:operational-info --rpc-timeout 10\r\"
    expect -re {\r\n>}
    send \"get --filter-xpath /o-ran-operations:operational-info --rpc-timeout 10\r\"
    expect -re {\r\n>}
    for {set i 0} {\$i < $count} {incr i} {
       	send \"get --filter-xpath /o-ran-operations:operational-info --rpc-timeout 10\r\"
	expect -re {\r\n>}
	sleep 1
    }
    send \"exit\r\"
    expect eof
} " 2>&1 | tee netopeer_v4listen.log

