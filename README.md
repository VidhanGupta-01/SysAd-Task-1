# SysAd-Task-1

initUsers.sh :
#!/bin/bash --> This is called a shebang. It tells the system to run this script using the Bash shell.
getent group "$group" --> checks if the group exists.
! --> means NOT.
sudo --> runs this command as superuser (admin privileges).
Redirecting output to --> /dev/null hides the output.
-m--> create home directory.
-d--> specify home directory path.
-g--> assign primary group.
if --> opens if loop.
fi --> closes if loop.
mkdir --> make directory.
chown--> change owner.
chown -R --> recursive operation.
ln --> creates link.
-s	--> Create symbolic link.
-n	--> Do not dereference symlinks to dirs.
-f	--> Force removal of destination before link.
chmod 700 --> Sets permissions on the home directory to 700.
yq --> (a YAML parser) to read the list of users under the role key in the YAML file.
e --> echo.
parse_yaml --> calls for all roles to create all users and their directories.
do --> helps in performing any action.
setfacl --> (access control lists) to give that moderator read-write access to the author's public folder.
base64 --> command in Bash is a standard utility used to encode and decode data using the Base64 encoding scheme.
chmod --> change mode.
done --> marks the end of a loop block-specifically for for, while, and until loops.
rwx --> stands for read, write, execute.
ACLs --> used to finely control access rights between moderators, authors, and admins.
