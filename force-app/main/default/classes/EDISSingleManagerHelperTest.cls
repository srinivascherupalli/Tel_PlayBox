/********************************************************

    Class Name : EDISSingleManagerHelperTest
    ===============================================================================================================================
    Change.No.    Developer Name          Date              Story Description
    1.             Milos                 12/07/2021          DIGI-869
    2.           Pawan Devaliya          04/08/2021          EDGE-229526
    **********************************************************/
@isTest
public class EDISSingleManagerHelperTest {
      @Testsetup
    static void dataSetup() { // datasetup
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        acc.Title__c = 'MRS';
        acc.CIDN__c = '738295241';
        acc.Type = 'Non Profit Organisation';
        insert acc;   
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        contact con=new contact(lastname='chopra',firstname ='yash', email='abc@gmail.com',phone= '8798765432',accountId=acc.id);
        insert con;

        Billing_Account__c ba = new Billing_Account__c();
    ba.Account__c = acc.Id;
    ba.Billing_Account_Number__c = '123123122234';
        ba.Billing_Account_Owner__c = con.id;
    insert ba;
        
        List<csord__Order_Request__c> ordRequestList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordRequestList.add(ordReq);  
        insert ordRequestList;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        insert ord;
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
        
        List<csord__Subscription__c> subList =new List<csord__Subscription__c>();
        csord__Subscription__c subRes=new csord__Subscription__c();
        subRes.name  = 'sub1';
        subRes.csord__Identification__c = 'sub1';
        subRes.csord__Order__c = ord.Id;
        subRes.Sub_status__c = 'Active';
        subRes.csord__Status__c='Provisioned';
        subRes.triggerBill_RTB__c=true;
        subRes.csordtelcoa__Product_Configuration__c = userPC.id;
        subList.add(subRes);
        
        csord__Subscription__c subRes1=new csord__Subscription__c();
        subRes1.name  = 'sub2';
        subRes1.csord__Identification__c = 'sub2';
        subRes1.csord__Order__c = ord.Id;
        subRes1.Sub_status__c = 'Active';
        subRes1.csord__Status__c='Provisioned';
        subRes1.triggerBill_RTB__c=true;
        subRes1.csordtelcoa__Product_Configuration__c = userPC.id;
    subRes1.eventId__c ='91d3e2ba-2d65-4752-837a-7b5193c5f1c5';
        subList.add(subRes1);
        insert subList; 
        
        List<csord__Service__c> servList = new List<csord__Service__c >();
        csord__Service__c servRe = new csord__Service__c();
        servRe.name ='tst servRe';
        servRe.csord__Identification__c  = 'test servRe';
        servRe.csord__Subscription__c = subRes.Id;
        servRe.csord__Status__c = 'Connected';
        servRe.csord__Order__c = ord.Id;
        servRe.Billing_Account__c = ba.Id;
        servRe.csordtelcoa__Product_Configuration__c = userPC.id;
        servList.add(servRe);
        
        csord__Service__c servRe1 = new csord__Service__c();
        servRe1.name ='tst servRe1';
        servRe1.csord__Identification__c  = 'test servRe';
        servRe1.csord__Subscription__c = subRes1.Id;
        servRe1.csord__Status__c = 'Connected';
        servRe1.csord__Order__c = ord.Id;
        servRe1.csordtelcoa__Product_Configuration__c = userPC.id;
        servList.add(servRe1);
        insert servList;
        
        List<Number__c> numList = new List<Number__c>();
        Number__c num=new Number__c();
        num.name='Num test4';
        num.Subscription_number__c=subRes.csordtelcoa__Subscription_Number__c;
        num.Type__c='New';
        num.Service_Number__c='61474850547';
        num.Status__c='Active';
        num.Mobile__c  = 'Mobile';
        num.Product_Configuration__c = userPC.id;
        num.Status_LastModifiedDate__c = Datetime.now();
        numList.add(num);
        
        Number__c num1=new Number__c();
        num1.name='Num test8';
        num1.Subscription_number__c=subRes1.csordtelcoa__Subscription_Number__c;
        num1.Type__c='New';
        num1.Service_Number__c='61474850548';
        num1.Status__c='Inactive';
        num1.Product_Configuration__c = userPC.id;
        num1.Status_LastModifiedDate__c = Datetime.now();
        numList.add(num1);
    
        System.debug('servList[0].csordtelcoa__Service_Number__c;  '+servList[0].csordtelcoa__Service_Number__c);
    
        System.debug('servList[1].csordtelcoa__Service_Number__c;  '+servList[1].csordtelcoa__Service_Number__c);
        System.debug('numList  115 '+numList);
        
        insert numList;
        
   
        EDISSingleRequestDTO dto = new EDISSingleRequestDTO();
        dto.correlationId = '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e';
        dto.path ='/application/edis-eai/v2/directory-listings';
        dto.method = 'POST';
        
        EDISSingleRequestDTO.CustomerContactAddress cca = new EDISSingleRequestDTO.CustomerContactAddress();
        cca.ccaIdentifier = '1234';
        cca.ccaOverseasAddressLine1 = 'test' ;
        cca.ccaOverseasAddressLine2 = 'test1';
        cca.ccaOverseasAddressLine3 = 't6est2';
        cca.ccaOverseasAddressCountryCode = '123456';
        
        EDISSingleRequestDTO.ServiceOrderDetails soa = new EDISSingleRequestDTO.ServiceOrderDetails();
        soa.listCode ='123';
        soa.orderType ='123';
        soa.orderStatus ='123';
        soa.serviceType ='123';
        soa.orderID ='123';
        soa.originatingSystem ='123';
        soa.portFlag ='123';
        soa.productName ='123';
        soa.telstraAddressId ='123';
        soa.soCreationTimestamp ='123';
        soa.telstraCommitmentDate ='123';
        soa.provisionCompletionDate ='123';
        soa.temporaryServiceIndicator ='123';
        soa.interimServiceIndicator ='123';
        soa.alternateAddressFlag ='123';
        soa.originalFNN ='123';
        soa.originalFamilyName ='123';
        soa.originalGivenNames ='123';
        soa.originalAddressIdentifier ='123';
        soa.lineItemStatus ='123';
        
        EDISSingleRequestDTO.ListingDetails ld = new EDISSingleRequestDTO.ListingDetails();
        ld.familyOrEntityName ='123';
        ld.organizationName ='123';
        ld.givenNames ='123';
        ld.listingFNN ='123';
        ld.actionCode ='123';
        ld.subactionCode ='123';
        ld.reasonCode ='123';
        
        EDISSingleRequestDTO.CustomerDetails cd = new EDISSingleRequestDTO.CustomerDetails();
        cd.customerID ='123';
        cd.customerType ='123';
        cd.familyName ='123';
        cd.givenNames ='123';
        cd.registeredCompanyName ='123';
        cd.customerTitle ='123';
        cd.customerContactGivenNames ='123';
        cd.customerContactFamilyName ='123';
        cd.contactPosition ='123';
        cd.contactFNN ='123.00';
        cd.contactEmail ='123';
        
        EDISSingleRequestDTO.EDISReqDTO reqDTO = new EDISSingleRequestDTO.EDISReqDTO();
        reqDTO.type ='123';
        reqDTO.customerDetails =cd;
        reqDTO.listingDetails =ld;
        reqDTO.serviceOrderDetails =soa;
        reqDTO.customerContactAddress =cca;
        
        dto.data = reqDTO;
            
        Integration_Record__c insertRecord = insertRecordBefore(dto);
        Integration_Record__c itr= new Integration_Record__c();
        itr.handler__c = 'SingleFNNListingHandler';
        itr.params__c = 'SingleFNNListingHandlerParams';
        insert itr;
    }

