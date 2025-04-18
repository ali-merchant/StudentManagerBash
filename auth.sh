#!/bin/bash

# Authentication helper functions for login

# Function to authenticate a teacher
authenticate_teacher() {
    echo -n "Enter Username: "
    read username
    echo -n "Enter Password: "
    read -s password  # Hide input for security
    echo ""

    TEACHER_CREDENTIALS="teacher_creds.txt"  # File storing teacher credentials

    # Check if the username and password match an entry in the credentials file
    # ^ and $ ensure the whole line matches (no partial match)
    if grep -q "^$username,$password$" "$TEACHER_CREDENTIALS"; then
        echo "Login successful!"

        TEACHER_ID="$username"  # Store teacher ID
        STUDENT_RECORDS="students_${TEACHER_ID}.txt"  # File specific to that teacher

        # Create the student record file if it doesn't exist
        [[ ! -f "$STUDENT_RECORDS" ]] && touch "$STUDENT_RECORDS"

        return 0  # Success
    else
        echo "Invalid credentials!"
        return 1  # Failure
    fi
}

# Function to authenticate a student
authenticate_student() {
    echo -n "Enter Roll Number: "
    read roll_no
    echo -n "Enter Password: "
    read -s password  # Hide input
    echo ""

    # Convert roll number to lowercase for consistent matching
    roll_no=$(echo "$roll_no" | tr '[:upper:]' '[:lower:]')

    # Check if the roll number and password match in the student credentials file
    # -q: quiet, -i: case-insensitive
    if grep -qi "^$roll_no,$password$" student_creds.txt; then
        STUDENT_ID="$roll_no"  # Save student ID
        echo "Student login successful!"
        return 0  # Success
    else
        echo "Invalid credentials!"
        return 1  # Failure
    fi
}
