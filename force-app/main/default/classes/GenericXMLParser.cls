public with sharing class GenericXMLParser {
    
	static set<string> arraysElem{set; get;}
	
	public static map<string, object> ParseXML(string xmlString, set<string> arraysNode){
		arraysElem = arraysNode;
		Dom.Document doc = new Dom.Document();
		doc.load(xmlString);
		
		map<string, object> xmlMap = parseXML(doc.getRootElement());
		return xmlMap;
	}
	
	private static map<string, object> parseXML(Dom.XmlNode xmlNode){
    	map<string, object> result = new map<string, object>();
    
		list<Dom.XmlNode> nodes = xmlNode.getChildElements();
    
    	if(nodes.size() > 0){
    		boolean isArray = isArray(xmlNode);
    		
    		if(isArray){
        		list<map<string, object>> childNodesList = new list<map<string, object>>();
    			for(Dom.XmlNode myNode : nodes){
        			childNodesList.add(parseXML(myNode));
    			}
        
        		result.put(xmlNode.getName(), childNodesList);
    		}else{
    			map<string, object> childNodesMap = new map<string, object>();
    			for(Dom.XmlNode myNode : nodes){
        			childNodesMap.putAll(parseXML(myNode));
    			}
        
        		result.put(xmlNode.getName(), childNodesMap);
    		}
    	}else{
    		result.put(xmlNode.getName(), xmlNode.getText());
    	}
    	return result;
	}
	
	private static boolean isArray(Dom.XmlNode node){
		if(arraysElem.contains(node.getName())){
			return true;
		}
		return false;
	}
	
	public static map<string, object> getNode(map<string, object> currentNode, string node){
		return getNode(currentNode, new list<string> {node});
	}
	
	public static map<string, object> getNode(map<string, object> currentNode, list<string> nodesHierarchy){
		map<string, object> resultNode = currentNode;
		for(string currentNodeName : nodesHierarchy){
			if(resultNode == null) {
				return null;
			}
			resultNode = (map<string, object>) resultNode.get(currentNodeName);
		}
		return resultNode;
	}
	
	public static list<map<string, object>> getNodeArray(map<string, object> currentNode, string node){
		return getNodeArray(currentNode, new list<string> {node});
	}
	
	public static list<map<string, object>> getNodeArray(map<string, object> currentNode, list<string> nodesHierarchy){
		for(integer index = 0; index < nodesHierarchy.size(); index++){
			if(index < nodesHierarchy.size() -1){
				currentNode = (map<string, object>)currentNode.get(nodesHierarchy[index]);
			}else{
				return (list<map<string, object>>)currentNode.get(nodesHierarchy[index]);
			}
		}
		return null;
	}
}