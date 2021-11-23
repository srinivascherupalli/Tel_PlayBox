@isTest
public class TransitionAutoConfigHelperTest {
    @TestSetup   public static void dataSetup(){
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia','Migration BOH user')]){
            profilesMap.put(profile.Name, profile); 
        }
        
        
        User migrationUser = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =profilesMap.get('Migration BOH user').id, country='United States',IsActive =true,                
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser@test.com');
        insert migrationUser; 
        
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        Id recodtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        system.runAs(migrationUser){
            Opportunity migrationOpp = new Opportunity();
            migrationOpp.RecordtypeId = recodtypeId;
            migrationOpp.AccountId = acc.Id;
            migrationOpp.Name = 'Migration Opportunity';
            migrationOpp.Product_Domain__c = 'OTHER';
            migrationOpp.StageName = 'Develop';
            migrationOpp.Product_Type__c = 'Modular';
            migrationOpp.CloseDate = System.Date.today();
            migrationOpp.Description__c = 'test';
            migrationOpp.Type = 'Migration';
            migrationOpp.Billing_Solution__c = 'Standard';
            insert migrationOpp;
            
            cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
            migrationOppBasket.csbb__Account__c = acc.Id;
            migrationOppBasket.AutoConfigStage__c='Not Initiated';
            migrationOppBasket.Name = 'Migration Opportunity Basket';
            migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
            migrationOppBasket.cscfga__Basket_Status__c  = 'Valid';  
            insert migrationOppBasket;
        }
    }
    
    @IsTest public static void setBasketAutoConfigInProgressStatusTest(){
        Test.startTest();
        cscfga__Product_Basket__c basket=[SELECT id,AutoConfigStage__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name=:'Migration Opportunity']; 
        basket.AutoConfigStage__c='In Progress';
        update basket;
        TransitionAutoConfigHelper.checkBasketAutoConfigStatus(new List<string>{basket.Id});
        List<FeedItem> feedItemList=[SELECT Body,Id,ParentId,Status,Title,Type FROM FeedItem WHERE ParentId =:basket.cscfga__Opportunity__c ];
        system.assert( basket.AutoConfigStage__c=='In Progress');
        Test.stopTest();
    }
    @IsTest public static void setBasketAutoConfigCompletedStatusTest(){
        Test.startTest();
        cscfga__Product_Basket__c basket=[SELECT id,AutoConfigStage__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name=:'Migration Opportunity']; 
        basket.AutoConfigStage__c='Completed';
        update basket;
        TransitionAutoConfigHelper.checkBasketAutoConfigStatus(new List<string>{basket.Id});
        List<FeedItem> feedItemList=[SELECT Body,Id,ParentId,Status,Title,Type FROM FeedItem WHERE ParentId =:basket.cscfga__Opportunity__c ];
        system.assert( basket.AutoConfigStage__c=='Completed');
        Test.stopTest();
    }
    @IsTest public static void setBasketAutoConfigFailedStatusTest(){
        Test.startTest();
        cscfga__Product_Basket__c basket=[SELECT id,AutoConfigStage__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name=:'Migration Opportunity']; 
        basket.AutoConfigStage__c='Failed';
        update basket;
        TransitionAutoConfigHelper.checkBasketAutoConfigStatus(new List<string>{basket.Id});
        List<FeedItem> feedItemList=[SELECT Body,Id,ParentId,Status,Title,Type FROM FeedItem WHERE ParentId =:basket.cscfga__Opportunity__c ];
        system.assert(basket.AutoConfigStage__c=='Failed');
        Test.stopTest();
    } 
}