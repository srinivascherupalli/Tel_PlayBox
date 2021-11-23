/*************************************************************************************************
EDGE - 92546
Name: NumberManagementHandlerTest
Description: Test class for NumberManagementHelper
Author:Sandip Deshmane
Revision History: EDGE-142086 - Updated for UX Uplift
***************************************************************************************************/
@isTest
public class NumberManagementHandlerTest {
    
    public static Id basketId{get; set;}
    public static Id PCId{get; set;}
    
    @testSetup
    public static void setupdata(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert cont;
        
        csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
        csord__Subscription__c sub =
        ProductTestService.getNewSubscriptionForAccount(acc);
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='test service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order2.id;
        serv.Primary_Contact__c = cont.Id;
        insert serv;
        system.debug('serv1'+serv);
        serv.csordtelcoa__Service_Number__c = 'SVC-000056370';
        update serv;
        system.debug('serv+' +serv);
        
        cscfga__Product_Configuration__c testProductConfiguration =
        TestDataFactory.generateProductConfiguration();
        
        system.debug(testProductConfiguration);
        cscfga__Product_Definition__c
        pd=TestDataFactory.generateProductDefinition();
        pd.Name='Next Generation Voice';
        pd.product_Specification__c='DMCAT_ProductSpecification_000871';
        update pd;
        testProductConfiguration.Type__c='Modify';
        testProductConfiguration.name='Next Generation Voice';
        testProductConfiguration.cscfga__Product_Definition__c=pd.id;
        testProductConfiguration.csordtelcoa__Replaced_Service__c=serv.id;
        update testProductConfiguration;
        PCId=testProductConfiguration.id;
        
        //EDGE-134990 - Added Number record in below Strin.
        Attachment attachment = new Attachment();        
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid": "47705868-4451-b1f8-54af-e262d6d3296b","listCode": "No Entry Line","status": "RESERVED","rangeTo": null,"rangeFrom": null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = String.valueOf('NumberManagementv1_schema.json');
        attachment.ParentId = PCId;
        insert attachment;
        //EDGE-134990 END

        System.debug('***Config Id:'+testProductConfiguration);
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        //EDGE-142086 - Updated for UX Uplift
        Number__c num= new Number__c(Service_Number__c='62384723',Type__c='FNN', Mobile__c='Fixed', Basket__c=basketId,Product_Configuration__c= PCId,Service_Id__c=serv.csordtelcoa__Service_Number__c, Status__c = 'ACTIVE', is_Part_of_Range__c= False);
        insert num;
        Number__c num2= new Number__c(Service_Number__c='62384724',Type__c='FNN',Mobile__c='Fixed', Basket__c=basketId,Product_Configuration__c= PCId,Service_Id__c=serv.csordtelcoa__Service_Number__c,Start_Range__c='62384722',End_Range__c='62384724',Status__c = 'ACTIVE', is_Part_of_Range__c= True);
        insert num2;
        Number__c num3= new Number__c(Service_Number__c='62384725',Type__c='FNN',Mobile__c='Fixed', Basket__c=basketId,Product_Configuration__c= PCId,Service_Id__c=serv.csordtelcoa__Service_Number__c,Start_Range__c='62384720',End_Range__c='62384725',Status__c = 'ACTIVE', is_Part_of_Range__c= True);
        insert num3;
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        System.debug('***Basket Id:'+basketId);
    }
    
    @isTest
    public static void getNumberListTest(){
        NumberManagementHandler.SearchReservedNumberWrapper
        searchNumWrap = new NumberManagementHandler.SearchReservedNumberWrapper();
        List<cscfga__Product_Configuration__c> configList = [select id, cscfga__Product_Basket__c, cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c limit 1];
        List<String> configIdList = new List<String>();
        for(cscfga__Product_Configuration__c conf : configList){
            System.debug('Product Configuration'+conf);
            configIdList.add(conf.id);
            basketId = conf.cscfga__Product_Basket__c;
        }
        searchNumWrap.selectedTabId = 'Fixed';
        searchNumWrap.basket_id = basketId;
        searchNumWrap.configId = configIdList;
        Test.startTest();
        List<NumberManagementHandler.NumberWrapper> numList = NumberManagementHandler.getNumberList(searchNumWrap);
        System.debug('****Numbr List:'+numList);
        Test.stopTest();
        System.assertEquals(3, numList.size());
    }
    
