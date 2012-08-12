#
## Calomel.org  ssh_gatekeeper.sh
#
## This script is run by the ForceCommand directive in the sshd_config. It expects
## the user SSH'ing to the box to answer the $QUERY question before being allowed
## a shell. Permissions of this script should be owned by root and executable by
## all other users (chmod 755)". Rsync, sftp and sshfs are allowed through,
## but scp is denied.
#

GOOGLE_AUTHENTICATOR='google-authenticator-demo'

## Disconnect clients who try to quit the script (Ctrl-c)
trap jail INT
jail()
 {
   kill -9 $PPID
   exit 0
 }

## Allow SSH. Clients can ssh to the box and then answer the $QUERY question.
if [ -z "$SSH_ORIGINAL_COMMAND" ];
  then
    ### The Decision
    ### If the binary exits okay, give the user their shell.
    ### If the binary exits with an error, log the attempt and kill the connection.
    $GOOGLE_AUTHENTICATOR

    if [ $? -eq 0 ];
      then
        $SHELL -l
        exit 0
      fi

    logger "ssh_gatekeeper $USER login failed from $SSH_CLIENT"
    kill -9 $PPID
    exit 0
fi

## Allow RSYNC. Rsync can not be used with the question above.
## We need to let the command though so our shell environment is clean. 
if [ `echo $SSH_ORIGINAL_COMMAND | awk '{print $1}'` = rsync ];
  then
    $SHELL -c "$SSH_ORIGINAL_COMMAND"
    exit 0
fi

## Allow sftp and sshfs. Make sure the path to your sftp-server binary
## is correctly expressed below. We need to let the command though so
## our shell environment is clean.
if [ `echo $SSH_ORIGINAL_COMMAND | awk '{print $1}'` = "/usr/lib/openssh/sftp-server" ];
  then
    $SHELL -c "$SSH_ORIGINAL_COMMAND"
    exit 0
fi

## Default deny. This is the last command to catch all other command
## input. If the client tries to use anything other than ssh or rsync
## the connection is dropped. SCP is denied.
kill -9 $PPID
exit 0
