@isTest
public with sharing class EncryptUtils_TEST {

    @testSetup
    static void initData() {
        Identity_TestFactory.createSettings();
    }

    @isTest
    static void test_getDecryptedMetadata_shoulReturnMetadata() {
        // Given
        Map<String,Object> metadata = new Map<String,Object> {
            'accountId' => '0058A00000AOFc7'
        };
        String base64EncryptedCid = EncryptUtils.getEncryptedMetadata(metadata);
        
        Map<String,Object> metadataResult = EncryptUtils.getDecryptedMetadata(base64EncryptedCid);
        
        // Then
        System.assertequals(metadataResult.get('accountId'), metadata.get('accountId'), 'ERROR');
    }
    
    @isTest
    static void test_getDecryptedMetadata_shoulReturnEmpty() {
        // Given
        String base64EncryptedCid1 = EncodingUtil.base64Encode(Blob.valueOf('azertyuiopmlkjhgfdsqwxcvbn'));
        String base64EncryptedCid2 = EncryptUtils.getEncryptedMetadata(new Map<String,Object> {
            'fullName' => 'Hans Kimkonssern',
            'timestamp' => DateTime.now().getTime(),
            'test' => 'test'
        }) + 'abc';
        
        Map<String,Object> metadata = new Map<String,Object>{};
            Map<String,Object> metadataResult = new Map<String,Object>{};
            Map<String,Object> metadataResult2 = new Map<String,Object>{};
        
        try{
            metadataResult = EncryptUtils.getDecryptedMetadata(base64EncryptedCid1);
            metadataResult2 = EncryptUtils.getDecryptedMetadata(base64EncryptedCid2);
        }
        catch(Exception e){
            // Then
            System.assertEquals(metadata, metadataResult, 'ERROR');
            System.assertEquals(metadata, metadataResult2, 'ERROR');
        }
        
    }
    
}