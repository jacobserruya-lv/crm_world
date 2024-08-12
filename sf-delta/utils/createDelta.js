const fs = require('fs');
const path = require('path');
const { getModifiedFiles } = require('./getModifiedFiles');

/*
 * Mapping of file extensions to exclude Salesforce component types.
 * This array is exported to an external file 
 */
/*const excludeMetadata = [
  '/customMetadata', // customMetadata
  '/labels', // Custom Label
  '/callCenters', // Callcenter
  '/authproviders', // AuthProvider
  '/namedCredentials', // NamedCredentials
  '/connectedApps', // connectedApp
  '/cspTrustedSites', // cspTrustedSites
  '/certs', // Certificate
  '/profiles' // profile
];*/




const metadataIgnoreFile = path.join(__dirname, '../metadataIgnore.txt');
let excludeMetadata = [];

try {
  if (fs.existsSync(metadataIgnoreFile)) {
    const data = fs.readFileSync(metadataIgnoreFile, 'utf8');
    excludeMetadata = data.trim().split('\n').map(line => line.trim()).filter(line => line !== '');
  } else {
    console.error(`metadataIgnore.txt does not exist at ${metadataIgnoreFile}`);
  }
} catch (err) {
  console.error(`Error reading metadataIgnore.txt: ${err}`);
}

/**
 * Copies modified files to a delta directory, preserving the directory structure.
 * @param {string[]} modifiedFiles - List of modified files with their paths.
 * @param {string} projectPath - The base project path.
 */
const createDelta = (projectPath, baseBranch) => {
  const deltaPath = 'delta/main/default'; // Folder to deploy to targeted SF ORG
  let modifiedFiles = getModifiedFiles(baseBranch);

  console.log(`=== GENERATING DELTA PROJECT FOLDER ===`);
  console.log(`from : ` + projectPath); 

  // Filter out -meta.xml files from the staticresources path
  modifiedFiles = modifiedFiles.filter(file => {
    return !(file.includes('/staticresources/') && file.endsWith('-meta.xml'));
  });

  modifiedFiles.forEach((file) => {
    if (!file.startsWith(projectPath)) return;

    // Check if the file name contains any value from excludeMetadata
    if (excludeMetadata.some((meta) => file.includes(meta))){
      console.log('ignored file : ');
      console.log(file);
      return;
    } 

    const sourceFile = file;
    const destFile = path.join(deltaPath, file.replace(projectPath, ''));
    const destDir = path.dirname(destFile);

    createDirectory(destDir);

    // Source files
    copyFile(sourceFile, destFile);

    // Meta from source files
    if (!sourceFile.endsWith('-meta.xml')) {
      copyMetaFile(sourceFile, destFile);
    }

    // Meta from special component source files
    if (file.includes('/objectTranslations/') || file.includes('/aura/') || file.includes('/lwc/')) {
      const bundlePath = path.dirname(file);
      copyDirectory(bundlePath, path.dirname(destFile));
    }
    if (file.includes('/staticresources/')) {
      copyStaticResourceMetaFile(file, projectPath, deltaPath);
    }

    // Handle paired metadata files
    addPairedFiles(file, projectPath, deltaPath);
  });
};

/**
 * Creates a directory if it does not exist.
 * @param {string} dir - The directory path.
 */
const createDirectory = (dir) => {
  fs.mkdirSync(dir, { recursive: true });
};

/**
 * Copies a file from source to destination.
 * @param {string} sourceFile - The source file path.
 * @param {string} destFile - The destination file path.
 */
const copyFile = (sourceFile, destFile) => {
  if (fs.existsSync(sourceFile)) {
    fs.copyFileSync(sourceFile, destFile);
  }
};

/**
 * Copies the meta file associated with a source file.
 * @param {string} sourceFile - The source file path.
 * @param {string} destFile - The destination file path.
 */
const copyMetaFile = (sourceFile, destFile) => {
  const metaFile = `${sourceFile}-meta.xml`;
  if (fs.existsSync(metaFile)) {
    const destMetaFile = `${destFile}-meta.xml`;
    fs.copyFileSync(metaFile, destMetaFile);
  }
};

/**
 * Copies the static resource meta file if it exists. If the resource is a directory, copies the entire directory.
 * @param {string} file - The static resource file path.
 * @param {string} projectPath - The base project path.
 * @param {string} deltaPath - The delta directory path.
 */
const copyStaticResourceMetaFile = (file, projectPath, deltaPath) => {
  const pathParts = file.split('/');
  const resourceFolder = pathParts[pathParts.indexOf('staticresources') + 1];
  const sourceResourcePath = path.join(projectPath, 'staticresources', resourceFolder);
  const destResourcePath = path.join(deltaPath, 'staticresources', resourceFolder);
  const resourceMetaFile = `${sourceResourcePath}.resource-meta.xml`;

  if (fs.existsSync(sourceResourcePath)) {
    if (fs.lstatSync(sourceResourcePath).isDirectory()) {
      copyDirectory(sourceResourcePath, destResourcePath);
    } else {
      copyFile(sourceResourcePath, destResourcePath);
    }

    if (fs.existsSync(resourceMetaFile)) {
      const destMetaFile = `${destResourcePath}.resource-meta.xml`;
      fs.copyFileSync(resourceMetaFile, destMetaFile);
    }
  }
};

/**
 * Recursively copies a directory from source to destination.
 * @param {string} sourceDir - The source directory path.
 * @param {string} destDir - The destination directory path.
 */
const copyDirectory = (sourceDir, destDir) => {
  createDirectory(destDir);
  const entries = fs.readdirSync(sourceDir, { withFileTypes: true });

  entries.forEach((entry) => {
    const sourcePath = path.join(sourceDir, entry.name);
    const destPath = path.join(destDir, entry.name);

    if (entry.isDirectory()) {
      copyDirectory(sourcePath, destPath);
    } else {
      copyFile(sourcePath, destPath);
    }
  });
};

/**
 * Adds paired metadata files to the delta directory if they exist.
 * @param {string} file - The original file path.
 * @param {string} projectPath - The base project path.
 * @param {string} deltaPath - The delta directory path.
 */
const addPairedFiles = (file, projectPath, deltaPath) => {
  const fileTypes = ['.page', '.cls', '.component', '.trigger'];
  fileTypes.forEach((fileType) => {
    if (file.endsWith(`${fileType}-meta.xml`)) {
      const pairedFile = file.replace('-meta.xml', '');
      const destPairedFile = path.join(deltaPath, pairedFile.replace(projectPath, ''));
      copyFile(pairedFile, destPairedFile);
    } else if (file.endsWith(fileType)) {
      const pairedMetaFile = `${file}-meta.xml`;
      const destPairedMetaFile = path.join(deltaPath, pairedMetaFile.replace(projectPath, ''));
      copyFile(pairedMetaFile, destPairedMetaFile);
    }
  });
};

module.exports = { createDelta };
