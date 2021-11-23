/*******************************************************************
@Class Name		:SFO_PortfolioManagementCaseHelperTest
@Sprint 		:20.09  & P2OB-6272 , 20.13 && P2OB-9317 && 20.14 P2OB-6280
@Author			:SFO Team (Pallavi B,Sravanthi)
@CreateDate		: 09/07/2020
@description	: Test class for SFO_PortfolioManagementCaseHelper.
@Last Modified	: 07/01/2020 21.01 by Sri, Team SFO
as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified	: 20/09/2021 21.13 by Pallavi B Team SFO,Test class fix
*********************************************************************/
@isTest
public class SFO_PortfolioManagementCaseHelperTest {
    list<Account> acclist =new list<Account>();
    @testSetup
    public static void createData(){
        //User Creation
        List<user> userList = new List<user>();
        User admin = TestUtil.createUser('admin@test.com.LaTest','AdminLA',Label.Profile_SystemAdmin);
        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA',Label.Profile_SalesEnterprise);
        sales.Phone = '0444444444';
        admin.Phone = '0444444444';
        userList.add(sales);
        userList.add(admin);
        insert userList;
        
        
        //Accounts with heirarchy Creation
        System.runAs(admin){
            Test.startTest(); //Added as part of Test class fix Sprint 21.13
            insert new Phoenix_Configurations__c(PFMFinanceQueueId__c =sales.id ,PFMCDMQueueId__c =sales.id);
            list<Account> acclist =new list<Account>();
            for(integer i=0;i<10;i++){
                Account customerAccount=TestUtil.createAccount('Testacc'+i);
                customerAccount.OwnerId=admin.id;
                customerAccount.CIDN__c='48445074'+i;
                customerAccount.OwnerId = sales.id;
                if(i!=0){
                    customerAccount.Parent_CIDN__c='48445074'+(i-1);
                    customerAccount.Ultimate_Parent_CIDN__c = '484450740';
                }
                
                acclist.add(customerAccount);
            }
            for(integer i=0;i<10;i++){
                Account customerAccount=TestUtil.createAccount('OtherTestacc'+i);
                customerAccount.OwnerId=admin.id;
                customerAccount.CIDN__c='48592641'+i;
                customerAccount.OwnerId = sales.id;
                if(i!=0){
                    customerAccount.Parent_CIDN__c='48592641'+(i-1);
                    customerAccount.Ultimate_Parent_CIDN__c = '485926410';  
                }
                
                acclist.add(customerAccount);
            }
            insert acclist;
            
            
            Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450745' LIMIT 1];
            Account newParentAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926415' LIMIT 1];
            Account newAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926412' LIMIT 1];
            Account newAcc1 = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450740' LIMIT 1];
            newParentAcc.Portfolio_Code__c = 'N0010';
            objAcc.Portfolio_Code__c = 'M0010';
            newAcc.Portfolio_Code__c = 'M0010';
            newAcc1.Portfolio_Code__c = 'N0010';
            list<Account> acclist2 =new list<Account>{newParentAcc,objAcc,newAcc,newAcc1};
                update acclist2;
            
            //Portfolio Code Creation
            List<Portfolio_Code__c> portcodelist = new List<Portfolio_Code__c>();
            Portfolio_Code__c portfolioCode =TestUtil.createPortfolioCode('AB010');
            portfolioCode.Revenue_Target__c = 3000.0;
            portcodelist.add(portfolioCode);
            Portfolio_Code__c portfolioCode1 =TestUtil.createPortfolioCode('S0010');
            portcodelist.add(portfolioCode1);
            Portfolio_Code__c portfolioCode2 =TestUtil.createPortfolioCode('T0010');
            portcodelist.add(portfolioCode2);
            Portfolio_Code__c portfolioCode3 =TestUtil.createPortfolioCode('M0010');
            portfolioCode3.Revenue_Target__c = 3000.0;
            portcodelist.add(portfolioCode3);
            Portfolio_Code__c portfolioCode4 =TestUtil.createPortfolioCode('N0010');
            portfolioCode4.Revenue_Target__c = 6000.0;
            portcodelist.add(portfolioCode4);
            
            insert portcodelist;
            
            //Territory insertions
            List<Territory2> territoryInsList = new List<Territory2>();
            Territory2 terCodeUParent = TestUtil.createPortfolioTerritories('TestModel', 'N0010');
            territoryInsList.add(terCodeUParent);
            Territory2 terCode1 = TestUtil.createPortfolioTerritories('TestModel', 'M0010');
            territoryInsList.add(terCode1);
            Territory2 terCodeParent = TestUtil.createPortfolioTerritories('TestModel', 'S0010');
            territoryInsList.add(terCodeParent);
            Territory2 terCodeChild = TestUtil.createPortfolioTerritories('TestModel', 'T0010');
            territoryInsList.add(terCodeChild);
            insert territoryInsList;
            //Territory Heirarchy changes
            List<Territory2> territoryUpList = new List<Territory2>();
            terCodeParent.ParentTerritory2Id = terCodeUParent.Id;
            territoryUpList.add(terCodeParent);            
            terCodeChild.ParentTerritory2Id = terCodeParent.Id;
            territoryUpList.add(terCodeChild);            
            update territoryUpList;
            
            //Assign owner for the created Territory
            UserTerritory2Association user2Territory1= TestUtil.createUserTerritory2Association(sales.Id,terCodeUParent.id,'Owner');
            List<UserTerritory2Association> listUser2Territory = new List<UserTerritory2Association>{user2Territory1};
                insert listUser2Territory;
                Test.stopTest();  //Added as part of Test class fix Sprint 21.13
        }
    }
    
