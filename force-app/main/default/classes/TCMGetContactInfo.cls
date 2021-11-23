/**
* @Description : Get Contacts from TCM application based on UUID and insert/update in Force.com.
* @Author : Anu Yadav
* @Date : 21/11/2017
* @Story : EDGE-34 @story:rework  : EDGE-14572
*/
public without sharing class TCMGetContactInfo {
    
    private String sourceInterface = null;
    private TCMGetInterface getInterface = null;
    private Map<String, Contact> uuidContactMap = null;
    private Map<String,cscrm__Address__c> addIdobjMap = null;
    private Map<String,cscrm__Address__c> addIdobjMapBUS = null;
    
    public TCMGetContactInfo(String sourceInterface){
        this.sourceInterface = (sourceInterface != null && String.isNotBlank(sourceInterface)) ? sourceInterface +' TCMGetContactInfo' : 'TCMGetContactInfo';
        getInterface = TCMGetInterface.getInstance();
        uuidContactMap = new Map<String,Contact>();
    }
    
    /**
    * Upsert GetContact fields in salesforce. 
    */
    public void contactUUIDs(List<String> contactUUIDs){
        system.debug('contactUUIDs'+contactUUIDs);
        tcmContactCallOuts(contactUUIDs);
        List<ContactObject.Contact> contactList = new List<ContactObject.Contact>();
        for(String contactUUID : contactUUIDs){
            ContactObject contactObj = getInterface.tcmGetContactObject.get(contactUUID);
            if(contactObj!=null && contactObj.data!=null && contactObj.data.contacts != null && !contactObj.data.contacts.isEmpty()){
                for(ContactObject.Contact contact : contactObj.data.contacts){
                    contactList.add(contact);
                }
           }
        }
        getContactsAddresses(contactList);
        loadUUIDContactMap(contactUUIDs);
        relateAddressToContact(contactList, contactUUIDs);
        getContactsAccountContactRelationship(contactList,contactUUIDs);
        system.debug('TCMGetContactInfo -- getContacts --contactList--'+contactList);
    }
    
    private void loadUUIDContactMap(List<String> uuids){
        List<Contact> contactList = [select uuid__c,id,accountID from contact where uuid__c in :uuids];
        for(Contact contactObj : contactList){
            uuidContactMap.put(contactObj.UUID__c, contactObj);
        }
    }
    
    private void tcmContactCallOuts(List<String> contactUUIDs){
        getInterface.getContactInfo(contactUUIDs);
    }
    
    private void getContactsAddresses(List<ContactObject.Contact> contactList){
        List<Contact> conList=new List<Contact>();
        List<cscrm__Address__c> addressListBusiness = new  List<cscrm__Address__c>();
        List<cscrm__Address__c> addresssListPersonal = new  List<cscrm__Address__c>();
        Map<String,ContactObject.BusinessAddress> conAddBusMap=new Map<String,ContactObject.BusinessAddress>();
        Map<String,ContactObject.PersonalAddress> conAddPersMap=new Map<String,ContactObject.PersonalAddress>();
        if(contactList!=null && !contactList.isEmpty()){
            for(ContactObject.Contact con : contactList){
                conList.add(getcontact(con));
                if(con!=null){
                    if(con.personalAddress!=null){
                        for(ContactObject.PersonalAddress cpadd:con.personalAddress){
                            conAddPersMap.put(con.Id,cpadd);
							addresssListPersonal.add(getTCMPersonalAddress(cpadd));
                        }    
                    }
                    if(con.businessAddress!=null){
                        for(ContactObject.BusinessAddress cbadd:con.BusinessAddress){
                            conAddBusMap.put(con.Id,cbadd);
							addressListBusiness.add(getTCMBusinessAddress(cbadd));
                        }
                    }
                }
            }
        }
        upsertContact(conList);
        upsertAddress(addresssListPersonal, addressListBusiness);
    }
    
    private void upsertContact(List<Contact> conList){
        List<Database.upsertResult> dbUpsert = null;
        if(!conList.isEmpty()){
        	dbUpsert=Database.upsert(conList,Contact.fields.uuid__c,false);    
        }
        updateApplicationLogs();
        for(Integer i=0; i< conList.size(); i++){
            Database.upsertResult upserResult = dbUpsert[i];
            if(!upserResult.isSuccess()){
                for(Database.Error err : upserResult.getErrors()) {
                    TCMBusinessErrorCode.getInstance().logCustomContactExcepction(conList[i].UUID__c,'Business',err.getMessage(),err.getFields());
                    System.debug('error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());                    
                    System.debug('fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
	
	private void updateApplicationLogs(){
        Logger2 logger2log = Logger2.getLogger(sourceInterface);
        TCMGetInterface getInterface = TCMGetInterface.getInstance();
        for(String keys : getInterface.callOutDataCapture.keyset()){
            TCMGetInterface.TCMRequestResponseCapture reqResCapture = getInterface.callOutDataCapture.get(keys);
            logger2log.logMessages(reqResCapture.url, reqResCapture.httpResponse.getBody(), '', '', '', '', false, false);
        }
        if(!(System.isBatch() || System.isFuture() || System.isScheduled())){
            logger2log.exitLogger();
        }
    }
    
    private void upsertAddress(List<cscrm__Address__c> addList,List<cscrm__Address__c> addListBus){
        addIdobjMap=new  Map<String,cscrm__Address__c>();
        addIdobjMapBUS=new  Map<String,cscrm__Address__c>();
        Database.upsert(addList,cscrm__Address__c.fields.Address_ID__c,false);
        Database.upsert(addListBus,cscrm__Address__c.fields.Address_ID__c,false);
        if(addList!=null && !addList.isEmpty()){
            for(cscrm__Address__c add:addList){
                addIdobjMap.put(add.Address_ID__c , add); 
            }
        }
        if(addListBus!=null && !addListBus.isEmpty()){
            for(cscrm__Address__c add:addListBus){
                addIdobjMapBUS.put(add.Address_ID__c , add); 
            }
        } 
    }
    
	//Relating Address To Contact
    private void relateAddressToContact(List<ContactObject.Contact> contactList, List<String> uuidList) {
        //Created Two lists to upsert As Salesforce Doesn't permit to upsert records with same external id
        system.debug('uuidContactMap--relateAddressToContact--TCMGetContactInfo--'+uuidContactMap);
        List<cscrm__contact_Address_Relationship__c> carList=new List<cscrm__contact_Address_Relationship__c>();
        List<cscrm__contact_Address_Relationship__c> carList2=new List<cscrm__contact_Address_Relationship__c>();
        for(contactObject.Contact con:contactList){
            if(con.personalAddress!=null){
                for(contactObject.personalAddress cpers:con.personalAddress){
                    cscrm__contact_Address_Relationship__c car = new cscrm__contact_Address_Relationship__c();
                    if(uuidContactMap.get(con.id) !=null && uuidContactMap.get(con.id).id!=null){
                        car.cscrm__Contact__c = uuidContactMap.get(con.id).id;    
                    }
                    car.cscrm__Address_Type__c = 'Home Address';
                    if( addIdobjMap!=null &&  addIdobjMap.get(cpers.addressid)!=null && addIdobjMap.get(cpers.addressid)!=null){
                        car.cscrm__Address__c= addIdobjMap.get(cpers.addressid).id;
                    }
                    car.ContactAddressRelationship__c = car.cscrm__Contact__c +''+ car.cscrm__Address__c;
                    carList.add(car);
                }
            }
            if(con.businessAddress!=null){
                for(contactObject.businessAddress cbus:con.businessAddress){
                    cscrm__contact_Address_Relationship__c car = new cscrm__contact_Address_Relationship__c();
                    if(uuidContactMap.get(con.id)!=null && uuidContactMap.get(con.id).id!=null){
                        car.cscrm__Contact__c = uuidContactMap.get(con.id).id; 
                    }
                    car.cscrm__Address_Type__c = 'Office Address';
                    if( addIdobjMap!=null && addIdobjMapBUS.get(cbus.addressid)!=null && addIdobjMapBUS.get(cbus.addressid).id!=null){
                        car.cscrm__Address__c= addIdobjMapBUS.get(cbus.addressid).id;
                    }
                    car.ContactAddressRelationship__c = car.cscrm__Contact__c +''+ car.cscrm__Address__c;
                    carList2.add(car);
                }
            }  
        }
        //Code unbulkified to upsert addresses
        Database.upsert(carList,cscrm__contact_Address_Relationship__c.fields.ContactAddressRelationship__c,false);
        Database.upsert(carList2,cscrm__contact_Address_Relationship__c.fields.ContactAddressRelationship__c,false);
    }
    
    public Contact getcontact(ContactObject.Contact contact){
        System.debug('TCM GetContactInfo- upsert contact :'+contact);
        Contact tcmContact = new Contact();
        //tcmContact.AccountId = tcmCustomer.Id;
        tcmContact.LastName = contact.LastName;
        tcmContact.MiddleName = contact.MiddleName;
        tcmContact.Salutation = contact.title;
        tcmContact.FirstName = contact.firstName;
        if(TCMCustomerContactHelper.isNotNullAndBlank(contact.birthDate)){
            tcmContact.Birthdate = Date.valueOf(contact.birthDate);    
        }
        tcmContact.UUID__c = contact.id;
        if(TCMCustomerContactHelper.isNotNullAndBlank(contact.status)){
            tcmContact.Contact_Status__c= contact.status;
        }
        tcmContact.Imported__c = true;
        tcmContact.Pref_Comm_Method__c=contact.preferredMethod;
        if(contact.identification!=null && contact.identification.driverLicense!=null){
            tcmContact.Driver_License_Id__c=contact.identification.driverLicense.dlNumber;
            tcmContact.Driver_Licence_State__c =contact.identification.driverLicense.state;
        }
        tcmContact.Source_System__c = contact.sourceSystem;
        tcmContact.lastVerifiedDate__c = (TCMCustomerContactHelper.isNotNullAndBlank(contact.lastVerifiedDate)) ? TCMCustomerContactHelper.validateDateField(contact.lastVerifiedDate) : TCMCustomerContactHelper.setLastVerifiedDateField(contact.lastVerifiedDate);
        tcmContact.Notes__c = contact.notes;
        if(TCMCustomerContactHelper.isNotNullAndBlank(contact.numberInHousehold)){
            tcmContact.numberInHousehold__c = Decimal.valueof(contact.numberInHousehold);
        }   
        tcmContact.Occupation__c = contact.occupation;
        tcmContact.timeZone__c = contact.timeZone;
        tcmContact.Has_Reviewed__c = (String.isNotBlank(contact.reviewedFlag) && contact.reviewedFlag == 'Y')? True : False;
        tcmContact.Language_Preference__c = (String.isNotBlank(contact.languagePreference)) ? contact.languagePreference : 'English';
        tcmContact.Online_Flag__c = (String.isNotBlank(contact.onlineFlag) && contact.onlineFlag == 'Y')? True : False;
        tcmContact.Merge_Status__c = contact.mergeStatus;
        tcmContact.ParentSourceSystemAction__c = contact.parentSourceSystemAction;
        if(contact.homeContact!=null){
            tcmContact.Home_Email__c=contact.homeContact.emailAddress;
            tcmContact.Home_Fax__c = TCMCustomerContactHelper.formatNumber(contact.homeContact.faxNumber);
            tcmContact.HomePhone=TCMCustomerContactHelper.formatNumber(contact.homeContact.mobileNumber);
            tcmContact.HomePhone__c = TCMCustomerContactHelper.formatNumber(contact.homeContact.phoneNumber);
        }
        if(contact.workContact != null){
            tcmContact.Email = contact.workContact.emailAddress;
            tcmContact.MobilePhone = TCMCustomerContactHelper.formatNumber(contact.workContact.mobileNumber);
            tcmContact.Fax = TCMCustomerContactHelper.formatNumber(contact.workContact.faxNumber);
            tcmContact.Phone = TCMCustomerContactHelper.formatNumber(contact.workContact.phoneNumber);
        }
        return tcmContact;
    }

    public  cscrm__Address__c getTCMPersonalAddress(ContactObject.PersonalAddress tcmPersonalAddress){
        String numTo = '';
        cscrm__Address__c address=null;
        List<cscrm__Address__c> addList=new List<cscrm__Address__c>();
        if(tcmPersonalAddress!=null){
            if(address==null){
                address = new cscrm__Address__c();
                address.Source_System__c = '';
            }
            if(address.Source_System__c == null || String.isBlank(address.Source_System__c) || address.Source_System__c == 'TCM'){
                //Creating new Address object if address not found in SalesForce db.
                address.Address_ID__c = tcmPersonalAddress.addressId;
                address.Source_System__c = 'TCM';
                address.cscrm__External_ID__c = tcmPersonalAddress.addressId;
                address.cscrm__State_Province__c = tcmPersonalAddress.state;
                address.cscrm__Zip_Postal_Code__c = tcmPersonalAddress.postalCode;
                address.cscrm__Street_Name__c = tcmPersonalAddress.streetName;
                //address.cscrm__Street_Type__c = tcmPersonalAddress.streetType;
                address.Locality__c = tcmPersonalAddress.locality;
                address.cscrm__Address_Type__c = tcmPersonalAddress.addressType;
                address.Address_Status__c = tcmPersonalAddress.status;
                if(tcmPersonalAddress.streetNumberEnd != null){
                    numTo =tcmPersonalAddress.streetNumberEnd;
                    if (tcmPersonalAddress.streetNumberEndSuffix != null) {numTo = numTo + tcmPersonalAddress.streetNumberEndSuffix; }
                    address.Street_Number_To__c = numTo;
                }
                address.streetNumberEndSuffix__c =tcmPersonalAddress.streetNumberEndSuffix;
                address.Street_Number_From__c= tcmPersonalAddress.streetNumberStart;
                //As Per Discussion With Eureka's Designer this field is mapped
                address.Street_Number_From_calc__c=tcmPersonalAddress.streetNumberStart;
                //address.streetNumberStartSuffix__c=tcmBusinessAddress.strretNumberStartSuffix;
                address.streetType__c=tcmPersonalAddress.streetType;
                address.streetTypeSuffix__c=tcmPersonalAddress.streettypesuffix;
                address.cscrm__Country__c=tcmPersonalAddress.country;
                if(tcmPersonalAddress.subAddress != null){
                    if(tcmPersonalAddress.subAddress.numberStart != null ){
                        address.TCM_numberStart__c =tcmPersonalAddress.subAddress.numberStart; 
                    }
                    if(tcmPersonalAddress.subAddress.numberEnd != null ){
                        address.TCM_numberEnd__c =tcmPersonalAddress.subAddress.numberEnd; 
                    }
                    //address.Sub_Address1_Type__c = tcmBusinessAddress.addressTypeCode;
                    address.Sub_Address1_Number__c = address.TCM_numberStart__c + ((address.TCM_numberEnd__c != null && address.TCM_numberEnd__c != '0' && address.TCM_numberEnd__c != '') ? ('-' + address.TCM_numberEnd__c) : '');
                    //address.Sub_Address_Level_1__c = address.Sub_Address1_Type__c + ' ' + address.Sub_Address1_Number__c;
                    address.cscrm__Building_Name__c = tcmPersonalAddress.SubAddress.propertyName;
                    if(tcmPersonalAddress.subAddress.addressLines != null  && !tcmPersonalAddress.subAddress.addressLines.isEmpty()){
                        if(tcmPersonalAddress.subAddress.addressLines[0] != null){
                            address.Address_Line_1__c = tcmPersonalAddress.subAddress.addressLines[0];    
                        }
                        if(tcmPersonalAddress.subAddress.addressLines[1] != null){
                            address.Address_Line_2__c = tcmPersonalAddress.subAddress.addressLines[1];    
                        }
                        if(tcmPersonalAddress.subAddress.addressLines[2] != null){
                            address.Address_Line_3__c = tcmPersonalAddress.subAddress.addressLines[2];    
                        }
                    }
                    if(tcmPersonalAddress.SubAddress.details != null){
                        if(tcmPersonalAddress.SubAddress.details[0]!=null){
                            address.Sub_Address2_Number__c = tcmPersonalAddress.SubAddress.details[0].value;
                            address.Sub_Address2_Type__c = tcmPersonalAddress.SubAddress.details[0].detailType;
                            
                        }
                        if(tcmPersonalAddress.SubAddress.details[1]!=null){
                            address.Sub_Address_3_Number__c = tcmPersonalAddress.SubAddress.details[1].value;
                            address.Sub_Address_3_Type__c = tcmPersonalAddress.SubAddress.details[1].detailType;
                        }
                    }
                }
                address.cscrm__Is_Billing_Address__c = true; 
            }
        }
        return address;
    }
    public cscrm__Address__c getTCMBusinessAddress(ContactObject.BusinessAddress tcmBusinessAddress){ 
        String numTo = '';
        cscrm__Address__c address=null;
        if(tcmBusinessAddress!=null){
            if(address==null){
                address = new cscrm__Address__c();
                address.Source_System__c = '';
            }
            if(address.Source_System__c == null || String.isBlank(address.Source_System__c) || address.Source_System__c == 'TCM'){
                //Creating new Address object if address not found in SalesForce db.
                address.Address_ID__c = tcmBusinessAddress.addressId;
                address.Source_System__c = 'TCM';
                address.cscrm__External_ID__c = tcmBusinessAddress.addressId;
                address.cscrm__State_Province__c = tcmBusinessAddress.state;
                address.cscrm__Zip_Postal_Code__c = tcmBusinessAddress.postalCode;
                address.cscrm__Street_Name__c = tcmBusinessAddress.streetName;
                //address.cscrm__Street_Type__c = tcmPersonalAddress.streetType;
                address.Locality__c = tcmBusinessAddress.locality;
                address.cscrm__Address_Type__c = tcmBusinessAddress.addressType;
                address.Address_Status__c = tcmBusinessAddress.status;
                
                if(tcmBusinessAddress.streetNumberEnd != null){
                    numTo =tcmBusinessAddress.streetNumberEnd;
                    if (tcmBusinessAddress.streetNumberEndSuffix != null) {numTo = numTo + tcmBusinessAddress.streetNumberEndSuffix; }
                    address.Street_Number_To__c = numTo;
                }
                address.streetNumberEndSuffix__c =tcmBusinessAddress.streetNumberEndSuffix;
                address.Street_Number_From__c= tcmBusinessAddress.streetNumberStart;
                //As Per Discussion With Eureka's Designer this field is mapped
                address.Street_Number_From_calc__c=tcmBusinessAddress.streetNumberStart;
                //address.streetNumberStartSuffix__c=tcmBusinessAddress.strretNumberStartSuffix;
                address.streetType__c=tcmBusinessAddress.streetType;
                address.streetTypeSuffix__c=tcmBusinessAddress.streettypesuffix;
                address.cscrm__Country__c=tcmBusinessAddress.country;
                if(tcmBusinessAddress.subAddress != null){
                    if(tcmBusinessAddress.subAddress.numberStart != null ){
                        address.TCM_numberStart__c =tcmBusinessAddress.subAddress.numberStart; 
                    }
                    if(tcmBusinessAddress.subAddress.numberEnd != null ){
                        address.TCM_numberEnd__c =tcmBusinessAddress.subAddress.numberEnd; 
                    }
                    //address.Sub_Address1_Type__c = tcmBusinessAddress.addressTypeCode;
                    address.Sub_Address1_Number__c = address.TCM_numberStart__c + ((address.TCM_numberEnd__c != null && address.TCM_numberEnd__c != '0' && address.TCM_numberEnd__c != '') ? ('-' + address.TCM_numberEnd__c) : '');
                    //address.Sub_Address_Level_1__c = address.Sub_Address1_Type__c + ' ' + address.Sub_Address1_Number__c;
                    address.cscrm__Building_Name__c = tcmBusinessAddress.SubAddress.propertyName;
                    if(tcmBusinessAddress.subAddress.addressLines != null  && !tcmBusinessAddress.subAddress.addressLines.isEmpty()){
                        if(tcmBusinessAddress.subAddress.addressLines[0] != null){
                            address.Address_Line_1__c = tcmBusinessAddress.subAddress.addressLines[0];    
                        }
                        if(tcmBusinessAddress.subAddress.addressLines[1] != null){
                            address.Address_Line_2__c = tcmBusinessAddress.subAddress.addressLines[1];    
                        }
                        if(tcmBusinessAddress.subAddress.addressLines[2] != null){
                            address.Address_Line_3__c = tcmBusinessAddress.subAddress.addressLines[2];    
                        }
                    }
                    if(tcmBusinessAddress.SubAddress.details != null){
                        if(tcmBusinessAddress.SubAddress.details[0]!=null){
                            address.Sub_Address2_Number__c = tcmBusinessAddress.SubAddress.details[0].value;
                            address.Sub_Address2_Type__c = tcmBusinessAddress.SubAddress.details[0].detailType;
                            //address.Sub_Address2_Type_Code__c = tcmPersonalAddress.SubAddress.details[0].detailTypeCode;
                            //address.Sub_Address_Level_2__c = address.Sub_Address2_Type__c + ' ' + address.Sub_Address2_Number__c;
                        }
                        if(tcmBusinessAddress.SubAddress.details[1]!=null){
                            address.Sub_Address_3_Number__c = tcmBusinessAddress.SubAddress.details[1].value;
                            address.Sub_Address_3_Type__c = tcmBusinessAddress.SubAddress.details[1].detailType;
                            //address.Sub_Address_3_Type_Code__c = tcmPersonalAddress.SubAddress.details[1].detailTypeCode;
                            //address.Sub_Address_Level_3__c = address.Sub_Address_3_Type__c + ' ' + address.Sub_Address_3_Number__c;
                        }
                    }
                }
                address.cscrm__Is_Billing_Address__c = true; 
            }
        }
        return address;
    }
    
    //ACR Mapping
    private void getContactsAccountContactRelationship(List<ContactObject.Contact> contactList,List<String> uuidList){
		
		List<AccountContactRelation> updatedACRList = new List<AccountContactRelation>();
		Map<Id,Id> mapContactAccountId = new Map<Id,Id>();
        List<Id> accountIds = new List<Id>();
        Set<Id> contactIds = new Set<Id>();
		for(Contact con : [Select Id,AccountId from Contact where UUID__c IN: uuidList]){
			contactIds.add(con.Id);
            accountIds.add(con.AccountId);
		}
		List<AccountContactRelation> accRList = [Select id, contactid, AccountId,Contact_Type__c,Contact_Usage__c,Composite_Key__c,Relationship_End_Date__c,Job_Description__c,Job_Title__c from AccountContactRelation where contactid IN: contactIds and accountid IN: accountIds];
		
        system.debug('accRList=='+accRList);
        system.debug('uuidContactMap=='+uuidContactMap);
        if(!accRList.isEmpty()){
            for(ContactObject.Contact contact : contactList){
                for(AccountContactRelation acrs:accRList){
                    if(acrs.contactId==uuidContactMap.get(contact.id).id && acrs.accountId==uuidContactMap.get(contact.id).accountId){
                        //acrs.Job_Description__c = contact.jobDescription;
                        acrs.Job_Title__c = contact.jobTitle;
                        acrs.Relationship_Verified_Date__c = TCMCustomerContactHelper.validateDateField(contact.customerAccounts[0].contactRelationship.verifiedDate);
                        acrs.Relationship_Expiry_Date__c = TCMCustomerContactHelper.validateDateField(contact.customerAccounts[0].contactRelationship.expiryDate);
                        updatedACRList.add(acRs);
                    }
                }
            }       
        }
        upsertAccountContactRelation(updatedACRList);
	}
	
	 private void upsertAccountContactRelation(List<AccountContactRelation> acrList){
        List<Database.upsertResult> dbUpsert = null;
        if(!acrList.isEmpty()){
        	dbUpsert=Database.upsert(acrList,AccountContactRelation.fields.Composite_Key__c,false);    
        }
        updateApplicationLogs();
        for(Integer i=0; i< acrList.size(); i++){
            Database.upsertResult upserResult = dbUpsert[i];
            if(!upserResult.isSuccess()){
                for(Database.Error err : upserResult.getErrors()) {
                    TCMBusinessErrorCode.getInstance().logCustomContactExcepction(acrList[i].Composite_Key__c,'Business',err.getMessage(),err.getFields());
                    System.debug('error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());                    
                    System.debug('fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

}