/*
* @Author : Ritika Jaiswal
* @Date : 17 April 2019
* @Desc : Test class for covering TM1EligibilityCheckService class
* @Jira : EDGE - 66569
*/

@isTest
public class TM1EligibilityCheckServiceTest{
      static blob b = [select body from staticResource where name = 'ServiceJSON'].body;    
      static String serviceDTO = b.toString();
      //EDGE-80772 - SolutionConsole RetroFit for TM1
      static String serviceDTO_V2 = '{ "Source_System_Id": "Replicator", "site": [ { "siteName": null, "productList": [ { "serviceList": [ { "Service_Type": "Voice", "service": [ { "serviceExtension": [ { "Services_To": "0246315099", "Services_From": "0246315001", "disableCheck": null, "checkValue": null } ], "Service_Type": "Voice", "Service_Id": "0246315000", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "checkValue": true }, { "serviceExtension": [ ], "Service_Type": "Voice", "Service_Id": "0246319001", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "checkValue": true } ], "disableCheck": null, "checkValue": null } ], "Product_Type": "ISDN-BRA", "disableCheck": null, "checkValue": true } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "266049834" } ], "Error_Description": "", "Error_Code": "", "Correlation_Id": "SFDC_REP_GETSERVICEa5f369527219745b8c", "CIDN": "6892971200" }';
        
      @testsetup static void setup() { 
        
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
              
        cscrm__Address__c addrs = new cscrm__Address__c();
        addrs.Address_ID__c = '152365895123';
        addrs.Name = 'Test Address';
        addrs.cscrm__Account__c = acc.id;
        insert addrs;
        
        cscrm__Site__c siteobj = new cscrm__Site__c();
        siteobj.Name = 'Test Site';
        siteobj.cscrm__Account__c = acc.id;
        siteobj.cscrm__Installation_Address__c = addrs.Id;
        siteobj.Status__c = 'Active';
        siteobj.Legacy__c = true;
        insert siteobj;
      
        cscfga__Product_Basket__c prodBasket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        prodBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        update prodBasket;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'IP Site';
        config.cscfga__Description__c = 'Test description';
        insert config;        
        //EDGE-80772 - SolutionConsole RetroFit for TM1
        /*csbb__Product_Configuration_Request__c prodConfigReq = ProductTestFactory.buildConfigRequest(prodBasket.Id,config.Id);
        prodConfigReq.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"152365895123","cscrm_installation_address_r_cscrm_state_province_c":"TAS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';       
        insert prodConfigReq;*/
        cscfga__Product_Category__c prodCat= new cscfga__Product_Category__c();
        prodCat.Name = 'Modular Products';
        insert prodCat;
        
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
        //EDGE-80772 - SolutionConsole RetroFit for TM1
        att.ParentId = config.Id; 
        att.Body = Blob.valueOf(serviceDTO_V2);
        insert att;
		
		Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testSuccess_CISEmail'));
		Attachment att1 = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
		List<String> toList = new List<String>{'to@to.com'};
		List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
		List<String> bccList = new List<String>{'bcc@bcc.com'};
		List<id> attList = new List<Id>{att1.id};
		
		EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList,null, 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'EDGESF_ORDER_2', '', null, null);
		Integration_Record__c insRec = new Integration_Record__c();
		Blob b = Crypto.GenerateAESKey(128);
		String GUID = EncodingUtil.ConvertTohex(b);
		insRec.params__c = GUID;
		insRec.paramPayload__c = JSON.serialize(dto);
		insRec.handler__c = 'CISEmailHandler';
		insRec.status__c = IntegrationQueueHandler.PENDING;
		insert insRec;
      }
    
    @isTest
    Public static void testSuccess(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTM1EligibilitycheckPostbackResponse('success_acknowledgement'));
        //EDGE-80772 - START SolutionConsole RetroFit for TM1
        cscfga__Product_Configuration__c prodConfig = [SELECT id FROM cscfga__Product_Configuration__c LIMIT 1];
        Map<String,ReplicatorGetServiceDataObject_V2> mapPcrToServiceDTO = new Map<String,ReplicatorGetServiceDataObject_V2>();
        ReplicatorGetServiceDataObject_V2 ServiceDTOrecord = ReplicatorGetServiceDataObject_V2.parse(serviceDTO_V2);
        if(prodConfig !=null) 
            mapPcrToServiceDTO.put(prodConfig.id,ServiceDTOrecord);
        TM1EligibilityCheckService.TramasEligibilityRequestMethod(mapPcrToServiceDTO);
        Integration_Record__c paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c LIMIT 1];
        TM1EligibilityCheckService.sendEligibilityCheckRequest(paramRequest.params__c);
        TramasElgibilityCallbackResponse__c responserecord = [SELECT id,UUID__c,Product_Configuration__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];
        Test.stopTest();
        //Assert, to check if a response-record is created with the related PC-record 
        System.assert(responserecord.Product_Configuration__c == prodConfig.id);
        //EDGE-80772 - END SolutionConsole RetroFit for TM1
    }
    
    @isTest
    Public static void testFailure(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTM1EligibilitycheckPostbackResponse('success_Error'));
        //EDGE-80772 - start SolutionConsole RetroFit for TM1
        cscfga__Product_Configuration__c prodConfig = [SELECT id FROM cscfga__Product_Configuration__c LIMIT 1];
        Map<String,ReplicatorGetServiceDataObject_V2> mapPcrToServiceDTO = new Map<String,ReplicatorGetServiceDataObject_V2>();
        ReplicatorGetServiceDataObject_V2 ServiceDTOrecord = ReplicatorGetServiceDataObject_V2.parse(serviceDTO_V2);
        if(prodConfig !=null)
            mapPcrToServiceDTO.put(prodConfig.id,ServiceDTOrecord);
        TM1EligibilityCheckService.TramasEligibilityRequestMethod(mapPcrToServiceDTO);
        Integration_Record__c paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c limit 1];
        TM1EligibilityCheckService.sendEligibilityCheckRequest(paramRequest.params__c);
        TramasElgibilityCallbackResponse__c responserecord = [SELECT id,UUID__c,Product_Configuration__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];      
        System.debug('responserecord:'+responserecord);
        Test.stopTest();
        //Assert, to check if a response-record is not updated with the UUID
        System.assert(String.isBlank(responserecord.UUID__c) == true);
        //EDGE-80772 - END SolutionConsole RetroFit for TM1
    }   
}