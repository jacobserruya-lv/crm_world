public with sharing class EncryptUtils {

    private final static String AES128 = 'AES128';
    private final static String SHA256 = 'SHA-256';
    private final static Blob AES_KEY = EncodingUtil.base64Decode(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c);

    public static String getEncryptedMetadata(Map<String,Object> metadata) {
        Map<String,Object> message = new Map<String,Object> { 'hash' => buildHash(metadata) };
        message.putAll(metadata);
        Blob encrypted = Crypto.encryptWithManagedIV(AES128, AES_KEY, Blob.valueOf(jsonSerialize(message)));
        return EncodingUtil.base64Encode(encrypted);
    }
    
    public static Map<String,Object> getDecryptedMetadata(String base64Encrypted) {
        try{
            Blob encrypted = EncodingUtil.base64Decode(base64Encrypted);
            String messageStringified = Crypto.decryptWithManagedIV(AES128, AES_KEY, encrypted).toString();
            Map<String,Object> metadata = (Map<String,Object>) JSON.deserializeUntyped(messageStringified);
            if(String.valueOf(metadata.get('hash')).equals(buildHash(metadata, new Set<String> { 'hash' }))){
                Map<String,Object> metadataClone = metadata.clone();
                metadataClone.remove('hash');
                return metadataClone;
            }
        }
        catch(Exception e){
            System.debug('> Exception in EncryptUtils.getDecryptedMetadata(): ' + e.getMessage());
        }
        return null;
    }
    

    /** PRIVATE METHODS ******************************************************************************************************************/

    private static String buildHash(Map<String,Object> metadata) {
        Map<String,Object> metadataOrderedByKey = sortByKeyAscendant(metadata);
        Blob input = Blob.valueOf(jsonSerialize(metadataOrderedByKey));
        Blob digest = Crypto.generateDigest(SHA256, input);
        return EncodingUtil.base64Encode(digest);
    }

    private static String buildHash(Map<String,Object> metadata, Set<String> metadataKeysToRemove) {
        if (metadataKeysToRemove != null && metadataKeysToRemove.size() > 0) {
            Map<String,Object> metadataClone = metadata.clone();
            for (String key: metadataKeysToRemove) {
                metadataClone.remove(key);
            }
            return buildHash(metadataClone);
        }
        return buildHash(metadata);
    }

    /**
     * @description
     * This method has been created because an Integer value (123) and its equivalent String value ("123") are not serialized the same
     */
    private static String jsonSerialize(Map<String,Object> input) {
        Map<String,String> inputNew = new Map<String,String>();
        for (String key: input.keySet()) {
            inputNew.put(key, String.valueOf(input.get(key)));
        }
        return JSON.serialize(inputNew);
    }
    
     private static Map<String,Object> sortByKeyAscendant(Map<String,Object> input) {
        Map<String,Object> output = new Map<String,Object>();
        if (input != null) {
            List<String> orderdKeyset = new List<String> (input.keySet());
            orderdKeyset.sort();
            for (String key: orderdKeyset) {
                output.put(key, input.get(key));
            }
        }
        return output;
    }
    
}