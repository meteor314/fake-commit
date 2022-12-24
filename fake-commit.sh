Color_Off='\033[0m'       # Text Reset
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;36m'         # Blue suck
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
#Colorsized text function

print_green() { # Print green text
	echo -e "${Green}" "${*}"
}
no_color() { # Print green text
	echo -e "${Color_Off}" "${*}"
}
print_red() { # Print green text
	echo -e "${Red}" "${*}"
}

print_blue() { # Print green text
	echo -e "${Blue}" "${*}"
}

print_white() { # Print green text
	echo -e "${White}" "${*}"
}


print_purple() { # Print green text
	echo -e "${Purple}" "${*}"
}

print_cyan() { # Print green text
	echo -e "${Cyan}" "${*}"
}

print_yellow () { # Print yellow text
	echo -e "${Yellow}" "${*}"
}

check_dependencies () {
	# checks if dependencies are present
	for dep; do
		if ! command -v "$dep" >/dev/null ; then
				print_red  "Program \"$dep\" not found. Please install it. 
				Type \"scoop install $dep\" if you're using windows or type apt-get install $dep if you're using linux"
				exit			
		fi
	done
}
check_dependencies git 


# generate fake commit for testing with bash 
mkcd() {
    mkdir -p "$@" && cd "$@"
}
# if os is windows go to temp folder
if [ "$OS" = "Windows_NT" ]; then
		cd /d %temp%
else
		cd /tmp
fi

mkcd fake-commit-history
git init
touch file.ini
git add file.ini

# ask for chose begin date 
print_blue "Enter begin date (YYYY-MM-DD): "
read begin_date
print_purple "Enter end date (YYYY-MM-DD): "
read end_date


no_color "This script will generate fake commit from $begin_date to $end_date,  
Please chose how many commit you want to generate each day:"
print_yellow "Enter min  number of commits: (or press enter, by default it's 1) "
read min_commits
echo "Enter max number of commits: ( or press enter, by default it's 3 ) "
read max_commits


print_green "Do you want to generate fake commit on weekends? (y/n)"
read weekends

# generate random number of commits beetween min and max
random_commits() {
    min=$1
    max=$2
    echo $(( $RANDOM % ($max - $min + 1) + $min ))
}

# generate fake commit for each day between begin and end date and for weekends if asked
while [ "$begin_date" != "$end_date" ]; do
    if [ "$weekends" = "y" ] || [ "$weekends" != "y" ] && [ "$(date -d "$begin_date" +%u)" -lt 6 ]; then
      # verify if min and max are set else set default value 1 and 3
      if [ -z "$min_commits" ]; then
				min_commits=1
			fi
			if [ -z "$max_commits" ]; then
				max_commits=3
			fi

      commits=$(random_commits $min_commits $max_commits)
      
     
      for i in $(seq 1 $commits); do
          # randomly skip some dates to simulate holidays
          if [ $(( $RANDOM % 10 )) -gt 5 ]; then
	   # for some commits, generate more then 7 commits
	       if [ $( random_commits 1 10 ) -gt 7 ]; then
						commits=$(random_commits 7 10)
				 fi
              echo "fake commit for $begin_date" >> file.ini
              # change commit date as the date of the day
              GIT_COMMITTER_DATE="$begin_date 12:00:00" git commit -m "fake commit for $begin_date" --date "$begin_date 12:00:00" file.ini
          fi
      done
    fi
    begin_date=$(date -I -d "$begin_date + 1 day")
done

print_blue "Fake commit generated in /tmp/fake-commit"
echo "Fake commit generated, you can chec this with: git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"

print_yellow "Do you want to push this fake commit to a remote repository? (y/n)"
read push

print_red "Do not forget to make your repository private!"

if [ "$push" = "y" ]; then
  no_color "Enter remote repository url: "
    read remote_url
    git remote add origin $remote_url
    git push -u origin master
fi

	

