/*
* @Author   :   Honey Mehta
* @Date     :   25 june 2020
* @Desc     :   Test class related to EDGE-153347  Apex class linked to "Contract Authorisation" button on CS Basket to capture Pre-Authorisation details for MACD Orders
* @MainClass:   ContractAuthorisationFileUploadHandler
*/

@isTest
public class ContractAuthorisationFileUploadHandTest {
    @testsetup static void setupTestData(){
        Account acc = new Account(Name = 'Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
      
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        
        ContentNote cn = new ContentNote(Title = 'Pre-authorisation comment',
                                         Content = Blob.valueOf('notes'));
        insert cn ;   
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId =opp.id; // update opportunity id here
        cdl.ContentDocumentId = cn.Id;
        cdl.shareType = 'V';
        insert cdl;
        
        //Create document
        String base64Data = EncodingUtil.urlDecode('test string for decoding base64', 'UTF-8');
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; 
        conVer.PathOnClient ='title.pdf';
        conVer.Title ='fileName';
        conVer.Description ='Contract Authorisation Docs';
        conVer.VersionData = EncodingUtil.base64Decode(base64Data);
        insert conVer; 
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId =opp.id;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;
        
    }
    
    @isTest static void testOnLoadCmp(){
        opportunity opp = [SELECT id FROM opportunity WHERE name = 'TestingOpp'];
        String opportunityId = opp.id;
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c 
                                            WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
        Test.startTest();
        ContractAuthorisationFileUploadHandler.ContractAuthorisationWrapper caWrapp=ContractAuthorisationFileUploadHandler.onLoadCmp(basket.id, opp.Id);
        Test.stopTest();
        System.assertEquals(false,caWrapp.isPreAuth);
        System.assertEquals('notes',caWrapp.preAuthComments);
        system.assert(caWrapp.contentDocId!=null);
    }
    
    @isTest static void testSubmitPreAuthAndNotes(){
        opportunity opp = [SELECT id FROM opportunity WHERE name = 'TestingOpp'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c 
                                            WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
        Test.startTest();
        ContractAuthorisationFileUploadHandler.submitPreAuthAndNotes(True, 'some value', basket.id, opp.id, '');
        Test.stopTest();
        cscfga__Product_Basket__c basket1 = [SELECT id, Pre_Authorised__c FROM cscfga__Product_Basket__c 
                                             WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
        Boolean isPreauth = basket1.Pre_Authorised__c;
        Set<String> ContentDocumentIds=new  Set<String>();
        List<ContentDocumentLink> cdlList=[SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.Title,ContentDocument.description 
                                           FROM ContentDocumentLink 
                                           where LinkedEntityId=:String.escapeSingleQuotes(opp.id)
                                           AND ContentDocument.Title='Pre-authorisation comment' 
                                          ];
        if(!cdlList.isEmpty()){
            for(ContentDocumentLink cl:cdlList){
                if(cl.ContentDocumentId!=null){
                    ContentDocumentIds.add(cl.ContentDocumentId);
                }
            }
        }
        List<ContentNote> lstContentNote=[SELECT Id, Title,TextPreview 
                                          FROM ContentNote 
                                          Where Id IN:ContentDocumentIds];
        System.assertEquals(True, isPreauth);
        System.assertEquals('notes', lstContentNote[0].TextPreview);
    }
    
    @isTest static void testSubmitPreAuthAndNotesNegative(){
        opportunity opp = [SELECT id FROM opportunity WHERE name = 'TestingOpp'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c 
                                            WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
        Test.startTest();
        ContractAuthorisationFileUploadHandler.submitPreAuthAndNotes(false, 'some value', basket.id, opp.id, '');
        Test.stopTest();
        cscfga__Product_Basket__c basket1 = [SELECT id, Pre_Authorised__c FROM cscfga__Product_Basket__c 
                                             WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
        Boolean isPreauth = basket1.Pre_Authorised__c;
        System.assertEquals(false, isPreauth);
    }
    
    @isTest static void testSubmitPreAuthAndNotesUpdate(){
        opportunity opp = [SELECT id FROM opportunity WHERE name = 'TestingOpp'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c 
                                            WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Test.startTest();
        ContractAuthorisationFileUploadHandler.submitPreAuthAndNotes(true, 'some value', basket.id, opp.id,cdList[0].Id);
        Test.stopTest();
        List<ContentDocument> cdListUpdated = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertNotEquals(cdList[0].Id, cdListUpdated[0].Id);
    }
    
    @isTest static void testSaveChunk(){
        opportunity opp = [SELECT id FROM opportunity WHERE name = 'TestingOpp'];
        String contentType = 'PDF';
        Test.startTest();
        ID fileId = ContractAuthorisationFileUploadHandler.saveChunk(opp.id, 'Test File', 'test', 'PDF', '');
        Test.stopTest();
        ContentDocumentLink cdl = [SELECT id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = : opp.id AND Id =: fileId];
        System.assertEquals('Test File', cdl.ContentDocument.Title);
    }
}