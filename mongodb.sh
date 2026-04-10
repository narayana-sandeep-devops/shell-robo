#!/bin/bsh

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this command with root user: $N" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2: $R Failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2: $G Success $Y" | tee -a $LOG_FILE
    fi
}


cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Installing MongoDB Server"

systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "Enable MongoDB"

Systemctl start mongod $>> $LOG_FILE
VALIDATE $? "MongoDB started"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

system restart mongod &>> $LOG_FILE
VALIDATE $? "MongoDB Restarted"
