#!/usr/bin/env bash

# usage: ./plugins_upgrade.sh ./usr/share/jenkins/plugins.txt ./usr/share/jenkins/plugins_new.txt

export PATH="/usr/local/bin:$PATH"

#curl -sSL https://plugins.jenkins.io/apache-httpcomponents-client-4-api | grep -oP "<span.+\"v\".+(?<=>)(\d|\.|-)+(?=</span>)" | grep -oP '(?<=>)(\d|\.|-)+' | head -1
#curl -sSL https://plugins.jenkins.io/docker-workflow | grep -oP "<span.+\"v\".+(?<=>)(\d|\.|-)+(?=</span>)" | grep -oP '(?<=>)(\d|\.|-)+' | head -1
#curl -sSL https://plugins.jenkins.io/cloudbees-folder | grep -E '<h3.+Version.+' | grep -oP "(?<=Version)(\d|\.|-)+(?=\()" | awk 'NR==1{print $1}'

url_prefix="https://plugins.jenkins.io"

target_file="$2"
if [[ "$1" != "${target_file}" ]] && [[ ! -z "${target_file}" ]]; then
    rm -f ${target_file}
    touch ${target_file}
else
    echo "    warn: source and target must different files and target must not empty"
    exit 1
fi

while read -r spec || [[ -n "$spec" ]]; do

    plugin=(${spec//:/ });
    echo "${spec}"
    [[ ${plugin[0]} =~ ^# ]] && echo "${spec}" >> ${target_file} && continue
    [[ ${plugin[0]} =~ ^[[:space:]]*$ ]] && echo "${spec}" >> ${target_file} && continue
    [[ -z ${plugin[1]} ]] && plugin[1]="latest"

    name="${plugin[0]}"
    version="${plugin[1]}"

    latest_version="${version}"
    latest_in_span=$(curl -sSL ${url_prefix}/${name} | grep -oP "<span.+\"v\".+(?<=>)(\d|\.|-)+(?=</span>)" | grep -oP '(?<=>)(\d|\.|-)+' | head -1)
    if [[ "$?" != "0" ]]; then (>&2 echo "    error query latest_version for ${name}"); fi
    latest_in_changelog=$(curl -sSL ${url_prefix}/${name} | grep -E '<h3.+Version.+' | grep -oP "(?<=Version)(\d|\.)+(?=\()" | awk 'NR==1{print $1}')
    if [[ "$?" != "0" ]]; then (>&2 echo "    error query latest_version for ${name}"); fi

    if [[ ! -z "${latest_in_span}" ]] && [[ ! -z "${latest_in_changelog}" ]] && [[ "${latest_in_span}" == "${latest_in_changelog}" ]]; then
        latest_version="${latest_in_span}"
    elif [[ ! -z "${latest_in_span}" ]]; then
        latest_version="${latest_in_span}"
    else
        (>&2 echo "    warn: error query latest_version for ${name} latest_in_span: ${latest_in_span}, latest_in_changelog: ${latest_in_changelog}")
    fi

    if [[ "${version}" != "${latest_version}" ]]; then
        (>&2 echo "${name} new version found, current version: ${version}, latest version: ${latest_version}")
        echo "${name}:${latest_version}" >> ${target_file}
    else
        (>&2 echo "  ${name} no new version found, current version: ${version}, latest version: ${latest_version}")
        echo "${name}:${plugin[1]}" >> ${target_file}
    fi

done  < "$1"
