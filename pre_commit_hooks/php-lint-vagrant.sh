#!/bin/bash

# Bash PHP Linter for Pre-commits
#
# Exit 0 if no errors found
# Exit 1 if errors were found
#
# Requires
# - php
#
# Arguments
# -p : Path to the PHP files in the vagrant box
#      Include a trailing slash in the path
#
#      Example
#      -p /var/www/html/
#      -p /vagrant/src/

# Check Flags - denotes if we should check all files or stop at the first error file
check_args_flag_all='all'
check_args_flag_first='first'

# Optional path to prepend
basepath=''

# Echo Colors
msg_color_magenta='\e[1;35m'
msg_color_yellow='\e[0;33m'
msg_color_none='\e[0m' # No Color

# Where to stop looking for file paths in the argument list
arg_lookup_start=1

# Flag to denote if a PHP error was found
php_errors_found=false

# Figure out if options were passed
while getopts ":p:" optname
  do
    case "$optname" in
      "p")
        ((arg_lookup_start++))
        basepath=$OPTARG
        ;;
    esac
  done

# Loop through the list of paths to run php lint against
echo -en "${msg_color_yellow}Running PHP Linter ...${msg_color_none} \n"

parse_error_count=0
for path in ${*:$arg_lookup_start}
do
    OUTPUT=$(vagrant ssh -c "php -l ${basepath}${path}")
    if echo "${OUTPUT}" | grep -qv "No syntax errors detected"; then
        parse_error_count=$[$parse_error_count +1]
        php_errors_found=true
    fi
done;

if [ "$php_errors_found" = true ]; then
    echo -en "${msg_color_magenta}$parse_error_count${msg_color_none} ${msg_color_yellow}PHP Parse error(s) were found!${msg_color_none} \n"
    exit 1
fi

echo -en "${msg_color_yellow}No PHP syntax errors found${msg_color_none} \n"
exit 0
