/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to callout the external interfaces
*/

public with sharing class TCMContactSearchController {
    
    public String requestLabel;
    public String result {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String birthDate {get; set;}
    public String emailAddress {get; set;}
    public String uuid {get; set;}
    public Boolean includeCustomer {get; set;}
    public String params {get; set;}
    
    public JSON2TCMContactCustomerObject contactCustomers {get;set;}
    public ContactObject contacts {get;set;}
    public String err {get;set;}
    public List<ContactObject.Contact> contactList {get; set;}
    
    private static Integer upper_limit = 25;
    private static Integer offset = 0;

    public TCMContactSearchController() {
        includeCustomer = false;
    }
    
    public void startSearch() {
    
        Object searchResponse;
        
        if(lastName != null && lastName != '' && firstName != null && firstName != null && birthDate != null && birthDate != '') {
            searchResponse = searchByNameBirthDate();
        }
        
        else if(lastName != null && lastName != '' && firstName != null && firstName != null && emailAddress != null && emailAddress != ''){
            searchResponse = searchByNameEmailAddress();
        }
        
        else if(uuid != null && uuid != '') {
            searchResponse = searchByContactUUID();
        }
        
    }

    //Search by FirstName, LastName & birthDate
    public Object searchByNameBirthDate() {
        
        
        this.err = null;
        params = '?firstName=' + firstName + '&lastName=' + lastName + '&birthDate=' + birthDate;
        params = params + '&include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        String token = TCMApiHelper.getTCMContactToken();
        String url = EnvironmentVariable.get('tcm_contactEndpoint');
        HttpResponse resp = TCMApiHelper.callout(url+params, token);
        
        String body = resp.getBody();
        System.debug('!@#$% HTTP Response Body : ' + body);
        
        this.result = body;  
        ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class); 
        System.debug('!@#$% Converted Object : ' + contacts);
        if(contacts != null && contacts.data != null){
            contactList = contacts.data.contacts;
        }else {
            err = this.result;
        }
        return contacts;
    }
    
    //Search by FirstName, LastName & emailAddress
    public Object searchByNameEmailAddress() {
        
        this.err = null;
        params = '?firstName=' + firstName + '&lastName=' + lastName + '&emailAddress=' + emailAddress;
        params = params + '&include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        String token = TCMApiHelper.getTCMContactToken();
        String url = EnvironmentVariable.get('tcm_contactEndpoint');
        HttpResponse resp = TCMApiHelper.callout(url+params, token);
        
        String body = resp.getBody();
        System.debug('!@#$% HTTP Response Body : ' + body);
        
        this.result = body;  
        ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class); 
        System.debug('!@#$% Converted Object : ' + contacts);
        if(contacts != null && contacts.data != null){
            contactList = contacts.data.contacts;
        }else {
            err = this.result;
        }
        return contacts;
    }
    
    
    public Object searchByContactUUID() {
        this.err = null;
        params = '/'+uuid;
        params = params + '?include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        String token = TCMApiHelper.getTCMContactToken();
        String url = EnvironmentVariable.get('tcm_contactEndpoint');
        HttpResponse resp = TCMApiHelper.callout(url+params, token);
        
        String body = resp.getBody();
        System.debug('!@#$% HTTP Response Body : ' + body);
        
        this.result = body;  
        ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class); 
        System.debug('!@#$% Converted Object : ' + contacts);
        if(contacts != null && contacts.data != null){
            contactList = contacts.data.contacts;
        }else {
            err = this.result;
        }
        
        return contacts;
    }
    
    public void next(){
        offset++;  
        startSearch();
    }
    
    public void previous(){
        offset--;  
        startSearch();
    }
}