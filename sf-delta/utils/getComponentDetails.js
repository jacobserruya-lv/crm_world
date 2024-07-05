const fs = require('fs');
const path = require('path');
const xml2js = require('xml2js');

/**
 * Retrieves the component type and name based on file path and extension.
 * @param {string} file - The file path.
 * @returns {Promise<{componentType: string, componentName: string}>} The component details.
 */
const getComponentDetails = async (file) => {

  /**
  * Mapping of file extensions to Salesforce component types.
  */
  const componentTypeMapping = {
    '.cls': 'ApexClass',
    '.trigger': 'ApexTrigger',
    '.page': 'ApexPage',
    '.xml': 'GenericMetadata',
  };

  const extname = path.extname(file);
  let componentType = componentTypeMapping[extname];
  let componentName = path.basename(file, extname);

  if (!componentType || file.includes('/objects/') || file.includes('/objectTranslations/')) {
    componentType = determineSpecialComponentType(file);
    componentName = determineSpecialComponentName(file, extname, componentType);
  } else if (extname === '.xml') {
    ({ componentType, componentName } = await handleXmlMetaFile(file));
  }
  return { componentType, componentName };
};

/**
 * Determines the component type for special cases based on the file path.
 * @param {string} file - The file path.
 * @returns {string} The determined component type or null if not applicable.
 */
const determineSpecialComponentType = (file) => {

  /**
  * Mapping of file extensions to 'Special' Salesforce component types.
  */
  const specialComponentTypes = [
    { pattern: '/lwc/', type: 'LightningComponentBundle' },
    { pattern: '/aura/', type: 'AuraDefinitionBundle' },
    { pattern: '/staticresources/', type: 'StaticResource' },
    { pattern: '/fields/', type: 'CustomField' },
    { pattern: '/validationRules/', type: 'ValidationRule' },
    { pattern: '/fieldSets/', type: 'FieldSet' },
    { pattern: '/listViews/', type: 'ListView' },
    { pattern: '/compactLayouts/', type: 'CompactLayout' },
    { pattern: '/objects/', type: 'CustomObject' },
    { pattern: '/objectTranslations/', type: 'CustomObjectTranslation' },
  ];

  for (const { pattern, type } of specialComponentTypes) {
    if (file.includes(pattern)) {
      return type;
    }
  }
  return null;
};

/**
 * Determines the component name for special cases based on the file path.
 * @param {string} file - The file path.
 * @param {string} extname - The file extension.
 * @param {string} componentType - The determined component type.
 * @returns {string} The determined component name or null if not applicable.
 */
const determineSpecialComponentName = (file, extname, componentType) => {
  const pathParts = file.split('/');
  const objectName = pathParts[pathParts.indexOf('objects') + 1];

  const componentNameMapping = {
    // Front & Static Resources
    'LightningComponentBundle': () => pathParts[pathParts.indexOf('lwc') + 1],
    'AuraDefinitionBundle': () => pathParts[pathParts.indexOf('aura') + 1],
    'StaticResource': () => path.basename(pathParts[pathParts.indexOf('staticresources') + 1], '.resource'),
    // Object & Object Dependencies
    'CustomField': () => `${objectName}.${path.basename(file, extname).replace('.field-meta', '')}`,
    'ValidationRule': () => `${objectName}.${path.basename(file, extname).replace('.validationRule-meta', '')}`,
    'FieldSet': () => `${objectName}.${path.basename(file, extname).replace('.fieldSet-meta', '')}`,
    'ListView': () => `${objectName}.${path.basename(file, extname).replace('.listView-meta', '')}`,
    'CompactLayout': () => `${objectName}.${path.basename(file, extname).replace('.compactLayout-meta', '')}`,
    'CustomObject': () => objectName,
    // Object Translations
    'CustomObjectTranslation': () => {
      const translationPathParts = file.split('/');
      const translationObjectName = translationPathParts[translationPathParts.indexOf('objectTranslations') + 1];
      return translationObjectName; 
    },
  };

  return componentNameMapping[componentType] ? componentNameMapping[componentType]() : null;
};

/**
 * Handles parsing of XML files to determine the component type and name.
 * @param {string} file - The XML file path.
 * @returns {Promise<{componentType: string, componentName: string}>} The component type and name.
 */
const handleXmlMetaFile = async (file) => {
  const componentName = path.basename(file, '-meta.xml').split('.')[0];
  const metaFilePath = file;

  if (fs.existsSync(metaFilePath)) {
    const metaFileContent = fs.readFileSync(metaFilePath, 'utf-8');
    const parsedXml = await xml2js.parseStringPromise(metaFileContent);
    const rootElement = Object.keys(parsedXml)[0];
    return { componentType: rootElement, componentName };
  } else {
    return { componentType: null, componentName: null };
  }
};

module.exports = { getComponentDetails };
