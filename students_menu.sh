#!/bin/bash
# Student interface script

# Function to display grades for the logged-in student
view_grades() {
    echo -e "\nYour Grades:"
    echo "Course | Marks | Grade"

    # Loop through all teacher-specific student files
    for teacher_file in students_*.txt; do
        # Extract teacher name from file name (e.g., students_john.txt -> john)
        teacher=${teacher_file#students_}
        teacher=${teacher%.txt}

        # Check if student exists in this file (case-insensitive match)
        if grep -qi "^$STUDENT_ID," "$teacher_file"; then
            # Display student record using awk for formatting
            grep -i "^$STUDENT_ID," "$teacher_file" | awk -F, -v t="$teacher" '{
                printf "%s (%s) | %s | %s\n", t, $2, $3, $4  # Teacher name (student name) | marks | grade
            }'
        fi
    done
}

# Function to calculate CGPA by averaging across all subjects/teachers
view_cgpa() {
    cgpa="0.00"           # Total CGPA points
    courses_found=0       # Number of files/teachers the student appears in

    # Loop through all teacher student files
    for teacher_file in students_*.txt; do
        if grep -qi "^$STUDENT_ID," "$teacher_file"; then
            # Calculate CGPA for this file (for this student)
            current_cgpa=$(calculate_cgpa "$teacher_file" "$STUDENT_ID")
            
            # Add this CGPA to total
            cgpa=$(echo "$cgpa + $current_cgpa" | bc)
            courses_found=$((courses_found + 1))
        fi
    done

    # If student was found in at least one file, average the CGPA
    if [ $courses_found -gt 0 ]; then
        final_cgpa=$(echo "scale=2; $cgpa / $courses_found" | bc)  # Rounded to 2 decimal places
        echo -e "\nYour CGPA: $final_cgpa"
    else
        echo "No courses found!"  # No records found across files
    fi
}

# Main menu loop for student
while true; do
    clear  # Clear screen on every iteration
    echo "STUDENT PORTAL"
    echo "1. View Grades"
    echo "2. View CGPA"
    echo "3. Logout"
    echo -n "Choose option: "
    read choice

    case $choice in
        1) view_grades                       # Show student grades
           read -p "Press Enter to continue..." ;;
        2) view_cgpa                         # Show student CGPA
           read -p "Press Enter to continue..." ;;
        3) break                             # Exit the loop and logout
           ;;
        *) echo "Invalid option!"            # Catch invalid menu choices
           ;;
    esac
done
