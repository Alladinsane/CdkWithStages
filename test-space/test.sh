function generateStages {
    all_regions=()
    config="../config/example.json"
    
    stages=$(jq .[] $config)
    for ou in $(echo $stages | jq keys[] --raw-output); do
        echo $ou
        for account in $(jq .[].$ou $config | jq keys[] --raw-output); do
            echo $account
            for region in $(jq .[].$ou.$account $config | jq .[] --raw-output); do
                echo $region
                regionname=$(echo $region | sed -r 's/^(.)|-(.)/\U\1\U\2/g' )
                echo $regionname
            done
        done
    done
    # readarray -d / -t namespace <<< "$STRING"
    # ou=${namespace[0]}
    # account=${namespace[1]}
    # region=$(echo ${namespace[2]} | tr -d '\n')
    # regionname=$(echo $region | sed -r 's/^(.)|-(.)/\U\1\U\2/g' )
    # createStage
    # declare -A regionObj
    
    # all_regions+=($region)
    
    # regions=$(printf "%s\n" "${all_regions[@]}" | sort -u | tr '\n' ' ')
    # createRegionConfigs
}
generateStages