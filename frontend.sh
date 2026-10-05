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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Install nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "remove default"

curl -o /tmp/frontend.tar.gz https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-frontend-v5.tar.gz
VALIDATE $? "download fronteng"

cd /usr/share/nginx/html
tar -xzf /tmp/frontend.tar.gz
VALIDATE $? "extract the FE code"

cp /home/ec2-user/expense-shell-newb/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copy expense conf"

systemctl restart nginx
VALIDATE $? "restart nginx"