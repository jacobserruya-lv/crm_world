/**
    Author: Avinash Yoganandan VO2-FRANCE
    Created for: CICD SF
    Create date: June 2024
    Description: Create dynamically a delta folder with all diff Metadata between 2 git branch & Package.xml
*/

const yargs = require('yargs');
const { createPackageXml } = require('./utils/createPackageXml');
const { createDelta } = require('./utils/createDelta');
const deltaFolder = 'delta/main/default';

// Command-line argument parsing
const argv = yargs
  .option('projectPath', {
    alias: 'p',
    description: 'Path to the Salesforce project',
    type: 'string',
    default: 'sfoa',
    demandOption: true
  })
  .option('baseBranch', {
    alias: 'b',
    description: 'Base branch to compare changes against',
    type: 'string',
    demandOption: true
  })
  .option('apiVersion', {
    alias: 'v',
    description: 'Salesforce API version',
    type: 'string',
    default: '60.0'
  })
  .help()
  .alias('help', 'h')
  .argv;

createDelta(argv.projectPath + '/main/default', argv.baseBranch);
createPackageXml(argv.apiVersion);

