/*********************************************************************************************************************************
Class Name : CreateMacOPty_Basket
Test Class : CreateMacOPty_BasketTest
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
1.        shubhi V              16/07/2020      EDGE-154023(new component)
2.        Aman Soni             18/09/2020      EDGE-167800 ..
3         Dheeraj Bhatt         26-Nov-2020     EDGE-185845  Ability to skip Quote and Contract for orders that are migrated from AM-L to AM-D
*********************************************************************************************************************************/
public with sharing class CreateMacOPty_Basket {
    private static final String OPPORTUNITY_REC_TYPE = 'Enterprise - In Contract';
    private static final String OPPORTUNITY_STAGE = 'Develop';
    private static final String OPPORTUNITY_TYPE_MAC = 'MACs (Moves, Adds & Change)';
    private static final String OPPORTUNITY_TYPE_DISCONNECT = 'Disconnect';
    private static final String OPPORTUNITY_PRODUCT_TYPE = 'Modular';
    private static final String OPPORTUNITY_PRIMARY_DOMAIN = 'Other';
    private static final String OPPORTUNITY_IN_CONTRACT = 'Yes';
    private static final String CHANGE_TYPE_MODIFY = 'Modify';
    private static final String CHANGE_TYPE_CANCEL = 'Cancel';
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');//EDGE-185845-Dheeraj Bhatt- Get the constant value from metadata
    @AuraEnabled(cacheable=false)
    public static String  CreateMacOPtyAndBasket (Id conId,Id accountId){
      List<Schema.SObjectType> sObjectTypeList = new Schema.SObjectType[] { Opportunity.SObjectType,OpportunityContactRole.SObjectType,cscfga__Product_Basket__c.SObjectType};// updated the order as uow needs parent first
      SObjectUnitOfWork UoW = new SObjectUnitOfWork(sObjectTypeList);
        if(conId!=null && accountId!=null){
            Opportunity opp = getOpportunity(accountId);
            UoW.registerNew(opp);
            OpportunityContactRole ocr = getOCR(conId);
            UoW.registerNew(ocr);
            UoW.registerRelationship(ocr, OpportunityContactRole.OpportunityId, opp);     
            cscfga__Product_Basket__c baskt = getBasket(accountId);
           UoW.registerNew(baskt);
           UoW.registerRelationship(baskt, cscfga__Product_Basket__c.cscfga__Opportunity__c, opp);     
           //system.debug('@@uow-->'+uow);
           UoW.commitWork();
            return baskt.id;
        }else{
            return null;
        }
    }
     // opportunity Contact Role
    @AuraEnabled
    public static OpportunityContactRole getOCR(Id conId){
        OpportunityContactRole ocr = new OpportunityContactRole();
        if(conId!=null){
            ocr.ContactId = conId;
            ocr.Role='Decision Maker';
        }
        return ocr;
    }
    //  opportunity 
    @AuraEnabled
    public static Opportunity getOpportunity(Id accountId){
        Opportunity opp = new Opportunity();
        String profileName=ShowSolutionsOnMACButtonController.getCurrentUserProfile() ;        
        if(accountId!=null){
            opp.Name = 'Existing Price Schedule_NewSolution_' + String.valueOf(Date.Today().format()); 
            opp.StageName = OPPORTUNITY_STAGE;
            opp.CloseDate = date.today().addDays(30);
            opp.Revenue_Impact_Date__c = opp.CloseDate + 15;//Added by Aman Soni for EDGE-167800
            opp.Product_Type__c = OPPORTUNITY_PRODUCT_TYPE;
            opp.Product_Domain__c = OPPORTUNITY_PRIMARY_DOMAIN;
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPPORTUNITY_REC_TYPE).getRecordTypeId();      
            opp.RecordTypeId = oppRecordTypeId;
            //EDGE-185845-Dheeraj Bhatt-Checking  logged in user is BOH User if yes then assign opportunity type to Migration
            if(customMetadataNameValueMap.containsKey('MigrationUserProfile') && profileName == customMetadataNameValueMap.get('MigrationUserProfile').get('Value__c') ){
                opp.Type= String.valueOf(customMetadataNameValueMap.get('Migration').get('Value__c'));
            }
            else {
                opp.Type=OPPORTUNITY_TYPE_MAC;   
            }
             opp.In_Contract_MAC__c = OPPORTUNITY_IN_CONTRACT;
            opp.IS_MACD__c = true; 
            opp.AccountID = accountId;
            opp.Pricing_Method__c='Complex';
            opp.description='Existing Price Schedule_NewSolution';
            if(FeatureManagement.checkPermission('Partner_User')){
                
            }
        }
        return opp;
    }
    // basket
    @AuraEnabled
    public static cscfga__Product_Basket__c getBasket(Id accountId){
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        if(accountId!=null){
            basket.csordtelcoa__Account__c=accountId;
        }
        return basket;
    }
}