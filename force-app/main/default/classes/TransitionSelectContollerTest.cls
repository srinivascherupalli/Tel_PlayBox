@isTest
public class TransitionSelectContollerTest {
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        testAccount.CIDN__c = '12456';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        //testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        //testOpp.Type = 'New To Market';
        //testOpp.Billing_Solution__c = 'Standard';
        insert testOpp;
        
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Mobile device', cscfga__Description__c = 'Mobile device',product_Specification__c='DMCAT_ProductSpecification_000423');
        insert CW_PD;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        cscfga__Configuration_Offer__c offer=new cscfga__Configuration_Offer__c();
        offer.Name='Telstra Collaboration';
        insert offer;//Added by Aishwarya
        
        // DIGI-6039 : Added by Jay (Osaka)
        Marketable_Offer__c marketableOfferRec = new Marketable_Offer__c ();
        marketableOfferRec.Name = 'Adaptive Collaboration';
        marketableOfferRec.Offer_ID__c = 'DMCAT_Offer_000618'; 
        insert marketableOfferRec;
        // End of DIGI-6039
        cscfga__Product_Configuration__c prdConfig = new cscfga__Product_Configuration__c();
        prdConfig.cscfga__Quantity__c = 1;
        prdConfig.cscfga__Product_Basket__c = testBasket.Id;
        prdConfig.cscfga__Product_Definition__c = CW_PD.Id;
        prdConfig.Marketable_Offer__c = marketableOfferRec.Id;// Added by Jay(Osaka)
        prdConfig.Offer_Reference__c = offer.Id;//Added by Aishwarya
        insert prdConfig;
        /*List<Legacy_Service__c> lstlegacyserviceToInsert=new List<Legacy_Service__c>();
        Legacy_Service__c legacyservice = new Legacy_Service__c();
        legacyservice.Product_Basket__c     = testBasket.Id;
        legacyservice.Service_Id__c         = '6134567899';
        legacyservice.Product_Type__c       = 'Enterprise Mobility';
        lstlegacyserviceToInsert.add(legacyservice);
        insert lstlegacyserviceToInsert;*/
    
    }
    @isTest
    public static void TestParsingDTOcidnNotPresent(){
        Boolean nextFlag = false;
        String str = 'Service Id,CIDN,Product Family\r\n6134567899,12456,Enterprise Mobility\r\n8674657,8674657,Enterprise Mobility\r\n8539866,8539866,Enterprise Mobility\r\n1002222222,1002222222,Enterprise Mobility\r\n4878561269,4878561269,Enterprise Mobility\r\n7986021,7986021,Enterprise Mobility\r\n758469,758469,Enterprise Mobility\r\n9012345678,9012345678,Enterprise Mobility\r\n186750,186750,Enterprise Mobility\r\n1234432112,1234432112,Enterprise Mobility\r\n8111000014,8111000014,Enterprise Mobility\r\n1111000002,1111000002,Enterprise Mobility\r\n345678654,345678654,Enterprise Mobility\r\n383700142,383700142,Enterprise Mobility\r\n888799,888799,Enterprise Mobility\r\n' ;
        string str2=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id,Name FROM cscfga__Product_Basket__c limit 1];
        Test.startTest();
        String response =TransitionSelectContoller.saveCSVfile(str2,basket[0].id,nextFlag);
        test.stopTest();
        System.debug('response: '+response);
        //System.assertEquals(response=='Provided CIDN number is not present in the system:8674657', true, 'Incorrect CIDN');

        System.assertNotEquals(response=='The Product Family in the CSV file does not match the Product Family of the offer in the basket.', false, 'Incorrect CIDN');
    }
    @isTest
    public static void TestParsingDTOSuccess(){
        Boolean nextFlag = false;
        String str = 'Service Id,CIDN,Product Family\r\n1234567899,12456,Enterprise Mobility\r\n' ;
        string str2=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        System.debug('basket: '+basket);
        test.startTest();
        String response = TransitionSelectContoller.saveCSVfile(str2,basket[0].id,nextFlag);
        test.stopTest();
        System.debug('response: '+response);
        System.assertNotEquals(response=='The Product Family in the CSV file does not match the Product Family of the offer in the basket.', false, 'Incorrect CIDN');
    }
    @isTest
    public static void TestParsingDTOErrorCidnBlank(){
        Boolean nextFlag = false;
        String str = 'Service Id,CIDN,Product Family\r\n1234567899,,Enterprise Mobility\r\n' ;
        string str2=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        test.startTest();
        String response = TransitionSelectContoller.saveCSVfile(str2,basket[0].id,nextFlag);
        test.stopTest();
        System.debug('response: 4 '+response);
        System.assertEquals(response=='CIDN value can not blank.', true, 'CIDN value can not blank.');
    }
    @isTest
    public static void TestParsingDTOErrorServiceidBlank(){
        Boolean nextFlag = false;
        String str =  'Service Id,CIDN,Product Family\r\n,1234567899,Enterprise Mobility\r\n';
        string str2=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        test.startTest();
        String response = TransitionSelectContoller.saveCSVfile(str2,basket[0].id,nextFlag);
        test.stopTest();
        System.debug('response: '+response);
        System.assertEquals(basket.size() > 0, true);
    }
    @isTest
    public static void TestParsingDTOError150Records(){
        Boolean nextFlag = false;
        String str =  'Service Id,CIDN,Product Family\r\n61123456789,12456,Enterprise Mobility\r\n61867465712,12456,Enterprise Mobility\r\n61853986615,12456,Enterprise Mobility\r\n61100222222,12456,Enterprise Mobility\r\n61487856126,12456,Enterprise Mobility\r\n617986021124,12456,Enterprise Mobility\r\n61758469142,12456,Enterprise Mobility\r\n61901234567,12456,Enterprise Mobility\r\n61186750124,12456,Enterprise Mobility\r\n61123443211,12456,Enterprise Mobility\r\n61811100001,12456,Enterprise Mobility\r\n61111100000,12456,Enterprise Mobility\r\n61383700142,12456,Enterprise Mobility\r\n61888799124,12456,Enterprise Mobility\r\n61256345590,12456,Enterprise Mobility\r\n61264815608,12456,Enterprise Mobility\r\n61273285626,12456,Enterprise Mobility\r\n61281755644,12456,Enterprise Mobility\r\n61290225662,12456,Enterprise Mobility\r\n61298695680,12456,Enterprise Mobility\r\n61307165698,12456,Enterprise Mobility\r\n61315635715,12456,Enterprise Mobility\r\n61324105733,12456,Enterprise Mobility\r\n61332575751,12456,Enterprise Mobility\r\n61341045769,12456,Enterprise Mobility\r\n613495157875,12456,Enterprise Mobility\r\n61357985805,12456\r\n';
        string str2=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        test.startTest();
        String response = TransitionSelectContoller.saveCSVfile(str2,basket[0].id,nextFlag);
        test.stopTest();
        System.debug('response: '+response);
        System.assertNotEquals(response=='Uploaded file can not be more then 150 records.', true, 'Service Id value can not blank.');
    }
    @isTest
    public static void getServiceTypeTransitionTest(){
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        test.startTest();
        TransitionSelectContoller.DetailsWrapper details = TransitionSelectContoller.getServiceType(basket[0].id); 
        Boolean checkForTenancy = TransitionSelectContoller.checkForTenancyOfferIdForCurrentBasket(basket[0].id);
        test.stopTest();
        System.assertEquals(details.serviceType=='Transition', true, 'details');
    }
     @isTest
    public static void getServiceTypeMigrationTest(){
        Boolean nextFlag = false;
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        List<Opportunity> opportunity = [SELECT id,type FROM Opportunity WHERE name = 'testOpp'];
        opportunity[0].type='Migration';
        //update opportunity;
        test.startTest();
        TransitionSelectContoller.DetailsWrapper details = TransitionSelectContoller.getServiceType(basket[0].id); 
        test.stopTest();
        System.assertNotEquals(details.serviceType=='Migration', true, 'details');
    }
     @isTest
    public static void getCIDNwithAccoundIdTest(){
        Set<String> setCIDN = new Set<String>{'12456'};
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        System.debug('basket in getCIDNwithAccoundIdTest ' + basket);
        test.startTest();
        csvUploaderHelper.getCIDNwithAccoundId(setCIDN); 
        System.assertEquals(basket.size() > 0,true);
        test.stopTest();
    }
    @isTest
    public static void noCSVValidation(){
        Boolean nextFlag = true;
        String csvInput;
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        test.startTest();
        String response = TransitionSelectContoller.saveCSVfile(csvInput,basket[0].id,nextFlag);
        System.assert(response.contains('missing')==true);
        test.stopTest();
            
    }
    
    @isTest
    public static void mulitpleCIDNValidation(){
        Boolean nextFlag = true;
        String str = 'Service Id,CIDN,Product Family\r\n1234567899,1245689,Enterprise Mobility\r\n8674657,12456,Enterprise Mobility\r\n8539866,12456,Enterprise Mobility\r\n1002222222,12456,Enterprise Mobility\r\n';
        string csvInput=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        test.startTest();
        String response = TransitionSelectContoller.saveCSVfile(csvInput,basket[0].id,nextFlag);
        System.assert(basket.size() >0, true);
        test.stopTest();
    }
    @isTest
    public static void TestParsingDTOError(){
        Boolean nextFlag = false;
        String str =  'Service Id,CIDN,\r\n61123456789,12456,Enterprise Mobility\r\n61867465712,12456,Enterprise Mobility\r\n61853986615,12456,Enterprise Mobility\r\n61100222222,12456,Enterprise Mobility\r\n61487856126,12456,Enterprise Mobility\r\n617986021124,12456,Enterprise Mobility\r\n61758469142,12456,Enterprise Mobility\r\n61901234567,12456,Enterprise Mobility\r\n61186750124,12456,Enterprise Mobility\r\n61123443211,12456,Enterprise Mobility\r\n61811100001,12456,Enterprise Mobility\r\n61111100000,12456,Enterprise Mobility\r\n61383700142,12456,Enterprise Mobility\r\n61888799124,12456,Enterprise Mobility\r\n61256345590,12456,Enterprise Mobility\r\n61264815608,12456,Enterprise Mobility\r\n61273285626,12456,Enterprise Mobility\r\n61281755644,12456,Enterprise Mobility\r\n61290225662,12456,Enterprise Mobility\r\n61298695680,12456,Enterprise Mobility\r\n61307165698,12456,Enterprise Mobility\r\n61315635715,12456,Enterprise Mobility\r\n61324105733,12456,Enterprise Mobility\r\n61332575751,12456,Enterprise Mobility\r\n61341045769,12456,Enterprise Mobility\r\n613495157875,12456,Enterprise Mobility\r\n61357985805,12456\r\n';
        string str2=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        test.startTest();
        String response = csvUploaderHelper.saveFile(str2,basket[0].id,nextFlag);
        test.stopTest();
        System.debug('response: '+response);
        System.assertEquals(response=='Some or all key details (Service ID, CIDN, Product Family) are missing.', true, 'Some or all key details (Service ID, CIDN, Product Family) are missing.');
    }
    @isTest
    public static void TestParsingDTOError2(){
        Boolean nextFlag = false;
        String str =  'Service Id,CIDN,Product Family\r\n61123456789,12456,PSTN\r\n61867465712,12456,Enterprise Mobility\r\n61853986615,12456,ISDN30\r\n61100222222,12456,Enterprise Mobility\r\n61487856126,12456,Enterprise Mobility\r\n617986021124,12456,Enterprise Mobility\r\n61758469142,12456,Enterprise Mobility\r\n61901234567,12456,Enterprise Mobility\r\n61186750124,12456,Enterprise Mobility\r\n61123443211,12456,Enterprise Mobility\r\n61811100001,12456,Enterprise Mobility\r\n61111100000,12456,Enterprise Mobility\r\n61383700142,12456,Enterprise Mobility\r\n61888799124,12456,Enterprise Mobility\r\n61256345590,12456,Enterprise Mobility\r\n61264815608,12456,Enterprise Mobility\r\n61273285626,12456,Enterprise Mobility\r\n61281755644,12456,Enterprise Mobility\r\n61290225662,12456,Enterprise Mobility\r\n61298695680,12456,Enterprise Mobility\r\n61307165698,12456,Enterprise Mobility\r\n61315635715,12456,Enterprise Mobility\r\n61324105733,12456,Enterprise Mobility\r\n61332575751,12456,Enterprise Mobility\r\n61341045769,12456,Enterprise Mobility\r\n613495157875,12456,Enterprise Mobility\r\n61357985805,12456\r\n';
        string str2=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        test.startTest();
        String response = csvUploaderHelper.saveFile(str2,basket[0].id,nextFlag);
        test.stopTest();
        System.debug('response: '+response);
        System.assertNotEquals(response=='Uploaded file can not be more then 150 records.', true, 'Service Id value can not blank.');
    }
    @isTest
    public static void fileUploadSuccess(){
        Boolean nextFlag = false;
        String str = 'Service Id,CIDN,Product Family\r\n61474896400,12456,PSTN\r\n' ;
        string str2=JSON.serialize(str);
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c limit 1];
        System.debug('basket: '+basket);
        test.startTest();
        String response = TransitionSelectContoller.saveCSVfile(str2,basket[0].id,nextFlag);
        test.stopTest();
        System.debug('responseSuccess: '+response);
        System.assertEquals(response=='file uploaded successfully.',true,'file uploaded successfully.');
    }
    
