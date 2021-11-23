@isTest
public class NumberReservationTM2CallOutTest {
    @testSetup 
    public static void setupdata(){
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Enterprise Mobility Plan' ;
        mo.Name = 'Enterprise Mobility Plan';
        mo.Offer_ID__c = 'DMCAT_ProductSpecification_001196';
        insert mo;
        
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Enterprise Mobility Plan';
        productDefinition.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000871';
        insert productDefinition;
        
        cscfga__Product_Definition__c productDefinition1 = new cscfga__Product_Definition__c();
        productDefinition1.Name = 'Enterprise Mobility Plan';
        productDefinition1.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition1.product_Specification__c = 'DMCAT_ProductSpecification_001196';
        insert productDefinition1; 
        
        cscfga__Product_Basket__c productBasket=TestDataFactory.generateProductBasket(); 
        productBasket.name='Retrigger Basket';
        update productBasket;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(productDefinition.id);
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = productBasket.Id;
        config.cscfga__Contract_Term__c = 36;
        config.Marketable_Offer__c = mo.Id;
        //config.OfferName__c = 'Adaptive Mobility';
        insert config;
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(productDefinition.id);
        config1.cscfga__total_contract_value__c = 125;
        config1.cscfga__Product_Basket__c = productBasket.Id;
        config1.cscfga__Contract_Term__c = 36;
        config1.Marketable_Offer__c = mo.Id;
        insert config1;
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(productDefinition1.id);
        config2.cscfga__total_contract_value__c = 125;
        config2.cscfga__Product_Basket__c = productBasket.Id;
        config2.cscfga__Contract_Term__c = 36;
        config2.Marketable_Offer__c = mo.Id;
        insert config2;
        
        //EDGE-148075 - Added Plan Type value to attachment
        //Kalashree Borgaonkar. updated json to cover tramas errors  
        String attachbody='{"CIDN":"6898327073","Correlation_Id":"abcd_1234","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"disableCheck":null,"eligibilityReason":null,"eligibilityStatus":null,"Product_Type":"Mobile PostPaid HandHeld","site":[{"ADBOR_Id":"0","Error_Code":null,"Error_Description":null,"serviceList":[{"checkValue":true,"disableCheck":null,"checkReserved":false,"groupType":[{"transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a","groupId":"mobileGroup","checkValue":true,"service":[{"plan_type":"MBB","calling_line_identifier":"off","contract_term":"0","directory_listing":null,"idd":"BFIDD100 &#124; Bus Fleet Plus IDD $100","imsi_number":"505013438393119","international_roaming":"EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack","message_bank":"3GPPMSGK &#124; 3G Pre-Paid Video Message Bank","plan_name":"3OB*049 &#124; 3G Cap 49 Business Mobile Plan","Service_Id":"0438034768","service_status":"AC","Reserve_status":"failed","tramasErrorCode":"TMV00009","Reason":"","service_type":null,"service_type_code":"NORM","sim_serial_number":"89610179078138000029","devices":[{"deviceType":"IMSI","physicalId":"098624178919736","networkId":"098624178919732"}],"serviceExtensions":[{"fromNumber":"61516728911","toNumber":"61516728914","Reserve_status":"completed","Reason":"transition","tramasErrorCode":"TMV00009"}]}]}],"Service_Type":null}],"siteName":null},{"ADBOR_Id":"0","Error_Code":null,"Error_Description":null,"serviceList":[{"checkValue":true,"disableCheck":null,"checkReserved":false,"groupType":[{"transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a","groupId":"mobileGroup","checkValue":true,"service":[{"calling_line_identifier":"off","contract_term":"0","directory_listing":null,"idd":"BFIDD100 &#124; Bus Fleet Plus IDD $100","imsi_number":"505013438393119","international_roaming":"EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack","message_bank":"3GPPMSGK &#124; 3G Pre-Paid Video Message Bank","plan_name":"3OB*049 &#124; 3G Cap 49 Business Mobile Plan","Service_Id":"07028050153","service_status":"AC","Reserve_status":"failed","Reason":"","service_type":null,"service_type_code":"NORM","sim_serial_number":"89610179078138000029","serviceExtensions":[{"fromNumber":"61516728911","toNumber":"61516728914","Reserve_status":"completed","Reason":"transition"}]}]}],"Service_Type":null}],"siteName":null},{"ADBOR_Id":"0000","Error_Code":null,"Error_Description":null,"serviceList":[{"checkValue":true,"disableCheck":null,"checkReserved":false,"groupType":[{"transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a","groupId":"mobileGroup","checkValue":true,"service":[{"calling_line_identifier":"on","contract_term":"120","directory_listing":null,"idd":"BFIDD100 &#124; Bus Fleet Plus IDD $100","imsi_number":"505013438393120","international_roaming":"EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack","message_bank":"3GPPMSGK &#124; 3G Pre-Paid Video Message Bank","plan_name":"3OB*049 &#124; 3G Cap 49 Business Mobile Plan","Service_Id":"0480126680","Reserve_status":"Error","Reason":"Test Error","service_status":"NOVA","service_type":null,"service_type_code":"NORM","siam_serial_number":"89610179078138000029"}]}],"Service_Type":null}],"siteName":null}]},{"checkValue":false,"disableCheck":null,"eligibilityReason":null,"eligibilityStatus":null,"Product_Type":"Mobile PrePaid HandHeld","site":[{"ADBOR_Id":"123","Error_Code":null,"Error_Description":null,"serviceList":[{"checkValue":false,"disableCheck":null,"checkReserved":false,"groupType":[{"transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a","groupId":"mobileGroup","service":[{"calling_line_identifier":"off","contract_term":"0","directory_listing":null,"idd":"BFIDD100 &#124; Bus Fleet Plus IDD $100","imsi_number":"505013438393119","international_roaming":"EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack","message_bank":"3GPPMSGK &#124; 3G Pre-Paid Video Message Bank","plan_name":"3OB*049 &#124; 3G Cap 49 Business Mobile Plan","Service_Id":"8910","Reserve_status":"","Reason":"","service_status":"AC","service_type":null,"service_type_code":"NORM","sim_serial_number":"89610179078138000029"}]}],"Service_Type":null}],"siteName":null}]}],"serviceCount":0,"Source_System_Id":"Replicator"}';
        Attachment attach=TestDataFactory.generateAttachment( label.MobileTransitionName,attachbody , config.id);
        //EDGE-149261 - Added Attribute
        cscfga__Attribute__c att = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = config.Id,
            Name = 'SelectPlanName',
            cscfga__Value__c = 'BYO',
            cscfga__is_active__c = true
        );
        insert att;
        TransitionResponseCodes__c code1 = new TransitionResponseCodes__c(Reason__c='Techincal error for every legacy service',Status__c='Failed',TRAMAS_Code__c='TN4014');
        TransitionResponseCodes__c code2 = new TransitionResponseCodes__c(Reason__c='Some/all rules did not pass',Status__c='Not Eligible',TRAMAS_Code__c='TM4011');
        TransitionResponseCodes__c code3 = new TransitionResponseCodes__c(Reason__c='This service is in credit management',Status__c='Not Eligible',TRAMAS_Code__c='TMV00009');
        List<TransitionResponseCodes__c> responseCodeList = new List<TransitionResponseCodes__c>();
        responseCodeList.add(code1);
        responseCodeList.add(code2);
        responseCodeList.add(code3);
        insert responseCodeList;
    }
    @isTest
    public static void getStatusAndReasonTest(){
        Test.startTest();
        Map<String,NumberReservationTM2CallOut.ErrorWrapper>  errorCodetoStausMap = NumberReservationTM2CallOut.getStatusAndReason();
        Test.stopTest();
        System.assertEquals(errorCodetoStausMap.size()>0,true, 'Error code map retrieved');
    }
    
    static void DeleteContractTest() {
        Test.startTest();
        try{
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c = 'ACTIVE';
            insert acc;  
            //CREATE CONTACT 
            Contact contact = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '123456789',
                Email = 'test@tele2.com'   
            );
            Insert contact;
            Contact contact2 = new Contact(
                AccountId = acc.id,
                LastName = 'Last1',
                FirstName = 'First1',
                Contact_Role__c = 'Consultant',
                MobilePhone = '1234567890',
                Email = 'test0@tele2.com'   
            );
            Insert contact2;
            
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            insert opp;
            
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            
            OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = basket.cscfga__Opportunity__c;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
            
            CustomConfigurationOptions__c CO = new CustomConfigurationOptions__c();
            CO.Name = 'ContractInitiate';
            CO.Enrichment_Basket_Stage__c = 'Contract Initiated';
            CO.External_Id__c = '7842';
            CO.MarketableOfferList__c = '';
            CO.Opportunity_Stage__c = 'Propose';
            Insert CO;
            
            ContractJunction__c record = new ContractJunction__c();
            record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            record.Email__c = oppContact.contact.Email;
            record.Phone__c = oppContact.contact.MobilePhone;
            record.Customer_Primary_Contact__c = oppContact.ContactId;
            record.Related_Basket__c = basket.id;
            record.DocuSign_Signer_2__c = contact.id;
            record.DocuSign_Signer_3__c = UserInfo.getUserId();
            record.CongaStatus__c = 'NotStarted';
            record.Account__c = basket.csbb__Account__c;
            record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
            record.Contract_Activated_Date__c = System.today();
            record.Contract_Term_Months__c = 36;
            record.Name = 'CN' + basket.Name.substring(2);
            insert record;          
            
            Delete record;
            system.assert(record != NULL);
        }
        catch(Exception e){
            
        } 
        Test.stopTest();
    }    
    
    //EDGE-195766 - Test methods for  'fetchReserveProdConfig' , 'TM2WebCalloutAsync' & 'fetchReserveProdConfig'
    @isTest
    static void fetchEligibleProdSuccessTest() {
        Test.startTest();
        try{
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c = 'ACTIVE';
            insert acc;  
            System.assertNotEquals(acc.Id, null);
            //CREATE CONTACT 
            Contact contact = new Contact( 
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '123456789',
                Email = 'test@tele2.com'   
            );
            Insert contact;
            System.assertNotEquals(contact.Id, null);
            Contact contact2 = new Contact(
                AccountId = acc.id,
                LastName = 'Last1',
                FirstName = 'First1',
                Contact_Role__c = 'Consultant',
                MobilePhone = '1234567890',
                Email = 'test0@tele2.com'   
            );
            Insert contact2;
            System.assertNotEquals(contact2.Id, null);
            
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            insert opp;
            System.assertNotEquals(opp.Id, null);
            
            Marketable_Offer__c mo = new Marketable_Offer__c();
            mo.OfferDefinationName__c ='CWP Mobility' ;
            mo.Name = 'CWP Mobility';
            mo.Offer_ID__c = 'D12333';
            insert mo;
            
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            System.assertNotEquals(basket.Id, null);
            
            OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = basket.cscfga__Opportunity__c;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
            System.assertNotEquals(oppContact.Id, null);
            //create Product Definition
            cscfga__Product_Definition__c defMob = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility', product_Specification__c = 'DMCAT_ProductSpecification_000420');
            
            List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMob};
                insert prodDefList;
            
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defMob.id);
            config.cscfga__total_contract_value__c = 325;
            config.cscfga__Product_Basket__c = basket.Id;
            config.cscfga__Contract_Term__c = 36;
            config.Marketable_Offer__c = mo.Id;
            insert config;
            
            Attachment att = new Attachment();
            att.Name = 'TransitionData.json';
            att.ParentId = config.Id;
            att.body = Blob.ValueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987999","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":525.45,"productID":"100018937100000091789","monthlyAmount":50,"deviceType":"Mobile Handset","deviceID":"352914116112240","contractType":"MRO","billLiteral":"Apple iPhone 11 64GB"},{"Service_Id":null,"remainingTerm":3,"remainingAmount":527.45,"productID":"100018937100000091970","monthlyAmount":55,"deviceType":"Mobile Handset","deviceID":"352914116115234","contractType":"MRO","billLiteral":"Apple iPhone 11 64GB"}],"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895435","networkId":"505013345678900","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987998","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":525.45,"productID":"100018937100000070790","monthlyAmount":50,"deviceType":"Mobile Handset","deviceID":"352914116159240","contractType":"MRO","billLiteral":"Apple iPhone 11 64GB"},{"Service_Id":null,"remainingTerm":3,"remainingAmount":527.45,"productID":"100018937100000090970","monthlyAmount":55,"deviceType":"Mobile Handset","deviceID":"352914116119234","contractType":"MRO","billLiteral":"Apple iPhone 11 64GB"}],"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895434","networkId":"505013345678901","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987997","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":525.45,"productID":"100018937100000071790","monthlyAmount":50,"deviceType":"Mobile Handset","deviceID":"352914116159230","contractType":"MRO","billLiteral":"Apple iPhone 11 64GB"},{"Service_Id":null,"remainingTerm":3,"remainingAmount":527.45,"productID":"100018937100000096970","monthlyAmount":55,"deviceType":"Mobile Handset","deviceID":"352914116119264","contractType":"MRO","billLiteral":"Apple iPhone 11 64GB"}],"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895433","networkId":"505013345678902","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987990","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":525.45,"productID":"100018937100000072790","monthlyAmount":50,"deviceType":"Mobile Handset","deviceID":"352914116169230","contractType":"MRO","billLiteral":"Apple iPhone 11 128GB"},{"Service_Id":null,"remainingTerm":3,"remainingAmount":527.45,"productID":"100018937100000066970","monthlyAmount":55,"deviceType":"Mobile Handset","deviceID":"352914116119064","contractType":"MRO","billLiteral":"Samsung note 11 512GB"}],"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895426","networkId":"505013345678909","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987991","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":525.45,"productID":"100018937100000045790","monthlyAmount":50,"deviceType":"Mobile Handset","deviceID":"352914116168730","contractType":"MRO","billLiteral":"Apple iPhone 11 128GB"},{"Service_Id":null,"remainingTerm":3,"remainingAmount":527.45,"productID":"100018937100000087970","monthlyAmount":55,"deviceType":"Mobile Handset","deviceID":"352914116120064","contractType":"MRO","billLiteral":"XI note 11 512GB"}],"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895427","networkId":"505013345678908","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987993","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":525.45,"productID":"100018937100000205790","monthlyAmount":50,"deviceType":"Mobile Handset","deviceID":"352914121168730","contractType":"MRO","billLiteral":"Apple iPhone 11 128GB"},{"Service_Id":null,"remainingTerm":3,"remainingAmount":527.45,"productID":"100018937100000567970","monthlyAmount":55,"deviceType":"Mobile Handset","deviceID":"352914116290064","contractType":"MRO","billLiteral":"XI note 11 512GB"}],"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895429","networkId":"505013345678906","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987992","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":525.45,"productID":"100018937100000253790","monthlyAmount":50,"deviceType":"Mobile Handset","deviceID":"352914121166730","contractType":"MRO","billLiteral":"Apple iPhone 11 128GB"},{"Service_Id":null,"remainingTerm":3,"remainingAmount":527.45,"productID":"100018937100000578970","monthlyAmount":55,"deviceType":"Mobile Handset","deviceID":"352914116293864","contractType":"MRO","billLiteral":"XI note 11 512GB"}],"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895428","networkId":"505013345678907","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987995","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"failed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":null,"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895431","networkId":"505013345678904","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987994","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":null,"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895430","networkId":"505013345678905","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":"7","calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","service_status":null,"Service_Id":"61477987996","service_association_role":null,"Reserved_ranges":null,"Reserve_status":"failed","replicatorUpdateDateTime":"2020-11-15 06:48:02.763","repayments":null,"Redirection_product":null,"Reason":null,"plan_type":"Mobile Broadband","plan_name":"Corporate Mobile Plus $5","mro_with_no_imei":null,"message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89618976543267895432","networkId":"505013345678903","deviceType":"SIM"}],"device_lease_contract_indicator":null,"contract_term":"O","contract_remaining_term":null,"calling_line_identifier":"ON","association_type":null,"aro_indicator":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012444"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":false}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":false,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"f2c34c9d1d510ea1a6","CIDN":"2804506976"}');
		insert att;
		System.assertNotEquals(att.Id, null);
		
		Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('success_acknowledgement'));
		
		ContractJunction__c record = new ContractJunction__c();
		record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
		record.Email__c = oppContact.contact.Email;
		record.Phone__c = oppContact.contact.MobilePhone;
		record.Customer_Primary_Contact__c = oppContact.ContactId;
		record.Related_Basket__c = basket.id;
		record.DocuSign_Signer_2__c = contact.id;
		record.DocuSign_Signer_3__c = UserInfo.getUserId();
		record.CongaStatus__c = 'NotStarted';
		record.Account__c = basket.csbb__Account__c;
		record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
		record.Contract_Activated_Date__c = System.today();
		record.Contract_Term_Months__c = 36;
		record.Name = 'CN' + basket.Name.substring(2);
		record.Status__c = 'Initiated';
		insert record;
		System.assertNotEquals(record.Id, null);
		record.Status__c = 'Contract Accepted';
		update record;
		
		NumberReservationTM2CallOut tm2callout = new NumberReservationTM2CallOut();
		tm2callout.fetchEligibleProdConfig(basket.id);            
		}
		catch(Exception e){            
		} 
		Test.stopTest();
		}     
		
		@isTest
		static void fetchEligibleProdErrorTest() {
			Test.startTest();
			try{
				Account acc = AccountTestFactory.buildAccount('Test Account') ;
				acc.Customer_Status__c = 'ACTIVE';
				insert acc;  
				System.assertNotEquals(acc.Id, null);
				//CREATE CONTACT 
				Contact contact = new Contact(
					AccountId = acc.id,
					LastName = 'Last',
					FirstName = 'First',
					Contact_Role__c = 'Consultant',
					MobilePhone = '123456789',
					Email = 'test@tele2.com'   
				);
				Insert contact;
				System.assertNotEquals(contact.Id, null);
				Contact contact2 = new Contact(
					AccountId = acc.id,
					LastName = 'Last1',
					FirstName = 'First1',
					Contact_Role__c = 'Consultant',
					MobilePhone = '1234567890',
					Email = 'test0@tele2.com'   
				);
				Insert contact2;
				System.assertNotEquals(contact2.Id, null);
				//CREATE OPPORTUNITY
				Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
				opp.amount = 4600;
				insert opp;
				System.assertNotEquals(opp.Id, null);
				
				//Create Basket
				cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
				basket.csbb__Account__c = acc.id;
				basket.cscfga__Opportunity__c = opp.id;
				basket.Name = 'basket1';
				insert basket;
				System.assertNotEquals(basket.Id, null);
				
				OpportunityContactRole oppContact = new OpportunityContactRole();
				oppContact.ContactId = contact.Id;
				oppContact.IsPrimary = true;
				oppContact.OpportunityId = basket.cscfga__Opportunity__c;
				oppContact.Role = 'Inside Sales Account Manager';
				insert oppContact;
				System.assertNotEquals(oppContact.Id, null);
				
				//create Product Definition
				cscfga__Product_Definition__c defMob = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility');
				
				List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMob};
					insert prodDefList;
				
				cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defMob.id);
				config.cscfga__total_contract_value__c = 325;
				config.cscfga__Product_Basket__c = basket.Id;
				config.cscfga__Contract_Term__c = 36;
				insert config;
				
				Attachment att = new Attachment();
				att.Name = 'TransitionData.json';
				att.ParentId = config.Id;
				att.body = Blob.ValueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"0438034768","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":"524822a6-71ef-4774-9edd-7528536b98ac"}],"disableCheck":null,"checkValue":true}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"NOVA","Service_Id":"0480126680","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393120","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"120","calling_line_identifier":"on"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0000"}],"Product_Type":"Mobile PostPaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":true},{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"8910","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"123"}],"Product_Type":"Mobile PrePaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":false}],"Error_Description":"","Error_Code":"","Correlation_Id":"abcd_1234","CIDN":"6898327073"}');
				insert att;
				System.assertNotEquals(att.Id, null);
				
				Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('error_acknowledgement'));
				
				ContractJunction__c record = new ContractJunction__c();
				record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
				record.Email__c = oppContact.contact.Email;
				record.Phone__c = oppContact.contact.MobilePhone;
				record.Customer_Primary_Contact__c = oppContact.ContactId;
				record.Related_Basket__c = basket.id;
				record.DocuSign_Signer_2__c = contact.id;
				record.DocuSign_Signer_3__c = UserInfo.getUserId();
				record.CongaStatus__c = 'NotStarted';
				record.Account__c = basket.csbb__Account__c;
				record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
				record.Contract_Activated_Date__c = System.today();
				record.Contract_Term_Months__c = 36;
				record.Name = 'CN' + basket.Name.substring(2);
				record.Status__c = 'Initiated';
				insert record;
				System.assertNotEquals(record.Id, null);
				record.Status__c = 'Contract Accepted';
				update record;
				
				NumberReservationTM2CallOut tm2callout = new NumberReservationTM2CallOut();
				tm2callout.fetchEligibleProdConfig(basket.id);
			}
			catch(Exception e){            
			} 
			Test.stopTest();
		} 
		/*****************************************************************************
* Description : Test method to cover | class : NumberReservationTM2CallOut 
| Method : fetchReserveProdConfigTest
******************************************************************************/ 
		@isTest
		static void fetchReserveProdConfigCwpTest() {
			Test.startTest();
			try{
				Account acc = AccountTestFactory.buildAccount('Test Account') ;
				acc.Customer_Status__c = 'ACTIVE';
				insert acc;  
				System.assertNotEquals(acc.Id, null);
				//CREATE CONTACT 
				Contact contact = new Contact(
					AccountId = acc.id,
					LastName = 'Last',
					FirstName = 'First',
					Contact_Role__c = 'Consultant',
					MobilePhone = '123456789',
					Email = 'test@tele2.com'   
				);
				Insert contact;
				System.assertNotEquals(contact.Id, null);
				Contact contact2 = new Contact(
					AccountId = acc.id,
					LastName = 'Last1',
					FirstName = 'First1',
					Contact_Role__c = 'Consultant',
					MobilePhone = '1234567890',
					Email = 'test0@tele2.com'   
				);
				Insert contact2;
				System.assertNotEquals(contact2.Id, null);
				
				//CREATE OPPORTUNITY
				Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
				opp.amount = 4600;
				insert opp;
				System.assertNotEquals(opp.Id, null);
				
				//Create Basket
				cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
				basket.csbb__Account__c = acc.id;
				basket.cscfga__Opportunity__c = opp.id;
				basket.Name = 'basket1';
				insert basket;
				System.assertNotEquals(basket.Id, null);
				
				OpportunityContactRole oppContact = new OpportunityContactRole();
				oppContact.ContactId = contact.Id;
				oppContact.IsPrimary = true;
				oppContact.OpportunityId = basket.cscfga__Opportunity__c;
				oppContact.Role = 'Inside Sales Account Manager';
				insert oppContact;
				System.assertNotEquals(oppContact.Id, null);
				//create Product Definition
				cscfga__Product_Definition__c defMob = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility');
				defMob.product_Specification__c = 'DMCAT_ProductSpecification_000871';
				
				List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMob};
					insert prodDefList;
				
				cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defMob.id);
				config.cscfga__total_contract_value__c = 325;
				config.cscfga__Product_Basket__c = basket.Id;
				config.cscfga__Contract_Term__c = 36;
				insert config;
				
				Attachment att = new Attachment();
				att.Name = 'TransitionData.json';
				att.ParentId = config.Id;
				att.body = Blob.ValueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"0438034768","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":"524822a6-71ef-4774-9edd-7528536b98ac"}],"disableCheck":null,"checkValue":true}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"NOVA","Service_Id":"0480126680","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393120","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"120","calling_line_identifier":"on"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0000"}],"Product_Type":"Mobile PostPaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":true},{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"8910","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"123"}],"Product_Type":"Mobile PrePaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":false}],"Error_Description":"","Error_Code":"","Correlation_Id":"abcd_1234","CIDN":"6898327073"}');
				insert att;
				System.assertNotEquals(att.Id, null);
				
				Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('error_acknowledgement'));
				
				ContractJunction__c record = new ContractJunction__c();
				record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
				record.Email__c = oppContact.contact.Email;
				record.Phone__c = oppContact.contact.MobilePhone;
				record.Customer_Primary_Contact__c = oppContact.ContactId;
				record.Related_Basket__c = basket.id;
				record.DocuSign_Signer_2__c = contact.id;
				record.DocuSign_Signer_3__c = UserInfo.getUserId();
				record.CongaStatus__c = 'NotStarted';
				record.Account__c = basket.csbb__Account__c;
				record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
				record.Contract_Activated_Date__c = System.today();
				record.Contract_Term_Months__c = 36;
				record.Name = 'CN' + basket.Name.substring(2);
				record.Status__c = 'Initiated';
				insert record;
				System.assertNotEquals(record.Id, null);
				record.Status__c = 'Contract Accepted';
				update record;
				
				NumberReservationTM2CallOut tm2callout = new NumberReservationTM2CallOut();
				tm2callout.fetchEligibleProdConfig(basket.id);
			}
			catch(Exception e){            
			} 
			Test.stopTest();
		} 
		@isTest
		static void fetchReserveProdConfigNgucTest() {
			Test.startTest();
			try{
				Account acc = AccountTestFactory.buildAccount('Test Account') ;
				acc.Customer_Status__c = 'ACTIVE';
				insert acc;  
				System.assertNotEquals(acc.Id, null);
				//CREATE CONTACT 
				Contact contact = new Contact(
					AccountId = acc.id,
					LastName = 'Last',
					FirstName = 'First',
					Contact_Role__c = 'Consultant',
					MobilePhone = '123456789',
					Email = 'test@tele2.com'   
				);
				Insert contact;
				System.assertNotEquals(contact.Id, null);
				Contact contact2 = new Contact(
					AccountId = acc.id,
					LastName = 'Last1',
					FirstName = 'First1',
					Contact_Role__c = 'Consultant',
					MobilePhone = '1234567890',
					Email = 'test0@tele2.com'   
				);
				Insert contact2;
				System.assertNotEquals(contact2.Id, null);
				
				//CREATE OPPORTUNITY
				Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
				opp.amount = 4600;
				insert opp;
				System.assertNotEquals(opp.Id, null);
				//Create Basket
				cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
				basket.csbb__Account__c = acc.id;
				basket.cscfga__Opportunity__c = opp.id;
				basket.Name = 'basket1';
				insert basket;
				System.assertNotEquals(basket.Id, null);
				
				OpportunityContactRole oppContact = new OpportunityContactRole();
				oppContact.ContactId = contact.Id;
				oppContact.IsPrimary = true;
				oppContact.OpportunityId = basket.cscfga__Opportunity__c;
				oppContact.Role = 'Inside Sales Account Manager';
				insert oppContact;
				System.assertNotEquals(oppContact.Id, null);
				//create Product Definition
				cscfga__Product_Definition__c defMob = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility');
				defMob.product_Specification__c = 'DMCAT_ProductOffering_000304';
				
				List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMob};
					insert prodDefList;
				
				cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defMob.id);
				config.cscfga__total_contract_value__c = 325;
				config.cscfga__Product_Basket__c = basket.Id;
				config.cscfga__Contract_Term__c = 36;
				config.Name = 'IP Site';
				insert config;
				
				Attachment att = new Attachment();
				att.Name = 'TransitionData.json';
				att.ParentId = config.Id;
				att.body = Blob.ValueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"0438034768","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":"524822a6-71ef-4774-9edd-7528536b98ac"}],"disableCheck":null,"checkValue":true}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"NOVA","Service_Id":"0480126680","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393120","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"120","calling_line_identifier":"on"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0000"}],"Product_Type":"Mobile PostPaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":true},{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"8910","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"123"}],"Product_Type":"Mobile PrePaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":false}],"Error_Description":"","Error_Code":"","Correlation_Id":"abcd_1234","CIDN":"6898327073"}');
				insert att;
				System.assertNotEquals(att.Id, null);
				
				Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('error_acknowledgement'));
				
				ContractJunction__c record = new ContractJunction__c();
				record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
				record.Email__c = oppContact.contact.Email;
				record.Phone__c = oppContact.contact.MobilePhone;
				record.Customer_Primary_Contact__c = oppContact.ContactId;
				record.Related_Basket__c = basket.id;
				record.DocuSign_Signer_2__c = contact.id;
				record.DocuSign_Signer_3__c = UserInfo.getUserId();
				record.CongaStatus__c = 'NotStarted';
				record.Account__c = basket.csbb__Account__c;
				record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
				record.Contract_Activated_Date__c = System.today();
				record.Contract_Term_Months__c = 36;
				record.Name = 'CN' + basket.Name.substring(2);
				record.Status__c = 'Initiated';
				insert record;
				System.assertNotEquals(record.Id, null);
				record.Status__c = 'Contract Accepted';
				update record;
				
				NumberReservationTM2CallOut tm2callout = new NumberReservationTM2CallOut();
				tm2callout.fetchEligibleProdConfig(basket.id);
			}
			catch(Exception e){            
			} 
			Test.stopTest();
		} 
		
		@isTest
		static void setMobileServiceStatusAndReasonTM1Test() {
			ReplicatorGetServiceManager.TableWrapper mobileTableWrapper = new ReplicatorGetServiceManager.TableWrapper();
			Test.startTest();
			mobileTableWrapper = NumberReservationTM2CallOut.setMobileServiceStatusAndReasonTM1(mobileTableWrapper,'TMV00009');
			Test.stopTest();
			System.assertEquals(mobileTableWrapper!=null,true);
			
		}
		@isTest
		static void setMobileServiceStatusAndReasonTM2Test() {
			TransitionController.transitionWrapper  mobileTableWrapper = new TransitionController.transitionWrapper();
			Test.startTest();
			mobileTableWrapper = NumberReservationTM2CallOut.setMobileServiceStatusAndReasonTM2(mobileTableWrapper,'TMV00009','Success');
			Test.stopTest();
			System.assertEquals(mobileTableWrapper!=null,true); 
		}
		@isTest
		static void setMobileServiceStatusAndReasonTMTest() {
			TransitionController.transitionWrapper  mobileTableWrapper = new TransitionController.transitionWrapper();
			Test.startTest();
			mobileTableWrapper = NumberReservationTM2CallOut.setMobileServiceStatusAndReasonTM2(mobileTableWrapper,null,'Success');
			Test.stopTest();
			System.assertEquals(mobileTableWrapper!=null,true);
		} 
		@isTest static void TM2ForFailedNumbers(){
			Test.startTest();
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('success_acknowledgement'));
			NumberReservationTM2CallOut tm2callout = new NumberReservationTM2CallOut();
			tm2callout.fetchEligibleProdConfig(basket.id);
			Test.stopTest();
			basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Id=:basket.Id];
			system.assertEquals(null, basket.Transition_basket_stage__c);
			
		}
		@isTest static void getTramsErrorCodeMobileSuccess(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id];
			MobileTramasElgibility__c tme = new MobileTramasElgibility__c();
			tme.Name = 'MobileTramasElgibility';
			tme.Product_Configuration__c = pcList[0].id;
			tme.Product_Basket__c = basket.id;
			tme.Type__c = 'TM2';
			insert tme; 
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeMobile(basket.id,null,System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap.executiontype=='TM2', true,'Success');
		}
		@isTest static void getTramsErrorCodeMobile(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id];
			MobileTramasElgibility__c tme = new MobileTramasElgibility__c();
			tme.Name = 'MobileTramasElgibility';
			tme.Product_Configuration__c = pcList[0].id;
			tme.Product_Basket__c = basket.id;
			tme.Type__c = 'TM2';
			insert tme; 
			Test.startTest(); 
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCode('Mobile',basket.id,'TM2',system.now());
			Test.stopTest();
			System.assertEquals(errorWrap.executiontype=='TM2', true,'Success');
		}
		@isTest static void getTramsErrorCodeNguc(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			TramasElgibilityCallbackResponse__c tec = new TramasElgibilityCallbackResponse__c();
			tec.Name = 'TMBatchCallback';
			tec.TranasactionId__c = '5a1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Correlation_ID__c = 'pa1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Product_Basket__c = basket.id;
            tec.Product_Configuration__c = pcList[0].id;
			tec.Type__c = 'TM2';
			insert tec;  
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCode('Fixed',basket.id,'TM2',System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap.tramasErrorCode=='Success', true,'Success');                             
		}
		@isTest static void getTramsErrorCodeMobileError(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id];
			MobileTramasElgibility__c tme = new MobileTramasElgibility__c();
			tme.Name = 'MobileTramasElgibility';
			tme.Product_Configuration__c = pcList[0].id;
			tme.Product_Basket__c = basket.id;
			tme.Type__c = 'Execution Error';
			tme.ErrorCode__c = 'TM4011';
			insert tme; 
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeMobile(basket.id,null,System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap.executiontype=='Execution Error', true,'Success');
		}
		@isTest static void getTramsErrorCodeMobileBlank(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeMobile(basket.id,null,System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap==null, true,'Blank');
		}
		/*@isTest static void getTramsErrorCodeNgucSuccess(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			TramasElgibilityCallbackResponse__c tec = new TramasElgibilityCallbackResponse__c();
			tec.Name = 'TMBatchCallback';
			tec.TranasactionId__c = '02053fa7-06b4-498f-ac7d-ffa288387a17';
			tec.Correlation_ID__c = 'pa1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Product_Basket__c = basket.id;
			tec.Type__c = 'TM2';
            tec.Product_Configuration__c = pcList[0].id;
			insert tec;  
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeNguc(basket.id,null);
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap==null, true,'Success');
		}*/ 
        @isTest static void getTramsErrorCodeNgucErrorTM1(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			 String attachbody='{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"transitionId":"5a1d8612-af50-4ea3-ae26-0de3c43d6ede","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679399","serviceExtensionFrom":"0749679300","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679300","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679479","serviceExtensionFrom":"0749679400","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679400","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679599","serviceExtensionFrom":"0749679500","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679500","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740924R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true},{"transitionId":"02053fa7-06b4-498f-ac7d-ffa288387a17","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679799","serviceExtensionFrom":"0749679700","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679700","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679199","serviceExtensionFrom":"0749679100","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679100","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740929R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true}],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":true}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","FNN":null,"Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}';
        	Attachment attach=TestDataFactory.generateAttachment( 'TransitionDataNgUc.json',attachbody , pcList[0].id);
			List<TramasElgibilityCallbackResponse__c> responseList = new List<TramasElgibilityCallbackResponse__c>();
            TramasElgibilityCallbackResponse__c tec = new TramasElgibilityCallbackResponse__c();
			tec.Name = 'TMBatchCallback';
			tec.TranasactionId__c = '5a1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Correlation_ID__c = 'pa1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Product_Basket__c = basket.id;
			tec.Type__c = 'Execution Error';
            tec.Error_code__c = 'TM4011';
            tec.Product_Configuration__c = pcList[0].id;
            responseList.add(tec);
            TramasElgibilityCallbackResponse__c tec1 = new TramasElgibilityCallbackResponse__c();
			tec1.Name = 'TMBatchCallback';
			tec1.TranasactionId__c = '02053fa7-06b4-498f-ac7d-ffa288387a17';
			tec1.Correlation_ID__c = 'pa1d8612-af50-pea3-ae26-0de3c43d6ede';
			tec1.Product_Basket__c = basket.id;
			tec1.Type__c = 'Execution Error';
            tec1.Error_code__c = 'TM4011';
            tec1.Product_Configuration__c = pcList[0].id;
			responseList.add(tec1);
            insert responseList;  
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeNguc(basket.id,'TM1',System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap.tramasErrorCode =='TM4011', true,'Fail');
		} 
          @isTest static void getTramsErrorCodeNgucErrorTM2(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			 String attachbody='{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"transitionId":"5a1d8612-af50-4ea3-ae26-0de3c43d6ede","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679399","serviceExtensionFrom":"0749679300","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679300","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679479","serviceExtensionFrom":"0749679400","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679400","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679599","serviceExtensionFrom":"0749679500","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679500","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740924R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true},{"transitionId":"02053fa7-06b4-498f-ac7d-ffa288387a17","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679799","serviceExtensionFrom":"0749679700","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679700","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679199","serviceExtensionFrom":"0749679100","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679100","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740929R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true}],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":true}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","FNN":null,"Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}';
        	Attachment attach=TestDataFactory.generateAttachment( 'TransitionDataNgUc.json',attachbody , pcList[0].id);
			List<TramasElgibilityCallbackResponse__c> responseList = new List<TramasElgibilityCallbackResponse__c>();
            TramasElgibilityCallbackResponse__c tec = new TramasElgibilityCallbackResponse__c();
			tec.Name = 'TMBatchCallback';
			tec.TranasactionId__c = '5a1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Correlation_ID__c = 'pa1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Product_Basket__c = basket.id;
			tec.Type__c = 'Execution Error';
            tec.Error_code__c = 'TM4011';
            tec.Product_Configuration__c = pcList[0].id;
            responseList.add(tec);
            TramasElgibilityCallbackResponse__c tec1 = new TramasElgibilityCallbackResponse__c();
			tec1.Name = 'TMBatchCallback';
			tec1.TranasactionId__c = '02053fa7-06b4-498f-ac7d-ffa288387a17';
			tec1.Correlation_ID__c = 'pa1d8612-af50-pea3-ae26-0de3c43d6ede';
			tec1.Product_Basket__c = basket.id;
			tec1.Type__c = 'Execution Error';
            tec1.Error_code__c = 'TM4011';
            tec1.Product_Configuration__c = pcList[0].id;
			responseList.add(tec1);
            insert responseList;  
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeNguc(basket.id,'TM2',System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap.tramasErrorCode =='TM4011', true,'Fail');
		} 
      @isTest static void getTramsErrorCodeNgucSuccess(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			 String attachbody='{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"transitionId":"5a1d8612-af50-4ea3-ae26-0de3c43d6ede","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679399","serviceExtensionFrom":"0749679300","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679300","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679479","serviceExtensionFrom":"0749679400","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679400","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679599","serviceExtensionFrom":"0749679500","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679500","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740924R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true},{"transitionId":"02053fa7-06b4-498f-ac7d-ffa288387a17","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679799","serviceExtensionFrom":"0749679700","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679700","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679199","serviceExtensionFrom":"0749679100","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679100","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740929R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true}],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":true}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","FNN":null,"Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}';
        	Attachment attach=TestDataFactory.generateAttachment( 'TransitionDataNgUc.json',attachbody , pcList[0].id);
			List<TramasElgibilityCallbackResponse__c> responseList = new List<TramasElgibilityCallbackResponse__c>();
            TramasElgibilityCallbackResponse__c tec = new TramasElgibilityCallbackResponse__c();
			tec.Name = 'TMBatchCallback';
			tec.TranasactionId__c = '5a1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Correlation_ID__c = 'pa1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Product_Basket__c = basket.id;
			tec.Type__c = 'TM1';
            tec.Product_Configuration__c = pcList[0].id;
            responseList.add(tec);
            TramasElgibilityCallbackResponse__c tec1 = new TramasElgibilityCallbackResponse__c();
			tec1.Name = 'TMBatchCallback';
			tec1.TranasactionId__c = '02053fa7-06b4-498f-ac7d-ffa288387a17';
			tec1.Correlation_ID__c = 'pa1d8612-af50-pea3-ae26-0de3c43d6ede';
			tec1.Product_Basket__c = basket.id;
			tec1.Type__c = 'TM1';
            tec1.Product_Configuration__c = pcList[0].id;
			responseList.add(tec1);
            insert responseList;  
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeNguc(basket.id,'TM2',System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap.tramasErrorCode =='Success', true,'Success');
		} 
       @isTest static void getTramsErrorCodeNgucPartialSuccess(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			 String attachbody='{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"transitionId":"5a1d8612-af50-4ea3-ae26-0de3c43d6ede","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679399","serviceExtensionFrom":"0749679300","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679300","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679479","serviceExtensionFrom":"0749679400","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679400","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679599","serviceExtensionFrom":"0749679500","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679500","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740924R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true},{"transitionId":"02053fa7-06b4-498f-ac7d-ffa288387a17","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679799","serviceExtensionFrom":"0749679700","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679700","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679199","serviceExtensionFrom":"0749679100","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679100","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740929R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true}],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":true}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","FNN":null,"Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}';
        	Attachment attach=TestDataFactory.generateAttachment( 'TransitionDataNgUc.json',attachbody , pcList[0].id);
			List<TramasElgibilityCallbackResponse__c> responseList = new List<TramasElgibilityCallbackResponse__c>();
            TramasElgibilityCallbackResponse__c tec = new TramasElgibilityCallbackResponse__c();
			tec.Name = 'TMBatchCallback';
			tec.TranasactionId__c = '5a1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Correlation_ID__c = 'pa1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Product_Basket__c = basket.id;
			tec.Type__c = 'TM1';
            tec.Product_Configuration__c = pcList[0].id;
            responseList.add(tec);
            TramasElgibilityCallbackResponse__c tec1 = new TramasElgibilityCallbackResponse__c();
			tec1.Name = 'TMBatchCallback';
			tec1.TranasactionId__c = '02053fa7-06b4-498f-ac7d-ffa288387a17';
			tec1.Correlation_ID__c = 'pa1d8612-af50-pea3-ae26-0de3c43d6ede';
			tec1.Product_Basket__c = basket.id;
			tec1.Type__c = 'Execution Error';
            tec1.Error_code__c = 'TM4011';
            tec1.Product_Configuration__c = pcList[0].id;
			responseList.add(tec1);
            insert responseList;  
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeNguc(basket.id,'TM2',System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap.tramasErrorCode=='Success', true,'Success');
		} 
       @isTest static void getTramsErrorCodeNgucErrorTM0(){
         cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			 String attachbody='{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"transitionId":"5a1d8612-af50-4ea3-ae26-0de3c43d6ede","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679399","serviceExtensionFrom":"0749679300","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679300","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679479","serviceExtensionFrom":"0749679400","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679400","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679599","serviceExtensionFrom":"0749679500","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679500","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740924R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true},{"transitionId":"02053fa7-06b4-498f-ac7d-ffa288387a17","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679799","serviceExtensionFrom":"0749679700","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679700","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679199","serviceExtensionFrom":"0749679100","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679100","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740929R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true}],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":true}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","FNN":null,"Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}';
        	Attachment attach=TestDataFactory.generateAttachment( 'TransitionDataNgUc.json',attachbody , pcList[0].id);
			List<TramasElgibilityCallbackResponse__c> responseList = new List<TramasElgibilityCallbackResponse__c>();
            TramasElgibilityCallbackResponse__c tec = new TramasElgibilityCallbackResponse__c();
			tec.Name = 'TMBatchCallback';
			tec.TranasactionId__c = '5a1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Correlation_ID__c = 'pa1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Product_Basket__c = basket.id;
			tec.Type__c = 'TM0 Execution Error';
            tec.Product_Configuration__c = pcList[0].id;
            responseList.add(tec);
            insert responseList;  
			Test.startTest();  
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCodeNguc(basket.id,'TM2',System.now());
			System.debug('errorWrap: '+errorWrap);
			Test.stopTest();
			System.assertEquals(errorWrap.executiontype =='TM0 Execution Error', true,'Error');                               
      }
      @isTest static void getTramsErrorCodeMobileTm0(){
			cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id];
			MobileTramasElgibility__c tme = new MobileTramasElgibility__c();
			tme.Name = 'MobileTramasElgibility';
			tme.Product_Configuration__c = pcList[0].id;
			tme.Product_Basket__c = basket.id;
			tme.Type__c = 'TM0 Execution Error';
			insert tme; 
			Test.startTest(); 
			NumberReservationTM2CallOut.ErrorWrapper errorWrap = NumberReservationTM2CallOut.getTramsErrorCode('Mobile',basket.id,'TM2',System.now());
			Test.stopTest();
			System.assertEquals(errorWrap.executiontype=='TM0 Execution Error', true,'Success');
		}
