#!/bin/bash

# Azure DevOps details
organization="<ADO_ORGANIZATION_NAME>"
pat="<ADO_PAT_HERE>" # Personal Access Token with the required permissions
project_name="<ADO_PROJECT_NAME>"

# Repositories to delete
repos_to_delete=("ARRAY" "OF" "VALUES")
accessToken=$(az account get-access-token --scope "499b84ac-1321-427f-aa17-267ca6975798/.default" --query accessToken -o tsv)



# Function to delete a repository in a given project
delete_repository() {
  repo_name=$1

  echo "Looking up repository id: $repo_name from project: $project_name"
  # authHeader="Authorization: Bearer $pat"
  authHeader="Authorization: Bearer $accessToken"
  getReposUrl="https://dev.azure.com/$organization/_apis/git/repositories?api-version=7.0"
  response=$(curl -s "$getReposUrl"  -H "Content-Type: application/json" -H "$authHeader")

  # # Debugging: Print out the response for inspection
  # echo "API Response:"
  # echo "$response"

  targetRepoId=$(echo "$response" | jq -r --arg name "$repo_name" '.value[] | select(.name == $name).id')

  # More debugging: Print out the targetRepoId
  echo "Repository ID: $targetRepoId"

  echo "Attempting to delete repository: $repo_name from project: $project_name"

  # Construct the API URL for the repository
  api_url="https://dev.azure.com/$organization/$encodedProjectName/_apis/git/repositories/$targetRepoId?api-version=7.0"

  # Make the API call to delete the repository
  delete_response=$(curl -s -w "%{http_code}" -o /dev/null -X DELETE -H "$authHeader" "$api_url")

  # Debugging: Print the response code
  echo "Delete Response Code: $delete_response"

  if [ "$delete_response" -eq 204 ]; then
    echo "Repository '$repo_name' deleted successfully from project $project_name."
  else
    echo "Failed to delete $repo_name from project $project_name. HTTP response code: $delete_response."
  fi
}

# Loop through each project and delete specified repositories
for repo in "${repos_to_delete[@]}"; do
  delete_repository "$repo"
done
