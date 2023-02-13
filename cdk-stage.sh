#!/bin/bash

##
# Parameters, validation and usage
##
function usage {
    echo ""
    echo "Updates coreDns for fargate."
    echo ""
    echo "usage: generate-typescript-project.sh --name string"
    echo ""
    echo "  --name      string     name for the cdk project"
    echo "  --config    string     full path to stage config file. If none provided, generates sample stages using a default config."
    echo "  --path      string     full path to directory to create project in(defaults to current working directory)"
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

if [[ -z $config ]]; then
  config="$home/config/example.json"
else
  config=$path
fi

##
# Functions
##
function setup {
    home=$(pwd)
    workdir="$root/$name"
    mkdir $workdir

    if [[ -z $config ]]; then
        configfile="$home/config/default.json"
    else
        configfile=$config
    fi
}

function createBaseCdkProject {
    cd $workdir
    cdk init app --language=typescript 
    cd $home
}

function updateEntryPoint {
    rm $workdir/bin/*
    eval "cat <<EOF
$(<$home/templates/cdk.ts.template)
EOF" > "$workdir/bin/cdk.ts"
}

function setupSrcDirectory {
    rm -r $workdir/lib
    mkdir $workdir/src
    cp -r $home/templates/src-dir-template/* $workdir/src/
}

function createStage {
    if [ ! -d "$workdir/src/stages/$ou" ]; then
            mkdir "$workdir/src/stages/$ou"
            eval "cat <<-EOF
$(<$home/templates/ou.template)
EOF" > "$workdir/src/stages/$ou/index.ts"
    fi

    if [ ! -d "$workdir/src/stages/$ou/$account" ]; then
        mkdir "$workdir/src/stages/$ou/$account"
            eval "cat <<-EOF
$(<$home/templates/account.template)
EOF" > "$workdir/src/stages/$ou/$account/index.ts"
    fi

    if [ ! -d "$ou/$account/$region" ]; then
        mkdir "$workdir/src/stages/$ou/$account/$region"
            eval "cat <<-EOF
$(<$home/templates/region.template)
EOF" > "$workdir/src/stages/$ou/$account/$region/index.ts"
    fi
}

function createConfigIndex {
    eval "cat <<-EOF
$(<$home/templates/region-index.template)
EOF" > "$workdir/src/configuration/regions/index.ts"
}

function createConfigFile {
     eval "cat <<-EOF
$(<$home/templates/region-config.template)
EOF" > "$workdir/src/configuration/regions/${region}.ts"
}

function createRegionConfigs {
    declare -a imports=()
    declare -a configs=()
    
    for region in ${regions[@]}; do
        regionname=$(echo $region | sed -r 's/^(.)|-(.)/\U\1\U\2/g' )
        importstatement="import { config as ${regionname}Config } from \"./$region\";"
        imports+=("$importstatement")
        config="['$region']: ${regionname}Config,"
        #echo $config
        configs+=("$config")

        createConfigFile
    done

    createConfigIndex
}

function generateStages {
    all_regions=()

    for LINE in $(cat "$config"); do
        STRING=$(echo $LINE | tr -d '\n')
        if [[ "$STRING" =~ "^(#)||(\/\/).*" ]]; then
            # Skip commented lines
            continue
        fi
        readarray -d / -t namespace <<< "$STRING"
        ou=${namespace[0]}
        account=${namespace[1]}
        region=$(echo ${namespace[2]} | tr -d '\n')
        regionname=$(echo $region | sed -r 's/^(.)|-(.)/\U\1\U\2/g' )
        createStage
        declare -A regionObj
        
        all_regions+=($region)
    done
    regions=$(printf "%s\n" "${all_regions[@]}" | sort -u | tr '\n' ' ')
    createRegionConfigs
}

function runInstall {
    cd $workdir
    npm install
}

##
# Begin script
##
setup

createBaseCdkProject

updateEntryPoint

setupSrcDirectory

generateStages

runInstall