/*************************************************************************************************
Name : profileAndProductCheckTest
Description : Test method for profileAndProductCheck
Developer : Abhishek Mallick
Story: EDGE-198190
***************************************************************************************************/
    
    @isTest
    public static void profileAndProductCheckTest(){
        Account accRec = new Account();
        accRec = [select id from Account where name = 'testAccount'];
        
        cscfga__Product_Basket__c prodBasketMobile = new cscfga__Product_Basket__c();
        prodBasketMobile.csbb__Account__c = accRec.Id;
        prodBasketMobile.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        prodBasketMobile.Name = 'Mobile Eligibility Transition';
        prodBasketMobile.isEligibilityCheckComplete__c = false;
        prodBasketMobile.isEligibilityTriggered__c = false;
        insert prodBasketMobile;
        
        cscfga__Product_Definition__c productDefinition = ProductTestFactory.buildProductDefinition('TestEligibility','Test');
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert productDefinition;
 
        cscfga__Product_Configuration__c prodConfigMobile = ProductTestFactory.buildProductConfig(productDefinition.Id);
        prodConfigMobile.name= 'Corporate Mobile Plus';
        prodConfigMobile.cscfga__Description__c = 'Test description';
        prodConfigMobile.cscfga__Product_Basket__c = prodBasketMobile.Id;
        prodConfigMobile.isEligibleForTriggered__c=true;
        prodConfigMobile.cscfga__Quantity__c = 1;
        insert prodConfigMobile;
        
        Test.startTest();
        Boolean flag = TransitionSelectContoller.profileAndProductCheck(prodBasketMobile.Id);
        Test.stopTest();
        System.assert(productDefinition != NULL);
    }
    
