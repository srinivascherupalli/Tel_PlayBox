@isTest
public with sharing class ReplicatorManagerTest {
    private static String ReplicatorAddress = '{"CIDN":"121","Ultimate_CIDN":"1891494118","Enterprise_ID":"553","ERROR_DESCRIPTION":"","Site":[{"ADBOR_ID":"111","Media_Type":"NBN","Site_Nick_Name":"Melbourne CBD","ADDRESS_NO_FROM":"22","ADDRESS_NO_TO":"25","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lonsdale","STREET_TYPE":"Street","LOC_NAME":"","ADBOR_POSTCODE":"3000","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","Address_Status":"CONFIRMED","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]},{"ADBOR_ID":"113","Media_Type":"NBN","Site_Nick_Name":"Sydney CBD","ADDRESS_NO_FROM":"234","ADDRESS_NO_TO":"278","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lakeview","STREET_TYPE":"Drive","LOC_NAME":"","ADBOR_POSTCODE":"2002","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","ADDRESS_STATUS":"","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"true","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]}]}';
    private static String serviceDTO='{ "Source_System_Id":"Replicator", "Correlation_Id":"1234", "ADBOR_Id":"413141258", "CIDN":"1234567890", "Error_Code":"", "Error_Description":"", "Site":[ { "ADBOR_Id":"152365895123", "Error_Code":"", "Error_Description":"", "productList":[ { "Product_Type":"Business Essentials", "Product_Identifier":"24432432432", "Association_Type":"", "Association_Role":"", "Association_Link_Id":"", "Business_Owner":"Business", "Bundle_Indicator":"Yes", "Purchase_Order":"", "Invoice_Arrangement_Id":"IA1234", "Invoice_Arrangement_Id_MICA":"", "In_Flight_Flag":"N", "In_Flight_Legacy_System":"", "In_Flight_Order_Id":"", "Nominated_FNN":"", "DOT_GenType":"", "Enterprise_Id":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"d", "Discount_Start_Date":"14/06/2017", "Discount_Monthly_Amount":"100", "Discount_Term":"Annual" } ], "service":[ { "Service_Id":"233424", "Technical_Association_Role":"tester", "Service_Type":"Broadband", "Bundle_Role":"Linked", "Last_Replicator_Update_Date":"14/06/2017", "Error_Code":"", "Error_Description":"", "serviceCharacteristic":[ { "name":"ADSL_Bearer_Id", "value":"" }, { "name":"VOIP_Platform", "value":"BW" }, { "name":"User_Type", "value":"Fax" } ], "planCharacteristic":[ { "Plan_Deal_Type":"aa", "Plan_Name":"bb", "Plan_Term":"manual", "Plan_Commercial_Type":"ss", "Plan_Monthly_Amount":"22", "Plan_Start_Date":"14/06/2018", "Instalments_Billed":"2", "Instalments_Remaining":"100", "Legacy_String":"", "discount":{ "Discount_Name":"serviceDiscount1", "Discount_Monthly_Amount":"33", "Discount_Percent_Amount":"33", "Discount_Start_Date":"07/02/2017", "Discount_Term":"cc" } }, { "Plan_Deal_Type":"cc", "Plan_Name":"vv", "Plan_Term":"quarterly", "Plan_Commercial_Type":"cs", "Plan_Monthly_Amount":"11", "Plan_Start_Date":"15/06/2017", "Instalments_Billed":"", "Instalments_Remaining":"", "Legacy_String":"", "discount":{ "Discount_Name":"serviceDiscount2", "Discount_Monthly_Amount":"23", "Discount_Percent_Amount":"", "Discount_Start_Date":"08/02/2017", "Discount_Term":"" } } ], "serviceRelationship":[ { "relationshipType":"contains", "device":{ "Device_Type":"Switch", "Device_Ownership":"Telstra", "Device_Model":"Yealink245", "Device_Name":"S-1", "SKU":"REP1234", "Device_Payment_Type":"monthly", "Device_Monthly_Amount":"33", "Device_Plan_Start_Date":"14/06/2019", "Device_Plan_Term":"ss", "Device_Billing_System":"cccc", "Device_Billing_System_Id":"2aa", "Legacy_Link":"ca", "DECT_BaseStation":"", "DECT_Handset":"", "Quantity":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"discount1", "Discount_Start_Date":"12/02/2016", "Discount_Term":"24", "Discount_Monthly_Amount":"25", "Discount_Percent_Amount":"" } ] } }, { "relationshipType":"contains", "serviceExtension":[ { "Services_From":"", "Services_To":"" }, { "Services_From":"", "Services_To":"" } ] }, { "relationshipType":"contains", "device":{ "Device_Type":"Switch", "Device_Ownership":"nbn", "Device_Model":"Yealink245", "Device_Name":"S-2", "SKU":"REP1234", "Device_Payment_Type":"atm", "Device_Monthly_Amount":"11", "Device_Plan_Start_Date":"12/02/2016", "Device_Plan_Term":"asa", "Device_Billing_System":"dsa", "Device_Billing_System_Id":"as2", "Legacy_Link":"", "DECT_BaseStation":"", "DECT_Handset":"", "Quantity":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"discount1", "Discount_Start_Date":"12/02/2016", "Discount_Term":"24", "Discount_Monthly_Amount":"25", "Discount_Percent_Amount":"" }, { "Discount_Name":"discount2", "Discount_Start_Date":"12/02/2016", "Discount_Term":"12", "Discount_Monthly_Amount":"250", "Discount_Percent_Amount":"" } ] } } ] }, { "Service_Id":"543433", "Technical_Association_Role":"developer", "Service_Type":"Voice", "Bundle_Role":"Compound", "Last_Replicator_Update_Date":"24/10/2018", "Error_Code":"", "Error_Description":"", "serviceCharacteristic":[ { "name":"ADSL_Bearer_Id", "value":"" }, { "name":"VOIP_Platform", "value":"BW" }, { "name":"User_Type", "value":"Fax" } ], "planCharacteristic":[ { "Plan_Deal_Type":"xx", "Plan_Name":"tt", "Plan_Term":"automatic", "Plan_Commercial_Type":"e1", "Plan_Monthly_Amount":"88", "Plan_Start_Date":"14/06/2018", "Instalments_Billed":"2", "Instalments_Remaining":"100", "Legacy_String":"", "discount":{ "Discount_Name":"serviceDiscount5", "Discount_Monthly_Amount":"43", "Discount_Percent_Amount":"53", "Discount_Start_Date":"07/02/2018", "Discount_Term":"cd" } } ], "serviceRelationship":[ { "relationshipType":"contains", "device":{ "Device_Type":"Router", "Device_Ownership":"Nbn", "Device_Model":"Luminous", "Device_Name":"S-16", "SKU":"REP1234", "Device_Payment_Type":"monthly", "Device_Monthly_Amount":"33", "Device_Plan_Start_Date":"14/06/2029", "Device_Plan_Term":"ss", "Device_Billing_System":"cccc", "Device_Billing_System_Id":"2aa", "Legacy_Link":"ca", "DECT_BaseStation":"", "DECT_Handset":"", "Quantity":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"discount8", "Discount_Start_Date":"12/02/2018", "Discount_Term":"14", "Discount_Monthly_Amount":"15", "Discount_Percent_Amount":"" } ] } }, { "relationshipType":"contains", "serviceExtension":[ { "Services_From":"", "Services_To":"" }, { "Services_From":"", "Services_To":"" } ] } ] } ] } ] }, { "ADBOR_Id":"189562345874", "Error_Code":"", "Error_Description":"", "productList":[ { "Product_Type":"Commercial Essentials", "Product_Identifier":"14432432432", "Association_Type":"", "Association_Role":"", "Association_Link_Id":"", "Business_Owner":"Commercial", "Bundle_Indicator":"Yes", "Purchase_Order":"", "Invoice_Arrangement_Id":"IA1234", "Invoice_Arrangement_Id_MICA":"", "In_Flight_Flag":"Y", "In_Flight_Legacy_System":"", "In_Flight_Order_Id":"", "Nominated_FNN":"", "DOT_GenType":"", "Enterprise_Id":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"asd", "Discount_Start_Date":"14/06/2017", "Discount_Monthly_Amount":"222", "Discount_Term":"aasa" }, { "Discount_Name":"dqdq", "Discount_Start_Date":"14/06/2017", "Discount_Monthly_Amount":"2211", "Discount_Term":"asas" } ], "service":[ { "Service_Id":"233424", "Technical_Association_Role":"", "Service_Type":"Broadband", "Bundle_Role":"Linked", "Last_Replicator_Update_Date":"14/06/2017", "Error_Code":"", "Error_Description":"", "serviceCharacteristic":[ { "name":"ADSL_Bearer_Id", "value":"" }, { "name":"VOIP_Platform", "value":"BW" }, { "name":"User_Type", "value":"Fax" }, { "name":"IP_Type", "value":"" } ], "planCharacteristic":[ { "Plan_Deal_Type":"xxww", "Plan_Name":"dacaca", "Plan_Term":"dsaaw", "Plan_Commercial_Type":"das", "Plan_Monthly_Amount":"22", "Plan_Start_Date":"14/06/2017", "Instalments_Billed":"", "Instalments_Remaining":"", "Legacy_String":"", "discount":{ "Discount_Name":"serviceDiscount1", "Discount_Monthly_Amount":"33", "Discount_Percent_Amount":"33", "Discount_Start_Date":"07/02/2017", "Discount_Term":"" } }, { "Plan_Deal_Type":"wqeqeq", "Plan_Name":"asaa", "Plan_Term":"221aa", "Plan_Commercial_Type":"avava", "Plan_Monthly_Amount":"2222", "Plan_Start_Date":"14/06/2017", "Instalments_Billed":"", "Instalments_Remaining":"", "Legacy_String":"", "discount":{ "Discount_Name":"serviceDiscount2", "Discount_Monthly_Amount":"23", "Discount_Percent_Amount":"", "Discount_Start_Date":"08/02/2017", "Discount_Term":"" } } ], "serviceRelationship":[ { "relationshipType":"contains", "device":{ "Device_Type":"Switch", "Device_Ownership":"", "Device_Model":"Yealink245", "Device_Name":"S-1", "SKU":"REP1234", "Device_Payment_Type":"", "Device_Monthly_Amount":"", "Device_Plan_Start_Date":"", "Device_Plan_Term":"", "Device_Billing_System":"", "Device_Billing_System_Id":"", "Legacy_Link":"", "DECT_BaseStation":"", "DECT_Handset":"", "Quantity":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"discount1", "Discount_Start_Date":"12/02/2016", "Discount_Term":"24", "Discount_Monthly_Amount":"25", "Discount_Percent_Amount":"" }, { "Discount_Name":"discount2", "Discount_Start_Date":"12/02/2016", "Discount_Term":"12", "Discount_Monthly_Amount":"250", "Discount_Percent_Amount":"" } ] } }, { "relationshipType":"contains", "serviceExtension":[ { "Services_From":"1", "Services_To":"1" }, { "Services_From":"1", "Services_To":"1" } ] }, { "relationshipType":"contains", "device":{ "Device_Type":"Switch", "Device_Ownership":"", "Device_Model":"Yealink245", "Device_Name":"S-2", "SKU":"REP1234", "Device_Payment_Type":"", "Device_Monthly_Amount":"", "Device_Plan_Start_Date":"", "Device_Plan_Term":"", "Device_Billing_System":"", "Device_Billing_System_Id":"", "Legacy_Link":"", "DECT_BaseStation":"", "DECT_Handset":"", "Quantity":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"discount1", "Discount_Start_Date":"12/02/2016", "Discount_Term":"24", "Discount_Monthly_Amount":"25", "Discount_Percent_Amount":"" }, { "Discount_Name":"discount2", "Discount_Start_Date":"12/02/2016", "Discount_Term":"12", "Discount_Monthly_Amount":"250", "Discount_Percent_Amount":"" } ] } } ] }, { "Service_Id":"543433", "service_Type":"Voice", "Last_Replicator_Update_Date":"14/06/2017", "Error_Code":"", "Error_Description":"", "serviceCharacteristic":[ { "name":"ADSL_Bearer_Id", "value":"" }, { "name":"VOIP_Platform", "value":"BW" }, { "name":"User_Type", "value":"Fax" }, { "name":"IP_Type", "value":"" } ], "planCharacteristic":[ { "Plan_Deal_Type":"", "Plan_Name":"", "Plan_Term":"", "Plan_Commercial_Type":"", "Plan_Monthly_Amount":"", "Plan_Start_Date":"", "Instalments_Billed":"", "Instalments_Remaining":"", "Legacy_String":"", "discount":{ "Discount_Name":"serviceDiscount2", "Discount_Monthly_Amount":"23", "Discount_Percent_Amount":"", "Discount_Start_Date":"08/02/2017", "Discount_Term":"" } }, { "Plan_Deal_Type":"", "Plan_Name":"", "Plan_Term":"", "Plan_Commercial_Type":"", "Plan_Monthly_Amount":"", "Plan_Start_Date":"", "Instalments_Billed":"", "Instalments_Remaining":"", "Legacy_String":"", "discount":{ "Discount_Name":"serviceDiscount2", "Discount_Monthly_Amount":"23", "Discount_Percent_Amount":"", "Discount_Start_Date":"08/02/2017", "Discount_Term":"" } } ] } ] } ] }, { "ADBOR_Id":"256345896231", "Error_Code":"", "Error_Description":"", "productList":[ { "Product_Type":"TBB Standalone", "Product_Identifier":"6", "Association_Type":"", "Association_Role":"", "Association_Link_Id":"", "Business_Owner":"Legacy", "Bundle_Indicator":"No", "Purchase_Order":"Y", "Invoice_Arrangement_Id":"1115192500", "Invoice_Arrangement_Id_MICA":"", "In_Flight_Flag":"N", "In_Flight_Legacy_System":"AXIS", "In_Flight_Order_Id":"", "Nominated_FNN":"", "DOT_GenType":"", "Enterprise_Id":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"", "Discount_Start_Date":"", "Discount_Monthly_Amount":"", "Discount_Term":"" } ], "service":[ { "Service_ID":"N1148129R", "Technical_Association_Role":"", "Service_Type":"Broadband", "Bundle_Role":"", "Last_Replicator_Update_Date":"2017-11-06 22:57:28", "Error_Code":"", "Error_Description":"", "serviceCharacteristic":[ { "name":"ADSL_Bearer_Id", "value":"0326481299" }, { "name":"VOIP_Platform", "value":"" }, { "name":"User_Type", "value":"" }, { "name":"IP_Type", "value":"IPv4" }, { "name":"Telstra_GW_IPv4", "value":"110.142.29.1" }, { "name":"Telstra_GW_IPv6", "value":"255.255.255.0" }, { "name":"Cust_WAN_IP", "value":"110.142.19.222" }, { "name":"IPv6_Prefix", "value":"/56" }, { "name":"Cust_LAN_IP", "value":"120.151.100.1" }, { "name":"Cust_LAN_IPv6", "value":"" }, { "name":"BCS_FNN", "value":"0326481299" }, { "name":"Host_Name", "value":"zaibpt0@direct.telstra.net" }, { "name":"Host_Password", "value":"450851" }, { "name":"Ops_Name", "value":"N7758001R" }, { "name":"GB_Allowance", "value":"9.8E-45" }, { "name":"VoicetoEmail_Text", "value":"" }, { "name":"Unified_Plan_ID", "value":"" }, { "name":"Directory_Option", "value":"" }, { "name":"Call_Barring_Option", "value":"" }, { "name":"RCRM_ Service", "value":"N" }, { "name":"Essential_Service", "value":"" }, { "name":"Temporary_Service", "value":"N" }, { "name":"NSC_ Service", "value":"" }, { "name":"AOH_FNN", "value":"" }, { "name":"AOH_Cust_Trade_Name", "value":"" }, { "name":"AOH_Cust_Contact", "value":"" }, { "name":"AOH_Cust_Email", "value":"" }, { "name":"AOH_Cust_Phone_Num", "value":"" }, { "name":"Shareable", "value":"Y" }, { "name":"Group_Plan_Name", "value":"TBB Group Core Shareable" }, { "name":"Group_Deal_Name", "value":"BizEssentials X-Small Group Allowance - 60GB" } ], "planCharacteristic":[ { "Plan_Deal_Type":"Plan", "Plan_Name":"TBB FTTP High Speed X-Small Monthly Fee", "Plan_Term":"24", "Plan_Commercial_Type":"Contract", "Plan_Monthly_Amount":"36.363636", "Plan_Start_Date":"28-07-2017", "Instalments_Billed":"3", "Instalments_Remaining":"21", "Legacy_String":"NA", "discount":{ "Discount_Name":"", "Discount_Monthly_Amount":"", "Discount_Percent_Amount":"", "Discount_Start_Date":"", "Discount_Term":"" } } ], "serviceRelationship":[ { "relationshipType":"contains", "device":{ "Device_Type":"Switch", "Device_Ownership":"Owned", "Device_Model":"CiscoSG300-10P", "Device_Name":"", "SKU":"", "Device_Payment_Type":"", "Device_Monthly_Amount":"", "Device_Plan_Start_Date":"", "Device_Plan_Term":"", "Device_Billing_System":"ONDB", "Device_Billing_System_ID":"48450484066", "Legacy_Link":"", "DECT_BaseStation":"", "DECT_Handset":"", "Quantity":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"", "Discount_Monthly_Amount":"", "Discount_Percent_Amount":"", "Discount_Start_Date":"", "Discount_Term":"" } ] } }, { "relationshipType":"contains", "device":{ "Device_Type":"Router", "Device_Ownership":"Owned", "Device_Model":"6", "Device_Name":"", "SKU":"", "Device_Payment_Type":"", "Device_Monthly_Amount":"", "Device_Plan_Start_Date":"", "Device_Plan_Term":"", "Device_Billing_System":"ONDB", "Device_Billing_System_ID":"48450484066", "Legacy_Link":"", "DECT_BaseStation":"", "DECT_Handset":"", "Quantity":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"", "Discount_Monthly_Amount":"", "Discount_Percent_Amount":"", "Discount_Start_Date":"", "Discount_Term":"" } ] } }, { "relationshipType":"contains", "serviceExtension":[  ] } ] } ] }, { "Product_Type":"PSTN", "Product_Identifier":"9", "Association_Type":"", "Association_Role":"", "Association_Link_Id":"", "Business_Owner":"Legacy", "Bundle_Indicator":"No", "Purchase_Order":"Y", "Invoice_Arrangement_Id":"1115192500", "Invoice_Arrangement_Id_MICA":"", "In_Flight_Flag":"N", "In_Flight_Legacy_System":"AXIS", "In_Flight_Order_Id":"", "Nominated_FNN":"", "DOT_GenType":"", "Enterprise_Id":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"", "Discount_Start_Date":"", "Discount_Monthly_Amount":"", "Discount_Term":"" } ], "service":[ { "Service_ID":"0326481299", "Technical_Association_Role":"", "Service_Type":"Voice", "Bundle_Role":"", "Last_Replicator_Update_Date":"2017-11-06 22:57:28", "Error_Code":"", "Error_Description":"", "serviceCharacteristic":[ { "name":"ADSL_Bearer_Id", "value":"" }, { "name":"VOIP_Platform", "value":"" }, { "name":"User_Type", "value":"" }, { "name":"IP_Type", "value":"" }, { "name":"Telstra_GW_IPv4", "value":"" }, { "name":"Telstra_GW_IPv6", "value":"" }, { "name":"Cust_WAN_IP", "value":"" }, { "name":"IPv6_Prefix", "value":"" }, { "name":"Cust_LAN_IP", "value":"" }, { "name":"Cust_LAN_IPv6", "value":"" }, { "name":"BCS_FNN", "value":"" }, { "name":"Host_Name", "value":"" }, { "name":"Host_Password", "value":"" }, { "name":"Ops_Name", "value":"" }, { "name":"GB_Allowance", "value":"" }, { "name":"VoicetoEmail_Text", "value":"" }, { "name":"Unified_Plan_ID", "value":"" }, { "name":"Directory_Option", "value":"Directory Listing" }, { "name":"Call_Barring_Option", "value":"" }, { "name":"RCRM_ Service", "value":"N" }, { "name":"Essential_Service", "value":"Y" }, { "name":"Temporary_Service", "value":"Y" }, { "name":"NSC_ Service", "value":"" }, { "name":"AOH_FNN", "value":"" }, { "name":"AOH_Cust_Trade_Name", "value":"" }, { "name":"AOH_Cust_Contact", "value":"" }, { "name":"AOH_Cust_Email", "value":"" }, { "name":"AOH_Cust_Phone_Num", "value":"" }, { "name":"Shareable", "value":"" }, { "name":"Group_Plan_Name", "value":"" }, { "name":"Group_Deal_Name", "value":"" } ], "planCharacteristic":[ { "Plan_Deal_Type":"Plan", "Plan_Name":"", "Plan_Term":"1", "Plan_Commercial_Type":"Casual", "Plan_Monthly_Amount":"", "Plan_Start_Date":"", "Instalments_Billed":"", "Instalments_Remaining":"", "Legacy_String":"NA", "discount":{ "Discount_Name":"$0.00/UNIT RATE METH=1/BCAT=REC/BILG METH = ADV", "Discount_Monthly_Amount":"6.21", "Discount_Percent_Amount":"", "Discount_Start_Date":"13-10-2014", "Discount_Term":"" } } ], "serviceRelationship":[ { "relationshipType":"contains", "device":{ "Device_Type":"BYO Analogue Device", "Device_Ownership":"Owned", "Device_Model":"Analogue Device", "Device_Name":"", "SKU":"", "Device_Payment_Type":"", "Device_Monthly_Amount":"", "Device_Plan_Start_Date":"", "Device_Plan_Term":"", "Device_Billing_System":"", "Device_Billing_System_ID":"", "Legacy_Link":"", "DECT_BaseStation":"", "DECT_Handset":"", "Quantity":"", "Error_Code":"", "Error_Description":"", "discount":[ { "Discount_Name":"", "Discount_Monthly_Amount":"", "Discount_Percent_Amount":"", "Discount_Start_Date":"", "Discount_Term":"" } ] } }, { "relationshipType":"contains", "serviceExtension":[ ] } ] } ] } ] } ] }';
    private static String selectedOffer='';
    private static List<String> adborIdList;
    @testSetup static void setup() {
        ProductTestService.getNewAccount('Test Account');
    }
    
    static ReplicatorGetServiceDataObject createBaseForOffers(){
        List<ReplicatorGetServiceDataObject.SiteDTO> getSiteDTO = new List<ReplicatorGetServiceDataObject.SiteDTO>();
        List<ReplicatorGetServiceDataObject.ProductDTO> productDTOList = new List<ReplicatorGetServiceDataObject.ProductDTO>();
        List<ReplicatorGetServiceDataObject.ProductDTO> productDTOList1 = new List<ReplicatorGetServiceDataObject.ProductDTO>();
        List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList = new  List<ReplicatorGetServiceDataObject.ServiceDTO>();
        List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList1 = new  List<ReplicatorGetServiceDataObject.ServiceDTO>();
        List<ReplicatorGetServiceDataObject.ServiceCharacteristicDTO> serviceCharList = new  List<ReplicatorGetServiceDataObject.ServiceCharacteristicDTO>();   
            ReplicatorGetServiceDataObject.ServiceCharacteristicDTO schar = new ReplicatorGetServiceDataObject.ServiceCharacteristicDTO();
            schar.name = 'Zone';
            schar.value = '1';
            
            ReplicatorGetServiceDataObject.ServiceCharacteristicDTO schar1 = new ReplicatorGetServiceDataObject.ServiceCharacteristicDTO();
            schar1.name = 'Type';
            schar1.value = 'Standard';
            
            serviceCharList.add(schar);
            serviceCharList.add(schar1);
            
            ReplicatorGetServiceDataObject.ServiceDTO  service1 = new ReplicatorGetServiceDataObject.ServiceDTO();
            service1.Service_Id = 'Service 1';
            service1.serviceCharacteristic = serviceCharList;
            ReplicatorGetServiceDataObject.ServiceDTO  service2 = new ReplicatorGetServiceDataObject.ServiceDTO();
            service2.Service_Id = 'Service 2';
            service2.serviceCharacteristic = serviceCharList;
        
            serviceList.add(service1);
            serviceList1.add(service2);
            
            ReplicatorGetServiceDataObject.ProductDTO pd1 = new ReplicatorGetServiceDataObject.ProductDTO();
           // ReplicatorGetServiceDataObject.ProductDTO pd2 = new ReplicatorGetServiceDataObject.ProductDTO();
          
            pd1.service = serviceList;
            pd1.Product_Type = 'ISDN-BRA';           
            productDTOList.add(pd1);
            
            ReplicatorGetServiceDataObject.SiteDTO sitedt1 = new ReplicatorGetServiceDataObject.SiteDTO();
            ReplicatorGetServiceDataObject.SiteDTO sitedt2 = new ReplicatorGetServiceDataObject.SiteDTO();
            
            sitedt1.ADBOR_Id = 'AddressID-1Test';
            sitedt1.productList = productDTOList;
            
            sitedt2.ADBOR_Id = 'AddressID-2Test';
            sitedt2.productList = productDTOList;
        
            getSiteDTO.add(sitedt1);
            getSiteDTO.add(sitedt2); 
            
            ReplicatorGetServiceDataObject rsd = new ReplicatorGetServiceDataObject();
            rsd.Site = getSiteDTO;
            rsd.CIDN = 'Test Trans';

        
            Account acc = AccountTestFactory.buildAccount('Test Name');
            acc.CIDN__c = 'Test Trans';
            insert acc;
            cscrm__Address__c address = AccountTestFactory.buildAddress('AddressID-1Test');
            insert address;
            cscrm__Address__c address1 = AccountTestFactory.buildAddress('AddressID-2Test');
            insert address1;
            
            List<Contact> contactInsertList = new List<Contact>();
           
            Contact pc = AccountTestFactory.buildContact(acc, 'testPC', 'testabc122@test.com');
            contactInsertList.add(pc);
            Contact sc = AccountTestFactory.buildContact(acc, 'testSC', 'estabc13222@testdom.com');
            contactInsertList.add(sc);
            
            Contact pc1 = AccountTestFactory.buildContact(acc, 'testPC1', 'testabc122@test1.com');
            contactInsertList.add(pc1);
            Contact sc1 = AccountTestFactory.buildContact(acc, 'testSC1', 'estabc13222@testdom1.com');
            contactInsertList.add(sc1);
        
            insert contactInsertList;

            cscrm__Site__c site = AccountTestFactory.buildSite(address.id, acc.id);
            site.Primary_Contact__c = pc.id;
            site.Secondary_Contact__c = sc.id;            
            insert site;
            
            cscrm__Site__c site1 = AccountTestFactory.buildSite(address.id, acc.id);
            site.Primary_Contact__c = pc1.id;
            site.Secondary_Contact__c = sc1.id;            
            insert site1;
            
             cscfga__Product_Category__c pcategory = ProductTestFactory.buildProductCategory();
             pcategory.name = 'Modular Products';
             insert pcategory;
        
            cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
            piSeat.Name = 'Standard - Zone1';
            piSeat.Package_Name__c = 'Connected Workplace';
            piSeat.Type__c ='Standard';
            piSeat.External_Id__c = 'test';
            piSeat.cspmb__Product_Definition_Name__c ='User';
            piSeat.Zone__c = 'Zone 1';
            insert piSeat;
             
            cscfga__Configuration_Offer__c  offer = new cscfga__Configuration_Offer__c();
            offer.Name= 'Connected Workplace Package';
            insert offer;
            
            cscfga__Configuration_Offer__c  offer1 = new cscfga__Configuration_Offer__c();
            offer.Name= 'Connected Workplace';
            insert offer1;

            cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            config.cscfga__Description__c = 'test Description ';
            config.cscfga__Contract_Term__c = 36;
            config.Name = 'User 1';
            config.cscfga__configuration_offer__c = offer.id;
            config.cscfga__Product_Basket__c =null;
            update config;
            
            cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
            config1.cscfga__Description__c = 'test Description1 ';
            config1.cscfga__Contract_Term__c = 36;
            config1.Name = 'Site';
            config1.cscfga__configuration_offer__c = offer.id;
            config1.cscfga__Product_Basket__c =null;
            update config1;
         
            cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
            config2.cscfga__Description__c = 'test Description ';
            config2.cscfga__Contract_Term__c = 36;
            config2.Name = 'User 1';
            config2.cscfga__configuration_offer__c = offer1.id;
            config2.cscfga__Product_Basket__c =null;
            update config2;

           
            List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
             cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('User', 'test', config.id);
            attList.add(attr0);

            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('ZoneSelected', 'Zone 2', config.id);
            attList.add(attr1);

            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('TypeUser', 'Standard', config.id);
            attList.add(attr2);

            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '5', config.id);
            attList.add(attr3);

            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('TOC', '500.00', config.id);
            attList.add(attr4);

            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('TRC', '600', config.id);
            attList.add(attr5);
            
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('Zone', null, config.id);
            attList.add(attr6);

            insert attList;
        
             Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
             insert opp;
 
             return rsd;
    }
    
    static testMethod void getCustomerSites_withoutErrorTest() {
        Test.startTest();
        List<Account> acctList = new List<Account>([SELECT Id FROM Account WHERE name = 'Test Account']);
        System.assertEquals(acctList.size(), 1, 'Unexpected number of Accounts retrived');
        Account acct = acctList.get(0);
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            ReplicatorGetSiteDataObject getSiteDTO = ReplicatorManager.getCustomerSites(acct.Id); 
            System.debug('GetSiteDTO: ' + getSiteDTO);
            
            System.assert(getSiteDTO != null, 'Error occured during getSite callout');
            System.assert(getSiteDTO.Site != null, 'Error, response do not contain any sites');
            System.assertEquals(getSiteDTO.Site.size(), 2, 'Error, unexpected number of sites in the response');
        Test.stopTest();
    }
    
    static testMethod void getCustomerServicesAtSite_withoutErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        List<String> demo=new List<String>();
        	demo.add('111');
        	demo.add('1143');
        	List<String> siteNameArray = new List<String>();
        	siteNameArray.add('111#abc');
        	siteNameArray.add('1143#xyz');
            ReplicatorGetServiceDataObject getServiceDTO = ReplicatorManager.getCustomerServicesAtSite('finCIDN', demo, siteNameArray);
            System.debug('getServiceDTO: ' + getServiceDTO);
            System.assert(getServiceDTO != null, 'Error occured during getService callout');
            System.assert(getServiceDTO.Site.get(0).productList != null, 'Error, response do not contain any products');
            System.assertEquals(getServiceDTO.Site.get(0).productList.size(), 1, 'Error, unexpected number of products in the response');
        Test.stopTest();
    }    
    
    static testMethod void getCustomerSites_withErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            ReplicatorGetSiteDataObject getSiteDTO = ReplicatorManager.getCustomerSites('errorId'+ IntegrationRecordHandlerUtil.ERROR_404_CODE);
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO != null, 'Error occured during getSite callout');
            System.assertEquals(getSiteDTO.error_code , String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE), 'Error, unexpected error code');
        Test.stopTest();
    }     
    
    static testMethod void inFlightCheckCase() {
        Test.startTest();
	  	AddressAndSiteObjectUtility.AuraProcessingMessage msg=ReplicatorManager.inFlightCheck('1010101018','123');
        Test.stopTest();
        system.assert(msg.isSuccess==false);
    } 
    
    static testMethod void upsertAddressSuccessCase1() {
        adborIdList=new List<String>();
        adborIdList.add('123454542154');
        adborIdList.add('123454547896');
        AddressAndSiteObjectUtility.AuraProcessingMessage expectedMsg = new AddressAndSiteObjectUtility.AuraProcessingMessage();
        expectedMsg.isSuccess=true;
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg=ReplicatorManager.upsertAddress(adborIdList,ReplicatorAddress);
        Test.stopTest();
        //System.assertEquals(expectedMsg.isSuccess, msg.isSuccess);
    }    
    
    static testMethod void upsertAddressFailureCase1() {
        AddressAndSiteObjectUtility.AuraProcessingMessage expectedMsg = new AddressAndSiteObjectUtility.AuraProcessingMessage();
        expectedMsg.isSuccess=false;
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg=ReplicatorManager.upsertAddress(adborIdList,ReplicatorAddress);
        Test.stopTest();
        //System.assert(msg==null);
    }   
    
    static testMethod void getOffersInListSuccess(){
        ReplicatorGetServiceDataObject service=createBaseForOffers();
        String serviceString = JSON.serialize(service);
        Test.startTest();
        List<String> offers=ReplicatorManager.getEligibleOffers(serviceString);  
        Test.stopTest();
        System.debug('getEligibleOffers:'+offers);
        System.assert(!offers.isEmpty());
    }
	
    static testMethod void getOffersInListFailure(){
        String serviceString='';
        Test.startTest();
        List<String> offers=ReplicatorManager.getEligibleOffers(serviceString);  
        Test.stopTest();
        System.assertEquals(null,offers);
    }
    
     static testMethod void redirectToBasketSuccess(){
        ReplicatorGetServiceDataObject service=createBaseForOffers();
        String serviceString = JSON.serialize(service);
        List<String> offers=ReplicatorManager.getEligibleOffers(serviceString);          
        selectedOffer = JSON.serialize(offers);
        Test.startTest();
        List<Opportunity> lstOpp = [Select Id from Opportunity];
        String urlToBasket=ReplicatorManager.redirectToBasket(serviceString,selectedOffer,lstOpp[0].Id);  
        Test.stopTest();
        System.assertEquals(null,urlToBasket);
    }  
    
    static testMethod void redirectToBasketFailure(){
        String serviceString='';
        createBaseForOffers();
        Test.startTest();
        List<Opportunity> lstOpp = [Select Id from Opportunity];
        String urlToBasket=ReplicatorManager.redirectToBasket(serviceString,selectedOffer,lstOpp[0].Id);  
        Test.stopTest();
        System.debug('urlToBasket:'+urlToBasket);
        System.assertEquals(null,urlToBasket);
    }  
	
    static testMethod void getReplicatorGetServiceDataObjectTest(){
        Test.startTest();
        ReplicatorGetServiceDataObject obj=ReplicatorManager.getReplicatorGetServiceDataObject();  
        Test.stopTest();
        System.assert(obj!=null);
    }
    
    static testMethod void getSelectedSiteTest(){
        String lagacySites = '{\"CIDN\":\"3480495100\",\"Correlation_Id\":\"SFDC_REP_GETSERVICE63b01b514685deecc8\",\"Error_Code\":\"\",\"Error_Description\":\"\",\"site\":[{\"ADBOR_Id\":\"120301570\",\"Error_Code\":\"\",\"Error_Description\":\"\",\"productList\":[{\"Association_Link_Id\":\"\",\"Association_Role\":\"\",\"Association_Type\":\"Multinumber\",\"Bundle_Indicator\":\"No\",\"Business_Owner\":\"Legacy\",\"discount\":[{\"Discount_Monthly_Amount\":\"\",\"Discount_Name\":\"\",\"Discount_Start_Date\":\"\",\"Discount_Term\":\"\"}],\"DOT_GenType\":\"\",\"Enterprise_Id\":\"\",\"Error_Code\":\"\",\"Error_Description\":\"\",\"In_Flight_Flag\":\"N\",\"In_Flight_Legacy_System\":\"AXIS\",\"In_Flight_Order_Id\":\"\",\"Invoice_Arrangement_Id\":\"7830903500\",\"Invoice_Arrangement_Id_MICA\":\"\",\"Nominated_FNN\":\"\",\"Product_Identifier\":\"124938\",\"Product_Type\":\"ISDN-BRA\",\"Purchase_Order\":\"N\",\"service\":[{\"Bundle_Role\":\"\",\"Error_Code\":\"\",\"Error_Description\":\"\",\"Last_Replicator_Update_Date\":\"2018-02-23 23:39:02\",\"planCharacteristic\":[{\"discount\":{\"Discount_Monthly_Amount\":\"\",\"Discount_Name\":\"\",\"Discount_Percent_Amount\":\"\",\"Discount_Start_Date\":\"\",\"Discount_Term\":\"\"},\"Instalments_Billed\":\"\",\"Instalments_Remaining\":\"\",\"Legacy_String\":\"NA\",\"Plan_Commercial_Type\":\"Not Known\",\"Plan_Deal_Type\":\"Plan\",\"Plan_Monthly_Amount\":\"\",\"Plan_Name\":\"\",\"Plan_Start_Date\":\"\",\"Plan_Term\":\"\"}],\"Service_Id\":\"0355995247\",\"Service_Type\":\"Voice\",\"serviceCharacteristic\":[{\"name\":\"ADSL_Bearer_Id\",\"value\":\"\"},{\"name\":\"VOIP_Platform\",\"value\":\"\"},{\"name\":\"User_Type\",\"value\":\"\"},{\"name\":\"IP_Type\",\"value\":\"\"},{\"name\":\"Telstra_GW_IPv4\",\"value\":\"\"},{\"name\":\"Telstra_GW_IPv6\",\"value\":\"\"},{\"name\":\"Cust_WAN_IP\",\"value\":\"\"},{\"name\":\"IPv6_Prefix\",\"value\":\"\"},{\"name\":\"Cust_LAN_IP\",\"value\":\"\"},{\"name\":\"Cust_LAN_IPv6\",\"value\":\"\"},{\"name\":\"BCS_FNN\",\"value\":\"\"},{\"name\":\"Host_Name\",\"value\":\"\"},{\"name\":\"Host_Password\",\"value\":\"\"},{\"name\":\"Ops_Name\",\"value\":\"\"},{\"name\":\"GB_Allowance\",\"value\":\"\"},{\"name\":\"VoicetoEmail_Text\",\"value\":\"\"},{\"name\":\"Unified_Plan_ID\",\"value\":\"\"},{\"name\":\"Directory_Option\",\"value\":\"\"},{\"name\":\"Call_Barring_Option\",\"value\":\"NO CALL BARRING\"},{\"name\":\"RCRM_ Service\",\"value\":\"N\"},{\"name\":\"Essential_Service\",\"value\":\"Y\"},{\"name\":\"Temporary_Service\",\"value\":\"N\"},{\"name\":\"NSC_ Service\",\"value\":\"\"},{\"name\":\"AOH_FNN\",\"value\":\"\"},{\"name\":\"AOH_Cust_Trade_Name\",\"value\":\"\"},{\"name\":\"AOH_Cust_Contact\",\"value\":\"\"},{\"name\":\"AOH_Cust_Email\",\"value\":\"\"},{\"name\":\"AOH_Cust_Phone_Num\",\"value\":\"\"},{\"name\":\"Shareable\",\"value\":\"\"},{\"name\":\"Group_Plan_Name\",\"value\":\"\"},{\"name\":\"Group_Deal_Name\",\"value\":\"\"}],\"serviceRelationship\":[{\"device\":{\"DECT_BaseStation\":\"\",\"DECT_Handset\":\"\",\"Device_Billing_System\":\"\",\"Device_Billing_System_Id\":\"\",\"Device_Model\":\"\",\"Device_Monthly_Amount\":\"\",\"Device_Name\":\"\",\"Device_Ownership\":\"\",\"Device_Payment_Type\":\"\",\"Device_Plan_Start_Date\":\"\",\"Device_Plan_Term\":\"\",\"Device_Type\":\"\",\"discount\":[{\"Discount_Monthly_Amount\":\"\",\"Discount_Name\":\"\",\"Discount_Percent_Amount\":\"\",\"Discount_Start_Date\":\"\",\"Discount_Term\":\"\"}],\"Error_Code\":\"\",\"Error_Description\":\"\",\"Legacy_Link\":\"\",\"Quantity\":\"\",\"SKU\":\"\"},\"relationshipType\":\"contains\"}],\"Technical_Association_Role\":\"Secondary\"}]}],\"siteName\":\"      MORTLAKE-ARARAT 2164-0  RD WOORNDOO VIC\"},{\"ADBOR_Id\":\"50281042\",\"Error_Code\":\"\",\"Error_Description\":\"\",\"productList\":[{\"Association_Link_Id\":\"\",\"Association_Role\":\"\",\"Association_Type\":\"\",\"Bundle_Indicator\":\"No\",\"Business_Owner\":\"Legacy\",\"discount\":[{\"Discount_Monthly_Amount\":\"\",\"Discount_Name\":\"\",\"Discount_Start_Date\":\"\",\"Discount_Term\":\"\"}],\"DOT_GenType\":\"\",\"Enterprise_Id\":\"\",\"Error_Code\":\"\",\"Error_Description\":\"\",\"In_Flight_Flag\":\"N\",\"In_Flight_Legacy_System\":\"AXIS\",\"In_Flight_Order_Id\":\"\",\"Invoice_Arrangement_Id\":\"7830903500\",\"Invoice_Arrangement_Id_MICA\":\"\",\"Nominated_FNN\":\"\",\"Product_Identifier\":\"370252\",\"Product_Type\":\"PSTN\",\"Purchase_Order\":\"N\",\"service\":[{\"Bundle_Role\":\"\",\"Error_Code\":\"\",\"Error_Description\":\"\",\"Last_Replicator_Update_Date\":\"2018-02-23 23:39:02\",\"planCharacteristic\":[{\"discount\":{\"Discount_Monthly_Amount\":\"\",\"Discount_Name\":\"\",\"Discount_Percent_Amount\":\"\",\"Discount_Start_Date\":\"\",\"Discount_Term\":\"\"},\"Instalments_Billed\":\"\",\"Instalments_Remaining\":\"\",\"Legacy_String\":\"NA\",\"Plan_Commercial_Type\":\"Casual\",\"Plan_Deal_Type\":\"Plan\",\"Plan_Monthly_Amount\":\"\",\"Plan_Name\":\"\",\"Plan_Start_Date\":\"\",\"Plan_Term\":\"1\"}],\"Service_Id\":\"0354706529\",\"Service_Type\":\"Voice\",\"serviceCharacteristic\":[{\"name\":\"ADSL_Bearer_Id\",\"value\":\"\"},{\"name\":\"VOIP_Platform\",\"value\":\"\"},{\"name\":\"User_Type\",\"value\":\"\"},{\"name\":\"IP_Type\",\"value\":\"\"},{\"name\":\"Telstra_GW_IPv4\",\"value\":\"\"},{\"name\":\"Telstra_GW_IPv6\",\"value\":\"\"},{\"name\":\"Cust_WAN_IP\",\"value\":\"\"},{\"name\":\"IPv6_Prefix\",\"value\":\"\"},{\"name\":\"Cust_LAN_IP\",\"value\":\"\"},{\"name\":\"Cust_LAN_IPv6\",\"value\":\"\"},{\"name\":\"BCS_FNN\",\"value\":\"\"},{\"name\":\"Host_Name\",\"value\":\"\"},{\"name\":\"Host_Password\",\"value\":\"\"},{\"name\":\"Ops_Name\",\"value\":\"\"},{\"name\":\"GB_Allowance\",\"value\":\"\"},{\"name\":\"VoicetoEmail_Text\",\"value\":\"\"},{\"name\":\"Unified_Plan_ID\",\"value\":\"\"},{\"name\":\"Directory_Option\",\"value\":\"No Entry Line\"},{\"name\":\"Call_Barring_Option\",\"value\":\"NO CALL BARRING\"},{\"name\":\"RCRM_ Service\",\"value\":\"N\"},{\"name\":\"Essential_Service\",\"value\":\"Y\"},{\"name\":\"Temporary_Service\",\"value\":\"N\"},{\"name\":\"NSC_ Service\",\"value\":\"\"},{\"name\":\"AOH_FNN\",\"value\":\"\"},{\"name\":\"AOH_Cust_Trade_Name\",\"value\":\"\"},{\"name\":\"AOH_Cust_Contact\",\"value\":\"\"},{\"name\":\"AOH_Cust_Email\",\"value\":\"\"},{\"name\":\"AOH_Cust_Phone_Num\",\"value\":\"\"},{\"name\":\"Shareable\",\"value\":\"\"},{\"name\":\"Group_Plan_Name\",\"value\":\"\"},{\"name\":\"Group_Deal_Name\",\"value\":\"\"}],\"serviceRelationship\":[{\"device\":{\"DECT_BaseStation\":\"\",\"DECT_Handset\":\"\",\"Device_Billing_System\":\"\",\"Device_Billing_System_Id\":\"\",\"Device_Model\":\"Analogue Device\",\"Device_Monthly_Amount\":\"\",\"Device_Name\":\"\",\"Device_Ownership\":\"Owned\",\"Device_Payment_Type\":\"\",\"Device_Plan_Start_Date\":\"\",\"Device_Plan_Term\":\"\",\"Device_Type\":\"BYO Analogue Device\",\"discount\":[{\"Discount_Monthly_Amount\":\"\",\"Discount_Name\":\"\",\"Discount_Percent_Amount\":\"\",\"Discount_Start_Date\":\"\",\"Discount_Term\":\"\"}],\"Error_Code\":\"\",\"Error_Description\":\"\",\"Legacy_Link\":\"\",\"Quantity\":\"\",\"SKU\":\"\"},\"relationshipType\":\"contains\"}],\"Technical_Association_Role\":\"\"}]}],\"siteName\":\"      BARKER 233-0  ST CASTLEMAINE VIC\"}],\"Source_System_Id\":\"Replicator\"}';
		String checkboxes = '["true","false"]';
        ReplicatorGetServiceDataObject obj=ReplicatorManager.getSelectedSite(checkboxes,lagacySites);  
        system.assert(obj != null);
    }
}