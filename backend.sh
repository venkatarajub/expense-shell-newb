#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log
mkdir -p $LOGS_FOLDER
USERID=$(id -u)

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$Y Run the script with root access $N"
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R FAILD $N .. Pls check"
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

CHECK_ROOT

echo "Script start date:$(date)"

dnf module disable nodejs -y
VALIDATE $? "disabling Nodejs"

dnf module enable nodejs:24 -y
VALIDATE $? "enabling Nodejs"

dnf install nodejs -y
VALIDATE $? "instaling Nodejs"

mkdir -p /app
id expense
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense
        VALIDATE $? "expense user add"
    fi

curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-backend-v5.tar.gz
VALIDATE $? "backend code donload"

cd /app
rm -rf /app/*
tar -xzf /tmp/backend.tar.gz
VALIDATE $? "backend code extracted"

cd /app
npm install
VALIDATE $? "npm installed"

cp /home/ec2-user/expense-shell-newb/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copy backend service"

dnf install mysql -y
VALIDATE $? "mysql client install"

mysql -h mysql.venra.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Loading schema"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable backend
VALIDATE $? "enabled backend"

systemctl restart backend
VALIDATE $? "restared backend"


