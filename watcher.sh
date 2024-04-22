#!/bin/bash

readonly NAMESPACE="sre"
readonly DEPLOYMENT="swype-app"
readonly MAX_RESTARTS=3
readonly SLEEP_BY=60

logger() {
    echo $(date '+%Y-%m-%d %H:%M:%S')" - "$1
}

get_pod_restarts() {
    kubectl get pods --selector app==$DEPLOYMENT --namespace $NAMESPACE | awk 'NR>1{print $4}'
}

scale_down_deployment() {
    kubectl scale --replicas=0 deployment/$DEPLOYMENT --namespace $NAMESPACE
}

main() {
    while true
    do
        restart_count=$(get_pod_restarts)

        logger "Restart count=$restart_count"
        
        if [[ $restart_count > $MAX_RESTARTS ]]
        then
            logger "$DEPLOYMENT restart count exceeded the limit of $MAX_RESTARTS restarts. Scalling down the deployment to 0"
            scale_down_deployment
            break
        else
            logger "$DEPLOYMENT restart count under the limit of $MAX_RESTARTS restarts. Waiting $SLEEP_BY seconds for the next check"
            sleep $SLEEP_BY
        fi
    done
}

main