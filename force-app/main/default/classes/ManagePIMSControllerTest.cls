/* 
Modifications : 
1. P2OB-6753 - Hawaii - 09/06/2020 - main class is updated so added fixes only against that 
2. P2OB-9678 - Hawaii - 8/10/2020 - Test Class updated for removing logic against button 'Deactivate User'
*/
@istest
public with sharing class ManagePIMSControllerTest {
    public static string getCertName(){
        string certificatename='sfdc_prod_client';
        boolean runningSandbox=PRMWebtoLeadContr.runningInASandbox();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        if(runningSandbox){
            if(baseUrl.containsIgnoreCase('preprod'))
                certificatename='sfdc_preprod_client';
            else if(baseUrl.containsIgnoreCase('qa2') || baseUrl.containsIgnoreCase('qa1'))
                certificatename='telstrab2b_sandbox';
        }else if(baseUrl.containsIgnoreCase('telstrab2b.my'))
                certificatename='sfdc_prod_client';
        return certificatename;
    }
    @testSetup static void setup() {
        
        //P2OB-6753 - Hawaii - Instead of creating role query on role to avoid error 'System.DmlException: Insert failed. First exception on row 0; first error: LIMIT_EXCEEDED, reached maximum number of roles: []'
        UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
          /*UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
         insert r;*/
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
            id p1 = [select id from profile where name='System Administrator'].id;
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
           id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
        id prmUser = [select id from profile where name='PRM Community User - Australia'].id;
        insert uSysAdmin;
          System.runAs(uSysAdmin){  
         test.startTest();
        list<contact> conlist= new list<contact>();
        Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
        insert ac;
        Account ac1 = new Account(name ='TelecomAC1',Account_Status__c = 'New',Overall_Accreditation__c='Platinum',PRM_Remaining_License__c=0);
        insert ac1; 
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
       conlist.add(con); //insert con;  
        Contact con1 = new Contact(LastName ='testCon1',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890');
        conlist.add(con1); //insert con1;
        Contact con2 = new Contact(LastName ='testCon2',AccountId = ac1.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',OTP_Mobile_Phone_Number__c='+911234567890');
        conlist.add(con2); //insert con2;        
        Contact tcwContact = new Contact(LastName ='testContcw',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TCW');
        conlist.add(tcwContact); //insert tcwContact;
        insert conlist;
              list<user> userlist= new list<user>();
        User pdua = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua@noemail.com',contactid=con.id);
       userlist.add(pdua);// insert pdua ;
       User nonPdua = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = prmUser, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='b2btestewwrnonPdua@noemail.com',contactid=con1.id);
       userlist.add(nonPdua); //insert nonPdua;
        User u2 = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p1, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='b2btestewwr@noemail.com');
        userlist.add(u2); //insert u2;
              insert userlist;
        test.stoptest();   
        //Userrole r = [Select id from Userrole where name ='CEO'];
        }
        }
    @istest
    public  static void testManagePIMSController(){
    test.starttest();
        ManagePIMSController pimscontroller = new ManagePIMSController();
        String methodName = 'callPIMS';
        Account ac = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
        Account ac1 = [select id,name,Account_Status__c,Overall_Accreditation__c from account where name='TelecomAC1' limit 1];
        Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
        Contact con1 = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon1' limit 1];
        Contact con2 = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon2' limit 1];
        Contact tcwContact = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testContcw' limit 1];
        ac.PartnerPrincipalContact__c=con1.id;
        update ac;
        id p = [select id from profile where name='Partner Community User'].id;
            string certificatename=getCertName();
             insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = certificatename);//telstrab2b_sandbox
         User u2 = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
        String params = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'createOrg'
        });
             String params3 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'deactivateOrg'
        });
        system.debug('params'+params);
        String params2 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'createUser'
        });
        String params4 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'elevateToPDUA'
        });
        /*String params5 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'deactivateUser'
        });*/
         String params6 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'updateUser'
        });
         String params7 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'freezeOrg'
        });
             String params8 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'finduser'
        });
              String params9 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'updateTCW'
        });
         String params10 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'removePDUA'
        });
        /*String params11 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>tcwContact.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'deactivateUser'
        });*/
        String params12 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>tcwContact.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'elevateToPDUA'
        });
         String params13 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>tcwContact.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'removePDUA'
        });
         String params17 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>tcwContact.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'reinstateUser'
        });
        string msRequest = '{'+
            '  \"userPid\": \"\",'+
            '  \"userFirstName\": \"Nikita\",'+
            '  \"userLastName\": \"Tiwa\",'+
            '  \"userEmail\": \"abc@telstra.com\",'+
            '  \"orgName\": \"abc\",'+
            '  \"isPDUA\": \"true\",'+
            '  \"isDeactivate\": \"true\",'+
            ' \"pimsAPIType\": \"MANAGEORG\",'+
            ' \"pageObjectID\": \"con.id\",'+
            '  \"mobileNumber\": \"0419111000\"'+
            '}';
        String pageObjectID1 = ac.id;  //acc status new for validate method
        String pageObjectID2 = con.id;
        String pageObjectID3 = ac1.id;  //acc status active for validate method
        WrapperMSPIMSParams.WrapperPageParameters pageParams = ManagePIMSController.parsePageParams(params);
        WrapperMSPIMSParams.WrapperPageParameters pageParams2 = ManagePIMSController.parsePageParams(params2);
        //system.runas(u2){
        ManagePIMSController.inactivateUsers(new Set<string>{con.id});
        ManagePIMSController.generateUniqueId();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        string Result=ManagePIMSController.validate(pageObjectID1); //obj type = account; acc status = active
        ManagePIMSController.validate(pageObjectID2); //object type = contact
        ManagePIMSController.validate(pageObjectID3); //obj type = account; acc status = new
        User prmUser=[select id,profile.name from user where profile.Name='PRM Community User - Australia' and isActive=true limit 1];
         //Account acc = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomACC' limit 1];
         //Contact cont = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCont' limit 1];
        User inactive = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
       System.runAs(prmUser) {
                // The following code runs as user 'partner Community User'
                string Result1=ManagePIMSController.validate(pageObjectID1); 
                ManagePIMSController.validate(pageObjectID2); 
                ManagePIMSController.validate(pageObjectID3); 
         }
         ManagePIMSController.validateContactDetails(pageObjectID2,'updateUser');
         ManagePIMSController.validateContactDetails(pageObjectID2,'createUser');
         ManagePIMSController.validateContactDetails(con1.id,'createUser');
        // ManagePIMSController.validateContactDetails(con1.id,'deactivateUser');
        // ManagePIMSController.validateContactDetails(con2.id,'deactivateUser'); 
         ManagePIMSController.validateContactDetails(con2.id,'finduser'); //Test
        ManagePIMSController.invoke(params,''); //pimsAPIType = MANAGEORG
        ManagePIMSController.invoke(params3,''); //pimsAPIType = MANAGEORG
        ManagePIMSController.invoke(params2,''); //pimsAPIType = MANAGEUSER
        ManagePIMSController.invoke(params4,''); //pimsAPIType = MANAGEUSER
        //ManagePIMSController.invoke(params5,''); //pimsAPIType = MANAGEUSER
        ManagePIMSController.invoke(params6,''); //pimsAPIType = MANAGEUSER
        ManagePIMSController.invoke(params7,''); //pimsAPIType = MANAGEUSER    
        ManagePIMSController.invoke(params8,''); //pimsAPIType = MANAGEUSER 
        ManagePIMSController.invoke(params9,''); //pimsAPIType = MANAGEUSER 
        ManagePIMSController.invoke(params10,''); //Remove PDUA      
        //ManagePIMSController.invoke(params11,''); // PIMSUserType= TCW, PIMSCallType=Deactivate user
        ManagePIMSController.invoke(params12,''); // PIMSUserType= TCW, PIMSCallType=elevatetoPDUA
        ManagePIMSController.invoke(params13,''); // PIMSUserType= TCW, PIMSCallType=removePDUA
    ManagePIMSController.invoke(params17,''); // PIMSUserType= TCW, PIMSCallType=reinstateUser
        String params14 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'reactivateOrg'
        });
        String params15 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'freezeOrg'
        });
         String params16 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'unfreezeOrg'
        });
        ManagePIMSController.invoke(params14,'');
        ManagePIMSController.invoke(params15,'');
        //ManagePIMSController.invoke(params16,'');
        /********/
        ManagePIMSInterface.callPIMSMicroservice(JSON.serialize(msRequest),
                       'PimsMicroserviceManageUser',
                       'POST',
                       con.LastName,
                       pageParams);
                test.stoptest(); 
    PIMSService.reactivateOrg(pageParams,'PimsMicroserviceManageOrg');
    PIMSService.reinstateUser(pageParams2,'PimsMicroserviceManageUser');
    pimsservice service= new pimsservice();
  service.findOrg();
    System.assert( Null!=Result,'Result' );
   // }
    }
     @istest
    public  static void testManagePIMSControllerparsePIMSResponse(){
   test.starttest();   
        ManagePIMSController pimscontroller = new ManagePIMSController();
        String methodName = 'callPIMS';
        Account ac = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
        Account ac1 = [select id,name,Account_Status__c,Overall_Accreditation__c from account where name='TelecomAC1' limit 1];
        Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
        id p = [select id from profile where name='Partner Community User'].id;
        string certificatename=getCertName();
              insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c =certificatename);//telstrab2b_sandbox
        User u2 = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
        String params = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'createOrg'
        });
             String params3 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'deactivateOrg'
        });
        system.debug('params'+params);
        String params2 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'createUser'
        });
        String params4 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'elevateToPDUA'
        });
        /*String params5 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'deactivateUser'
        });*/
         String params6 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'updateUser'
        });
        String params7 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'reinstateUser'
        });
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "title": "Success", "status": "200","orgId": "34535","pimsStatus": 0,"description": "Other"}');
        WrapperMSPIMSParams.WrapperPageParameters state=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params, WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate= new ContinuationController.WrapperState();
        wrpstate.pageParams=state;
        wrpstate.requestTime=DateTime.now();
        object str=ManagePIMSController.parsePIMSResponse(res,wrpstate);
        WrapperMSPIMSParams.WrapperPageParameters state1=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params3, WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate1= new ContinuationController.WrapperState();
        wrpstate1.pageParams=state1;
        wrpstate1.requestTime=DateTime.now();
        object str1=ManagePIMSController.parsePIMSResponse(res,wrpstate1);
        WrapperMSPIMSParams.WrapperPageParameters state2=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params2, WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate2= new ContinuationController.WrapperState();
        wrpstate2.pageParams=state2;
        wrpstate2.requestTime=DateTime.now();
        object str2=ManagePIMSController.parsePIMSResponse(res,wrpstate2);
         WrapperMSPIMSParams.WrapperPageParameters state4=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params4, WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate4= new ContinuationController.WrapperState();
        wrpstate4.pageParams=state4;
        wrpstate4.requestTime=DateTime.now();
        object str4=ManagePIMSController.parsePIMSResponse(res,wrpstate4);        
        /*WrapperMSPIMSParams.WrapperPageParameters state5=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params5,    WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate5= new ContinuationController.WrapperState();
        wrpstate5.pageParams=state5;
        wrpstate5.requestTime=DateTime.now();
        object str5=ManagePIMSController.parsePIMSResponse(res,wrpstate5);  */
        WrapperMSPIMSParams.WrapperPageParameters state7=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params7,    WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate7= new ContinuationController.WrapperState();
        wrpstate7.pageParams=state7;
        wrpstate7.requestTime=DateTime.now();
        object str7=ManagePIMSController.parsePIMSResponse(res,wrpstate7);  
            test.stoptest();
        //Assert Added SCA 
        System.assert( Null!=str7);
    //}
    }
    @istest
    public  static void testIsPIMSAccessible(){        
        ManagePIMSController.WrapperServiceResponse wr=  new ManagePIMSController.WrapperServiceResponse();
        ManagePIMSController.WrapperPageResponse wr1= new ManagePIMSController.WrapperPageResponse();
        WrapperMSPIMSParams.WrapperPageParameters wr2= new WrapperMSPIMSParams.WrapperPageParameters();
        Account ac = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
        Account ac1 = [select id,name,Account_Status__c,Overall_Accreditation__c from account where name='TelecomAC1' limit 1];
        Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
        Contact con1 = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon1' limit 1];
        Group  CATGroup = [Select Id,Type from Group where DeveloperName=:PRMConstants.PRM_PUBLICGROUP_CHANNEL_ACQUISITION_TEAM And type='Regular' limit 1];
        User u2 = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
        system.runas(u2){
               /*GroupMember GM = new GroupMember();
                        GM.GroupId = CATGroup.id;
                        GM.UserOrGroupId = u2.id;                                                    
             insert GM;*/
           Map<String, String> specAttributes = (Map<String, String>) JSON.deserialize(Label.PRM_PARTNER_LICENSE_VALIDATION_MESSAGE, Map<String, String>.class);
            string response= ManagePIMSController.IsPIMSAccessible(con.id);
            string str=specAttributes.get('nonPlatinumPDUA');
            system.assert(!response.contains(str));
            string response2= ManagePIMSController.IsPIMSAccessible(ac1.id);
            string response1= ManagePIMSController.IsPIMSAccessible(con1.id);
            string str1=specAttributes.get('platinumPDUA');
            system.assert(!response1.contains(str1));
              }
    }
 @istest
    public  static void testvalidateContactDetails(){
        ManagePIMSController pimscontroller = new ManagePIMSController();
        String methodName = 'callPIMS';
       Account ac = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
        Account ac1 = [select id,name,Account_Status__c,Overall_Accreditation__c from account where name='TelecomAC1' limit 1];
        Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
        Contact con1 = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon1' limit 1];
        Contact con2 = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon2' limit 1];
        ac.PartnerPrincipalContact__c=con1.id;
        update ac;
       User u2 = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
       String result='';
        test.starttest();
        system.runas(u2){
         result=ManagePIMSController.validateContactDetails(con.id,'updateUser');
         ManagePIMSController.validateContactDetails(con.id,'createUser');
         ManagePIMSController.validateContactDetails(con1.id,'createUser');
         //ManagePIMSController.validateContactDetails(con1.id,'deactivateUser');
         //ManagePIMSController.validateContactDetails(con2.id,'deactivateUser');  
                test.stopTest(); 
    System.assert( Null!=Result,'Result' );
    }
    } 
