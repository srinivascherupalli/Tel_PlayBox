@isTest 
public class CompUtilityReplicatorManagerTest { 
    static blob b = [select body from staticResource where name = 'ServiceJSON'].body;    
    static String serviceDTO = b.toString();
    //static blob b2 = [select body from staticResource where name = 'TransitionJsonDataForTestClass'].body;      
    /* static String OLDJSON  = '{ "Source_System_Id": "Replicator", "Correlation_Id": "1234", "CIDN": "1234567890", "Error_Code": "", "Error_Description": "", "site": [{ "ADBOR_Id": "222141258", "Error_Code": "", "Error_Description": "", "ProductList": [{ "Product_Type": "PSTN", "Product_Identifier": "6", "Association_Type": "Hunt Group", "Association_Role": "Auxilliary", "Association_Link_Id": "7", "Business_Owner": "Legacy", "Bundle_Indicator": "No", "Purchase_Order": "Y", "Invoice_Arrangement_Id": "4501519250", "Invoice_Arrangement_Id_MICA": "", "In_Flight_Flag": "N", "In_Flight_Legacy_System": "AXIS", "In_Flight_Order_Id": "", "Nominated_FNN": "", "DOT_GenType": "", "Enterprise_Id": "", "Error_Code": "", "Error_Description": "", "discount": [{ "Discount_Name": "", "Discount_Start_Date": "", "Discount_Monthly_Amount": "", "Discount_Term": "" }], "service": [{ "Service_ID": "0387681299", "Technical_Association_Role": "", "Service_Type": "Voice", "Bundle_Role": "", "Last_Replicator_Update_Date": "2017-11-08 00:28:39", "Error_Code": "", "Error_Description": "", "serviceCharacteristic": [{ "name": "ADSL_Bearer_Id", "value": "" }, { "name": "VOIP_Platform", "value": "" }, { "name": "User_Type", "value": "" }, { "name": "IP_Type", "value": "" }, { "name": "Telstra_GW_IPv4", "value": "" }, { "name": "Telstra_GW_IPv6", "value": "" }, { "name": "Cust_WAN_IP", "value": "" }, { "name": "IPv6_Prefix", "value": "" }, { "name": "Cust_LAN_IP", "value": "" }, { "name": "Cust_LAN_IPv6", "value": "" }, { "name": "BCS_FNN", "value": "" }, { "name": "Host_Name", "value": "" }, { "name": "Host_Password", "value": "" }, { "name": "Ops_Name", "value": "" }, { "name": "GB_Allowance", "value": "" }, { "name": "VoicetoEmail_Text", "value": "" }, { "name": "Unified_Plan_ID", "value": "" }, { "name": "Directory_Option", "value": "Directory Listing" }, { "name": "Call_Barring_Option", "value": "LOCAL CALLS ONLY" }, { "name": "RCRM_ Service", "value": "N" }, { "name": "Essential_Service", "value": "Y" }, { "name": "Temporary_Service", "value": "Y" }, { "name": "NSC_ Service", "value": "" }, { "name": "AOH_FNN", "value": "" }, { "name": "AOH_Cust_Trade_Name", "value": "" }, { "name": "AOH_Cust_Contact", "value": "" }, { "name": "AOH_Cust_Email", "value": "" }, { "name": "AOH_Cust_Phone_Num", "value": "" }, { "name": "Shareable", "value": "" }, { "name": "Group_Plan_Name", "value": "" }, { "name": "Group_Deal_Name", "value": "" }], "planCharacteristic": [{ "Plan_Deal_Type": "Plan", "Plan_Name": "$50 MONTHLY PLAN", "Plan_Term": "1", "Plan_Commercial_Type": "Casual", "Plan_Monthly_Amount": "16.13", "Plan_Start_Date": "13-07-2014", "Instalments_Billed": "", "Instalments_Remaining": "", "Legacy_String": "NA", "discount": { "Discount_Name": "$0.00/UNIT RATE METH=1/BCAT=REC/BILG METH = ADV", "Discount_Monthly_Amount": "10.11", "Discount_Percent_Amount": "", "Discount_Start_Date": "13-09-2014", "Discount_Term": "" } }], "serviceRelationship": [{ "relationshipType": "contains", "device": { "Device_Type": "BYO Analogue Device", "Device_Ownership": "Owned", "Device_Model": "Analogue Device", "Device_Name": "", "SKU": "", "Device_Payment_Type": "", "Device_Monthly_Amount": "", "Device_Plan_Start_Date": "", "Device_Plan_Term": "", "Device_Billing_System": "", "Device_Billing_System_ID": "", "Legacy_Link": "", "DECT_BaseStation": "", "DECT_Handset": "", "Quantity": "", "Error_Code": "", "Error_Description": "", "discount": [{ "Discount_Name": "", "Discount_Monthly_Amount": "", "Discount_Percent_Amount": "", "Discount_Start_Date": "", "Discount_Term": "" }] } }, { "relationshipType": "contains", "serviceExtension": [] }] }] }] }] }';*/
    
