#!/bin/bash
#helper functions called by both parties


calculate_grade() {
    marks=$1
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

grade_to_points() {
    case $1 in
        A) echo 4.0 ;;
        B) echo 3.0 ;;
        C) echo 2.0 ;;
        D) echo 1.0 ;;
        *) echo 0.0 ;;
    esac
}

calculate_cgpa() {
    student_file="$1"
    roll_no="$2"

    # Get all records for the student (in case of multiple subjects)
    records=$(grep -i "^$roll_no," "$student_file")

    total_points=0
    total_credits=0

                # discard roll , name and grade
    while IFS=, read -r _ _ marks _; do
        grade=$(calculate_grade "$marks")
        points=$(grade_to_points "$grade")
        total_points=$(echo "$total_points + $points" | bc)
        total_credits=$((total_credits + 1))
    done <<< "$records"

    if [ "$total_credits" -gt 0 ]; then
                    #After decimal 2 point
                    #basic calculator
        cgpa=$(echo "scale=2; $total_points / $total_credits" | bc)
        echo "$cgpa"
    else
        echo "0.00"
    fi
}

