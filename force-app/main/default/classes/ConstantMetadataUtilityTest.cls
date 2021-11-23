/********************************************************************************
EDGE        -140733
Class       -ConstantMetadataUtilityTest
Description -Test Class for ConstantMetadataUtility class
Author      - Dheeraj Bhatt
********************************************************************************/
@IsTest
public class ConstantMetadataUtilityTest {
    @TestSetup public static void Datasetup(){
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();
        List<Number__c> lstNum= new List<Number__c>();
        TestDataFactory.generateProductConfiguration();
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        cscfga__Product_Configuration__c productConfig  = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%'];    
        productConfig.cscfga__Product_Basket__c=basket.Id;
        update productConfig;
        Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411111111','Y');
        sqRecord.SQ_Type__c='Port in SQ';
        sqRecord.Incumbent_Account_Number__c='3545654656';
        sqRecord.Incumbent_Carrier__c='Vodafone';
        sqRecord.Added_to_CA_form__c=true;
        sqRecord.basket_id__c=basket.id;//DIGI-867
        sqList.add(sqRecord);
        Service_Qualification__c sqRecord1 = TestUtil.createServiceQualification(acc,'61422222222','N');
        sqRecord1.SQ_Type__c='Port in SQ';
        sqRecord1.Added_to_CA_form__c=true;
        sqRecord1.basket_id__c=basket.id;//DIGI-867
        sqList.add(sqRecord1);
        insert sqList;
        Service_Qualification__c sq = [SELECT id FROM Service_Qualification__c WHERE Service_Number__c='61411111111'];
        Service_Qualification__c sq1 = [SELECT id FROM Service_Qualification__c WHERE Service_Number__c='61422222222'];
        Number__c num1 = TestUtil.createNumber('61411111111',basket.id,sq.id);
        num1.Type__c='Port In';
        lstNum.add(num1);
       
        Number__c num2 = TestUtil.createNumber('61422222222',basket.id,sq1.id);
       	insert lstNum;
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthForm.Is_active__c=true;
        custAuthForm.Customer_Authorised_date__c=Date.Today();
        insert  custAuthForm;
       
    }
    /**********************************************************************************************************
EDGE       -140733
Method      -getConstantMetadataUtilityRecordsTest
Description -Test method for ConstantMetadataUtility class getConstantMetadataUtilityRecords method
Author      -Dheeraj Bhatt
************************************************************************************************************/ 
    @IsTest public static void getConstantMetadataUtilityRecordsTest(){
        Test.startTest();
        map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');   
        Test.stopTest();
        system.assert(customMetadataNameValueMap.size() > 0);
    }  
    /*------------------------------------------------------------------------------------
EDGE        -142351
Method      -uploadFileTestTest
Description -Test method for ConstantMetadataUtility class uploadFile method
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------*/   
    @isTest public static void uploadFileTest(){
        account acc = [SELECT id FROM account Limit 1];
        Test.startTest();
         ConstantMetadataUtility.uploadFile(acc.id,'Filename','base64Data','contentType');
        List<ContentDocumentLink> uploadeFileList=[SELECT id from ContentDocumentLink WHERE LinkedEntityId =:acc.id];
        system.assert(!uploadeFileList.isEmpty());
        Test.stopTest();
    }
    //EDGE-147324
    @isTest public static void getbasketdetailsTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c Limit 1];
        Test.startTest();
         List<cscfga__Product_Basket__c> lstbasket = ConstantMetadataUtility.getbasketdetails(basket.id);
        system.assert(!lstbasket.isEmpty());
        Test.stopTest();
    }
    //EDGE-147324
    @isTest public static void getserviceQualificationTest(){
        account acc = [SELECT id FROM account Limit 1];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c Limit 1];
        Test.startTest();
         List<Service_Qualification__c> lstserqual = ConstantMetadataUtility.getserviceQualification(acc.id,basket.id); //DIGI-867
        system.debug('lstserqual>>>'+lstserqual);
        system.assertNotEquals(!lstserqual.isEmpty(), true);
        Test.stopTest();
    }
     @IsTest public static void checkForPartnerUserTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'saleEnt', Email='SalesEnterpriseUnified@test.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
                          UserName='testpermissionsetuser@test.com');
        insert u;
        System.runAs(u)
        {
            Test.startTest();
            Boolean isPartnerUser= ConstantMetadataUtility.checkForPartnerUser();
            system.assertEquals(false, isPartnerUser);
            Test.stopTest();
        }
    }
    @IsTest public static void findPicklistOptionsTest(){
       test.startTest();
      List<ConstantMetadataUtility.picklistWrapper> wrapper=  ConstantMetadataUtility.findPicklistOptions( 'Asset', 'status');
        system.assert(!wrapper.isEmpty());
       test.stopTest();
    }
    public static testMethod void getAllFieldsTest(){
        Test.startTest();
        List<string> fields=ConstantMetadataUtility.getAllFields('Account');
          system.assert(!fields.isEmpty());
        Test.stopTest();
    }
     public static testMethod void getSOQLTest(){
        Test.startTest();
        List<string> fieldList=ConstantMetadataUtility.getAllFields('Account');
         string soql=ConstantMetadataUtility.getSOQL('Account', fieldList, 'Name !=null', 'Name');
          system.assert(string.isNotBlank(soql));
        Test.stopTest();
    }
   public static testmethod void fetchProductandPlanMetadataTest(){
        test.startTest();
         Map<string,List<Plan__mdt>> mapOfProductAndPlan=ConstantMetadataUtility.fetchProductandPlanMetadata();
        system.assert(!mapOfProductAndPlan.isEmpty());
        test.stopTest();
    }
}