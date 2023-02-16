#!/bin/bash
# Last updated: 2023-01-11


start_time=$(date +%s)

BASEDIR=~/Discord/DiscordDMs-snapshot/

## TELEGRAM_NOTIFY_IF_FAILED=yes/no
TELEGRAM_NOTIFY_IF_FAILED=yes
## BTRFS_DEDUP=yes/no
BTRFS_DEDUP=no

thisyear=`date +%Y`
export red="$(tput setaf 1)"
export green="$(tput setaf 2)"
export cyan="$(tput setaf 6)"
export purple="$(tput setaf 057)"
export b="$(tput bold)"
export reset="$(tput sgr0)"


info() {
	printf "${b}${cyan}%s${reset} ${b}%s${reset}\\n" "::" "${@}"
}

fail() {
	printf "${red}%s${reset}\\n" "[ERROR] $*" >&2
}

succeed() {
	printf "${b}${green}%s${reset} %s\\n\\n" "[OK]" "${@}"
}

msg_head() {
	printf "${b}${cyan}%s${reset} ${b}%s${reset}" "${@}"
}

msg() {
	printf "${purple}%s${reset} %s${reset}\\n" "${@}"
}



notify_telegram() {
datetime=`date`
MESSAGE="$1"
curl -X POST -H 'Content-Type: application/json' -d "{\"chat_id\": \"$CHAT_ID\", \"text\": \"$MESSAGE\", \"disable_notification\": false}" https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
}

check_valid_token() {
	info "Verifying token"
	if discord-chat-exporter-cli dm -t $DISCORD_TOKEN 2>&1 >/dev/null | grep -q "Authentication token is invalid"; then
		fail "Token is invalid, it probably expired, please update a new one"
		[[ "$TELEGRAM_NOTIFY_IF_FAILED" == "yes" ]] && { notify_telegram "Discord DMs backup failed due to invalid token"; exit 1 ;}
	else
		succeed "Token is valid"
	fi
}

show_syntax() {
	echo "./exportDMs-Discord_inyear.sh <-manual/-weekly/-dedup>"
	exit 1
}

dedup() {
	info "Cleaning btrfs duplicated files"
	sudo duperemove -drA $BASEDIR
	dedup_end_time=$(date +%s)
	total_exec_time=$(( $dedup_end_time - $start_time ))
	msg_head "Exporting and deduplicating finished after:" ; msg "$(( $total_exec_time/60 )) min and $(( $total_exec_time%60 )) sec"
}

### START!
[ ! -d $BASEDIR ] && { fail "Failed to find destination dir, please re-check BASEDIR variable" ; exit 1 ;}
source $BASEDIR/exportDMs-Discord_inyear.sourcefile


OUTDIR_NAME=`echo DiscordDMs-snapshot inyear$thisyear_$(date +%Y-%m-%d\ %H:%M%:::z)`
case "$1" in
	"-manual" )
		info "Running in manual mode"
		OUTDIR_PATH="$BASEDIR/DiscordDMs-snapshot_manual/$OUTDIR_NAME" ;;
	"-weekly" )
		info "Running in weekly mode"
		OUTDIR_PATH="$BASEDIR/DiscordDMs-snapshot_weekly/$OUTDIR_NAME" ;;
	"-dedup" )
		dedup ;
		exit 1 ;;
	*)
		show_syntax ;;
esac

[ ! -d "$OUTDIR_PATH" ] && mkdir -p "$OUTDIR_PATH" || { msg "Oops, output dir already exists" ;}
info "Backing up DMs only in year $thisyear"
DATE=`date`
TELEGRAM_MSG=`echo Discord DMs backup started at $DATE`
[[ "$TELEGRAM_NOTIFY_IF_FAILED" == "yes" ]] && notify_telegram "$TELEGRAM_MSG"

check_valid_token

msg_head "Output dir name:" ; msg "$OUTDIR_NAME"
msg_head "Output dir full path:" ; msg "$OUTDIR_PATH"
echo
discord-chat-exporter-cli exportdm -t "$DISCORD_TOKEN" -f HtmlDark --media -o "$OUTDIR_PATH" --after $thisyear-01-01


end_time=$(date +%s)
exec_time=$(( $end_time - $start_time ))

storage_used=`du -h  "$OUTDIR_PATH" |tail -n 1 |cut -f1 `
msg_head "Storage used:" ; msg "$storage_used"
time_used=`echo $(( $exec_time/60 )) min and $(( $exec_time%60 )) sec`
msg_head "Backup finished after:" ; msg "$time_used"

TELEGRAM_MSG="Discord DMs backup finished after: $time_used, used $storage_used"
[[ "$TELEGRAM_NOTIFY_IF_FAILED" == "yes" ]] && notify_telegram "$TELEGRAM_MSG"

notify_telegram "----------"

if [ "BTRFS_DEDUP" == "yes" ]; then
	dedup
	exit 1
fi
