#!/usr/bin/env bash

# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

configure_aws_cli(){
	aws --version
	aws configure set default.region ap-southeast-1
	aws configure set default.output json
}

push_ecr_image(){
    # docker tag go-sample-webapp 012881927014.dkr.ecr.ap-southeast-1.amazonaws.com/go-sample-webapp
	eval $(aws ecr get-login --region ap-southeast-1)
	docker push 012881927014.dkr.ecr.ap-southeast-1.amazonaws.com/go-sample-webapp
}

make_task_def(){
	task_template='[
		{
			"name": "go-sample-webapp",
			"image": "012881927014.dkr.ecr.ap-southeast-1.amazonaws.com/go-sample-webapp",
			"essential": true,
			"memory": 200,
			"cpu": 10,
			"portMappings": [
				{
					"containerPort": 8080,
					"hostPort": 80
				}
			]
		}
	]'

	task_def="$task_template"
}

register_definition() {

    if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family "circleci"); then
        echo "Revision: $revision"
    else
        echo "Failed to register task definitions"
        return 1
    fi
}

run_task(){
    if run = $(aws ecs run-task --cluster circleci --task-definition "$task_def"); then
    	echo $run
    else 
  	echo "Failed"
	return 1
    fi
}

# deploy_cluster() {

#     family="sample-webapp-task-family"

#     make_task_def
#     register_definition
#     if [[ $(aws ecs update-service --cluster sample-webapp-cluster --service sample-webapp-service --task-definition $revision | \
#                    $JQ '.service.taskDefinition') != $revision ]]; then
#         echo "Error updating service."
#         return 1
#     fi

#     # wait for older revisions to disappear
#     # not really necessary, but nice for demos
#     for attempt in {1..30}; do
#         if stale=$(aws ecs describe-services --cluster sample-webapp-cluster --services sample-webapp-service | \
#                        $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
#             echo "Waiting for stale deployments:"
#             echo "$stale"
#             sleep 5
#         else
#             echo "Deployed!"
#             return 0
#         fi
#     done
#     echo "Service update took too long."
#     return 1
# }



configure_aws_cli
push_ecr_image
# deploy_cluster
make_task_def
register_definition
run_task
