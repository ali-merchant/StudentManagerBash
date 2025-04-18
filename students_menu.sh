#!/bin/bash
#student uses this


view_grades() {
    echo -e "\nYour Grades:"
    echo "Course | Marks | Grade"
    
    # Search all teacher files for this student
    for teacher_file in students_*.txt; do
        teacher=${teacher_file#students_}
        teacher=${teacher%.txt}
        
        if grep -qi "^$STUDENT_ID," "$teacher_file"; then
            #To print thats why no -q
            grep -i "^$STUDENT_ID," "$teacher_file" | awk -F, -v t="$teacher" '{
                printf "%s (%s) | %s | %s\n", t, $2, $3, $4
            }'
        fi
    done
}

view_cgpa() {
    cgpa="0.00"
    courses_found=0

    for teacher_file in students_*.txt; do
        if grep -qi "^$STUDENT_ID," "$teacher_file"; then
            current_cgpa=$(calculate_cgpa "$teacher_file" "$STUDENT_ID")
            # Convert CGPA string to a number for calculation
            cgpa=$(echo "$cgpa + $current_cgpa" | bc)
            courses_found=$((courses_found + 1))
        fi
    done

    if [ $courses_found -gt 0 ]; then
        # Calculate average CGPA across all teacher files
        final_cgpa=$(echo "scale=2; $cgpa / $courses_found" | bc)
        echo -e "\nYour CGPA: $final_cgpa"
    else
        echo "No courses found!"
    fi
}

while true; do
    clear
    echo "STUDENT PORTAL"
    echo "1. View Grades"
    echo "2. View CGPA"
    echo "3. Logout"
    echo -n "Choose option: "
    read choice

    case $choice in
        1) view_grades
           read -p "Press Enter to continue..."
           ;;
        2) view_cgpa
           read -p "Press Enter to continue..."
           ;;
        3) break ;;
        *) echo "Invalid option!" ;;
    esac
done
