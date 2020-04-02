STAGING=${MODULES}/cli/projects/cli/src/cli
DESTINATION=svtcli@10.1.4.149:will/.
FILES="HivePolicy.pm svt-pv-policy-set SvtCommand.pm"

showStaging() {
    for file in $FILES
    do
        md5sum ${STAGING}/$file
    done
}


refresh() {
    for file in $FILES
    do
        scp ${STAGING}/$file ${DESTINATION}
    done
}

cat << FIN
    Available Functions:
    showStaging
    refresh
FIN

