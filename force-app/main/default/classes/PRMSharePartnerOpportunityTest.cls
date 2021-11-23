/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   23/9/2019
Desc                :   This Class is test class for 'PRMSharePartnerOpportunity' 
12 Nov 2021 : removing account lookup assignment from Contact for 21.15 FDR fix                       // DUPLICATE_USERNAME fix      
***********************************************************************/
@isTest
public class PRMSharePartnerOpportunityTest {

    @testSetup static void setup() {
        Map<String,Profile> profileMap = new Map<String,Profile>();
        Profile[] partnerProfile = [Select id,Name from Profile where Name IN ('PRM Community User - Australia','System Administrator')];
        
        for(Profile prof : partnerProfile){
            profileMap.put(prof.Name,prof);
        }
        
        UserRole userRole = [Select id,Name from UserRole where Name = 'CEO']; 
        // DUPUPLICATE_USERNAME - Hawaii - 02-09-2020
        List<User> adminUserList = PRMTestUtility.createInternalUsers(2, new List<Profile>{profileMap.get('System Administrator')}, userRole) ;
        insert adminUserList;
       /* User systemAdminUser = new User(alias = 'PART', email='test@noemail1234.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileMap.get('System Administrator'), country='United States',IsActive =true,
            timezonesidkey='America/Los_Angeles', username='test@noemail.com1',UserRoleId=userRole.Id);
            adminUserList.add(systemAdminUser);
        User systemAdminUser1 = new User(alias = 'PART', email='test@noemail1234.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileMap.get('System Administrator'), country='United States',IsActive =true,
            timezonesidkey='America/Los_Angeles', username='test1@noemail.com1',UserRoleId=userRole.Id);
            adminUserList.add(systemAdminUser1);
        
        insert adminUserList;*/

         
        
        system.runas(adminUserList[0]){ 
        
            List<Account> accList = new List<Account>();
            Id EntAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
            Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
            Account acc = new Account();
                acc.Name = 'Test Accountdit';
                acc.recordTypeId=EntAccRecTypeId ;
                acc.Partner_Type__c='Channel';
                acc.Customer_Status__c='ACTIVE';
                acc.Migrated_Customer__c=true;
                acc.OwnerId = adminUserList[0].Id;
                acc.UCIDN__c = 'VI28909';
                accList.add(acc);
            insert accList;
        
            List<Contact> conList = new List<Contact>();
                Contact con = new Contact();
                    con.FirstName = 'Test Account';
                    con.LastName='Last Name';
                    con.AccountId=accList[0].Id;
                conList.add(con);
              Contact partCon = new Contact();
                    partCon.FirstName = 'Test Account1';
                    partCon.LastName='Last Name1';
                    //partCon.AccountId=accList[0].Id; // 21.15 FDR fix
              conList.add(partCon);
            insert conList;
            
            Account partneracc = new Account();
            partneracc.RecordTypeId = partnerAccRecTypeId;
            partneracc.Name = 'Test Accountdit2';
            partneracc.Account_Status__c = 'Active';
            partneracc.Customer_Trading_Name__c = 'Test';
            partneracc.ABN__c = 'aaaa';
            partneracc.ACN__c = 'ccc';
            partneracc.State_Coverage__c = 'VIC';
            partneracc.Partner_Type__c = 'Distributor';
            partneracc.Website = 'www.vsygqwoci.com';
            partneracc.Phone = '0412354323';
            partneracc.Overall_Accreditation__c = 'Platinum';
            partneracc.Mobility_Accreditation__c = 'Platinum';
            partneracc.Cloud_Accreditation__c = 'Platinum';
            partneracc.Data_Security_Accreditation__c = 'Platinum';
            partneracc.Collaboration_Accreditation__c = 'Platinum';
            partneracc.PartnerPrincipalContact__c = conList[0].id;
            partneracc.UCIDN__c = 'VI28909';
                
            insert partnerAcc;
            accList.add(partnerAcc);
            accList[1].isPartner = True;
            accList[1].PartnerPrincipalContact__c = conList[1].Id;
            update accList[1];
            conList.get(1).AccountId = accList[1].Id;
            update conList;
            
            // DUPLICATE_USERNAME - Hawaii - 02-09-2020
            List<User> userList = PRMTestUtility.createPartnerUsers(1, new List<Profile>{profileMap.get('PRM Community User - Australia')}, new List<Contact>{conList[1]},true);
            insert userList;
            
            /*List<User> userList = new List<User>();
            User partUser = new User(alias = 'PART', email='test@noemail345555.com',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = profileMap.get('PRM Community User - Australia'), country='United States',IsActive =true,
                        ContactId = conList[1].Id,isPRMSuperUser=True, 
                        timezonesidkey='America/Los_Angeles', username='test@noemail.com');
                        userList.add(partUser);
             
            insert userList;*/
            
            AccountShare[] shareList = new List<AccountShare>();
                AccountShare share = new AccountShare();
                    share.AccountId = accList[0].Id;
                    share.UserOrGroupId = userList[0].Id;
                    share.AccountAccessLevel = 'Read';
                    share.CaseAccessLevel = 'Read';
                    share.OpportunityAccessLevel = 'Read';
                    shareList.add(share);
                AccountShare partshare = new AccountShare();
                    partshare.AccountId = accList[1].Id;
                    partshare.UserOrGroupId = userList[0].Id;
                    partshare.AccountAccessLevel = 'Read';
                    partshare.CaseAccessLevel = 'Read';
                    partshare.OpportunityAccessLevel = 'Read';
                    shareList.add(partshare);
             insert shareList;
            
            system.runas(userList[0]){
                PRM_Default__c prmDefault = new PRM_Default__c();
                    prmDefault.TBTCProfile1__c = '';
                    prmDefault.Partner_Opportunity_Amount__c = 0;
                    prmDefault.Partner_Opportunity_Verification__c = true;
                    prmDefault.Partner_Opp_Conflict_Number_of_Days__c = 5;
                insert prmDefault;
                Id partnerRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
                List<Opportunity> oppList = new List<Opportunity>();
                Opportunity opp1 = new Opportunity();
                    opp1.AccountId = accList[0].Id;
                    opp1.recordTypeId=partnerRecTypeId ;
                    opp1.Name = 'Test Opp 1';
                    opp1.Proposal_Required_Date__c = System.today() + 2;
                    opp1.CloseDate = System.today() + 40;
                    opp1.StageName = 'Develop';
                    opp1.Amount = 10;
                    opp1.Description__c = 'Test';
                    opp1.Product_Domain__c = 'MOBILES';
                    opp1.Shared_Opportunity__c = True;
                    opp1.Override_Reason__c = 'Incumbent Partner does not have appropriate coverage';
                    opp1.SubmittoPartnerStatus__c = 'Submitted';
                    opp1.Associated_Distributor__c = accList[1].Id;
                    oppList.add(opp1);
                Test.startTest();
                insert oppList;
                system.debug('oppList value is'+oppList);
                Test.stopTest();
            }
        }
    }
    
