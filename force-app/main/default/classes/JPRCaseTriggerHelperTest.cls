/******************************************************************************
@Author: Mofit
@CreateDate: 16/08/2020
@ModifiedByandDate: 
@Description: This Class is created to cover the test coverage of JPRCaseTriggerHelper
@Test Class Coverage : 85%
******************************************************************************
=====================================================================================================================
Sr.No.    Developer Name               Date          Story Description
1.         Durga                   16-08-2021       	DIGI-2050
====================================================================================================================*/
@isTest
public class JPRCaseTriggerHelperTest {
    
    public static String recId_ChannelCareWorkOrder = workorder.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Channel_Care_Bulk_Request').getRecordTypeId();
    public static String recId_salesSupportChild=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
    public static String recId_Channel_care_partners_Request = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Channel_Care_for_Partners').getRecordTypeId();
    public static String recId_CPE_Requests = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CPE_Requests').getRecordTypeId();

   /**
      * This method is used to create the cases as required in the test methods.
      * @Author: Mofit
      * @Date: 16-08-2021
      */
    @testSetup public static void DataSetup() {
        test.startTest();
        
        Account customerAccount=TestUtil.createAccount('Testacc');
        customerAccount.APTPS_Off_Shore_Restricted__c = true;
        insert customerAccount;
        
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(customerAccount);     
        insert opp;
        
        Profile pf_bill = [select id from profile where name ='Billing Consultant'];
        List<User> userList=new List<User>();
        for(Integer i=0;i<3;i++)
        {
    	User billConsultant= new User(alias = 'bill',email='Test'+i+'billUser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                      lastname='user', languagelocalekey='en_US',localesidkey='en_US',
                                      profileid = pf_bill.id,
                                      timezonesidkey='Australia/Sydney',
                                      username='Test'+i+'billUser@testagent.com',phone='+121231231234');
    	userList.add(billConsultant);
        }
    	insert userList;
        
        Integer NumberOfCases = 1;
        Integer NumberOfWorkOrders = 1;
        List<Case> CasesOfService = new List<Case>();
        List<WorkOrder> WODetails = new List<WorkOrder>();
        Case caseObj = null;
        for(Integer i=0;i<NumberOfCases;i++){
            caseObj = new Case();
            caseObj.subject = 'Test Case Record '+i;
            caseObj.Status = 'New';
            caseObj.soc_SFD_Offshore_Restricted__c = false;
            caseObj.description = 'Test Case description';
            caseObj.salesup_No_of_sites_or_services__c= 35;
            caseObj.AccountId=customerAccount.id;
            caseObj.OpportunityId__c=opp.Id;
            caseObj.RecordTypeId = recId_salesSupportChild;
            caseObj.OwnerId = userList[0].Id;
            CasesOfService.add(caseObj);
        }
        insert CasesOfService;
        
        for(Integer i=0;i<NumberOfWorkOrders;i++){
        WorkOrder woObj = new WorkOrder();
        woObj.Status = 'New';
        woObj.description = 'Test Case description'+i;
        woObj.cusdl_work_order_type__c = 'Commercial';
        woObj.CaseId = CasesOfService[0].Id;
        woObj.RecordTypeId = recId_ChannelCareWorkOrder; 
        woObj.sfd_Offshore_Restricted__c = true;
        WODetails.add(woObj);
        }
        insert WODetails;
        
        test.stopTest();
    }
    