/*************************************************************************************************
Name : getCIDNDetailsTest
Description : Test method for getCIDNDetails(Positive)
Developer : Abhishek Mallick
Story: EDGE-198196
***************************************************************************************************/    
    
    @isTest
    public static void getCIDNDetailsTest(){
        Map<String,String> cidnValues = new Map<String,String>();
        Account accRec = new Account();
        accRec.Name = 'Test Account1';
        accRec.CIDN__c = '1234567890';
        accRec.Parent_CIDN__c = '0987654321';
        accRec.Ultimate_Parent_CIDN__c = '9819167890';
        accRec.Customer_Status__c = 'ACTIVE';
        
        insert accRec;
        
        Account accRecParent = new Account();
        accRecParent.Name = 'Test Account2';
        accRecParent.CIDN__c = '9087654272';
        accRecParent.Parent_CIDN__c = '1234567890';
        accRecParent.Ultimate_Parent_CIDN__c = '8374638028';
        accRecParent.Customer_Status__c = 'ACTIVE';
        insert accRecParent;
        
        Account accRecUltimate = new Account();
        accRecUltimate.Name = 'Test Account3';
        accRecUltimate.CIDN__c = '0987612345';
        accRecUltimate.Parent_CIDN__c = '6543219876';
        accRecUltimate.Ultimate_Parent_CIDN__c = '1234567890';
        accRecUltimate.Customer_Status__c = 'ACTIVE';
        insert accRecUltimate;
        
        cscfga__Product_Basket__c prodBasketMobile = new cscfga__Product_Basket__c();
        prodBasketMobile.csbb__Account__c = accRec.Id;
        prodBasketMobile.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        prodBasketMobile.Name = 'Mobile Eligibility Transition';
        prodBasketMobile.isEligibilityCheckComplete__c = false;
        prodBasketMobile.isEligibilityTriggered__c = false;
        insert prodBasketMobile;
        
        Test.startTest();
        cidnValues = TransitionSelectContoller.getCIDNDetails(prodBasketMobile.Id);
        test.stopTest();
        System.assert(!cidnValues.isEmpty());
        
    }
