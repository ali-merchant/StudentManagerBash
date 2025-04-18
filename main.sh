#!/bin/bash
#Main file to control flow

source auth.sh
source student.sh
source grades.sh

echo "Welcome to the Student Management System"
echo "1. Teacher Login"
echo "2. Student Login"
echo -n "Choose login type: "
read login_type

case $login_type in
    1) if authenticate_teacher; then
           while true; do
               clear
               source menu.sh
           done
       fi ;;
    2) if authenticate_student; then
           source students_menu.sh
       fi ;;
    *) echo "Invalid option!" ;;
esac
