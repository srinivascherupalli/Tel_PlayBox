/**************************************************************************************************************
Name          : SOWApprovalRequestServiceTest
Created By    : V Ravi Shankar
Created Date  : Mar 20 2020
Description   : EDGE-EDGE-137715 - This is a test class to test the logic of SOWApprovalRequestServiceTest
**************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class SOWApprovalRequestServiceTest {
    
    @testsetup static void setupTestData() {
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration'); 
        customSetting.Name = 'CommercialConfiguration';
        customSetting.External_Id__c = 'CCO_T_1';
        customSetting.Opportunity_Stage__c = 'Develop';
        
        CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Quote'); 
        customSetting1.Name = 'Quote';
        customSetting1.External_Id__c = 'CCO_T_2';
        customSetting1.Opportunity_Stage__c = 'Develop';
        List<CustomConfigurationOptions__c> csList = new List<CustomConfigurationOptions__c>{customSetting, customSetting1};
            INSERT csList;
        
        Marketable_Offer__c moPS = new Marketable_Offer__c(OfferDefinationName__c ='Professional Services',Name = 'Professional Services-MDM Config',Offer_ID__c = 'DMCAT_Offer_000750',type__c = 'Professional Service');
        insert moPS;
        
        cscfga__Product_Configuration__c pd = TestDataFactory.generateProductConfiguration();
        pd.name = 'Professional Services-MDM Config';
        pd.Type__c = 'New'; 
        pd.Marketable_Offer__c = moPS.id;
        pd.cscfga__Product_Family__c='Professional Services-MDM Config';
        update pd;
        
        cscfga__Product_Basket__c basket = [SELECT id,csordtelcoa__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c LIMIT 1];
        Opportunity opp = TestDataFactory.generateOpportunity();
        //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
        opp.AccountId = basket.csordtelcoa__Account__c;
        Update opp;
        //Finished
        basket.cscfga__Opportunity__c=opp.id;
        update basket;
        
        Contact con = new Contact(FirstName = 'Testing',LastName = 'Test',AccountId = basket.csordtelcoa__Account__c);
        insert con;
        
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = con.Id,OpportunityId = opp.Id,IsPrimary = TRUE,Role = 'Decision Maker');
        insert ocr;
        
        Master_Clauses__c mc = new Master_Clauses__c(Offer_Id__c='DMCAT_Offer_000750',Reviewer__c= UserInfo.getUserId(),name='Professional Services-MDM Config');
        insert mc;
        
        List<Clauses__c> clList=new List<Clauses__c>();
        Clauses__c cl1=new Clauses__c(name='Clauses1',description__c='Test1',Sequence__c=1,Included__c=true,Comment__c='Test1');
        clList.add(cl1);
        Clauses__c cl2=new Clauses__c(name='Clauses2',description__c='Test2',Sequence__c=2,Included__c=true,Comment__c='Test2');
        clList.add(cl2);
        insert clList;
        
        Clauses__c clChild=new Clauses__c(name='Clauses1',description__c='Test1',Comment__c='Test1',ParentId__c=cl1.id);
        insert clChild;
        
        List<Clauses_Junction__c> cj_list= new List<Clauses_Junction__c>();
        for(Clauses__c cl:clList){
            Clauses_Junction__c cj= new Clauses_Junction__c(Active__c=true,Items__c=cl.id,MasterItems__c=mc.id);
            cj_list.add(cj);
        }
        insert cj_list;
        CustomButtonSOW cbs = new CustomButtonSOW();
        String sowStr = cbs.performAction(basket.id);       
    }
    
    static testmethod void performActionPositiveTest() {
        map<string,string> resMap = new map<string,string>();
        SOW__c sow = [SELECT Id,Status__c FROM SOW__c LIMIT 1];
        resMap = SOWApprovalRequestService.submitAndProcessApprovalRequest(sow.Id);
        system.assertequals(resMap.get('Result'), 'Success');
    }
    static testmethod void performApprovalRequestedTest() {
        map<string,string> resMap = new map<string,string>();
        SOW__c sow = [SELECT Id,Status__c FROM SOW__c LIMIT 1];
        sow.Status__c = 'Approval Requested';
        update sow;
        resMap = SOWApprovalRequestService.submitAndProcessApprovalRequest(sow.Id);
        system.assertequals(resMap.get('Result'), 'Error');
    }       
    static testmethod void performApprovedTest() {
        map<string,string> resMap = new map<string,string>();
        SOW__c sow = [SELECT Id,Status__c FROM SOW__c LIMIT 1];
        sow.Status__c = 'Approved';
        update sow;
        resMap = SOWApprovalRequestService.submitAndProcessApprovalRequest(sow.Id);
        system.assertequals(resMap.get('Result'), 'Error');
    }     
    static testmethod void performActionNegativeTest() {
        map<string,string> resMap = new map<string,string>();
        resMap = SOWApprovalRequestService.submitAndProcessApprovalRequest('3323444223');
        system.assertequals(resMap.get('Result'), 'Error');
    }   
    static testmethod void fetchsowsTest() {
        SOW__c sow = [SELECT Id,Status__c FROM SOW__c LIMIT 1];
        System.assertNotEquals(SOWApprovalRequestService.fetchsows(sow.id),null);
    }
    static testmethod void getDeliverablestest() {
        SOW_Items__c sow = [SELECT Id FROM SOW_Items__c where Sequence__c=1];
        System.assertNotEquals(SOWApprovalRequestService.getDeliverables(sow.id),null);
    }
}