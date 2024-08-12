const fs = require('fs');
const path = require('path');
const xml2js = require('xml2js');

const { getComponentDetails } = require('./getComponentDetails');

/**
 * Reads and parses the existing package.xml file if it exists.
 * @param {string} packageXmlPath - The path to the package.xml file.
 * @returns {Promise<Object>} The parsed XML object or an empty object if the file does not exist.
 */
const readExistingPackageXml = async (packageXmlPath) => {
  if (fs.existsSync(packageXmlPath)) {
    const packageXmlContent = fs.readFileSync(packageXmlPath, 'utf-8');
    const parsedXml = await xml2js.parseStringPromise(packageXmlContent);
    return parsedXml.Package || {};
  }
  return {};
};


/**
 * Recursively gets all file paths in a directory.
 * @param {string} dir - The directory to search.
 * @param {string[]} fileList - The list of file paths (used for recursion).
 * @returns {string[]} The list of file paths.
 */
const getAllFilePaths = (dir, fileList = []) => {
  const files = fs.readdirSync(dir);
  files.forEach(file => {
    const filePath = path.join(dir, file);
    if (fs.statSync(filePath).isDirectory()) {
      getAllFilePaths(filePath, fileList);
    } else {
      fileList.push(filePath);
    }
  });
  return fileList;
};



/**
 * Creates a package.xml file based on the modified files and their component details.
 * @param {string} apiVersion - The Salesforce API version to use.
 */
const createPackageXml = async (apiVersion) => {

  const deltaPath = 'delta/main/default';

  // Check if deltaPath exists
  if (!fs.existsSync(deltaPath)) {
    console.log(`Directory ${deltaPath} does not exist. Skipping package.xml generation.`);
    return;
  }
  
  const packageXmlPath = path.join(deltaPath, 'package.xml');
  const existingPackage = await readExistingPackageXml(packageXmlPath);

  const components = extractComponents(existingPackage);
  const modifiedFiles = getAllFilePaths(deltaPath);

  //console.log('Delta Files :');
  //console.log(modifiedFiles);
  await updateComponentsWithFiles(modifiedFiles, deltaPath, components);

  // Check if components is empty before building package XML
  if (Object.keys(components).length === 0) {
    console.log('No components found. Skipping package.xml generation.');
    return;
  }
  
  const packageXml = buildPackageXml(components, apiVersion);
  savePackageXml(packageXmlPath, packageXml);
  fs.readFile(packageXmlPath, 'utf8', (err, data) => {
    if (err) {
      console.error(err);
      return;
    }
  });
  
};

/**
 * Extracts components from the existing package XML structure.
 * @param {Object} existingPackage - The existing package XML object.
 * @returns {Object} The components object.
 */
const extractComponents = (existingPackage) => {
  return existingPackage.types ? existingPackage.types.reduce((acc, type) => {
    acc[type.name[0]] = type.members;
    return acc;
  }, {}) : {};
};

/**
 * Updates the components object with details from modified files.
 * @param {string[]} modifiedFiles - List of modified files.
 * @param {string} deltaPath - to deploy project path.
 * @param {Object} components - The components object to update.
 */
const updateComponentsWithFiles = async (modifiedFiles, deltaPath, components) => {
  for (const file of modifiedFiles) {
    if (!file.startsWith(deltaPath)) continue;

    const { componentType, componentName } = await getComponentDetails(file);
    if (componentType && componentName) {
      if (!components[componentType]) components[componentType] = [];
      if (!components[componentType].includes(componentName)) components[componentType].push(componentName);
    }
  }
};

/**
 * Builds the package XML structure.
 * @param {Object} components - The components object.
 * @param {string} apiVersion - The Salesforce API version to use.
 * @returns {Object} The package XML structure.
 */
const buildPackageXml = (components, apiVersion) => {
  return {
    Package: {
      $: { xmlns: 'http://soap.sforce.com/2006/04/metadata' },
      types: Object.keys(components).map(type => ({
        members: components[type],
        name: type
      })),
      version: [apiVersion]
    }
  };
};

/**
 * Saves the package XML to a file.
 * @param {string} packageXmlPath - The path to save the package.xml file.
 * @param {Object} packageXml - The package XML structure.
 */
const savePackageXml = (packageXmlPath, packageXml) => {
  const builder = new xml2js.Builder();
  const xml = builder.buildObject(packageXml);

  fs.mkdirSync(path.dirname(packageXmlPath), { recursive: true });
  fs.writeFileSync(packageXmlPath, xml);
};

module.exports = { createPackageXml };