    /*
Team SFO, sprint 20.11, P2OB-8416, 20.13 && P2OB-9317
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with request type as Child to Child, with losing account and gaining account from two different heirarchies. 
Main class is SFO_PortfolioManagementCaseHelper
*/
    static testMethod void requestTypeMoveAccountsSCN1(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450745' LIMIT 1];
        Account newParentAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926415' LIMIT 1];
        UserTerritory2Association terrUser1 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Subsidiary_to_subsidiary;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.New_Parent_Account__c = newParentAcc.Id;  // New Parent Account from different Hierarchy
            objCase.New_Revenue_Target__c = 1000;
            objCase.salesup_Gaining_Portfolio_Code__c = newParentAcc.Portfolio_Code__c; 
            objCase.Losing_Approver__c = terrUser1.UserId;
            insert objCase;
            SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod(new List<id> {objCase.id});
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c,Churn_Propensity_New__c FROM Account WHERE id = :objAcc.id LIMIT 1];
            Account casechildacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.Parent_CIDN__c = '484450746' LIMIT 1];
            Portfolio_Code__c portCode = [select id, name, Revenue_Target__c from Portfolio_Code__c where name = : objCase.salesup_Gaining_Portfolio_Code__c];
            system.assertEquals(caseacc.Parent_CIDN__c,newParentAcc.CIDN__c,'requestTypeMoveAccounts Parent Account Parent_CIDN__c is wrong');
            system.assertEquals(caseacc.Ultimate_Parent_CIDN__c,newParentAcc.Ultimate_Parent_CIDN__c,'requestTypeMoveAccounts Parent Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(caseacc.Portfolio_Code__c,newParentAcc.Portfolio_Code__c,'requestTypeMoveAccounts Parent Account Portfolio_Code__c is wrong');
            system.assertEquals(casechildacc.Ultimate_Parent_CIDN__c,newParentAcc.Ultimate_Parent_CIDN__c,'requestTypeMoveAccounts child  Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(portCode.Revenue_Target__c,7000,'requestTypeMoveAccounts revenue update didnt happen');  
            
        }
        test.stopTest();
    }
    /*
Team SFO, sprint 20.11, P2OB-8416 , 20.13 && P2OB-9317
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with request type as Child to child, with losing account and gaining account from two different heirarchies. 
Main class is SFO_PortfolioManagementCaseHelper
*/
    static testMethod void requestTypeMoveAccountsSCN2(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450743' LIMIT 1];
        Account newParentAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926412' LIMIT 1];
        UserTerritory2Association terrUser2 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Subsidiary_to_subsidiary;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.New_Parent_Account__c = newParentAcc.Id;  // New Parent Account from different Hierarchy
            objCase.salesup_Gaining_Portfolio_Code__c =newParentAcc.Portfolio_Code__c ;
            objCase.New_Revenue_Target__c = 1000;
            objCase.Losing_Approver__c = terrUser2.UserId;
            insert objCase;
            SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod(new List<id> {objCase.id});
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE id = :objAcc.id LIMIT 1];
            Account casechildacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.Parent_CIDN__c = '484450745' LIMIT 1];
            system.assertEquals(caseacc.Parent_CIDN__c,newParentAcc.CIDN__c,'requestTypeMoveAccounts Parent Account CIDN is wrong');
            system.assertEquals(caseacc.Ultimate_Parent_CIDN__c,newParentAcc.Ultimate_Parent_CIDN__c,'requestTypeMoveAccounts Parent Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(caseacc.Portfolio_Code__c,newParentAcc.Portfolio_Code__c,'requestTypeMoveAccounts Parent Account Portfolio_Code__c is wrong');
            system.assertEquals(casechildacc.Ultimate_Parent_CIDN__c,newParentAcc.Ultimate_Parent_CIDN__c,'requestTypeMoveAccounts Parent Account Ultimate_Parent_CIDN__c is wrong');    
        }
        test.stopTest();
    }
    /*
Team SFO, sprint 20.11, P2OB-8414
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with request type as Make Subsidiary Account Ultimate.
Main class is SFO_PortfolioManagementCaseHelper
P2OB-6280 Relevant Changes as Number of accounts in heirarchy reduced 
*/
    static testMethod void requestTypemakeSubsAccountUltSCN1(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926414' LIMIT 1];
        
        UserTerritory2Association terrUser3 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Subsidiary_to_Ultimate;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.salesup_Gaining_Portfolio_Code__c = 'N0010';
            objCase.New_Revenue_Target__c =  0;
            objCase.Losing_Approver__c = terrUser3.UserId;
            insert objCase;
            SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod(new List<id> {objCase.id});
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE id = :objAcc.id LIMIT 1];
            Account casechildacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.Parent_CIDN__c = '485926416' LIMIT 1];
            system.assertEquals(caseacc.Parent_CIDN__c,null,'requestTypemakeSubsAccountUlt Parent Account CIDN is wrong');
            system.assertEquals(caseacc.Ultimate_Parent_CIDN__c,null,'requestTypemakeSubsAccountUlt Parent Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(casechildacc.Ultimate_Parent_CIDN__c,objAcc.CIDN__c,'requestTypemakeSubsAccountUlt child Account Ultimate_Parent_CIDN__c is wrong');
        }
        test.stopTest();
    }
    /*
Team SFO, sprint 20.11, P2OB-8414
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with request type as Make Subsidiary Account Ultimate. 
Main class is SFO_PortfolioManagementCaseHelper
P2OB-6280 Relevant Changes as Number of accounts in heirarchy reduced 
*/
    static testMethod void requestTypemakeSubsAccountUltSCN2(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450745' LIMIT 1];
        UserTerritory2Association terrUser4 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Subsidiary_to_Ultimate;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.Losing_Approver__c = terrUser4.UserId;
            objCase.New_Revenue_Target__c =  0;
            insert objCase;
            SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod(new List<id> {objCase.id});
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE id = :objAcc.id LIMIT 1];
            Account childAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.Parent_CIDN__c = '484450746' LIMIT 1];
            list<Account> casechildacclist = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Ultimate_Parent_CIDN__c = :caseacc.CIDN__c LIMIT 15];
            system.assertEquals(caseacc.Parent_CIDN__c,null,'requestTypemakeSubsAccountUlt parent Account Parent_CIDN__c is wrong');
            system.assertEquals(caseacc.Ultimate_Parent_CIDN__c,null,'requestTypemakeSubsAccountUlt parent Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(childAcc.Ultimate_Parent_CIDN__c,objAcc.CIDN__c,'requestTypemakeSubsAccountUlt child Account Ultimate_Parent_CIDN__c is wrong');  
            system.assertEquals(casechildacclist.size(),4,'requestTypemakeSubsAccountUlt child accounts reparenting to new ultimate is wrong');  
        }
        test.stopTest();
    } 
    /*
Team SFO, sprint 20.11, P2OB-8415
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with request type as Make Ultimate Account Subsidiary. 
Main class is SFO_PortfolioManagementCaseHelper
P2OB-6280 Relevant Changes as Number of accounts in heirarchy reduced 
*/
    static testMethod void requestTypemakeUltAccountSubSCN1(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450740' LIMIT 1];
        Account newParentAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926412' LIMIT 1];
        UserTerritory2Association terrUser5 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Ultimate_to_Subsidiary;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.New_Parent_Account__c = newParentAcc.Id;  // New Parent Account from different Hierarchy
            objCase.salesup_Gaining_Portfolio_Code__c = 'N0010'; 
            objCase.Losing_Approver__c = terrUser5.UserId;
            objCase.New_Revenue_Target__c =  0;
            insert objCase;
            SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod(new List<id> {objCase.id});
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE id = :objAcc.id LIMIT 1];
            Account childAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.Parent_CIDN__c = '484450746' LIMIT 1];
            list<Account> casechildacclist = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Ultimate_Parent_CIDN__c = :newParentAcc.Ultimate_Parent_CIDN__c LIMIT 40];
            system.assertEquals(caseacc.Parent_CIDN__c,newParentAcc.CIDN__c,'requestTypemakeUltAccountSub parent Account Parent_CIDN__c is wrong');
            system.assertEquals(caseacc.Ultimate_Parent_CIDN__c,newParentAcc.Ultimate_Parent_CIDN__c,'requestTypemakeUltAccountSub parent Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(childAcc.Ultimate_Parent_CIDN__c,newParentAcc.Ultimate_Parent_CIDN__c,'requestTypemakeUltAccountSub Child Account Ultimate_Parent_CIDN__c is wrong');  
            system.assertEquals(casechildacclist.size(),19,'requestTypemakeUltAccountSub child accounts reparenting to new ultimate is wrong');             
        }
        test.stopTest();
    } 
    /*
Team SFO, sprint 20.11, P2OB-8415
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with request type as Make Ultimate Account Subsidiary. 
Main class is SFO_PortfolioManagementCaseHelper
P2OB-6280 Relevant Changes as Number of accounts in heirarchy reduced 
*/
    static testMethod void requestTypemakeUltAccountSubSCN2(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926410' LIMIT 1];
        Account newParentAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450749' LIMIT 1];
        UserTerritory2Association terrUser6 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Ultimate_to_Subsidiary;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.New_Parent_Account__c = newParentAcc.Id;  // New Parent Account from different Hierarchy
            objCase.salesup_Gaining_Portfolio_Code__c = 'N0010'; 
            objCase.Losing_Approver__c = terrUser6.UserId;
            objCase.New_Revenue_Target__c =  0;
            insert objCase;
            SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod(new List<id> {objCase.id});
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE id = :objAcc.id LIMIT 1];
            Account childAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.Parent_CIDN__c = '485926416' LIMIT 1];
            list<Account> casechildacclist = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Ultimate_Parent_CIDN__c = :newParentAcc.Ultimate_Parent_CIDN__c LIMIT 40];
            system.assertEquals(caseacc.Parent_CIDN__c,newParentAcc.CIDN__c,'requestTypemakeUltAccountSub parent Account Parent_CIDN__c is wrong');
            system.assertEquals(caseacc.Ultimate_Parent_CIDN__c,newParentAcc.Ultimate_Parent_CIDN__c,'requestTypemakeUltAccountSub parent Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(childAcc.Ultimate_Parent_CIDN__c,newParentAcc.Ultimate_Parent_CIDN__c,'requestTypemakeUltAccountSub child Account Ultimate_Parent_CIDN__c is wrong');  
            system.assertEquals(casechildacclist.size(),19,'requestTypemakeUltAccountSub child accounts reparenting to new ultimate is wrong');          
        }
        test.stopTest();
    }
    /*
Team SFO, sprint 20.12, P2OB-8608
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with Request Type as 'Move Accounts' , Business Unit for Transferas= 'Telstra Enterprise to Small Business' 
Main class is SFO_PortfolioManagementCaseHelper
P2OB-6280 Relevant Changes as Number of accounts in heirarchy reduced 
*/
    static testMethod void requestTypeMoveAccountsENTtoSB(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,APTPS_Tier__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926410' LIMIT 1];
        UserTerritory2Association terrUser7 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Move_Accounts;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Telstra_Enterprise_to_Small_Business;
            objCase.salesup_Gaining_Portfolio_Code__c = 'SUMGD';
            objCase.New_Revenue_Target__c =  0;
            objCase.Losing_Approver__c = terrUser7.UserId;
            insert objCase;
            SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod(new List<id> {objCase.id});
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c,APTPS_Tier__c FROM Account WHERE id = :objAcc.id LIMIT 1];
            Account childAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c,APTPS_Tier__c FROM Account WHERE Account.Parent_CIDN__c = '485926416' LIMIT 1];
            list<Account> casechildacclist = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Ultimate_Parent_CIDN__c = :caseacc.CIDN__c LIMIT 40];
            system.assertEquals(caseacc.Parent_CIDN__c,null,'requestTypeMoveAccountsENTtoSB parent Account Parent_CIDN__c is wrong');
            system.assertEquals(caseacc.Ultimate_Parent_CIDN__c,null,'requestTypeMoveAccountsENTtoSB parent Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(childAcc.Ultimate_Parent_CIDN__c,caseacc.CIDN__c,'requestTypeMoveAccountsENTtoSB child Account Ultimate_Parent_CIDN__c is wrong');   
            system.assertEquals(caseacc.APTPS_Tier__c,null,'requestTypeMoveAccountsENTtoSB parent Account APTPS_Tier__c is wrong');   
            system.assertEquals(childAcc.APTPS_Tier__c,null,'requestTypeMoveAccountsENTtoSB child Account APTPS_Tier__c is wrong');  
            system.assertEquals(childAcc.Portfolio_Code__c,'SUMGD','requestTypeMoveAccountsENTtoSB child Account Portfolio_Code__c is wrong');
        }
        test.stopTest();
    }
    /*
Team SFO, sprint 20.12, P2OB-8608
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with Request Type as 'Move Accounts' , Business Unit for Transferas= 'Telstra Enterprise to Small Business' 
Main class is SFO_PortfolioManagementCaseHelper
*/
    static testMethod void requestTypeMoveAccountsTargetsENTtoSB(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926415' LIMIT 1];
        UserTerritory2Association terrUser8 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        Portfolio_Code__c objPortFolioCodes = [select id,name,Revenue_Target__c from Portfolio_Code__c WHERE Name = : objAcc.Portfolio_Code__c limit 1 ];
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Move_Accounts;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Telstra_Enterprise_to_Small_Business;
            objCase.salesup_Gaining_Portfolio_Code__c = 'SUMGD';
            objCase.New_Revenue_Target__c = 1000;
            objCase.Losing_Approver__c = terrUser8.UserId;
            insert objCase;
            SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod(new List<id> {objCase.id});
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c,APTPS_Tier__c FROM Account WHERE id = :objAcc.id LIMIT 1];
            Account childAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c,APTPS_Tier__c FROM Account WHERE Account.Parent_CIDN__c = '485926416' LIMIT 1];
            list<Account> casechildacclist = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Ultimate_Parent_CIDN__c = :caseacc.CIDN__c LIMIT 40];
            Portfolio_Code__c portCodeold = [select id, name, Revenue_Target__c from Portfolio_Code__c where name = : objAcc.Portfolio_Code__c LIMIT 1];
            system.assertNotEquals(caseacc.Parent_CIDN__c,objAcc.Parent_CIDN__c,'requestTypeMoveAccountsENTtoSB parent Account Parent_CIDN__c is wrong');
            system.assertNotEquals(caseacc.Ultimate_Parent_CIDN__c,objAcc.Ultimate_Parent_CIDN__c,'requestTypeMoveAccountsENTtoSB parent Account Ultimate_Parent_CIDN__c is wrong');
            system.assertEquals(childAcc.Ultimate_Parent_CIDN__c,caseacc.CIDN__c,'requestTypeMoveAccountsENTtoSB child Account Ultimate_Parent_CIDN__c is wrong'); 
            system.assertEquals(caseacc.APTPS_Tier__c,null,'requestTypeMoveAccountsENTtoSB parent Account APTPS_Tier__c is wrong');   
            system.assertEquals(childAcc.APTPS_Tier__c,null,'requestTypeMoveAccountsENTtoSB child Account APTPS_Tier__c is wrong');  
            system.assertEquals(childAcc.Portfolio_Code__c,'SUMGD','requestTypeMoveAccountsENTtoSB child Account Portfolio_Code__c is wrong'); 
            system.assertEquals(portCodeold.Revenue_Target__c,objPortFolioCodes.Revenue_Target__c-1000,'requestTypeMoveAccountsENTtoSB revenue update failed');
        }
        test.stopTest();
    }
    /*
Team SFO, sprint 20.12, P2OB-7201
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with Request Type as 'Move Accounts' , Business Unit for Transferas= 'Small Business to Telstra Enterprise' 
Main class is SFO_PortfolioManagementCaseHelper
*/
    static testMethod void requestTypeMoveAccountsTargetsSBtoENT(){
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        UserTerritory2Association terrUser9 = [Select Id,UserId from UserTerritory2Association limit 1];
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        String caseSupportType = 'Other Sales Support Requests';
        Portfolio_Code__c objPortFolioCodes = [select id,name,Revenue_Target__c from Portfolio_Code__c WHERE Name = 'N0010' limit 1 ];
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Ownership_Code__c = 'KGB';
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Move_Accounts;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Small_Business_to_Telstra_Enterprise;
            objCase.salesup_Gaining_Portfolio_Code__c = 'N0010';
            objCase.New_Revenue_Target__c = 1000;
            objCase.Losing_Approver__c = terrUser9.UserId;
            insert objCase;
            
            Portfolio_Code__c portRevAfter = [select id,name,Revenue_Target__c from Portfolio_Code__c WHERE Name = 'N0010' limit 1 ];
            system.assertEquals(objPortFolioCodes.Revenue_Target__c+1000,portRevAfter.Revenue_Target__c,'requestTypeMoveAccountsSBtoENT revenue target failed');  
        }
    }
    
    /*
Team SFO, sprint 20.13, P2OB-9015
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with Request Type as 'Move Account to Insolvency' , Business Unit for Transferas= 'Within Telstra Enterprise' 
Main class is SFO_PortfolioManagementCaseHelper
*/
    static testMethod void requestTypeMoveAccountstoInsolvency(){
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450740' LIMIT 1];
        UserTerritory2Association terrUser9 = [Select Id,UserId from UserTerritory2Association limit 1];
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        String caseSupportType = 'Other Sales Support Requests';
        Portfolio_Code__c objPortFolioCodes = [select id,name,Revenue_Target__c from Portfolio_Code__c WHERE Name = : objAcc.Portfolio_Code__c limit 1 ];
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.AccountId =objAcc.id;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Move_Account_to_Insolvency;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.salesup_Gaining_Portfolio_Code__c = 'SZA01';
            objCase.New_Revenue_Target__c = 1000;
            objCase.Losing_Approver__c = terrUser9.UserId;
            objCase.Ownership_Code__c ='KGB';
            insert objCase;
            Account newAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450740' LIMIT 1];
            Portfolio_Code__c portRevAfter = [select id,name,Revenue_Target__c from Portfolio_Code__c WHERE Name = 'N0010' limit 1 ];
            system.assertEquals(objPortFolioCodes.Revenue_Target__c-1000,portRevAfter.Revenue_Target__c,'requestTypeMoveAccounttoInsolvency Revenue_Target__c update failed');
            system.assertEquals(newAcc.Portfolio_Code__c , 'SZA01','requestTypeMoveAccounttoInsolvency parent Account portcode update failed'); 
        }
        test.stopTest();
    }
    /*
Team SFO, sprint 20.13
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with Request Type as 'Update account portfolio code' , Business Unit for Transferas= 'with in Telstra Enterprise' 
Main class is SFO_PortfolioManagementCaseHelper
*/
    static testMethod void requestTypeUpdateAccountPortcode(){
        
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,APTPS_Tier__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926410' LIMIT 1];
        UserTerritory2Association terrUser7 = [Select Id,UserId from UserTerritory2Association limit 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Request_Type_Value;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.salesup_Gaining_Portfolio_Code__c = 'S0010'; 
            objCase.Losing_Approver__c = terrUser7.UserId;
            objCase.New_Revenue_Target__c =  0;
            objCase.Ownership_Code__c='KGD';
            insert objCase;
            Account caseacc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c,APTPS_Tier__c FROM Account WHERE id = :objAcc.id LIMIT 1];     
            system.assertEquals(caseacc.Portfolio_Code__c,'S0010','requestTypeUpdateAccountPortcode  Account Portfolio_Code__c is wrong');
        }
        test.stopTest();
    }
    /*
Team SFO, sprint 20.14, P2OB-6280
Testmethod to cover for portfolioManagementInvocableMethod (Invocable method) and all methods refered through this.
Channel Care Cases for porfolio management with Request Type as 'Move Account out of Insolvency' , Business Unit for Transferas= 'Within Telstra Enterprise' 
Main class is SFO_PortfolioManagementCaseHelper
*/
    static testMethod void requestTypeMoveAccountsOutOfInsolvency(){
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450740' LIMIT 1];
        UserTerritory2Association terrUser9 = [Select Id,UserId from UserTerritory2Association limit 1];
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        String caseSupportType = 'Other Sales Support Requests';
        Portfolio_Code__c objPortFolioCodes = [select id,name,Revenue_Target__c from Portfolio_Code__c WHERE Name = 'M0010' limit 1 ];
        test.startTest();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.AccountId =objAcc.id;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = Label.Case_Status_Approved;
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Move_Account_Out_of_Insolvency;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.salesup_Gaining_Portfolio_Code__c = 'M0010';
            objCase.New_Revenue_Target__c = 1000;
            objCase.Losing_Approver__c = terrUser9.UserId;
            objCase.Ownership_Code__c ='KGB';
            insert objCase;
            Account newAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450740' LIMIT 1];
            Portfolio_Code__c portRevAfter = [select id,name,Revenue_Target__c from Portfolio_Code__c WHERE Name = 'M0010' limit 1 ];
            system.assertEquals(objPortFolioCodes.Revenue_Target__c+1000,portRevAfter.Revenue_Target__c,'requestTypeMoveAccountsOutOfInsolvency Revenue_Target__c update failed');
            system.assertEquals(newAcc.Portfolio_Code__c , 'M0010','requestTypeMoveAccountsOutOfInsolvency parent Account portcode update failed'); 
        }
        test.stopTest();
    }
}