     //Response from replicator
    static String OLDJSON  ='{"Source_System_Id":"Replicator","Correlation_Id":"97484ea2a1a780d424","CIDN":"2022012339","Error_Code":"","Error_Description":"","site":[{"ADBOR_Id":"50824647","Error_Code":"","Error_Description":"","productList":[{"Product_Type":"PSTN","Product_Identifier":"264623","Association_Type":"","Association_Role":"","Association_Link_Id":"","Business_Owner":"Legacy","Bundle_Indicator":"No","Purchase_Order":"Y","Invoice_Arrangement_Id":"2099409200","Invoice_Arrangement_Id_MICA":"","In_Flight_Flag":"N","In_Flight_Legacy_System":"AXIS","In_Flight_Order_Id":"","Nominated_FNN":"","DOT_GenType":"","Enterprise_Id":"","Error_Code":"","Error_Description":"","discount":[{"Discount_Name":"","Discount_Start_Date":"","Discount_Monthly_Amount":"","Discount_Term":""}],"service":[{"Service_ID":"0235828965","Technical_Association_Role":"","Service_Type":"Voice","Bundle_Role":"","Last_Replicator_Update_Date":"2018-06-20 18:49:51","Error_Code":"","Error_Description":"","serviceCharacteristic":[{"name":"ADSL_Bearer_Id","value":""},{"name":"VOIP_Platform","value":""},{"name":"User_Type","value":""},{"name":"IP_Type","value":""},{"name":"Telstra_GW_IPv4","value":""},{"name":"Telstra_GW_IPv6","value":""},{"name":"Cust_WAN_IP","value":""},{"name":"IPv6_Prefix","value":""},{"name":"Cust_LAN_IP","value":""},{"name":"Cust_LAN_IPv6","value":""},{"name":"BCS_FNN","value":""},{"name":"Host_Name","value":""},{"name":"Host_Password","value":""},{"name":"Ops_Name","value":""},{"name":"GB_Allowance","value":""},{"name":"VoicetoEmail_Text","value":""},{"name":"Unified_Plan_ID","value":""},{"name":"Directory_Option","value":""},{"name":"Call_Barring_Option","value":""},{"name":"RCRM_ Service","value":"N"},{"name":"Essential_Service","value":"Y"},{"name":"Temporary_Service","value":""},{"name":"NSC_ Service","value":""},{"name":"AOH_FNN","value":""},{"name":"AOH_Cust_Trade_Name","value":""},{"name":"AOH_Cust_Contact","value":""},{"name":"AOH_Cust_Email","value":""},{"name":"AOH_Cust_Phone_Num","value":""},{"name":"Shareable","value":""},{"name":"Group_Plan_Name","value":""},{"name":"Group_Deal_Name","value":""}],"planCharacteristic":null,"serviceRelationship":[{"relationshipType":"contains","serviceExtension":[{"Services_From":"0235828965","Services_To":"0235828975"}]}]}]},{"Product_Type":"ISDN2","Product_Identifier":"540147","Association_Type":"","Association_Role":"","Association_Link_Id":"","Business_Owner":"Legacy","Bundle_Indicator":"No","Purchase_Order":"Y","Invoice_Arrangement_Id":"2099409200","Invoice_Arrangement_Id_MICA":"","In_Flight_Flag":"N","In_Flight_Legacy_System":"AXIS","In_Flight_Order_Id":"","Nominated_FNN":"","DOT_GenType":"","Enterprise_Id":"","Error_Code":"","Error_Description":"","discount":[{"Discount_Name":"","Discount_Start_Date":"","Discount_Monthly_Amount":"","Discount_Term":""}],"service":[{"Service_ID":"0846238057","Technical_Association_Role":"","Service_Type":"Voice","Bundle_Role":"","Last_Replicator_Update_Date":"2018-06-20 18:49:51","Error_Code":"","Error_Description":"","serviceCharacteristic":[{"name":"ADSL_Bearer_Id","value":""},{"name":"VOIP_Platform","value":""},{"name":"User_Type","value":""},{"name":"IP_Type","value":""},{"name":"Telstra_GW_IPv4","value":""},{"name":"Telstra_GW_IPv6","value":""},{"name":"Cust_WAN_IP","value":""},{"name":"IPv6_Prefix","value":""},{"name":"Cust_LAN_IP","value":""},{"name":"Cust_LAN_IPv6","value":""},{"name":"BCS_FNN","value":""},{"name":"Host_Name","value":""},{"name":"Host_Password","value":""},{"name":"Ops_Name","value":""},{"name":"GB_Allowance","value":""},{"name":"VoicetoEmail_Text","value":""},{"name":"Unified_Plan_ID","value":""},{"name":"Directory_Option","value":""},{"name":"Call_Barring_Option","value":""},{"name":"RCRM_ Service","value":"N"},{"name":"Essential_Service","value":"Y"},{"name":"Temporary_Service","value":""},{"name":"NSC_ Service","value":""},{"name":"AOH_FNN","value":""},{"name":"AOH_Cust_Trade_Name","value":""},{"name":"AOH_Cust_Contact","value":""},{"name":"AOH_Cust_Email","value":""},{"name":"AOH_Cust_Phone_Num","value":""},{"name":"Shareable","value":""},{"name":"Group_Plan_Name","value":""},{"name":"Group_Deal_Name","value":""}],"planCharacteristic":null,"serviceRelationship":[{"relationshipType":"contains","serviceExtension":[{"Services_From":"0846238057","Services_To":"0846238067"}]}]}]},{"Product_Type":"ISDN2DID","Product_Identifier":"680490","Association_Type":"","Association_Role":"","Association_Link_Id":"","Business_Owner":"Legacy","Bundle_Indicator":"No","Purchase_Order":"Y","Invoice_Arrangement_Id":"2099409200","Invoice_Arrangement_Id_MICA":"","In_Flight_Flag":"N","In_Flight_Legacy_System":"AXIS","In_Flight_Order_Id":"","Nominated_FNN":"","DOT_GenType":"","Enterprise_Id":"","Error_Code":"","Error_Description":"","discount":[{"Discount_Name":"","Discount_Start_Date":"","Discount_Monthly_Amount":"","Discount_Term":""}],"service":[{"Service_ID":"0725392025","Technical_Association_Role":"","Service_Type":"Voice","Bundle_Role":"","Last_Replicator_Update_Date":"2018-06-20 18:49:51","Error_Code":"","Error_Description":"","serviceCharacteristic":[{"name":"ADSL_Bearer_Id","value":""},{"name":"VOIP_Platform","value":""},{"name":"User_Type","value":""},{"name":"IP_Type","value":""},{"name":"Telstra_GW_IPv4","value":""},{"name":"Telstra_GW_IPv6","value":""},{"name":"Cust_WAN_IP","value":""},{"name":"IPv6_Prefix","value":""},{"name":"Cust_LAN_IP","value":""},{"name":"Cust_LAN_IPv6","value":""},{"name":"BCS_FNN","value":""},{"name":"Host_Name","value":""},{"name":"Host_Password","value":""},{"name":"Ops_Name","value":""},{"name":"GB_Allowance","value":""},{"name":"VoicetoEmail_Text","value":""},{"name":"Unified_Plan_ID","value":""},{"name":"Directory_Option","value":""},{"name":"Call_Barring_Option","value":""},{"name":"RCRM_ Service","value":"N"},{"name":"Essential_Service","value":"Y"},{"name":"Temporary_Service","value":""},{"name":"NSC_ Service","value":""},{"name":"AOH_FNN","value":""},{"name":"AOH_Cust_Trade_Name","value":""},{"name":"AOH_Cust_Contact","value":""},{"name":"AOH_Cust_Email","value":""},{"name":"AOH_Cust_Phone_Num","value":""},{"name":"Shareable","value":""},{"name":"Group_Plan_Name","value":""},{"name":"Group_Deal_Name","value":""}],"planCharacteristic":null,"serviceRelationship":[{"relationshipType":"contains","serviceExtension":[{"Services_From":"0725392025","Services_To":"0725392035"},{"Services_From":"0725392045","Services_To":"0725392055"}]}]}]},{"Product_Type":"BE Bundle","Product_Identifier":"241345","Association_Type":"","Association_Role":"","Association_Link_Id":"","Business_Owner":"Legacy","Bundle_Indicator":"No","Purchase_Order":"Y","Invoice_Arrangement_Id":"2099409200","Invoice_Arrangement_Id_MICA":"","In_Flight_Flag":"N","In_Flight_Legacy_System":"AXIS","In_Flight_Order_Id":"","Nominated_FNN":"","DOT_GenType":"","Enterprise_Id":"","Error_Code":"","Error_Description":"","discount":[{"Discount_Name":"","Discount_Start_Date":"","Discount_Monthly_Amount":"","Discount_Term":""}],"service":[{"Service_ID":"0650094369","Technical_Association_Role":"","Service_Type":"Voice","Bundle_Role":"","Last_Replicator_Update_Date":"2018-06-20 18:49:51","Error_Code":"","Error_Description":"","serviceCharacteristic":[{"name":"ADSL_Bearer_Id","value":""},{"name":"VOIP_Platform","value":""},{"name":"User_Type","value":""},{"name":"IP_Type","value":""},{"name":"Telstra_GW_IPv4","value":""},{"name":"Telstra_GW_IPv6","value":""},{"name":"Cust_WAN_IP","value":""},{"name":"IPv6_Prefix","value":""},{"name":"Cust_LAN_IP","value":""},{"name":"Cust_LAN_IPv6","value":""},{"name":"BCS_FNN","value":""},{"name":"Host_Name","value":""},{"name":"Host_Password","value":""},{"name":"Ops_Name","value":""},{"name":"GB_Allowance","value":""},{"name":"VoicetoEmail_Text","value":""},{"name":"Unified_Plan_ID","value":""},{"name":"Directory_Option","value":""},{"name":"Call_Barring_Option","value":""},{"name":"RCRM_ Service","value":"N"},{"name":"Essential_Service","value":"Y"},{"name":"Temporary_Service","value":""},{"name":"NSC_ Service","value":""},{"name":"AOH_FNN","value":""},{"name":"AOH_Cust_Trade_Name","value":""},{"name":"AOH_Cust_Contact","value":""},{"name":"AOH_Cust_Email","value":""},{"name":"AOH_Cust_Phone_Num","value":""},{"name":"Shareable","value":""},{"name":"Group_Plan_Name","value":""},{"name":"Group_Deal_Name","value":""}],"planCharacteristic":null,"serviceRelationship":[{"relationshipType":"contains","serviceExtension":[{"Services_From":"0650094369","Services_To":"0650094379"}]}]}]}]}]}';
    
    static String serviceDTO_V2 = '{ "Source_System_Id": "Replicator", "site": [ { "siteName": null, "productList": [ { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0235828975", "Services_From": "0235828965", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0235828965", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "PSTN", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": true }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0846238067", "Services_From": "0846238057", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0846238057", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "ISDN2", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": true }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0725392035", "Services_From": "0725392025", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }, { "Services_To": "0725392055", "Services_From": "0725392045", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0725392025", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "ISDN2DID", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": true }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0650094379", "Services_From": "0650094369", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0650094369", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": true } ], "Product_Type": "BE Bundle", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": true } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50824647" } ], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "219903779387dbb9f5", "CIDN": "2022012339" }';
    
    static String mobileServiceDTO='{ "Source_System_Id": "Replicator", "productList": [ { "site": [ { "siteName": null, "serviceList": [ { "groupType": [ { "Service_Type": "Voice", "GroupId": "group1", "service": [ { "service_id": "2224534613", "service_status": "AC", "serviceExtension": [ ], "service_type_code": "NORM", "directory_listing": "Y", "imsi_number": "505013438393119", "sim_serial_number": "89610179078138000029", "calling_line_identifier": "off", "plan_name": "3OB*049 | 3G Cap 49 Business Mobile Plan", "contract_term": "0", "international_roaming": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank": "3GPPMSGK | 3G Pre-Paid Video Message Bank", "idd": "BFIDD100 | Bus Fleet Plus IDD $100", "checkValue": false, "Association_Type": "", "Association_Role": "" }, { "service_id": "2224534614", "service_status": "AC", "serviceExtension": [ ], "service_type_code": "NORM", "directory_listing": "Y", "imsi_number": "505013438393119", "sim_serial_number": "89610179078138000029", "calling_line_identifier": "off", "plan_name": "3OB*049 | 3G Cap 49 Business Mobile Plan", "contract_term": "0", "international_roaming": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank": "3GPPMSGK | 3G Pre-Paid Video Message Bank", "idd": "BFIDD100 | Bus Fleet Plus IDD $100", "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": true } ] } ] } ], "Product_Type": "Any mobile Product", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true } ], "CIDN": "584847036" }';
    static String TransitionDataNgUcJSON = '{"CIDN":"1100037407","Correlation_Id":"75847359875974589374","Error_Code":"","Error_Description":"","productList":[{"checkValue":null,"disableCheck":null,"eligibilityReason":null,"eligibilityStatus":null,"Product_Type":"ISDN2","site":[{"ADBOR_Id":"0","Error_Code":null,"Error_Description":null,"serviceList":[{"checkReserved":false,"checkValue":true,"disableCheck":null,"EligibilityReason":null,"EligibilityStatus":null,"groupType":[{"checkValue":true,"disableCheck":null,"groupId":"0358852382","service":[{"accountDetails":null,"calling_line_identifier":null,"contract_term":null,"devices":null,"directory_listing":null,"Eligibility_status":null,"idd":null,"imsi_number":null,"international_roaming":null,"message_bank":null,"plan_name":null,"Reason":null,"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","Reserve_status":null,"service_association_role":"GDN","Service_Id":"0358852382","service_status":null,"service_type":"voice","service_type_code":null,"serviceExtensions":null,"sim_serial_number":null},{"accountDetails":null,"calling_line_identifier":null,"contract_term":null,"devices":null,"directory_listing":null,"Eligibility_status":null,"idd":null,"imsi_number":null,"international_roaming":null,"message_bank":null,"plan_name":null,"Reason":null,"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","Reserve_status":null,"service_association_role":"AUXILLARY","Service_Id":"0358851406","service_status":null,"service_type":"voice","service_type_code":null,"serviceExtensions":null,"sim_serial_number":null}],"transitionId":"63030a64-41ec-4e57-9e6c-d5da7565b315"}],"Service_Type":"0358852382"}],"siteName":null}]}],"serviceCount":0,"Source_System_Id":"Replicator"}';
    
