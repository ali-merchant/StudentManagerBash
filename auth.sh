
#authenitcation helper fucntions for login

authenticate_teacher() {
    echo -n "Enter Username: "
    read username
    echo -n "Enter Password: "
    read -s password
    echo ""

    TEACHER_CREDENTIALS="teacher_creds.txt" # set file name
                #caret specifies start
                #$specifies end
                #ONLY username,password
    if grep -q "^$username,$password$" "$TEACHER_CREDENTIALS"; then
        echo "Login successful!"
        TEACHER_ID="$username"
        STUDENT_RECORDS="students_${TEACHER_ID}.txt"
        #if NOT exists STUDENT_RECORDS
        # && Runs second command only if first is true
        [[ ! -f "$STUDENT_RECORDS" ]] && touch "$STUDENT_RECORDS"

        return 0  # Success
    else
        echo "Invalid credentials!"
        return 1  # Failure
    fi
}

authenticate_student() {
    echo -n "Enter Roll Number: "
    read roll_no
    echo -n "Enter Password: "
    read -s password
    echo ""

    # Convert to lowercase for case-insensitive matching
    #tr ~ translate all upper to lower
    roll_no=$(echo "$roll_no" | tr '[:upper:]' '[:lower:]')

    # Use grep for authentication
    #silent insensitive
    #-v is ! in grep
    if grep -qi "^$roll_no,$password$" student_creds.txt; then
        STUDENT_ID="$roll_no"
        echo "Student login successful!"
        return 0
    else
        echo "Invalid credentials!"
        return 1
    fi
}
