public virtual with sharing class AbstractDeploymentAutomationService implements DeploymentAutomationService{
    
    protected List<SObject> addConfigLst = new List<SObject>();
    protected Metadata.DeployContainer metaDataList = new Metadata.DeployContainer();
    protected List<SObject> deleteConfigLst = new List<SObject>();
    protected List<SObject> deleteDataList = new List<SObject>();
    protected List<SObject> addDataList = new List<SObject>();
    
    /****** METHODS RELATED TO METADATA CREATION ---- START *******/
    
    /**
     * Method to create all Error Mapping CustomMetadata
     */
    protected void createErrorMappingRecords(Metadata.CustomMetadata ErrorMappingRecord,string errorcode, string errordescription,string interfacevalue, string BusinessDescription){
        ErrorMappingRecord.values.add(addStringMetadataTypeField(ErrorMappingRecord, 'ErrorCode__c',errorcode));   
        ErrorMappingRecord.values.add(addStringMetadataTypeField(ErrorMappingRecord, 'ErrorDescription__c',errordescription)); 
        ErrorMappingRecord.values.add(addStringMetadataTypeField(ErrorMappingRecord, 'Interface__c',interfacevalue));
        ErrorMappingRecord.values.add(addStringMetadataTypeField(ErrorMappingRecord, 'BusinessDescription__c',BusinessDescription)); 
    }
    
    protected void createIntegrationHandlerRecords(Metadata.CustomMetadata Recordname, string Endpoint, string Authendpoint,string Clientid, string Clientsecret, string Scope, string Granttype,string Oathmethod,decimal timeout){       
        
        Recordname.values.add(addStringMetadataTypeField(Recordname, 'Auth_End_Point__c',Authendpoint));   
        Recordname.values.add(addStringMetadataTypeField(Recordname, 'Client_Id__c',Clientid));   
        Recordname.values.add(addStringMetadataTypeField(Recordname, 'Client_Secret__c',Clientsecret));   
        
        Recordname.values.add(addStringMetadataTypeField(Recordname, 'End_Point__c',Endpoint));
        Recordname.values.add(addStringMetadataTypeField(Recordname, 'Grant_Type__c',Granttype));
        
        Recordname.values.add(addDecimalMetadataTypeField(Recordname, 'Timeout__c',timeout));
       
        Recordname.values.add(addStringMetadataTypeField(Recordname, 'oauth_Method__c',Oathmethod));
       
        Recordname.values.add(addStringMetadataTypeField(Recordname, 'Scope__c',Scope));
    }
    
    
    
    
    
    
        
    protected Metadata.CustomMetadata createMetadataType(String fullName, String label){       
        Metadata.CustomMetadata metaDataType =  new Metadata.CustomMetadata();
        metaDataType.fullName = fullName;
        metaDataType.label = label;
        return metaDataType;
    }
    
    protected Metadata.CustomMetadataValue addStringMetadataTypeField(Metadata.CustomMetadata metaDataType, String fieldName, String fieldValue){        
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();  
        customField.field = fieldName;
        customField.value = fieldValue;    
        metaDataType.values.add(customField);
        return customField;
    }
    
    protected Metadata.CustomMetadataValue addDecimalMetadataTypeField(Metadata.CustomMetadata metaDataType, String fieldName, Decimal fieldValue){        
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();  
        customField.field = fieldName;
        customField.value = fieldValue;    
        metaDataType.values.add(customField);
        return customField;
    }
    
    protected Metadata.CustomMetadataValue addBooleanMetadataTypeField(Metadata.CustomMetadata metaDataType, String fieldName, Boolean fieldValue){        
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();  
        customField.field = fieldName;
        customField.value = fieldValue;    
        metaDataType.values.add(customField);
        return customField;
    }
    
    
   
    protected void addMetaData(Metadata.CustomMetadata metaDataType){
        metaDataList.addMetadata(metaDataType);
    }
    
    /****** METHODS RELATED TO METADATA CREATION ---- ENDS *******/
    
    
    /****** METHODS RELATED TO CUSTOM SETTINGS CREATION ---- START *******/
    
     protected void createAndAddCalloutServiceSettings(string Name, string Description, string Endpoint, string ExternalId, string Password, Decimal Timeout, string Username){       
        csbb__Callout_Service__c setRec = new csbb__Callout_Service__c();
        setRec.Name = Name;
        setRec.csbb__Description__c = Description;
        setRec.csbb__End_Point__c = Endpoint;
        setRec.External_Id__c = ExternalId;
        setRec.csbb__Password__c = Password;
        setRec.csbb__Timeout__c = Timeout;
        setRec.csbb__Username__c = Username;
        addConfigLst.add(setRec);
    }
    
    protected void createAndAddCalloutServiceMethodSettings(string Name, string CalloutService, string CertificateNames, string ExternalId, string HttpMethod, string Method, string MethodShortcut, string MethodType, string OfferAvailability, string ParameterMapping, string PayloadPath, string StaticHttpHeaders){     
        csbb__Callout_Service_Method__c setRec = new csbb__Callout_Service_Method__c();   
        setRec.Name = Name;
        setRec.csbb__Callout_Service__c = CalloutService;
        setRec.csbb__Certificate_Names__c = CertificateNames;
        setRec.External_Id__c = ExternalId;
        setRec.csbb__Http_Method__c = HttpMethod;
        setRec.csbb__Method__c = Method;
        setRec.csbb__Method_Shortcut__c = MethodShortcut;
        setRec.csbb__Method_Type__c = MethodType;
        setRec.csbb__Offer_Availability__c = OfferAvailability;
        setRec.csbb__Parameter_Mapping__c = ParameterMapping;
        setRec.csbb__Payload_Path__c = PayloadPath;
        setRec.csbb__Static_Http_Headers__c = StaticHttpHeaders;
        addConfigLst.add(setRec);
    }   
    
    protected void findAllCustomSettingsToDelete(){
        List<csbb__Callout_Service__c> delLst = [Select id from csbb__Callout_Service__c];
        List<csbb__Callout_Service_Method__c> delLst2 = [Select id from csbb__Callout_Service_Method__c];
        List<Sobject> fullLst = new List<Sobject>();
        deleteConfigLst.addAll(delLst);
        deleteConfigLst.addAll(delLst2);
    }

    public virtual void clearAllCustomSettings(){
        System.debug('***** RE-SETTING ALL CUSTOM SETTINGS *******');
        findAllCustomSettingsToDelete();
        
        if(!deleteConfigLst.isEmpty())
            delete deleteConfigLst;
    }
    
    /****** METHODS RELATED TO CUSTOM SETTINGS CREATION ---- END *******/
    
    
    public virtual void clearAllDataSetup(){
        System.debug('***** RE-SETTING ALL DATA *******');
        
    }
    
    public virtual void runAllCustomSettings(){}
    public virtual void runAllCustomMetadaTypes(){}
    public virtual void runAllDataSetup(){}
    
    
}