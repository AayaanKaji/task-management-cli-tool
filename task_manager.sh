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
}

edit_task() {
    echo -n "Enter task ID to edit: "
    read task_id
}

remove_task() {
    echo -n "Enter task ID to remove: "
    read task_id
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