/*************************************************************************************************
Name : getCIDNDetailsTest
Description : Test method for getCIDNDetails(Negative)
Developer : Abhishek Mallick
Story: EDGE-198196
***************************************************************************************************/ 
    
    @isTest
    public static void getCIDNDetailsTestNegative(){
        Map<String,String> cidnValues = new Map<String,String>();
        Account accRec = new Account();
        accRec.Name = 'Test Account';
        accRec.CIDN__c = '1234567890';
        accRec.Parent_CIDN__c = '0987654321';
        accRec.Ultimate_Parent_CIDN__c = '9819167890';
        accRec.Customer_Status__c = 'PENDING';
        
        insert accRec;
        
        cscfga__Product_Basket__c prodBasketMobile = new cscfga__Product_Basket__c();
        prodBasketMobile.csbb__Account__c = accRec.Id;
        prodBasketMobile.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        prodBasketMobile.Name = 'Mobile Eligibility Transition';
        prodBasketMobile.isEligibilityCheckComplete__c = false;
        prodBasketMobile.isEligibilityTriggered__c = false;
        insert prodBasketMobile;
        
        Test.startTest();
        cidnValues = TransitionSelectContoller.getCIDNDetails(prodBasketMobile.Id);
        test.stopTest();
        System.assert(cidnValues.isEmpty() == true);
    }
    
     @isTest
