@isTest
public class C2O_NumberTriggerTest { 
    @Testsetup
    static void dataSetup(){
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='EnableHV';
        csSite.value__c='True';
        insert csSite;
        
        Environment_Configurations__c csd = new Environment_Configurations__c();
        csd.call_EDIS_Batch__c = true;
        insert csd;
        
        EnvironmentVariable__c tokenCustomSetting = new EnvironmentVariable__c();         
        tokenCustomSetting.Name = 'EnableThrowException';        
        tokenCustomSetting.Value__c = 'false';        
        insert tokenCustomSetting;  
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        insert ordReq2;
        
        csord__Order__c ord1 = ProductTestFactory.buildOrder('Resume_12345', acc.id, 'Created', ordReq2.id);
        ord1.csord__Order_Request__c = ordReq2.Id;
        ord1.csordtelcoa__Opportunity__c = opp.Id;
        insert ord1;
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('Resume_123456', acc.id, 'Created', ordReq2.id);
        ord1.csord__Order_Request__c = ordReq2.Id;
        ord1.csordtelcoa__Opportunity__c = opp.Id;
        insert ord2;
        
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        csord__Subscription__c subRes=new csord__Subscription__c();
        subRes.name  = 'test sub12';
        subRes.csord__Identification__c = 'test identity12';
        subRes.csord__Order__c = ord1.Id;
        subRes.Sub_status__c = 'Active';
        subRes.csord__Status__c='Active';
        subList.add(subRes);
        
        csord__Subscription__c subRes2=new csord__Subscription__c();
        subRes2.name  = 'test sub122';
        subRes2.csord__Identification__c = 'test identity122';
        subRes2.csord__Order__c = ord2.Id;
        subRes2.Sub_status__c = 'Active';
        subRes2.csord__Status__c='Active';
        subList.add(subRes2);
        insert subList;
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        cscfga__Product_Definition__c userPD2 = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductSpecification_001525');
        insert userPD2;
        
        List<cscfga__Product_Configuration__c> lisOfPC = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        lisOfPC.add(userPC);
        cscfga__Product_Configuration__c userPC3 = new cscfga__Product_Configuration__c(Name = 'IP site2', cscfga__Product_Definition__c = userPD2.Id, Quantity_Product_Configuration__c = 3);
        lisOfPC.add(userPC3);
        insert lisOfPC;
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
        
        csord__Service__c servRe = new csord__Service__c();
        servRe.name ='tst servRe';
        servRe.csord__Identification__c  = 'test servRe';
        servRe.csord__Subscription__c = subRes.Id;
        servRe.csord__Status__c = 'Service Created';
        servRe.csord__Order__c = ord1.Id;
        servRe.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(servRe);
        
        csord__Service__c servRe2 = new csord__Service__c();
        servRe2.name ='tst servRe 2';
        servRe2.csord__Identification__c  = 'test servRe 2';
        servRe2.csord__Subscription__c = subRes2.Id;
        servRe2.csord__Status__c = 'Service Created';
        servRe2.csord__Order__c = ord2.Id;
        servRe2.csordtelcoa__Product_Configuration__c = userPC3.id;
        servs.add(servRe2);
        
        csord__Service__c servRe3 = new csord__Service__c();
        servRe3.name ='tst servRe 2';
        servRe3.csord__Identification__c  = 'test servRe 2';
        servRe3.csord__Subscription__c = subRes2.Id;
        servRe3.csord__Status__c = 'Service Created';
        servRe3.csord__Order__c = ord2.Id;
        servRe3.csordtelcoa__Product_Configuration__c = userPC3.id;
        servs.add(servRe3);
        
        
        
        insert servs;
        
        csord__Service__c serv = [select id,csordtelcoa__Service_Number__c from csord__Service__c where id =: servRe.Id limit 1];
        
        List<Number__c> listofNum = new List<Number__c>();
        Number__c num=new Number__c();
        num.name='Num test4';
        num.Subscription_number__c=subRes.csordtelcoa__Subscription_Number__c;
        num.Type__c='New';
        num.Service_Number__c='61474850547';
        num.Status__c='Active';
        num.Product_ID__c='gb58-89jk-yuit-fr46';
        num.Service_Id__c = serv.csordtelcoa__Service_Number__c;
        listofNum.add(num);
        //insert listofNum;
        
        Number__c num2=new Number__c();
        num2.name='Num test6';
        num2.Subscription_number__c=subRes.csordtelcoa__Subscription_Number__c;
        num2.Type__c='New';
        num2.Service_Number__c='62474850547';
        num2.Status__c='Provisioning In Progress';
        num2.Product_ID__c='gb58-89jk-yuit-fr46';
        num2.Product_Configuration__c = userPC3.Id;
        num2.Service_Id__c = servRe3.csordtelcoa__Service_Number__c;
        listofNum.add(num2);
        
        insert listofNum;
    }
    @isTest
    static void testprocessNotificationRecordMSComplete(){
        
        Test.startTest();
      //  BypassTrigger.isRunningTestCheck = true;
        List<Number__c> numlist =[select id,status__c from Number__c];
        if(numlist.size()>0){
            for(Number__c n:numlist){
                n.Status__c = C2O_OrderConstants.ACTIVE;
            }   
            update numlist;
        }
        System.debug('number status...'+numlist);
        
        //delete numlist;
        
        Test.stopTest();
        
    }
}