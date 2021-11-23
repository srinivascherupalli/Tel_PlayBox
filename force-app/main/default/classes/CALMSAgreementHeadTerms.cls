/*
 *   CALMSAgreementHeadTerms Class has methods to create Agreement head term record  
 */ 
public with sharing class CALMSAgreementHeadTerms extends CALMSDataProcessingAbstract {
    
    private static final String AGREEMENT_CATEGORY = 'Agreement Category';
    private static final String AGREEMENT_SUBCATEGORY = 'Agreement Subcategory';
    private static final String APPROVAL_STATUS = 'Approval Status';
    private static final String AUTO_RENEWAL = 'Auto Renewal';
    private static final String SOURCE = 'Source';
    private static final String TELSTRA_LEGAL_ENTITY = 'Telstra Legal Entity';
    private static final String VARIATION_SUMMARY_PAGE_NEEDED = 'Variation Summary Page Needed';

    //get the SA record type
    private static final Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
         
    //create a head term record based on SF/Cloudsense data
    public Apttus__APTS_Agreement__c createHeadTermsRecord(String BasketId, String primaryContact){
        //Get agteement head term details from metadata
        Map<String, String> configMap = getConfiguration('Agreement_Head_Term');
       
        //create and insert Agreement record
        Apttus__APTS_Agreement__c record = new Apttus__APTS_Agreement__c();
        record.RecordTypeId = AGREEMENT_SA_RECORDTYPEID;
        record.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
        record.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
        record.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
        record.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
        record.Apttus__Source__c = configMap.get(SOURCE);
        record.APTPS_Legacy_opportunity_ID__c = this.opp.Id;
        record.Apttus__Term_Months__c = 36;
        record.Apttus__Auto_Renew_Term_Months__c = 1;
        record.APTPS_Contract_Manager__c = UserInfo.getUserId();
        record.APTPS_Commercial_Manager__c = UserInfo.getUserId();
        record.Apttus__Requestor__c = UserInfo.getUserId();
        system.debug('Primary contact'+primaryContact);
        record.APTPS_Customer_Primary_Contact__c = primaryContact;
        record.Apttus__Account__c = this.opp.Account.Id;
        //record.Apttus__Total_Contract_Value__c = this.opp.Total_Contract_Value_Calc__c;
        //record.APTPS_Sales_Account_Executive__c = this.opp.Account.OwnerId;
        //record.APTPS_Exclusivity__c = ConversionUtils.stringtoBoolean(configMap.get(EXCLUSIVITY));
        record.Apttus__Agreement_Category__c = configMap.get(AGREEMENT_CATEGORY);
        record.APTPS_Agreement_Subcategory__c = configMap.get(AGREEMENT_SUBCATEGORY);
        //record.Apttus__Status_Category__c = configMap.get(STATUS_CATEGORY);
        record.Related_Basket__c = BasketId;
        record.Apttus__Related_Opportunity__c = this.opp.Id;
        record.Auto_Created_by_Basket__c = true;
        System.debug('REcord :'+record);
        return record;
    
    }
    
    //CALMSAgreementHeadTerms constructor to initialize opportunity and basket snapshot data
    public CALMSAgreementHeadTerms (Opportunity opp, List<sObject> lstObjects){
        super(opp, lstObjects);
    }
    
    
    //Method to create a map and insert metadata values comming from Contract Generation Metadata
    private static Map<String, String> getConfiguration(String configName) {
        Map<String, String> configMap = new Map<String, String>();
        
        try {
            Contract_Generation_Setting__mdt config = getContractGenerationSettings(configName);
            if(config != null) {
                configMap.put(AGREEMENT_CATEGORY, config.Agreement_Category__c);
                configMap.put(AGREEMENT_SUBCATEGORY, config.Agreement_Subcategory__c);
                configMap.put(APPROVAL_STATUS, config.Approval_Status__c);
                configMap.put(AUTO_RENEWAL, ConversionUtils.booleanToString(config.Auto_Renew__c));
                configMap.put(VARIATION_SUMMARY_PAGE_NEEDED, ConversionUtils.booleanToString(config.Variation_Summary_Page_Needed__c));
                //configMap.put(AUTO_RENEW_TERM_MONTHS, String.valueOf(config.Auto_Renew_Term_Months__c));
                //configMap.put(EXCLUSIVITY, ConversionUtils.booleanToString(config.Exclusivity__c));
                configMap.put(SOURCE, config.Source__c); 
                //configMap.put(STATUS_CATEGORY, config.Status_Category__c);        
                configMap.put(TELSTRA_LEGAL_ENTITY, config.Addresses_for_Notices__c);       
                //configMap.put(TERM_MONTHS,  String.valueOf(config.Term_Months__c));       
                //configMap.put(TOTAL_CONTRACT_VALUE, String.valueOf(config.Total_Contract_Value__c));      
            }
        }
        catch(Exception e) {
            return null;
        }
       
        return configMap;
    }
    
    //Method to fetch metadata 
    @TestVisible 
    private static Contract_Generation_Setting__mdt getContractGenerationSettings(String hName) {
        Contract_Generation_Setting__mdt contractGenerationSettingRecord= new Contract_Generation_Setting__mdt ();//Initialize the variable according to EDGE-66847
        
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Contract_Generation_Setting__mdt')) + '\n ' +
                          ' FROM Contract_Generation_Setting__mdt \n ' +
                          ' WHERE DeveloperName = \'' + String.escapeSingleQuotes(hName) + '\' LIMIT 1 ';
        system.debug('Query 2'+queryStr);
        System.debug('QueryStr: ' + queryStr);
        List<Contract_Generation_Setting__mdt> contractGenerationSettingRecordList = Database.query(queryStr);
       System.debug('QueryStr results: ' + queryStr);                                       
        if(contractGenerationSettingRecordList != null && !contractGenerationSettingRecordList.isEmpty() && contractGenerationSettingRecordList.get(0) != null) {
            contractGenerationSettingRecord = contractGenerationSettingRecordList.get(0);
            System.debug('setting frst contractGenerationSettingRecord');
        }
        System.debug('HandleSettingRecord: ' + contractGenerationSettingRecord);         
        return contractGenerationSettingRecord;                          
    }
    
    public override void test(){
        system.debug('test');
    }
}