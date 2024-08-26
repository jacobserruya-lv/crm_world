const { execSync } = require('child_process');

const getModifiedFiles = (projectPath, baseBranch) => {
  const output = execSync(`git diff --name-only origin/${baseBranch} -- ${projectPath}`).toString();
  return output.split('\n').filter(file => file.trim() !== '');
};

module.exports = { getModifiedFiles };