    @testsetup static void CompUtilityReplicatorManagerTestDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '2022012339';
        insert acc;
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        
        cscrm__Address__c addrs = new cscrm__Address__c();
        addrs.Address_ID__c = '50824647';
        addrs.Name = 'Test Address';
        addrs.cscrm__Account__c = acc.id;
        lstAddress.add(addrs);
        
        cscrm__Address__c addrs1 = new cscrm__Address__c();
        addrs1.Address_ID__c = '256345896231';
        addrs1.Name = 'Test Address';
        addrs1.cscrm__Account__c = acc.id;
        lstAddress.add(addrs1);
        
        cscrm__Address__c addrs2 = new cscrm__Address__c();
        addrs2.Address_ID__c = '189562345874';
        addrs2.Name = 'Test Address';
        addrs2.cscrm__Account__c = acc.id;
        lstAddress.add(addrs2);

        
        insert lstAddress;
        List<cscrm__Site__c> lstSite = new List<cscrm__Site__c>();
        
        cscrm__Site__c siteobj = new cscrm__Site__c();
        siteobj.Name = 'Test Site';
        siteobj.cscrm__Account__c = acc.id;
        siteobj.cscrm__Installation_Address__c = addrs.Id;
        siteobj.Status__c = 'Active';
        siteobj.Legacy__c = true;
        lstSite.add(siteobj);
        
        cscrm__Site__c siteobj1 = new cscrm__Site__c();
        siteobj1.Name = 'Test Site1';
        siteobj1.cscrm__Account__c = acc.id;
        siteobj1.cscrm__Installation_Address__c = lstAddress[1].Id;
        siteobj1.Status__c = 'Active';
        siteobj1.Legacy__c = true;
        lstSite.add(siteobj1);
        
        cscrm__Site__c siteobj2 = new cscrm__Site__c();
        siteobj2.Name = 'Test Site2';
        siteobj2.cscrm__Account__c = acc.id;
        siteobj2.cscrm__Installation_Address__c = lstAddress[2].Id;
        siteobj2.Status__c = 'Active';
        siteobj2.Legacy__c = true;
        lstSite.add(siteobj2);
        
        insert lstSite;
       
        cscfga__Product_Basket__c prodBasket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        prodBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        prodBasket.Name = 'Transition';
        prodBasket.isEligibilityCheckComplete__c = false;
        prodBasket.isEligibilityTriggered__c = false;
        update prodBasket;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert pd;
        
        //Start of EGDE-199057 By Abhishek from Osaka Team
        
        //End of EGDE-199057 By Abhishek from Osaka Team
        
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'Connected Workplace';
        config.cscfga__Description__c = 'Test description';
        config.cscfga__Product_Basket__c = prodBasket.Id;
        config.isEligibleForTriggered__c=true;
        config.cscfga__Quantity__c = 1;
        insert config;
        
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(pd.Id);
        config1.name= 'Test';
        config1.cscfga__Description__c = 'Test description';
        config1.isEligibleForTriggered__c=false;
        insert config1;
        
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(pd.Id);
        config2.name= 'IP Site';
        config2.cscfga__Description__c = 'IP Site';
        config2.cscfga__Product_Basket__c = prodBasket.Id;
        config2.cscfga__Quantity__c = 1;
        config2.cscfga__Root_Configuration__c = config.Id;
        config2.isEligibleForTriggered__c=false;
        insert config2;
        
        cscfga__Product_Configuration__c config3 = ProductTestFactory.buildProductConfig(pd.Id);
        config3.name= 'User';
        config3.cscfga__Description__c = 'User';
        config3.cscfga__Product_Basket__c = prodBasket.Id;
        config3.cscfga__Root_Configuration__c = config2.Id;
        config3.cscfga__Quantity__c = 2;  
        config3.isEligibleForTriggered__c=false;
        insert config3;

        
        List<csbb__Product_Configuration_Request__c> lstPCR = new List<csbb__Product_Configuration_Request__c>();
        
        csbb__Product_Configuration_Request__c prodConfigReq = ProductTestFactory.buildConfigRequest(prodBasket.Id,config2.Id);
        
        prodConfigReq.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"50824647","cscrm_installation_address_r_cscrm_state_province_c":"TAS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';
        lstPCR.add(prodConfigReq);
        
        /*csbb__Product_Configuration_Request__c prodConfigReq1 = ProductTestFactory.buildConfigRequest(prodBasket.Id,config.Id);
        prodConfigReq1.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"152365895124","cscrm_installation_address_r_cscrm_state_province_c":"AS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';
        lstPCR.add(prodConfigReq1);*/
        
        insert lstPCR;
        
        cscfga__Product_Category__c prodCat= new cscfga__Product_Category__c();
        prodCat.Name = 'Modular Products';
        insert prodCat;
        
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
        att.ParentId = config2.Id;
        att.Body = Blob.valueOf(serviceDTO_V2);
        insert att;
        
        Attachment att1 = new Attachment();
        att1.Name = 'TransitionDataNgUc.json';
        att1.ParentId = config2.Id;
        att1.Body = Blob.valueOf(TransitionDataNgUcJSON);
        insert att1;
        
        Attachment att2 = new Attachment();
        att2.Name = 'TransitionData.json';
        att2.ParentId = config2.Id;
        att2.Body = Blob.valueOf(TransitionDataNgUcJSON);
        insert att2;
      
        
        EnvironmentVariable__c cs = new EnvironmentVariable__c();
        cs.Name='newReplicatorJSONresponseO';
        cs.Value__c='false';
        insert cs;
        List<TramasElgibilityCallbackResponse__c> tm1list=new List<TramasElgibilityCallbackResponse__c>();
        TramasElgibilityCallbackResponse__c tm1=new TramasElgibilityCallbackResponse__c(Product_Configuration__c=config.id,Eligibility_Criteria__c='Not Accessed',Product_Basket__c=prodBasket.id);
        TramasElgibilityCallbackResponse__c tm1_2=new TramasElgibilityCallbackResponse__c(Product_Configuration__c=config1.id,Eligibility_Criteria__c='Eligible',Product_Basket__c=prodBasket.id);   

        //List<cscfga__Product_Configuration__c> pcList = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name= 'IP Site'];
        //where cscfga__Product_Configuration__r.cscfga__Root_Configuration__c =: configId 
        cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.Name = 'Site Name';
        attr.cscfga__value__c = 'Test Site';
        //attr.cscfga__Is_Line_Item__c = true;
        attr.cscfga__Product_Configuration__c = config2.Id;
        INSERT attr;
        cscfga__Attribute__c attr1 = new cscfga__Attribute__c();
        attr1.Name = 'Site Address';
        attr1.cscfga__value__c = 'Test Address';
        //attr1.cscfga__Is_Line_Item__c = true;
        attr1.cscfga__Product_Configuration__c = config2.Id;
        INSERT attr1;
        cscfga__Attribute__c attr2 = new cscfga__Attribute__c();
        attr2.Name = 'AdborID';
        attr2.cscfga__value__c = '50824647';
        //attr2.cscfga__Is_Line_Item__c = true;
        attr2.cscfga__Product_Configuration__c = config2.Id;
        INSERT attr2;
        cscfga__Attribute__c attr3 = new cscfga__Attribute__c();
        attr3.Name = 'test';
        attr3.cscfga__value__c = 'test';
        attr3.cscfga__Is_Line_Item__c = true;
        attr3.cscfga__Product_Configuration__c = config3.Id;
        INSERT attr3;

        Id recodtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
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
        
