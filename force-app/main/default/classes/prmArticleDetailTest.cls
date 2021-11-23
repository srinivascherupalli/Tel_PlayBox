/*********** 
 * Team : Hawaii
 * Description : This test class covers 'prmArticleDetail' class.Modified assert statement to cover modified logic in class
 *              prmArticleDetail as part of Jira : P2OB-7463
 * Jira : P2OB-7463
 * Modified Date : 20/7/2020
 Date            Version             Modified By             Desc
 8-Aug-2020        1                 Hawaii                  P2OB-8030 && P20B-7893 : Added coverage for method getArticleCategory 
 18-Aug-2020       2                 Hawaii                  P2OB-8030 && P20B-7893 : Test Class fix for QA2 deployment
 6 Sept-2020       3                 Hawaii                  P20B-9098 - Cover method 'getFilterMetadata'in prmArticleDetail class
 19-March-2021     4                 Hawaii                  P2OB-12539 - Test Recommendation Logic
 *****************/
@isTest
public with sharing class prmArticleDetailTest {                 

    Static List<String> categoryName = new List<String>();
    Static List<String> categoryLabel = new List<String>();
    @isTest
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
            
            List<Partner_Content__c> partnerContent = new List<Partner_Content__c>();
            
            Partner_Content__c partnerContent1 = new Partner_Content__c();
            partnerContent1.Title__c = 'Test Partner Content';
            partnerContent1.Image__c = 'Iamge data';
            partnerContent1.Image_Description__c = 'Image Description';
            partnerContent1.Content_Type__c = 'Offer';
            partnerContent1.Ownerid = adminUser[0].id;
            partnerContent1.Active__c = true;
            partnerContent1.Featured_Image__c = 'https://test.com';
            
            partnerContent.add(partnerContent1);
            
            knowledgeCommunityName__c setting = new knowledgeCommunityName__c();
                setting.Name = 'EDGE Partners';
                setting.comm_name__c = 'EDGE Partners';
            insert setting;
            
            Id generalRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('General_Content').getRecordTypeId();
            Id enterpriseRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Enterprise_Partner_Knowledge_Content').getRecordTypeId();
            Id faqRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('FAQ').getRecordTypeId();
                
            List<Knowledge__kav> kvlist=new List<Knowledge__kav>();
                
            Knowledge__kav akv1=new Knowledge__kav();
                akv1.UrlName='testurl';
                akv1.Title='Test akv';
                akv1.Sub_Title__c = 'Test SubTitle';
                akv1.Summary = 'Test Summary';
                akv1.RecordTypeId = generalRecordTypeId;
                akv1.IsVisibleInPrm = true;
            kvlist.add(akv1);
                
            Knowledge__kav akv2=new Knowledge__kav();
                akv2.UrlName='testurl1';
                akv2.Title='Test akv1';
                akv2.Sub_Title__c = 'Test SubTitle1';
                akv2.Summary = 'Test Summary1';
                akv2.RecordTypeId = enterpriseRecordTypeId;
                akv2.IsVisibleInPrm = true;
            kvlist.add(akv2);
            
            Knowledge__kav akv3=new Knowledge__kav();
                akv3.UrlName='testurl2';
                akv3.Title='Test akv2';
                akv3.Sub_Title__c = 'Test SubTitle2';
                akv3.Summary = 'Test Summary2';
                akv3.RecordTypeId = faqRecordTypeId;
                akv3.IsVisibleInPrm = true;
            kvlist.add(akv3);
            
            //P2OB-12539 - Create article for recommendations
            Knowledge__kav akv4=new Knowledge__kav();
                akv4.UrlName='testurl3';
                akv4.Title='Test akv3';
                akv4.Sub_Title__c = 'Test SubTitle3';
                akv4.Summary = 'Test Summary3';
                akv4.RecordTypeId = faqRecordTypeId;
                akv4.IsVisibleInPrm = true;
                akv4.Publish_as_Recommendation_on_TPC__c = true;
                akv4.TPC_Publish_Page__c = 'TPC Home Page';
                akv4.Publish_for_Number_of_Days__c = 2;
            kvlist.add(akv4);
                
            Insert kvlist;
                
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = kvlist[2].Id;
            Test.setFixedSearchResults(fixedSearchResults);
                
            Knowledge__kav[] listArticle = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav WHERE id IN :  kvlist];
                
            KbManagement.PublishingService.publishArticle(listArticle[0].KnowledgeArticleId, true);
            KbManagement.PublishingService.publishArticle(listArticle[1].KnowledgeArticleId, true);
            KbManagement.PublishingService.publishArticle(listArticle[2].KnowledgeArticleId, true);
            //P2OB-12539 - Publish article for recommendations
            KbManagement.PublishingService.publishArticle(listArticle[3].KnowledgeArticleId, true);
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
                dataCategory1.DataCategoryName = (categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management');
            dataCategorySelectionList.add(dataCategory1);
                
            Knowledge__DataCategorySelection dataCategory2 = new Knowledge__DataCategorySelection();
                dataCategory2.ParentId = listArticle[1].Id;
                dataCategory2.DataCategoryGroupName = 'Partner';
                dataCategory2.DataCategoryName = (categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management');
            dataCategorySelectionList.add(dataCategory2);
            
            Knowledge__DataCategorySelection dataCategory3 = new Knowledge__DataCategorySelection();
                dataCategory3.ParentId = listArticle[2].Id;
                dataCategory3.DataCategoryGroupName = 'Partner';
                dataCategory3.DataCategoryName = (categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Onboarding');
            dataCategorySelectionList.add(dataCategory3);
            
             //P2OB-12539 - assign article for recommendations to category
            Knowledge__DataCategorySelection dataCategory4 = new Knowledge__DataCategorySelection();
                dataCategory4.ParentId = listArticle[3].Id;
                dataCategory4.DataCategoryGroupName = 'Partner';
                dataCategory4.DataCategoryName = (categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Onboarding');
            dataCategorySelectionList.add(dataCategory4);
                
                
            insert dataCategorySelectionList;

            System.assert(listArticle[0].id != null);
            System.assert(listArticle[1].id != null);
        }
    }

    // P2OB-8030 && P20B-7893 : Added additional method call for getArticleCategory method
    @isTest
    public static void testGetArticleDetail(){
        testData();
        Test.startTest();
            User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') AND Profile.Name = 'PRM Community User - Australia' order by Profile.Name asc];
            system.runAs(usr[0]){
                String urlName = 'testurl';
                new prmArticleDetail();
                prmArticleDetail.KnowledgeArticleWrapper kaWrapper = prmArticleDetail.getArticleDetail(urlName);
                System.assert(kaWrapper.articleDetail.Id != null);
                List<PRMCarouselWrapper> prmCarWrp1 = prmArticleDetail.getArticleCategory('',(categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management'),false,'',9,'','','',false);
                List<PRMCarouselWrapper> prmCarWrp2 = prmArticleDetail.getSupportQuestionArticleCategory((categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management'));
                List<PRMCarouselWrapper> prmCarWrp3 = prmArticleDetail.getArticleCategory('Test',(categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management'),false,'',9,'','','',false);
                List<PRMCarouselWrapper> prmCarWrp4 = prmArticleDetail.getArticleCategory('Test',(categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management'),true,'',9,'','','',false);
                List<PRMCarouselWrapper> prmCarWrp5 = prmArticleDetail.getArticleCategory('','',false,'',9,'','','',false);
                List<PRMCarouselWrapper> prmCarWrp6 = prmArticleDetail.getSupportQuestionArticleCategory(categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management');
                List<PRMCarouselWrapper> prmCarWrp7 = prmArticleDetail.getArticleCategory('',(categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management'),true,'',9,'','','',false);
                List<PRMCarouselWrapper> prmCarWrp8 = prmArticleDetail.getArticleCategory('','All',false,'',9,'','','',false);
                //P2OB-12539 - Test Recommendation Logic
                List<PRMCarouselWrapper> prmCarWrp9 = prmArticleDetail.getArticleCategory('','',false,'',9,'','','',true);
                // P2oB-8434 - check excluded Categories 
                List<String> excludedCategories = prmArticleDetail.getExcludedCategories();
                //P20B-9098 - cover getFilterMetadata method
                List<prmArticleDetail.filterWrapper> filterWrap = prmArticleDetail.getFilterMetadata('Event');
                system.assertEquals(filterWrap.size() > 0,true);
                System.assert(excludedCategories.size()>0);
                System.assert(prmCarWrp1.size()>0);
                System.assert(prmCarWrp3.size()>0);
                System.assert(prmCarWrp4.size()>0);
                System.assert(prmCarWrp5 != null);
                System.assert(prmCarWrp6.size()>0);
                System.assert(prmCarWrp9 != null);
            }
        Test.stopTest(); 
    }
}