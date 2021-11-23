/********************************************************
  Class Name                 :   CaseTriggerHandlerTest
  Last modified              :   16/02/2021
  Description for change     :   SFO FDR Test failure 21.02 , Moved Case creation to setup method
  Modified By                :   SFO 
                                 03-06-2021 :Pallavi B (SFO)  : P2OB-14319(Bug)::Sprint 21.07
                                 27-07-2021 : Sravanthi (SFO) : FDR Test Failure fix
*****************************************************/
@isTest
public class CaseTriggerHandlerTest {
    @testSetup
    static void setup()
    {
         Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
         Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; //EDGE-85331 :: =:'Sales - Enterprise'];
        List<user> userList = new List<user>();
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',Phone='+121231231234');
                User sales1 = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser1@testsales.com',Phone='+121231231234');
       User admin = new User(alias = 'standt',email='adminuser@testadmin.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdmin', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pfAdmin.id,
                              timezonesidkey='Australia/Sydney',
                              username='TestingAdmin@TestingAdmin.com');
        userList.add(sales);
        userList.add(sales1);
        userList.add(admin);
        insert userList;
         PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;
         // Given custom permission associated to the mocked PermissionSet
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [SELECT Id FROM CustomPermission
            WHERE DeveloperName = 'Sales_and_Marketing_Permission'][0].Id
            );

