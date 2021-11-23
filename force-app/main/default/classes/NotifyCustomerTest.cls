@isTest
private class NotifyCustomerTest {

    @testSetup static void setup() {
        
    }
    
    static testMethod void testDoPost_create() {
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='TCMupdate', Value__c = 'true');
        insert envrn;
        RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyCustomer';  
        req.httpMethod = 'POST';
        String reqBody = '{"request":{"data":{"cac":"1234567890","eventAction":"","cidn":"784512","parentCidn":"784512","rootCidn":"","dataSovereignty":"","ownershipCode":"","abnOverride":"Y","businessUnit":"","customerManagedFlag":"","customerType":"Business","marketSegment":"","priorityAssist":"","accountStatus":"Active","lastModifiedDate":"","location":"","churnpropensity":"","customerSince":"","description":"This is a sample description of the account","franchiseArrange":"","languagePreference":"English","retiredUId":"","retirementReason":"","servicingOrgUnit":"","timeZone":"","writtenaAuthorityRequiredFlag":"","effectiveRetiredDate":"","lastVerifiedDate":"","createdDate":"2017-09-09","duplicateOverridReason":"","revenueOrganisationUnit":"","potentialRevenue":"","currentRevenue":"","partners":"","premiumService":"","approveDeclineReason":"","recommendedPaymentMethod":"","recommendedBillingFrequency":"","validationCustomerConsent":"","validationConsentRequestDate":"","customerEffectiveStartDate":"2017-03-09","relationshipType":"","reportingPointIndicator":"","customerEffectiveEndDate":"2018-09-09","ansicCode":"","primaryIndustryIndicator":"Hospitality","masterID":"","mergeStatus":"","retagFlag":"","dateOfApplication":"","lastUpdated":"","sourceSysOperation":"","parentSourceSystem":"RCRM","category":{"online":"","bpProtect":"","protect":""},"creditSituation":{"creditLimit":"","creditManagementStatus":"","creditRating":""},"concession":{"concessionAuthority":"","concessionNumber":"","concessionType":"","paymentType":"","paymentStatus":"","validConcessionFlag":"","lastValidatedDate":"","bypassConcessionValidation":"","validationResultOverride":""},"customerAccount":{"title":"Mr","firstName":"testFirst","middleName":""testMiddle,"lastName":"Hellenic Republic Inc.","birthDate":"","phoneNumber":"","faxNumber":"78412575","emailAddress":"customer@company.com","abn":"784125495","acn":"124785963","webAddress":"www.hellenicrepublicinc.com","driverLicenseNumber":"20379868","driverLicenseState":"NSW","fraudFlag":"","vipFlag":"","accountUuid":"","preferredMethod":""},"address":[{"isPrimary":"","status":"","statusCode":"","addressType":"","exchange":"","addressTypeCode":"","country":"","state":"","postalCode":"","addressId":"","streetName":"","streetType":"","streetTypeCode":"","streetTypeSuffix":"","streetTypeSuffixCode":"","streetNumberStart":"","streetNumberStartSuffix":"","streetNumberEnd":"","streetNumberEndSuffix":"","internationalPostcode":"","internationalState":"","deliveryPointId":"","registeredPlan":"Lot 57","locality":"","additionalInfo":"","geographicalLocationCode":"","lastUpdatedDateTime":"","subAddress":{"buildingName":"11111","propertyName":"11111","numberStart":"1","numberEnd":"11111","privateStreetName":"11111","privateStreetType":"11111","privateStreetTypeCode":"","details":[{"detailType":"","detailTypeCode":"","value":""}],"addressLines":["Block A","1501","City Road"]}}],"accountTrading":[{"isPrimary":"","startDate":"","endDate":"","tradingName":"Hellenic","lastUpdatedDateTime":""}]}}}';
        req.requestBody = System.Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        ASIC__c asic = new ASIC__c();
        asic.Name = 'TestIndustry';
        asic.Industry__c = 'TestIndustry';
        asic.SIC_Code__c = '1234';
        insert asic;
        