	/*
    Team Jaipur, Durga :: sprint 21.11, DIGI-2050
    Testmethod to cover handleOffshoreCase method for Updates Rules 
    Main class is CaseTriggerHelper
    */
    // This method will cover Case owner change from User to Queue scenario for handleOffshoreCase method
    static testMethod void handleOffshoreCaseUserToQueueTest(){
        
        test.StartTest();
        List<Case> CasesOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c,OpportunityId__c FROM Case where RecordTypeId =: recId_salesSupportChild
                                     and OpportunityId__c != null limit 1];
        CasesOfService[0].soc_SFD_Offshore_Restricted__c = false;
        Group gr = [select Id,developername from Group where Type = 'Queue' AND developername ='cpe_Ordering_Hardware'];
        User usid = [select name,id, lastname from  User where email='Test0billUser@testsales.com' limit 1 ];
        List<Case> CaseOfService = new List<Case>();
        OpportunityShare oppShare = new OpportunityShare();
        oppShare.OpportunityId = CasesOfService[0].OpportunityId__c;
        oppShare.UserOrGroupId = CasesOfService[0].OwnerId;
        oppShare.OpportunityAccessLevel = 'Read';
        oppshare.RowCause = 'Manual';
		insert oppShare;
        for(Case cs: CasesOfService){
            cs.OwnerId = gr.Id;
            CaseOfService.add(cs);
        }
        update CaseOfService;
        List<Case> updatedCaseOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c,OpportunityId__c FROM Case where RecordTypeId =: recId_salesSupportChild
                                     and OpportunityId__c != null limit 1];
        List<OpportunityShare> deletedOppShare = [select Id from OpportunityShare where OpportunityId =: CasesOfService[0].OpportunityId__c AND UserOrGroupId =: CasesOfService[0].OwnerId 
                        AND OpportunityAccessLevel = 'Read' AND RowCause = 'Manual'];
		system.assertEquals(0, deletedOppShare.size());  
        test.StopTest();
    }
    // This method will cover Case owner change from Queue to User scenario for handleOffshoreCase method
    static testMethod void handleOffshoreCaseQueueToUserTest(){
        test.StartTest();
        List<Case> CasesOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c,OpportunityId__c FROM Case where RecordTypeId =: recId_salesSupportChild
                                     and OpportunityId__c != null limit 1];
        CasesOfService[0].soc_SFD_Offshore_Restricted__c = false;
        Group gr = [select Id,developername from Group where Type = 'Queue' AND developername ='cpe_Ordering_Hardware'];
        CasesOfService[0].OwnerId = gr.id;
        User usid = [select name,id, lastname from  User where email='Test1billUser@testsales.com' limit 1 ];
        List<Case> CaseOfService = new List<Case>();
        
        for(Case cs: CasesOfService){
            cs.OwnerId = usid.Id;
            CaseOfService.add(cs);
        }
        update CaseOfService;
        List<OpportunityShare> oppCreate = [select Id from OpportunityShare where OpportunityId =: CasesOfService[0].OpportunityId__c AND UserOrGroupId =: usid.id 
                        AND OpportunityAccessLevel = 'Read' AND RowCause = 'Manual'];
		system.assertEquals(1, oppCreate.size());
        test.StopTest();
    }
    // This method will cover Case owner change from User to User scenario for handleOffshoreCase method
    static testMethod void handleOffshoreCaseUserToUserTest(){
        test.StartTest();
        List<Case> CasesOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c,OpportunityId__c FROM Case where RecordTypeId =: recId_salesSupportChild
                                     and OpportunityId__c != null limit 1];
        CasesOfService[0].soc_SFD_Offshore_Restricted__c = false;
        User usid = [select name,id, lastname from  User where email='Test2billUser@testsales.com' limit 1 ];
        List<Case> CaseOfService = new List<Case>();
        
        for(Case cs: CasesOfService){
            cs.OwnerId = usid.Id;
            CaseOfService.add(cs);
        }
        update CaseOfService;
        List<OpportunityShare> oppCreate = [select Id from OpportunityShare where OpportunityId =: CasesOfService[0].OpportunityId__c AND UserOrGroupId =: usid.id 
                        AND OpportunityAccessLevel = 'Read' AND RowCause = 'Manual'];
		system.assertEquals(1, oppCreate.size());
        test.StopTest();
    }
    // This method will cover Case Status change scenario for handleOffshoreCase method
    static testMethod void handleOffshoreCaseStatusChangeTest(){
        test.StartTest();
        List<Case> CasesOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c,OpportunityId__c FROM Case where RecordTypeId =: recId_salesSupportChild
                                     and OpportunityId__c != null limit 1];
        CasesOfService[0].soc_SFD_Offshore_Restricted__c = false;
        OpportunityShare oppShare = new OpportunityShare();
        oppShare.OpportunityId = CasesOfService[0].OpportunityId__c;
        oppShare.UserOrGroupId = CasesOfService[0].OwnerId;
        oppShare.OpportunityAccessLevel = 'Read';
        oppshare.RowCause = 'Manual';
		insert oppShare;
        List<Case> CaseOfService = new List<Case>();
        
        for(Case cs: CasesOfService){
            cs.status = 'Rejected';
            CaseOfService.add(cs);
        }
        workorder wo = [select id from workorder where caseId =: CasesOfService[0].id];
        wo.Status = 'Rejected';
        update wo;
        update CaseOfService;
        List<OpportunityShare> deletedOppShare = [select Id from OpportunityShare where OpportunityId =: CasesOfService[0].OpportunityId__c AND UserOrGroupId =: CasesOfService[0].OwnerId 
                        AND OpportunityAccessLevel = 'Read' AND RowCause = 'Manual'];
		system.assertEquals(0, deletedOppShare.size());
        test.StopTest();
    }
 
    /*
    Team Jaipur, Durga :: sprint 21.11, DIGI-2050
    Testmethod to cover handleWorkOrder method for Updates Rules 
    Main class is JPRCaseTriggerHelper
    */
    // This method will cover Case Offshore flag change from true to false for handleWorkOrder method
    static testMethod void handleWorkOrderOffshoreCheckedtest(){
        test.StartTest();
        List<Case> caseList = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c FROM Case where RecordTypeId =: recId_salesSupportChild LIMIT 1];
        WorkOrder woid = new WorkOrder();
        woid.Status = 'New';
        woid.description = 'Test Case description1';
        woid.cusdl_work_order_type__c = 'Commercial1';
        woid.CaseId = caseList[0].Id;
        woid.RecordTypeId = recId_ChannelCareWorkOrder; 
        woid.sfd_Offshore_Restricted__c = true;
        insert woid;
        for(Case caseService: caseList){
            caseService.soc_SFD_Offshore_Restricted__c = false;
        }
        update caseList;
        workorder updatedWoid = [select id,sfd_Offshore_Restricted__c from workorder where workorder.CaseId=:caseList[0].id and RecordTypeId =: recId_ChannelCareWorkOrder LIMIT 1];
        System.assertEquals(updatedWoid.sfd_Offshore_Restricted__c,false);
        test.StopTest();
    }
    // This method will cover Case Offshore flag change from false to true for handleWorkOrder method
    static testMethod void handleWorkOrderOffshoreUnCheckedtest(){
        test.StartTest();
        List<Case> CasesOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c FROM Case where RecordTypeId =: recId_salesSupportChild LIMIT 1];
        CasesOfService[0].soc_SFD_Offshore_Restricted__c = false;
        WorkOrder woObj1 = new WorkOrder();
        woObj1.Status = 'New';
        woObj1.description = 'Test Case description1';
        woObj1.cusdl_work_order_type__c = 'Commercial1';
        woObj1.CaseId = CasesOfService[0].Id;
        woObj1.RecordTypeId = recId_ChannelCareWorkOrder; 
        woObj1.sfd_Offshore_Restricted__c = false;
        insert woObj1;
        
        for(Case CaseOfService: CasesOfService){
            CaseOfService.soc_SFD_Offshore_Restricted__c = true;
        }
        update CasesOfService;
		workorder updatedWoid = [select id,sfd_Offshore_Restricted__c from workorder where workorder.CaseId=:CasesOfService[0].id and RecordTypeId =: recId_ChannelCareWorkOrder LIMIT 1];
        System.assertEquals(updatedWoid.sfd_Offshore_Restricted__c,true);
               
        test.StopTest();
    }  
   
    /**
      * This method is used to test logic covered in handlePartnerCaseBeforeInsert  and handlePartnerCaseBeforeUpdate method.
      * @Author: Chandrakant
      * @Date: 06-09-2021
    */
    @IsTest
    static void handlePartnerCaseTest(){
        
        Test.startTest();
        
        Account acc = new Account(name='TestParentAccount',CIDN__c='123467',ABN__c='12323',Parent_CIDN__c='123');
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
        insert basket;
        
        cscfga__Product_Basket__c querybasket = [Select id, name from cscfga__Product_Basket__c where id =: basket.id];
        
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        
        List<csord__Order__c> ordlist = new List<csord__Order__c>();

       	csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.name = 'testorder' ;
        ord.csord__Status__c = 'Connected';
        ord.csordtelcoa__Opportunity__c =  opp.id;
        ord.Product_Basket__c = basket.id;
        ordlist.add(ord);
        
        csord__Order__c ord2 = new csord__Order__c();
        ord2.csord__Identification__c = 'test identification';
        ord2.csord__Account__c = acc.id;
        ord2.name = 'testorder' ;
        ord2.csord__Status__c = 'Connected';
        ord2.csordtelcoa__Opportunity__c =  opp.id;
        ord2.Product_Basket__c = basket.id;
        ordlist.add(ord2);
        
        insert ordlist;
        /*
        ContractJunction__c parentContractJunction = new ContractJunction__c();
        parentContractJunction.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        parentContractJunction.CongaStatus__c = 'NotStarted';
        parentContractJunction.Status__c = 'Initiated';
        parentContractJunction.Related_Opportunity__c = opp.Id;
        parentContractJunction.Contract_Activated_Date__c = System.today();
        parentContractJunction.Contract_Term_Months__c = 36;
        parentContractJunction.BSA_Generated__c = true;
        parentContractJunction.GPTVersion__c = 1.2;
        parentContractJunction.OFTVersion__c = 1.4;
        parentContractJunction.BSAVersion__c = 1.3;
        parentContractJunction.Account__c = acc.id;
        insert parentContractJunction;
        
        ContractJunction__c contractJunction = new ContractJunction__c();
        contractJunction.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contractJunction.CongaStatus__c = 'NotStarted';
        contractJunction.Status__c = 'Initiated';
        contractJunction.Related_Opportunity__c = opp.Id;
        contractJunction.Contract_Activated_Date__c = System.today();
        contractJunction.Contract_Term_Months__c = 36;
        contractJunction.BSA_Generated__c = true;
        contractJunction.GPTVersion__c = 1.2;
        contractJunction.OFTVersion__c = 1.4;
        contractJunction.BSAVersion__c = 1.3;
        contractJunction.Account__c = acc.id;
        contractJunction.Parent_Contract__c= parentContractJunction.Id;
        
        insert contractJunction;
		*/
        
        Case caseObj = new Case();
            caseObj.subject = 'Partner Case Record 1';
            caseObj.Status = 'New';
            caseobj.ss_Type__c ='Digital Product Technical Support';
            caseobj.ss_Category__c ='Order Support';
        	caseobj.ss_Work_Required__c ='Raise a followup request for a submitted order';
            caseobj.ss_Order__c =ord.Id; 
            caseObj.soc_SFD_Offshore_Restricted__c = false;
            caseObj.description = 'Partner Test Case description';
            caseObj.AccountId=acc.id;
            caseObj.RecordTypeId = recId_Channel_care_partners_Request;
        //Update same case to trigger handlePartnerCaseBeforeInsert method logic
        insert caseObj;
        
        Case cs = [select id,ss_Order__c,OpportunityId__c,ss_Contract__c,RecordTypeId,subject,ss_Basket_Number__c from case where id =: caseObj.Id  limit 1];
        System.assertEquals(cs.ss_Basket_Number__c, querybasket.name);
        
        //Update same case to trigger handlePartnerCaseBeforeUpdate method logic
        cs.ss_Order__c = ord2.id;
        update cs;
        
        Case updatedCase = [select id,ss_Order__c,OpportunityId__c,ss_Contract__c,RecordTypeId,subject,ss_Basket_Number__c from case where id =: caseObj.Id  limit 1];
        System.assertEquals(updatedCase.ss_Basket_Number__c, querybasket.name);

        Test.stopTest();        
    } 

    /*
    Team Jaipur, Durga :: sprint 21.13, DIGI-12640
    Testmethod to cover cpePurpleGovernanceOffshoreNotRestricted method for Updates ownerid
    Main class is JPRCaseTriggerHelper
    */
    @isTest
    static void cpePurpleGovernanceOffshoreNotRestrictedtest(){
        Account acc = new Account(name='TestParentAccount',CIDN__c='123467',ABN__c='12323',Parent_CIDN__c='123');
        acc.Customer_Status__c = 'ACTIVE';
        acc.APTPS_Off_Shore_Restricted__c=true;
        insert acc;
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 460;
        insert opp;
        Profile pf_bill = [select id from profile where name ='Billing Consultant'];
        User u = new User(alias = 'billi',email='TesillUser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                      lastname='user1', languagelocalekey='en_US',localesidkey='en_US',cpe_Purple__c=true,
                                      profileid = pf_bill.id,
                                      timezonesidkey='Australia/Sydney',
                                      username='standdur@testorg.com',phone='+121231231234');
        insert u;
        test.StartTest();
        Case caseObj = new Case();
            caseObj.subject = 'Case Record 1';
            caseObj.Status = 'New';
            caseObj.description = 'Test Case description';
            caseObj.AccountId=acc.id;
            caseObj.RecordTypeId = recId_CPE_Requests;
            caseObj.Type='CPE Purple';
            caseObj.OwnerId=u.id;
            caseObj.cpe_Tagged_Sales_Lead__c=u.id;
        	caseObj.Origin = 'Email';
            caseObj.salesup_Work_Required__c='Partnering Engagement Order';
            caseObj.srvsup_Categories__c='Ordering Hardware & Services';
            caseobj.cpe_CPE_Skills_Set__c='Purple Onshore - Alteration Cart';
            caseObj.soc_SFD_Offshore_Restricted__c = false;
            
        insert caseObj;
        case uplist = [select OwnerId,cpe_Governance_Status__c from case where Id=:caseObj.id LIMIT 1];
        uplist.cpe_Governance_Status__c='Sales Support Required';
        update uplist;
        case upcase = [select OwnerId,cpe_CPE_Skills_Set__c from case where Id=:caseObj.id LIMIT 1];
        List<Group> gr = [Select developerName from Group WHERE Id=:upcase.OwnerId LIMIT 1];
        System.assertEquals(gr[0].developerName,'cpe_Ordering_Hardware');
        System.assertEquals(upcase.cpe_CPE_Skills_Set__c,'Purple - General Enquiry');
        test.StopTest();
    }
    
    /*
    Team Jaipur, Harshita Verma :: Sprint 21.14, DIGI-21815 
    This method is used to test logic covered in handleTelstraConnectCases, On Channel care record type for any case created from Telstra Connect the Contact Customer option must be set to YES
    Main class is JPRCaseTriggerHelper
    */
   
    @isTest
    static void handleTelstraConnectCasesTest(){
        
        //Test.startTest();
        Account acc = new Account(name='TestParentAccount',CIDN__c='123467',ABN__c='12323',Parent_CIDN__c='123');
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;

        Profile pf_integrations = [select id from profile where name ='Integration - TConnect'];
 
    	User connectuserT = new User(alias = 'Tuser98',email='tConnect98User@test121.com',emailencodingkey='UTF-8',IsActive =true,
                                      lastname='userT1', languagelocalekey='en_US',localesidkey='en_US', profileid = pf_integrations.id,
                                      timezonesidkey='Australia/Sydney',username='tconnectuser@testorg.com',phone='+19898711234');
    	
        insert connectuserT;
        User testuser = [select name from  User where email='tConnect98User@test121.com'];

		system.runAS(testuser){
			Case caseObj = new Case();
            caseObj.subject = 'Channel care case 1';
            caseObj.Status = 'New';
            caseobj.ss_Type__c ='Billing';
            caseobj.ss_Category__c ='Request Billing Changes for the customer';
            caseobj.ss_Work_Required__c ='Refund';
            caseObj.soc_SFD_Offshore_Restricted__c = false;
            caseObj.description = 'TPC Test Case description';
            caseObj.AccountId=acc.id;
            caseObj.RecordTypeId = recId_salesSupportChild;
            caseObj.Origin = 'Telstra Connect';
			Test.startTest();
        	insert caseObj;
            Test.stopTest(); 
            Case cs = [select id, salesup_Contact_Customer__c from case where id =: caseObj.Id  limit 1];
        	System.assertEquals(cs.salesup_Contact_Customer__c,'Yes');
        }
    }

    /**
      * This method is used to test logic covered in addInvoiceApexShareRecord method.
      * @Author: Chandrakant
      * @Date: 02-11-2021
    */
    @IsTest
    static void addInvoiceApexShareRecordTest(){
        
        Test.startTest();
        
        Account ac = new Account(name ='Test Acc',Account_Status__c = 'Active');
        insert ac;  
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;
        
        Profile partnerProfile = [select id from profile where name ='PRM Community User - Australia'];
 
    	User pUser = new User(alias = 'Tuser98',email='partner@test121.com',emailencodingkey='UTF-8',IsActive =true,ContactId = con.id,
                                      lastname='userT1', languagelocalekey='en_US',localesidkey='en_US', profileid = partnerProfile.id,
                                      timezonesidkey='Australia/Sydney',username='puser@testorg.com',phone='+19898711234');
    	
        insert pUser;
        User partnerUser = [select name from User where email='partner@test121.com'];
        
        System.runAs(partnerUser){
        Billing_Account__c billingAcc = TestUtil.createBillingAccount('700000005112');
        insert billingAcc;
        
        Invoice__c inv = new Invoice__c();
        inv.Name = '9900000017373';
        inv.Billing_Account__c =  billingAcc.id;
        insert inv;
        
        Case caseObj = new Case();
            caseObj.subject = 'Partner Case Record 1';
        	caseObj.ss_Invoice_number__c = inv.id;
            caseObj.ss_Type__c ='Billing';
            caseObj.ss_Category__c ='Request billing changes for the customer';
        	caseObj.ss_Work_Required__c ='Extend bill payment date';
            caseObj.description = 'Partner Test Case description';
        	caseObj.Origin = 'TPC';
        	caseObj.Requestor__c = partnerUser.id;
            caseObj.RecordTypeId = recId_salesSupportChild;
        	
        	insert caseObj;
        	
        	List<Invoice__share> ivShare = [Select id,ParentId,RowCause from Invoice__share where parentId =: inv.Id 
                AND RowCause =: Schema.Invoice__share.RowCause.TPC_Partner_Access__C ];
        	System.assertNotEquals(ivShare[0].id, Null);    
            
            Invoice__c inv2 = new Invoice__c();
        	inv2.Name = '9900000017374';
        	inv2.Billing_Account__c =  billingAcc.id;
        	insert inv2;
            
            Case getCs = [Select id, ss_Invoice_number__c from Case where id =: caseObj.id];
            getCs.ss_Invoice_number__c = inv2.id;
            update getCs;
            
            List<Invoice__share> ivShare2 =[Select id,ParentId,RowCause from Invoice__share where parentId =: inv.Id 
                AND RowCause =: Schema.Invoice__share.RowCause.TPC_Partner_Access__C];
            
        	System.assertEquals(ivShare2.size(), 0);  
        	Test.stopTest();     
        }
    }
}