/*************************************************************************************************
Name        : getserviceidTest
Description : get serviceid
Author      : Kalashree Borgaonkar
Story       : EDGE-203928
***************************************************************************************************/ 
        @isTest static void getserviceidTest(){
            Test.startTest();
            String serviceid = NumberReservationTM2CallOut.getserviceid('-','61423456789');
            Test.stopTest();
            System.assertEquals(serviceid=='61423456789', true,'Success');
        }   
/*************************************************************************************************
Name        : getserviceidRangeTest
Description : get Range
Author      : Kalashree Borgaonkar
Story       : EDGE-203928
***************************************************************************************************/ 
         @isTest static void getserviceidRangeTest(){
            Test.startTest();
            String serviceid = NumberReservationTM2CallOut.getserviceid('61423456701-61423456710','61423456789');
            Test.stopTest();
            System.assertEquals(serviceid=='61423456701-61423456710', true,'Success');
        }   
 /*************************************************************************************************
Name        : checkforNumberAssignmentTest
Description : checkforNumberAssignmentTest - true
Author      : Kalashree Borgaonkar
Story       : EDGE-203928
***************************************************************************************************/ 
            @isTest static void checkforNumberAssignmentTest(){
                List<String> serviceIdList = new List<String>{'61411111111'};
                cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
				System.debug('basket: '+basket);                    
                List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id];
                System.debug('basket: '+basket);
                Number__c num1 = TestUtil.createNumber('61411111111',basket.id,null);
                num1.Product_Configuration__c = pcList[0].id;
                insert num1;
                Test.startTest();
                Map<String,Boolean> serviceTogreyMap =  NumberReservationTM2CallOut.checkforNumberAssignment(basket.id,serviceIdList);
                Test.stopTest();
                System.assertEquals(serviceTogreyMap.get('61411111111'), true,'Greyed out');
            }    
