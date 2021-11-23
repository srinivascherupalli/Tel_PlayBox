/*******************************************************************
Modified By        :  Hawaii
Modified Date      :  22/07/2020
Desc               :  Added test Methods for methods getArticleList,getCategoryList,getArticleCategory in 'PRMOffersCarouse'
                      class.Modified existing testData method to create common test data.
Apex Class Covered : PRMOffersCarousel,PRMCarouselWrapper,PRMKnowledgeArticleUtility and 

Date            Version           Modified By             Desc
22-July-2020      1               Hawaii                  P2OB-7462  
11-Aug-2020       2               Hawaii                  P2OB-8030 && P20B-7893: Added coverage for methods in PRMKnowledgeArticleUtility class 
18-Aug-2020       3               Hawaii                  P2OB-8030 && P20B-7893 : Test Class fix for QA2 deployment
26-Sep-2020       4               Hawaii                  P2OB-9636
19-March-2021     5               Hawaii                  P2OB-12539 - Test Recommendation Logic
***********************************************************************/
@isTest
public with sharing class PRMOffersCarouselTest {
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
                
                Insert kvlist;
                
                
                Knowledge__kav[] listArticle = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav WHERE id IN :  kvlist];
                
                KbManagement.PublishingService.publishArticle(listArticle[0].KnowledgeArticleId, true);
                KbManagement.PublishingService.publishArticle(listArticle[1].KnowledgeArticleId, true);
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
                    dataCategory3.ParentId = listArticle[1].Id;
                    dataCategory3.DataCategoryGroupName = 'Partner';
                    dataCategory3.DataCategoryName = (categoryName.get(1) != '' ? categoryName.get(1) : 'Partner_Onboarding');
                dataCategorySelectionList.add(dataCategory3);
                
            insert dataCategorySelectionList;
            System.assert(listArticle[0].id != null);
            System.assert(listArticle[1].id != null);
        }
    }
    
    @isTest
    public static void testOfferCarouselPartnerData(){
    
        testData();
        Test.startTest();
        List<Network> networkList = [Select id,Name from Network Where Name = 'EDGE Partners' LIMIT 1];
        Knowledge__kav[] obj1 = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav];

        ConnectApi.KnowledgeArticleVersionCollection connectCollection = new ConnectApi.KnowledgeArticleVersionCollection();
        List<ConnectApi.KnowledgeArticleVersion> listKAV = new List<ConnectApi.KnowledgeArticleVersion>();
        ConnectApi.KnowledgeArticleVersion connectKAV = new ConnectApi.KnowledgeArticleVersion();
        connectKAV.knowledgeArticleId = obj1[0].KnowledgeArticleId;

        listKAV.add(connectKAV);

        connectCollection.items = listKAV;

        ConnectApi.Knowledge.setTestGetTrendingArticles(''+networkList[0].Id,5,connectCollection);
        List<PRMCarouselWrapper> lstPartnerContent = PRMOffersCarousel.getOfferCarouselData('Offer',5);

        List<PRMCarouselWrapper> lstPartnerContent1 = PRMOffersCarousel.getOfferCarouselData('Knowledge',5);

        System.assert(lstPartnerContent1.size() > 0);
    
        Test.stopTest();
    }
    
    @isTest
    public static void testGetArticleCategoryGroupList(){
        
            testData();
            
            Test.startTest();

            Map<String,List<Knowledge__DataCategorySelection>> knwlDataCat = PRMOffersCarousel.getArticleCategoryGroupList();

            System.assert(knwlDataCat.containsKey((categoryLabel.get(0) != '' ? categoryLabel.get(0) : 'Partner Deal Management')));


            List<String> partnerList = new List<String>();
            partnerList.add((categoryLabel.get(0) != '' ? categoryLabel.get(0) : 'Partner Deal Management'));

            List<PRMCarouselWrapper> knlwArtclData = PRMOffersCarousel.getKnowldegeArticleData('Test','');

            List<PRMCarouselWrapper> knlwArtclData1 = PRMOffersCarousel.getKnowldegeArticleData('','');
        System.assert(knlwArtclData1.size() > 0);
        Test.stopTest();
    }
    
    //test method to cover getArticleList method
    @isTest
    public static void testGetArticleList(){
        testData();
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') AND Profile.Name = 'PRM Community User - Australia' order by Profile.Name asc];
        system.runAs(usr[0]){
            Map<String,List<Knowledge__DataCategorySelection>> getArticleList = PRMOffersCarousel.getArticleList();
            System.assert(getArticleList.containsKey((categoryLabel.get(0) != '' ? categoryLabel.get(0) : 'Partner Deal Management')));
        }
        Test.stopTest();
    }
    
    //P2OB-7462 : test method to cover getArticleCategory method
    @isTest
    public static void testGetArticleCategory(){
        testData();
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') order by Profile.Name asc];
        system.runAs(usr[0]){
            Knowledge__kav kavArticles = [SELECT Id,Title,KnowledgeArticleId,UrlName FROM Knowledge__kav Where Title = 'Test akv'];
            String getArticleCategory = PRMOffersCarousel.getArticleCategory(kavArticles.UrlName);
            System.assert(getArticleCategory != null); // updated assert
            System.assert(getArticleCategory.contains('topCategoryName'));  // added assert P2OB-9636
        }
        Test.stopTest();
    }
    
    //P2OB-7462 : test method to cover getCategoryList method
    @isTest
    public static void testGetCategoryList(){
        testData();
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') order by Profile.Name asc];
        system.runAs(usr[0]){
            String getCategoryList = PRMOffersCarousel.getCategoryList((categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management'),true);
            System.assert(getCategoryList != '');
        }
        Test.stopTest();
    }
    
    //P2OB-8030 && P20B-7893 : test method to cover getArticleListWithPermissionSet method when user has permission set
    @isTest
    public static void testGetArticleListWithPermissionSet(){
        testData();
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') order by Profile.Name asc];
        
        system.runAs(usr[0]){
            Map<String,List<Knowledge__DataCategorySelection>> getArticleList = PRMOffersCarousel.getArticleList();
            System.assert(getArticleList.containsKey((categoryLabel.get(0) != '' ? categoryLabel.get(0) : 'Partner Deal Management')));
        }
        Test.stopTest();
    }
    
    //P2OB-8030 && P20B-7893 : test method to cover getTrandingKnowledgeArticleIds method when user has permission set
    @isTest
    public static void testGetTrandingKnowledgeArticleIds(){
        testData();
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') order by Profile.Name asc];
        system.runAs(usr[0]){
            //P2OB-12539 - Pass Additional Parameters
            List<PRMCarouselWrapper> wrap = prmArticleDetail.getArticleCategory('','',false,'',9,'','','',false);
            system.assertEquals(wrap != null, true);
        }
        Test.stopTest();
    }
    
    //P2OB-8030 && P20B-7893 : test method to cover getArticleInfo method when user has permission set
    @isTest
    public static void testGetArticleInfo(){
        testData();
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') order by Profile.Name asc];
        system.runAs(usr[0]){
            //P2OB-12539 - Pass Additional Parameters
            List<PRMCarouselWrapper> wrap = prmArticleDetail.getArticleCategory('',(categoryName.get(0) != '' ? categoryName.get(0) : 'Partner_Deal_Management'),false,'',9,'','','',false);
            //P2OB-12539 - Pass Additional Parameters
            List<PRMCarouselWrapper> wrap1 = prmArticleDetail.getArticleCategory('','',false,'',9,'','','',false);
            system.assertEquals(wrap != null, true);
        }
        Test.stopTest();
    }
    
    //P2OB-8030 && P20B-7893 : test method to cover getKnowldegeArticleRecomendedData method when user has permission set
    @isTest
    public static void testGetKnowldegeArticleRecomendedData(){
        testData();
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') order by Profile.Name asc];
        system.runAs(usr[0]){
            List<PRMCarouselWrapper> wrap = PRMOffersCarousel.getKnowldegeArticleRecomendedData();
            system.assertEquals(wrap.size()>0, true);
        }
        Test.stopTest();
    }
}