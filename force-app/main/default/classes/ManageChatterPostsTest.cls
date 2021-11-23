@isTest
public with sharing class ManageChatterPostsTest{ 
      @isTest static void ManageChatterTestprmuser(){  
                  list<string> strlist= new list<string>();
     
       User admin = TestUtil.createUser('admin@test.com.LaTest','AdminLA',Label.Profile_SystemAdmin);
        insert admin ;
        
        Id contactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
        Id partnerAccRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); // fetch partner record type
        Contact principleCon = new Contact(LastName ='testPrinCon',Work_Phone_Number__c= '+61123456789',OTP_Mobile_Phone_Number__c='+61123456789',RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG');
        insert principleCon; 
        id prmUser = [select id from profile where name='PRM Community User - Australia'].id;
        Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25,RecordtypeId = partnerAccRecTypeId,
                                Customer_Trading_Name__c = 'Test',
                                ABN__c = 'aaaa',
                                ACN__c = 'ccc',
                                State_Coverage__c = 'VIC',
                                Partner_Type__c = 'Distributor',
                                Website = 'www.vsygqwoci.com',
                                Phone = '0412354323',
                                Overall_Accreditation__c = 'Platinum',
                                Mobility_Accreditation__c = 'Platinum',
                                Cloud_Accreditation__c = 'Platinum',
                                Data_Security_Accreditation__c = 'Platinum',
                                Collaboration_Accreditation__c = 'Platinum',
                                PartnerPrincipalContact__c = principleCon.id
                                );
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG');
        insert con; 
        
        User prm_user= new User(alias = 'test123', email='b2btestewwr@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = prmUser, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='TestManagechatterprm123@noemail.com',contactid=con.id);
        insert prm_user;

     
        Account acc = new Account(Name = 'TestManagechatterAcc');
        acc.Customer_Status__c = 'ACQUIRED';
        acc.Ownerid=prm_user.id;
        insert acc;
        
                          
        Test.startTest();
        system.runas(prm_user){
                  Account Acc1=[select Id,Name,CreatedById from Account where name='TestManagechatterAcc'];
             String str=acc1.id+'!{'+acc1.Createdbyid+' TestMessage-  {record:'+acc1.id;
            strlist.add(str);
            ManageChatterPosts.PostChatterMessage(strlist); 
            
          
            }  
        Test.stopTest();
          system.assert(strlist.size()>0);
        
        
        
     }  
     
@isTest static void TestManagechatterSales(){  
              
        List<user> userList = new List<user>();
                    list<string> strlist= new list<string>();

        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA',Label.Profile_SalesEnterprise);
        User admin = TestUtil.createUser('admin@test.com.LaTest','AdminLA',Label.Profile_SystemAdmin);
        sales.Phone = '0444444444';
        userList.add(sales);
        userList.add(admin);
        insert userList;
        System.runAs(admin){
            Account customerAccount=TestUtil.createAccount('TestManagechatterAcc');
            customerAccount.OwnerId=sales.id;
            customerAccount.CIDN__c='48445074';
            insert customerAccount;
       
        }
        
        System.runAs(sales){
            Test.startTest();
            Account Acc1=[select Id,Name,CreatedById from Account where name='TestManagechatterAcc'];
             String str=acc1.id+'!{'+acc1.Createdbyid+' TestMessage-  {record:'+acc1.id;
            strlist.add(str);
            ManageChatterPosts.PostChatterMessage(strlist); 
          
            
        Test.stopTest();
                    system.assert(strlist.size()>0);     

    }
            
    }
}