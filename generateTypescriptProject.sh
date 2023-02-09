#!/bin/bash

## Parameters, validation and usage
function usage {
    echo ""
    echo "Updates coreDns for fargate."
    echo ""
    echo "usage: generate-typescript-project.sh --name string"
    echo ""
    echo "  --name      string     name for the cdk project"
    echo "  --path      string     path to directory to create project in(defaults to current working directory)"
    echo
}

function die {
    printf "Script failed: %s\n\n" "$1"
    exit 1
}

while [ $# -gt 0 ]; do
    if [[ $1 == "--help" ]]; then
        usage
        exit 0
    elif [[ $1 == "--"* ]]; then
        v="${1/--/}"
        declare "$v"="$2"
        shift
    fi
    shift
done

if [[ -z $name ]]; then
    usage
    die "Missing parameter --name"
fi

if [[ -z $path ]]; then
  root="."
else
  root=$path
fi

## functions
function setup {
    home=$(pwd)
    workdir="$root/$name"
    mkdir $workdir
}

function createBaseCdkProject {
    cd $workdir
    cdk init app --language=typescript 
    cd $home
}

function updateEntryPoint {
    for file in "$(ls $workdir/bin/)"
    do
        eval "cat <<EOF
$(<$home/templates/cdk.template)
EOF
    " > "$workdir/bin/$file"
    done
}

function setupSrcDirectory {
    rm -r $workdir/lib
    mkdir $workdir/src
    cp -r $home/templates/src_template/* $workdir/src/
}

function runInstall {
    cd $workdir
    npm install
}

## Begin script
setup

createBaseCdkProject

updateEntryPoint

setupSrcDirectory

runInstall


