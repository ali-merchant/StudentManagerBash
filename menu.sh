#!/bin/bash

echo "1. Add Student"
echo "2. View Students"
echo "3. Assign/Update Marks"
echo "4. Delete Student"
echo "5. List Passed Students"
echo "6. List Failed Students"
echo "7. List Students by CGPA"
echo "8. Exit"
echo -e "Choose an option: "
read -r choice

case $choice in
    1) add_student
        read -p "Press Enter to return to the menu..."
        ;;
    2) view_students
        read -p "Press Enter to return to the menu..."
        ;;
    3) update_marks
        read -p "Press Enter to return to the menu..."
        ;;
    4) delete_student
        read -p "Press Enter to return to the menu..."
        ;;
    5) list_passed_students
        read -p "Press Enter to return to the menu..."
        ;;
    6) list_failed_students
        read -p "Press Enter to return to the menu..."
        ;;
    7) list_students_by_cgpa
        read -p "Press Enter to return to the menu..."
        ;;
    8) exit 0 ;;
    *) echo "Invalid option!" ;;
esac
