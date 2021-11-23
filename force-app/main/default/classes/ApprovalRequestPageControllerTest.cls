/*******************************************************************
@Class Name     :   ApprovalRequestPageControllerTest
@Sprint         :   20.13 (P2OB-9282)
@Author         :   Sri,Amar (Team SFO)
@CreateDate     :   09/21/2020
@Description    :   Get the parentId/targetId for the current approval request/processinstanceworkitem Test Class
@References     :   EditRelatedRecordFromApprovalRequestPage Aura Component
@TestCoverage   :   ApprovalRequestPageController
*********************************************************************/

@isTest
public class ApprovalRequestPageControllerTest {
    @testSetup
    public static void createData(){
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
            
            list<Account> acclist =new list<Account>();
            for(integer i=0;i<2;i++){
                Account customerAccount=TestUtil.createAccount('Testacc'+i);
                customerAccount.OwnerId=admin.id;
                customerAccount.CIDN__c='48445074'+i;
                customerAccount.OwnerId = sales.id;
                customerAccount.Total_Revenue_Month_1__c = 5000;
                if(i!=0){
                    customerAccount.Parent_CIDN__c='48445074'+(i-1);
                    customerAccount.Ultimate_Parent_CIDN__c = '484450740';
                }
                
                acclist.add(customerAccount);
            }
            for(integer i=0;i<2;i++){
                Account customerAccount=TestUtil.createAccount('OtherTestacc'+i);
                customerAccount.OwnerId=admin.id;
                customerAccount.CIDN__c='48592641'+i;
                customerAccount.OwnerId = sales.id;
                customerAccount.Total_Revenue_Month_1__c = 5000;
                if(i!=0){
                    customerAccount.Parent_CIDN__c='48592641'+(i-1);
                    customerAccount.Ultimate_Parent_CIDN__c = '485926410';  
                }
                
                acclist.add(customerAccount);
            }
            Test.startTest();
            insert acclist;
            
            list<Account> acclist2 =new list<Account>();
            Account objAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450741' LIMIT 1];
            Account newParentAcc = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926411' LIMIT 1];
            newParentAcc.Portfolio_Code__c = 'N0010';
            objAcc.Portfolio_Code__c = 'M0010';
            acclist2.add(newParentAcc);
            acclist2.add(objAcc);
            update acclist2;
            Test.stopTest();
        }
    }
    //Sprint 20.13. This Method Covers getRelatedRecord Method in ApprovalRequestPageController
    static testMethod void updateFinalRevenueValueTest(){
		
        User sales = [Select id,IsActive from user where UserName ='sales@test.com.LaTest' and IsActive =true Limit 1 ];
        
        Account objAcc1 = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Total_Revenue_Month_1__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '484450741' LIMIT 1];
        
        Account newParentAcc1 = [SELECT id,Parent_CIDN__c,CIDN__c,Ultimate_Parent_CIDN__c,Portfolio_Code__c FROM Account WHERE Account.CIDN__c = '485926411' LIMIT 1];
        
        String caseSupportType = 'Other Sales Support Requests';
        id recordTypeIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
        System.runAs(sales){
            Case objCase = TestUtil.createCaseEnterprise(recordTypeIdChannelCare,null,null,'Channel Care Case');
            objCase.AccountId = objAcc1.Id;
            objCase.RecordTypeId = recordTypeIdChannelCare;
            objCase.Subject ='Portfolio Management Subject';
            objCase.Description ='Portfolio Management Description';
            objCase.salesup_Support_Type__c = caseSupportType;
            objCase.srvsup_Categories__c = Label.salesup_Miscellaneous_Category;
            objCase.salesup_Work_Required__c = Label.WorkRequired_PortfolioManagement;
            objCase.Status = 'new';
            objCase.Transfer_Type__c = Label.Case_Transfer_Type_Subsidiary_to_subsidiary;
            objCase.Business_Unit_for_Transfer__c = Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise;
            objCase.New_Parent_Account__c = newParentAcc1.Id;  // New Parent Account from different Hierarchy
            objCase.New_Revenue_Target__c = 1000;
            objCase.Losing_Approver__c = sales.id;
            objCase.Gaining_Approver__c = sales.id;
            objCase.salesup_Gaining_Portfolio_Code__c = newParentAcc1.Portfolio_Code__c; 
            insert objCase;
			
            system.assertEquals(objCase.Subject,'Portfolio Management Subject');
			
            case caseinfo = [select id, Current_Revenue_Targets__c,salesup_Work_Required__c,status,Losing_Approver__c,New_Revenue_Target__c,owner.id, recordtype.name from case where id = :objCase.id LIMIT 1];
            caseinfo.ownerid = sales.id;
            update caseinfo;
            
            //Submitting for approval.
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(objCase.id);
            try{
                test.starttest();
                Approval.ProcessResult result = Approval.process(app);
                ProcessInstance pi = [SELECT Id,TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :objCase.Id LIMIT 1];
                ProcessInstanceWorkitem proInstWorkitemin = [Select Id, ProcessInstanceId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstanceId = :pi.id LIMIT 1];
                
			    case resultCase1 = ApprovalRequestPageController.getRelatedRecord(proInstWorkitemin.id);
			    system.assertNotEquals(resultCase1,null);
			
                ApprovalRequestPageController.getRelatedRecord(null);
                ApprovalRequestPageController.getRelatedRecord(objAcc1.id);
                
                string appId = proInstWorkitemin.id;
                string appdummy = appId.substring(0, appId.length()-3)+'ABC';
                ApprovalRequestPageController.getRelatedRecord((appId.substring(0, appId.length()-3))+'ABC');
				
                case caseinfo1 = [select id, Current_Revenue_Targets__c,salesup_Work_Required__c,status,Losing_Approver__c,New_Revenue_Target__c,owner.id, recordtype.name from case where id = :objCase.id];
                caseinfo1.salesup_Work_Required__c = 'DummyPortfolio';
                update caseinfo1;
				
                ApprovalRequestPageController.getRelatedRecord(proInstWorkitemin.id);
                
                test.stoptest();
                
            }catch(Exception ex){
                system.debug('ApprovalRequestPageControllerTest getCaseIdfromProcessInstanceWorkitem method :::'+ ex.getmessage());
            }
        }
    }
}