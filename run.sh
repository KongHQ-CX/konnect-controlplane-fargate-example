#!/bin/bash

echo "> We are in Konnect Region: '${KONNECT_REGION}'"

export KPAT=$(aws secretsmanager get-secret-value --secret-id ${KONNECT_PAT_SECRET_ARN} --output text --query 'SecretString')

# load array into a bash array
# output each entry as a single line json
readarray CONTROL_PLANES < <(yq -o=j -I=0 '.control_planes[]' control-planes.yaml )

if [ "$MODE" == "plan" ]
then
  echo -e "**SUMMARY OF CHANGES**\n\n\`\`\`yaml\n" > out.txt
  echo "control_planes: []" > control_planes_konnect.yaml

  for CONTROL_PLANE in "${CONTROL_PLANES[@]}";
  do
    # identity mapping is a single json snippet representing a single entry
    export name=$(echo "$CONTROL_PLANE" | yq '.name' -)

    echo ""
    echo "> Looking up control-plane: $name"
    export AUTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --request GET \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer ${KPAT}" \
      --url "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes?filter%5Bname%5D%5Beq%5D=${name}")

    if [[ "$AUTH_STATUS" == 401 ]]
    then
      echo "!! Konnect PAT token is invalid, missing, or expired"
      exit 1
    fi

    export FOUND_STATUS=$(curl -s --request GET \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer ${KPAT}" \
      --url "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes?filter%5Bname%5D%5Beq%5D=${name}" | yq -P e '.meta.page.total')

    if [[ "$FOUND_STATUS" < 1 ]]
    then
      echo "> Control Plane $name does not exist - would create it..."

      echo "-> Create: Konnect control-plane: '$name'" >> out.txt

      echo "> Pre-decorating Git object with Konnect object for this control plane"
      export CONTROL_PLANE_ID="not_yet_known"
      export CLUSTER_ENDPOINT="not_yet_known"
      export TELEMETRY_ENDPOINT="not_yet_known"
      yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .id = strenv(CONTROL_PLANE_ID)' control-planes.yaml
      yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .cluster_endpoint = strenv(CLUSTER_ENDPOINT)' control-planes.yaml
      yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .telemetry_endpoint = strenv(TELEMETRY_ENDPOINT)' control-planes.yaml

    else
      echo "> Reading back new control plane info for Terraform"
      curl -s --request GET \
        --header 'Accept: application/json' \
        --header "Authorization: Bearer ${KPAT}" \
        --url "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes?filter%5Bname%5D%5Beq%5D=${name}" |
        yq -P '.data[0]' > current.yaml
      
      echo "> Decorating Git object with Konnect object for this control plane"
      export CONTROL_PLANE_ID=$(cat current.yaml | yq '.id' -)
      export CLUSTER_ENDPOINT=$(cat current.yaml | yq '.config.control_plane_endpoint' -)
      export TELEMETRY_ENDPOINT=$(cat current.yaml | yq '.config.telemetry_endpoint' -)
      yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .id = strenv(CONTROL_PLANE_ID)' control-planes.yaml
      yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .cluster_endpoint = strenv(CLUSTER_ENDPOINT)' control-planes.yaml
      yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .telemetry_endpoint = strenv(TELEMETRY_ENDPOINT)' control-planes.yaml
    fi

    sleep 1
  done

  echo -e "\`\`\`\n\n**TERRAFORM PLAN**\n\`\`\`" >> out.txt
  terraform init -upgrade
  terraform plan -var "konnect_pat=${KPAT}" -no-color >> out.txt

  echo "\`\`\`" >> out.txt
fi

if [ "$MODE" == "apply" ]
then
  echo "control_planes: []" > control_planes_konnect.yaml

  for CONTROL_PLANE in "${CONTROL_PLANES[@]}";
  do
    # identity mapping is a single json snippet representing a single entry
    export name=$(echo "$CONTROL_PLANE" | yq '.name' -)
    export desc=$(echo "$CONTROL_PLANE" | yq '.description' -)
    export aws_account=$(echo "$CONTROL_PLANE" | yq '.aws_account' -)
    export ecs_cluster=$(echo "$CONTROL_PLANE" | yq '.ecs_cluster' -)

    echo ""
    echo "> Looking up control-plane: $name"
    export AUTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --request GET \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer ${KPAT}" \
      --url "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes?filter%5Bname%5D%5Beq%5D=${name}")

    if [[ "$AUTH_STATUS" == 401 ]]
    then
      echo "!! Konnect PAT token is invalid, missing, or expired"
      exit 1
    fi

    export FOUND_STATUS=$(curl -s --request GET \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer ${KPAT}" \
      --url "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes?filter%5Bname%5D%5Beq%5D=${name}" | yq -P e '.meta.page.total')

    if [[ "$FOUND_STATUS" < 1 ]]
    then
      echo "> Control Plane $name does not exist - creating it..."

      cat <<EOF > control_plane.json
{
  "name": "$name",
  "description": "$description",
  "cluster_type": "CLUSTER_TYPE_HYBRID",
  "labels": {
    "aws_region": "$AWS_REGION",
    "aws_account": "$(aws sts get-caller-identity --output text --query "Account")",
    "ecs_cluster": "$ecs_cluster"
  }
}
EOF

      export CREATED_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --request POST \
        --header 'Accept: application/json' \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer ${KPAT}" \
        --url "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes" \
        -d @control_plane.json)

      if [[ "$CREATED_STATUS" != 201 ]]
      then
        echo "!! Control Plane creation failed, status: $CREATED_STATUS"
        exit 1
      fi
    fi

    sleep 1

    echo "> Reading back new control plane info for Terraform"
    curl -s --request GET \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer ${KPAT}" \
      --url "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes?filter%5Bname%5D%5Beq%5D=${name}" |
      yq -P '.data[0]' > current.yaml
    
    echo "> Decorating Git object with Konnect object for this control plane"
    export CONTROL_PLANE_ID=$(cat current.yaml | yq '.id' -)
    export CLUSTER_ENDPOINT=$(cat current.yaml | yq '.config.control_plane_endpoint' -)
    export TELEMETRY_ENDPOINT=$(cat current.yaml | yq '.config.telemetry_endpoint' -)
    yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .id = strenv(CONTROL_PLANE_ID)' control-planes.yaml
    yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .cluster_endpoint = strenv(CLUSTER_ENDPOINT)' control-planes.yaml
    yq e -i '.control_planes[] |= select(.name == strenv(name)) |= .telemetry_endpoint = strenv(TELEMETRY_ENDPOINT)' control-planes.yaml
    
  done

  terraform init -upgrade
  terraform apply -var "konnect_pat=${KPAT}" --auto-approve
fi