@isTest    
    public  static void testmanageAccount(){
    User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
        String Pimscalltype1 = PRMConstants.FREEZE_ORG;
        String Pimscalltype2 = PRMConstants.UNFREEZE_ORG;
        String Pimscalltype3 = PRMConstants.REINSTATE_USER;
       Account ac = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
       Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
       Contact con1 = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon1' limit 1];
        User pdua = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where username='b2btestewwrpdua@noemail.com' limit 1];
        User nonPdua = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
        test.starttest();
        Object result=ManagePIMSController.manageAccount(ac.id, Pimscalltype1);
        ManagePIMSController.manageAccount(ac.id, Pimscalltype2);
        ManagePIMSController.manageContact(con .id, Pimscalltype3);
        test.stoptest();
        System.assert( Null!=result,'result');
    }
   }
    @istest
    public  static void testparsePIMSResponsefinduser(){
   test.starttest();   
        ManagePIMSController pimscontroller = new ManagePIMSController();
        String methodName = 'callPIMS';
        Account ac = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
        Account ac1 = [select id,name,Account_Status__c,Overall_Accreditation__c from account where name='TelecomAC1' limit 1];
        Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
        id p = [select id from profile where name='Partner Community User'].id;
        string certificatename=getCertName();
              insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c =certificatename);//telstrab2b_sandbox
        User u2 = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
         String paramsfinduser = JSON.serialize(
                new Map<String, Object> {
                'userPid' => '',
                'userFirstName'=>'Nikita',
                'userLastName'=>'Tiwa',
                'userEmail'=>'abc@telstra.com',
                'isPDUA'=>'false',
                'isDeactivate'=>'false',
                'pimsAPIType'=>'MANAGEUSER',
                'pageObjectID'=>con.id,
                'mobileNumber'=>'0419111000',
                 'pimsCallType'=>'finduser'
    });
            HttpResponse resfinduser = new HttpResponse();
            resfinduser.setStatusCode(200);
            resfinduser.setHeader('Content-Type', 'application/json');
            resfinduser.setBody('{"data":{"userPid": "P500147","userFirstName": "first","userLastName": "name","userEmail": "P500147@retail1.telstra.com","orgId": 43,"userType": "OTHER","isDeactivate": "FALSE","userMobileNumber": "","isPDUA": "FALSE","partnerLevelId": "Premise", "retailLiveId": "PDUA","positionTypeId": "TLS Shop Sales Rep","partnerNameId": "TLS WAURN PONDS_","partnerCodeId": "LA8H","timezone": "", "userOrgCategory": "TCW"},"description": "User found: P504303.","pimsStatus": 0}');
           HttpResponse resfindusercase1 = new HttpResponse();
           resfindusercase1.setStatusCode(200);
           resfindusercase1.setHeader('Content-Type', 'application/json');
            resfindusercase1.setBody('{"data":{"orgId": -1},"description": "User not found: .","pimsStatus": -1}');
    IntegrationRecordHandlerUtilCalloutMock mock= new IntegrationRecordHandlerUtilCalloutMock();
            WrapperMSPIMSParams.WrapperPageParameters stateFindUser=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) paramsfinduser, WrapperMSPIMSParams.WrapperPageParameters.class);
            ContinuationController.WrapperState wrpstatefinduser= new ContinuationController.WrapperState();
            wrpstatefinduser.pageParams=stateFindUser;
            wrpstatefinduser.requestTime=DateTime.now();
            object str9=ManagePIMSController.parsePIMSResponse(resfinduser,wrpstatefinduser);        
            WrapperMSPIMSParams.WrapperPageParameters stateFindUsercase1=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) paramsfinduser, WrapperMSPIMSParams.WrapperPageParameters.class);
            ContinuationController.WrapperState wrpstatefindusercase1= new ContinuationController.WrapperState();
            wrpstatefindusercase1.pageParams=stateFindUsercase1;
            wrpstatefindusercase1.requestTime=DateTime.now();
            object Resultfinduser=ManagePIMSController.parsePIMSResponse(resfindusercase1,wrpstatefinduser);
    System.assert( Null!=Resultfinduser,'Resultfinduser' );
            test.stoptest();
    }
      @istest
    public  static void testManageparsePIMSResponsecase2(){
        ManagePIMSController pimscontroller = new ManagePIMSController();
        String methodName = 'callPIMS';
        Account ac = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
        Account ac1 = [select id,name,Account_Status__c,Overall_Accreditation__c from account where name='TelecomAC1' limit 1];
        Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
        id p = [select id from profile where name='Partner Community User'].id;
        string certificatename=getCertName();
              insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c =certificatename);//telstrab2b_sandbox
        User u2 = [select id,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
           String params6 = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEUSER',
            'pageObjectID'=>con.id,
            'mobileNumber'=>'0419111000',
             'pimsCallType'=>'updateUser'
        });
        String params = JSON.serialize(
            new Map<String, Object> {
            'userPid' => '',
            'userFirstName'=>'Nikita',
            'userLastName'=>'Tiwa',
            'userEmail'=>'abc@telstra.com',
            'isPDUA'=>'false',
            'isDeactivate'=>'false',
            'pimsAPIType'=>'MANAGEORG',
            'pageObjectID'=>ac.id,
            'mobileNumber'=>'0419111000',
            'pimsCallType'=>'createOrg'
        });
    test.starttest();       
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "title": "Success", "status": "200","orgId": "34535","pimsStatus": 0,"description": "Other"}');
        WrapperMSPIMSParams.WrapperPageParameters state6=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params6, WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate6= new ContinuationController.WrapperState();
        wrpstate6.pageParams=state6;
        wrpstate6.requestTime=DateTime.now();
        object str6=ManagePIMSController.parsePIMSResponse(res,wrpstate6);
         //Error Case response 400 
        HttpResponse resError = new HttpResponse();
        resError.setStatusCode(400);
        resError.setHeader('Content-Type', 'application/json');
        resError.setBody('{ "title": "Exception", "status": "400","orgId": "34535","pimsStatus": -1,"description": "Other"}');
        WrapperMSPIMSParams.WrapperPageParameters state7=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params, WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate7= new ContinuationController.WrapperState();
        wrpstate7.pageParams=state7;
        wrpstate7.requestTime=DateTime.now();
        object str7=ManagePIMSController.parsePIMSResponse(resError,wrpstate7);        
        //Error Case response 500
        HttpResponse resError500 = new HttpResponse();
        resError500.setStatusCode(500);
        resError500.setHeader('Content-Type', 'application/json');
        resError500.setBody('{ "title": "Exception", "status": "500","orgId": "34535","pimsStatus": -1,"description": "Other"}');
         WrapperMSPIMSParams.WrapperPageParameters state8=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params, WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate8= new ContinuationController.WrapperState();
        wrpstate8.pageParams=state8;
        wrpstate8.requestTime=DateTime.now();
        object str8=ManagePIMSController.parsePIMSResponse(resError500,wrpstate8);
        WrapperMSPIMSParams.WrapperPageResponse resp=ManagePIMSController.getExceptionErrorResponse('Test','Test');
        //Error Case response 300
        HttpResponse resError300 = new HttpResponse();
        resError300.setStatusCode(300);
        resError300.setHeader('Content-Type', 'application/json');
        resError300.setBody('{ "title": "Exception", "status": "300","orgId": "34535","pimsStatus": -3,"description": "Other"}');
         WrapperMSPIMSParams.WrapperPageParameters state9=(WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String) params, WrapperMSPIMSParams.WrapperPageParameters.class);
        ContinuationController.WrapperState wrpstate9= new ContinuationController.WrapperState();
        wrpstate9.pageParams=state9;
        wrpstate9.requestTime=DateTime.now();
        object str9=ManagePIMSController.parsePIMSResponse(resError300,wrpstate9);
        test.stopTest();
               System.assert( Null!=str8,'Resultfinduser' );
       }
    
    @istest
    public  static void test_getPartnerRolesfromMDT(){
        List<PRM_Manage_User_Onboarding__mdt> records = new List<PRM_Manage_User_Onboarding__mdt>();
        Test.startTest();
        records = ManagePIMSController.getPartnerRolesfromMDT();
        Test.stopTest();
        System.assert(records.size()>0);
    }
    
    @istest
    public  static void test_getDeactivateReasonPicklist(){
        List<String> options = new List<String>();
        Test.startTest();
        options = ManagePIMSController.getDeactivateReasonPicklist();
        Test.stopTest();
        System.assert(options.size()>0);
    }
}