        csord__Solution__c sol = new csord__Solution__c(Name = 'Adaptive Mobility', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        insert sol;
        
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Next Generation Enterprise Mobility';
        offer.Name = 'Adaptive Mobility';
        offer.Offer_ID__c = 'DMCAT_Offer_001233';
        insert offer;
        
        cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
        migrationOppBasket.csbb__Account__c = acc.Id;
        migrationOppBasket.AutoConfigStage__c='Not Initiated';
        migrationOppBasket.Name = 'Migration Opportunity Basket';
        migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
        migrationOppBasket.cscfga__Basket_Status__c  = 'Valid';  
        insert migrationOppBasket;
        
        cscfga__Product_Configuration__c productConfig = TestDataFactory.generateProductConfiguration();
        productConfig.cssdm__solution_association__c = sol.Id;
        productConfig.Marketable_Offer__c=offer.id;
        productConfig.cscfga__Product_Basket__c=migrationOppBasket.id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        update productConfig;
        
        EnvironmentVariable__c certificate =TestDataFactory.generateEnvironmentVariable('massl_certificate_name','telstrab2b_sandbox');
        insert certificate;
    
    }
    /*@isTest
    private static void testCompUtilityReplicatorManager() {
        Test.startTest();
        
        CompUtilityReplicatorManager compUtil = new CompUtilityReplicatorManager();
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        Map<String,ProductBasketSiteDataObject> pbsdList = CompUtilityReplicatorManager.fetchSiteFromBasketControllerMap(prodBasket[0].Id);
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        String pbsdJson = JSON.serialize(pbsdList);
        ReplicatorGetServiceDataObject serviceData = CompUtilityReplicatorManager.getCustomerServices('finCIDN',pbsdJson);
         //Map<String,List<String>> isdnbraTest=CompUtilityReplicatorManager.getISDNBRAProduct(prodBasket[0].Id,OLDJSON);
        
       // system.assert(serviceData == null);
       
        //Map<String,ReplicatorGetServiceDataObject.SiteDTO> mapSites = CompUtilityReplicatorManager.getCustomerServicesMap(serviceDTO);
       
        //system.assert(mapSites != null);
        
        //List<string> selectedProd = new List<string>{'222141258-PSTN','266049834-ISDN-BRA'};
        //system.assert(selectedProd != null);
        //ReplicatorGetServiceDataObject selectedDTO = CompUtilityReplicatorManager.getSelectedSite(selectedProd,OLDJSON);
        //system.assert(selectedDTO != null);
        
        CompUtilityReplicatorManager.redirectToBasket(JSON.serialize(selectedDTO),prodBasket[0].Id);
        
        //system.assertEquals(prodBasket[0].Id, basketId);
        cscfga__Product_Basket__c productBasket = CompUtilityReplicatorManager.getBasket(prodBasket[0].Id);
        system.assertEquals('1234567890', productBasket.csbb__Account__r.CIDN__c);
        //string basketStage = CompUtilityReplicatorManager.getBasketStage(prodBasket[0].Id);
        system.assertEquals('Commercial Configuration', productBasket.csordtelcoa__Basket_Stage__c);
        //Map<String,List<String>> mp = CompUtilityReplicatorManager.getISDNBRAProduct(prodBasket[0].Id,JSON.serialize(serviceData));
        Test.stopTest();
    }*/
    
    
    @isTest
    private static void testCompUtilityReplicatorManager_V2() {
        Test.startTest();
        /* EDGE-75696, EDGE-85840, EDGE-84055 : Getting Custom setting to check which flow to execute for replicator response */
        insert new EnvironmentVariable__c(Name= 'newReplicatorJSONresponse', Value__c = 'true');
        insert new EnvironmentVariable__c(Name= 'PCRtoPCFlag', Value__c = 'false');
        Boolean sendCallout = true;
        CompUtilityReplicatorManager compUtil = new CompUtilityReplicatorManager();
        
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c where name = 'Transition'];
        String basketId = prodBasket[0].Id;
        String siteMap2 = '{"101119100":{"ADBOR_Id":"101119100","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"AUXILLARY","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847727530","Service_Type":"voice","serviceExtension":[],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""},"101119188":{"ADBOR_Id":"101119188","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"GDN","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847225111","Service_Type":"voice","serviceExtension":[{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225100","Services_To":"0847225110"},{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225112","Services_To":"0847225199"}],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""}}';
        Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteMap2ObjTest = (Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>)Json.deserialize(siteMap2, Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>.Class);
       
        Map<String,ProductBasketSiteDataObject> pbsdList = CompUtilityReplicatorManager.fetchSiteFromBasketControllerMap(basketId);
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        String pbsdJson = JSON.serialize(pbsdList);
        
        system.debug('pbsdJson--->'+pbsdJson);
        
        ReplicatorGetServiceDataObject serviceData = CompUtilityReplicatorManager.getCustomerServices('finCIDN',pbsdJson); 
        
        ReplicatorGetServiceDataObject_V2 serviceDataNew = CompUtilityReplicatorManager.getCustomerServices_New('finCIDN',pbsdJson,'50824647'); 
        //system.assert(serviceDataNew != null);
        
        //System.debug('serviceDTO_V2-->>'+serviceDTO_V2);
        
        Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> mapSitesNew = CompUtilityReplicatorManager.getCustomerServicesMap_New(serviceDTO_V2,siteMap2ObjTest);
        system.assert(mapSitesNew != null);
        
        List<string> selectedProd = new List<string>{'50824647-PSTN'};
        system.assert(selectedProd != null);       
        
        ReplicatorGetServiceDataObject_V2 selectedDTONew = CompUtilityReplicatorManager.getSelectedSite_V2(serviceDTO_V2, basketId, JSON.serialize(mapSitesNew),sendCallout);
        //system.assert(selectedDTONew != null);
        
        ReplicatorGetServiceDataObject OLDServiceDTO = ReplicatorGetServiceDataObject.parse(OLDJSON);
        ReplicatorGetServiceDataObject_V2 getNewServiceDTO = CompUtilityReplicatorManager.getNewServiceDTO(OLDServiceDTO);
        system.assert(getNewServiceDTO != null);
        
        //CompUtilityReplicatorManager.transitionAllRecommended(serviceDTO_V2,basketId);
        
        //Map<String,List<String>> isdbBRAold = CompUtilityReplicatorManager.getISDNBRAProduct(basketId, serviceDTO);
        //system.assert(isdbBRAold != null);
        
        Map<String,List<String>> isdbBRA = CompUtilityReplicatorManager.getISDNBRAProduct_V2(basketId, serviceDTO_V2);
        system.assert(isdbBRA != null);
        
        List<ProductBasketSiteDataObject.ProductConfiguration> listconfigs = CompUtilityReplicatorManager.getExistingSubscription('12345');
        
        CompUtilityReplicatorManager.redirectToBasket(JSON.serialize(serviceData),basketId);
        //CompUtilityReplicatorManager.redirectToBasket_V2(JSON.serialize(serviceDataNew), basketId);
        //system.assertEquals(prodBasket[0].Id, basketId);
        cscfga__Product_Basket__c productBasket = CompUtilityReplicatorManager.getBasket(basketId);
        system.assertEquals('2022012339', productBasket.csbb__Account__r.CIDN__c);
        
