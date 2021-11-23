@isTest
public class importO2ADataFromCSVControllerTest {
   
    @Testsetup
    static void dataSetup(){
        
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='EnableHV';
        csSite.value__c='True';
        insert csSite;
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
      opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Customer_Order_Number__c='ON00145811';
        ord.csordtelcoa__Opportunity__c = opp.Id;
       
        insert ord;
    
     List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        csord__Subscription__c replSubs=new csord__Subscription__c();
        replSubs.name  = 'test replaced subs';
        replSubs.csord__Identification__c = 'test identity replced';
       // replSubs.csord__Order__c = ord.Id;
        replSubs.Sub_status__c = 'Active';
        replSubs.eventId__c = '9f0ded2-1bfd-7916-662d-9e28c804294e';
        subList.add(replSubs);
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.csord__Status__c='Active';
        subs.csordtelcoa__Subscription_Number__c ='SN-12345';
        subs.Suspension_reason__c='Requested by Customer';
        subs.csordtelcoa__Replaced_Subscription__c = replSubs.id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.changeType__c = 'Resume';//EDGE-180743 
        subList.add(subs);
        
      
        insert subList;
    
       
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
        
        //EDGE-132208 - Added Configuration Record
        cscfga__Product_Configuration__c userPC1 = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3, Type__c = 'Cancel');
        insert userPC1;
        //EDGE-160243
    cscfga__Product_Configuration__c userPC2 = new cscfga__Product_Configuration__c(Name = 'Business Calling', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3, Type__c = 'New');
        insert userPC2;
    
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = 'SVC-000189133';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c =  ord.Id;
        serv.csordtelcoa__Product_Configuration__c = userPC2.id;
        servs.add(serv);
        
       csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = 'SVC-000187271';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord.Id;
        servs.add(serv1);
        insert servs;
    
       
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv1.Id;
        atts.add(att1);
         insert atts;
   
    }   

    @isTest
    static void testreadFromFile(){
        String datajson ='{ "datesO2AList":[ { "Sale_Order_ID": "ON00145811", "Order_Item_ID": "ON00145811|SVC-000187271|8d15e372-c487-6cd7-cb4a-ddd1bc74197b", "telstraCommittedDate": "2020-12-14T19:09:40+00:00", "currentForecastedDeliveryDate": "2020-12-14T19:01:12+00:00", "productCompletionDate": "2020-12-08T13:40:13+00:00", "productCancellationDate": "", "ServiceActivationDate": "2020-12-05T19:01:12+00:00", "ServiceDeactivationDate": "", "DesignCompletionDate": "", "InstallationDate": "2020-12-1T19:01:12+00:00", "EquipmentDeliveredDate": "", "CustomerOrderAcceptanceDate": "", "EstimatedDeliveryDate": "" }, { "Sale_Order_ID": "ON00147118", "Order_Item_ID": "ON00147118|SVC-000189133|1a4f1398-caf5-3ff4-0a22-6e543eac9e70", "telstraCommittedDate": "2020-12-11T19:09:40+00:00", "currentForecastedDeliveryDate": "2020-12-11T19:01:12+00:00", "productCompletionDate": "", "productCancellationDate": "2020-12-07T13:40:13+00:00", "ServiceActivationDate": "2020-12-10T19:01:12+00:00", "ServiceDeactivationDate": "", "DesignCompletionDate": "2020-12-2T19:01:12+00:00", "InstallationDate": "", "EquipmentDeliveredDate": "2020-12-3T19:01:12+00:00", "CustomerOrderAcceptanceDate": "2020-12-5T19:01:12+00:00", "EstimatedDeliveryDate": "2020-12-5T19:01:12+00:00" } ] }';

        importO2ADataFromCSVController ob = new importO2ADataFromCSVController();
            ob.readFromFile();
                System.assertNotEquals( null,datajson);

            }
    
     @isTest
    static void testreadCSVFile(){
        
       csord__Service__c srvc= [SELECT ID,csordtelcoa__Service_Number__c, Name,csord__Identification__c  from csord__Service__c  WHERE Name=:'tst service1' AND csord__Identification__c  =:'test identify1' LIMIT 1];
             importO2ADataFromCSVController ob = new importO2ADataFromCSVController();  
String datajson ='{ "datesO2AList":[ { "Sale_Order_ID": "ON00145811", "Order_Item_ID": "ON00145811|'+ srvc.csordtelcoa__Service_Number__c +'|8d15e372-c487-6cd7-cb4a-ddd1bc74197b", "telstraCommittedDate": "2020-12-14T19:09:40+00:00", "currentForecastedDeliveryDate": "2020-12-14T19:01:12+00:00", "productCompletionDate": "2020-12-08T13:40:13+00:00", "productCancellationDate": "", "ServiceActivationDate": "2020-12-05T19:01:12+00:00", "ServiceDeactivationDate": "", "DesignCompletionDate": "", "InstallationDate": "2020-12-1T19:01:12+00:00", "EquipmentDeliveredDate": "2020-12-5T19:01:12+00:00","EstimatedDeliveryDate": "", "CustomerOrderAcceptanceDate": "", "EquipmentOrderedDate": "2020-12-6T19:01:12+00:00" }, { "Sale_Order_ID": "ON00147118", "Order_Item_ID": "ON00147118|SVC-000189133|1a4f1398-caf5-3ff4-0a22-6e543eac9e70", "telstraCommittedDate": "2020-12-11T19:09:40+00:00", "currentForecastedDeliveryDate": "2020-12-11T19:01:12+00:00", "productCompletionDate": "", "productCancellationDate": "2020-12-07T13:40:13+00:00", "ServiceActivationDate": "2020-12-10T19:01:12+00:00", "ServiceDeactivationDate": "2020-12-11T19:01:12+00:00", "DesignCompletionDate": "2020-12-2T19:01:12+00:00", "InstallationDate": "", "EquipmentDeliveredDate": "2020-12-3T19:01:12+00:00", "CustomerOrderAcceptanceDate": "2020-12-5T19:01:12+00:00", "EquipmentOrderedDate": "2020-12-5T19:01:12+00:00" } ] }';
        ob.csvFileBody=Blob.valueOf(datajson);    
        ob.readCSVFile(datajson);
            System.assertNotEquals( null,datajson);
            ob.saveData();

    }
}