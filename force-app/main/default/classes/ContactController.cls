public class ContactController {
	private static Integer upper_limit = 10;
    public static Integer offset = 0;
    @testvisible private static Integer statuscode{get;set;}
    @testvisible private static String bodyresp{get;set;}
    @testvisible private static String httpURl{get;set;}
    @AuraEnabled
    public static List<Contact> getExpenses(String fname) {
        //system.debug('firstname'+fname+'Last Name'+lname+'uuid '+email );
        return [SELECT Id, FirstName, LastName, BirthDate, Email 
                FROM Contact where FirstName =:fname];
    } 
     
 
  	@AuraEnabled
    public static ContactObject getStartSearch(String fname,String lname, String bdate, String email, String conuuid, Boolean next, Boolean prev) {
        //list<ContactObject.Contact> searchResponse = new list<ContactObject.Contact>();
        ContactObject searchResponse = new ContactObject();
        system.debug('firstname'+fname+'Last Name'+lname+'uuid '+conuuid );
        
        if(lname != null && lname != '' && fname != null && fname != null){
        	searchResponse = searchByName(lname,fname,next,prev);
        }
        else if(lname != null && lname != '' && bdate != null && bdate != '') {
            searchResponse = searchByLastNameBirthDate(lname,bdate,next,prev);
        }
        
        else if(email != null && email != ''){
			searchResponse = searchByEmailAddress(email,next,prev);
        }
        else if (bdate != null && bdate != ''){
        	searchResponse = searchByBirthDate(bdate,next,prev);
        }
        else if(conuuid != null && conuuid != '') {
            searchResponse = searchByContactUUID(conuuid,next,prev);
        }
        
        
        return searchResponse;
    }
     //Search by lastname,firstname
     public static ContactObject  searchByName(String lastName, String firstName, Boolean next, Boolean prev) {
        // return [SELECT Id, FirstName, LastName, BirthDate, Email 
                //FROM Contact where FirstName = 'Test'];
        
        //return null;
        List<ContactObject.Contact> contactList =  new List<ContactObject.Contact>();
        ContactObject contactobj =  new ContactObject() ;
        String err = null;
        String result ;
        String params = '';
		
		if(offset == null) {
                offset = 0;
        }
        Boolean calloutUnsuccesful = false;
		if(next == true){
			offset =  offset + upper_limit;
		}
		if(prev == true){
		    offset = offset - upper_limit;
		}	
        try{
        params = '?firstName=' + firstName + '&lastName=' + lastName ;
        params = params + '&include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        String token = TCMApiHelper.getTCMContactToken();
        String url = EnvironmentVariable.get('tcm_contactEndpoint');
        HttpResponse resp = TCMApiHelper.callout(url+params, token);
        
        String body = resp.getBody();
        System.debug('!@#$% HTTP Response Body : ' + body);
        
        result = body;  
        if(resp.getStatusCode() != 200){
            calloutUnsuccesful = true;
            //throw new applicationException('Some Message');
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        
        ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class); 
        contactobj = contacts;
        System.debug('!@#$% Converted Object : ' + contacts);
        if(contacts != null && contacts.data != null){
            contactList = contacts.data.contacts;
        }else {
            err = result;
        }
        } /*catch(Exception excptn){
            throw excptn;
        }*/
        catch(NullPointerException e) {
            calloutUnsuccesful = true;
            throw new AuraHandledException( Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED);
        }
        catch(CalloutException ce) {
            calloutUnsuccesful = true;
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        return contactobj;
        //return contactList;
    }
    
    //Search by emailAddress
    public static ContactObject searchByEmailAddress(String emailAddress, Boolean next, Boolean prev) {
        
       List<ContactObject.Contact> contactList =  new List<ContactObject.Contact>();
        ContactObject contactobj =  new ContactObject() ;
        String err = null;
        String result ;
        String params = '';
		
		if(offset == null) {
                offset = 0;
        }
        Boolean calloutUnsuccesful = false;
		if(next == true){
			offset =  offset + upper_limit;
		}
		if(prev == true){
		    offset = offset - upper_limit;
		}	
        try{
        params = '?emailAddress=' + emailAddress;
        params = params + '&include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        String token = TCMApiHelper.getTCMContactToken();
        String url = EnvironmentVariable.get('tcm_contactEndpoint');
        HttpResponse resp = TCMApiHelper.callout(url+params, token);
        
        String body = resp.getBody();
        System.debug('!@#$% HTTP Response Body : ' + body);
        
        result = body;  
        if(resp.getStatusCode() != 200){
            calloutUnsuccesful = true;
            //throw new applicationException('Some Message');
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        
        ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class); 
        contactobj = contacts;
        System.debug('!@#$% Converted Object : ' + contacts);
        if(contacts != null && contacts.data != null){
            contactList = contacts.data.contacts;
        }else {
            err = result;
        }
        } /*catch(Exception excptn){
            throw excptn;
        }*/
        catch(NullPointerException e) {
            calloutUnsuccesful = true;
            throw new AuraHandledException( Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED);
        }
        catch(CalloutException ce) {
            calloutUnsuccesful = true;
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        return contactobj;
        //return contactList;
    }
    
    //Search By LastName,BirthDate
    public static ContactObject searchByLastNameBirthDate(String lastName, String birthdate, Boolean next, Boolean prev) {
        
	List<ContactObject.Contact> contactList =  new List<ContactObject.Contact>();
        ContactObject contactobj =  new ContactObject() ;
        String err = null;
        String result ;
        String params = '';
		
		if(offset == null) {
                offset = 0;
        }
        Boolean calloutUnsuccesful = false;
		if(next == true){
			offset =  offset + upper_limit;
		}
		if(prev == true){
		    offset = offset - upper_limit;
		}	
        try{
        params = '?lastName=' + lastName + '&birthDate=' + birthDate;
        params = params + '?include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        String token = TCMApiHelper.getTCMContactToken();
        String url = EnvironmentVariable.get('tcm_contactEndpoint');
        HttpResponse resp = TCMApiHelper.callout(url+params, token);
        
        String body = resp.getBody();
        System.debug('!@#$% HTTP Response Body : ' + body);
        
        result = body;  
        if(resp.getStatusCode() != 200){
            calloutUnsuccesful = true;
            //throw new applicationException('Some Message');
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        
        ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class); 
        contactobj = contacts;
        System.debug('!@#$% Converted Object : ' + contacts);
        if(contacts != null && contacts.data != null){
            contactList = contacts.data.contacts;
        }else {
            err = result;
        }
        } /*catch(Exception excptn){
            throw excptn;
        }*/
        catch(NullPointerException e) {
            calloutUnsuccesful = true;
            throw new AuraHandledException( Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED);
        }
        catch(CalloutException ce) {
            calloutUnsuccesful = true;
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        return contactobj;
        //return contactList;
    }
    
    //Search By Birthdate
    public static ContactObject searchByBirthDate(String birthdate, Boolean next, Boolean prev) {
        
	List<ContactObject.Contact> contactList =  new List<ContactObject.Contact>();
        ContactObject contactobj =  new ContactObject() ;
        String err = null;
        String result ;
        String params = '';
		
		if(offset == null) {
                offset = 0;
        }
        Boolean calloutUnsuccesful = false;
		if(next == true){
			offset =  offset + upper_limit;
		}
		if(prev == true){
		    offset = offset - upper_limit;
		}	
        try{
        params = '?birthDate=' + birthDate;
        params = params + '?include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        String token = TCMApiHelper.getTCMContactToken();
        String url = EnvironmentVariable.get('tcm_contactEndpoint');
        HttpResponse resp = TCMApiHelper.callout(url+params, token);
        
        String body = resp.getBody();
        System.debug('!@#$% HTTP Response Body : ' + body);
        
        result = body;  
        if(resp.getStatusCode() != 200){
            calloutUnsuccesful = true;
            //throw new applicationException('Some Message');
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        
        ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class); 
        contactobj = contacts;
        System.debug('!@#$% Converted Object : ' + contacts);
        if(contacts != null && contacts.data != null){
            contactList = contacts.data.contacts;
        }else {
            err = result;
        }
        } /*catch(Exception excptn){
            throw excptn;
        }*/
        catch(NullPointerException e) {
            calloutUnsuccesful = true;
            throw new AuraHandledException( Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED);
        }
        catch(CalloutException ce) {
            calloutUnsuccesful = true;
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        return contactobj;
        //return contactList;
    }
    //Search By UUID
    public static ContactObject searchByContactUUID(String conuuid, Boolean next, Boolean prev) {
        List<ContactObject.Contact> contactList =  new List<ContactObject.Contact>();
        ContactObject contactobj =  new ContactObject() ;
        String err = null;
        String result ;
        String params = '';
		
		if(offset == null) {
                offset = 0;
        }
        Boolean calloutUnsuccesful = false;
		if(next == true){
			offset =  offset + upper_limit;
		}
		if(prev == true){
		    offset = offset - upper_limit;
		}	
        try{
        params = '/'+conuuid;
        params = params + '?include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        String token = TCMApiHelper.getTCMContactToken();
        String url = EnvironmentVariable.get('tcm_contactEndpoint');
        HttpResponse resp = TCMApiHelper.callout(url+params, token);
        
        String body = resp.getBody();
        System.debug('!@#$% HTTP Response Body : ' + body);
        
        result = body;  
        if(resp.getStatusCode() != 200){
            calloutUnsuccesful = true;
            //throw new applicationException('Some Message');
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        
        ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class); 
        contactobj = contacts;
        System.debug('!@#$% Converted Object : ' + contacts);
        if(contacts != null && contacts.data != null){
            contactList = contacts.data.contacts;
        }else {
            err = result;
        }
        } /*catch(Exception excptn){
            throw excptn;
        }*/
        catch(NullPointerException e) {
            calloutUnsuccesful = true;
            throw new AuraHandledException( Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED);
        }
        catch(CalloutException ce) {
            calloutUnsuccesful = true;
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
        return contactobj;
        //return contactList;
    }
    
    @AuraEnabled
    public static map<String, String> contactsave(String lstRecordId){
        system.debug('contactid'+lstRecordId);
        String data =  lstRecordId.substring(1, lstRecordId.length()-1);
        String data1 = '{'+data+'}';
        system.debug('contactid'+data1);
        ContactObject.Contact contacts = (ContactObject.Contact)JSON.deserialize(data, ContactObject.Contact.class); 
        system.debug('contactid'+data);
        system.debug('contacts=='+contacts);
        list<ContactObject.CustomerAccount> custacc = contacts.customerAccounts; 
        system.debug('contacts=='+custacc);
        system.debug('contacts=='+contacts.customerAccounts);
        system.debug('id'+contacts.birthDate);
        //return 'hii';
        //List < String > oErrorMsg = new List < String > ();
        map < String, String > oErrorMsg = new map <String , String> ();
        
        list<Contact> conlist = [SELECT UUID__c From Contact WHERE UUID__c =: contacts.id];
        system.debug('conlist'+conlist);
        
        if(conlist.size() > 0){
           oErrorMsg.put(Label.CONTACT_SEARCH_ERROR_ALREADY_EXISTS, '');
        }
        else{
            /*
            Contact c = new Contact();
            //c.AccountId = contacts.Id;
            c.Salutation = contacts.title;
            c.FirstName = contacts.firstName;
            c.LastName = contacts.LastName;
            c.MiddleName = contacts.middleName;
            c.UUID__c = contacts.id;
            if(contacts.birthDate != null && contacts.birthDate != ''){
                c.Birthdate = Date.valueOf(contacts.birthDate);    
            }
            c.Contact_Status__c = contacts.status;
            
           	c.Contact_Type__c = custacc[0].ContactRelationship.contactType;
            c.Imported__c = true;
            c.Home_Email__c = contacts.homeContact.emailAddress;
            c.Home_Fax__c = contacts.homeContact.faxNumber;
            c.HomePhone__c = contacts.homeContact.phoneNumber;
            c.Mobile_Phone_Number__c = contacts.homeContact.mobileNumber;
            c.HomePhone__c = contacts.homeContact.phoneNumber;
            c.HomePhone__c = contacts.homeContact.phoneNumber;
            */
            try {
                List<Contact> contactList=new List<Contact>();
                Map<String,cscrm__Address__c> addIdobjMap=new Map<String,cscrm__Address__c>();
                Map<String,cscrm__Address__c> addIdobjMapBUS=new Map<String,cscrm__Address__c>();
                List<cscrm__Address__c> personalAddressList=new List<cscrm__Address__c>();
                List<cscrm__Address__c> businessAddressList=new List<cscrm__Address__c>();
                TCMGetContactInfo tcmgetconinfo=new TCMGetContactInfo('TCMCONTACTSEARCH');
				contactList.add(tcmgetconinfo.getcontact(contacts));
                if(contacts.personalAddress!=null){
                for(Contactobject.PersonalAddress cpadd:contacts.personalAddress){
                    personalAddressList.add(tcmgetconinfo.getTCMPersonalAddress(cpadd));  
                }
                }
                if(contacts.businessAddress!=null){
                for(Contactobject.BusinessAddress cbadd:contacts.businessAddress){
                    businessAddressList.add(tcmgetconinfo.getTCMBusinessAddress(cbadd));  
                }
                }
                if(contactList!=null && !contactList.isEmpty()){
                  Database.insert(contactList);  
                }
                
                if(personalAddressList!=null && !personalAddressList.isEmpty()){
                    system.debug('personalAddressList'+personalAddressList);
                	Database.upsert(personalAddressList,cscrm__Address__c.fields.Address_ID__c,false);
                    for(cscrm__Address__c add:personalAddressList){
           				addIdobjMap.put(add.Address_ID__c , add); 
        			}
                }
                if(businessAddressList!=null && !businessAddressList.isEmpty()){
                    system.debug('businessAddressList'+businessAddressList);
               		Database.upsert(businessAddressList,cscrm__Address__c.fields.Address_ID__c,false);
                    for(cscrm__Address__c add:businessAddressList){
           				addIdobjMapBUS.put(add.Address_ID__c , add); 
        			}
                }
                
               	relateAddressToContact(contacts,contactlist,addIdobjMap,addIdobjMapBUS); 
              	oErrorMsg.put(Label.CUSTOMER_SEARCH_INFO_CONTACTS_IMPORT_SUCCESSFUL, '');
            } 
           catch(DMLException e) {
                 
                    Logger2 logger = Logger2.getLogger('TCMContactSearchService');
   
                    logger.logMessages(httpURl, bodyresp, e.getStackTraceString(), 'Business', TCMBusinessErrorCode.getInstance().getCode(e.getMessage().toLowerCase(UserInfo.getLocale())), e.getMessage(), true, false,statuscode,'',contacts.id,TCMCustomerContactConstants.TCMERRORCODE_FAILURE);
                    oErrorMsg.put(Label.CONTACT_SEARCH_ERROR_IMPORT, ''	);
                    return oErrorMsg;
            }
           
        }
        
        return oErrorMsg;
    }
    
        private static void relateAddressToContact(ContactObject.Contact contact,List<Contact> conList,Map<String,cscrm__Address__c> persMap,Map<String,cscrm__Address__c> busMap) {
        //Created Two lists to upsert As Salesforce Doesn't permit to upsert records with same external id
        List<cscrm__contact_Address_Relationship__c> carList=new List<cscrm__contact_Address_Relationship__c>();
        List<cscrm__contact_Address_Relationship__c> carList2=new List<cscrm__contact_Address_Relationship__c>();
        
        
        
            if(contact.personalAddress!=null){
                for(contactObject.personalAddress cpers:contact.personalAddress){
                    cscrm__contact_Address_Relationship__c car = new cscrm__contact_Address_Relationship__c();
                    
                        car.cscrm__Contact__c =conList[0].id ;    
                    
                    car.cscrm__Address_Type__c = 'Home Address';
                    if( persMap!=null &&  persMap.get(cpers.addressid)!=null){
                        car.cscrm__Address__c= persMap.get(cpers.addressid).id;
                    }
                    car.ContactAddressRelationship__c = car.cscrm__Contact__c +''+ car.cscrm__Address__c;
                    carList.add(car);
                }
            }
            if(contact.businessAddress!=null){
                for(contactObject.businessAddress cbus:contact.businessAddress){
                    cscrm__contact_Address_Relationship__c car = new cscrm__contact_Address_Relationship__c();
                   
                        car.cscrm__Contact__c =conList[0].id ; 
                    
                    car.cscrm__Address_Type__c = 'Office Address';
                    if( busMap!=null && busMap.get(cbus.addressid)!=null){
                        car.cscrm__Address__c= busMap.get(cbus.addressid).id;
                    }
                    car.ContactAddressRelationship__c = car.cscrm__Contact__c +''+ car.cscrm__Address__c;
                    carList2.add(car);
                }
            }
         Database.upsert(carList,cscrm__contact_Address_Relationship__c.fields.ContactAddressRelationship__c,false);
         Database.upsert(carList2,cscrm__contact_Address_Relationship__c.fields.ContactAddressRelationship__c,false);
            
        }
    
    
    public class applicationException extends Exception {}
}