/*************************************************************************************************
Name        : checkforNumberAssignmentTest
Description : checkforNumberAssignmentTest - true
Author      : Kalashree Borgaonkar
Story       : EDGE-203928
***************************************************************************************************/ 
      @isTest static void checkforNumberAssignmentFalseTest(){
          List<String> serviceIdList = new List<String>{'61411111111'};
          cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
          System.debug('basket: '+basket);                    
          List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id];
          System.debug('basket: '+basket);
          Number__c num1 = TestUtil.createNumber('61411111111',basket.id,null);
          //num1.Product_Configuration__c = pcList[0].id;
          insert num1;
          Test.startTest();
          Map<String,Boolean> serviceTogreyMap =  NumberReservationTM2CallOut.checkforNumberAssignment(basket.id,serviceIdList);
          Test.stopTest();
          System.assertEquals(serviceTogreyMap.get('61411111111'), false,'Not Greyed out');
       } 
/*************************************************************************************************
Name        : populateAssignedToinLegacyTableTest
Description : populateAssignedToinLegacyTableTest - true
Author      : Aishwarya
Story       : DIGI-1944
***************************************************************************************************/ 
@isTest static void populateAssignedToinLegacyTableTest(){
                List<String> serviceIdList = new List<String>{'61411111111'};
                cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
				System.debug('basket: '+basket);                    
                List<cscfga__Product_Configuration__c> pcList = [select id,Name,OfferName__c,cssdm__solution_association__r.Name,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id];
                System.debug('pcList: '+pcList);
                Number__c num1 = TestUtil.createNumber('61411111111',basket.id,null);
                num1.Product_Configuration__c = pcList[0].id;
                insert num1;
                Test.startTest();
                Map<String,String> serviceToAssignedto =  NumberReservationTM2CallOut.populateAssignedToinLegacyTable(basket.id,serviceIdList);
                Test.stopTest();
                 //system.debug('serviceToAssignedto***' +serviceToAssignedto);
                System.assertEquals(serviceToAssignedto.get('61411111111'),'Enterprise Mobility Plan | test config');
            }                                       
