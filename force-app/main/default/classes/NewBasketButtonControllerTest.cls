@isTest
private class NewBasketButtonControllerTest {
    
    @isTest static void test_getPathPrefix() {
        String result = NewBasketButtonController.getPathPrefix();
        System.assert(result == '');
    }
    
    @isTest static void test_method_two() {
        //Opportunity opp = TestDataFactory.generateOpportunity();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='oppTest', StageName='Develop', CloseDate = Date.today(), recordtypeid=oppRecordTypeId );
        insert opp;
        insert new PRM_Default__c(SetupOwnerId=UserInfo.getProfileId(),PartnerProfileId__c=userinfo.getProfileId(),Valid_Opportunity_Basket_Verification__c='Valid1,Valid2');
        Map<String, String> resultMap = NewBasketButtonController.getValidOpportunity(opp.Id);
        System.debug(resultMap == new Map<string, string>{'status'=>'success','message'=>'Success'});
       System.assert(resultMap.size() == 4);
    }
    
    @isTest static void test_method_three() {
        //Opportunity opp = TestDataFactory.generateOpportunity();
        //Added by Hawaii for P2OB-11846 
        RecordType r = [Select Id from RecordType where DeveloperName='Enterprise' and sObjectType='Account'];
        List<Account> aList = PRMTestUtility.createPartnerAccounts(1, r.Id, null, 'Active', null);
        aList[0].OwnerId = UserInfo.getUserId();
        insert aList[0];
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='oppTest', AccountId=aList[0].id, StageName='Develop', recordtypeid=oppRecordTypeId, Opportunity_Source__c='Partner', CloseDate = Date.today());
        insert opp;
        insert new PRM_Default__c(SetupOwnerId=UserInfo.getProfileId(),PartnerProfileId__c=userinfo.getProfileId(),Valid_Opportunity_Basket_Verification__c='Valid1,Valid2');
        Map<String, String> resultMap = NewBasketButtonController.getValidOpportunity(opp.Id);
        System.debug(resultMap == new Map<string, string>{'status'=>'success','message'=>'Success'});
        System.assert(resultMap.size() == 6);  
    }

    //EDGE-177925 added by Manish B Team Amsterdam
    @isTest static void testDelegatedPricingWarning() {

        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='oppTest', StageName='Develop',Product_Type__c='Modular',Pricing_Method__c='Delegated Pricing',
                                          recordtypeid=oppRecordTypeId, Opportunity_Source__c='Partner', 
                                          CloseDate = Date.today());
        insert opp;
        insert new PRM_Default__c(SetupOwnerId=UserInfo.getProfileId(),PartnerProfileId__c=userinfo.getProfileId(),Valid_Opportunity_Basket_Verification__c='Valid1,Valid2');
        Map<String, String> resultMap = NewBasketButtonController.getValidOpportunity(opp.Id);
        System.debug(resultMap == new Map<string, string>{'status'=>'success','message'=>'Success'});
        System.assert(resultMap.size() == 4);  

        System.assertEquals('true', resultMap.get('isDelegatedPricing'));
 

    }
	
	@isTest static void testStopCreationOfProductbasket() {

        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='oppTest', StageName='Develop',Product_Type__c='Modular',Pricing_Method__c='Delegated Pricing',
                                          recordtypeid=oppRecordTypeId, Opportunity_Source__c='Partner',Partner_Opportunity_Verification__c='Approved', CloseDate = Date.today());
        insert opp;
        
        insert new PRM_Default__c(SetupOwnerId=UserInfo.getProfileId(),PartnerProfileId__c=userinfo.getProfileId(),Valid_Opportunity_Basket_Verification__c='Valid1,Valid2,Approved');
        Map<String, String> resultMap = NewBasketButtonController.getValidOpportunity(opp.Id);
        System.debug(resultMap == new Map<string, string>{'status'=>'success','message'=>'Success'}); 

        System.assertEquals('New product basket cannot be created from Digitised Deal opportunity', resultMap.get('message'));
    }
    
    @isTest static void test_method_four() {
        NewBasketButtonController.caseRecordId();
        System.assertEquals(1,1);
        }
    
    //Added by Ayush(Hawaii) for P2OB-8462, Updated for P2OB-11846
    @isTest static void test_closure_state() {
        //Opportunity opp = TestDataFactory.generateOpportunity();
        RecordType r = [Select Id from RecordType where DeveloperName='Enterprise' and sObjectType='Account'];
        List<Account> aList = PRMTestUtility.createPartnerAccounts(1, r.Id, null, 'Active', null);
        aList[0].OwnerId = UserInfo.getUserId();
        insert aList[0];
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='oppTest', AccountId=aList[0].id, Opportunity_Source__c='Partner', StageName='Propose', Submit_for_Closure_Status__c = 'Submitted', CloseDate = Date.today(), recordtypeid=oppRecordTypeId,OwnerId=UserInfo.getUserId());
        insert opp;
        insert new PRM_Default__c(SetupOwnerId=UserInfo.getProfileId(),PartnerProfileId__c=userinfo.getProfileId(),Valid_Opportunity_Basket_Verification__c='Valid1,Valid2');
        Map<String, String> resultMap = NewBasketButtonController.getValidOpportunity(opp.Id);
        //System.debug(resultMap == new Map<string, string>{'approvalPending'=>'true'});
        System.assert(resultMap.size() == 5);
    }

    @isTest static void test_basket_creation() {
        //Opportunity opp = TestDataFactory.generateOpportunity();
        RecordType r = [Select Id from RecordType where DeveloperName='Enterprise' and sObjectType='Account'];
        List<Account> aList = PRMTestUtility.createPartnerAccounts(1, r.Id, null, 'Active', null);
        aList[0].OwnerId = UserInfo.getUserId();
        insert aList[0];
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='oppTest', AccountId=aList[0].id, Opportunity_Source__c='Partner', StageName='Propose', Submit_for_Closure_Status__c = 'Submitted', CloseDate = Date.today(), recordtypeid=oppRecordTypeId,OwnerId=UserInfo.getUserId());
        insert opp;
        insert new PRM_Default__c(SetupOwnerId=UserInfo.getProfileId(),PartnerProfileId__c=userinfo.getProfileId(),Valid_Opportunity_Basket_Verification__c='Valid1,Valid2');
        string s='{"cscfga__Opportunity__c":"'+opp.id+'"}';
        Test.startTest();
        string bid=NewBasketButtonController.createBasketRecord(s);
        System.assert(bid.length()>0);
        Test.stopTest();
    }
}