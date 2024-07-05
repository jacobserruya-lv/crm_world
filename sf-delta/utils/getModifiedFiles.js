const { execSync } = require('child_process');

const getModifiedFiles = (baseBranch) => {
  const output = execSync(`git diff --name-only origin/${baseBranch}..HEAD`).toString();
  return output.split('\n').filter(file => file.trim() !== '');
};

module.exports = { getModifiedFiles };