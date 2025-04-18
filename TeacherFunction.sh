#!/bin/bash

# Accessible by teacher!
# This file includes all the functions used by teachers for managing student records.

#---------------------------------------------------
# Function to add a new student to the record file
#---------------------------------------------------
add_student() {
    # Check if student record file exists and count lines (students)
    if [[ -f "$STUDENT_RECORDS" ]]; then
        student_count=$(wc -l < "$STUDENT_RECORDS")
    else
        student_count=0
    fi

    # Limit max students per teacher to 20
    if (( student_count >= 20 )); then
        echo "Error: Maximum limit of 20 students per teacher reached."
        return 1
    fi

    # Input Roll Number
    echo -n "Enter Roll Number: "
    read roll_no
    roll_no=$(echo "$roll_no" | tr '[:upper:]' '[:lower:]')  # set to lowercase

    if [[ -z "$roll_no" ]]; then
        echo "Error: Roll number must be a non-empty value."
        return 1
    fi

    # Check for duplicate Roll Number
    if grep -qi "^$roll_no," "$STUDENT_RECORDS"; then
        echo "Error: A student with Roll Number $roll_no already exists."
        return 1
    fi

    # Input student name
    echo -n "Enter Name: "
    read name

    # Name validation: not empty or containing commas (CSV format safe)
    if [[ -z "$name" || "$name" =~ [,] ]]; then
        echo "Error: Name cannot be empty or contain commas."
        return 1
    fi

    # Input marks
    echo -n "Enter Marks (0-100): "
    read marks

    # Validate marks are numeric and in range
    if ! [[ "$marks" =~ ^[0-9]+$ ]] || (( marks < 0 || marks > 100 )); then
        echo "Error: Marks must be a number between 0 and 100."
        return 1
    fi

    # Calculate grade using helper function
    grade=$(calculate_grade "$marks")

    # Append to CSV file: roll_no,name,marks,grade
    echo "$roll_no,$name,$marks,$grade" >> "$STUDENT_RECORDS"
    echo "Student added successfully!"
}

#-------------------------------------
# Function to display all students
#-------------------------------------
view_students() {
    if [ ! -f "$STUDENT_RECORDS" ]; then
        echo -e "\nNo student records found."
        return
    fi
    echo -e "\nRoll No | Name | Marks | Grade"
    cat "$STUDENT_RECORDS"
}

#-------------------------------------
# Function to delete a student record
#-------------------------------------
delete_student() {
    echo -n "Enter Roll Number to delete: "
    read roll_no
    roll_no=$(echo "$roll_no" | tr '[:upper:]' '[:lower:]')

    if [[ -z "$roll_no" ]]; then
        echo "Error: Roll number cannot be empty."
        return 1
    fi

    # Check if student exists
    if ! grep -qi "^$roll_no," "$STUDENT_RECORDS"; then
        echo "Error: No student found with Roll Number $roll_no."
        return 1
    fi

    cp "$STUDENT_RECORDS" "${STUDENT_RECORDS}.bak"  # Backup original

    # Remove the student entry (case-insensitive match)
    grep -vi "^$roll_no," "$STUDENT_RECORDS" > temp.txt

    # Replace original file
    if [[ -f temp.txt ]]; then
        mv temp.txt "$STUDENT_RECORDS"
        echo "Student with Roll Number $roll_no deleted successfully!"
    else
        echo "Error: Failed to delete student record."
        mv "${STUDENT_RECORDS}.bak" "$STUDENT_RECORDS"
    fi

    rm -f temp.txt
}

#-------------------------------------
# Function to update marks for a student
#-------------------------------------
update_marks() {
    echo -n "Enter Roll Number to update: "
    read roll_no
    roll_no=$(echo "$roll_no" | tr '[:upper:]' '[:lower:]')

    if ! grep -qi "^$roll_no," "$STUDENT_RECORDS"; then
        echo "Error: No student found with Roll Number $roll_no."
        return 1
    fi

    echo -n "Enter new marks: "
    read new_marks

    # Validate new marks
    if ! [[ "$new_marks" =~ ^[0-9]+$ ]] || (( new_marks < 0 || new_marks > 100 )); then
        echo "Error: Marks must be a number between 0 and 100."
        return 1
    fi

    new_grade=$(calculate_grade "$new_marks")

    # Update the specific student's marks and grade using sed
    sed -i "/^$roll_no,/s/^\([^,]*,[^,]*,\)[^,]*,[^,]*$/\1$new_marks,$new_grade/" "$STUDENT_RECORDS"
    echo "Marks updated successfully!"
}

#----------------------------------------------------------
# Function to list students who passed (CGPA >= threshold)
#----------------------------------------------------------
list_passed_students() {
    threshold=${1:-2.0}
    echo -e "\nPassed Students (CGPA >= $threshold):"
    echo "Roll No | Name | CGPA"

    while IFS=, read -r roll_no name marks _; do
        cgpa=$(calculate_cgpa "$STUDENT_RECORDS" "$roll_no")
        if (( $(echo "$cgpa >= $threshold" | bc -l) )); then
            echo "$roll_no | $name | $cgpa"
        fi
    done < "$STUDENT_RECORDS" | sort -k3 -nr  # Sort by CGPA descending
}

#----------------------------------------------------------
# Function to list students who failed (CGPA < threshold)
#----------------------------------------------------------
list_failed_students() {
    threshold=${1:-2.0}
    echo -e "\nFailed Students (CGPA < $threshold):"
    echo "Roll No | Name | CGPA"

    while IFS=, read -r roll_no name marks _; do
        cgpa=$(calculate_cgpa "$STUDENT_RECORDS" "$roll_no")
        if (( $(echo "$cgpa < $threshold" | bc -l) )); then
            echo "$roll_no | $name | $cgpa"
        fi
    done < "$STUDENT_RECORDS" | sort -k3 -n  # Sort by CGPA ascending
}

#-----------------------------------------------------
# Function to sort students by CGPA (asc or desc)
#-----------------------------------------------------
list_students_by_cgpa() {
    echo -e "\n1. Ascending order (lowest CGPA first)"
    echo "2. Descending order (highest CGPA first)"
    echo -n "Choose sorting order: "
    read -r order

    echo -e "\nStudents List:"
    echo "Roll No | Name | CGPA"

    tmpfile=$(mktemp)
    declare -A processed_rolls  # To avoid duplicates

    while IFS=, read -r roll_no name marks _; do
        if [[ -z "${processed_rolls[$roll_no]}" ]]; then
            cgpa=$(calculate_cgpa "$STUDENT_RECORDS" "$roll_no")
            echo "$roll_no | $name | $cgpa" >> "$tmpfile"
            processed_rolls[$roll_no]=1
        fi
    done < "$STUDENT_RECORDS"

    # Sort using 3rd column (CGPA)
    if [ "$order" -eq 1 ]; then
        sort -t '|' -k3n "$tmpfile"   # Ascending
    else
        sort -t '|' -k3nr "$tmpfile"  # Descending
    fi

    rm "$tmpfile"
}
