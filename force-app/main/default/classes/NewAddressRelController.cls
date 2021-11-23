public without sharing class NewAddressRelController { 
    @AuraEnabled
    public static String saveNewAddressRel(String addressType, String account, String address,Boolean active){
        cscrm__Account_Address_Relationship__c accountAddressRelationship = new cscrm__Account_Address_Relationship__c();
        accountAddressRelationship.cscrm__Address_Type__c = addressType;
        accountAddressRelationship.cscrm__Account__c = account;
        accountAddressRelationship.cscrm__Address__c = address;
        if(hasAddress(addressType,account)){
            accountAddressRelationship.cscrm__Active__c = true;
        } 
        //accountAddressRelationship.cscrm__Active__c = active;
        return AddressAndSiteObjectUtility.addressRelSaveUtility(accountAddressRelationship); 
    }
	@AuraEnabled
    public static List<SelectOptionz> getaddressTypes(){
        return AddressAndSiteObjectUtility.getaddressTypes();
    }
	
	@AuraEnabled
    public static Boolean hasAddress(String addressType,String account){
        List<cscrm__Account_Address_Relationship__c> accAddressRelationship = [SELECT Id, cscrm__Account__c, cscrm__Address_Type__c FROM cscrm__Account_Address_Relationship__c where cscrm__Active__c = true and cscrm__Account__c = :account and cscrm__Address_Type__c = :addressType];
        return accAddressRelationship.isEmpty();
    }
    /**
     * US48003
     * Get address type by using address Id.      
     * @param:  address           Address Id to get the address type.
     * @return  sObject   AddressType record.
     */  
    @AuraEnabled
    public static sObject getAddressType(String address){
        sObject AddressType;       
		AddressType = Database.query('select cscrm__Address_Type__c from cscrm__Address__c where Id = : address'); 
        return AddressType;
    }
	
	/**
     * US48003
     * Get address name by using address Id.      
     * @param:  addressId           Address Id to get the address type.
     * @return  String   address name.
     */  
	@AuraEnabled
    public static String getAddressNameSFDC(String addressId){
        String addressName = '';
        try{
            if(!String.isEmpty(addressId)){
            	cscrm__Address__c addressRecord = [SELECT Street_Number_Start_calc__c, Street_Number_End_calc__c, cscrm__Street_Name__c, Street_Type_calc__c, Locality__c FROM cscrm__Address__c WHERE Id =:addressId];
                String streetNumberStart = (null != String.valueOf(addressRecord.Street_Number_Start_calc__c)? String.valueOf(addressRecord.Street_Number_Start_calc__c) : '');
                String streetNumberEnd = (null != String.valueOf(addressRecord.Street_Number_End_calc__c)? String.valueOf(addressRecord.Street_Number_End_calc__c) : '');
                String streetName = (null != String.valueOf(addressRecord.cscrm__Street_Name__c)? String.valueOf(addressRecord.cscrm__Street_Name__c) : '');
                String streetType = (null != String.valueOf(addressRecord.Street_Type_calc__c)? String.valueOf(addressRecord.Street_Type_calc__c) : '');
                String locality = (null != String.valueOf(addressRecord.Locality__c)? String.valueOf(addressRecord.Locality__c) : '');
                addressName = streetNumberStart + ' ' + streetNumberEnd + ' ' + streetName + ' ' + streetType + ' ' + ' ' + locality;
            }
            system.debug('address Name : '+addressName);
            return addressName;
        }catch(Exception e){
            system.debug('Exception while getting address details :'+e.getMessage());
        }
        system.debug('Site Name : '+addressName);
        return addressName;
    }
    
	/**
     * US48003
     * Get parent account record.      
     * @param:  addressId           Address Id to get the address type.
     * @return  sObject   Parent Account record.
     */  
    @AuraEnabled
   public static sObject getParentAccount(String accountId){
        Account accountRecord = New Account();
        try{
            if(!String.isEmpty(accountId)){
                Account accountDetails =Database.query('SELECT Id, Name FROM Account WHERE ID =:accountId');
                accountRecord = accountDetails;
               }
            return accountRecord;
        }catch(Exception e){
            system.debug('Exception while loading account details :'+e.getMessage());
        }
        return accountRecord;
    }
    
}