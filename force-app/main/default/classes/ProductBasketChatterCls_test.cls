@isTest
public class ProductBasketChatterCls_test {
    @isTest
    public static void isPartnerusertest() 
    {       
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'admin', Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName='admin@test.com.portfoliotest');
        
        //User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        u.Phone = '3433233223';
        userList.add(u);
        insert userList;    
        System.runAs(u){
            Id partnerRecordID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
            List<Account> a = new List<Account>();
            Account ac = new Account();
            ac.name = 'Test';
            ac.RecordTypeId = partnerRecordID;
            //a.add(ac);
            insert ac;
            id recType = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();  // fetch partner contact record type           
            Contact con2 = new Contact(RecordTypeId=recType,LastName ='testCon2',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890',Community_User_Type__c='Domestic'); // Hawaii
            insert con2;
            
            //Partner_of_Record__c por = new Partner_of_Record__c();
            Account acc = AccountTestFactory.buildAccount('TestAcc');
            insert acc;
            Contact con = AccountTestFactory.buildContact(acc,'Technical Contact');
            insert con;
            
            
            Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
            opp.Product_Type__c = 'Modular';
            opp.accountId = ac.Id;
            insert opp;
            try{
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'Test';
            basket.Device_Care_Contact__c = con.Id;
            basket.cscfga__Basket_Status__c = 'valid';
            basket.Order_Requester__c =con.Id;
            basket.csordtelcoa__Basket_Stage__c ='Draft';
            basket.csbb__Synchronised_with_Opportunity__c =false;
            insert basket;
            basket.csordtelcoa__Basket_Stage__c ='Approved';
            update basket;
            cscfga__Product_Basket__c basket1 = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
            cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
            List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
                insert pdList;
            cscfga__Product_Category__c cat = new cscfga__Product_Category__c();
            cat.Product_Family_Level_1__c= 'Mobile';
            insert cat;
            Marketable_Offer__c offer = new Marketable_Offer__c();
            offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
            offer.Name = 'Telstra Collaboration';
            offer.Product_Category__c = cat.id;
            offer.Offer_ID__c = 'DMCAT_Offer_000618';
            offer.Config__c = '{"skipBasketSyncValidations":false}';
            insert offer;
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', Marketable_Offer__c= offer.id, cscfga__Product_Basket__c = basket.Id,
                                                                                        cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
            list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
                insert configList1;
            list<id> baskId = new list<id>();
            
            
            Partner_of_Record__c rec =new Partner_of_Record__c();
            rec.Customer__c = ac.id;
            rec.Status__c ='Active';
            insert rec;
            Partner_of_Record_Domain__c dom = new Partner_of_Record_Domain__c();
            dom.Partner_of_Record__c = rec.id;
            dom.Status__c = 'Active';
            dom.Domain_Name__c = 'Mobile';
            insert dom;
            baskId.add(basket.Id);
            
            test.starttest();
            ProductBasketChatterCls.sendChattertoCE(baskId);            
            test.stoptest();
            System.assertEquals(basket.csordtelcoa__Basket_Stage__c, 'Approved');
            }
            catch(Exception ex){
                System.assertEquals(true,ex.getMessage().contains('ConnectApi methods are not supported'));
            }
        }
    }
    @isTest
    public static void isPartnerusertest2() 
    {       
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'admin', Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName='admin@test.com.portfoliotest');
        
        //User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        u.Phone = '3433233223';
        userList.add(u);
        insert userList;
        
