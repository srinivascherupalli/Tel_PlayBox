/*------------------------------------------------------
Created by Team Hawaii for story number P2OB-9096 
Date - 2nd September 2020
Main Class Covered - PRMEventDetailsContr
--------------------------------------------------------*/

@isTest
public class PRMEventDetailsContrTest {
    Static List<String> categoryName = new List<String>();
    Static List<String> categoryLabel = new List<String>();
    @testSetup
    public static void testData(){
        //Profile Map
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile])
            profilesMap.put(profile.Name, profile);
        //Role Map
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName = 'Sales_Ops'])
            rolesMap.put(role.DeveloperName, role);
        //Create Admin User
        User[] adminUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        adminUser[0].UserPermissionsKnowledgeUser = true;
        insert adminUser;
        List<User> users= new List<User>();
        List<Contact> contactList = new List<Contact>();
        User[] partnerUser=new List<User>();
        //Create Customer Account
        Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
        
        //Run as System Admin
        System.runAs(adminUser[0]){
            //Create Partner Account
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);          
            insert partnerAccount; 
            //Create Partner Contact
            contactList = PRMTestUtility.createContact(2,Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner_Contact').getRecordTypeId(),partnerAccount[0].Id);
            insert contactList;
            partnerAccount[0].isPartner = True;
            partnerAccount[0].PartnerPrincipalContact__c = contactList[0].id;
            partnerAccount[0].CWP_Eligible_Partner__c = false;
            partnerAccount[0].Account_Status__c = 'Active';
            //Update Partner account
            update partnerAccount[0];
            
            //Create Partner User
            partnerUser = PRMTestUtility.createPartnerUsers(2,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,contactList,false);
            users.addAll(partnerUser);
            insert users;
            
            // Create PermissionSet with Custom Permission and assign to test user
            PermissionSet ps = new PermissionSet();
                ps.Name = 'TestNew';
                ps.Label = 'TestNew';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
                sea.ParentId = ps.Id;
                sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'PRM_Active_User'][0].Id;
            insert sea;
            PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = users[0].Id;
                psa.PermissionSetId = ps.Id;
            insert psa;
            
            
            
            knowledgeCommunityName__c setting = new knowledgeCommunityName__c();
                setting.Name = 'EDGE Partners';
                setting.comm_name__c = 'EDGE Partners';
            insert setting;
            
            Id generalRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('General_Content').getRecordTypeId();
            Id enterpriseRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Enterprise_Partner_Knowledge_Content').getRecordTypeId();
                
                List<Knowledge__kav> kvlist=new List<Knowledge__kav>();
                
                Knowledge__kav akv1=new Knowledge__kav();
                    akv1.UrlName='testurl';
                    akv1.Title='Test akv';
                    akv1.Sub_Title__c = 'Test SubTitle';
                    akv1.Summary = 'Test Summary';
                    akv1.RecordTypeId = generalRecordTypeId;
                    akv1.IsVisibleInPrm = true;
                kvlist.add(akv1);
                Insert kvlist;
                
                
                Knowledge__kav[] listArticle = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav WHERE id IN :  kvlist];
                
                KbManagement.PublishingService.publishArticle(listArticle[0].KnowledgeArticleId, true);
                String childcategory = '';
                system.runAs(users[0]){
                    childcategory = PRMKnowledgeArticleUtility.getCategoryList('All',false) != '' ? PRMKnowledgeArticleUtility.getCategoryList('All',false) : 'Partner_Deal_Management,Partner Deal Management';
                }
                List<Object> productCategoryList = (List<Object>) JSON.deserializeUntyped(childcategory);
                if(!productCategoryList.isEmpty()){
                    for(Integer i=0; i<productCategoryList.size();i++){
                        Map<String, Object> categoryMap = (Map<String, Object>)productCategoryList[i];
                        categoryName.add((String)categoryMap.get('name'));
                        categoryLabel.add((String)categoryMap.get('label'));
                    }
                }
            
            List<Knowledge__DataCategorySelection> dataCategorySelectionList = new List<Knowledge__DataCategorySelection>();
                Knowledge__DataCategorySelection dataCategory1 = new Knowledge__DataCategorySelection();
                    dataCategory1.ParentId = listArticle[0].Id;
                    dataCategory1.DataCategoryGroupName = 'Partner';
                    dataCategory1.DataCategoryName = 'Event';
                dataCategorySelectionList.add(dataCategory1);
                
            insert dataCategorySelectionList;
            System.assert(listArticle[0].id != null);
    }
    }
    
	
    @isTest
    static void getArticleDetailTest(){
        Knowledge__kav kArticle = [Select Id from Knowledge__kav];
        
        Test.startTest();
        PRMEventDetailsContr.DetailWrapper w = PRMEventDetailsContr.getArticleDetail(kArticle.Id, 'Knowledge__kav');
        Test.stopTest();
        Knowledge__kav articleAfterRun = (Knowledge__kav) w.articleDetail;
        System.assertEquals(True, w.fieldDetailsList.size()>0);
        System.assertEquals(UserInfo.getTimeZone().toString(), w.userTimeZone);
    }
}