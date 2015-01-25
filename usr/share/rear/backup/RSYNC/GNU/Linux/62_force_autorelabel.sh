[ -f $TMP_DIR/force.autorelabel ] && {

	> "${TMP_DIR}/selinux.autorelabel"

	case $RSYNC_PROTO in

	(ssh)
		# for some reason rsync changes the mode of backup after each run to 666
		ssh $RSYNC_USER@$RSYNC_HOST "chmod $v 755 ${RSYNC_BACKUP_DIR}" 2>&8
		$BACKUP_PROG -a "${TMP_DIR}/selinux.autorelabel" \
		 "$RSYNC_USER@$RSYNC_HOST:${RSYNC_BACKUP_DIR}/.autorelabel" 2>&8
		_rc=$?
		if [ $_rc -ne 0 ]; then
			LogPrint "Failed to create .autorelabel on ${RSYNC_BACKUP_DIR} [${rsync_err_msg[$_rc]}]"
			#StopIfError "Failed to create .autorelabel on ${RSYNC_BACKUP_DIR}"
		fi
		;;

	(rsync)
		$BACKUP_PROG -a "${TMP_DIR}/selinux.autorelabel" \
		 "${RSYNC_PROTO}://${RSYNC_USER}@${RSYNC_HOST}:${RSYNC_PORT}/${RSYNC_BACKUP_DIR}/.autorelabel"
		_rc=$?
		if [ $_rc -ne 0 ]; then
			LogPrint "Failed to create .autorelabel on ${RSYNC_PATH}/${RSYNC_BACKUP_DIR} [${rsync_err_msg[$_rc]}]"
			#StopIfError "Failed to create .autorelabel on ${RSYNC_BACKUP_DIR}"
		fi
		;;

	(*)
		local scheme=$(url_scheme $BACKUP_URL)
		local path=$(url_path $BACKUP_URL)
		local opath=$(backup_path $scheme $path)
		# probably using the BACKUP=NETFS workflow instead
		if [ -d "${opath}" ]; then
			if [ ! -f "${opath}/selinux.autorelabel" ]; then
				> "${opath}/selinux.autorelabel"
				StopIfError "Failed to create selinux.autorelabel on ${opath}"
			fi
		fi
		;;

	esac
	Log "Trigger (forced) autorelabel (SELinux) file"
}

