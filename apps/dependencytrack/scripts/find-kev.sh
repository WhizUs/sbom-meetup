#!/bin/bash
# use this script to find CISA known exploited vulnerabilities
# source: https://docs.dependencytrack.org/usage/community-usage-examples/

api_base_url=$(op run --env-file op.env -- printenv DTRACK_API_BASE_URL)
api_key=$(op run --env-file op.env -- printenv DTRACK_API_KEY)

urlCISA='https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json'
catalog=$(curl -s -X GET "$urlCISA" | jq '.vulnerabilities')


echo $catalog | jq -c 'to_entries[]' | while read -r vulnerability; do
    cve_id=$(echo "$vulnerability" | jq -r '.value.cveID')
    uri="$api_base_url/api/v1/vulnerability/source/NVD/vuln/$cve_id/projects"
    response=$(curl -s -X GET -H "Content-Type: application/json" -H "X-Api-Key: $api_key" "$uri")

    if [ ! "$response" == [] ]; then
        affected_projects=$(echo "$response" | jq -c '.[]')
        project_name=$(echo "$affected_projects" | jq -r '.name')
        project_version=$(echo "$affected_projects" | jq -r '.version')
        project_uuid=$(echo "$affected_projects" | jq -r '.uuid')
        echo "$cve_id: $project_name v.$project_version UUID: $project_uuid"
    fi

done
