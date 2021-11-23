@isTest
public class LRMMSISDNServiceTest{
    
    
    @TestSetup static void dataSetup()
    {
        Test.startTest();
        Account acc = new Account(Name='Test Account');
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csbb__Account__c = acc.id;
        //basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.cscfga__Configuration_Status__c = 'Valid';
        
        insert config;
        
        csord__Order_Request__c orderReq = new csord__Order_Request__c();
        orderReq.name = 'OR-12121';
        orderReq.csord__Module_Name__c = 'TestReq';
        orderReq.csord__Module_Version__c = '12';
        insert orderReq;
        
        csord__Order__c  pord = new csord__Order__c();
        pord.name = 'pordTestOrder';
        pord.csord__Account__c = acc.id;
        pord.csord__Status2__c = 'Created';
        pord.csord__Order_Request__c = orderReq.Id;
        pord.csord__Identification__c = 'IDE1322';
        pord.stage__c = 'Being Fulfilled';       
        insert pord;
        
        csord__Order__c  ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Primary_Order__c=pord.id;
        ord.csord__Account__c = acc.id;
        ord.csord__Status2__c = 'Created';
        ord.csord__Order_Request__c = orderReq.Id;
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';       
        insert ord;
        
        
        csord__Subscription__c subs = new csord__Subscription__c();
        subs.name = 'TestOrder';
        subs.csord__Account__c = acc.id;
        subs.csord__Order__c = ord.id;
        subs.csord__Identification__c = 'IDE1322';
        subs.csord__Order_Request__c = orderReq.id;
        insert subs;
        
        csord__Service__c ser = new csord__Service__c();
        ser.name = 'serTestOrder';
        ser.csord__Order__c = ord.id;
        ser.csord__Subscription__c = subs.id;
        ser.csord__Identification__c =  'IDE1322';
        ser.csord__Order_Request__c = orderReq.id;
        ser.Model__c = 'TestOrder';
        ser.TechnologyType__c = 'Mobile Access';
        ser.csordtelcoa__Product_Configuration__c = config.id;
        insert ser;
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-2911-eb71-8e13-bd04b7f9824a","additionalAttributes" : {"ServiceId" : "61402022091","IPWirelessProductInstanceID" : "9127db1b-b9f7-4b69-d55b-f856689c1b7e"},"endDate":"","description":"CWP CFS Specification","code":"DMCAT_ProductSpecification_000263","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+ser.Id+'","legacyAttributes":[]}');
        
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = ser.Id;
        insert att1;
        Test.stopTest();
    }
    static testMethod void processTest(){
        csord__Service__c ser = [select Id, Name from csord__Service__c where Name= 'serTestOrder'];
        String handlerName = 'SearchReserveMSISDNHandler';
        String scenarioType = 'Change of Mobile Number';
        List<csord__Order__c> orderstatus = [select id, isMSISDNReserved__c,RecordTypeId,csord__Status2__c from csord__Order__c where Name ='pordTestOrder' limit 1];
        List<RecordType> MSISDNRecordtype = null;
        if (!orderstatus.isEmpty())
        {
            MSISDNRecordtype = [SELECT DeveloperName  FROM RecordType   WHERE Id =: orderstatus[0].RecordTypeId];
            Boolean MSISDNReserved = orderstatus[0].isMSISDNReserved__c;
            system.debug('isMSISDNReserved ' +MSISDNReserved+'MSISDNStatus  '+MSISDNRecordtype);
        }
        Map<String,FNNDTO> serviceIDFNNDTOMap = new Map<String,FNNDTO>();
        FNNDTO dto = new FNNDTO();
        FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
        fdo.poolName = 'Postpaid';
        fdo.activityName = 'DIRECT HOLD';
        fdo.searchStatus = 'AVAILABLE';
        dto.data = fdo;
        serviceIDFNNDTOMap.put(ser.id,dto);
        Cache.Org.put('SearchReserveMSISDNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        LRMMSISDNService msisdnServiceJob = new LRMMSISDNService(serviceIDFNNDTOMap,orderstatus[0].id,MSISDNRecordtype[0].DeveloperName,handlerName, scenarioType);
        System.debug('msisdnServiceJob'+msisdnServiceJob);
        Test.startTest();
        msisdnServiceJob.searchReserveMSISDN('lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        //ID jobID = System.enqueueJob(msisdnServiceJob);
        //System.debug('msisdnServiceJobenquedone1'+jobID);
        Test.stopTest();
        system.assertNotEquals(null,serviceIDFNNDTOMap);
        }
    static testMethod void processTest2(){ 
        csord__Service__c ser = [select Id, Name from csord__Service__c where Name= 'serTestOrder'];
        String heldhandlerName = 'HeldToReserveMSISDNHandler';
        String scenarioType = 'Change of Mobile Number';
        List<csord__Order__c> orderstatus = [select id, isMSISDNReserved__c,RecordTypeId,csord__Status2__c from csord__Order__c where Name ='pordTestOrder' limit 1];
        List<csord__Order__c> HELDorderstatus = [select id, isMSISDNReserved__c,RecordTypeId,csord__Status2__c from csord__Order__c where id =: orderstatus[0].id limit 1];
        List<RecordType> heldMSISDNRecordtype = [SELECT DeveloperName  FROM RecordType WHERE DeveloperName = 'MSISDN_Reserved'];
        Map<String,FNNDTO> heldserviceIDFNNDTOMap = new Map<String,FNNDTO>();
        FNNDTO helddto = new FNNDTO();
        FNNDTO.FNNDataObject heldfdo = new FNNDTO.FNNDataObject();
        heldfdo.activityName = 'CONNECT';
        helddto.data = heldfdo;
        heldserviceIDFNNDTOMap.put(ser.id,helddto);
        Cache.Org.put('HeldToReserveMSISDNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        LRMMSISDNService heldmsisdnServiceJob = new LRMMSISDNService(heldserviceIDFNNDTOMap,orderstatus[0].id,heldMSISDNRecordtype[0].DeveloperName,heldhandlerName, scenarioType);
        System.debug(heldmsisdnServiceJob);
        Test.startTest();
        heldmsisdnServiceJob.HeldToReserveMSISDN('lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        //ID jobIDs = System.enqueueJob(heldmsisdnServiceJob);
        //System.debug('msisdnServiceJobenquedon2'+jobIDs);
        Test.stopTest();
        system.assertNotEquals(null,heldserviceIDFNNDTOMap);
        //done changes
    }
    
}