/*************************************************************************************************
Name        : updateTransitionJson
Description : update transition json after call callback responses have been received
Author      : Kalashree Borgaonkar
Story       : EDGE-203022
***************************************************************************************************/ 
      /*  @isTest static void updateTransitionJsonTest(){
         	cscfga__Product_Basket__c basket= [SELECT id ,name,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name='Retrigger Basket'];
			Set<id> basketid = new Set<id>(); 
            basketid.add(basket.id);
            List<cscfga__Product_Configuration__c> pcList = [select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basket.id]; 
			 String attachbody='{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"transitionId":"5a1d8612-af50-4ea3-ae26-0de3c43d6ede","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679399","serviceExtensionFrom":"0749679300","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679300","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679479","serviceExtensionFrom":"0749679400","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679400","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679599","serviceExtensionFrom":"0749679500","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679500","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740924R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true},{"transitionId":"02053fa7-06b4-498f-ac7d-ffa288387a17","tramasErrorCode":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679799","serviceExtensionFrom":"0749679700","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679700","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null},{"trunk_capacity":null,"tramasErrorCode":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"tramasErrorCode":null,"serviceExtensionTo":"0749679199","serviceExtensionFrom":"0749679100","Reserve_status":"Completed","Reason":"","eligibilityStatus":"Eligible","eligibilityReason":"","checkReserved":true}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679100","service_association_role":"service","Reserved_ranges":null,"Reserve_status":"Completed","replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":"","plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null,"eligibilityStatus":null,"eligibilityReason":"","Eligibility_status":"Eligible","directory_listing":null,"devices":null,"device_lease_contract_indicator":null,"contract_term":null,"contract_remaining_term":null,"calling_line_identifier":null,"association_type":null,"aro_indicator":null,"accountDetails":null}],"groupId":"N7740929R","EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":null,"checkValue":true}],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":true}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","FNN":null,"Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}';
        	Attachment attach=TestDataFactory.generateAttachment( 'TransitionDataNgUc.json',attachbody , pcList[0].id);
			List<TramasElgibilityCallbackResponse__c> responseList = new List<TramasElgibilityCallbackResponse__c>();
            TramasElgibilityCallbackResponse__c tec = new TramasElgibilityCallbackResponse__c();
			tec.Name = 'TMBatchCallback';
			tec.TranasactionId__c = '5a1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Correlation_ID__c = 'pa1d8612-af50-4ea3-ae26-0de3c43d6ede';
			tec.Product_Basket__c = basket.id;
			tec.Type__c = 'TM2';
            tec.Product_Configuration__c = pcList[0].id;
            responseList.add(tec);
            insert responseList;  
             String attachbody1='{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/5a1d8612-af50-4ea3-ae26-0de3c43d6ede"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"5a1d8612-af50-4ea3-ae26-0de3c43d6ede","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"completed","results":[]}],"metadata":{"salesforceId":"00P2N000003DadnUAC","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        	System.debug('Techid: '+tec.id);
            Attachment attach1=new Attachment(  
                    Name = 'EligibilityResults.txt',
                    body = Blob.valueOf(attachbody1),
                    parentId = tec.id
                  );
            insert attach1;
			List<Attachment> attList   = [SELECT id,Body,parentid,name FROM Attachment];
           
            Test.startTest();  
			 NumberReservationTM2CallOut.updateTransitionJson(basketid);
			Test.stopTest();
			System.assertEquals(attach1.body!=null, true,'Error');                               
      }*/
}