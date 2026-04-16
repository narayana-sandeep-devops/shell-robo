#!/bin/bsh

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

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


dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabled Nodejs:20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Nodejs installed"

id roboshop &>> $LOG_FILE

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "User roboshop created"
else
    echo -e "User is already created.. $Y skipping $N"
fi


mkdir -p /app
VALIDATE $? "App folder created"


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
VALIDATE $? "Downloaded package to tmp folder"


cd /app 
VALIDATE $? "moved to app directory"

rm -rf /app/*
VALIDATE

unzip /tmp/catalogue.zip
VALIDATE $? "Package downloaded and copied to app folder"


cp SCRIPT_DIR/catalogue.service /etc/systemd/system/

