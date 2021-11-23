@RestResource(urlMapping='/NotifyContact/*')
global with sharing class NotifyContact{
    
    @HttpDelete
    global static String doDelete() {
        Logger log = Logger.getLogger('NotifyContactDelete');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId];
        delete contact;
        log.logRequest(string.valueOf(req.requestURI), true);
        log.logResponse('Contact : ' + contactId + ' successfully deleted.' ,true);
        return 'Contact : ' + contactId + ' successfully deleted.';
    }
    
    // Retrieve an existing contact
    @HttpGet
    global static Contact doGet() {
        Logger log = Logger.getLogger('NotifyContactGet');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Contact response = getExistingContact(contactId);
        log.logRequest(string.valueOf(req.requestURI), true);
        log.logResponse(response != null? string.valueOf(response) : 'No records found' ,true);
        return response;
    }
    
    @HttpPost
    global static NotifyContactResponse doPost(NotifyContactRequest request) {
        /*************************************************************
		EDGE: 67176
		Author: Ila Anmol Verma
		Description: Custom Setting to ignore TCM updates for Address	
		****************************************************************/
        String flag = EnvironmentVariable__c.getValues('TCMupdate').Value__c;
		if(flag=='True'){
        NotifyContactResponse response = new NotifyContactResponse();
        Logger2 logger = Logger2.getLogger('NotifyContactPost'); //For logging error
        try{
            Contact contact = null;
            String operation = '';
            if(request != null && request.data != null){
                if(String.isNotBlank(request.data.contactId)){
                    contact = getExistingContact(request.data.contactId);
                    /*Keeping Dormant
					//EDGE - 35520
                    if(isEndateChangedAndFCRPresent(request,Contact)){
                        logger.logMessages(JSON.serialize(request), '', '', 'Business', '', System.Label.TCM_ACR_end_date_error, TRUE, false,200,'',contact.uuid__C,'Integration');
                        response = setErrorResponse(response,contact,System.Label.TCM_ACR_end_date_error);
                        return response;
                    }
					*/
                }
                if(contact == null && String.isNotBlank(request.data.id)){
                    contact = getExistingContactByUUID(request.data.id);
                      /*Keeping Dormant
					//EDGE-29842 (AC10): Added
                    //system.debug('request.data.status > ' + request.data.status);
                    //system.debug('isActiveACRPresentForContact(contact) > ' + isActiveACRPresentForContact(contact));
                    if(contact != null && request.data.status == 'Inactive' && isActiveACRPresentForContact(contact)){
                        //system.debug('System.Label.TCM_InactiveContact_ActiveACR_ErrorMessage >> ' + System.Label.TCM_InactiveContact_ActiveACR_ErrorMessage);
                        logger.logMessages(JSON.serialize(request), JSON.serialize(response), 'Business', '', System.Label.TCM_InactiveContact_ActiveACR_ErrorMessage, '', false, false,200,'','UUID','Business');
                        response = setErrorResponse(response,contact,System.Label.TCM_InactiveContact_ActiveACR_ErrorMessage);
                        return response;
                    }else{
                        //EDGE - 35520
                        if(isEndateChangedAndFCRPresent(request,Contact)){
                            logger.logMessages(JSON.serialize(request), '', '', 'Business', '', System.Label.TCM_ACR_end_date_error, TRUE, false,200,'',contact.uuid__C,'Integration');
                            response = setErrorResponse(response,contact,System.Label.TCM_ACR_end_date_error);
                            return response;
                        }  
                    }
                    system.debug('passed over ');
					*/
                }
                if(contact != null && contact.Id != null && String.isNotBlank(request.data.id)){
                    operation = 'updated';
                    contact = mapRequestToContact(request, contact);
                    update contact;
                    if(contact.AccountId != null){
                        insertAccountContactRelation(request,contact);
                    }
                    updateHomeOfficeAddress(request.data,contact);
                } else if(request.data.status != null && request.data.status != 'Inactive'){
                    operation = 'created';
                    contact = mapRequestToContact(request, contact);
                    contact.AccountId = accountRecordId(request);
                    upsert contact UUID__c;
                    if(contact.AccountId != null){
                        insertAccountContactRelation(request,contact);
                    }
                    addHomeOfficeAddress(request.data,contact);
                }
            }
            if(contact != NULL){
                response.Data = contact.id;
                response.Status = 'Success';
                response.StatusCode = 200;
                response.ErrorCode = null;
                response.Message = 'Contact ' + operation;
            }
        } catch(DmlException e){
            //EDGE-2331
            //Logger2 logger = Logger2.getLogger('NotifyContactPost');
            response.Status = 'Success';
            response.StatusCode = 200;
            response.ErrorCode = TCMBusinessErrorCode.getInstance().getCode(e.getMessage().toLowerCase());
            response.Message = 'Contact ' + e.getMessage();
            logger.logMessages(JSON.serialize(request), JSON.serialize(response), e.getStackTraceString(), 'Business', TCMBusinessErrorCode.getInstance().getCode(e.getMessage().toLowerCase()), e.getMessage(), true, false,response.StatusCode,'',request.Data.id,TCMCustomerContactConstants.TCMERRORCODE_FAILURE);
        } finally {
            logger.logMessages(JSON.serialize(request), JSON.serialize(response), '', '', '', '', false, false, response.StatusCode,null,request.Data.id, null);
            logger.exitLogger();
        	}
        return response;
        }else
        {		// P2OB-15034 Allow only Contact UUID to be updated as part of NotifyContact Event
                system.debug('REquest received');
            	NotifyContactResponse response = new NotifyContactResponse();
                Logger2 logger = Logger2.getLogger('NotifyContactPost'); //For logging error
            	system.debug('Request :'+ request);
            	system.debug('Contact Id :'+ request.data.contactId);
            	system.debug('Contact Id :'+ request.Data.id);
                try{
                    Contact contact = null;
                    String operation = '';
                            if(request != null && request.data != null){
                                if(String.isNotBlank(request.data.contactId)){
                                    contact = getExistingContact(request.data.contactId);
                                    }
                                }
                        
                        if(contact != null && contact.Id != null){
                            if(String.isNotBlank(request.data.id)){
                                operation = 'updated';
                                contact.UUID__C = request.Data.id;
                                update contact;
                                
                                response.Data = contact.id;
                                response.Status = 'Success';
                                response.StatusCode = 200;
                                response.ErrorCode = null;
                                response.Message = 'Contact ' + operation;
                                
                            }else{

                                response.Message = 'Contact Missing UUID' ;                                
                            }

                       }
                        
                } catch(DmlException e){
                    response.Status = 'Success';
                    response.StatusCode = 200;
                    response.ErrorCode = TCMBusinessErrorCode.getInstance().getCode(e.getMessage().toLowerCase());
                    response.Message = 'Contact ' + e.getMessage();
                    logger.logMessages(JSON.serialize(request), JSON.serialize(response), e.getStackTraceString(), 'Business', TCMBusinessErrorCode.getInstance().getCode(e.getMessage().toLowerCase()), e.getMessage(), true, false,response.StatusCode,'',request.data.id,TCMCustomerContactConstants.TCMERRORCODE_FAILURE);
                } finally {
                    logger.logMessages(JSON.serialize(request), JSON.serialize(response), '', '', '', '', false, false, response.StatusCode,null,request.data.id, null);
                    logger.exitLogger();
                    }
                return response;
        }
    }
    
    private static void updateHomeOfficeAddress(NotifyContactRequest.Data requestData, Contact contact){
        List<cscrm__Address__c> addresses = getExistingAddresses(contact.Id ,'Office Address');
        //Removed DML inside For loop
        List<cscrm__Address__c> addToUpsert = new List<cscrm__Address__c>();
        if(requestData.businessAddress != null) {
            for(NotifyContactRequest.BusinessAddress addr : requestData.businessAddress) {
                if(addresses != null) {
                    for(cscrm__Address__c address : addresses) {
                        if(address.cscrm__Address_Type__c == 'Office Address'){
                            if(addr.addressId == address.cscrm__External_ID__c) {
                                address = mapRequestToAddress(addr, address, contact);
                                System.debug('!@#$% Upserted address : ' + address);
                                addToUpsert.add(address);
                            } 
                        }
                    }    
                   
                }   
            } 
            //Removed DML inside For loop
             upsert addToUpsert; 
        }
        
        
        List<cscrm__Address__c> peraddresses = getExistingAddresses(contact.Id ,'Home Address');
        //Removed DML inside For loop
        List<cscrm__Address__c> perAddToUpsert = new List<cscrm__Address__c>();
        if(requestData.PersonalAddress != null) {
            for(NotifyContactRequest.PersonalAddress addr : requestData.personalAddress) {
                if(addresses != null) {
                    for(cscrm__Address__c address : peraddresses) {
                        if(address.cscrm__Address_Type__c == 'Home Address'){
                            if(addr.addressId == address.cscrm__External_ID__c) {
                                address = mapRequestToPersonalAddress(addr, address, contact);
                                System.debug('!@#$% Upserted address : ' + address);
                                perAddToUpsert.add(address);
                            } 
                        }
                    }    
                }   
            }    
            //Removed DML inside For loop
            upsert perAddToUpsert;
        }
    }
    
    private static void addHomeOfficeAddress(NotifyContactRequest.Data requestData, Contact contact){
        if(requestData.businessAddress != null) {
            List<cscrm__Address__c> addressList = new List<cscrm__Address__c>();
            for(NotifyContactRequest.BusinessAddress addr : requestData.businessAddress){
                cscrm__Address__c address = mapRequestToAddress(addr, null, contact);
                addressList.add(address);    
            }
            insert addressList;
            addAddress(addressList,'Office Address', contact.Id);
        }
        
        if(requestData.personalAddress != null) {
            List<cscrm__Address__c> addressList = new List<cscrm__Address__c>();
            for(NotifyContactRequest.PersonalAddress addr : requestData.personalAddress){
                cscrm__Address__c address = mapRequestToPersonalAddress(addr, null, contact);
                addressList.add(address);    
            }
            insert addressList;
            addAddress(addressList,'Home Address', contact.Id);
        }
    }
    
    private static void addAddress(List<cscrm__Address__c> addressList, String addressType, Id contact){
        List<cscrm__Contact_Address_Relationship__c> conAddressList = new List<cscrm__Contact_Address_Relationship__c>();
        for(cscrm__Address__c address : addressList){
            cscrm__Contact_Address_Relationship__c conAddress = new cscrm__Contact_Address_Relationship__c();
            conAddress.cscrm__Contact__c = contact;
            conAddress.cscrm__Address_Type__c = addressType;
            conAddress.cscrm__Address__c = address.id;
            conAddressList.add(conAddress);
        }
        insert conAddressList;
    }
    
    private static AccountContactRelation insertAccountContactRelation(NotifyContactRequest req, Contact con){
        AccountContactRelation accR = null;
        List<AccountContactRelation> accRList = [Select id, contactid, AccountId,Contact_Type__c,Contact_Usage__c,Composite_Key__c,Relationship_End_Date__c from AccountContactRelation where contactid =:con.id and AccountId=:con.AccountId];
        if(accRList != null && accRList.size() == 1){
            accR = accRList[0];
            if(req.data.customerAccounts != null && req.data.customerAccounts.size() >0){
                if(req.data.customerAccounts[0].contactRelationship.contactType != NULL 
                   && req.data.customerAccounts[0].contactRelationship.contactType.trim().length() > 0){
                       accR.Roles = req.data.customerAccounts[0].ContactRelationship.contactType;
                   }
                if(req.data.customerAccounts[0].contactRelationship.contactUsage != NULL 
                   && req.data.customerAccounts[0].contactRelationship.contactUsage.trim().length() > 0){
                       accR.Contact_Usage__c = req.data.customerAccounts[0].ContactRelationship.contactUsage;
                   }
                accR.Opt_Out_SMS_MMS__c = TCMCustomerContactHelper.validateOptInFields(req.data.customerAccounts[0].smsOptIn) && TCMCustomerContactHelper.validateOptInFields(req.data.CustomerAccounts[0].mmsOptIn) ? true : false;
                accR.Opt_Out_Emails__c = TCMCustomerContactHelper.validateOptInFields(req.data.CustomerAccounts[0].emailOptIn);
                accR.Opt_Out_Face_to_Face__c = TCMCustomerContactHelper.validateOptInFields(req.data.CustomerAccounts[0].faceToFaceOptIn);
                accR.Opt_Out_Telemarketing__c = TCMCustomerContactHelper.validateOptInFields(req.data.CustomerAccounts[0].phoneOptIn);
                accR.Opt_Out_Direct_Mail_White_Mail__c = TCMCustomerContactHelper.validateOptInFields(req.data.CustomerAccounts[0].directMailOptIn);
                //accR.Job_Description__c = req.data.jobDescription;
                //accR.Job_Title__c = req.data.jobTitle;
                accR.Relationship_Verified_Date__c = TCMCustomerContactHelper.validateDateField(req.data.customerAccounts[0].contactRelationship.verifiedDate);
                accR.Relationship_Expiry_Date__c = TCMCustomerContactHelper.validateDateField(req.data.customerAccounts[0].contactRelationship.expiryDate);
                
                if(req.data.customerAccounts[0].contactRelationship != null){
                    //Modified as per NFB-4049
                    if(String.isNotBlank(req.data.customerAccounts[0].contactRelationship.endDate)){
                        accR.Relationship_End_Date__c = validateDateField(req.data.customerAccounts[0].contactRelationship.endDate);
                    } else {
                        accR.Relationship_End_Date__c = null;
                    }
                }
            }
            try{
                upsert accR Composite_Key__c;
            } catch (Exception e){
                System.debug('Exception while inserting the Account Contact Relationship');
            }
        } 
        return accR;
    }    
    
    private static Id accountRecordId(NotifyContactRequest req){
        Id accId = null;
        if(req.data.customerAccounts.size() > 0 && req.data.customerAccounts[0].accountUUID != null)
            accId = findAccountByUUID(req.data.customerAccounts[0].accountUUID);
        return accId;
    }
    
    private static Contact mapRequestToContact(NotifyContactRequest req, Contact c) {
        if(c == null) c = new Contact();
        c.Salutation = req.data.title;
        c.firstName = req.data.firstName;
        c.MiddleName = req.data.middleName;
        c.lastName = req.data.lastName;
        if(String.isNotBlank(req.data.birthDate))
            c.Birthdate = Date.valueOf(req.data.birthDate);    
        c.Contact_Status__c = req.data.status;
        c.Merge_Status__c = req.data.mergeStatus;
        if(String.isNotBlank(req.data.onlineFlag))
            c.Online_Flag__c = Boolean.valueOf(req.data.onlineFlag);
        c.Pref_Comm_Method__c = req.data.preferredMethod;
        c.UUID__c = req.data.id;
        c.lastVerifiedDate__c = (String.isNotBlank(req.data.lastVerifiedDate))?validateDateField(req.data.lastVerifiedDate) : TCMCustomerContactHelper.setLastVerifiedDateField(req.data.lastVerifiedDate);
        c.Notes__c = req.data.notes;
        if(String.isNotBlank(req.data.numberInHousehold)){
            c.numberInHousehold__c = Integer.valueOf(req.data.numberInHousehold);
        }
        c.Occupation__c = req.data.occupation;
        c.timeZone__c = req.data.timeZone;
        if(String.isNotBlank(req.data.reviewedFlag)){
            c.Has_Reviewed__c = Boolean.valueOf(req.data.reviewedFlag);
        }
        c.Language_Preference__c = (String.isNotBlank(req.data.languagePreference)) ? req.data.languagePreference : 'English';
        c.ParentSourceSystemAction__c =req.data.parentSourceSystemAction;
        c.Source_System__c = req.data.parentSourceSystemAction;
        if(req.data.homeContact != null){
            c.Home_Email__c = req.data.homeContact.emailAddress;
            c.HomePhone__c = TCMCustomerContactHelper.formatNumber(req.data.homeContact.phoneNumber);
            c.Home_Fax__c = TCMCustomerContactHelper.formatNumber(req.data.homeContact.faxNumber); 
            c.HomePhone = TCMCustomerContactHelper.formatNumber(req.data.homeContact.mobileNumber);
        }
        if(req.data.workContact != null){
            c.Email = req.data.workContact.emailAddress;
            c.MobilePhone = TCMCustomerContactHelper.formatNumber(req.data.workContact.mobileNumber);
            c.Phone = TCMCustomerContactHelper.formatNumber(req.data.workContact.phoneNumber);
            c.Fax = TCMCustomerContactHelper.formatNumber(req.data.workContact.faxNumber);
        }
        
        
        if(req.data.identification != null && req.data.identification.driverLicense != null){
            c.Driver_License_Id__c = req.data.identification.driverLicense.driversLicenseNo;
            c.Driver_Licence_State__c = req.data.identification.driverLicense.state;    
        }
        
        c.Contact_Status__c = req.data.status;
        c.Send_Create_Event__c = false;
        return c;
    }
    
    private static cscrm__Address__c mapRequestToPersonalAddress(NotifyContactRequest.PersonalAddress add, cscrm__Address__c address, contact c) {
        String stNumber = ''; 
        String numTo = '';
        if(address == null){
            address = new cscrm__Address__c();    
        }
        address.cscrm__Country__c = add.country;
        address.cscrm__Account__c = c.AccountId ;
        address.Address_Status__c = add.status;
        address.cscrm__Address_Type__c =add.addressType;
        address.Is_Primary_Address__c =Boolean.valueOf(add.isPrimary);
        address.cscrm__Country__c =add.country;
        address.streetNumberEndSuffix__c =add.streetNumberEndSuffix;
        address.Address_ID__c =add.addressId;
        address.cscrm__Zip_Postal_Code__c = add.postalCode;
        address.cscrm__Address_Type__c = add.isPrimary;
        address.TCM_registeredPlan__c =add.registeredPlan;
        address.streetNumberStartSuffix__c =add.streetNumberStartSuffix;
        address.cscrm__State_Province__c =add.state;
        if(add.streetNumberStart != null){
            stNumber  = add.streetNumberStart;
            if (add.streetNumberStartSuffix != null) {stNumber = stNumber + add.streetNumberStartSuffix; }
            address.cscrm__Street_Number_Start__c  = stNumber;
        }
        
        if(add.streetNumberEnd != null){
            numTo =add.streetNumberEnd;
            if (add.streetNumberEndSuffix != null) {numTo = numTo + add.streetNumberEndSuffix; }
            address.cscrm__Street_Number_End__c = numTo;
        }        
        address.cscrm__Street_Type__c =add.streetType;
        address.streetTypeSuffix__c =add.streetTypeSuffix;
        address.TCM_additionalInfo__c =add.additionalInfo;
        address.TCM_internationalPostcode__c =add.internationalPostCode;
        address.TCM_internationalState__c =add.internationalState;
        address.cscrm__City__c =add.locality;
        address.Locality__c =add.locality;
        address.cscrm__Street_Name__c =add.streetName;
        //address.DP_Id__c =add.deliveryPointId;
        //address.TCM_Address_Type_Value__c =add.addressTypeCode;
        //address.TCM_Street_Type_code__c =add.streetTypeCode;
        //address.TCM_street_Type_Suffix_Code__c =add.streetTypeSuffixCode;
        //address.TCM_status_Code__c =add.statusCode;
        if(add.subAddress != null){
            if(add.subAddress.numberStart != null ){
                address.TCM_numberStart__c =add.subAddress.numberStart; 
            }
            if(add.subAddress.numberEnd != null ){
                address.TCM_numberEnd__c =add.subAddress.numberEnd; 
            }
            
            address.Sub_Address1_Type__c = add.addressTypeCode;
            address.Sub_Address1_Number__c = address.TCM_numberStart__c + ((address.TCM_numberEnd__c != null && address.TCM_numberEnd__c != '0' && address.TCM_numberEnd__c != '') ? ('-' + address.TCM_numberEnd__c) : '');
            address.Sub_Address_Level_1__c = address.Sub_Address1_Type__c + ' ' + address.Sub_Address1_Number__c;
            
            address.TCM_privateStreetName__c =add.subAddress.privateStreetName;
            address.TCM_privateStreetType__c = add.subAddress.privateStreetType;
            address.cscrm__Property_Name__c = add.subAddress.propertyName;
            address.cscrm__Building_Name__c = add.subAddress.propertyName;
            
            if(add.subAddress.addressLines != null  && !add.subAddress.addressLines.isEmpty()){
                if(add.subAddress.addressLines[0] != null){
                    address.Address_Line_1__c = add.subAddress.addressLines[0];    
                }
                if(add.subAddress.addressLines[1] != null){
                    address.Address_Line_2__c = add.subAddress.addressLines[1];    
                }
                if(add.subAddress.addressLines[2] != null){
                    address.Address_Line_3__c = add.subAddress.addressLines[2];    
                }
            }
            if(add.SubAddress.details != null){
                if(add.subAddress.details[0]!=null){
                    address.Sub_Address2_Number__c = add.subAddress.details[0].value;
                    address.Sub_Address2_Type__c = add.subAddress.details[0].detailType;
                    address.Sub_Address2_Type_Code__c = add.subAddress.details[0].detailTypeCode;
                    address.Sub_Address_Level_2__c = address.Sub_Address2_Type__c + ' ' + address.Sub_Address2_Number__c;
                }
                if(add.subAddress.details[1]!=null){
                    address.Sub_Address_3_Number__c = add.subAddress.details[1].value;
                    address.Sub_Address_3_Type__c = add.subAddress.details[1].detailType;
                    address.Sub_Address_3_Type_Code__c = add.subAddress.details[1].detailTypeCode;
                    address.Sub_Address_Level_3__c = address.Sub_Address_3_Type__c + ' ' + address.Sub_Address_3_Number__c;
                }
            }
        }
        return address;
    }
    
    private static cscrm__Address__c mapRequestToAddress(NotifyContactRequest.BusinessAddress add, cscrm__Address__c address, contact c) {
        String stNumber = ''; 
        String numTo = '';
        if(address == null){
            address = new cscrm__Address__c();    
        }
        address.cscrm__Country__c = add.country;
        address.cscrm__Account__c = c.AccountId ;
        address.Address_Status__c = add.status;
        address.cscrm__Address_Type__c =add.addressType;
        address.Is_Primary_Address__c =Boolean.valueOf(add.isPrimary);
        address.cscrm__Country__c =add.country;
        address.streetNumberEndSuffix__c =add.streetNumberEndSuffix;
        address.Address_ID__c =add.addressId;
        address.cscrm__Zip_Postal_Code__c = add.postalCode;
        address.cscrm__Address_Type__c = add.isPrimary;
        address.TCM_registeredPlan__c =add.registeredPlan;
        address.streetNumberStartSuffix__c =add.streetNumberStartSuffix;
        address.cscrm__State_Province__c =add.state;
        if(add.streetNumberStart != null){
            stNumber  = add.streetNumberStart;
            if (add.streetNumberStartSuffix != null) {stNumber = stNumber + add.streetNumberStartSuffix; }
            address.cscrm__Street_Number_Start__c  = stNumber;
        }
        
        if(add.streetNumberEnd != null){
            numTo =add.streetNumberEnd;
            if (add.streetNumberEndSuffix != null) {numTo = numTo + add.streetNumberEndSuffix; }
            address.cscrm__Street_Number_End__c = numTo;
        }        
        address.cscrm__Street_Type__c =add.streetType;
        address.streetTypeSuffix__c =add.streetTypeSuffix;
        address.TCM_additionalInfo__c =add.additionalInfo;
        address.TCM_internationalPostcode__c =add.internationalPostCode;
        address.TCM_internationalState__c =add.internationalState;
        address.cscrm__City__c =add.locality;
        address.Locality__c =add.locality;
        address.cscrm__Street_Name__c =add.streetName;
        //address.DP_Id__c =add.deliveryPointId;
        //address.TCM_Address_Type_Value__c =add.addressTypeCode;
        //address.TCM_Street_Type_code__c =add.streetTypeCode;
        //address.TCM_street_Type_Suffix_Code__c =add.streetTypeSuffixCode;
        //address.TCM_status_Code__c =add.statusCode;
        if(add.subAddress != null){
            if(add.subAddress.numberStart != null ){
                address.TCM_numberStart__c =add.subAddress.numberStart; 
            }
            if(add.subAddress.numberEnd != null ){
                address.TCM_numberEnd__c =add.subAddress.numberEnd; 
            }
            
            address.Sub_Address1_Type__c = add.addressTypeCode;
            address.Sub_Address1_Number__c = address.TCM_numberStart__c + ((address.TCM_numberEnd__c != null && address.TCM_numberEnd__c != '0' && address.TCM_numberEnd__c != '') ? ('-' + address.TCM_numberEnd__c) : '');
            address.Sub_Address_Level_1__c = address.Sub_Address1_Type__c + ' ' + address.Sub_Address1_Number__c;
            
            address.TCM_numberEnd__c =add.subAddress.numberEnd;
            address.TCM_privateStreetName__c =add.subAddress.privateStreetName;
            address.TCM_privateStreetType__c = add.subAddress.privateStreetType;
            address.cscrm__Property_Name__c = add.subAddress.propertyName;
            address.cscrm__Building_Name__c = add.subAddress.propertyName;
            //address.TCM_privateStreetTypeCode__c =add.subAddress.privateStreetTypeCode;
            if(add.subAddress.addressLines != null  && !add.subAddress.addressLines.isEmpty()){
                if(add.subAddress.addressLines[0] != null){
                    address.Address_Line_1__c = add.subAddress.addressLines[0];    
                }
                if(add.subAddress.addressLines[1] != null){
                    address.Address_Line_2__c = add.subAddress.addressLines[1];    
                }
                if(add.subAddress.addressLines[2] != null){
                    address.Address_Line_3__c = add.subAddress.addressLines[2];    
                }
            }
            if(add.SubAddress.details != null){
                if(add.subAddress.details[0]!=null){
                    address.Sub_Address2_Number__c = add.subAddress.details[0].value;
                    address.Sub_Address2_Type__c = add.subAddress.details[0].detailType;
                    address.Sub_Address2_Type_Code__c = add.subAddress.details[0].detailTypeCode;
                    address.Sub_Address_Level_2__c = address.Sub_Address2_Type__c + ' ' + address.Sub_Address2_Number__c;
                }
                if(add.subAddress.details[1]!=null){
                    address.Sub_Address_3_Number__c = add.subAddress.details[1].value;
                    address.Sub_Address_3_Type__c = add.subAddress.details[1].detailType;
                    address.Sub_Address_3_Type_Code__c = add.subAddress.details[1].detailTypeCode;
                    address.Sub_Address_Level_3__c = address.Sub_Address_3_Type__c + ' ' + address.Sub_Address_3_Number__c;
                }
            }
        } 
        
        return address;
    }
    
    private static Id findAccountByUUID(String accountUUID) {
        System.debug('!@#$% Querying for account using Account UUID : ' + accountUUID);
        List<Account> accountObject = null;
        accountObject = [SELECT Id, Name FROM Account WHERE Account_UUID__c = :accountUUID LIMIT 1];
        if(!accountObject.isEmpty()){
            return accountObject[0].Id;
        }
        return null;
    }
    
    private static Contact getExistingContact(String contactId) {
        System.debug('!@#$% Querying for Contact using Contact contactid : ' + contactId);
        List<Contact> contactObj = [SELECT AccountId,AssistantName,AssistantPhone,Birthdate,Contact_Status__c,CreatedById,CreatedDate,Department,Description,DoNotCall,Email,EmailBouncedDate,EmailBouncedReason,Fax,FirstName,HasOptedOutOfEmail,HasOptedOutOfFax,HomePhone,HomePhone__c,Home_Email__c,Home_Fax__c,Id,IsDeleted,IsEmailBounced,Jigsaw,JigsawContactId,Language_Preference__c,LastActivityDate,LastCURequestDate,LastCUUpdateDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastViewedDate,LeadSource,MailingAddress,MailingCity,MailingCountry,MailingGeocodeAccuracy,MailingLatitude,MailingLongitude,MailingPostalCode,MailingState,MailingStreet,MasterRecordId,MobilePhone,Name,OtherAddress,OtherCity,OtherCountry,OtherGeocodeAccuracy,OtherLatitude,OtherLongitude,OtherPhone,OtherPostalCode,OtherState,OtherStreet,OwnerId,Phone,PhotoUrl,Pref_Comm_Method__c,ReportsToId,Salutation,SystemModstamp,Driver_License_Id__c,Driver_Licence_State__c,Title,UUID__c   FROM Contact WHERE Id = :contactId ];
        if(!contactObj.isEmpty()){
            return contactObj[0];
        }
        return null;
    }
    
    private static Contact getExistingContactByUUID(String contactId) {
        System.debug('!@#$% Querying for Contact using Contact contactid : ' + contactId);
        List<Contact> contactObj = [SELECT AccountId,AssistantName,AssistantPhone,Birthdate,Contact_Status__c,CreatedById,CreatedDate,Department,Description,DoNotCall,Email,EmailBouncedDate,EmailBouncedReason,Fax,FirstName,HasOptedOutOfEmail,HasOptedOutOfFax,HomePhone,HomePhone__c,Home_Email__c,Home_Fax__c,Id,IsDeleted,IsEmailBounced,Jigsaw,JigsawContactId,Language_Preference__c,LastActivityDate,LastCURequestDate,LastCUUpdateDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastViewedDate,LeadSource,MailingAddress,MailingCity,MailingCountry,MailingGeocodeAccuracy,MailingLatitude,MailingLongitude,MailingPostalCode,MailingState,MailingStreet,MasterRecordId,MobilePhone,Name,OtherAddress,OtherCity,OtherCountry,OtherGeocodeAccuracy,OtherLatitude,OtherLongitude,OtherPhone,OtherPostalCode,OtherState,OtherStreet,OwnerId,Phone,PhotoUrl,Pref_Comm_Method__c,ReportsToId,Salutation,SystemModstamp,Driver_License_Id__c,Driver_Licence_State__c,Title,UUID__c   FROM Contact WHERE UUID__c = :contactId ];
        if(!contactObj.isEmpty()){
            return contactObj[0];
        }
        return null;
    }
    
    private static List<cscrm__Address__c> getExistingAddresses(Id contactId, String addresType){
        Map<Id, cscrm__Contact_Address_Relationship__c> mapAddress = new Map<Id, cscrm__Contact_Address_Relationship__c>([SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, cscrm__Active__c, cscrm__Address_Type__c, cscrm__Contact__c, cscrm__Address__c,cscrm__Address__r.cscrm__External_ID__c, cscrm__End_Date__c, cscrm__Start_Date__c FROM cscrm__Contact_Address_Relationship__c WHERE cscrm__Contact__c = :contactId and cscrm__Address_Type__c =:addresType]);
        if(mapAddress != null && !mapAddress.keySet().isEmpty()){
            List<cscrm__Address__c> addrsList = [SELECT cscrm__Account__c,Address_Line_1__c,Locality__c,cscrm__Address_Details__c,cscrm__Address_Type__c,cscrm__Building_Name__c,cscrm__Building_Number__c,cscrm__Building_Type__c,cscrm__City__c,cscrm__Country__c,cscrm__External_Address_Id__c,cscrm__External_ID__c,cscrm__Geolocation__c,cscrm__Geolocation__Latitude__s,cscrm__Geolocation__Longitude__s,cscrm__Is_Billing_Address__c,cscrm__Is_Installation_Address__c,cscrm__Is_Registered_Office_Address__c,cscrm__Is_Shipping_Address__c,cscrm__Level_Number__c,cscrm__Level_Type__c,cscrm__Plan_Number__c,cscrm__Property_Name__c,cscrm__State_Province__c,cscrm__Street_Name__c,cscrm__Street_Number_End__c,cscrm__Street_Number_Start__c,cscrm__Street_Type__c,cscrm__Street__c,cscrm__Unit_Number__c,cscrm__Unit_Type__c,cscrm__Zip_Postal_Code__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,SystemModstamp FROM cscrm__Address__c WHERE id IN:mapAddress.keySet()];
            if(!addrsList.isEmpty()){
                return addrsList;
            }
        }
        return null;
    }
    
    private static Date validateDateField(String value){
        return (value != null && String.isNotBlank(value)) ? Date.valueOf(value) : null;
    }
    /*Keeping Dormant
    //EDGE-29842
    private static Boolean IsActiveACRPresentForContact(Contact tcmCon){
        return ([SELECT count() FROM AccountContactRelation WHERE ContactId =: tcmCon.Id AND Relationship_End_Date__c = null] > 0)?True:False;
    }
    //EDGE-35520
    private static Boolean IsActiveFCRPresentForContact(String tcmConid,String tcmAccid){
        return ([SELECT count() FROM Functional_Contact_Role__c WHERE ContactID__c =: tcmConid AND (Billing_Account_Number__r.Account__c =: tcmAccid OR OrderID__r.csord__Account__c =: tcmAccid OR SiteID__r.cscrm__Account__c =: tcmAccid  OR SubscriptionID__r.csord__Account__c =: tcmAccid) AND Relationship_End_Date__c = null] > 0)?True:False;
    }
    
    private static Boolean isEndateChangedAndFCRPresent(NotifyContactRequest request, Contact contact){
        if(contact != null && request.data.customerAccounts != null && !request.data.customerAccounts.isEmpty()){
            System.debug('Contact present');
            List<AccountContactRelation> accRList = [SELECT id, contactid, AccountId,Contact_Type__c,Contact_Usage__c,Composite_Key__c,Relationship_End_Date__c 
                                                     FROM AccountContactRelation WHERE contactid =:contact.id AND AccountId=:contact.AccountId];
            if(accRList != null && accRList.size() == 1){
                AccountContactRelation accR = accRList[0];
                System.debug('accrTest: '+accR);
                if(request.data.customerAccounts[0].contactRelationship != null
                   && String.isNotBlank(request.data.customerAccounts[0].contactRelationship.endDate)){
                       Date relationEndDate =  validateDateField(request.data.customerAccounts[0].contactRelationship.endDate);
                       System.debug('relationEndDate: '+relationEndDate+' accr.Relationship_End_Date__c: '+accr.Relationship_End_Date__c);
                       if(accr.Relationship_End_Date__c!=relationEndDate && relationEndDate!=null && IsActiveFCRPresentForContact(accr.contactid,accr.accountid)){
                           //Show error
                           return true;   
                       }
                       
                   }
            }
        }
        return false;
    }
    private static NotifyContactResponse setErrorResponse(NotifyContactResponse response,Contact con,String errorMessage){
        response.Data = con.id;
        response.Status = 'Success';
        response.StatusCode = 200;       
        response.Message = 'Contact Error : ' + errorMessage;
        response.ErrorCode = TCMBusinessErrorCode.getInstance().getCode(errorMessage.toLowerCase('Locale.EN'));
        return response;
    }
	*/
}