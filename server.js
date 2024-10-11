const express = require('express');
const axios = require('axios');
const cors = require('cors'); // Import cors
const bodyParser = require('body-parser');

const app = express();
const port = process.env.PORT || 3000;
app.use(cors());  // Enable CORS for all origins

app.use(bodyParser.json());

const GITHUB_TOKEN = process.env.INPUT_TOKEN; // Replace with your GitHub Personal Access Token
const REPO_OWNER = 'mariannunez'; // Replace with your GitHub username
const REPO_NAME = 'test_execution_menu'; // Replace with your repository name
const WORKFLOW_ID = 'allure-report.yml'; // Replace with the name of your workflow file
const GITHUB_API_URL = `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/workflows/${WORKFLOW_ID}/dispatches`;

app.post('/trigger-action', async (req, res) => {
  try {
    const response = await axios.post(
      GITHUB_API_URL,
      {
        ref: 'main', // Or specify the branch you want to trigger the action on
        inputs: req.body.inputs || {}, // Optional: pass inputs to the GitHub Action
      },
      {
        headers: {
          'Authorization': `Bearer ${GITHUB_TOKEN}`,
          'Accept': 'application/vnd.github.v3+json',
        },
      }
    );

    res.status(200).json({ message: 'GitHub Action triggered successfully', response: response.data });
  } catch (error) {
    console.error('Error triggering GitHub Action:', error);
    res.status(500).json({ message: 'Failed to trigger GitHub Action', error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
