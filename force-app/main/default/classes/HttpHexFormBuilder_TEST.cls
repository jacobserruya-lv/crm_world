@isTest
public with sharing class HttpHexFormBuilder_TEST {

    @isTest
    static void testGetBoundary(){
        String expectedBoundary = '----sfdc-multi-form';
        String actualBoundary = HttpHexFormBuilder.getBoundary();
        System.assertEquals(expectedBoundary, actualBoundary, 'Boundary value should match');
    }
    
    @isTest
    static void testGetContentType(){
        String expectedContentType = 'multipart/form-data; boundary=----sfdc-multi-form';
        String actualContentType = HttpHexFormBuilder.GetContentType();
        System.assertEquals(expectedContentType, actualContentType, 'Content Type should match');
    }
    
    @isTest
    static void testWriteParam(){
        
        HttpHexFormBuilder builder = HttpHexFormBuilder.build();
        builder.writeParam('key', 'value');
        String key ='key';
        String value = 'value';
        String boundary = HttpHexFormBuilder.getBoundary();


        String expectedForm = EncodingUtil.convertToHex( Blob.valueOf( '--' + boundary + '\r\nContent-Disposition: form-data; name="' + key + '";\r\n\r\n' + value + '\r\n' ) );
        expectedForm += EncodingUtil.convertToHex( Blob.valueOf( '--' + boundary + '--' ) );

        String actualForm = builder.getFormAsString();
        
        System.assertEquals(expectedForm, actualForm, 'Form Content should match');
    }
        
    @isTest
    static void testWriteFile(){
        
        HttpHexFormBuilder builder = HttpHexFormBuilder.build();
        builder.writeFile('key', 'file.txt', 'file content');
        String key = 'key';
        String fileName = 'file.txt';
        String fileContent = 'file content';
        String boundary = HttpHexFormBuilder.getBoundary();
        String mimeType = HttpHexFormBuilder.resolveMimeType('file.txt');

        String expectedForm = '--' + boundary;
        expectedForm += '\r\nContent-Disposition: form-data; name="' + key + '"; filename="' + fileName + '";\r\nContent-Type: ' + mimeType + ';\r\n\r\n';
        expectedForm = EncodingUtil.convertToHex( Blob.valueOf( expectedForm ) );
 
        expectedForm += EncodingUtil.convertToHex( EncodingUtil.base64Decode( fileContent ) );
        expectedForm += EncodingUtil.convertToHex( Blob.valueOf( '\r\n' ) );
        expectedForm += EncodingUtil.convertToHex( Blob.valueOf( '--' + boundary + '--' ) );

        String actualForm = builder.getFormAsString();
        System.debug('expectedForm: '+ expectedForm);
        System.debug('actualForm: '+ actualForm);

        System.assertEquals(expectedForm, actualForm, 'Form Content should match');
    }
    
    @isTest
    static void testGetFormAsBlob(){
        HttpHexFormBuilder builder = HttpHexFormBuilder.build();
        builder.writeFile('key', 'file.txt', 'file content');
        
        String key = 'key';
        String fileName = 'file.txt';
        String fileContent = 'file content';
        String boundary = HttpHexFormBuilder.getBoundary();
        String mimeType = HttpHexFormBuilder.resolveMimeType('file.txt');

        String expectedForm = '--' + boundary;
        expectedForm += '\r\nContent-Disposition: form-data; name="' + key + '"; filename="' + fileName + '";\r\nContent-Type: ' + mimeType + ';\r\n\r\n';
        expectedForm = EncodingUtil.convertToHex( Blob.valueOf( expectedForm ) );
 
        expectedForm += EncodingUtil.convertToHex( EncodingUtil.base64Decode( fileContent ) );
        expectedForm += EncodingUtil.convertToHex( Blob.valueOf( '\r\n' ) );
        expectedForm += EncodingUtil.convertToHex( Blob.valueOf( '--' + boundary + '--' ) );

        Blob expectedFormBlob = EncodingUtil.convertFromHex(expectedForm);

        Blob actualFormBlob = builder.getFormAsBlob();        

        System.assertEquals(expectedFormBlob, actualFormBlob, 'Form As Blob should match');
    }
    
    @isTest
    static void testResolveMimeType(){
        
        String mimeTypePng = HttpHexFormBuilder.resolveMimeType('image.png');
        System.assertEquals('image/png', mimeTypePng, 'Mime type for PNG should be image/png');
        
        String mimeTypeJpg = HttpHexFormBuilder.resolveMimeType('image.jpg');
        System.assertEquals('image/jpg', mimeTypeJpg, 'Mime type for JPG should be image/jpg');
        
        String mimeTypeMp4 = HttpHexFormBuilder.resolveMimeType('video.mp4');
        System.assertEquals('video/mp4', mimeTypeMp4, 'Mime type for MP4 should be video/mp4');
        
        String mimeTypeGif = HttpHexFormBuilder.resolveMimeType('image.gif');
        System.assertEquals('image/gif', mimeTypeGif, 'Mime type for GIF should be image/gif');
    }

}