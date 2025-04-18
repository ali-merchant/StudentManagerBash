#!/bin/bash

#Accessible by teacher !
#Includes all functions called by teachers

add_student() {

    if [[ -f "$STUDENT_RECORDS" ]]; then
        student_count=$(wc -l < "$STUDENT_RECORDS")
    else
        student_count=0
    fi

    if (( student_count >= 20 )); then
        echo "Error: Maximum limit of 20 students per teacher reached."
        return 1
    fi

    echo -n "Enter Roll Number: "
    read roll_no

    #set lower case
    roll_no=$(echo "$roll_no" | tr '[:upper:]' '[:lower:]')

    # Check if roll number is empty
    if [[ -z "$roll_no" ]]; then
        echo "Error: Roll number must be a non-empty value."
        return 1
    fi

    # Check if roll number already exists
    #-q to make silent -i to make case insensitive
    if grep -qi "^$roll_no," "$STUDENT_RECORDS"; then
        echo "Error: A student with Roll Number $roll_no already exists."
        return 1
    fi

    echo -n "Enter Name: "
    read name



    # Check if name is empty or contains commas (to avoid CSV corruption)
    if [[ -z "$name" || "$name" =~ [,] ]]; then
        echo "Error: Name cannot be empty or contain commas."
        return 1
    fi

    echo -n "Enter Marks (0-100): "
    read marks

    # Check if marks are a number between 0 and 100
    if ! [[ "$marks" =~ ^[0-9]+$ ]] || (( marks < 0 || marks > 100 )); then
        echo "Error: Marks must be a number between 0 and 100."
        return 1
    fi

    # Calculate grade
    grade=$(calculate_grade "$marks")

    # Append student record to file
    echo "$roll_no,$name,$marks,$grade" >> "$STUDENT_RECORDS"

    echo "Student added successfully!"
}


view_students() {
    if [ ! -f "$STUDENT_RECORDS" ]; then
        echo -e "\nNo student records found."
        return
    fi
    echo -e "\nRoll No | Name | Marks | Grade"
    cat "$STUDENT_RECORDS"
#     echo ""  # Ensures an extra newline after output
}

delete_student() {
    echo -n "Enter Roll Number to delete: "
    read roll_no

    #set lower case
    roll_no=$(echo "$roll_no" | tr '[:upper:]' '[:lower:]')


    # Check if input is empty
    if [[ -z "$roll_no" ]]; then
        echo "Error: Roll number cannot be empty."
        return 1
    fi

    # Check if student exists
    if ! grep -qi "^$roll_no," "$STUDENT_RECORDS"; then
        echo "Error: No student found with Roll Number $roll_no."
        return 1
    fi

    # Create a backup before deleting
    cp "$STUDENT_RECORDS" "${STUDENT_RECORDS}.bak"

    # Always create temp.txt, even if empty
    # insensitive grep get everything other than this roll
    grep -vi "^$roll_no," "$STUDENT_RECORDS" > temp.txt

    # Ensure temp.txt exists before replacing the file
    if [[ -f temp.txt ]]; then
        mv temp.txt "$STUDENT_RECORDS"
        echo "Student with Roll Number $roll_no deleted successfully!"
    else
        echo "Error: Failed to delete student record."
        mv "${STUDENT_RECORDS}.bak" "$STUDENT_RECORDS"  # Restore backup
    fi

    # Always delete temp.txt at the end
    rm -f temp.txt
}

update_marks() {
    echo -n "Enter Roll Number to update: "
    read roll_no

    # Convert roll number to lowercase
    roll_no=$(echo "$roll_no" | tr '[:upper:]' '[:lower:]')

    # Check if student exists
    if ! grep -qi "^$roll_no," "$STUDENT_RECORDS"; then
        echo "Error: No student found with Roll Number $roll_no."
        return 1
    fi

    echo -n "Enter new marks: "
    read new_marks

    # Check if marks are a valid number between 0 and 100
    if ! [[ "$new_marks" =~ ^[0-9]+$ ]] || (( new_marks < 0 || new_marks > 100 )); then
    echo "Error: Marks must be a number between 0 and 100."
        return 1
    fi

    new_grade=$(calculate_grade "$new_marks")

    # Use sed to update student record
    sed -i "/^$roll_no,/s/^\([^,]*,[^,]*,\)[^,]*,[^,]*$/\1$new_marks,$new_grade/" "$STUDENT_RECORDS"

    echo "Marks updated successfully!"
}

list_passed_students() {
    threshold=${1:-2.0}
    echo -e "\nPassed Students (CGPA >= $threshold):"
    echo "Roll No | Name | CGPA"

    # Process ONLY the current teacher's file
    while IFS=, read -r roll_no name marks _; do
        cgpa=$(calculate_cgpa "$STUDENT_RECORDS" "$roll_no")
        if (( $(echo "$cgpa >= $threshold" | bc -l) )); then
            echo "$roll_no | $name | $cgpa"
        fi
    done < "$STUDENT_RECORDS" | sort -k3 -nr
}

list_failed_students() {
    threshold=${1:-2.0}
    echo -e "\nFailed Students (CGPA < $threshold):"
    echo "Roll No | Name | CGPA"

    # Process ONLY the current teacher's file
    while IFS=, read -r roll_no name marks _; do
        cgpa=$(calculate_cgpa "$STUDENT_RECORDS" "$roll_no")
        if (( $(echo "$cgpa < $threshold" | bc -l) )); then
            echo "$roll_no | $name | $cgpa"
        fi
    done < "$STUDENT_RECORDS" | sort -k3 -n
}

list_students_by_cgpa() {
    echo -e "\n1. Ascending order (lowest CGPA first)"
    echo "2. Descending order (highest CGPA first)"
    echo -n "Choose sorting order: "
    read -r order

    echo -e "\nStudents List:"
    echo "Roll No | Name | CGPA"

    # Temporary file and associative array to track unique students
    tmpfile=$(mktemp)
    declare -A processed_rolls  # Track processed roll numbers

    # Process ONLY the current teacher's student file
    while IFS=, read -r roll_no name marks _; do
        # Skip if roll_no already processed
        if [[ -z "${processed_rolls[$roll_no]}" ]]; then
            cgpa=$(calculate_cgpa "$STUDENT_RECORDS" "$roll_no")
            echo "$roll_no | $name | $cgpa" >> "$tmpfile"
            processed_rolls[$roll_no]=1  # Mark as processed
        fi
    done < "$STUDENT_RECORDS"

    # Sort by CGPA (3rd field) using '|' as delimiter
    if [ "$order" -eq 1 ]; then
        sort -t '|' -k3n "$tmpfile"   # Ascending
    else
        sort -t '|' -k3nr "$tmpfile"  # Descending
    fi

    rm "$tmpfile"
}
