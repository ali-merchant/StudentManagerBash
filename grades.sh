#!/bin/bash
# Helper functions used by both teachers and students

# Function to calculate grade based on marks
calculate_grade() {
    marks=$1  # Get marks passed as first argument

    if [ "$marks" -ge 90 ]; then
        echo "A"
    elif [ "$marks" -ge 80 ]; then
        echo "B"
    elif [ "$marks" -ge 70 ]; then
        echo "C"
    elif [ "$marks" -ge 60 ]; then
        echo "D"
    else
        echo "F"
    fi
}

# Function to convert letter grade to grade points (for CGPA)
grade_to_points() {
    case $1 in
        A) echo 4.0 ;;  # Grade A = 4.0 points
        B) echo 3.0 ;;  # Grade B = 3.0 points
        C) echo 2.0 ;;  # Grade C = 2.0 points
        D) echo 1.0 ;;  # Grade D = 1.0 point
        *) echo 0.0 ;;  # Grade F or anything else = 0.0 points
    esac
}

# Function to calculate CGPA for a student using their roll number
calculate_cgpa() {
    student_file="$1"  # Student record file
    roll_no="$2"       # Roll number to look for

    # Find all lines matching the student roll number (case-insensitive)
    records=$(grep -i "^$roll_no," "$student_file")

    total_points=0  # Sum of grade points
    total_credits=0 # Total subjects/courses counted

    # Read each matched line and calculate grade points
    # Format: roll,name,marks,subject
    while IFS=, read -r _ _ marks _; do
        grade=$(calculate_grade "$marks")           # Convert marks to grade
        points=$(grade_to_points "$grade")          # Convert grade to points
        total_points=$(echo "$total_points + $points" | bc)  # Add points (using bc for floating-point)
        total_credits=$((total_credits + 1))        # Count subjects
    done <<< "$records"

    # If student has at least one subject, calculate CGPA
    if [ "$total_credits" -gt 0 ]; then
        cgpa=$(echo "scale=2; $total_points / $total_credits" | bc)  # Round to 2 decimal places
        echo "$cgpa"
    else
        echo "0.00"  # No subjects = CGPA is 0.00
    fi
}
