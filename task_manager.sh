#!/bin/bash

file="tasks.csv"

if [ ! -f "$file" ]; then
    touch "$file"
    echo "Id, Name, Status, Due Date, Description" > "$file"
    echo "Database created"
fi

main_menu() {
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
    awk -F", " 'NR == 1 { printf "%s\t%s\t%s\t\t%s\t\t%s\n", $1, $2, $3, $4, $5 }' "$file"
    awk -v id="$task_id" -F", " '$1 == id { printf "%s\t%s\t%s\t\t%s\t\t%s\n", $1, $2, $3, $4, $5 }' "$file"
    echo ""
}

display_tasks() {
    echo "Tasks: "
    awk -F", " 'NR == 1 { printf "%s\t%s\t%s\t\t%s\t\t%s\n", $1, $2, $3, $4, $5 }' "$file"
    awk -F", " 'NR > 1 { printf "%s\t%s\t%s\t\t%s\t\t%s\n", $1, $2, $3, $4, $5 }' "$file"
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
        echo -e -n "[ Done(d) | Skipped(s) | In Progress(p) ]\nEnter new status (d/s/p): "
        read new_sts

        case "$new_sts" in
            d) new_status="Done" ;;
            s) new_status="Skipped" ;;
            p) new_status="In Progress" ;;
            *)
                echo -e "Invalid status. Please enter 'd', 's', or 'p'.\n"
                return
                ;;
        esac

        # apply the change
        temp_file="temp.csv"

        awk -v id="$task_id" -v status="$new_status" -F", " '{if ($1 == id) { $3 = status } { printf "%s, %s, %s, %s, %s\n", $1, $2, $3, $4, $5 } }' "$file" > "$temp_file"
        mv "$temp_file" "$file"

        echo -e "Status of task with ID $task_id changed to $new_status.\n"
    else
        echo -e "Task with ID $task_id does not exist.\n"
    fi
}

change_name() {
    task_id="$1"

    echo -e -n "Enter new name: "
    read new_name

    # apply the change
    temp_file="temp.csv"

    awk -v id="$task_id" -v name="$new_name" -F", " '{if ($1 == id) { $2 = name } { printf "%s, %s, %s, %s, %s\n", $1, $2, $3, $4, $5 } }' "$file" > "$temp_file"
    mv "$temp_file" "$file"

    echo -e "Name of task with ID $task_id changed to $new_name.\n"
}

change_due_date() {
    task_id="$1"
    echo -e -n "Enter new due date: "
    read new_date

    # apply the change
    temp_file="temp.csv"

    awk -v id="$task_id" -v date="$new_date" -F", " '{if ($1 == id) { $4 = date } { printf "%s, %s, %s, %s, %s\n", $1, $2, $3, $4, $5 } }' "$file" > "$temp_file"
    mv "$temp_file" "$file"

    echo -e "Due date of task with ID $task_id changed to $new_date.\n"
}

change_description() {
    task_id="$1"
    echo -e -n "Enter new description: "
    read new_desc

    # apply the change
    temp_file="temp.csv"

    awk -v id="$task_id" -v desc="$new_desc" -F", " '{if ($1 == id) { $5 = desc } { printf "%s, %s, %s, %s, %s\n", $1, $2, $3, $4, $5 } }' "$file" > "$temp_file"
    mv "$temp_file" "$file"

    echo -e "Description of task with ID $task_id changed to $new_desc.\n"
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
    main_menu
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