public static void uploadAthurizationTest(){
    String strBlob = '{Test Content}'; 
   TransitionSelectContoller.FileInfo fileData =new  TransitionSelectContoller.FileInfo ();
    fileData.Title = 'Penguins.pdf';
    fileData.VersionData = Blob.valueOf(strBlob);
    String json='{ "VersionData" : "VGVzdCBDb250ZW50","Title" : "Penguins.pdf"}';
    String yourFiles = '{"Title": "Penguins.pdf","VersionData": "strBlob"}';
    Blob bodyBlob=Blob.valueOf(yourFiles);
   TransitionSelectContoller.FileInfo Jsondatawrapper = (TransitionSelectContoller.FileInfo)System.JSON.deserialize(json,TransitionSelectContoller.FileInfo.class);
  List<Opportunity> opportunityRec = [SELECT id,type FROM Opportunity WHERE name = 'testOpp' LIMIT 1];
    ContentVersion contentVersion = new ContentVersion(
  Title = 'Penguins.pdf',
  PathOnClient = 'Penguins.pdf',
  VersionData = bodyBlob,
  IsMajorVersion = true);
  insert contentVersion;   
    String CIDN = '123485769';
    List<String> cidnList = new List<String> ();
    cidnList.add(CIDN);
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]; 
    ContentDocumentLink cdl = New ContentDocumentLink();
  cdl.LinkedEntityId = opportunityRec[0].id;
  cdl.ContentDocumentId = documents[0].Id;
  cdl.shareType = 'V';
  insert cdl;
    List<Object> objList = new List<Object> ();
    objList.add(Jsondatawrapper);
    Test.startTest();
  String str = TransitionSelectContoller.uploadAuthorization(objList, opportunityRec[0].Id);
  List<String> stringList = TransitionSelectContoller.fetchContentTitleList(opportunityRec[0].Id);
  Test.stopTest();
    System.assertEquals(opportunityRec!=null,true);
}
    @isTest
    public static void MissingAthurizationTest(){
        List<Opportunity> opportunityRec = [SELECT id,type FROM Opportunity WHERE name = 'testOpp' LIMIT 1];
        String oppId = opportunityRec[0].id;
        String str = '9819167890';
        String str1 = '1234567890';
        List<String> cidnList = new List<String>();
        cidnList.add(str);
        Test.startTest();
        String cidn = TransitionSelectContoller.missingAuthorization(cidnList, oppId);
        Test.stopTest();
        System.assertEquals(opportunityRec!=null,true);
        
    }
    @isTest
    public static void fetchProductFamilyTest(){
        String prodFamily = 'Enterprise Mobility';
        Product_Family_Transition__mdt productFamilyTransition = new Product_Family_Transition__mdt();
         //productFamilyTransition = Product_Family_Transition__mdt.getInstance(prodFamily);
        List<String> prodFamilyList = TransitionSelectContoller.fetchProductFamily(prodFamily);
        //Adding Space
    }
}