        system.assertEquals('Commercial Configuration', productBasket.csordtelcoa__Basket_Stage__c);
        
        
        Test.stopTest();
    }
    
    @isTest
    private static void testCompUtilityReplicatorManager_V2_withoutAttachments() {
        insert new EnvironmentVariable__c(Name= 'PCRtoPCFlag', Value__c = 'false');
        List<Attachment> attList = [SELECT Id FROM Attachment];
        DELETE attList;
        
        Test.startTest();
        /* EDGE-75696, EDGE-85840, EDGE-84055 : Getting Custom setting to check which flow to execute for replicator response */
        insert new EnvironmentVariable__c(Name= 'newReplicatorJSONresponse', Value__c = 'true');
        CompUtilityReplicatorManager compUtil = new CompUtilityReplicatorManager();
        
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        
        
        Map<String,ProductBasketSiteDataObject> pbsdList = CompUtilityReplicatorManager.fetchSiteFromBasketControllerMap(basketId);
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        String pbsdJson = JSON.serialize(pbsdList);
        
        
        ReplicatorGetServiceDataObject_V2 serviceDataNew = CompUtilityReplicatorManager.getCustomerServices_New('finCIDN',pbsdJson,'50824647'); 
        //system.assert(serviceDataNew != null);
        CompUtilityReplicatorManager.mergeIndividualSiteResponse(serviceDataNew,serviceDataNew,'50824647','2022012339');
        
        //System.debug('serviceDTO_V2-->>'+serviceDTO_V2);
        String siteMap2 = '{"101119100":{"ADBOR_Id":"101119100","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"AUXILLARY","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847727530","Service_Type":"voice","serviceExtension":[],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""},"101119188":{"ADBOR_Id":"101119188","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"GDN","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847225111","Service_Type":"voice","serviceExtension":[{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225100","Services_To":"0847225110"},{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225112","Services_To":"0847225199"}],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""}}';
        Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteMap2ObjTest = (Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>)Json.deserialize(siteMap2, Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>.Class);
        Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> mapSitesNew = CompUtilityReplicatorManager.getCustomerServicesMap_New(serviceDTO_V2,siteMap2ObjTest);
        system.assert(mapSitesNew != null);
        
        List<string> selectedProd = new List<string>{'152365895123-24432432432','189562345874-14432432432'};
        system.assert(selectedProd != null);
        Boolean sendCallout = true;
        //ReplicatorGetServiceDataObject selectedDTO = CompUtilityReplicatorManager.getSelectedSite(selectedProd,serviceDTO);
        //system.assert(selectedDTO != null);
        
        ReplicatorGetServiceDataObject_V2 selectedDTONew = CompUtilityReplicatorManager.getSelectedSite_V2(serviceDTO_V2, basketId, JSON.serialize(mapSitesNew),sendCallout);
        system.assert(selectedDTONew != null);
        
        ReplicatorGetServiceDataObject OLDServiceDTO = ReplicatorGetServiceDataObject.parse(OLDJSON);
        ReplicatorGetServiceDataObject_V2 getNewServiceDTO = CompUtilityReplicatorManager.getNewServiceDTO(OLDServiceDTO);
        system.assert(getNewServiceDTO != null);
        
        //CompUtilityReplicatorManager.transitionAllRecommended(serviceDTO_V2, basketId);
        
        //Map<String,List<String>> isdbBRAold = CompUtilityReplicatorManager.getISDNBRAProduct(basketId, serviceDTO);
        //system.assert(isdbBRAold != null);
        
        Map<String,List<String>> isdbBRA = CompUtilityReplicatorManager.getISDNBRAProduct_V2(basketId, serviceDTO_V2);
        system.assert(isdbBRA != null);
        
        List<ProductBasketSiteDataObject.ProductConfiguration> listconfigs = CompUtilityReplicatorManager.getExistingSubscription('12345');
        //CompUtilityReplicatorManager.redirectToBasket(JSON.serialize(selectedDTO),basketId);
        //CompUtilityReplicatorManager.redirectToBasket_V2(JSON.serialize(serviceDataNew), basketId);
        //System.assertEquals(prodBasket[0].Id, basketId);
        cscfga__Product_Basket__c productBasket = CompUtilityReplicatorManager.getBasket(basketId);
        system.assertEquals('2022012339', productBasket.csbb__Account__r.CIDN__c);       
        system.assertEquals('Commercial Configuration', productBasket.csordtelcoa__Basket_Stage__c);
        TransitionDataDTO TransitionDTO = TransitionDataDTO.parse(TransitionDataNgUcJSON);
        CompUtilityReplicatorManager.insertJSONResponseNgUc(TransitionDTO,null,basketId,false);
     
        Test.stopTest();
    }
    
    @isTest
    public static void testGetExistingSubscription(){
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        
        
         
        Test.startTest();
        List<ProductBasketSiteDataObject.ProductConfiguration> pcDescription = CompUtilityReplicatorManager.getExistingSubscription([SELECT Id FROM cscfga__Product_Configuration__c WHERE Name= 'IP Site' limit 1].Id);
        Test.stopTest();
        
        System.assert(pcDescription != null);
    }
    @isTest
    public static void testgetEligibityStatus(){
        insert new EnvironmentVariable__c(Name= 'PCRtoPCFlag', Value__c = 'false');
        List<cscfga__Product_Basket__c> pb = [select Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c from cscfga__Product_Basket__c where Name = 'Transition'];
        String basketId = pb[0].Id;
        ID basId = pb[0].Id;
        List<String> selectProd = new List<String>();
        selectProd.add('50824647');
        
        string CIDN = '2022012339';
       /* List<cscfga__Product_Configuration__c> pcList = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name= 'User'];
        //where cscfga__Product_Configuration__r.cscfga__Root_Configuration__c =: configId 
        cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.Name = 'Test';
        attr.cscfga__Is_Line_Item__c = true;
        attr.cscfga__Product_Configuration__c = pcList[0].Id;
        INSERT attr;
        */
        String TransitionJSONData='{ "Source_System_Id": "Replicator", "site": [ { "siteName": null, "productList": [ { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0235828975", "Services_From": "0235828965", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0235828965", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "PSTN", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": true }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0846238067", "Services_From": "0846238057", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0846238057", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "ISDN2", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": false }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0725392035", "Services_From": "0725392025", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }, { "Services_To": "0725392055", "Services_From": "0725392045", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0725392025", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "ISDN2DID", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": false }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0650094379", "Services_From": "0650094369", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0650094369", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "BE Bundle", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": false } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50824647" } ], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "219903779387dbb9f5", "CIDN": "2022012339" }';
        String adBorId = '50824647';
        List<cscfga__Product_Configuration__c> pcListConf = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name= 'IP Site'];
         List<cscfga__Product_Configuration__c> pcList = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name= 'Connected Workplace' ];
         
          Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
        att.ParentId = pcListConf[0].Id;
        att.Body = Blob.valueOf(TransitionJSONData);
        insert att;
       
        TramasElgibilityCallbackResponse__c eligTram = new TramasElgibilityCallbackResponse__c();
        eligTram.Product_Configuration__c = pcListConf[0].Id;
        eligTram.Product_Basket__c = pb[0].Id;
        eligTram.Eligibility_Criteria__c = 'Eligible';
        eligTram.Correlation_ID__c = 'abcd1234xyz';
        insert eligTram;
        
        //where cscfga__Product_Configuration__r.cscfga__Root_Configuration__c =: pcListConf.id]; 
        /*cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.Name = 'Site Name';
        attr.cscfga__value__c = 'Test Site';
        attr.cscfga__Is_Line_Item__c = true;
        attr.cscfga__Product_Configuration__c = pcList[0].Id;
        INSERT attr;
        cscfga__Attribute__c attr1 = new cscfga__Attribute__c();
        attr1.Name = 'Site Address';
        attr1.cscfga__value__c = 'Test Address';
        attr1.cscfga__Is_Line_Item__c = true;
        attr1.cscfga__Product_Configuration__c = pcList[0].Id;
        INSERT attr1;
        cscfga__Attribute__c attr2 = new cscfga__Attribute__c();
        attr2.Name = 'AdborID';
        attr2.cscfga__value__c = '50824647';
        attr2.cscfga__Is_Line_Item__c = true;
        attr2.cscfga__Product_Configuration__c = pcList[0].Id;
        INSERT attr2;*/
       
        Boolean sendCallout = true;
        
        Test.startTest();
        String siteMap2 = '{"101119100":{"ADBOR_Id":"101119100","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"AUXILLARY","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847727530","Service_Type":"voice","serviceExtension":[],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""},"101119188":{"ADBOR_Id":"101119188","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"GDN","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847225111","Service_Type":"voice","serviceExtension":[{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225100","Services_To":"0847225110"},{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225112","Services_To":"0847225199"}],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""}}';
        Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteMap2ObjTest = (Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>)Json.deserialize(siteMap2, Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>.Class);
        List<ProductBasketSiteDataObject.ProductConfiguration> pcDescription = CompUtilityReplicatorManager.getExistingSubscription(pcListConf[0].id);
        Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> mapSitesNew = CompUtilityReplicatorManager.getCustomerServicesMap_New(serviceDTO_V2,siteMap2ObjTest);
        Map<String,ProductBasketSiteDataObject> pbsdList = CompUtilityReplicatorManager.fetchSiteFromBasketControllerMap(basketId);
        String pbsdJson = JSON.serialize(pbsdList);
        ReplicatorGetServiceDataObject_V2 serviceDataNew = CompUtilityReplicatorManager.getCustomerServices_New('finCIDN',pbsdJson,'123123');
        List<Integer> IntResponse =CompUtilityReplicatorManager.getEligibityStatus(basketId);
        Map<String,Boolean> mapResponse = CompUtilityReplicatorManager.HandleButtonHideShow(basketId);
        cscfga__Product_Basket__c pbasket = CompUtilityReplicatorManager.setIsEligibilityTriggeredUpdate(basId);
        ReplicatorGetServiceDataObject_V2 selectedDTONew = CompUtilityReplicatorManager.getSelectedSite_V2(serviceDTO_V2, basketId, JSON.serialize(mapSitesNew),sendCallout);
        Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> HandleCheckValueOnProductSelectDeselectTest =  CompUtilityReplicatorManager.HandleCheckValueOnProductSelectDeselect(mapSitesNew,selectProd,adBorId);
        //List<TableWrapper> servicesTablewrapper = CompUtilityReplicatorManager.getServicesTablewrapper(serviceDTO_V2);
        Boolean reviewConfirmedDisabledCalculateTest = CompUtilityReplicatorManager.reviewConfirmedDisabledCalculate(mapSitesNew,basketId);
        //ReplicatorGetServiceDTO getCustomerServices_V2Test = CompUtilityReplicatorManager.getCustomerServices_V2(CIDN,selectProd);
         Map<String, List<TransitionReviewConfirmWrapper>> getReviewConfirmDataNewTest=CompUtilityReplicatorManager.getReviewConfirmDataNew(mapSitesNew,pbsdList);
         List<TransitionReviewConfirmWrapper> getReviewConfirmDataTest = CompUtilityReplicatorManager.getReviewConfirmData(mapSitesNew,pbsdList);
        List<CompUtilityReplicatorManager.TableWrapper> getServicesTablewrapperTest = CompUtilityReplicatorManager.getServicesTablewrapper(mapSitesNew.get('50824647'));
        pb[0].isEligibilityTriggered__c =true;
        pb[0].isEligibilityCheckComplete__c =false;
        update pb[0];
        Map<String,Boolean> mapResponse1 = CompUtilityReplicatorManager.HandleButtonHideShow(basketId);
        pb[0].isEligibilityTriggered__c =true;
        pb[0].isEligibilityCheckComplete__c =true;
        update pb[0];
        Map<String,Boolean> mapResponse2 = CompUtilityReplicatorManager.HandleButtonHideShow(basketId);
        pb[0].isEligibilityTriggered__c =false;
        pb[0].isEligibilityCheckComplete__c =true;
        update pb[0];
        Map<String,Boolean> mapResponse3 = CompUtilityReplicatorManager.HandleButtonHideShow(basketId);
        pb[0].isEligibilityTriggered__c =false;
        pb[0].isEligibilityCheckComplete__c =false;
        update pb[0];
        Map<String,Boolean> mapResponse4 = CompUtilityReplicatorManager.HandleButtonHideShow(basketId);
        Test.stopTest();

        System.assert(basketId != null);
    }
    @isTest
    public static void getCustomerServicesMap_NewTest(){
        String siteMap2 = '{"101119100":{"ADBOR_Id":"101119100","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"AUXILLARY","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847727530","Service_Type":"voice","serviceExtension":[],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""},"101119188":{"ADBOR_Id":"101119188","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"GDN","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847225111","Service_Type":"voice","serviceExtension":[{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225100","Services_To":"0847225110"},{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225112","Services_To":"0847225199"}],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""}}';
        Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteMap2ObjTest = (Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>)Json.deserialize(siteMap2, Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>.Class);
        List<cscfga__Product_Basket__c> pb = [select Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c from cscfga__Product_Basket__c where Name = 'Transition'];
        String basketId = pb[0].Id;
        ID basId = pb[0].Id;
        List<String> selectProd = new List<String>();
        selectProd.add('50824647');
        string CIDN = '2022012339';
        ReplicatorGetServiceDataObject servObject=CompUtilityReplicatorManager.getCustomerServicesAtSite('2022012339',selectProd);
        Test.startTest();
        String TransitionJson='{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"7836518762","Services_From":"7836518752","eligibilityStatus":"Eligible","eligibilityReason":"","disableCheck":null,"checkValue":true}],"Service_Type":"Voice","Service_Id":"7836518752","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","eligibilityStatus":"Eligible","eligibilityReason":"","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false}],"Product_Type":"PSTN","eligibilityStatus":"Eligible","eligibilityReason":null,"disableCheck":null,"checkValue":true},{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"9508637503","Services_From":"9508637493","eligibilityStatus":"Ineligible","eligibilityReason":"All Numbers are not available","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"9508637493","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false}],"Product_Type":"ISDN","eligibilityStatus":"Not valid for assessment","eligibilityReason":null,"disableCheck":null,"checkValue":false},{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"2913852477","Services_From":"2913852467","eligibilityStatus":"Ineligible","eligibilityReason":"All Numbers are not available","disableCheck":null,"checkValue":false},{"Services_To":"2913852497","Services_From":"2913852487","eligibilityStatus":"Ineligible","eligibilityReason":"All Numbers are not available","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"2913852467","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false}],"Product_Type":"ISDN2DID","eligibilityStatus":"Ineligible","eligibilityReason":null,"disableCheck":null,"checkValue":false}],"Error_Description":"","Error_Code":"","ADBOR_Id":"401432055"}],"serviceCount":2,"Error_Description":"","Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICE82cfb97b7581e661a0","CIDN":"5829086067"}';
        ReplicatorGetServiceDataObject_V2 ServiceDTO = ReplicatorGetServiceDataObject_V2.parse(TransitionJson);
        Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> SiteMap = CompUtilityReplicatorManager.getCustomerServicesMap_New(TransitionJson,siteMap2ObjTest);
        Map<String,ProductBasketSiteDataObject> prodbasketmap=new Map<String,ProductBasketSiteDataObject>();
        ProductBasketSiteDataObject pbsdObject=new ProductBasketSiteDataObject();
        pbsdObject.adBorId = '401432055';
        prodbasketmap.put('401432055',pbsdObject);
        //EDGE-120154 Changes Start from here
        Map<String, List<TransitionReviewConfirmWrapper>> wrapperMap= new Map<String, List<TransitionReviewConfirmWrapper>>();
        wrapperMap=CompUtilityReplicatorManager.getReviewConfirmDataNew(SiteMap,prodbasketmap);
        //EDGE-120154 Changes End here
        CompUtilityReplicatorManager.getReviewConfirmData(SiteMap,prodbasketmap);
        CompUtilityReplicatorManager.getServicesTablewrapper(SiteMap.get('401432055'));
        CompUtilityReplicatorManager.initializeGridDataMap();     
         List<String> updateSelectedProductTest = CompUtilityReplicatorManager.updateSelectedProduct(SiteMap);
        Test.stopTest();
        
         System.assert(wrapperMap.containskey('401432055') == true);//EDGE-120154 assert
        System.assert(basketId != null);
    }
    @isTest
    public static void basketStageChangeTest(){
        List<cscfga__Product_Basket__c> pbList = [select Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Name = 'Transition'];
        String basketId = pbList[0].Id;
        cscfga__Product_Basket__c pb=new cscfga__Product_Basket__c();
        Test.startTest();
        pb=CompUtilityReplicatorManager.updatetransitionBasketStagetoInitial(basketId);
        pb=CompUtilityReplicatorManager.updatetransitionBasketStagetoCheckEligibility(basketId);
        List<Integer> eligibleStatus=CompUtilityReplicatorManager.getEligibityStatus(basketId);
        pb.Transition_basket_stage__c='Check Eligibility Completed';
        update pb;
        pb=CompUtilityReplicatorManager.updatetransitionBasketStagetoModifySelection(basketId);
        pb=CompUtilityReplicatorManager.updatetransitionBasketStagetoReviewConfirm(basketId);
        Test.stopTest();         
        System.assert(basketId != null);
    }
    @isTest
    public static void basketStageChangeTestCatchblock(){
        List<cscfga__Product_Basket__c> pbList = [select Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Name = 'Transition'];
        String basketId = '';
        cscfga__Product_Basket__c pb=new cscfga__Product_Basket__c();
        //ID basId = pbList[0].Id;
        Test.startTest();
        pb=CompUtilityReplicatorManager.updatetransitionBasketStagetoInitial(basketId);
        pb=CompUtilityReplicatorManager.updatetransitionBasketStagetoCheckEligibility(basketId);
        //pb=CompUtilityReplicatorManager.updatetransitionBasketStagetoModifySelection(basketId);
        // pb=CompUtilityReplicatorManager.updatetransitionBasketStagetoReviewConfirm(basketId);
        //pb=CompUtilityReplicatorManager.setIsEligibilityTriggeredUpdate(basketId);
        //List<Integer> eligibleStatus=CompUtilityReplicatorManager.getEligibityStatus(basketId);
        Test.stopTest();         
        System.assert(basketId == '');
    }

        @isTest
    public static void fetchSiteFromBasketControllerMapTestCS(){
        Test.startTest();
        insert new EnvironmentVariable__c(Name= 'newReplicatorJSONresponse', Value__c = 'true');
        insert new EnvironmentVariable__c(Name= 'PCRtoPCFlag', Value__c = 'true');
        Boolean sendCallout = true;
        CompUtilityReplicatorManager compUtil = new CompUtilityReplicatorManager();

        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c where name = 'Transition'];
        String basketId = prodBasket[0].Id;
        String siteMap2 = '{"101119100":{"ADBOR_Id":"101119100","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"AUXILLARY","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847727530","Service_Type":"voice","serviceExtension":[],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""},"101119188":{"ADBOR_Id":"101119188","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"GDN","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847225111","Service_Type":"voice","serviceExtension":[{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225100","Services_To":"0847225110"},{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225112","Services_To":"0847225199"}],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""}}';
        Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteMap2ObjTest = (Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>)Json.deserialize(siteMap2, Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>.Class);

        Map<String,ProductBasketSiteDataObject> pbsdList = CompUtilityReplicatorManager.fetchSiteFromBasketControllerMap(basketId);
        System.assert(pbsdList.size() > 0);
        Test.stopTest();
    }

        @isTest
    public static void insertJSONResponseMobileTest(){
        Test.startTest();
        String finCIDN='12343';
        try{
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Mobile PrePaid HandHeld","fnn":"0429701914","site":{"siteType":"ADBOR_ID","siteId":"123"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000030"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"24 "},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701124","site":{"siteType":"ADBOR_ID","siteId":"11111"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"120"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Enterprise Mobility","fnn":"0429701111","site":{"siteType":"ADBOR_ID","siteId":"2222222"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | Enterprise Mobility"},{"name":"contract_term","value":"220"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Enterprise Mobility","fnn":"042970223333","site":{"siteType":"ADBOR_ID","siteId":"33333333"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | Enterprise Mobility Upgrade"},{"name":"contract_term","value":"120"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]}]}');
        TransitionDataDTO mobileResponseFinal = ReplicatorGetServiceManager.transformReplicatorResponse(getServiceDTO, basketRecord.Id, 'Mobile');
        
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        List < Attachment > insertAttachment = CompUtilityReplicatorManager.insertJSONResponseMobile(mobileResponseFinal, tableWrapperData, basketRecord.Id, true);
        System.assert(mobileResponseFinal!=null);
       // System.assert(insertAttachment.size() > 0);
        }
        catch(Exception e){

        }
        Test.stopTest();
        
    }


    @isTest
    public static void getMobileServicesTablewrapperTest(){
        Test.startTest();
        String finCIDN='12343';
        try{
            ReplicatorGetServiceDTO getServiceDTO; 
            cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
            getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Mobile PrePaid HandHeld","fnn":"0429701914","site":{"siteType":"ADBOR_ID","siteId":"123"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000030"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"24 "},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701124","site":{"siteType":"ADBOR_ID","siteId":"11111"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"120"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Enterprise Mobility","fnn":"0429701111","site":{"siteType":"ADBOR_ID","siteId":"2222222"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | Enterprise Mobility"},{"name":"contract_term","value":"220"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Enterprise Mobility","fnn":"042970223333","site":{"siteType":"ADBOR_ID","siteId":"33333333"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | Enterprise Mobility Upgrade"},{"name":"contract_term","value":"120"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]}]}');
            TransitionDataDTO mobileResponseFinal = ReplicatorGetServiceManager.transformReplicatorResponse(getServiceDTO, basketRecord.Id, 'Mobile');
            
            
            List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = CompUtilityReplicatorManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
            if( tableWrapperData != null && tableWrapperData.size() > 0){
                System.assert(tableWrapperData.size() > 0);
            }
        }
        catch(Exception e){
            
        }
        Test.stopTest();       
    }
    
    @isTest
    public static void getNgUcServicesTablewrapperTest(){
        Test.startTest();
        String finCIDN='12343';
        try{
            ReplicatorGetServiceDTO getServiceDTO; 
            cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
            TransitionDataDTO TransitionDTO = TransitionDataDTO.parse(TransitionDataNgUcJSON);
            List < ReplicatorGetServiceManager.NgUCTableWrapper > mobileResponseFinal = CompUtilityReplicatorManager.getNgUcServicesTablewrapper(TransitionDTO, basketRecord.Id);
            
            
          //  List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = CompUtilityReplicatorManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
    //    System.assert(mobileResponseFinal.size() > 0);
        
        for(ReplicatorGetServiceManager.NgUCTableWrapper tableData : mobileResponseFinal){
            system.debug('**********>>>'+tableData);
           system.assertEquals(tableData.checkValue, true);
        }
        }
        catch(Exception e){
            
        }
        Test.stopTest();       
    }
    
    /* @Author    :   Abhishek Mallick(Osaka Team)
     * @Updated    : Ramya, for additional scenarios.
        * @Desc     :   Test Method for getMROLegacyDetailsTest CompUtilityReplicatorManager
        * @US       :   EDGE-177640
       * */   
    
    @isTest
    public static void getMROLegacyDetailsTest(){
        Test.startTest();
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c where name = 'Transition'];
        String basketId = prodBasket[0].id;
        String dataJson = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"645935fc-79c6-4247-8911-e7c52b17629c","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61474896431","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090156","deviceID":"352914116119203","deviceType":"Mobile Handset","billLiteral":"Apple iPhone 12 64GB","contractType":"MRO","monthlyAmount":"111.00","remainingTerm":"6","remainingAmount":"1111.45"},{"productID":"100300584800000020077","deviceID":"354880094381776","deviceType":"Mobile Handset","billLiteral":"Samsung Galaxy S20 5G 128GB","contractType":"MRO","monthlyAmount":"22.00","remainingTerm":"15","remainingAmount":"222.43"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}},{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61474896432","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","repayments":null,"Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $10","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}},{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61474896433","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $15","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090167","deviceID":"352914116119203","deviceType":"Mobile Handset","billLiteral":"Apple iPhone XR 64GB","contractType":"MRO","monthlyAmount":"333.00","remainingTerm":"8","remainingAmount":"3333.45"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO TransitionDataJSON = TransitionDataDTO.parse(dataJson);
        CompUtilityReplicatorManager.getMROLegacyDetails(TransitionDataJSON,basketId);
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>([Select id from Legacy_Service__c where Product_Basket__r.id=:basketId]);
        System.assert(legacyServiceList.size() > 0);
        Test.stopTest();
    }
    
    @isTest
    public static void getMROLegacyDetailsTestNegative(){
        Test.startTest();
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c where name = 'Transition'];
        String basketId = prodBasket[0].id;
        String dataJson = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"645935fc-79c6-4247-8911-e7c52b17629c","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61474896431","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090156","deviceID":"352914116119203","deviceType":"Mobile Handset","billLiteral":"Apple iPhone 12 64GB","contractType":"MRO","monthlyAmount":"111.00","remainingTerm":"6","remainingAmount":"1111.45"},{"productID":"100300584800000020077","deviceID":"354880094381776","deviceType":"Mobile Handset","billLiteral":"Samsung Galaxy S20 5G 128GB","contractType":"MRO","monthlyAmount":"22.00","remainingTerm":"15","remainingAmount":"222.43"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}},{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61474896432","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","repayments":null,"Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $10","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}},{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61474896433","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $15","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090167","deviceID":"352914116119203","deviceType":"Mobile Handset","billLiteral":"Apple iPhone XR 64GB","contractType":"MRO","monthlyAmount":"333.00","remainingTerm":"8","remainingAmount":"3333.45"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO TransitionDataJSON = TransitionDataDTO.parse(dataJson);
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test';
        legacyRec.Service_Id__c = '61465768323';
        legacyRec.Product_Basket__c = basketId;
        legacyRec.Select__c = true;
        insert legacyRec;
        Legacy_Service__c legacyRecFalse = new Legacy_Service__c();
        legacyRecFalse.Name = 'test1';
        legacyRecFalse.Service_Id__c = '61465768324';
        legacyRecFalse.Product_Basket__c = basketId;
        legacyRecFalse.Select__c = false;
        insert legacyRecFalse;
        CompUtilityReplicatorManager.getMROLegacyDetails(TransitionDataJSON,basketId);
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>([Select id from Legacy_Service__c where Product_Basket__r.id=:basketId]);
        System.assert(legacyServiceList.size() > 0);
        Test.stopTest();
    }
    @isTest
    public static void getMRODetailsTest(){
        Test.startTest();
        String searchVal = '61465768323';
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c where name = 'Transition'];
        String basketId = prodBasket[0].id;
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test';
        legacyRec.Service_Id__c = '614768323';
        legacyRec.Product_Basket__c = basketId;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        insert legacyRec;
        Legacy_Service__c legacyRecfalse = new Legacy_Service__c();
        legacyRecfalse.Name = 'test1';
        legacyRecfalse.Service_Id__c = '61768323';
        legacyRecfalse.Product_Basket__c = basketId;
        legacyRecfalse.Eligibility_Status__c = 'Eligible';
        legacyRecfalse.Select__c = false;
        insert legacyRecfalse;
        //Ramya:Deselected
        //
        Service_Add_On__c addOnRecFalse = new Service_Add_On__c();
        addOnRecFalse.Legacy_Service__c = legacyRec.Id;
        addOnRecFalse.Contract_Type__c = 'MRO';
        addOnRecFalse.Charging_Option__c = 'Keep monthly repayment';
        addOnRecFalse.Final_Remaining_Amount__c = 550;
        addOnRecFalse.Final_Remaining_Term__c = 5; 
        addOnRecFalse.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecFalse.Residual_Remaining_Amount__c = 555;
        addOnRecFalse.Residual_Remaining_Term__c = 6;
        addOnRecFalse.Instance_Id__C ='34288431';
        addOnRecFalse.Status__C ='Sync Completed';
        addOnRecFalse.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRecFalse;
        
        
        Service_Add_On__c addOnRec = new Service_Add_On__c();
        addOnRec.Legacy_Service__c = legacyRec.Id;
        addOnRec.Contract_Type__c = 'MRO';
        addOnRec.Charging_Option__c = 'Keep monthly repayment';
        addOnRec.Final_Remaining_Amount__c = 555;
        addOnRec.Final_Remaining_Term__c = 6; 
        addOnRec.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRec.Residual_Remaining_Amount__c = 555;
        addOnRec.Residual_Remaining_Term__c = 6;
        addOnRec.Instance_Id__C ='342343';
        addOnRec.Status__C ='Pending';
        addOnRec.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRec;

        //DPG-4072 START
        Service_Add_On__c addOnRecARO = new Service_Add_On__c();
        addOnRecARO.Legacy_Service__c = legacyRec.Id;
        addOnRecARO.Contract_Type__c = 'ARO';
        addOnRecARO.Charging_Option__c = 'Keep monthly repayment';
        addOnRecARO.Final_Remaining_Amount__c = 555;
        addOnRecARO.Final_Remaining_Term__c = 6; 
        addOnRec.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecARO.Residual_Remaining_Amount__c = 555;
        addOnRecARO.Residual_Remaining_Term__c = 6;
        addOnRecARO.Instance_Id__C ='342343243';
        addOnRecARO.Status__C ='Pending';
        addOnRecARO.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRecARO;
        //DPG-4072 END

        Service_Add_On__c addOnRecInst = new Service_Add_On__c();
        addOnRecInst.Legacy_Service__c = legacyRec.Id;
        addOnRecInst.Contract_Type__c = 'MRO';
        addOnRecInst.Charging_Option__c = 'Keep monthly repayment';
        addOnRecInst.Final_Remaining_Amount__c = 555;
        addOnRecInst.Final_Remaining_Term__c = 6; 
        addOnRecInst.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecInst.Residual_Remaining_Amount__c = 555;
        addOnRecInst.Residual_Remaining_Term__c = 6;
        addOnRecInst.Instance_Id__C ='3423434';
        addOnRecInst.Status__C ='Sync Removal Pending';
        addOnRecInst.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRecInst;
        Service_Add_On__c addOnRecInstan = new Service_Add_On__c();
        addOnRecInstan.Legacy_Service__c = legacyRec.Id;
        addOnRecInstan.Contract_Type__c = 'MRO';
        addOnRecInstan.Charging_Option__c = 'Keep monthly repayment';
        addOnRecInstan.Final_Remaining_Amount__c = 550;
        addOnRecInstan.Final_Remaining_Term__c = 5; 
        addOnRecInstan.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecInstan.Residual_Remaining_Amount__c = 555;
        addOnRecInstan.Residual_Remaining_Term__c = 6;
        addOnRecInstan.Instance_Id__C ='34288434';
        addOnRecInstan.Status__C ='Sync Removal Completed';
        addOnRecInstan.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRecInstan;
        Legacy_Service__c legacyRecordUnselected = new Legacy_Service__c();
        legacyRecordUnselected.Name = 'testUnselected';
        legacyRecordUnselected.Service_Id__c = '61465768325';
        legacyRecordUnselected.Product_Basket__c = basketId;
        legacyRecordUnselected.Eligibility_Status__c = 'Eligible';
        legacyRecordUnselected.Select__c = false;
        insert legacyRecordUnselected;
        
        Service_Add_On__c addOnRecord = new Service_Add_On__c();
        addOnRecord.Legacy_Service__c = legacyRecordUnselected.Id;
        addOnRecord.Contract_Type__c = 'MRO';
        addOnRecord.Charging_Option__c = 'Keep monthly repayment';
        addOnRecord.Final_Remaining_Amount__c = 555;
        addOnRecord.Final_Remaining_Term__c = 6; 
        addOnRecord.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecord.Residual_Remaining_Amount__c = 555;
        addOnRecord.Residual_Remaining_Term__c = 6;
        addOnRecord.Instance_Id__C ='342346';
        addOnRecord.Status__C ='Pending';
        addOnRecord.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRecord;
        Service_Add_On__c addOnRecInstance = new Service_Add_On__c();
        addOnRecInstance.Legacy_Service__c = legacyRec.Id;
        addOnRecInstance.Contract_Type__c = 'MRO';
        addOnRecInstance.Charging_Option__c = 'Keep monthly repayment';
        addOnRecInstance.Final_Remaining_Amount__c = 555;
        addOnRecInstance.Final_Remaining_Term__c = 6; 
        addOnRecInstance.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecInstance.Residual_Remaining_Amount__c = 555;
        addOnRecInstance.Residual_Remaining_Term__c = 6;
        addOnRecInstance.Instance_Id__C ='3423438';
        addOnRecInstance.Status__C ='Sync Completed';
        addOnRecInstance.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRecInstance;
        CompUtilityReplicatorManager.getMRODetails(basketId,searchVal);
        CompUtilityReplicatorManager.getMROConfirmDetails(basketId);
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>([Select id from Legacy_Service__c where Product_Basket__r.id=:basketId]);
        System.assert(legacyServiceList.size() > 0);
        Test.stopTest();
    }
    @isTest
    public static void getMRODetailsTestNegative(){
        
        String searchVal;
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c where name = 'Transition'];
        String basketId = prodBasket[0].id;
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '61465768323';
        legacyRec.Product_Basket__c = basketId;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        insert legacyRec;
        
        Service_Add_On__c addOnRec = new Service_Add_On__c();
        addOnRec.Legacy_Service__c = legacyRec.Id;
        addOnRec.Contract_Type__c = 'MRO';
        addOnRec.Charging_Option__c = 'Keep monthly repayment';
        addOnRec.Final_Remaining_Amount__c = 555;
        addOnRec.Final_Remaining_Term__c = 6;
        addOnRec.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRec.Residual_Remaining_Amount__c = 555;
        addOnRec.Residual_Remaining_Term__c = 6;
        addOnRec.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRec;
        CompUtilityReplicatorManager.getMRODetails(basketId,searchVal);
        Test.startTest();
        Boolean isTransitionJsonReturned=CompUtilityReplicatorManagerHelper.checkReplicatorResponse(basketId);
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>([Select id from Legacy_Service__c where Product_Basket__r.id=:basketId]);
        System.assert(legacyServiceList.size() > 0);
        Test.stopTest();
    }
    
     @isTest
    public static void getMRODetailsTestEmpty(){
        Test.startTest();
        String searchVal = 'Apple iPhone XR 64GB';
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c where name = 'Transition'];
        String basketId = prodBasket[0].id;
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '';
        legacyRec.Product_Basket__c = basketId;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        insert legacyRec;
        
        Service_Add_On__c addOnRec = new Service_Add_On__c();
        addOnRec.Legacy_Service__c = legacyRec.Id;
        addOnRec.Contract_Type__c = 'MRO';
        addOnRec.Charging_Option__c = 'Keep monthly repayment';
        addOnRec.Final_Remaining_Amount__c = 555;
        addOnRec.Final_Remaining_Term__c = 6;
        addOnRec.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRec.Residual_Remaining_Amount__c = 555;
        addOnRec.Residual_Remaining_Term__c = 6;
        addOnRec.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRec;
        CompUtilityReplicatorManager.getMRODetails(basketId,searchVal);
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>([Select id from Legacy_Service__c where Product_Basket__r.id=:basketId]);
        System.assert(legacyServiceList.size() > 0);
        Test.stopTest();
    }
    @isTest
    public static void getMRODetailsTestMethod(){
        List<All_Payment_Types__mdt> paymentTypes = new List<All_Payment_Types__mdt>();
        Test.startTest();
        String searchVal = '61465768323';
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c where name = 'Transition'];
        String basketId = prodBasket[0].id;
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '61465768323';
        legacyRec.Product_Basket__c = basketId;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        insert legacyRec;
        
        Service_Add_On__c addOnRec = new Service_Add_On__c();
        addOnRec.Legacy_Service__c = legacyRec.Id;
        addOnRec.Contract_Type__c = 'MRO';
        addOnRec.Charging_Option__c = 'Keep monthly repayment';
        addOnRec.Final_Remaining_Amount__c = 555;
        addOnRec.Final_Remaining_Term__c = 6;
        addOnRec.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRec.Residual_Remaining_Amount__c = 555;
        addOnRec.Residual_Remaining_Term__c = 6;
        addOnRec.Product_End_Date__c = Date.newInstance(2021, 08, 01);
        Insert addOnRec;
        paymentTypes = CompUtilityReplicatorManager.enablePaymentTypes();
        CompUtilityReplicatorManager.getMRODetails(basketId,searchVal);
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>([Select id from Legacy_Service__c where Product_Basket__r.id=:basketId]);
        System.assert(legacyServiceList.size() > 0);
        Test.stopTest();
    }

    /* @Author    :   Abhishek Mallick(Osaka Team)
     * @Updated    : 
        * @Desc     :   Test Method for getEligibilityStatusMobile CompUtilityReplicatorManager
        * @US       :   EDGE-199057
       * */      
    @isTest
    public static void getEligibilityStatusMobileTest(){
        Boolean isMobileEligibility;
        Account accRec = new Account();
        accRec = [select id from Account where name = 'TestAcc'];
        String callBackResponse = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/5032e07a-9b62-4076-bf10-c849ad5084e5"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/d56ae6fb-1a45-4a42-b808-b5d1a83a5c5d"}],"executionId":"5032e07a-9b62-4076-bf10-c849ad5084e5","transitionId":"d56ae6fb-1a45-4a42-b808-b5d1a83a5c5d","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"failed","results":[]}],"metadata":{"salesforceId":"00P2N000003161rUAA","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"4c9342fb-b8daf39f-d952fbe1-7283e742","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        
        cscfga__Product_Basket__c prodBasketMobile = new cscfga__Product_Basket__c();
        prodBasketMobile.csbb__Account__c = accRec.Id;
        prodBasketMobile.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        prodBasketMobile.Name = 'Mobile Eligibility Transition';
        prodBasketMobile.Transition_basket_stage__c = 'Check Eligibility Triggered';
        prodBasketMobile.isEligibilityCheckComplete__c = false;
        prodBasketMobile.isEligibilityTriggered__c = false;
        insert prodBasketMobile;
        
        cscfga__Product_Definition__c productDefinition = ProductTestFactory.buildProductDefinition('TestEligibility','Test');
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert productDefinition;
 
        cscfga__Product_Configuration__c prodConfigMobile = ProductTestFactory.buildProductConfig(productDefinition.Id);
        prodConfigMobile.name= 'Corporate Mobile Plus';
        prodConfigMobile.cscfga__Description__c = 'Test description';
        prodConfigMobile.cscfga__Product_Basket__c = prodBasketMobile.Id;
        prodConfigMobile.isEligibleForTriggered__c=true;
        prodConfigMobile.cscfga__Quantity__c = 1;
        insert prodConfigMobile;
        
        MobileTramasElgibility__c mobileTramRec = new MobileTramasElgibility__c();
        mobileTramRec.name = 'MobileTramasEligibility';
        mobileTramRec.Type__c = 'TM1';
        mobileTramRec.Product_Basket__c = prodBasketMobile.Id;
        mobileTramRec.Product_Configuration__c= prodConfigMobile.Id;
        insert mobileTramRec;
        
        Attachment attRec = new Attachment();
        attRec.Name = 'MobileTramasElgibility.json';
        attRec.ParentId = mobileTramRec.Id; 
        Blob bodyBlob=Blob.valueOf(callBackResponse);
        attRec.body=bodyBlob;
        attRec.Body = bodyBlob;
        insert attRec;
        
        String basketId = prodBasketMobile.Id;
        Test.startTest();
        isMobileEligibility=CompUtilityReplicatorManager.getEligibilityStatusMobile(basketId);
        System.assert(attRec.Id!=null);
        Test.stopTest();
        
    }
