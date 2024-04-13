#!/bin/bash

file="tasks.csv"

if [ ! -f "$file" ]; then
    touch "$file"
    echo "Id, Name, Status, Due Date, Description" > "$file"
    echo "Database created"
fi

display_menu() {
    echo "Task Management System"
    echo "1. Display Tasks"
    echo "2. Add Task"
    echo "3. Change Task Status"
    echo "4. Edit Task"
    echo "5. Remove Task"
    echo "0. Exit"
}

display_task() {
    task_id="$1"
    echo "Task details: "
    awk -F"," 'NR == 1 { printf "%s\t%s\t%s\t\t%s\t\t%s\n", $1, $2, $3, $4, $5 }' "$file"
    awk -v id="$task_id" -F"," '$1 == id { printf "%s\t%s\t%s\t\t%s\t\t%s\n", $1, $2, $3, $4, $5 }' "$file"
    echo ""
}

display_tasks() {
    echo "Tasks: "
    awk -F"," '{ printf "%s\t%s\t%s\t\t%s\t\t%s\n", $1, $2, $3, $4, $5 }' "$file"
    echo ""
}

add_task() {
    last_id=$(tail -n 1 "$file" | cut -d',' -f1)
    if [ -z "$last_id" ]; then
        new_id=1
    else
        new_id=$((last_id + 1))
    fi

    echo "Enter task details:"
    echo -n "Name: "
    read name
    echo -n "Due Date: "
    read due_date
    echo -n "Description: "
    read description
    
    echo -e "\n$new_id, $name, "In Progress", $due_date, $description" >> "$file"
    echo "Task added successfully, with ID: $new_id\n"
}

change_task_status() {
    echo -n "Enter task ID to change status: "
    read task_id

    if grep -q "^$task_id," "$file"; then
        display_task "$task_id"

        # status options
        echo -e "[ Done(d) | Skipped(s) | In Progress(p) ]\nEnter new status (d/s/p): "
        read new_sts

        if [ "$new_sts" == 'd' ]; then
            new_status="Done"
        elif [ "$new_sts" == 's' ]; then
            new_status="Skipped"
        elif [ "$new_sts" == 'p' ]; then
            new_status="In Progress"
        else
            echo "Invalid status. Please enter 'd', 's', or 'p'."
            return
        fi

        # apply the change
        temp_file="temp.csv"

        awk -v id="$task_id" -v status="$new_status" -F="," '{if ($1 == id) { $3 = status } print }' "$file"
        mv "$temp_file" "$file"

        echo -e "Status of task with ID $task_id changed to $new_status.\n"
    else
        echo -e "Task with ID $task_id does not exist.\n"
    fi
}

edit_menu() {
    echo "Edit Task Details"
    echo "1. Display Task"
    echo "2. Change Name"
    echo "3. Change Due Date"
    echo "4. Change Description"
    echo "0. Previous Menu"
}

edit_task() {
    echo -n "Enter task ID to edit: "
    read task_id

    if grep -q "^$task_id," "$file"; then
        display_task "$task_id"

        while true; do
            edit_menu
            echo -n "Enter your choice: "
            read choice
        
            case $choice in
                1) display_task "$task_id" ;;
                2) change_name "$task_id" ;;
                3) change_due_date "$task_id" ;;
                4) change_description "$task_id" ;;
                0) echo -e "Exiting...\n" ; return ;;
                *) echo "Invalid Choice" ;;
            esac
        done
    else
        echo -e "Task with ID $task_id does not exist.\n"
    fi
}

remove_task() {
    echo -n "Enter task ID to remove: "
    read task_id
    
    if grep -q "^$task_id," "$file"; then
        display_task "$task_id"

        temp_file="temp.csv"
        
        awk -v id="$task_id" -F"," '$1 != id' "$file" > "$temp_file"
        
        mv "$temp_file" "$file"
        
        echo -e "Task with ID $task_id removed successfully.\n"
    else
        echo -e "Task with ID $task_id does not exist.\n"
    fi
}

while true; do
    display_menu
    echo -n "Enter your choice: "
    read choice
    
    case $choice in
        1) display_tasks ;;
        2) add_task ;;
        3) change_task_status ;;
        4) edit_task ;;
        5) remove_task ;;
        0) echo "Exiting..."; exit ;;
        *) echo "Invalid choice..." ;;
    esac
done