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
elif [ -n "$ALLOW_SCP_RSYNC" ];
  then
    # rsync and scp don't like google-authenticator, so we're going to let them
    # run if $ALLOW_SCP_RSYNC is set.
    cmd=`echo "$SSH_ORIGINAL_COMMAND" | awk '{ print $1 }'`

    if [ "$cmd" = "rsync" -o "$cmd" = "scp" -o "$cmd" = "/usr/bin/rsync" -o "$cmd" = "/usr/bin/scp" ];
      then
        $SHELL -c "$SSH_ORIGINAL_COMMAND"
        exit 0
    fi

    cmd=''

    logger "ssh_gatekeeper $USER from $SSH_CLIENT attempted command $SSH_ORIGINAL_COMMAND"
fi

kill -9 $PPID
exit 0
