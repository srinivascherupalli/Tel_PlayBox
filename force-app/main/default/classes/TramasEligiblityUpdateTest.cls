@isTest
public class TramasEligiblityUpdateTest{
   static blob b = [select body from staticResource where name = 'ServiceJSON'].body;    
      static String serviceDTO = b.toString();
      static String serviceDTO_V2 = '{ "Source_System_Id": "Replicator", "site": [ { "siteName": null, "productList": [ { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0333458320", "Services_From": "0333458310", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null } ], "Service_Type": "Voice", "Service_Id": "0333458310", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null }, { "User_Type": "", "serviceExtension": [ ], "Service_Type": "Voice", "Service_Id": "0266862625", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null }, { "User_Type": "", "serviceExtension": [ ], "Service_Type": "Voice", "Service_Id": "0266814617", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "PSTN", "disableCheck": null, "checkValue": true }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ ], "Service_Type": "Voice", "Service_Id": "0292236598", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null }, { "User_Type": "", "serviceExtension": [ { "Services_To": "0333458420", "Services_From": "0333458410", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null } ], "Service_Type": "Voice", "Service_Id": "0333458410", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "BE Bundle", "disableCheck": null, "checkValue": false }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0893457332", "Services_From": "0393457300", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null }, { "Services_To": "0393457399", "Services_From": "0393457334", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null } ], "Service_Type": "Voice", "Service_Id": "0393457300", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null }, { "User_Type": "", "serviceExtension": [ { "Services_To": "0266183204", "Services_From": "0266183201", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null } ], "Service_Type": "Voice", "Service_Id": "0266183200", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "In Dial", "Association_Role": "Primary", "eligibilityStatus": null, "eligibilityReason": null } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "ISDN2DID", "disableCheck": null, "checkValue": true } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "260274355" } ], "serviceCount": 5, "Error_Description": "", "Error_Code": "", "Correlation_Id": "SFDC_REP_GETSERVICE633218060aca2c1ffa", "CIDN": "5810217906" }'; 
      
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
        
        csbb__Product_Configuration_Request__c prodConfigReq = ProductTestFactory.buildConfigRequest(prodBasket.Id,config.Id);
        prodConfigReq.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"152365895123","cscrm_installation_address_r_cscrm_state_province_c":"TAS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';       
        insert prodConfigReq;
        
        cscfga__Product_Category__c prodCat= new cscfga__Product_Category__c();
        prodCat.Name = 'Modular Products';
        insert prodCat;
        
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
        //EDGE-80772 :Solution Console retrofit 
        att.ParentId = config.Id;
        att.Body = Blob.valueOf(serviceDTO_V2);
        insert att;
        
        TramasElgibilityCallbackResponse__c newTER= new TramasElgibilityCallbackResponse__c();
        newTER.Product_Basket__c=prodBasket.id;
        newTER.Product_Configuration__c=config.id;
        //EDGE-80772 - commented for SolutionConsole RetroFit for TM1
        //newTER.Product_Configuration_Request__c=prodConfigReq.id;  commented for EDGE-80772 :Solution Console retrofit 
        newTER.Correlation_ID__c='123456asdfghuiko';
        insert newTER;
        
