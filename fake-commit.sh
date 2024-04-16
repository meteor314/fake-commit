#!/bin/bash

generate_random_date() {
    start_timestamp=$(date -d "$1" +%s)
    end_timestamp=$(date -d "$2" +%s)
    while true; do
        random_timestamp=$((start_timestamp + RANDOM % (end_timestamp - start_timestamp + 1)))
        random_date=$(date -d "@$random_timestamp" +"%Y-%m-%d")
        day_of_week=$(date -d "$random_date" +"%u")
        if [ "$day_of_week" -le 5 ]; then
            break
        fi
    done
    echo "$(date -d "@$random_timestamp" +"%Y-%m-%d %H:%M:%S")"
}

generate_random_commit() {
    random_message=$(shuf -n 1 messages.txt)
    random_date=$1
    echo "Creating commit on $random_date with message: \"$random_message\""
    echo "Commit on $random_date: $random_message" >> "$folder/commits.log"
    git add "$folder/commits.log"
    git commit --date="$random_date" -m "$random_message" >/dev/null 2>&1
}

# Main script
echo "Welcome to the random commit generator!"
read -p "Enter the start date (YYYY-MM-DD): " start_date
read -p "Enter the end date (YYYY-MM-DD): " end_date
read -p "Enter the folder where commits should be logged (press Enter for current directory): " folder

# set default folder to current directory if empty
folder="${folder:-.}"

if [ -d "$folder/.git" ]; then
    rm -rf "$folder/.git"
fi

mkdir -p "$folder"

cat <<EOF > messages.txt
Fix typo
Update documentation
Add feature
Refactor code
Fix bug
Implement new functionality
EOF


cd "$folder" || exit
git init >/dev/null 2>&1

current_date="$start_date"
while [[ "$current_date" < "$end_date" ]]; do
    skip_day=$((RANDOM % 2))
    if [ "$skip_day" -eq 0 ]; then
        num_commits=$((RANDOM % 2 + 2))
        for ((i = 0; i < num_commits; i++)); do
            generate_random_commit "$current_date"
        done
    fi
    current_date=$(date -d "$current_date + 1 day" +"%Y-%m-%d")
done

echo "Commits generated successfully."

echo "Would you like to push the commits to a remote repository? This will overwrite the existing commits in the remote repository."

select yn in "Yes" "No"; do
	case $yn in
		Yes ) read -p "Enter the remote repository URL: " remote_url
			  git remote add origin "$remote_url"
				current_branch=$(git branch --show-current) # get current branch
				git push -u origin "$current_branch" --force 
			  break;;
		No ) echo "Commits were not pushed to a remote repository."
			 break;;
	esac
done
