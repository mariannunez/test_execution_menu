#! /usr/bin/env bash

unset JAVA_HOME

mkdir -p ./${INPUT_GH_PAGES}
mkdir -p ./${INPUT_ALLURE_HISTORY}
cp -r ./${INPUT_GH_PAGES}/. ./${INPUT_ALLURE_HISTORY}
GITHUB_TOKEN=${INPUT_TOKEN}

REPOSITORY_OWNER_SLASH_NAME=${INPUT_GITHUB_REPO}
REPOSITORY_NAME=${REPOSITORY_OWNER_SLASH_NAME##*/}
GITHUB_PAGES_WEBSITE_URL="https://${INPUT_GITHUB_REPO_OWNER}.github.io/${REPOSITORY_NAME}"
#echo "Github pages url $GITHUB_PAGES_WEBSITE_URL"

if [[ ${INPUT_SUBFOLDER} != '' ]]; then
    INPUT_ALLURE_HISTORY="${INPUT_ALLURE_HISTORY}/${INPUT_SUBFOLDER}"
    INPUT_GH_PAGES="${INPUT_GH_PAGES}/${INPUT_SUBFOLDER}"
    echo "NEW allure history folder ${INPUT_ALLURE_HISTORY}"
    mkdir -p ./${INPUT_ALLURE_HISTORY}
    GITHUB_PAGES_WEBSITE_URL="${GITHUB_PAGES_WEBSITE_URL}/${INPUT_SUBFOLDER}"
    echo "NEW github pages url ${GITHUB_PAGES_WEBSITE_URL}"
fi

if [[ ${INPUT_REPORT_URL} != '' ]]; then
    GITHUB_PAGES_WEBSITE_URL="${INPUT_REPORT_URL}"
    echo "Replacing github pages url with user input. NEW url ${GITHUB_PAGES_WEBSITE_URL}"
fi

COUNT=$( ( ls ./${INPUT_ALLURE_HISTORY} | wc -l ) )
echo "count folders in allure-history: ${COUNT}"
echo "keep reports count ${INPUT_KEEP_REPORTS}"
INPUT_KEEP_REPORTS=$((INPUT_KEEP_REPORTS+1))
echo "if ${COUNT} > ${INPUT_KEEP_REPORTS}"
if (( COUNT > INPUT_KEEP_REPORTS )); then
  cd ./${INPUT_ALLURE_HISTORY}
  echo "remove index.html last-history"
  rm index.html last-history -rv
  echo "remove old reports"
  ls | sort -n | grep -v 'CNAME' | head -n -$((${INPUT_KEEP_REPORTS}-2)) | xargs rm -rv;
  cd ${GITHUB_WORKSPACE}
fi

echo "<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Checkbox Generator</title>
  <script type="module">
    import { suites } from './suites.js';

    window.onload = () => {
      const container = document.getElementById('checkbox-container');

      Object.keys(suites).forEach(suite => {
        const suiteTitle = document.createElement('h3');
        suiteTitle.textContent = suite;
        container.appendChild(suiteTitle);

        suites[suite].forEach(spec => {
          const label = document.createElement('label');
          const checkbox = document.createElement('input');
          checkbox.type = 'checkbox';
          checkbox.value = spec;

          label.appendChild(checkbox);
          label.appendChild(document.createTextNode(spec));
          container.appendChild(label);
          container.appendChild(document.createElement('br'));
        });
      });
    };
  </script>
</head>
<body>
  <div id="checkbox-container"></div>
  
  <button id="trigger-action-btn">Trigger GitHub Action</button>

    <script>
        document.getElementById('trigger-action-btn').addEventListener('click', function() {
            const repoOwner = 'mariannunez';  // Replace with your GitHub username
            const repoName = 'test_execution_menu';  // Replace with your GitHub repository name
            const workflowId = 'allure-report.yml';  // Replace with your workflow file name (e.g., "action.yml")
            const githubToken = ${GITHUB_TOKEN};  // Replace with your GitHub Personal Access Token

            const url = 'https://api.github.com/repos/${repoOwner}/${repoName}/actions/workflows/${workflowId}/dispatches';
            const data = {
                ref: 'main'  // Or the branch you want to trigger the action on
            };

            fetch(url, {
                method: 'POST',
                headers: {
                    'Authorization': 'Bearer ${GITHUB_TOKEN}',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            })
            .then(response => {
                if (response.ok) {
                    alert('GitHub Action triggered successfully!');
                } else {
                    alert('Failed to trigger GitHub Action.');
                }
            })
            .catch(error => {
                console.error('Error triggering GitHub Action:', error);
                alert('An error occurred.');
            });
        });
    </script>
</body>
" > ./${INPUT_ALLURE_HISTORY}/index.html # path

#echo "executor.json"
echo '{"name":"GitHub Actions","type":"github","reportName":"Allure Report with history",' > executor.json
echo "\"url\":\"${GITHUB_PAGES_WEBSITE_URL}\"," >> executor.json # ???
echo "\"reportUrl\":\"${GITHUB_PAGES_WEBSITE_URL}/${INPUT_GITHUB_RUN_NUM}/\"," >> executor.json
echo "\"buildUrl\":\"${INPUT_GITHUB_SERVER_URL}/${INPUT_GITHUB_REPO}/actions/runs/${INPUT_GITHUB_RUN_ID}\"," >> executor.json
echo "\"buildName\":\"GitHub Actions Run #${INPUT_GITHUB_RUN_ID}\",\"buildOrder\":\"${INPUT_GITHUB_RUN_NUM}\"}" >> executor.json
#cat executor.json
mv ./executor.json ./${INPUT_ALLURE_RESULTS}

#environment.properties
# echo "URL=${GITHUB_PAGES_WEBSITE_URL}" >> ./${INPUT_ALLURE_RESULTS}/environment.properties

echo "Copy path files from Suites files"
cp -r ./suites.js ./${INPUT_ALLURE_HISTORY}/suites.js

echo "keep allure history from ${INPUT_GH_PAGES}/last-history to ${INPUT_ALLURE_RESULTS}/history"
cp -r ./${INPUT_GH_PAGES}/last-history/. ./${INPUT_ALLURE_RESULTS}/history

echo "generating report from ${INPUT_ALLURE_RESULTS} to ${INPUT_ALLURE_REPORT} ..."
#ls -l ${INPUT_ALLURE_RESULTS}
allure generate --clean ${INPUT_ALLURE_RESULTS} -o ${INPUT_ALLURE_REPORT}
#echo "listing report directory ..."
#ls -l ${INPUT_ALLURE_REPORT}

echo "copy allure-report to ${INPUT_ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}"
cp -r ./${INPUT_ALLURE_REPORT}/. ./${INPUT_ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}
echo "copy allure-report history to /${INPUT_ALLURE_HISTORY}/last-history"
cp -r ./${INPUT_ALLURE_REPORT}/history/. ./${INPUT_ALLURE_HISTORY}/last-history
