/*
AUTHOR : Anu Yadav
DESCRIPTION : This class is used to generate and send request messages for ManageContact
*/

public without sharing class ManageContactHandler {
    public static List<cscrm__Address__c> businessAddresses{get;private set;}
    public static List<cscrm__Address__c> personalAddresses{get;private set;}
    public static Account account {get; set;}
    
    public static final String EVENT_ACTION_CREATE = 'Create';
    public static final String EVENT_ACTION_UPDATE = 'Update';
    public static final String EVENT_ACTION_CROSSREF = 'CrossRef';
    public static final String HOME_ADDRESS = 'Home Address';
    public static final String OFFICE_ADDRESS = 'Office Address';
    public static final String Certificate_name = EnvironmentVariable.get('certificate_name');
    
    public static String generateManageContactRequest(Contact c, String event,String acrRoles, Boolean isEndDated, String accountId){
        
        System.debug('!@#$% Generating ManageContact request for ' + event + ' event');
        
        ManageContactRequest mcr = new ManageContactRequest();
        ManageContactRequest.Data data = new ManageContactRequest.Data();
        
        getExistingAddresses(c.Id);
        //Address - ##INTERFACE MANDATORY##
        data.businessAddress = getMCRContactBusinessAddress(businessAddresses);
        System.debug('businessAddress: '+data.businessAddress);
        data.personalAddress = getMCRContactPersonalAddress(personalAddresses);
        System.debug('personalAddress: '+data.personalAddress);
        
        data.externalSystemId = (c.Source_System__c == null)?'':c.Source_System__c;
        data.id = (c.UUID__c == null)?'':c.UUID__c;
        data.title = (c.Salutation == null)?'':c.Salutation.toUpperCase(UserInfo.getLocale());
        data.firstName = (c.FirstName == null)?'':c.FirstName; // INTERFACE MANDATORY
        data.middleName = (c.MiddleName == null)?'':c.MiddleName;
        data.lastName = (c.LastName == null)?'':c.LastName; // INTERFACE MANDATORY
        data.birthDate = (c.Birthdate == null)?'':validateDateField(c.Birthdate);     
        data.homeContact = new ManageContactRequest.HomeContact();
        data.homeContact.emailAddress = (c.Home_Email__c == null)?'':c.Home_Email__c;
        data.homeContact.faxNumber = (c.Home_Fax__c == null)?'':c.Home_Fax__c;
        data.homeContact.mobileNumber = (c.HomePhone == null)?'':c.HomePhone;
        data.homeContact.phoneNumber = (c.HomePhone__c == null)?'':c.HomePhone__c;
        data.workContact = new ManageContactRequest.WorkContact();
        data.workContact.emailAddress = (c.Email == null)?'':c.Email;
        data.workContact.faxNumber = (c.Fax == null)?'':c.Fax;
        data.workContact.phoneNumber = (c.Phone == null)?'':c.Phone;
        data.workContact.mobileNumber = (c.MobilePhone == null)?'':c.MobilePhone;
        
        data.status = (EVENT_ACTION_CREATE == event)?'Active':c.Contact_Status__c; // INTERFACE MANDATORY
        data.onlineFlag = TCMCustomerContactHelper.validateField(c.Online_Flag__c);
        data.preferredMethod = (c.Pref_Comm_Method__c == null)?'':c.Pref_Comm_Method__c;
        data.eventAction = event; // INTERFACE MANDATORY
        DateTime dt = System.Datetime.now();
        data.sendDateTime = String.valueOf(dt)+'.'+String.valueOf(dt.millisecond()); // INTERFACE MANDATORY
        data.contactId = (c.Id == null)?'':String.valueof(c.Id); // INTERFACE MANDATORY//ADDED AS 15 Digit ID
        data.lastVerifiedDate = (c.lastVerifiedDate__c == null)?'':validateDateField(c.lastVerifiedDate__c);
        data.notes = (c.Notes__c == null)?'':c.Notes__c;
        data.numberInHousehold = (c.numberInHousehold__c == null)?'':String.valueof(c.numberInHousehold__c);
        //data.occupation = (c.Occupation__c == null)?'':c.Occupation__c;
        data.timeZone = (c.timeZone__c == null)?'':c.timeZone__c;
        //data.jobDescription = (c.Job_Description__c == null)?'':c.Job_Description__c;
        //data.jobTitle = (c.jobTitle__c == null)?'':c.jobTitle__c;
        data.reviewedFlag =  TCMCustomerContactHelper.validateField(c.Has_Reviewed__c);
        data.languagePreference = (c.Language_Preference__c == null)?'':c.Language_Preference__c;
        data.lastUpdated = (c.TCM_Last_Updated_Datetime__c == null)?'':validateDateFieldWithTZD(c.TCM_Last_Updated_Datetime__c);
        
        data.customerAccounts = new ManageContactRequest.CustomerAccounts();
        AccountContactRelation acr = (String.isNotBlank(accountId)) ? getAccountContactRelation(accountId,c.Id) : getAccountContactRelation(c.AccountId,c.Id);
        if(account != null) {
            data.customerAccounts.accountUuid = (account.Account_UUID__c == null)?'':account.Account_UUID__c; // INTERFACE MANDATORY    
            data.customerAccounts.customerCode = (account.Customer_ID__c == null)?'':account.Customer_ID__c;
        }
        if(acr != null){
            data.customerAccounts.mmsOptIn = TCMCustomerContactHelper.validateOptOutFields(acr.Opt_Out_SMS_MMS__c);
            data.customerAccounts.smsOptIn = TCMCustomerContactHelper.validateOptOutFields(acr.Opt_Out_SMS_MMS__c);
            data.customerAccounts.emailOptIn = TCMCustomerContactHelper.validateOptOutFields(acr.Opt_Out_Emails__c);
            data.customerAccounts.faceToFaceOptIn = TCMCustomerContactHelper.validateOptOutFields(acr.Opt_Out_Face_to_Face__c);
            data.customerAccounts.phoneOptIn = TCMCustomerContactHelper.validateOptOutFields(acr.Opt_Out_Telemarketing__c);
            data.customerAccounts.directMailOptIn = TCMCustomerContactHelper.validateOptOutFields(acr.Opt_Out_Direct_Mail_White_Mail__c);
            data.customerAccounts.contactRelationship = new ManageContactRequest.ContactRelationship();
            //data.jobDescription = (acr.Job_Description__c == null)?'': acr.Job_Description__c;
            data.jobTitle = (acr.Job_Title__c == null)?'': acr.Job_Title__c;
            if(String.isNotBlank(acrRoles) && isEndDated != null && isEndDated){
                data.customerAccounts.contactRelationship.endDate = validateDateFieldWithTZD(Date.today());
                data.customerAccounts.contactRelationship.contactType = acrRoles;
            } else {
                //data.customerAccounts.contactRelationship.endDate = (acr.Relationship_End_Date__c == null)?'':String.valueOf(acr.Relationship_End_Date__c);
                data.customerAccounts.contactRelationship.contactType = (acr.Roles == null)?'':acr.Roles;
            }
            data.customerAccounts.contactRelationship.contactUsage = (acr.Contact_Usage__c == null)?'':acr.Contact_Usage__c;
            data.customerAccounts.contactRelationship.verifiedDate = (acr.Relationship_Verified_Date__c == null)?'':String.valueOf(acr.Relationship_Verified_Date__c);
            data.customerAccounts.contactRelationship.expiryDate =  (acr.Relationship_Expiry_Date__c == null)?'':String.valueOf(acr.Relationship_Expiry_Date__c);
        }
        data.identification = new ManageContactRequest.Identification();
        if(isNotNullAndBlank(c.Driver_License_Id__c)){
          data.identification.driverLicense = new ManageContactRequest.DriverLicense();
          data.identification.driverLicense.num = c.Driver_License_Id__c;  
          data.identification.driverLicense.state = (c.Driver_Licence_State__c == null)?'':c.Driver_Licence_State__c; //Length check of 7 should be done
        }
        mcr.data = data;
        String mcRequest = System.JSON.serializePretty(mcr, true);
        mcRequest = mcRequest.replace('"num"', '"number"');
        return mcRequest;
    }
    
    @future(callout=true)
    public static void sendmanageContactList(String manageContacts){
        //form the manage contact request.
        //Deserialze the String to list
        //Iterate for look and call the sendManageContact.
        //identifier = UUID__c.
        List<ManageContactDAO> manageContactList = (List<ManageContactDAO>)System.JSON.deserialize(manageContacts, List<ManageContactDAO>.class);
        for(ManageContactDAO manageContDAO : manageContactList){
            System.debug('In sendmanageContactList: '+manageContDAO);
            manageContDAO.mcReq = ManageContactHandler.generateManageContactRequest(manageContDAO.manageContact, manageContDAO.eventType,manageContDAO.acrRole,manageContDAO.isACREndDated, manageContDAO.accountId);
            manageContDAO.identifier = manageContDAO.manageContact.UUID__c;
            //sendManageContact(mcReq, manageContDAO.eventType,manageContDAO.manageContact.UUID__c);
        }
         Logger2 log = Logger2.getLogger('ManageContactRequest');
        for(ManageContactDAO manageConDAO : manageContactList){
                ManageContactHandler.sendManageContact(manageConDAO.mcReq,manageConDAO.eventType,manageConDAO.identifier,log);
            }
        log.exitLogger();
      //System.enqueueJob(new ManageContactQueueableCallOut(manageContactList));
    }
    
    /**************** Start of Edge 85839 *****************/
    //Override the method with one extra boolean argument to extend the existing functionality to use in SyncUpContactTCM Batch.
    @TestVisible
    public static void sendManageContact(String req, String event, String identifier, Logger2 log) {
        /**************** Start of Edge 85839 *****************/
         HttpResponse resp = sendManageContact(req, event, identifier, log, false);
          System.debug('resp :: '+resp);
        /**************** End of Edge 85839 *****************/
    }
    
    /**
     * @createdBy           : 
     * @name sendManageContact
     * @description         : The method is called from the "SyncUpContactTCM" batchable class and it will help to send the Contact data to TCM.
     * @param req           : String data for the Contact Object
     * @param event         : EVENT_ACTION_UPDATE
     * @param identifier    : Account with respective Customer_ID__c
     * @param isBatch       : true
     * @return HttpResponse : HttpResponse
     * @jiraStoryRef        : EDGE-85839
     * @modifiedBy          : Sasidhar Devarapalli,OSAKA
     * 
     **/
    @TestVisible
    public static HttpResponse sendManageContact(String req, String event, String identifier, Logger2 log, Boolean isBatch) { 
        //Logger log = Logger.getLogger('ManageContactRequest');  
        HttpResponse resp;
        Boolean callout = true;
        IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
        String token = '';
        if(is.EnableMocks__c != true){
            token = TCMSearchManager.getTCMContactToken();
        }
        
        // Prepare Request
        HttpRequest request = new HttpRequest();
        
        if(is.EnableMocks__c == true){
            request.setEndpoint(EnvironmentVariable.get('MockEndpoint'));    
        }
        else {
            String ep = EnvironmentVariable.get('tcm_contactEndpoint');
            System.debug('++ep='+ep);
            if(event != EVENT_ACTION_CREATE) {
                if(String.isNotBlank(identifier)) {
                    ep = ep + '/'+identifier;    
                } else {
                    callout = false;
                }
            }
            request.setEndpoint(ep);
        }
        if(event == EVENT_ACTION_CREATE){
            request.setMethod('POST');    
        } else {
            request.setMethod('PUT');
        }
        //Set Certificate
        if(Certificate_name != null){
            request.setClientCertificateName(Certificate_name);
        }
        request.setBody(req);
        
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        
        System.debug('!@#$% Request : ' + request);
        System.debug('!@#$% ManageContactRequest Body : ' + request.getBody());
        
        // Send Request
        if(callout){
            Http httpClient = new Http();
            
            try{
                resp = httpClient.send(request);
                System.debug('!@#$% ManageContact Response : ' + resp); 
            } catch(Exception e){
            /**************** Start of Edge 85839 *****************/
                if(!isBatch)
                    log.logMessages(request.getBody(), (resp !=null ? resp.getBody() : ''), e.getStackTraceString(), 'Technical', '', '', false, false, (resp !=null ? resp.getStatusCode() : null),null,identifier, null);
                
            } finally {
                if(!isBatch)
                    log.logMessages(request.getBody(), (resp !=null ? resp.getBody() : ''), '', '', '', '', false, false, (resp !=null ? resp.getStatusCode() : null),null,identifier, null);
            }
        }
        return resp;
        /**************** End of Edge 85839 *****************/
    }
    /**************** End of Edge 85839 *****************/
        /*------------------------------------------------------------ 
EDGE-39902
Method: getMCRContactBusinessAddress 
Description: generate address payload
Inputs: List if cscrm__Address__c
Returns: 
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    @TestVisible
    private static List<ManageContactRequest.BusinessAddress> getMCRContactBusinessAddress(List<cscrm__Address__c> addresses){
        System.debug('getMCRContactBusinessAddress:' +addresses);
        List<ManageContactRequest.BusinessAddress> businessAddressItemList= new List<ManageContactRequest.BusinessAddress>();
        if(addresses != null && !addresses.isEmpty() ){
            for(cscrm__Address__c address : addresses){
               ManageContactRequest.BusinessAddress businessAddressItem = new ManageContactRequest.BusinessAddress();
                BusinessAddressItem.isPrimary = 'Y';//As we are sending primary addresses only INTERFACE MANDATORY
                businessAddressItem.addressId = (address.Address_ID__c == null)?'':address.Address_ID__c; //INTERFACE MANDATORY
                businessAddressItem.country = (address.cscrm__Country__c == null)?'':address.cscrm__Country__c;
                businessAddressItem.status = (address.Address_Status__c == null)?'':validateAddressStatus(address.Address_Status__c);
                //businessAddressItem.addressType = (address.cscrm__Address_Type__c == null)?'':address.cscrm__Address_Type__c;
                businessAddressItem.addressType = (address.Sub_Address_Type__c == null)?'':AddressTriggerHandler.getAddressTypeForTCMManage(address.Parent_Address_Id__c,address.Number_of_Sub_addresses__c,address.Sub_Address_Type__c); //EDGE-39902
                businessAddressItem.state = (address.cscrm__State_Province__c == null)?'':address.cscrm__State_Province__c;
                businessAddressItem.postalCode = (address.cscrm__Zip_Postal_Code__c == null)?'':address.cscrm__Zip_Postal_Code__c;
                businessAddressItem.streetName = (address.cscrm__Street_Name__c == null)?'':address.cscrm__Street_Name__c;
                businessAddressItem.streetType = (address.streetType__c == null)?'':AddressTriggerHandler.getStreetTypeForTCMManage(address.streetType__c); //EDGE-39902
                businessAddressItem.streetTypeSuffix = (address.streetTypeSuffix__c == null)?'':address.streetTypeSuffix__c;
                //Changed As Per Discussion With Designer Of Eureka
                businessAddressItem.streetNumberStart=(address.Street_Number_From_calc__c == null)?'':address.Street_Number_From_calc__c;
                businessAddressItem.streetNumberStartSuffix = (address.streetNumberStartSuffix__c == null)?'':address.streetNumberStartSuffix__c;
                businessAddressItem.streetNumberEnd = (address.cscrm__Street_Number_End__c == null)?'':address.cscrm__Street_Number_End__c;
                businessAddressItem.streetNumberEndSuffix = (address.streetNumberEndSuffix__c == null)?'':address.streetNumberEndSuffix__c;
                businessAddressItem.internationalPostCode = (address.TCM_internationalPostcode__c == null)?'':address.TCM_internationalPostcode__c;
                businessAddressItem.internationalState = (address.TCM_internationalState__c == null)?'':address.TCM_internationalState__c;
                businessAddressItem.registeredPlan = (address.TCM_registeredPlan__c == null)?'':address.TCM_registeredPlan__c;
                businessAddressItem.locality = (address.Locality__c == null)?'':address.Locality__c;
                businessAddressItem.additionalInfo = (address.TCM_additionalInfo__c == null)?'':address.TCM_additionalInfo__c;
                // SubAddress
                businessAddressItem.subAddress = new ManageContactRequest.SubAddress();
                businessAddressItem.subAddress.buildingName = (address.cscrm__Building_Name__c == null)?'':address.cscrm__Building_Name__c;
                businessAddressItem.subAddress.propertyName = (address.cscrm__Property_Name__c == null)?'':address.cscrm__Property_Name__c;
                businessAddressItem.subAddress.numberStart =  (address.TCM_numberStart__c == null)?'': address.TCM_numberStart__c;
                businessAddressItem.subAddress.numberEnd = (address.TCM_numberEnd__c == null)?'': address.TCM_numberEnd__c;
                businessAddressItem.subAddress.privateStreetName = (address.TCM_privateStreetName__c == null)?'':address.TCM_privateStreetName__c;
                businessAddressItem.subAddress.privateStreetType = (address.TCM_privateStreetType__c == null)?'':address.TCM_privateStreetType__c;
                // Details
                ManageContactRequest.Detail detailItem1 = new ManageContactRequest.Detail();
                detailItem1.detailType = (address.Sub_Address1_Type__c == null)?'':address.Sub_Address1_Type__c;
                detailItem1.value = (address.Sub_Address1_Number__c == null)?'':address.Sub_Address1_Number__c;
                ManageContactRequest.Detail detailItem2 = new ManageContactRequest.Detail();
                detailItem2.detailType = (address.Sub_Address2_Type__c == null)?'':address.Sub_Address2_Type__c;
                detailItem2.value = (address.Sub_Address2_Number__c == null)?'':address.Sub_Address2_Number__c;
                businessAddressItem.subAddress.details = new List<ManageContactRequest.Detail>();
                businessAddressItem.subAddress.details.add(detailItem1);
                businessAddressItem.subAddress.details.add(detailItem2);
                if(address.Address_Line_1__c != null){
                    businessAddressItem.subAddress.addressLines = new List<String>();
                    businessAddressItem.subAddress.addressLines.add(address.Address_Line_1__c);      
                }
                if(address.Address_Line_2__c != null){
                    businessAddressItem.subAddress.addressLines.add(address.Address_Line_2__c);      
                }
                if(address.Address_Line_3__c != null){
                    businessAddressItem.subAddress.addressLines.add(address.Address_Line_3__c);      
                }
              businessAddressItemList.add(businessAddressItem);
            }
        }
        return businessAddressItemList;
    }
            /*------------------------------------------------------------ 
EDGE-39902
Method: getMCRContactPersonalAddress 
Description: generate address payload
Inputs: List if cscrm__Address__c
Returns: 
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    @TestVisible
    private static List<ManageContactRequest.PersonalAddress> getMCRContactPersonalAddress(List<cscrm__Address__c> addresses){
        System.debug('addresses: getMCRContactPersonalAddress'+addresses);
        List<ManageContactRequest.PersonalAddress> PersonalAddressList= new List<ManageContactRequest.PersonalAddress>();
        if(addresses != null && !addresses.isEmpty() ){
            for(cscrm__Address__c address : addresses){
                ManageContactRequest.PersonalAddress personalAddressItem = new ManageContactRequest.PersonalAddress();
                personalAddressItem.isPrimary = 'Y'; //As we are sending primary addresses only INTERFACE MANDATORY
                personalAddressItem.addressId = (address.Address_ID__c == null)?'':address.Address_ID__c; //INTERFACE MANDATORY
                personalAddressItem.country = (address.cscrm__Country__c == null)?'':address.cscrm__Country__c; //INTERFACE MANDATORY
                personalAddressItem.status = (address.Address_Status__c == null)?'':validateAddressStatus(address.Address_Status__c);
                //personalAddressItem.addressType = (address.cscrm__Address_Type__c == null)?'':address.cscrm__Address_Type__c;
                personalAddressItem.addressType = (address.Sub_Address_Type__c == null)?'':AddressTriggerHandler.getAddressTypeForTCMManage(address.Parent_Address_Id__c,address.Number_of_Sub_addresses__c,address.Sub_Address_Type__c); //EDGE - 39902
                personalAddressItem.state = (address.cscrm__State_Province__c == null)?'':address.cscrm__State_Province__c;
                personalAddressItem.postalCode = (address.cscrm__Zip_Postal_Code__c == null)?'':address.cscrm__Zip_Postal_Code__c;
                personalAddressItem.streetName = (address.cscrm__Street_Name__c == null)?'':address.cscrm__Street_Name__c;
                personalAddressItem.streetType = (address.streetType__c == null)?'':AddressTriggerHandler.getStreetTypeForTCMManage(address.streetType__c);
                personalAddressItem.streetTypeSuffix = (address.streetTypeSuffix__c == null)?'':address.streetTypeSuffix__c;
                //Changed As Per Discussion With Designer Of Eureka
                personalAddressItem.streetNumberStart=(address.Street_Number_From_calc__c == null)?'':address.Street_Number_From_calc__c;
                personalAddressItem.streetNumberStartSuffix = (address.streetNumberStartSuffix__c == null)?'':address.streetNumberStartSuffix__c;
                personalAddressItem.streetNumberEnd = (address.cscrm__Street_Number_End__c == null)?'':address.cscrm__Street_Number_End__c;
                personalAddressItem.streetNumberEndSuffix = (address.streetNumberEndSuffix__c == null)?'':address.streetNumberEndSuffix__c;
                personalAddressItem.internationalPostcode = (address.TCM_internationalPostcode__c == null)?'':address.TCM_internationalPostcode__c;
                personalAddressItem.internationalState = (address.TCM_internationalState__c == null)?'':address.TCM_internationalState__c;
                personalAddressItem.registeredPlan = (address.TCM_registeredPlan__c == null)?'':address.TCM_registeredPlan__c;
                personalAddressItem.locality = (address.Locality__c == null)?'':address.Locality__c;
                personalAddressItem.additionalInfo = (address.TCM_additionalInfo__c == null)?'':address.TCM_additionalInfo__c;
                // SubAddress
                personalAddressItem.subAddress = new ManageContactRequest.SubAddress();
                personalAddressItem.subAddress.buildingName = (address.cscrm__Building_Name__c == null)?'':address.cscrm__Building_Name__c;
                personalAddressItem.subAddress.propertyName = (address.cscrm__Property_Name__c == null)?'':address.cscrm__Property_Name__c;
                personalAddressItem.subAddress.numberStart = (address.TCM_numberStart__c == null)?'':address.TCM_numberStart__c;
                personalAddressItem.subAddress.numberEnd = (address.TCM_numberEnd__c == null)?'': address.TCM_numberEnd__c;
                personalAddressItem.subAddress.privateStreetName = (address.TCM_privateStreetName__c == null)?'':address.TCM_privateStreetName__c;
                personalAddressItem.subAddress.privateStreetType = (address.TCM_privateStreetType__c == null)?'':address.TCM_privateStreetType__c;
                // Details
                ManageContactRequest.Detail detailItem1 = new ManageContactRequest.Detail();
                detailItem1.detailType = (address.Sub_Address1_Type__c == null)?'':address.Sub_Address1_Type__c;
                detailItem1.value = (address.Sub_Address1_Number__c == null)?'':address.Sub_Address1_Number__c;
                ManageContactRequest.Detail detailItem2 = new ManageContactRequest.Detail();
                detailItem2.detailType = (address.Sub_Address2_Type__c == null)?'':address.Sub_Address2_Type__c;
                detailItem2.value = (address.Sub_Address2_Number__c == null)?'':address.Sub_Address2_Number__c;
                personalAddressItem.subAddress.details = new List<ManageContactRequest.Detail>();
                personalAddressItem.subAddress.details.add(detailItem1);
                personalAddressItem.subAddress.details.add(detailItem2);
                if(address.Address_Line_1__c != null){
                    personalAddressItem.subAddress.addressLines = new List<String>();
                    personalAddressItem.subAddress.addressLines.add(address.Address_Line_1__c);      
                }
                if(address.Address_Line_2__c != null){
                    personalAddressItem.subAddress.addressLines.add(address.Address_Line_2__c);      
                }
                if(address.Address_Line_3__c != null){
                    personalAddressItem.subAddress.addressLines.add(address.Address_Line_3__c);      
                }
                PersonalAddressList.add(personalAddressItem);
            }
        }
        return PersonalAddressList;
    }
    
    private static AccountContactRelation getAccountContactRelation(String accountId,String contactId){
        AccountContactRelation acr = null;
        Account acc = null;
        if(isNotNullAndBlank(accountId) && isNotNullAndBlank(contactId)) {
            List<AccountContactRelation> acrs = [SELECT AccountId,ContactId,Contact_Usage__c,Opt_Out_Telemarketing__c,Relationship_End_Date__c,Roles,Account.Account_UUID__c,Account.Customer_ID__c,Opt_Out_SMS_MMS__c,Opt_Out_Emails__c,Opt_Out_Face_to_Face__c,Opt_Out_Direct_Mail_White_Mail__c,Job_Description__c ,Job_Title__c,Relationship_Verified_Date__c,Relationship_Expiry_Date__c FROM AccountContactRelation where AccountId =:accountId AND ContactId =:contactId];
            if(!acrs.isEmpty()){
                acr = acrs[0];
                acc = acrs[0].Account;
                account=acc;
           }
        }
        return acr;
    }
   
    @TestVisible
    private static void getExistingAddresses(Id contactId){
        businessAddresses = new List<cscrm__Address__c>();
        personalAddresses = new List<cscrm__Address__c>();
        List<cscrm__Contact_Address_Relationship__c> carsList =[SELECT cscrm__Address__r.Address_ID__c,cscrm__Address__r.Address_Line_1__c,cscrm__Address__r.Address_Line_2__c,cscrm__Address__r.Address_Line_3__c,cscrm__Address__r.Address_Status__c,cscrm__Address__r.Address_Type__c,cscrm__Address__r.Building_Name__c,cscrm__Address__r.cscrm__Account__c,cscrm__Address__r.cscrm__Address_Details__c,cscrm__Address__r.cscrm__Address_Type__c,cscrm__Address__r.cscrm__Building_Name__c,cscrm__Address__r.cscrm__Building_Number__c,cscrm__Address__r.cscrm__Building_Type__c,cscrm__Address__r.cscrm__City__c,cscrm__Address__r.cscrm__Country__c,cscrm__Address__r.cscrm__External_Address_Id__c,cscrm__Address__r.cscrm__External_ID__c,cscrm__Address__r.cscrm__Geolocation__c,cscrm__Address__r.cscrm__Is_Billing_Address__c,cscrm__Address__r.cscrm__Is_Installation_Address__c,cscrm__Address__r.cscrm__Is_Registered_Office_Address__c,cscrm__Address__r.cscrm__Is_Shipping_Address__c,cscrm__Address__r.cscrm__Level_Number__c,cscrm__Address__r.cscrm__Level_Type__c,cscrm__Address__r.cscrm__Plan_Number__c,cscrm__Address__r.cscrm__Property_Name__c,cscrm__Address__r.cscrm__State_Province__c,cscrm__Address__r.cscrm__Street_Name__c,cscrm__Address__r.cscrm__Street_Number_End__c,cscrm__Address__r.cscrm__Street_Number_Start__c,cscrm__Address__r.cscrm__Street_Type__c,cscrm__Address__r.cscrm__Street__c,cscrm__Address__r.cscrm__Unit_Number__c,cscrm__Address__r.cscrm__Unit_Type__c,cscrm__Address__r.cscrm__Zip_Postal_Code__c,cscrm__Address__r.DP_Id__c,cscrm__Address__r.Id,cscrm__Address__r.Is_Primary_Address__c,cscrm__Address__r.Locality__c,cscrm__Address__r.Name,cscrm__Address__r.NBN_Location_Id__c,cscrm__Address__r.NBN_Status_Image__c,cscrm__Address__r.NBN_Status__c,cscrm__Address__r.Number_of_Sub_addresses__c,cscrm__Address__r.Parent_Address_Id__c,cscrm__Address__r.Postal_Delivery_Type__c,cscrm__Address__r.Ready_For_Service_Date__c,cscrm__Address__r.Rural_Mail_Type__c,cscrm__Address__r.Source_System__c,cscrm__Address__r.streetNumberEndSuffix__c,cscrm__Address__r.streetNumberStartSuffix__c,cscrm__Address__r.streetTypeSuffix__c,cscrm__Address__r.streetType__c,cscrm__Address__r.Street_Number_End_calc__c,cscrm__Address__r.Street_Number_From_calc__c,cscrm__Address__r.Street_Number_From__c,cscrm__Address__r.Street_Number_Start_calc__c,cscrm__Address__r.Street_Number_To__c,cscrm__Address__r.Street_Type_calc__c,cscrm__Address__r.Sub_Address1_Number__c,cscrm__Address__r.Sub_Address1_Type_Code__c,cscrm__Address__r.Sub_Address1_Type__c,cscrm__Address__r.Sub_Address2_Number__c,cscrm__Address__r.Sub_Address2_Type_Code__c,cscrm__Address__r.Sub_Address2_Type__c,cscrm__Address__r.Sub_Address_3_Number__c,cscrm__Address__r.Sub_Address_3_Type_Code__c,cscrm__Address__r.Sub_Address_3_Type__c,cscrm__Address__r.Sub_Address_4_Number__c,cscrm__Address__r.Sub_Address_4_Type_Code__c,cscrm__Address__r.Sub_Address_4_Type__c,cscrm__Address__r.Sub_Address_Level_1_calc__c,cscrm__Address__r.Sub_Address_Level_1__c,cscrm__Address__r.Sub_Address_Level_2_calc__c,cscrm__Address__r.Sub_Address_Level_2__c,cscrm__Address__r.Sub_Address_Level_3_calc__c,cscrm__Address__r.Sub_Address_Level_3__c,cscrm__Address__r.Sub_Address_Level_4_calc__c,cscrm__Address__r.Sub_Address_Level_4__c,cscrm__Address__r.Sub_Address_Number__c,cscrm__Address__r.Sub_Address_Type__c,cscrm__Address__r.TCM_additionalInfo__c,cscrm__Address__r.TCM_Address_Type_Value__c,cscrm__Address__r.TCM_internationalPostcode__c,cscrm__Address__r.TCM_internationalState__c,cscrm__Address__r.TCM_numberEnd__c,cscrm__Address__r.TCM_numberStart__c,cscrm__Address__r.TCM_privateStreetName__c,cscrm__Address__r.TCM_privateStreetTypeCode__c,cscrm__Address__r.TCM_privateStreetType__c,cscrm__Address__r.TCM_registeredPlan__c,cscrm__Address__r.TCM_status_Code__c,cscrm__Address__r.TCM_Street_Type_code__c,cscrm__Address__r.TCM_street_Type_Suffix_Code__c,cscrm__Address_Type__c,cscrm__Contact__c FROM cscrm__Contact_Address_Relationship__c where cscrm__Contact__c =:contactId AND cscrm__Address_Type__c IN ('Home Address','Office Address') AND cscrm__Active__c=true AND Primary__c=true];
        if(carsList != NULL && !carsList.isEmpty()){
            for(cscrm__Contact_Address_Relationship__c car:carsList){
                if(car.cscrm__Address_Type__c == OFFICE_ADDRESS){
                    businessAddresses.add(car.cscrm__Address__r); 
                } else if(car.cscrm__Address_Type__c == HOME_ADDRESS){
                    personalAddresses.add(car.cscrm__Address__r); 
                }
            }
        }
    }
    
    private static boolean isNotNullAndBlank(String value){
        return (value != null && String.isNotBlank(value)) ? true : false;
    }
    private static String validateDateField(Date value){
        DateTime d = value ;
        String dateStr = d.format('yyyy-MM-dd');
        return dateStr;
    } 
    @testVisible
    private static String validateDateFieldWithTZD(Datetime value){
        String dateStr = value.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        return dateStr;
    } 
    @testVisible
    private static String validateAddressStatus(String value){
        String status ='';
        if(value =='CONFIRMED') {
            status = 'CO';
        }
        else if(value == 'UNCONFIRMED'){
            status = 'UN';
        }
        return status;
    }
}