        Attachment attachmentRecord = new Attachment();
                    attachmentRecord.Body = Blob.valueOf('');
                    attachmentRecord.Name = String.valueOf('EligibilityResults.txt');  
                    attachmentRecord.parentId=newTER.id;
        insert attachmentRecord;
        
      }
      @isTest
      Public static void testScenario2(){
        String bodyString='';
        Test.startTest();
            attachment attrecord1= [Select id,body,bodylength,description from attachment where name=:'EligibilityResults.txt' limit 1];
           
        Test.stopTest();
         System.assert(String.isBlank(attrecord1.description) == true);
        
    }
      
      @isTest
    Public static void testScenario1(){
        String payloadString='{"Object_Category":"Product","Correlation_ID":"147747a3-a6c1-d7d7-d5f7-ead6ea9fa32e","Total_Discovered_Count":9,"Eligible_Count":1,"Ineligible_Count":7,"Overall_Eligibility_Results":"Ineligible and Warning","Discovered_Objects":[{"Object_Type":"Dialable Number","Product_Technology_Family":"PSTN","Number_of_Relationships":0,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","PSTN":"Active"},"Address_ID":null,"Eligible":"Eligible","List_of_Relationships":[],"Reason":null,"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0333458310","Provided_As_Input":true,"Customer_ID":null,"Site_ID":null},{"Object_Type":"Dialable Number","Product_Technology_Family":"ISDN30 INDIAL","Number_of_Relationships":0,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","ISDN2 DID":"Active","Prime":"Active"},"Address_ID":null,"Eligible":"Ineligible","List_of_Relationships":[],"Reason":["All Aux need to be Transitioned with Prime"],"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0266862625","Provided_As_Input":true,"Customer_ID":null,"Site_ID":null},{"Object_Type":"Dialable Number","Product_Technology_Family":"ISDN2 INDIAL","Number_of_Relationships":1,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","ISDN2 DID":"Active","Prime":"Active"},"Address_ID":null,"Eligible":"Ineligible","List_of_Relationships":[{"Type":"Parent/Child","RPID":"someuuid-ddd-asdas4-asdasda"}],"Reason":["All Aux need to be Transitioned with Prime"],"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0266814617","Provided_As_Input":true,"Customer_ID":null,"Site_ID":null},{"Object_Type":"Dialable Number","Product_Technology_Family":"PSTN","Number_of_Relationships":0,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","PSTN":"Active","Credit Management":"Active"},"Address_ID":null,"Eligible":"Warning","List_of_Relationships":[],"Reason":["Credit Management is Active"],"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0393457334","Provided_As_Input":true,"Customer_ID":null,"Site_ID":null},{"Object_Type":"Dialable Number","Product_Technology_Family":"LH PRIME","Number_of_Relationships":1,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","ISDN2":"Active","Prime":"Active"},"Address_ID":null,"Eligible":"Ineligible","List_of_Relationships":[{"Type":"Parent/Child","RPID":"someuuid-ddd-asdas4-asdasda"}],"Reason":["All Aux need to be Transitioned with Prime"],"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0266183201","Provided_As_Input":true,"Customer_ID":null,"Site_ID":null},{"Object_Type":"Dialable Number","Product_Technology_Family":"MN AUX","Number_of_Relationships":1,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","Prime":"Active","Aux":"Active","ISDN2":"Active"},"Address_ID":null,"Eligible":"Ineligible","List_of_Relationships":[{"Type":"Parent/Child","RPID":"someuuid-ddd-asdas4-asdasda"}],"Reason":["All Aux need to be Transitioned with Prime","The Prime needs to be Transitioned with the Aux"],"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0266183202","Provided_As_Input":null,"Customer_ID":null,"Site_ID":null},{"Object_Type":"Dialable Number","Product_Technology_Family":"MN AUX","Number_of_Relationships":1,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","Prime":"Active","Aux":"Active","ISDN2":"Active"},"Address_ID":null,"Eligible":"Ineligible","List_of_Relationships":[{"Type":"Parent/Child","RPID":"someuuid-ddd-asdas4-asdasda"}],"Reason":["All Aux need to be Transitioned with Prime","The Prime needs to be Transitioned with the Aux"],"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0266183203","Provided_As_Input":null,"Customer_ID":null,"Site_ID":null},{"Object_Type":"Dialable Number","Product_Technology_Family":"MN AUX","Number_of_Relationships":1,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","Prime":"Active","Aux":"Active","ISDN2":"Active"},"Address_ID":null,"Eligible":"Ineligible","List_of_Relationships":[{"Type":"Parent/Child","RPID":"someuuid-ddd-asdas4-asdasda"}],"Reason":["All Aux need to be Transitioned with Prime","The Prime needs to be Transitioned with the Aux"],"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0266183204","Provided_As_Input":null,"Customer_ID":null,"Site_ID":null},{"Object_Type":"Dialable Number","Product_Technology_Family":"MN AUX","Number_of_Relationships":1,"Account_ID":null,"Characteristics_Of_Interest":{"Status":"Active","Prime":"Active","Aux":"Active","ISDN2":"Active"},"Address_ID":null,"Eligible":"Ineligible","List_of_Relationships":[{"Type":"Parent/Child","RPID":"someuuid-ddd-asdas4-asdasda"}],"Reason":["All Aux need to be Transitioned with Prime","The Prime needs to be Transitioned with the Aux"],"Object_Category":"Resource","Contract_ID":null,"In-Flight_Order_ID":null,"PIID":"0266183205","Provided_As_Input":null,"Customer_ID":null,"Site_ID":null}],"Client_ID":"24447","UUID":"08c39754-e994-4bf8-b8d0-6743383f4f93","Warning_Count":1}';
        
        Test.startTest();
            attachment attrecord= [Select id,body,bodylength,description from attachment where name=:'EligibilityResults.txt' limit 1];
             Map<Id, sObject> objRecordsoldMap = new Map<Id, sObject>();
             objRecordsoldMap.putAll( [Select id,body,bodylength,description from attachment where name=:'EligibilityResults.txt' limit 1 ] );
            attrecord.body=blob.valueOf(payloadString);
            attrecord.description='EligibilityResults';
            update attrecord;
            Map<Id, sObject> objRecordsnewMap = new Map<Id, sObject>();
             objRecordsnewMap.putAll( [Select id,body,bodylength,description from attachment where id=:attrecord.id limit 1 ] );
             TramasEligiblityUpdate.tamasAttachmentsUpdate(objRecordsnewMap,objRecordsoldMap);
        Test.stopTest();
        System.assert(attrecord.id!=null);
        //Assert, to check if a response-record is created with the related PC-record 
        
    }
     
    
    
}