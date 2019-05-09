#!/bin/bash

set -e

if [ "$1" = 'deploy' ]; then

    if [ -d "$BAKLAVA_CONFIG" ]; then

        echo "Starting the deployment."

        export DEPLOY_FOLDER=$BAKLAVA_HOME/deployment/cluster$(ls /baklava/deployment/ | wc -l)

        echo "Deployment folder: "$DEPLOY_FOLDER
        mkdir -p $DEPLOY_FOLDER && cd $DEPLOY_FOLDER

        # generate the ssh-key
        echo "Generating the ssh-key."
        ssh-keygen -b 4096 -t rsa -f id_rsa_baklava -q -P ""
        cp $DEPLOY_FOLDER/id_rsa_baklava /baklava/id_rsa_baklava
        cp $DEPLOY_FOLDER/id_rsa_baklava.pub /baklava/id_rsa_baklava.pub

        cp -iR $BAKLAVA_CONFIG $DEPLOY_FOLDER/
        cd $DEPLOY_FOLDER/config
        terraform init && \
            terraform validate -var DEPLOY_FOLDER=$DEPLOY_FOLDER && \
            terraform apply -var DEPLOY_FOLDER=$DEPLOY_FOLDER

    else

        echo "Couldn't find the config files. Exiting."

    fi

else

    echo "Running $@"
    exec "$@"

fi