            insert sea;
            PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = sales.id,
            PermissionSetId = ps.Id
            );
            insert psa;
        System.runAs(admin){
            Account customerAccount=TestUtil.createAccount('Testacc');
            customerAccount.OwnerId=sales.id;
            
            Account acc=TestUtil.createAccount('Testacc Channel');
            acc.OwnerId=admin.id;
            acc.CIDN__c='484450741';
            acc.OwnerId = sales.id;
        
            list<Account> acclist = new list<Account>{customerAccount,acc};
            Test.startTest();
                insert acclist;
        list<Opportunity> oppList = new list<Opportunity>();
        Opportunity opp =TestUtil.createOpportunity(customerAccount.id);
        opp.Product_Type__c='Modular';
        opp.OwnerId=sales.id;
        opp.Opportunity_Type__c='Disconnected';
        opp.Contract_Attachment_Count__c=1;
        opp.Attachment_Count__c=1;
        oppList.add(opp) ;

        Opportunity opp2 =TestUtil.createOpportunity(customerAccount.id);
        opp2.Name='testopporunity1';
        opp.OwnerId=sales.id;
        opp2.Product_Type__c='Modular';
        opp2.Opportunity_Type__c='Disconnected';
        opp2.Contract_Attachment_Count__c=1;
        opp2.Attachment_Count__c=1;
        oppList.add(opp2) ;
        insert oppList;


        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;

        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();

        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,Description='test,test,test,test',PriceBookEntryID=pbe1.id, quantity=4,Domain__c='UNIFIED COMMUNICATIONS', totalprice=200);
        oliList.add(lineItem1) ;

        OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=opp2.id,Description='test,test,test,test',PriceBookEntryID=pbe1.id, quantity=4,Domain__c='UNIFIED COMMUNICATIONS', totalprice=200);
        oliList.add(lineItem2) ;
        insert oliList;
        Territory2 terCodeParent = TestUtil.createPortfolioTerritories('TestModel', 'S0010');
        insert terCodeParent;
        Portfolio_Code__c portfolioCode =TestUtil.createPortfolioCode('S0010');
        insert portfolioCode;
        
        List<Case> lstCases = new List<Case>();
        
        Case caseObj = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId,customerAccount.id,opplist[1].id,'Parent case');
        caseObj.Reason = 'Other';
        caseobj.Feedback_Closure_Details__c = 'Test Class';
        lstCases.add(caseObj);
        
        Case caseObj1 = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get('SFD Order Request').RecordTypeId,customerAccount.id,opplist[1].id,'Parent case');
        caseObj1.Reason = 'Other';
        caseobj1.Feedback_Closure_Details__c = 'Test Class';
        lstCases.add(caseObj1);
        insert lstCases;
            
        Case caseChildObj = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId,customerAccount.id,opplist[1].id,'This is child case');
        caseChildObj.ParentId = caseObj.id;
        caseChildObj.Reason = 'Other';
        caseChildObj.Feedback_Closure_Details__c = 'Test Class';
        caseChildObj.Salesup_Actual_Amount_Approved__c=50.1234;
        caseChildObj.Customer_requested_Transfer_Amount__c=50.1234;
        insert caseChildObj;   
        Test.stopTest();
            
      }

    }
    /*   Description :   SFO FDR Test failure 21.02 , Moved Case creation to setup method 
         Last modified : 16/02/2021 */
    static testMethod void updateChildCasesTest(){
       Case caseObj = [SELECT status,Salesup_Actual_Amount_Approved__c,Customer_requested_Transfer_Amount__c FROM case WHERE subject = 'Parent case' LIMIT 1];
        
        Test.starttest();
        caseObj.Status = 'Closed';
        caseObj.description = 'Closed';
        CaseTriggerHandler.getChildCasesRecursionCheck=True;
        set<id> caseIds = new set<id>();
        caseIds.add(caseObj.Id);
        CaseTriggerHandler.getChildCases(caseIds);
        //update caseObj;
        System.debug('After updae case: '+caseObj);
        
        test.stoptest();
        Case childCase = [SELECT status,Salesup_Actual_Amount_Approved__c,Customer_requested_Transfer_Amount__c FROM case WHERE subject = 'This is child case'];
        //System.assertEquals('Closed', childCase.Status);
        //System.assertEquals('50.12', String.valueOf(childCase.Salesup_Actual_Amount_Approved__c));
        //System.assertEquals('50.12', String.valueOf(childCase.Customer_requested_Transfer_Amount__c));
    }
    //SFO Team (Sravanthi Velagapudi):EDGE-63998
    //Test method to cover existingCaseCheck Enterprise Pricing recordtype.
    static testMethod void etcWaiverTest(){
        Test.starttest(); 
        List<Opportunity> opplist =[SELECT id,accountId FROM Opportunity ];

        Case caseObj = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get(system.label.Case_RecordType_PricingETCWaiver).RecordTypeId,opplist[0].accountId,opplist[1].id,'ETC case1');
        Case caseObj1 = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get(system.label.Case_RecordType_PricingETCWaiver).RecordTypeId,opplist[0].accountId,opplist[0].id,'ETC case1');
        
            try{
            insert caseObj;
            CaseTriggerHandler.existingCaseCheckRecursion=True;
            caseObj1.OpportunityId__c=opplist[1].id;
            insert caseobj1;

            }
        //To cover Add error method in handler
        catch(DMLException Ex){
            System.assertEquals(Ex.getMessage().contains(System.label.Case_Error_For_Existing_ETC_Case_WIth_Same_Opp),TRUE);
        }

         
        CaseTriggerHandler.existingCaseCheckRecursion=True;
        try{
            caseObj1.OpportunityId__c=opplist[0].id;
            insert caseobj1;
            CaseTriggerHandler.existingCaseCheckRecursion=True;
            caseObj.OpportunityId__c=opplist[0].id;
            update caseObj;
            }
        //To cover Add error method in handler
        catch(DMLException Ex){
            System.assertEquals(Ex.getMessage().contains(System.label.Case_Error_For_Existing_ETC_Case_WIth_Same_Opp),TRUE);
        }
        System.assertEquals(opplist[0].id, caseObj1.OpportunityId__c);
        test.stoptest();
    }
    
    //SFO Team (Sravanthi Velagapudi):EDGE-69764
    //Test method to cover existingCaseCheck Enterprise Pricing recordtype.
    static testMethod void enterprisePricingTest(){
        Test.starttest();
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        List<Opportunity> opplist =[SELECT id,accountId,OwnerId FROM Opportunity ];
        for(Opportunity opp:opplist){
        opp.OwnerId =sales.id;
        }
        update oppList;
        
        system.runas(sales){

        Case caseObj =TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get(system.label.Case_RecordType_EnterprisePricing).RecordTypeId,opplist[1].accountId,opplist[1].id,'Pricing case1');
        caseObj.Description = 'Case for Enterprise Pricing , Description field mandatory.';
        caseObj.Reason = 'Other';
        caseObj.OwnerId=sales.id;

        Case caseObj1 = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get(system.label.Case_RecordType_EnterprisePricing).RecordTypeId,opplist[1].accountId,opplist[1].id,'Pricing case2');
        caseObj1.Description = 'Case for Enterprise Pricing , Description field mandatory.';
        caseobj1.OwnerId=sales.id;
        try{
            insert caseObj;
            caseObj1.OpportunityId__c=opplist[1].id;
            CaseTriggerHandler.existingCaseCheckRecursion=True;
            insert caseobj1;
            }
        //To cover Add error method in handler
        catch(DMLException Ex){
            System.assertEquals(Ex.getMessage().contains(System.label.Case_Error_For_Existing_EP_Case_WIth_Same_Opp), TRUE);
            }
        }
        test.stoptest();
    }

    /*SFO Team:EDGE-88444
    Sprint: 19.08
    Developer: Shaik Mahaboob Subani
    Test method to cover existingCaseCheck Contract Support recordtype
    for throwing an Error if we create a case of contract support record type with same opportunity.**/
    static testMethod void contractsupportTest(){
        Test.starttest();
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        List<Opportunity> opplist =[SELECT id,accountId,OwnerId FROM Opportunity ];
        for(Opportunity opp:opplist){
        opp.OwnerId =sales.id;
        }
        update oppList;


        system.runas(sales){

            
            Case caseObj = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get(system.label.Case_RecordType_ContractSupport).RecordTypeId,opplist[1].accountId,opplist[1].id,'Contract case1');
            caseObj.Reason = 'Other';
            caseObj.OwnerId=sales.id;
            
            Case caseObj1 = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get(system.label.Case_RecordType_ContractSupport).RecordTypeId,opplist[1].accountId,opplist[1].id,'Contract case2');
        caseObj1.Reason = 'Other';
        try{
            insert caseObj;
            CaseTriggerHandler.existingCaseCheckRecursion=True;
            caseObj1.OpportunityId__c=opplist[1].id;
            insert caseobj1;
           }
        //To cover Add error method in handler
        catch(DMLException Ex){
            System.assertEquals(Ex.getMessage().contains(System.label.Case_Error_For_Existing_CS_Case_With_Same_Opp),TRUE);
          }
            
          
        }
        test.stoptest();
        
    }
    
    /*
Team SFO, sprint 20.10, P2OB-6270(Sri)  
Testmethod to cover assignCaseOwner method
Main class is CaseTriggerHandlerTest
*/
    @isTest
    static void assignCaseOwnerTest(){
        String caseSupportType = 'Other Sales Support Requests';
        
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        Portfolio_Code__c portCode = TestUtil.createPortfolioCode('UP001');
        insert portCode;
        
        Account customerAccount=[SELECT id,OwnerId  FROM Account WHERE Name = 'Testacc' AND Customer_Status__c='ACTIVE' LIMIT 1];
        customerAccount.OwnerId=sales.id;
        update customerAccount;
        
        system.runAs(sales){
            Test.startTest();
            Case channelCareCase = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId(),customerAccount.id,null,'Channel Care Case');
            channelCareCase.salesup_Support_Type__c = caseSupportType;
            channelCareCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            channelCareCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            channelCareCase.Transfer_Type__c = Label.Case_Request_Type_Value;
            channelCareCase.Gaining_Approver__c = Sales.Id;
            channelCareCase.salesup_Gaining_Portfolio_Code__c = portCode.name;
            channelCareCase.New_Revenue_Target__c = 2222;
            try{
                insert channelCareCase;
                system.assertEquals([select id, ownerId, Final_Revenue_Target_Updated__c from case where id =:channelCareCase.Id].Final_Revenue_Target_Updated__c, false);
            }
            catch(DMLException ex){
                System.debug('CaseTriggerHandlerTest assignCaseOwnerTest' + Ex.getMessage());
            }
            Test.stopTest();
        }    
    }
    /*SFO Team:P2OB-10544
    Sprint: 20.15
    Developer: Sravanthi
    Test method to cover existingCaseCheck Channel Care recordtype
    for throwing an Error if we create two cases of Channel Care record type with same Account.**/
    static testMethod void channelCarePortfolioManagementTest(){
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        
        Account acc =[SELECT id,OwnerId FROM Account WHERE Name = 'Testacc Channel' LIMIT 1 ];
        acc.OwnerId = sales.id;
        update acc; 
        
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        String caseSupportType = 'Other Sales Support Requests';
        
        system.runas(sales){
            
            Test.starttest();
            
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = acc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Transfer_Type__c = Label.Case_Request_Type_Value;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.salesup_Gaining_Portfolio_Code__c = 'S0010'; 
            objCase.Losing_Approver__c = sales.Id;
            objCase.New_Revenue_Target__c =  0;
            objCase.OwnerId=sales.id;
            Case objCaseDup = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCaseDup.AccountId = acc.Id;
            objCaseDup.RecordTypeId = recordTypeIdChannelCare;
            objCaseDup.Subject ='Portfolio Management Subject';
            objCaseDup.Description ='Portfolio Management Description';
            objCaseDup.salesup_Support_Type__c = caseSupportType;
            objCaseDup.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCaseDup.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCaseDup.Transfer_Type__c = Label.Case_Request_Type_Value;
            objCaseDup.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCaseDup.salesup_Gaining_Portfolio_Code__c = 'S0010'; 
            objCaseDup.Losing_Approver__c = sales.Id;
            objCaseDup.New_Revenue_Target__c =  0;
            objCaseDup.OwnerId=sales.id;
            list<Case> caseList = new List<Case>{objCase,objCaseDup};
            try{
                  Database.Insert(caseList,false);
            }
            catch(DMLException Ex){
                System.assertEquals(Ex.getMessage().contains(System.label.Case_Error_For_Existing_ChannelCare_Case_With_Same_Acc),TRUE);
            }
            
            
                
            list<Case> caseListresult = [SELECT id FROM Case Where AccountId = : acc.Id];
            system.assertEquals(caseListresult.size(), 1);
            test.stoptest();
        }
        
    }
    