    public static testMethod void testFetchOpportunityDetails(){
        Test.startTest();
        User use = [Select id,Name,Profile.Name from User where email = 'test@noemail1234.com0' and Profile.Name = 'System Administrator'];
        system.runAs(use){
            Distributor_Model_Setting__c disModel = new Distributor_Model_Setting__c();
                disModel.isEnabled__c =True;
            insert disModel;
            
            Account accNew = [Select id,Primary_Distributor__c,Account_Status__c from Account where Name = 'Test Accountdit2'];
            Opportunity oppListNew = [Select id,Name,Distributor_Contact__r.Name,Associated_Distributor__r.Name from Opportunity where Name = 'Test Opp 1'];
            PRMSharePartnerOpportunity.fetchDistributorSettingDetails();
            PRMSharePartnerOpportunity.fetchOpportunityDetails(oppListNew.Id);
            PRMSharePartnerOpportunity.fetchPartnerDetails();
            PRMSharePartnerOpportunity.updateOpportunity(JSON.serialize(accNew),JSON.serialize(oppListNew),'Partner');
            PRMSharePartnerOpportunity.updateOpportunity(JSON.serialize(accNew),JSON.serialize(oppListNew),'Distributor');
            PRMSharePartnerOpportunity.findRecords('Test','Account','Partner',accNew.Id);
            PRMSharePartnerOpportunity.findRecords('Test','Account','Distributor',accNew.Id);
            system.assertEquals(PRMSharePartnerOpportunity.findRecords('Test','Account','Partner',accNew.Id).size(),1);
        }
        Test.stopTest();
        
    }
}