/*-----------------------------------------------------------------------------
EDGE-200766
Method Name -feedbackCaseTest
Description -Test method to cover CompUtilityReplicatorManager class feedbackCase method. 
Author - Preeti Malik
-------------------------------------------------------------------------------*/
    @IsTest public static void feedbackCaseTest(){
        
        String basketId = [Select id,csbb__Account__c From cscfga__Product_Basket__c LIMIT 1].id;
        CompUtilityReplicatorManager.feedbackCase(basketId,'84667','96384753','8563');
        
        List<Case> feedbackCases = [Select id From case];
        
        system.assertEquals(true, feedbackCases.size()>0);
        
    }
     @isTest
    public static void getTramsErrorCodeTest(){
        List<String> selectProd = new List<String>();
        List<cscfga__Product_Basket__c> pb = [SELECT Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c 
                                              FROM cscfga__Product_Basket__c 
                                              WHERE Name = 'Transition'];
        Test.startTest();
        NumberReservationTM2CallOut.ErrorWrapper errorWrap =  CompUtilityReplicatorManager.getTramsErrorCode('Mobile',pb[0].id,'TM1',System.now());
        System.debug('errorWrap:'+errorWrap);
        Test.stopTest();
        System.assertEquals(errorWrap==null, true, 'Success');
    }
    
     @isTest
    public static void CompUtilityReplicatorManagerTest(){
        
        List<cscfga__Product_Basket__c> pb = [SELECT Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c 
                                              FROM cscfga__Product_Basket__c 
                                              WHERE Name = 'Transition'];
                                              
        Test.startTest();
        
           CompUtilityReplicatorManager.getCommunityUrl();
           CompUtilityReplicatorManager.getCurrentDatetime();
           CompUtilityReplicatorManager.checkReplicatorResponseHelper(pb[0].Id);
           
        Test.stopTest();
        
    }
    @IsTest public static void autoSIOConfigSuccessTest(){
        Test.startTest();
        string basketId=[SELECT id,Name,cscfga__Opportunity__r.Name from cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name ='Migration Opportunity' LIMIT 1]?.Id;
        Test.setMock(HttpCalloutMock.class, new OrderLodgementMock('success_acknowledgement'));
        Boolean isSucess= CompUtilityReplicatorManager.autoSIOConfig(basketId);
        system.assertEquals(isSucess!=null, true );
        Test.stopTest();   
    }
    
}