    public static Integration_Record__c insertRecordBefore(EDISSingleRequestDTO dto){
        Integration_Record__c insertRecord = new Integration_Record__c();
        blob b = Crypto.generateAesKey(128);
        String GUID = EncodingUtil.convertToHex(b);
        insertRecord.params__c =GUID;
        insertRecord.paramPayload__c = JSON.serialize(dto);
        insertRecord.handler__c = 'SingleFNNListingHandler';
        insertRecord.status__c = IntegrationQueueHandler.PENDING;
        insert insertRecord;
        return insertRecord;
    }

   

    @isTest
    public static void buildingMapsTest() {
        List<Integration_Record__c> existingRequests = [SELECT Id, Params__c, ParamPayload__c FROM Integration_Record__c WHERE handler__c = 'SingleFNNListingHandler'];

       /* if (numList.isEmpty()) {
            numList = new List<Number__c>();
        }*/
        
        Cache.Org.put('SingleFNNListingHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');

        Test.startTest();
        List<Number__c> numList = [SELECT id, Service_Id__c,Mobile__c, Service_Number__c, Status__c, Name, Type__c  FROM Number__c limit 2];
        
        List<csord__Service__c> servList = [SELECT id, csordtelcoa__Service_Number__c,  Name  FROM csord__Service__c limit 2];
        numList[0].Service_Id__c = servList[0].csordtelcoa__Service_Number__c;
        numList[1].Service_Id__c = servList[1].csordtelcoa__Service_Number__c;
        update numList;

      System.debug('numList  :: '+numList);
      System.debug('servList  :: '+servList);
        Test.setMock(HttpCalloutMock.class, new EDISMockResponseGenerator());
        
        // EDISSingleService.callEDISSingleService(existingRequests.get(0).params__c,'SingleFNNListingHandler');

        EDISSingleManagerHelper.buildingMaps(numList);

        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"path": "","method": "POST","data": { "type": "","serviceOrderDetails": { "temporaryServiceIndicator": "N","telstraCommitmentDate": null,"telstraAddressId": "241031544","soCreationTimestamp": null, "serviceType": "","provisionCompletionDate": "","productName": "","portFlag": "", "originatingSystem": "", "originalGivenNames": "","originalFNN": "","originalFamilyOrEntityName": "", "originalAddressIdentifier": "","orderType": "", "orderStatus": "","orderID": null,"listCode": "No Entry Line","lineItemStatus": "","interimServiceIndicator": "N","alternateAddressFlag": "T"},"listingDetails": {"subactionCode": "", "reasonCode": "","organizationName": "","listingFNN": "","givenNames": "TestMunich","familyOrEntityName": "TestMunich","actionCode": "add"},"customerDetails": {"registeredCompanyName": "", "givenNames": "TestMunich","familyName": "TestMunich","customerType": "Company","customerTitle": null,"customerID": "9834556", "customerContactGivenNames": "","customerContactFamilyName": "","contactPosition": "","contactFNN": 0,"contactEmail": "praj@gmail.com"},"customerContactAddress": {"ccaOverseasAddressLine3": "","ccaOverseasAddressLine2": "","ccaOverseasAddressLine1": "","ccaOverseasAddressCountryCode": "","ccaIdentifier": "241031544"}},"correlationId": "798cd026-07e1-7af1-9e5d-1f20f9f7d9bd"}}');
    req.setMethod('POST');
    EDISMockResponseGenerator mockRes = new EDISMockResponseGenerator();
        response = mockRes.respond(req);

        EDISSingleResponseDTO res = (EDISSingleResponseDTO) JSON.deserialize(response.getBody(), EDISSingleResponseDTO.class);

        Test.stopTest();
    }
    
        
    @isTest
    public static void buildingMapsExceptionTest() {

        Test.startTest();
        List<Number__c> numList = [SELECT Service_Id__c, Service_Number__c, Name  FROM Number__c limit 2];
        
               List<csord__Service__c> servList = [SELECT id, csordtelcoa__Service_Number__c,  Name  FROM csord__Service__c limit 2];
        numList[0].Service_Id__c = null;
        numList[1].Service_Id__c = null;
        update numList;


        EDISSingleManagerHelper.buildingMaps(numList);
        Test.stopTest();
    }
    
        @isTest
    public static void buildingMapsException2Test() {

        Test.startTest();
        List<Number__c> numList = new List<Number__c>();
                
               csord__Service__c svc = [SELECT id, csordtelcoa__Service_Number__c,  Name  FROM csord__Service__c limit 1];
               Number__c num = new Number__c(Service_Id__c = svc.csordtelcoa__Service_Number__c);
               numList.add(num);
               insert numList;
               
        EDISSingleManagerHelper.buildingMaps(numList);
        Test.stopTest();
    }
    
    
 /*   @isTest
    public static void testPopulateListingDetailsDTO(){
        csord__Service__c ser=[Select Id,Name from csord__Service__c limit 1];
    Number__c num = [select id from Number__c limit 1];
        Test.startTest();
        EDISSingleRequestDTO.ListingDetails listing = EDISSingleManagerHelper.populateListingDetailsDTO(ser, num);
    system.assertNotEquals(null, ser);
        Test.stopTest();
        
    }
    */
    
    
 /*    @isTest
    public static void testpopulateEdisReqDTO(){
         Test.startTest();
        csord__Service__c ser=[Select Id,Name from csord__Service__c  where name ='tst servRe' limit 1];
        Number__c num = [select id, Service_Number__c from Number__c limit 1 ];
        EDISSingleRequestDTO.EDISReqDTO  dto = EDISSingleManagerHelper.populateEdisReqDTO(ser,num);
        Test.stopTest();
    }
  */     
}