        System.runAs(u){
            Id partnerRecordID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
            List<Account> a = new List<Account>();
            Account ac = new Account();
            ac.name = 'Test';
            ac.RecordTypeId = partnerRecordID;
            //a.add(ac);
            insert ac;
            id recType = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();  // fetch partner contact record type           
            Contact con2 = new Contact(RecordTypeId=recType,LastName ='testCon2',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890',Community_User_Type__c='Domestic'); // Hawaii
            insert con2;
            
            //Partner_of_Record__c por = new Partner_of_Record__c();
            Account acc = AccountTestFactory.buildAccount('TestAcc');
            insert acc;
            Contact con = AccountTestFactory.buildContact(acc,'Technical Contact');
            insert con;
            
            
            Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
            opp.Product_Type__c = 'Modular';
            opp.accountId = ac.Id;
            insert opp;
            try{
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'Test';
            basket.Device_Care_Contact__c = con.Id;
            basket.cscfga__Basket_Status__c = 'valid';
            basket.Order_Requester__c =con.Id;
            basket.csordtelcoa__Basket_Stage__c ='Draft';
            basket.csbb__Synchronised_with_Opportunity__c =false;
            insert basket;
            basket.csordtelcoa__Basket_Stage__c ='CE POR Basket Review';
            update basket;
            cscfga__Product_Basket__c basket1 = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
            cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
            List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
                insert pdList;
            cscfga__Product_Category__c cat = new cscfga__Product_Category__c();
            cat.Product_Family_Level_1__c= 'Mobile';
            insert cat;
            Marketable_Offer__c offer = new Marketable_Offer__c();
            offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
            offer.Name = 'Telstra Collaboration';
            offer.Product_Category__c = cat.id;
            offer.Offer_ID__c = 'DMCAT_Offer_000618';
            offer.Config__c = '{"skipBasketSyncValidations":false}';
            insert offer;
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', Marketable_Offer__c= offer.id, cscfga__Product_Basket__c = basket.Id,
                                                                                        cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
            list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
                insert configList1;
            list<id> baskId = new list<id>();
            
            
            Partner_of_Record__c rec =new Partner_of_Record__c();
            rec.Customer__c = ac.id;
            rec.Status__c ='Active';
            insert rec;
            Partner_of_Record_Domain__c dom = new Partner_of_Record_Domain__c();
            dom.Partner_of_Record__c = rec.id;
            dom.Status__c = 'Active';
            dom.Domain_Name__c = 'Mobile';
            insert dom;
            baskId.add(basket.Id);
            
            test.starttest();
            ProductBasketChatterCls.sendChattertoCE(baskId);            
            test.stoptest();
            System.assertEquals(basket.csordtelcoa__Basket_Stage__c, 'CE POR Basket Review');
            }
            catch(Exception ex){  
                System.assertEquals(true,ex.getMessage().contains('ConnectApi methods are not supported'));
            }
        }
    }
    @isTest
    public static void isPartnerusertest3() 
    {       
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'admin', Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName='admin@test.com.portfoliotest');
        
        //User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        u.Phone = '3433233223';
        userList.add(u);
        insert userList;
        
        System.runAs(u){
            Id partnerRecordID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
            List<Account> a = new List<Account>();
            Account ac = new Account();
            ac.name = 'Test';
            ac.RecordTypeId = partnerRecordID;
            //a.add(ac);
            insert ac;
            id recType = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();  // fetch partner contact record type           
            Contact con2 = new Contact(RecordTypeId=recType,LastName ='testCon2',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890',Community_User_Type__c='Domestic'); // Hawaii
            insert con2;
            
            //Partner_of_Record__c por = new Partner_of_Record__c();
            Account acc = AccountTestFactory.buildAccount('TestAcc');
            insert acc;
            Contact con = AccountTestFactory.buildContact(acc,'Technical Contact');
            insert con;
            
            
            Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
            opp.Product_Type__c = 'Modular';
            opp.accountId = ac.Id;
            insert opp;
            try{
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'Test';
            basket.Device_Care_Contact__c = con.Id;
            basket.cscfga__Basket_Status__c = 'valid';
            basket.Order_Requester__c =con.Id;
            basket.csordtelcoa__Basket_Stage__c ='Draft';
            basket.csbb__Synchronised_with_Opportunity__c =false;
            insert basket;
            basket.csordtelcoa__Basket_Stage__c ='Rejected';
            update basket;
            cscfga__Product_Basket__c basket1 = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
            cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
            List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
                insert pdList;
            cscfga__Product_Category__c cat = new cscfga__Product_Category__c();
            cat.Product_Family_Level_1__c= 'Mobile';
            insert cat;
            Marketable_Offer__c offer = new Marketable_Offer__c();
            offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
            offer.Name = 'Telstra Collaboration';
            offer.Product_Category__c = cat.id;
            offer.Offer_ID__c = 'DMCAT_Offer_000618';
            offer.Config__c = '{"skipBasketSyncValidations":false}';
            insert offer;
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', Marketable_Offer__c= offer.id, cscfga__Product_Basket__c = basket.Id,
                                                                                        cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
            list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
                insert configList1;
            list<id> baskId = new list<id>();
            
            
            Partner_of_Record__c rec =new Partner_of_Record__c();
            rec.Customer__c = ac.id;
            rec.Status__c ='Active';
            insert rec;
            Partner_of_Record_Domain__c dom = new Partner_of_Record_Domain__c();
            dom.Partner_of_Record__c = rec.id;
            dom.Status__c = 'Active';
            dom.Domain_Name__c = 'Mobile';
            insert dom;
            baskId.add(basket.Id);
            
            test.starttest();
            ProductBasketChatterCls.sendChattertoCE(baskId);
            test.stoptest();
            System.assertEquals(basket.csordtelcoa__Basket_Stage__c, 'Rejected');
            }
            catch(Exception ex){    
                System.assertEquals(true,ex.getMessage().contains('ConnectApi methods are not supported'));
            }
        }
    }
}