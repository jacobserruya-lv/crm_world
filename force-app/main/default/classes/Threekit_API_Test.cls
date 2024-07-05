@isTest
public class Threekit_API_Test {

    @isTest
    public static void test_all() {
        Test.setMock(HttpCalloutMock.class, new Threekit_API_Test.Mock());
        Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();

            RestContext.request = request;
            RestContext.response = response;

            Threekit_API.getRecipeDetails('sVPK_M0L2');
            Map<String,Object> resp = (Map<String,Object>)JSON.deserializeUntyped(mockBody);
            Threekit_API.parseBody(resp,false);
        Test.stopTest();
    }
    
    @isTest
    public static void test_all2() {
        Test.setMock(HttpCalloutMock.class, new Threekit_API_Test.Mock2());
        Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();

            RestContext.request = request;
            RestContext.response = response;

            Threekit_API.getRecipeDetails('sVPK_M0L2');
            Map<String,Object> resp = (Map<String,Object>)JSON.deserializeUntyped(mockBody);
            Threekit_API.parseBody(resp,false);
        Test.stopTest();
    }


       @isTest
    public static void test_all3() {
        Test.setMock(HttpCalloutMock.class, new Threekit_API_Test.Mock3());
        Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();

            RestContext.request = request;
            RestContext.response = response;

            Threekit_API.getRecipeDetails('THVPJLM9');
            Map<String,Object> resp = (Map<String,Object>)JSON.deserializeUntyped(mockBodyAlpha);
            Threekit_API.parseBody(resp,true);
        Test.stopTest();
    }

    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(mockBody);
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class Mock2 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"baba":conflict"}');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            return res;
        }
    }

    private class Mock3 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(mockBodyAlpha);
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            return res;
        }
    }

    private static String mockBody = '{"id":"55d52431-f915-4a27-9d89-79c3a16b280c","productId":"b5acbcf9-4337-4e4b-94b3-e8138f6400f6","productVersion":"v1","variant":{"Losine":{"type":"item","assetId":"ddc203d0-1acc-46db-a9c8-1443c360b46e","configuration":""},"Variant":{"type":"item","assetId":"c610465b-9a3f-4877-9c7b-4a0dc10f9ebf","configuration":""},"Marquage":{"type":"item","assetId":"593d7d10-2bc6-43ba-a66a-5f10790b4353","configuration":""},"Top Color":{"type":"item","assetId":"4258afaa-8cb5-4b27-b60a-5322f7e23d5b","configuration":""},"Slice Color":{"type":"item","assetId":"1478fc5f-414b-4693-a8aa-81bb66844fac","configuration":""},"Strap Color":{"type":"item","assetId":"7ad0a743-1702-44a1-b595-a472984418c1","configuration":""},"Accent Color":{"type":"item","assetId":"1388981a-a0d2-4769-aa6b-7fadf2bd6ae7","configuration":""},"Drawers Color":{"type":"item","assetId":"c70816f3-ebf2-4f48-9bc0-0882fad9e3d7","configuration":""},"Losine Double":{"type":"item","assetId":"e1fadc10-409f-4e20-b979-b44cbfff612a","configuration":""},"Trunk Variant":"Monogram Red","Glass Material":{"type":"item","assetId":"33163917-554f-4ce5-9ac3-79729ae49098","configuration":""},"Stitching Color":{"type":"item","assetId":"21e45e85-b3e3-4bfc-8010-ff46f05596b4","configuration":""},"Trimming2 Color":{"type":"item","assetId":"98e46b38-e348-4980-9b98-ad63dd50b8f9","configuration":""},"Lid & Door Color":{"type":"item","assetId":"596e408f-984b-4094-a154-a90e6a52b054","configuration":""},"Stitching2 Color":{"type":"item","assetId":"21e45e85-b3e3-4bfc-8010-ff46f05596b4","configuration":""},"Metallic Finition":{"type":"item","assetId":"1a312b52-6d85-4557-9697-a76929c88867","configuration":""},"Exterior Material Color":{"type":"item","assetId":"3c9ddfdd-6aed-47ca-af52-ce95d39a7cc8","configuration":""}},"metadata":{"sku":["M20340"],"industrialCode":{},"readableConfiguration":{"Losine":{},"Variant":{"value":"Monogram Macassar Black","thumbnail":"https://preview.threekit.com/api/images/webp/200x0/https://preview.threekit.com/api/files/76db6b82-52b2-4712-9fec-12501125a8dc/content"},"Marquage":{},"Top Color":{},"Slice Color":{},"Strap Color":{},"Accent Color":{},"Drawers Color":{},"Losine Double":{},"Glass Material":{},"Stitching Color":{"value":"Couture Noir"},"Trimming2 Color":{},"Lid & Door Color":{},"Stitching2 Color":{"value":"Couture Noir"},"Metallic Finition":{"value":"Palladium","thumbnail":"https://preview.threekit.com/api/files/0d1d3e25-fd57-49a9-8bcc-758d69449a94/content"},"Exterior Material Color":{"value":"Classic","thumbnail":"https://preview.threekit.com/api/files/c3d10c2f-cf0f-42ed-a44a-a34c28663330/content"}},"threekitConfiguration":{"Losine":{"type":"item","assetId":"ddc203d0-1acc-46db-a9c8-1443c360b46e","configuration":""},"Variant":{"type":"item","assetId":"c610465b-9a3f-4877-9c7b-4a0dc10f9ebf","configuration":""},"Marquage":{"type":"item","assetId":"593d7d10-2bc6-43ba-a66a-5f10790b4353","configuration":""},"Top Color":{"type":"item","assetId":"4258afaa-8cb5-4b27-b60a-5322f7e23d5b","configuration":""},"Slice Color":{"type":"item","assetId":"1478fc5f-414b-4693-a8aa-81bb66844fac","configuration":""},"Strap Color":{"type":"item","assetId":"7ad0a743-1702-44a1-b595-a472984418c1","configuration":""},"Accent Color":{"type":"item","assetId":"1388981a-a0d2-4769-aa6b-7fadf2bd6ae7","configuration":""},"Drawers Color":{"type":"item","assetId":"c70816f3-ebf2-4f48-9bc0-0882fad9e3d7","configuration":""},"Losine Double":{"type":"item","assetId":"e1fadc10-409f-4e20-b979-b44cbfff612a","configuration":""},"Trunk Variant":"Monogram Red","Glass Material":{"type":"item","assetId":"33163917-554f-4ce5-9ac3-79729ae49098","configuration":""},"Stitching Color":{"type":"item","assetId":"21e45e85-b3e3-4bfc-8010-ff46f05596b4","configuration":""},"Trimming2 Color":{"type":"item","assetId":"98e46b38-e348-4980-9b98-ad63dd50b8f9","configuration":""},"Lid & Door Color":{"type":"item","assetId":"596e408f-984b-4094-a154-a90e6a52b054","configuration":""},"Stitching2 Color":{"type":"item","assetId":"21e45e85-b3e3-4bfc-8010-ff46f05596b4","configuration":""},"Metallic Finition":{"type":"item","assetId":"1a312b52-6d85-4557-9697-a76929c88867","configuration":""},"Exterior Material Color":{"type":"item","assetId":"3c9ddfdd-6aed-47ca-af52-ce95d39a7cc8","configuration":""}}},"createdAt":"2022-02-06T09:02:10.629Z","shortId":"sVPK_M0L2","orgId":"82f1c1f2-5594-4734-824a-94d7a74d0aac","thumbnail":"sha256-f11e20a9c7a372d77c65cc23583d07be7560693330206d209fb5e9f98f306f20","customerId":null,"scope":null,"identifier":null}';
    private static String mockBodyAlpha ='{"custom":{"jde":{"RIGIV01":"RIGIMAT04","RIGIV02":"RIGICOLE10","RIGIV03":"RIGILIN02","RIGIV04":"RIGICOLI54","RIGIV05":"RIGIMFIN02","RIGIV06":"RIGILOCKY","RIGIV07":"","RIGIV08":"RIGIPATY","RIGIV09":"RIGIPST02","RIGIV10":"","RIGIV11":"RIGISI05","RIGIV17":"RIGICOI01","RIGIV18":""},"skus":["P00684"],"macro_components":{}},"version":"v1","metadata":{"skus":["P00684"],"locale":"locale_LOCALE","baseUrl":"https://preview.threekit.com","readableConfiguration":{"Camera":{"uiVisible":false},"has patch":{"value":"yes","thumbnail":"https://preview.threekit.com/api/files/38f20da6-1f76-41f9-ba2e-31cc0183d26c/content","uiVisible":true,"uiPositionIndex":5,"attributeDisplayName":"Has patch","attributeValueDisplayName":"Yes"},"Lining Color":{"value":"MIC.CREME","thumbnail":"https://preview.threekit.com/api/files/771f13f3-81b8-4a98-b805-08b0bd9b20d3/content","uiVisible":true,"uiPositionIndex":4,"attributeDisplayName":"Interior color","attributeValueDisplayName":"Crème"},"MODEL Taille":{"value":"BISTEN 75","uiVisible":true,"uiPositionIndex":0,"attributeDisplayName":"Size","attributeValueDisplayName":"Bisten 75"},"Rotate Model":{"uiVisible":false},"Lining Material":{"value":"Microfibre","thumbnail":"https://preview.threekit.com/api/files/da1f2540-b0eb-4001-a08e-d6513315e73d/content","uiVisible":true,"uiPositionIndex":3,"attributeDisplayName":"Interior material","attributeValueDisplayName":"Microfibre"},"has lock number":{"value":"yes","thumbnail":"https://preview.threekit.com/api/files/38f20da6-1f76-41f9-ba2e-31cc0183d26c/content","uiVisible":true,"uiPositionIndex":9,"attributeDisplayName":"Has lock number","attributeValueDisplayName":"Yes"},"Exterior material":{"value":"Epi","thumbnail":"https://preview.threekit.com/api/files/e923b9c2-d0f0-469c-8c67-4209d1f59abc/content","uiVisible":true,"uiPositionIndex":1,"attributeDisplayName":"Exterior material","attributeValueDisplayName":"Epi"},"Model Presentation":{"uiVisible":false},"perso + / patch style":{"value":"Palladium","thumbnail":"https://preview.threekit.com/api/files/71709810-9d5c-44ad-871a-084cb14e6214/content","uiVisible":true,"thumbnailColor":"#dbd8d5","uiPositionIndex":6,"attributeDisplayName":"Patch style","attributeValueDisplayName":"Palladium"},"Exterior Material Color":{"value":"EPI IVOIRE","thumbnail":"https://preview.threekit.com/api/files/baa40282-83ab-451f-9df6-e26c104fcd26/content","uiVisible":true,"uiPositionIndex":2,"attributeDisplayName":"Exterior color","attributeValueDisplayName":"Ivoire"},"perso + / patch text line 1":{"value":"","uiVisible":true,"uiPositionIndex":7,"attributeDisplayName":"Patch text"},"perso + / patch text line 2":{"value":"","uiVisible":true,"uiPositionIndex":8,"attributeDisplayName":"Patch text (line 2)"},"perso + / Lock number exists":{"value":"","uiVisible":true,"uiPositionIndex":10,"attributeDisplayName":"Existing lock number"},"dataDrivenConfiguratorToolSwitch":{"uiVisible":false}},"threekitConfiguration":{"Camera":{"type":"item","assetId":"a19489b7-67ed-4345-ad12-76773a07dc93"},"has patch":{"type":"item","assetId":"735ee208-2580-46ea-ab3a-e96898c0a9ce"},"Lining Color":{"assetId":"8b7c6077-aee1-4c13-821c-63119c88a194"},"MODEL Taille":{"assetId":"e067056c-2b2c-4fd0-ae16-4c6b16ea79cd"},"Rotate Model":0,"Lining Material":{"assetId":"13bf6955-acb5-48fd-94ce-8c179a3e752e"},"has lock number":{"assetId":"52895693-c4bd-4fc8-9427-5dfa413e42a2"},"Exterior material":{"assetId":"97dca821-52c2-43ab-b50c-008f24fd39f5"},"Model Presentation":"Closed","perso + / patch style":{"assetId":"aabd5a3a-bb78-4835-a7b2-2f5143060a2f"},"Exterior Material Color":{"assetId":"0708c51c-2deb-422f-866a-d8285a6249d0"},"perso + / patch text line 1":"","perso + / patch text line 2":"","perso + / Lock number exists":"","dataDrivenConfiguratorToolSwitch":"On"}},"recipeId":"TQRRCHJR","published_on":[],"creation_date":"2023-12-14T10:39:44.577Z","dataDrivenConfiguratorCodeVersion":"0.0.20-WIP-preview-202310151903","dataDrivenConfiguratorExtensionCodeVersion":"202312070025","configuration":{"Camera":{"type":"item","assetId":"a19489b7-67ed-4345-ad12-76773a07dc93"},"has patch":{"type":"item","assetId":"735ee208-2580-46ea-ab3a-e96898c0a9ce"},"Lining Color":{"assetId":"8b7c6077-aee1-4c13-821c-63119c88a194"},"MODEL Taille":{"assetId":"e067056c-2b2c-4fd0-ae16-4c6b16ea79cd"},"Rotate Model":0,"Lining Material":{"assetId":"13bf6955-acb5-48fd-94ce-8c179a3e752e"},"has lock number":{"assetId":"52895693-c4bd-4fc8-9427-5dfa413e42a2"},"Exterior material":{"assetId":"97dca821-52c2-43ab-b50c-008f24fd39f5"},"Model Presentation":"Closed","perso + / patch style":{"assetId":"aabd5a3a-bb78-4835-a7b2-2f5143060a2f"},"Exterior Material Color":{"assetId":"0708c51c-2deb-422f-866a-d8285a6249d0"},"perso + / patch text line 1":"","perso + / patch text line 2":"","perso + / Lock number exists":"","dataDrivenConfiguratorToolSwitch":"On"},"attachments":{"Open":"https://lv-api.3kit.com/api/configurations/TQRRCHJR/image/Open","Side":"https://lv-api.3kit.com/api/configurations/TQRRCHJR/image/Side","Front":"https://lv-api.3kit.com/api/configurations/TQRRCHJR/image/Front"},"skus":["P00684"]}';
}