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

##
# Functions
##
function setup {
    home=$(pwd)
    workdir="$root/$name"
    mkdir $workdir

    if [[ -z $config ]]; then
        config="$home/config/example.json"
    else
        config=$path
    fi
}

function createBaseCdkProject {
    cd $workdir
    cdk init app --language=typescript 
    cd $home
}

function updateEntryPoint {
    entrypointName=$(jq .name $workdir/package.json --raw-output)
    rm $workdir/bin/*
    eval "cat <<EOF
$(<$home/templates/cdk.ts.template)
EOF" > "$workdir/bin/$entrypointName.ts"
}

function setupSrcDirectory {
    rm -r $workdir/lib
    mkdir $workdir/src
    cp -r $home/templates/src-dir-template/* $workdir/src/
}

function createRegionConfigFile {
    echo "Generating config file for $region"
    echo "as $workdir/src/configuration/regions/$region.ts..."

    eval "cat <<-EOF
$(<$home/templates/region-config.template)
EOF" > "$workdir/src/configuration/regions/${region}.ts"
    echo "Done."
    echo " "
}

function createStage {
    if [ ! -d "$workdir/src/stages/$ou" ]; then
        echo "Generating index for OU $ou at"
        echo "$workdir/src/stages/$ou..."

        mkdir "$workdir/src/stages/$ou"
        eval "cat <<-EOF
$(<$home/templates/ou.template)
EOF" > "$workdir/src/stages/$ou/index.ts"

        echo "Done."
        echo " "
    fi

    if [ ! -d "$workdir/src/stages/$ou/$account" ]; then
        echo "Generating index for account $account at "
        echo "$workdir/src/stages/$ou/$account..."

        mkdir "$workdir/src/stages/$ou/$account"
        eval "cat <<-EOF
$(<$home/templates/account.template)
EOF" > "$workdir/src/stages/$ou/$account/index.ts"

        echo "Done."
        echo " "
    fi

    if [ ! -d "$workdir/src/stages/$ou/$account/$region" ]; then
        echo "Generating index for region $region at "
        echo "$workdir/src/stages/$ou/$account/$region..."

        mkdir "$workdir/src/stages/$ou/$account/$region"
        eval "cat <<-EOF
$(<$home/templates/region.template)
EOF" > "$workdir/src/stages/$ou/$account/$region/index.ts"

        echo "Done."
        echo " " 
    fi

    if [ ! -f "$workdir/src/configuration/regions/${region}.ts" ]; then
        createRegionConfigFile
    fi
}

function createRegionConfigIndex {
    echo "Generating index file for $workdir/src/configuration/regions..."
    declare -a imports=()
    declare -a configs=()
    
    for region in ${regions[@]}; do
        regionname=$(echo $region | sed -r 's/^(.)|-(.)/\U\1\U\2/g' )
        importstatement="import { config as ${regionname}Config } from \"./$region\";"
        imports+=("$importstatement")
        config="['$region']: ${regionname}Config,"
        configs+=("$config")
    done

    eval "cat <<-EOF
$(<$home/templates/region-index.template)
EOF" > "$workdir/src/configuration/regions/index.ts"
    echo "Done."
    echo " "
}

function generateStages {
    all_regions=()

    echo "Creating stages based on configuration from"
    echo "$config:"
    echo " "
    stages=$(jq .[] $config)
    echo "$stages"
    echo " "

    for ou in $(echo $stages | jq keys[] --raw-output); do
        for account in $(jq .[].$ou $config | jq keys[] --raw-output); do
            for region in $(jq .[].$ou.$account $config | jq .[] --raw-output); do
                regionname=$(echo $region | sed -r 's/^(.)|-(.)/\U\1\U\2/g' )
                all_regions+=($region)
                createStage
            done
        done
    done
    
    regions=$(printf "%s\n" "${all_regions[@]}" | sort -u | tr '\n' ' ')
    createRegionConfigIndex
}

function runInstall {
    echo "Installing libraries..."
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

echo " "
echo "Project $name is ready!"

