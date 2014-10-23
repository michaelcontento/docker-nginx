#!/usr/bin/env bash
set -e

log() {
    echo $@
}

error() {
    log "ERROR: $@"
    exit 1
}

copyTemplate() {
    local srcFile=$1
    local dstFile=$2

    [ -z $srcFile ] && error "copyTemplate: srcFile argument missing"
    [ -z $dstFile ] && error "copyTemplate: dstFile argument missing"
    [ ! -f $srcFile ] && error "copyTemplate: source file ($srcFile) does not exists"

    cp -f $srcFile $dstFile
}

getEnvVars() {
    env | egrep '(_NAME=|_PORT_)'
}

replaceTemplateVars() {
    local file=$1
    [ -z $file ] && error "replaceTemplateVars: missing argument"

    for var in $(getEnvVars); do
        local parts=(${var/=/ })
        local key=${parts[0]}
        local keyStar=$(echo $key | sed -E 's/^[^_]+/\\*/')
        local value=${parts[1]}

        sed -i -e "s@{$key}@$value@g" $file
        sed -i -e "s@{$keyStar}@$value@g" $file
    done
}

processTemplate() {
    local srcFile=$1
    [ -z $srcFile ] && error "processTemplate: srcFile must be given"

    local dstFile="/etc/nginx/sites-enabled/$(basename $srcFile)"
    log "  $srcFile --> $dstFile"

    copyTemplate $srcFile $dstFile
    replaceTemplateVars $dstFile
}

log "===> Processing template arguments"
while (( "$#" )); do
    if [ "$1" == "--" ]; then
        shift
        break
    fi

    processTemplate $1
    shift
done

log "===> Running nginx"
exec nginx -g "daemon off;" $@