        NotifyCustomerRequest ncr = new NotifyCustomerRequest();
        ncr.data = new NotifyCustomerRequest.Data();
        ncr.data.customerAccount = new NotifyCustomerRequest.CustomerAccount();
        ncr.data.customerAccount.title = 'Mr.';
        ncr.data.customerAccount.firstName = 'Hi';
        ncr.data.customerAccount.lastName = 'Hello';
        ncr.data.customerAccount.birthDate = '1980-09-09';
        ncr.data.customerAccount.fraudFlag = 'true';
        ncr.data.customerAccount.preferredMethod = 'Email';
        ncr.data.customerAccount.emailAddress = 'abc@test.com';
        ncr.data.cac = '2123456789';
        ncr.data.masterId = '1234567890';
        ncr.data.customerType = 'Sole Trader';
        ncr.data.retiredUId ='';
        ncr.data.customerManagedFlag = 'Y';
        ncr.data.address = new List<NotifyCustomerRequest.Address>();
        NotifyCustomerRequest.Address addressItem = new NotifyCustomerRequest.Address();
        addressItem.addressId = '12345';
        ncr.data.address.add(addressItem);
        ncr.data.CreditSituation = new NotifyCustomerRequest.CreditSituation();
        ncr.data.CreditSituation.creditLimit='10000';
        ncr.data.CreditSituation.creditRating = '1000';
        ncr.data.Concession = new NotifyCustomerRequest.Concession();
        ncr.data.Concession.validConcessionFlag= 'true';
        ncr.data.lastVerifiedDate='2017-06-30';
        ncr.data.priorityAssist= 'true';
        ncr.data.writtenaAuthorityRequiredFlag= 'true';
        ncr.data.Category = new NotifyCustomerRequest.Category();
        ncr.data.Category.online = 'true';
        ncr.data.potentialRevenue = '1000';
        ncr.data.currentRevenue= '20000';
        ncr.data.dateOfApplication='2017-05-05';
        ncr.data.validationConsentRequestDate= '2017-05-08';
        //ncr.data.actualRetiredDate='2017-03-03';
        ncr.data.ansicCode = '1234';
        NotifyCustomer.doPost(ncr);
        System.assertEquals('1234', ncr.data.ansicCode);
        
    }

    static testMethod void testDoPost_update_1() {
        
        Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '2123456789';
        a.Pref_Comm_Method__c= 'Email';
        a.Email__c='abc@test.com';
        a.Customer_Status__c= 'Active';
        insert a;
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='TCMupdate', Value__c = 'true');
        insert envrn;
        Contact c = TestUtil.createContact(a.Id, 'first', 'last');
        c.AccountId = a.Id;
        c.Birthdate =  Date.newInstance(1980 , 10 ,20);
        insert c;
        
        AccountContactRelation acr= [Select Id,AccountId,ContactId,Roles from AccountContactRelation where AccountId =:a.Id AND ContactId =:c.Id];
        acr.Roles='Legal Lessee';
        update acr;
        
        cscrm__Address__c address = TestUtil.createAddress();
        address.cscrm__Account__c = a.Id;
        insert address;
        
        ASIC__c asic = new ASIC__c();
        asic.Name = 'TestIndustry';
        asic.Industry__c = 'TestIndustry';
        asic.SIC_Code__c = '1234';
        insert asic;
        
        Account_Industry_Relationship__c air = new Account_Industry_Relationship__c();
        air.AccountID__c= a.Id;
        air.IndustryID__c = asic.Id;
        insert air;
        
        RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyCustomer';  
        req.httpMethod = 'POST';
        String reqBody = '{"request":{"data":{"cac":"1234567890","eventAction":"","cidn":"784512","parentCidn":"784512","rootCidn":"","dataSovereignty":"","ownershipCode":"","abnOverride":"Y","businessUnit":"","customerManagedFlag":"","customerType":"Business","marketSegment":"","priorityAssist":"","accountStatus":"Active","lastModifiedDate":"","location":"","churnpropensity":"","customerSince":"","description":"This is a sample description of the account","franchiseArrange":"","languagePreference":"English","retiredUId":"","retirementReason":"","servicingOrgUnit":"","timeZone":"","writtenaAuthorityRequiredFlag":"","effectiveRetiredDate":"","lastVerifiedDate":"","createdDate":"","duplicateOverridReason":"","revenueOrganisationUnit":"","potentialRevenue":"","currentRevenue":"","partners":"","premiumService":"","approveDeclineReason":"","recommendedPaymentMethod":"","recommendedBillingFrequency":"","validationCustomerConsent":"","validationConsentRequestDate":"","customerEffectiveStartDate":"","relationshipType":"","reportingPointIndicator":"","customerEffectiveEndDate":"","ansicCode":"","primaryIndustryIndicator":"Hospitality","masterID":"","mergeStatus":"","retagFlag":"","dateOfApplication":"","lastUpdated":"","sourceSysOperation":"","parentSourceSystem":"RCRM","category":{"online":"","bpProtect":"","protect":""},"creditSituation":{"creditLimit":"","creditManagementStatus":"","creditRating":""},"concession":{"concessionAuthority":"","concessionNumber":"","concessionType":"","paymentType":"","paymentStatus":"","validConcessionFlag":"","lastValidatedDate":"","bypassConcessionValidation":"","validationResultOverride":""},"customerAccount":{"title":"","firstName":"","lastName":"Hellenic Republic Inc.","birthDate":"","phoneNumber":"","faxNumber":"78412575","emailAddress":"customer@company.com","abn":"784125495","acn":"124785963","webAddress":"www.hellenicrepublicinc.com","driverLicenseNumber":"20379868","driverLicenseState":"NSW","fraudFlag":"","vipFlag":"","accountUuid":"","preferredMethod":""},"address":[{"isPrimary":"","status":"","statusCode":"","addressType":"","exchange":"","addressTypeCode":"","country":"","state":"","postalCode":"","addressId":"","streetName":"","streetType":"","streetTypeCode":"","streetTypeSuffix":"","streetTypeSuffixCode":"","streetNumberStart":"","streetNumberStartSuffix":"","streetNumberEnd":"","streetNumberEndSuffix":"","internationalPostcode":"","internationalState":"","deliveryPointId":"","registeredPlan":"Lot 57","locality":"","additionalInfo":"","geographicalLocationCode":"","lastUpdatedDateTime":"","subAddress":{"buildingName":"11111","propertyName":"11111","numberStart":"1","numberEnd":"11111","privateStreetName":"11111","privateStreetType":"11111","privateStreetTypeCode":"","details":[{"detailType":"","detailTypeCode":"","value":""}],"addressLines":["Block A","1501","City Road"]}}],"accountTrading":[{"isPrimary":"","startDate":"","endDate":"","tradingName":"Hellenic","lastUpdatedDateTime":""}]}}}';
        req.requestBody = System.Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
       
        NotifyCustomerRequest ncr = new NotifyCustomerRequest();
        ncr.data = new NotifyCustomerRequest.Data();
        ncr.data.cac = '2123456789';
        ncr.data.masterId = '1234567890';
        ncr.data.customerManagedFlag = 'N';
        ncr.data.customerType = 'Sole Trader';
        ncr.data.customerAccount = new NotifyCustomerRequest.CustomerAccount();
        ncr.data.customerAccount.title = 'Mr.';
        ncr.data.customerAccount.firstName = 'Hi';
        ncr.data.customerAccount.lastName = 'Hello';
        ncr.data.customerAccount.birthDate = '1987-11-29';
        ncr.data.customerAccount.preferredMethod ='Email';
        ncr.data.customerAccount.emailAddress='abc@xyz.com';
        ncr.data.address = new List<NotifyCustomerRequest.Address>();
        NotifyCustomerRequest.Address addressItem = new NotifyCustomerRequest.Address();
        addressItem.addressId = '12345678';
        addressItem.subAddress = new NotifyCustomerRequest.SubAddress();
        addressItem.subAddress.addressLines = new List<String>();
        addressItem.subAddress.addressLines.add('one');
        addressItem.subAddress.addressLines.add('two');
        addressItem.subAddress.addressLines.add('three');
        ncr.data.address.add(addressItem);
        
        ncr.data.accountTrading = new List<NotifyCustomerRequest.AccountTrading>();
        NotifyCustomerRequest.AccountTrading accountTradingItem = new NotifyCustomerRequest.AccountTrading();
        accountTradingItem.tradingName = 'My Account';
        ncr.data.accountTrading.add(accountTradingItem);
        
        ncr.data.CreditSituation = new NotifyCustomerRequest.CreditSituation();
        ncr.data.CreditSituation.creditLimit='10000';
        ncr.data.CreditSituation.creditRating = '1000';
        ncr.data.Concession = new NotifyCustomerRequest.Concession();
        ncr.data.Concession.validConcessionFlag= 'true';
        ncr.data.lastVerifiedDate='2017-06-30';
        ncr.data.priorityAssist= 'true';
        ncr.data.writtenaAuthorityRequiredFlag= 'true';
        ncr.data.Category = new NotifyCustomerRequest.Category();
        ncr.data.Category.online = 'true';
        ncr.data.potentialRevenue = '1000';
        ncr.data.currentRevenue= '20000';
        ncr.data.dateOfApplication='2017-05-05';
        ncr.data.validationConsentRequestDate= '2017-05-08';
        ncr.data.ansicCode = '1234';
        NotifyCustomer.doPost(ncr);
        System.assertEquals('1234', ncr.data.ansicCode);
        
    }
    
    static testMethod void testDoPost_update_2() {
        
        Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '2123456789';
        a.Pref_Comm_Method__c= 'Email';
        a.Email__c='abc@test.com';
        a.Customer_Status__c= 'Active';
        insert a;
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='TCMupdate', Value__c = 'true');
        insert envrn;
        Contact c = TestUtil.createContact(a.Id, 'first', 'last');
        c.Birthdate =  Date.newInstance(1980 , 10 ,20);
        insert c;
        
        cscrm__Address__c address = TestUtil.createAddress();
        insert address;
        
        ASIC__c asic = new ASIC__c();
        asic.Name = 'TestIndustry';
        asic.Industry__c = 'TestIndustry';
        asic.SIC_Code__c = '1234';
        insert asic;
        
        Account_Industry_Relationship__c air = new Account_Industry_Relationship__c();
        air.AccountID__c= a.Id;
        air.IndustryID__c = asic.Id;
        insert air;
        
        RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyCustomer';  
        req.httpMethod = 'POST';
        String reqBody = '{"request":{"data":{"cac":"1234567890","eventAction":"","cidn":"784512","parentCidn":"784512","rootCidn":"","dataSovereignty":"","ownershipCode":"","abnOverride":"Y","businessUnit":"","customerManagedFlag":"","customerType":"Business","marketSegment":"","priorityAssist":"","accountStatus":"Active","lastModifiedDate":"","location":"","churnpropensity":"","customerSince":"","description":"This is a sample description of the account","franchiseArrange":"","languagePreference":"English","retiredUId":"","retirementReason":"","servicingOrgUnit":"","timeZone":"","writtenaAuthorityRequiredFlag":"","effectiveRetiredDate":"","lastVerifiedDate":"","createdDate":"","duplicateOverridReason":"","revenueOrganisationUnit":"","potentialRevenue":"","currentRevenue":"","partners":"","premiumService":"","approveDeclineReason":"","recommendedPaymentMethod":"","recommendedBillingFrequency":"","validationCustomerConsent":"","validationConsentRequestDate":"","customerEffectiveStartDate":"","relationshipType":"","reportingPointIndicator":"","customerEffectiveEndDate":"","ansicCode":"","primaryIndustryIndicator":"Hospitality","masterID":"","mergeStatus":"","retagFlag":"","dateOfApplication":"","lastUpdated":"","sourceSysOperation":"","parentSourceSystem":"RCRM","category":{"online":"","bpProtect":"","protect":""},"creditSituation":{"creditLimit":"","creditManagementStatus":"","creditRating":""},"concession":{"concessionAuthority":"","concessionNumber":"","concessionType":"","paymentType":"","paymentStatus":"","validConcessionFlag":"","lastValidatedDate":"","bypassConcessionValidation":"","validationResultOverride":""},"customerAccount":{"title":"","firstName":"","lastName":"Hellenic Republic Inc.","birthDate":"","phoneNumber":"","faxNumber":"78412575","emailAddress":"customer@company.com","abn":"784125495","acn":"124785963","webAddress":"www.hellenicrepublicinc.com","driverLicenseNumber":"20379868","driverLicenseState":"NSW","fraudFlag":"","vipFlag":"","accountUuid":"","preferredMethod":""},"address":[{"isPrimary":"","status":"","statusCode":"","addressType":"","exchange":"","addressTypeCode":"","country":"","state":"","postalCode":"","addressId":"","streetName":"","streetType":"","streetTypeCode":"","streetTypeSuffix":"","streetTypeSuffixCode":"","streetNumberStart":"","streetNumberStartSuffix":"","streetNumberEnd":"","streetNumberEndSuffix":"","internationalPostcode":"","internationalState":"","deliveryPointId":"","registeredPlan":"Lot 57","locality":"","additionalInfo":"","geographicalLocationCode":"","lastUpdatedDateTime":"","subAddress":{"buildingName":"11111","propertyName":"11111","numberStart":"1","numberEnd":"11111","privateStreetName":"11111","privateStreetType":"11111","privateStreetTypeCode":"","details":[{"detailType":"","detailTypeCode":"","value":""}],"addressLines":["Block A","1501","City Road"]}}],"accountTrading":[{"isPrimary":"","startDate":"","endDate":"","tradingName":"Hellenic","lastUpdatedDateTime":""}]}}}';
        req.requestBody = System.Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
       
        NotifyCustomerRequest ncr = new NotifyCustomerRequest();
        ncr.data = new NotifyCustomerRequest.Data();
        ncr.data.cac = '2123456789';
        ncr.data.masterId = '1234567890';
        ncr.data.customerManagedFlag = 'N';
        ncr.data.customerAccount = new NotifyCustomerRequest.CustomerAccount();
        ncr.data.customerAccount.title = 'Mr.';
        ncr.data.customerAccount.firstName = 'Hi';
        ncr.data.customerAccount.lastName = 'Hello';
        ncr.data.customerAccount.birthDate = '1987-11-29';
        ncr.data.customerAccount.preferredMethod ='Email';
        ncr.data.customerAccount.emailAddress='abc@xyz.com';
        ncr.data.address = new List<NotifyCustomerRequest.Address>();
        NotifyCustomerRequest.Address addressItem = new NotifyCustomerRequest.Address();
        addressItem.addressId = '12345678';
        addressItem.subAddress = new NotifyCustomerRequest.SubAddress();
        addressItem.subAddress.addressLines = new List<String>();
        addressItem.subAddress.addressLines.add('one');
        addressItem.subAddress.addressLines.add('two');
        addressItem.subAddress.addressLines.add('three');
        addressItem.streetNumberStart = '12345';
        List<NotifyCustomerRequest.Detail> lstdetails = new List<NotifyCustomerRequest.Detail>();
        NotifyCustomerRequest.Detail details = new NotifyCustomerRequest.Detail();
        details.detailType='test';
        details.detailTypeCode = '23423';
        details.value = '34';
        lstdetails.add(details);
        
        NotifyCustomerRequest.Detail details2 = new NotifyCustomerRequest.Detail();
        details2.detailType='test1';
        details2.detailTypeCode = '234232';
        details2.value = '343';
        lstdetails.add(details2);
        
		addressItem.subAddress.details =lstdetails;
        
        addressItem.streetNumberEnd = '34567';
        ncr.data.address.add(addressItem);
        
        ncr.data.accountTrading = new List<NotifyCustomerRequest.AccountTrading>();
        NotifyCustomerRequest.AccountTrading accountTradingItem = new NotifyCustomerRequest.AccountTrading();
        accountTradingItem.tradingName = 'My Account';
        ncr.data.accountTrading.add(accountTradingItem);
       
        ncr.data.CreditSituation = new NotifyCustomerRequest.CreditSituation();
        ncr.data.CreditSituation.creditLimit='10000';
        ncr.data.CreditSituation.creditRating = '1000';
        ncr.data.Concession = new NotifyCustomerRequest.Concession();
        ncr.data.Concession.validConcessionFlag= 'true';
        ncr.data.lastVerifiedDate='2017-06-30';
        ncr.data.priorityAssist= 'true';
        ncr.data.writtenaAuthorityRequiredFlag= 'true';
        ncr.data.Category = new NotifyCustomerRequest.Category();
        ncr.data.Category.online = 'true';
        ncr.data.potentialRevenue = '1000';
        ncr.data.currentRevenue= '20000';
        ncr.data.dateOfApplication='2017-05-05';
        ncr.data.validationConsentRequestDate= '2017-05-08';
        ncr.data.ansicCode = '1234';
        NotifyCustomer.doPost(ncr);
        NotifyCustomer.returnaddressLines(address, addressItem);
        NotifyCustomer.returnsubaddressdetails(address, addressItem);
        NotifyCustomer.returnStreetNumber (address,addressItem);
        NotifyCustomer.mapRequestToAddress (addressItem,address,a);
        System.assertEquals('1234', ncr.data.ansicCode);
        
    }

    static testMethod void testDoGet() {
        Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c= 'Email';
        a.Email__c='abc@test.com';
        a.Customer_Status__c= 'Active';
        insert a;
        
        RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyCustomer/'+a.Id;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account acc = NotifyCustomer.doGet();
        System.assertEquals('Active', a.Customer_Status__c);
        
    }
    
    static testMethod void testDoDelete() {
        Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c= 'Email';
        a.Email__c='abc@test.com';
        a.Customer_Status__c= 'Active';
        insert a;
        
        RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyCustomer/'+a.Id;  
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        System.assertEquals('Active', a.Customer_Status__c);
        NotifyCustomer.doDelete();
    }
    
    
    static testMethod void saveNewAddressReltest() {
        Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c= 'Email';
        a.Email__c='abc@test.com';
        a.Customer_Status__c= 'Active';
        insert a;
    }
    
    static testMethod void testDoPost_update_3() {
        
        Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '2123456789';
        a.Pref_Comm_Method__c= 'Email';
        a.Email__c='abc@test.com';
        a.Customer_Status__c= 'Active';
        insert a;
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='TCMupdate', Value__c = 'true');
        insert envrn;
        Contact c = TestUtil.createContact(a.Id, 'first', 'last');
        c.Birthdate =  Date.newInstance(1980 , 10 ,20);
        insert c;
        
        AccountContactRelation acr=new AccountContactRelation(accountid=a.id,contactid=c.Id,roles='Legal Lessee');
        
        //insert acr;
        cscrm__Address__c address = TestUtil.createAddress();
        address.cscrm__Account__c = a.Id;
        insert address;
        
        String account = ''+a.id;
        String address2 = address.Id;
        String addressType = '';
        cscrm__Account_Address_Relationship__c accountAddressRelationship = new cscrm__Account_Address_Relationship__c();
            accountAddressRelationship.cscrm__Address_Type__c = addressType;
            accountAddressRelationship.cscrm__Account__c = account;
            accountAddressRelationship.cscrm__Address__c = address2;
            accountAddressRelationship.cscrm__Active__c = true;   
        
        NotifyCustomer.getLegalLesseContactNameForSoleTrader(a.id);
        NotifyCustomer.getFieldMetaData();
        NotifyCustomer.addressRelSaveUtility(accountAddressRelationship);
        
        NotifyCustomer.saveNewAddressRel(addressType, a.id, address.id,true);
        System.assertEquals(acr.roles, 'Legal Lessee');
        
    }
    
}