/**
* Description : Test Class for covering PRM PPV sceanrios using mock API callout                  
* Jira        : P2OB - 11853
* Author      : Team Hawaii :  Ritika Jaiswal

* Date        : 15-Jan-2021 
**/
@isTest
public class PRM_PPV_Test {
    private static String fed_id;
    @testsetup static void setup() {
        
        fed_id= 'a' + Math.round((Math.random() * (900000) + 100000));
        System.debug('Fed-id'+fed_id);


        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile])
            profilesMap.put(profile.Name, profile);
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole])
            rolesMap.put(role.DeveloperName, role);
        List<User> users= new List<User>();
        
        //Create Admin User
        User[] ICMUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        users.addAll(ICMUser);
        insert users;
        
        List<Contact> contactList = new List<Contact>();
        User[] partnerUser;
        
        Account[] partnerAccount;       
        
        Account[] customerAccount;

        
        System.runAs(users[0]){
             //insert  new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'sfdc_prod_client');
        }

        
        System.runAs(users[0]){
            //Create Customer Account
            customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            insert customerAccount;
        }
        

        //ICM creating partner-account, and partner contact
        System.runAs(users[0]){         
            partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);           
            insert partnerAccount;            
            
            Contact contact = new Contact();
            contact.FirstName = 'Test Account';
            contact.LastName='Last Name';
            contact.AccountId=partnerAccount[0].Id; //Contact assigned in partner-account
            contactList.add(contact);
            insert contactList; 
            partnerAccount[0].isPartner = True;
            partnerAccount[0].PartnerPrincipalContact__c = contact.id;
            partnerAccount[0].CWP_Eligible_Partner__c = false;
            partnerAccount[0].Account_Status__c = 'Active';
            update partnerAccount[0];
            
            //Create Partner User
            partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,contactList,false);

            partnerUser[0].FederationIdentifier = fed_id;
            partnerUser[0].email = 'PRM_PPV_Test@test.com';
            
            insert partnerUser;
            
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MAC').getRecordTypeId();
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = PRMTestUtility.createOpportunity(1,customerAccount,oppRecordTypeId,partnerAccount[0].Id);
            insert oppList;
            
            List<PRM_PPVCheck_Staging__c> stagingRecords = new List<PRM_PPVCheck_Staging__c>();
            for(integer i=0; i < 10 ; i++){
                PRM_PPVCheck_Staging__c stage_record = new PRM_PPVCheck_Staging__c();
                stage_record.Opportunity_Id__c = oppList[0].id;
                stage_record.Parent_Number__c = '61400000001';
                stage_record.CA_Form_status__c = 'Pending';
                stage_record.Is_Processed_in_CSV__c = false ; 
                stage_record.Secondary_numbers__c = '61400000002';
                stage_record.Requested_by__c = UserInfo.getUserId();
                stage_record.Method_of_Verification__c = 'AuthRepSMS';
                stage_record.Response_Details__c = '{"method":"POST","path":"/","correlationId":"b8cd867d-fc72-4969-86cf-168a2e748dad","errors":[{"message":"Attribute provided in incorrect format - [mobileNumber]","code":2001}],"code":422,"status":422,"responseCode":"PPV-VALIDATION-ERROR","time":"2021-02-09T10:27:42.101Z"}';
                stagingRecords.add(stage_record);
            }
            insert stagingRecords;

        }    
    }
    
    
    public static testMethod void test_sendVerificationRequest(){       
        Test.startTest();
        User partnerUser = [Select id from user where email = 'PRM_PPV_Test@test.com' limit 1];
        System.runAs(partnerUser){


        	Test.setMock(HttpCalloutMock.class, new Mock_PRM_PPV_Response('success_PPV_Creation'));
        	PRM_PPV_CreateVerificationRequest.FlowInputParameter fip = new PRM_PPV_CreateVerificationRequest.FlowInputParameter();
        	fip.numbers_for_porting = new List<String>{'0456876999'};
            fip.custAuthRepDetails =  '0456876999';
        	fip.verificationMethod = 'AuthRepSMS';

        	List<PRM_PPV_CreateVerificationRequest.FlowOutputParameter> fop = PRM_PPV_CreateVerificationRequest.sendVerificationRequest(new List<PRM_PPV_CreateVerificationRequest.FlowInputParameter>{fip});
        	Test.stopTest();
        	System.assert(fop[0].isResultSuccess == true);
        }
        


    }
    
    public static testMethod void test_sendVerificationRequest_failure(){
        Test.startTest();
        User partnerUser = [Select id from user where email = 'PRM_PPV_Test@test.com' limit 1];
        System.runAs(partnerUser){

        Test.setMock(HttpCalloutMock.class, new Mock_PRM_PPV_Response('PPV_Creation_Fail'));

        	PRM_PPV_CreateVerificationRequest.FlowInputParameter fip = new PRM_PPV_CreateVerificationRequest.FlowInputParameter();
        	fip.numbers_for_porting = new List<String>{'0456876999'};
            fip.custAuthRepDetails =  '0456876999';
        fip.verificationMethod = 'AuthRepCall';
        	List<PRM_PPV_CreateVerificationRequest.FlowOutputParameter> fop = PRM_PPV_CreateVerificationRequest.sendVerificationRequest(new List<PRM_PPV_CreateVerificationRequest.FlowInputParameter>{fip});
        	Test.stopTest();
        	System.assert(fop[0].isResultSuccess == false);
        }
        


    }
    
    public static testMethod void test_verifyOTPCode(){
        Test.startTest();
        User partnerUser = [Select id from user where email = 'PRM_PPV_Test@test.com' limit 1];
        System.runAs(partnerUser){


        	Test.setMock(HttpCalloutMock.class, new Mock_PRM_PPV_Response('success_PPV_Verify'));
        	PRM_PPV_VerifyCode_Request.FlowInputParameter fip = new PRM_PPV_VerifyCode_Request.FlowInputParameter();
        	fip.numbers_for_porting = new List<String>{'0456876999'};
            fip.custAuthRepDetails = '0456876999';

            fip.verificationMethod = 'AuthRepSMS';
            fip.OTP_input = '123445';
            fip.CA_Form_status='Completed';
            
            PRM_PPV_VerifyCode_Request.FlowInputParameter fip1 = new PRM_PPV_VerifyCode_Request.FlowInputParameter();
            fip1.numbers_for_porting = new List<String>{'0456876999'};
            fip1.custAuthRepDetails = '0456876999';
            fip1.verificationMethod = 'AuthRepCall';
            fip1.CA_Form_status='Completed';
            
            List<PRM_PPV_VerifyCode_Request.FlowOutputParameter> fop = PRM_PPV_VerifyCode_Request.verifyOTPCode(new List<PRM_PPV_VerifyCode_Request.FlowInputParameter>{fip,fip1});
            Test.stopTest();

        	System.assert(fop[0].isResultSuccess == true);
        }
        
    }
    public static testMethod void test_verifyOTPCode_failure(){
        Test.startTest();
        User partnerUser = [Select id from user where email = 'PRM_PPV_Test@test.com' limit 1];
        System.runAs(partnerUser){
            Test.setMock(HttpCalloutMock.class, new Mock_PRM_PPV_Response('notfound_Exception'));
        	PRM_PPV_VerifyCode_Request.FlowInputParameter fip = new PRM_PPV_VerifyCode_Request.FlowInputParameter();
        	fip.numbers_for_porting = new List<String>{'0456876999'};
            fip.custAuthRepDetails = '0456876999';
        	fip.OTP_input = '123445'; 

        	fip.CA_Form_status='Completed';
        	List<PRM_PPV_VerifyCode_Request.FlowOutputParameter> fop = PRM_PPV_VerifyCode_Request.verifyOTPCode(new List<PRM_PPV_VerifyCode_Request.FlowInputParameter>{fip});
        	Test.stopTest();
        	System.assert(fop[0].isResultSuccess == false);
        }
        
    }
    public static testMethod void test_PRMPrePortVerificationBatch(){        
        User partnerUser = [Select id from user where email = 'PRM_PPV_Test@test.com' limit 1];
        Opportunity toppty = [select id from Opportunity limit 1];
        List<PRM_PPV_Invocable_For_ExecuteBatch.FlowInputParameter> fipList = new List<PRM_PPV_Invocable_For_ExecuteBatch.FlowInputParameter>();
        PRM_PPV_Invocable_For_ExecuteBatch.FlowInputParameter fip = new PRM_PPV_Invocable_For_ExecuteBatch.FlowInputParameter();
        fip.batch_size = 50;
        fip.reference_recordID = toppty.id;
        fiplist.add(fip);
        Set<String> strName = new Set<String>();
        strName.add('Irfan.Inamdar@telstra.com');
        
        System.runAs(partnerUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_PRM_PPV_Response('success_PPV_Verify'));
            PRM_PPV_Invocable_For_ExecuteBatch.executeBatchMethod(fiplist);
            PRMPrePortVerificationBatch mybatchclass = new PRMPrePortVerificationBatch(fip.reference_recordID);
			mybatchclass.postChattertorequester(strName); 
            Test.stopTest(); 
            
        }
        
        PRM_PPVCheck_Staging__c stagingRecords = [select id,Is_Processed_in_CSV__c from PRM_PPVCheck_Staging__c limit 1];
        System.assert(stagingRecords.Is_Processed_in_CSV__c == true);
    }
    
    public static testMethod void test_PRMPrePortVerificationBatch_auth_expire(){        
        User partnerUser = [Select id from user where email = 'PRM_PPV_Test@test.com' limit 1];
        Opportunity toppty = [select id from Opportunity limit 1];
        List<PRM_PPV_Invocable_For_ExecuteBatch.FlowInputParameter> fipList = new List<PRM_PPV_Invocable_For_ExecuteBatch.FlowInputParameter>();
        PRM_PPV_Invocable_For_ExecuteBatch.FlowInputParameter fip = new PRM_PPV_Invocable_For_ExecuteBatch.FlowInputParameter();
        fip.batch_size = 50;
        fip.reference_recordID = toppty.id;
        fiplist.add(fip);
        
        System.runAs(partnerUser){ 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock_PRM_PPV_Response('PPV_auth_expire'));
            PRM_PPV_Invocable_For_ExecuteBatch.executeBatchMethod(fiplist);
            Test.stopTest();
        }
        
        PRM_PPVCheck_Staging__c stagingRecords = [select id,Is_Processed_in_CSV__c from PRM_PPVCheck_Staging__c limit 1];
        System.assert(stagingRecords.Is_Processed_in_CSV__c == true);

    }
    
    
     public static testMethod void test_PRMPrePortVerificationBatch2(){ 
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        Account accc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity oppp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c baskett = [SELECT id,csbb__Account__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthForm.Is_active__c=true;
        custAuthForm.Type__c ='Mobile';
        insert  custAuthForm;
        User partnerUser = [Select id from user where email = 'PRM_PPV_Test@test.com' limit 1];
        Opportunity toppty = [select id from Opportunity limit 1];
        
        
        Test.startTest();
        System.runAs(partnerUser){
            
            Test.setMock(HttpCalloutMock.class, new Mock_PRM_PPV_Response('success_PPV_Verify'));
            PRMPrePortVerificationBatch mybatch = new PRMPrePortVerificationBatch(oppp.id,baskett.id,custAuthForm.id);
            
                        
        }
        Test.stopTest(); 
    }
}