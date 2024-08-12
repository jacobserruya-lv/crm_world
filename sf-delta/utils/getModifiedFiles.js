const { execSync } = require('child_process');

  const getModifiedFiles = (baseBranch) => {
  const  output = execSync(`git diff --name-only origin/${baseBranch}`).toString();    // Diff with the actual version 
  return output.split('\n').filter(file => file.trim() !== '');
};

module.exports = { getModifiedFiles };