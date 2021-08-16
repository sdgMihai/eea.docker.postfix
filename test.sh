#!/usr/bin/sh

docker-compose up > /dev/null 2>&1 &
sleep 5

docker exec -it server sh -c 'useradd -m -s /usr/bin/sh incoming'
expect -c '
    set timeout -1
    spawn docker exec -it server sh -c {passwd incoming}
    match_max 100000
    expect -exact "New password: "
    send -- "studentstudent\r"
    expect -exact "Retype new password: "
    send -- "studentstudent\r"
    expect eof
'


chmod +x script.exp
./script.exp

RESULT=""
echo 'testing mail has been sent to mailbox of incoming@foo.com'
if docker logs server | grep incoming@foo.com | grep status=sent
then
    echo 'message sent from bar@foo.com to incoming@foo.com succesfully'
else
    echo 'message not sent-> check server logs and output above for error cause'
fi

sleep 1
docker-compose down > /dev/null 2>&1 &