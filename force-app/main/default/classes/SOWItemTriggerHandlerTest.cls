/**************************************************************************************************************
Name          : SOWItemTriggerHandlerTest
Created By    : V Ravi Shankar
Created Date  : Mar 20 2020
Description   : EDGE-137715 - This is a test class to test the logic of SOWItemTriggerHandler
**************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class SOWItemTriggerHandlerTest {
    
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
        
        Marketable_Offer__c moPS = new Marketable_Offer__c(OfferDefinationName__c ='Professional Services',Name = 'Professional Services-MDM Config',Offer_ID__c = 'DMCAT_ProductOffering_000716',type__c = 'Professional Service');
        insert moPS;
        
        cscfga__Product_Configuration__c pd = TestDataFactory.generateProductConfiguration();
        pd.name = 'Professional Services-MDM Config';
        pd.Type__c = 'New'; 
        pd.Marketable_Offer__c = moPS.id;
        pd.cscfga__Product_Family__c='Professional Services-MDM Config';
        update pd;
        
        cscfga__Product_Basket__c basket = [SELECT id,csordtelcoa__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c LIMIT 1];
        Opportunity opp = TestDataFactory.generateOpportunity();
        basket.cscfga__Opportunity__c=opp.id;
        update basket;
        
        Contact con = new Contact(FirstName = 'Testing',LastName = 'Test',AccountId = basket.csordtelcoa__Account__c);
        insert con;
        
        //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
        // Fix Start
        Account acc1 = AccountTestFactory.buildAccount('Test Account') ;
        insert acc1;
        opp.accountId= acc1.id;
        update opp;
        
        AccountContactRelation acr = new AccountContactRelation( AccountId= acc1.id , ContactId = con.id , IsActive = true  );
        insert acr;
        // Fix ends

        
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = con.Id,OpportunityId = opp.Id,IsPrimary = TRUE,Role = 'Decision Maker');
        insert ocr;
        
        Master_Clauses__c mc = new Master_Clauses__c(Offer_Id__c='DMCAT_ProductOffering_000716',Reviewer__c= UserInfo.getUserId(),name='Professional Services-MDM Config');
        insert mc;
        
        List<Clauses__c> clList=new List<Clauses__c>();
        Clauses__c cl1=new Clauses__c(name='Clauses1',description__c='Test1',Sequence__c=1,Included__c=true,Comment__c='Test1');
        clList.add(cl1);
        //Clauses__c cl2=new Clauses__c(name='Clauses2',description__c='Test2',Sequence__c=2,Included__c=true,Comment__c='Test2');
        //clList.add(cl2);
        insert clList;
        
        List<Clauses__c> clListcc=new List<Clauses__c>();
        Clauses__c cl3=new Clauses__c(name='Clausescc1',ParentId__c=clList[0].Id,Comment__c='Test1');
        Clauses__c cl4=new Clauses__c(name='Clausescc1',ParentId__c=clList[0].Id,Comment__c='Test1Ext');
        clListcc.add(cl3);
        clListcc.add(cl4);
        insert clListcc;
        
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
        Id sowItemId = null;
        SOW_Items__c sowItem = [SELECT Id, Comment__c FROM SOW_Items__c WHERE Sequence__c=1 LIMIT 1];
        sowItemId = sowItem.Id;
        sowItem.Comment__c = 'TestNew';     
        update sowItem;
        SOW_Items__c sowItem2 = [SELECT Id, Approval_Required__c FROM SOW_Items__c WHERE Id = :sowItemId];
        system.assertequals(sowItem2.Approval_Required__c, true);
    }
    static testmethod void performActionNegativeTest() {
        map<string,string> resMap = new map<string,string>();
        Id sowItemId = null;
        SOW_Items__c sowItem = [SELECT Id, Comment__c FROM SOW_Items__c WHERE Sequence__c=1 LIMIT 1];
        sowItemId = sowItem.Id;
        sowItem.Comment__c = 'Test1';
        update sowItem;
        SOW_Items__c sowItem2 = [SELECT Id, Approval_Required__c FROM SOW_Items__c WHERE Id = :sowItemId];
        system.assertequals(sowItem2.Approval_Required__c, false);
    }    
}