    @isTest
    public static void getNumberListNegativeTest(){
        Test.startTest();
        NumberManagementHandler.SearchReservedNumberWrapper
        searchNumWrap = new NumberManagementHandler.SearchReservedNumberWrapper();
        List<cscfga__Product_Configuration__c> configList = [select id, cscfga__Product_Basket__c, cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c limit 1];
        List<String> configIdList = new List<String>();
        for(cscfga__Product_Configuration__c conf : configList){
            configIdList.add(conf.id);
            basketId = conf.cscfga__Product_Basket__c;
        }
        searchNumWrap.selectedTabId = 'Mobile';
        searchNumWrap.basket_id = basketId;
        searchNumWrap.configId = configIdList;
        List<NumberManagementHandler.NumberWrapper> numList = NumberManagementHandler.getNumberList(searchNumWrap);
        System.debug('****Numbr List in Negative:'+numList);
        Test.stopTest();
        System.assertEquals(0, numList.size());
    }
    //EDGE-142086 - Updated for UX Uplift
    @isTest
    public static void removeReservedNumbersTest(){        
        Test.startTest();
        List<NumberManagementHandler.NumberWrapper> NumWrapList = new List<NumberManagementHandler.NumberWrapper>();
        List<NumberManagementHandler.NumberWrapper> NumWrapList1 = new List<NumberManagementHandler.NumberWrapper>();
        List<Number__C> lstNumbers = [select id, Service_Number__c, Product_Configuration__c, Basket__c, Start_Range__c, End_Range__c from Number__c where Service_Number__c In ('62384724','62384725')];
        for(Number__c num : lstNumbers){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Start_Range__c+' - '+num.End_Range__c;
            numberList.IsSelected = true;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList.add(numberList);
        }
        List<Number__C> lstNumbers1 = [select id, Service_Number__c, Product_Configuration__c, Basket__c from Number__c where Service_Number__c = '62384724'];
        for(Number__c num : lstNumbers1){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Service_Number__c;
            numberList.IsSelected = true;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList1.add(numberList);
        }
		
		
        System.debug('**Number List:' + NumWrapList);
        String numberListSerialized = JSON.serialize(NumWrapList);
        String numberListSerialized1 = JSON.serialize(NumWrapList1);
        List<NumberManagementHandler.NumberWrapper> numList = NumberManagementHandler.removeReservedNumbers(numberListSerialized, numberListSerialized1, basketId);
        //EDGE-134990 Added Attahment test data & asserts 
        List<Attachment> attList = new List<Attachment>();
		attList = [select Id,Body,ParentId FROM Attachment WHERE Name like '%NumberManagementv1%'];
		system.debug('Attach--->'+attList);
		String attbody;
        for (Attachment att : attList) {
			attbody = att.Body.toString();
		}
		System.debug('attbody--->'+attbody);
        Test.stopTest();
        System.assertEquals(attbody.contains('RESERVED'), true);//EDGE-134990 END
        System.assertEquals(numList !=Null, true);
        System.assertNotEquals(numList ==Null, true);
    }
    //EDGE-142086 - Updated for UX Uplift
    @isTest
    public static void removeReservedNumbersTest1(){        
        Test.startTest();
        List<NumberManagementHandler.NumberWrapper> NumWrapList = new List<NumberManagementHandler.NumberWrapper>();
        List<NumberManagementHandler.NumberWrapper> NumWrapList1 = new List<NumberManagementHandler.NumberWrapper>();
        List<Number__C> lstNumbers = [select id, Service_Number__c, Product_Configuration__c, Basket__c, Start_Range__c, End_Range__c from Number__c where Service_Number__c In ('62384724','62384725')];
        for(Number__c num : lstNumbers){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Start_Range__c+' - '+num.End_Range__c;
            numberList.IsSelected = true;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList.add(numberList);
        }
        //EDGE-153588 - Updated query to find PC based on Service Id
        List<Number__C> lstNumbers1 = [select id, Service_Number__c, Product_Configuration__c, Basket__c, Service_Id__c from Number__c where Service_Number__c = '62384724'];
        for(Number__c num : lstNumbers1){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Service_Number__c;
            numberList.IsSelected = true;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList1.add(numberList);
        }
		
		
        System.debug('**Number List:' + NumWrapList);
        String numberListSerialized = JSON.serialize(NumWrapList);
        String numberListSerialized1 = JSON.serialize(NumWrapList1);
        List<NumberManagementHandler.NumberWrapper> numList = NumberManagementHandler.removeReservedNumbers(numberListSerialized1, numberListSerialized, basketId);
        System.assertEquals(numList !=Null, true);
        System.assertNotEquals(numList ==Null, true);
        //EDGE-153588 - Updated query to find PC based on Service Id
        System.assertEquals(lstNumbers1[0].Service_Id__c == 'SVC-000056370', true);
    }
    @isTest
    public static void addToNumberPoolTest(){
        Test.startTest();
        List<NumberManagementHandler.NumberWrapper> NumWrapList = new List<NumberManagementHandler.NumberWrapper>();
        List<NumberManagementHandler.NumberWrapper> NumWrapList1 = new List<NumberManagementHandler.NumberWrapper>();
        List<NumberManagementHandler.NumberWrapper> NumWrapList2 = new List<NumberManagementHandler.NumberWrapper>();
        List<Number__C> lstNumbers = [select id, Service_Number__c, Product_Configuration__c, Basket__c from Number__c where Service_Number__c = '62384723'];
        for(Number__c num : lstNumbers){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Service_Number__c;
            numberList.IsSelected = false;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList.add(numberList);
        }
        List<Number__C> lstNumbers1 = [select id, Service_Number__c, Product_Configuration__c, Basket__c from Number__c where Service_Number__c = '62384725'];
        for(Number__c num : lstNumbers1){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Service_Number__c;
            numberList.IsSelected = true;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList1.add(numberList);
        }
        List<Number__C> lstNumbers2 = [select id, Service_Number__c, Product_Configuration__c, Basket__c from Number__c where Service_Number__c = '62384724'];
        for(Number__c num : lstNumbers2){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Service_Number__c;
            numberList.IsSelected = true;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList2.add(numberList);
        }
        System.debug('**Number List:' + NumWrapList);
        String numberListSerialized = JSON.serialize(NumWrapList);
        String numberListSerialized1 = JSON.serialize(NumWrapList1);
        String numberListSerialized2 = JSON.serialize(NumWrapList2);
        Map<String, List<NumberManagementHandler.NumberWrapper>> allNumMap = new Map<String, List<NumberManagementHandler.NumberWrapper>>(); 
        allNumMap = NumberManagementHandler.addToNumberPool(numberListSerialized1, numberListSerialized2, numberListSerialized);
        Test.stopTest();
        System.assertEquals(allNumMap !=Null, true);
        System.assertNotEquals(allNumMap ==Null, true);
    }
    //EDGE-142086 - Commented for UX Uplift
    /*
    @isTest
    public static void removeFromNumberPoolTest(){
        Test.startTest();
        List<NumberManagementHandler.NumberWrapper> NumWrapList = new List<NumberManagementHandler.NumberWrapper>();
        List<NumberManagementHandler.NumberWrapper> NumWrapList1 = new List<NumberManagementHandler.NumberWrapper>();
        List<NumberManagementHandler.NumberWrapper> NumWrapList2 = new List<NumberManagementHandler.NumberWrapper>();
        List<Number__C> lstNumbers = [select id, Service_Number__c, Product_Configuration__c, Basket__c from Number__c where Service_Number__c = '62384723'];
        for(Number__c num : lstNumbers){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Service_Number__c;
            numberList.IsSelected = false;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList.add(numberList);
        }
        List<Number__C> lstNumbers1 = [select id, Service_Number__c, Product_Configuration__c, Basket__c from Number__c where Service_Number__c = '62384725'];
        for(Number__c num : lstNumbers1){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Service_Number__c;
            numberList.IsSelected = true;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList1.add(numberList);
        }
        List<Number__C> lstNumbers2 = [select id, Service_Number__c, Product_Configuration__c, Basket__c from Number__c where Service_Number__c = '62384724'];
        for(Number__c num : lstNumbers2){
            NumberManagementHandler.NumberWrapper numberList = new NumberManagementHandler.NumberWrapper();
            numberList.numberId = num.id;
            numberList.PhoneNumber = num.Service_Number__c;
            numberList.IsSelected = true;  
            numberList.ProdConfigId = PCId;
            numberList.ProdConfigName = true;
            numberList.ProdBasketId = basketId;
            numberList.Type = 'FNN';
            numberList.NumberRange = '-';
            numberList.Status = 'ACTIVE';
            NumWrapList2.add(numberList);
        }
        System.debug('**Number List:' + NumWrapList);
        String numberListSerialized = JSON.serialize(NumWrapList);
        String numberListSerialized1 = JSON.serialize(NumWrapList1);
        String numberListSerialized2 = JSON.serialize(NumWrapList2);
        Map<String, List<NumberManagementHandler.NumberWrapper>> allNumMap = new Map<String, List<NumberManagementHandler.NumberWrapper>>(); 
        allNumMap = NumberManagementHandler.removeFromNumberPool(numberListSerialized1, numberListSerialized, numberListSerialized2);
        Test.stopTest();
        System.assertEquals(allNumMap !=Null, true);
        System.assertNotEquals(allNumMap ==Null, true);
    }*/
    @isTest
    public static void getDetailsTest(){
        Test.startTest();
        NumberManagementHandler.NumberWrapper numWrap = new NumberManagementHandler.NumberWrapper();
        Number__C myNumber = [select Id, Type__c,Mobile__c, Service_Id__c, Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c,Start_Range__c,End_range__c,Number_Range__c,Status__c from Number__c where Service_Number__c = '62384724'];
        NumberManagementHandler.NumberWrapper numWrapUpdated = NumberManagementHandler.getDetails(myNumber, numWrap);
        Test.stopTest();
        System.debug('**Number :' + numWrapUpdated.numberId);
        System.assertEquals(numWrapUpdated.numberId == myNumber.id, true);
        System.assertNotEquals(numWrapUpdated.numberId != myNumber.id, true);

    }
    //EDGE-142086 - Updated for UX Uplift
    @isTest
    public static void getFilteredNumberListTest(){
        NumberManagementHandler.SearchReservedNumberWrapper
        searchNumWrap = new NumberManagementHandler.SearchReservedNumberWrapper();
        List<cscfga__Product_Configuration__c> configList = [select id, cscfga__Product_Basket__c, cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c limit 1];
        List<String> configIdList = new List<String>();
        for(cscfga__Product_Configuration__c conf : configList){
            System.debug('Product Configuration'+conf);
            configIdList.add(conf.id);
            basketId = conf.cscfga__Product_Basket__c;
        }
        searchNumWrap.searchTerm = '';
        searchNumWrap.basket_id = basketId;
        searchNumWrap.configId = configIdList;
        Test.startTest();
        List<NumberManagementHandler.NumberWrapper> numList = NumberManagementHandler.getFilteredNumberList(searchNumWrap);
        System.debug('****Number List:'+numList);
        Test.stopTest();
        System.assertEquals(3, numList.size());
        System.assertEquals(numList[0].PhoneNumber == '62384723', true);
    }
 //EDGE-142086 - Updated for UX Uplift   
    @isTest
    public static void getFilteredNumberListSOSLTest(){
        NumberManagementHandler.SearchReservedNumberWrapper
        searchNumWrap = new NumberManagementHandler.SearchReservedNumberWrapper();
        List<cscfga__Product_Configuration__c> configList = [select id, cscfga__Product_Basket__c, cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c limit 1];
        List<String> configIdList = new List<String>();
        for(cscfga__Product_Configuration__c conf : configList){
            System.debug('Product Configuration'+conf);
            configIdList.add(conf.id);
            basketId = conf.cscfga__Product_Basket__c;
        }
        searchNumWrap.searchTerm = '623';
        searchNumWrap.basket_id = basketId;
        searchNumWrap.configId = configIdList;
        Number__c num= [Select Id from Number__c where Service_Number__c='62384723'];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = num.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        Test.startTest();
		List<NumberManagementHandler.NumberWrapper> numList = NumberManagementHandler.getFilteredNumberList(searchNumWrap);
        System.debug('****Number List:'+numList);
        Test.stopTest();
        System.assertEquals(1, numList.size());
        System.assertEquals(numList[0].PhoneNumber == '62384723',true);
    }
}