/*******************************************************************
@Method Name    :   synchSuggestedRevenueTargetAndHisTrack
@Sprint         :   21.07  & P2OB-14319
@Author         :   SFO Team (Pallavi B)
@CreateDate     :   03/06/2021
@Description    :   Test Method to cover synchSuggestedRevenueTargetAndHisTrack.
@References     :   caseTrigger in before update
@TestCoverage   :   CaseTriggerHandlerTest
*********************************************************************/
    @isTest
    static void synchSuggestedRevenueTargetAndHisTrackTest(){
        String caseSupportType = 'Other Sales Support Requests';
        
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        Portfolio_Code__c portCode = TestUtil.createPortfolioCode('UP001');
        insert portCode;
        
        User sales1 = [Select id,IsActive from user where lastname ='Testing1' and IsActive =true Limit 1 ];
        Portfolio_Code__c portCode1 = TestUtil.createPortfolioCode('UP002');
        insert portCode1;
        
        Account customerAccount=[SELECT id,OwnerId  FROM Account WHERE Name = 'Testacc' AND Customer_Status__c='ACTIVE' LIMIT 1];
        customerAccount.OwnerId=sales.id;
        update customerAccount;
        
        system.runAs(sales){
            Test.startTest();
            Case channelCareCase = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId(),customerAccount.id,null,'Channel Care Case');
            channelCareCase.salesup_Support_Type__c = caseSupportType;
            channelCareCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            channelCareCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            channelCareCase.Transfer_Type__c = Label.Case_Request_Type_Value;
            channelCareCase.Gaining_Approver__c = Sales.Id;
            channelCareCase.Status ='In Progress';
            channelCareCase.salesup_Gaining_Portfolio_Code__c = portCode.name;
                insert channelCareCase;
            try{
                channelCareCase.Losing_Approver__c = Sales1.Id;
                update channelCareCase;
                system.assertEquals([select id, ownerId, New_Revenue_Target__c from case where id =:channelCareCase.Id].New_Revenue_Target__c, [select id, ownerId, Current_Revenue_Targets__c from case where id =:channelCareCase.Id].Current_Revenue_Targets__c);
            }
            catch(DMLException ex){
                System.debug('CaseTriggerHandlerTest synchSuggestedRevenueTargetAndHisTrackTest' + Ex.getMessage());
            }
            Test.stopTest();
        }    
    }
}
//comment for code coverage