/**
* @Author   :   Maq, Lokesh - Latest
* @Date     :   Aug 2020
* @Desc     :   This class is written for Creating agreement Records.
* @US       :   EDGE-165484, EDGE-165483,EDGE-165485
* @Status   :   End point Deveopment is still pending.
* 
* */
public with sharing class AgreementRecordContract {
    private static final Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
    private static final Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    private static final Id AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Product_Key_Facts').getRecordTypeId();
    private static final Id GENERAL_PRODUCT_TERMS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('General_Product_Terms').getRecordTypeId();
    private static final Id APPLICATION_FORM_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Application_Form').getRecordTypeId();
    public static set < Id > activeContractJunId = new set < id > (); //Variable Added to store agreement record
    public static list < Id > CJ_Id = new list < id > ();
    public static list < Apttus__APTS_Agreement__c > agreementRecords = New list < Apttus__APTS_Agreement__c > ();
    public static list < Apttus__APTS_Agreement__c > agreementChildRecords = New list < Apttus__APTS_Agreement__c > ();
    public static list < Apttus__AgreementLineItem__c > agreementLineitemRecords = New list < Apttus__AgreementLineItem__c > ();
    public static list<cscfga__Product_Configuration__c> ProductConfigList=new list<cscfga__Product_Configuration__c>();
    private static final String AGREEMENT_CATEGORY = 'Agreement Category';
    private static final String AGREEMENT_Subtype = 'Agreement Subtype';
    private static final String AGREEMENT_SUBCATEGORY = 'Agreement Subcategory';
    private static final String APPROVAL_STATUS = 'Approval Status';
    private static final String AUTO_RENEWAL = 'Auto Renewal';
    private static final String SOURCE = 'Source';
    private static final String TELSTRA_LEGAL_ENTITY = 'Telstra Legal Entity';
    private static final String VARIATION_SUMMARY_PAGE_NEEDED = 'Variation Summary Page Needed';
    public static String contractTypeGlobal = '';
    public static String psProductFamilies = '';
    public static String prodname = 'Adaptive Mobility';
    public static map<id,ContractJunction__c> cjRelatedvalueMp=new map<id,ContractJunction__c>();
    public static id parentAgreement;
    public static id ChildAgreement;
    public static id prodRecord;
    public static List<String> contractFileName; //EDGE-176732
    private static String DSAfileNameSigned;
    private static String PriceSchedulefileNameSigned;
    private static String OrderFormfileNameSigned;
    public static Date signeddate;
    public static Date otherPartySingedDate;
    public static string Recname;
    public static Map <String, Boolean> isDSAPresentInPc = new Map <String, Boolean>();
    
    @InvocableMethod(label = 'Agreement record creation'
                     description = 'Inserts the parent agreement specified and related child agreement')
    public static void createAgreementForContract(list < ContractJunction__c > ContractJunction) {
        
        try {
            // EDGE-176732 <Tech story> CALMS status post initial agreement records creation- Part 2 | Maq
             AllCQEnvironmentVariable cqVariables = new AllCQEnvironmentVariable();
            contractFileName = new List<String>(AllCQEnvironmentVariable.getValueAsList('DSAFilename')); 
            
            for (ContractJunction__c currentContractRecord: ContractJunction) {
                if (currentContractRecord.Status__c == 'In Effect' && currentContractRecord.Agreement_Number__c != null) { //Added condition for EDGE-39832
                    activeContractJunId.add(currentContractRecord.Id);
                }
                else {
                    CJ_Id.add(currentContractRecord.Id);
                    
                }
            }
            list<ContractJunction__c> ContractJunctionRec=[SELECT Id, Account__r.Owner.Id,Account__r.Owner.Name,Customer_Primary_Contact__r.name,Account__r.APTPS_Contract_Manager__c,Account__r.APTPS_Commercial_Manager__c,Related_Opportunity__r.Amount FROM ContractJunction__c WHERE ID IN: CJ_Id];
            if(ContractJunctionRec.size()>0){
                for(ContractJunction__c c: ContractJunctionRec){
                    cjRelatedvalueMp.put(c.Id, c);
                }
            }
            if (activeContractJunId.size() > 0) {
                // activateAgreementDocuments(activeContractJunId);//Calling Function for Added condition for EDGE-39832
            }
            else {
              
            list<dsfs__DocuSign_Recipient_Status__c> signedInformation = [SELECT id,name, SignedOnPaper__c,dsfs__Date_Signed__c FROM dsfs__DocuSign_Recipient_Status__c WHERE ContractJunction__c IN: CJ_Id];
                if(signedInformation.size() > 2 && (signedInformation[2].dsfs__Date_Signed__c!=null)){
                        signeddate = Date.valueof(signedInformation[2].dsfs__Date_Signed__c);
                        system.debug('signeddate :' + signeddate);
                    }
                if(signedInformation.size() > 1 && (signedInformation[1].dsfs__Date_Signed__c!=null)){
                        otherPartySingedDate = Date.valueof(signedInformation[1].dsfs__Date_Signed__c);
                        system.debug('signeddate :' + signeddate);
                    }
                 if(signedInformation.size() > 1 && (signedInformation[1].name!=null)){
                        Recname = signedInformation[1].name;
                        system.debug('signeddate :' + signeddate);
                    }
                isDSAPresentInPc = validationForAgreementCreation(ContractJunction, 'DSA');
                System.debug('***********>isDSAPresentInPc: '+isDSAPresentInPc);
                //call to create DSA
                list < Apttus__APTS_Agreement__c > agreementSA = New list < Apttus__APTS_Agreement__c > ();
                if(isDSAPresentInPc.containsKey('isAgreementGeneratedDSA') && isDSAPresentInPc.get('isAgreementGeneratedDSA') == false)
                {
                    agreementSA = mapAgreementWithContract(ContractJunction, AGREEMENT_SA_RECORDTYPEID, 'Agreement_Head_Term', false, NULL);
                    agreementRecords.addAll(agreementSA);
                    Database.SaveResult[] agmt = performDML(agreementRecords);
                    if(agmt.size() > 0){
                        parentAgreement = agmt[0].getId();
                        system.debug('@@@@@@parentAgreement'+parentAgreement);
                    }
                }
                //call to create PS
                list < Apttus__APTS_Agreement__c > agreementPS = New list < Apttus__APTS_Agreement__c > ();
                if(isDSAPresentInPc.containsKey('isAgreementGeneratedPricing') && isDSAPresentInPc.get('isAgreementGeneratedPricing') == false)
                {
                    /*   
                        agreementPS = createChildAgreementData(ContractJunction, AGREEMENT_Schedule_RECORDTYPEID, 'Agreement_Schedule_Term', false, parentAgreement);
                        agreementChildRecords.addAll(agreementPS);
                        Database.SaveResult[] childagmt = performDML(agreementChildRecords);
                        if(childagmt.size() > 0){
                        ChildAgreement = childagmt[0].getId();
                        }
                    */
                }
                if(isDSAPresentInPc.containsKey('isAgreementGeneratedPS') && isDSAPresentInPc.get('isAgreementGeneratedPS') == false)
                {
                    system.debug('#####$$$$');
                    system.debug('@@@@@@@parentAgreement '+parentAgreement);
                    id parentid;
                    if(parentAgreement == NULL) {
                        map<id,Apttus__APTS_Agreement__c> agmtrec =new Map<Id,Apttus__APTS_Agreement__c>([SELECT  Id, Name,Apttus__Parent_Agreement__c FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c=:CJ_Id and Apttus__Parent_Agreement__c=null]);
                        set<ID> SetAGGID = new set<ID>();
                        SetAGGID = agmtrec.keySet();
                        system.debug('@@@ SetAGGID '+SetAGGID);
                        list<id> ids=new list<id>();
                        ids.addall(SetAGGID);
                        parentid=ids[0];
                        parentAgreement = ids[0];
                    }
                    else{
                        parentid = parentAgreement;
                    }
                    system.debug('@@@@@ parentid'+parentid);
                    agreementPS = createChildAgreementData(ContractJunction, AGREEMENT_Schedule_RECORDTYPEID, 'Agreement_Schedule_Term', false,parentid);
                    agreementChildRecords.addAll(agreementPS);
                    Database.SaveResult[] childagmt = performDML(agreementChildRecords);
                    if(childagmt.size() > 0){
                        ChildAgreement = childagmt[0].getId();
                    }
                    system.debug('@@childagmt'+childagmt);
                }
                
                // AgreementLineItems record creation block
                list < Apttus__AgreementLineItem__c > agreementLI= new list < Apttus__AgreementLineItem__c >();  
                if(isDSAPresentInPc.containsKey('isAgreementGeneratedPS') && isDSAPresentInPc.get('isAgreementGeneratedPS') == false)
                {
                    agreementLI = createAgreementLineItem(ProductConfigList,ChildAgreement);
                    agreementLineitemRecords.addAll(agreementLI);
                    if(agreementLineitemRecords.size() > 0)
                        Database.SaveResult[] agmtLT = performDML(agreementLineitemRecords);
                }
                
                
                // File Copy fron Conga to Apptus : EDGE-176732 <Tech story> CALMS status post initial agreement records creation- Part 2
                if(parentAgreement != NULL || ChildAgreement != NULL ){
                    generateContentFileforAgmt(true, CJ_Id);
                    updateCJStatus(JSON.serialize(ContractJunction),String.valueOf(parentAgreement));
                } 
            }
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.INFO, 'Error occurred## ' + ex.getMessage());
            System.debug(LoggingLevel.INFO, 'Error Line## ' + ex.getLineNumber());
            System.debug(LoggingLevel.INFO, 'Error Trace## ' + ex.getStackTraceString());
            System.debug(LoggingLevel.INFO, 'Error Cause## ' + ex.getCause());
        }
    }
    public static map<String, boolean> validationForAgreementCreation(list < ContractJunction__c > conJunctionRecord , String contractType) {
        
        String AgreementCategoryDSA = 'Digital Services';
        String AgreementCategoryBSA = 'Business Services';
        string AgreementCategoryPricing='Pricing';
        String recordTypePriceSchedule = 'Schedule';
        Boolean isAgreementGeneratedDSA = false;
        Boolean isAgreementGeneratedBSA = false;
        Boolean isAgreementGeneratedPS = false;
        Boolean isAgreementGeneratedPricing = false;
        String psProductFamilies = '';
        map<String, boolean> agreementFlags = new map<String, boolean>();
        if(conJunctionRecord.size()> 0){
            if(conJunctionRecord[0].isDSAGenerated__c == true){  // DSA/BSA Related record check
                list<Apttus__APTS_Agreement__c> relatedAgreementsDSA_BSA = [SELECT  Id, Name, apttus__account__c, recordtype.name, apttus__agreement_category__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__c=: conJunctionRecord[0].Account__c AND (RecordTypeId=: AGREEMENT_SA_RECORDTYPEID OR RecordTypeId=: AGREEMENT_Schedule_RECORDTYPEID OR Apttus__Agreement_Category__c =:AgreementCategoryDSA OR Apttus__Agreement_Category__c =: AgreementCategoryBSA OR Apttus__Agreement_Category__c=: AgreementCategoryPricing )  AND Apttus__Status__c !='Cancelled Request'];
                if(relatedAgreementsDSA_BSA.size() > 0){
                    for(Apttus__APTS_Agreement__c relatedAgreement: relatedAgreementsDSA_BSA){
                        if(relatedAgreement.Apttus__Agreement_Category__c == AgreementCategoryDSA){
                              isAgreementGeneratedDSA = true;
                        }
                        if(relatedAgreement.Apttus__Agreement_Category__c == AgreementCategoryBSA){
                            isAgreementGeneratedBSA = true;
                        }
                        if(relatedAgreement.Apttus__Agreement_Category__c == AgreementCategoryPricing){
                            isAgreementGeneratedPricing = true;
                        }
                    }
                }
            }
            
            set<String> productFamilySet = new set<String>();
            list<cscfga__Product_Configuration__c> pcConfig = [SELECT id, Name, Marketable_Offer__r.Contract_Type__c, Marketable_Offer__r.Product_Family__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: conJunctionRecord[0].Related_Basket__c]; 
            if(pcConfig.size() > 0){
                for(cscfga__Product_Configuration__c pcForMarketOffer : pcConfig ){
                    if(pcForMarketOffer.Marketable_Offer__r.Contract_Type__c == contractType && pcForMarketOffer.Marketable_Offer__r.Contract_Type__c != ''){
                        if(pcForMarketOffer.Marketable_Offer__r.Product_Family__c != null)
                            productFamilySet.add(pcForMarketOffer.Marketable_Offer__r.Product_Family__c);
                        ProductConfigList.add(pcForMarketOffer);
                        
                    }
                }
            }
            if(productFamilySet.size() > 0)
                psProductFamilies = String.join(new List<String>(productFamilySet), ';');
            
            if(productFamilySet.size() > 0){
                list<Apttus__agreementlineitem__c> relatedAgreementLineItems = [SELECT  Id, Name, Apttus__agreementid__c, Apttus__agreementid__r.apttus__account__c, Apttus__agreementid__r.recordtype.name, Apttus__agreementid__r.apttus__agreement_category__c, Apttus__productid__c, Apttus__productid__r.marketable_product_family__c FROM Apttus__agreementlineitem__c WHERE Apttus__AgreementId__r.Apttus__Account__c=: conJunctionRecord[0].Account__c AND Apttus__productid__r.Name IN: productFamilySet AND Apttus__agreementid__r.recordtype.name =:  recordTypePriceSchedule]; 
                if(relatedAgreementLineItems.size() > 0){
                    isAgreementGeneratedPS = true;
                }
            }
            
            agreementFlags.put('isAgreementGeneratedPS', isAgreementGeneratedPS);
            agreementFlags.put('isAgreementGeneratedDSA', isAgreementGeneratedDSA);
            agreementFlags.put('isAgreementGeneratedBSA', isAgreementGeneratedBSA);
            agreementFlags.put('isAgreementGeneratedPricing', isAgreementGeneratedPricing);
        }
        return agreementFlags;
    }
    private static Database.SaveResult[] performDML(list < sObject > agmtSA) {
        Database.SaveResult[] agmtList = Database.insert(agmtSA, true);
        return agmtList;
    }
    private static list < Apttus__APTS_Agreement__c > mapAgreementWithContract(list < ContractJunction__c > ContractJunction, Id AGREEMENT_RECORDTYPEID, String configKey, Boolean isChildRecord, Id parentId) {
        list < Apttus__APTS_Agreement__c > agreementNewRecord = New list < Apttus__APTS_Agreement__c > ();
        Map < String, map < string, string >> relatedValueMap = relatedValue(ContractJunction);
        Map < String, String > configMap = getConfiguration(configKey);
        for (ContractJunction__c ContJun: ContractJunction) {
            Apttus__APTS_Agreement__c AgmtRecord = new Apttus__APTS_Agreement__c();
            AgmtRecord.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
            AgmtRecord.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
            AgmtRecord.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
            AgmtRecord.Apttus__Agreement_Category__c = configMap.get(AGREEMENT_CATEGORY);
            AgmtRecord.APTPS_Agreement_Subcategory__c = configMap.get(AGREEMENT_SUBCATEGORY);
            AgmtRecord.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
            AgmtRecord.Apttus__Source__c = configMap.get(SOURCE);
            AgmtRecord.RecordTypeId = AGREEMENT_RECORDTYPEID;
            AgmtRecord.APTPS_Sales_Account_Executive__c =  relatedValueMap.get(ContJun.Id).get('Account_Owner');
            AgmtRecord.Apttus__Related_Opportunity__c = ContJun.Related_Opportunity__c;
            AgmtRecord.Apttus__Term_Months__c = ContJun.Contract_Term_Months__c;
            AgmtRecord.Apttus__Auto_Renew_Term_Months__c =1;
            AgmtRecord.APTPS_Contract_Manager__c = relatedValueMap.get(ContJun.Id).get('Contract_Manager');
            AgmtRecord.APTPS_Commercial_Manager__c = relatedValueMap.get(ContJun.Id).get('Commercial_Manager');
            AgmtRecord.Agreement_Owner__c=relatedValueMap.get(ContJun.Id).get('Contract_Manager');
            AgmtRecord.Apttus__Requestor__c = UserInfo.getUserId();
            //AgmtRecord.APTPS_Customer_Primary_Contact__c = ContJun.Customer_Primary_Contact__c;
            AgmtRecord.APTPS_Customer_Primary_Contact__c = ContJun.DocuSign_Signer_2__c;
            AgmtRecord.Apttus__Account__c = ContJun.Account__c;
            AgmtRecord.Apttus__Total_Contract_Value__c = Decimal.valueOf(relatedValueMap.get(ContJun.Id).get('Opportunity_Amount'));
            AgmtRecord.Auto_Created_by_Basket__c = true;
            AgmtRecord.Related_Basket__c = ContJun.Related_Basket__c;
            //AgmtRecord.Apttus__Status_Category__c = 'Requestor';
            //AgmtRecord.Apttus__Status__c = 'Requestor';
            AgmtRecord.Apttus__Contract_End_Date__c = ContJun.Original_End_Date__c;
            AgmtRecord.APTPS_Effective_End_Date__c = ContJun.Effective_End_Date__c;
            AgmtRecord.Apttus__Contract_Start_Date__c = ContJun.Contract_Start_Date__c;
            AgmtRecord.Related_Contract__c = ContJun.Id;
            //AgmtRecord.APTPS_Company_Signed_By__c=relatedValueMap.get(ContJun.Id).get('Account_Owner_Name');
            AgmtRecord.APTPS_Company_Signed_By__c=String.valueOf(ContJun.CreatedById);
            AgmtRecord.Apttus__Other_Party_Signed_By__c=ContJun.Customer_Primary_Contact__c;
            AgmtRecord.APTPS_Legacy_opportunity_ID__c = ContJun.Related_Opportunity__c;
            AgmtRecord.APTPS_Payment_Terms_days__c = 30;
            if(signeddate!=null){
             AgmtRecord.Apttus__Company_Signed_Date__c=signeddate;
             }
            if(otherPartySingedDate!=null){
             AgmtRecord.Apttus__Other_Party_Signed_Date__c=otherPartySingedDate;
            }
            if(Recname!=null){
            AgmtRecord.APTPS_Other_Party_Signed_By__c=Recname;
            }
            agreementNewRecord.add(AgmtRecord);
        }
        return agreementNewRecord;
    }
    private static list <Apttus__APTS_Agreement__c > createChildAgreementData(list < ContractJunction__c > ContractJunction, Id AGREEMENT_RECORDTYPEID, String configKey, Boolean isChildRecord, Id parentId){
        list < Apttus__APTS_Agreement__c > agreementChildRecord = New list < Apttus__APTS_Agreement__c > ();
        Map < String, map < string, string >> relatedValueMap = relatedValue(ContractJunction);
        Map < String, String > configMap = getConfiguration(configKey);
        for (ContractJunction__c ContJun: ContractJunction) {
            Apttus__APTS_Agreement__c AgmtRecord = new Apttus__APTS_Agreement__c();
            AgmtRecord.Apttus__Parent_Agreement__c=parentId;
            AgmtRecord.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
            AgmtRecord.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
            AgmtRecord.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
            AgmtRecord.Apttus__Agreement_Category__c = configMap.get(AGREEMENT_CATEGORY);
            AgmtRecord.APTPS_Agreement_Subcategory__c = configMap.get(AGREEMENT_SUBCATEGORY);
            AgmtRecord.Apttus__Subtype__c=configMap.get(AGREEMENT_Subtype);
            AgmtRecord.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
            AgmtRecord.Apttus__Source__c = configMap.get(SOURCE);
            AgmtRecord.RecordTypeId=AGREEMENT_RECORDTYPEID;
            AgmtRecord.APTPS_Sales_Account_Executive__c =  relatedValueMap.get(ContJun.Id).get('Account_Owner');
            AgmtRecord.Apttus__Related_Opportunity__c = ContJun.Related_Opportunity__c;
            AgmtRecord.Apttus__Term_Months__c = ContJun.Contract_Term_Months__c;
            AgmtRecord.Apttus__Auto_Renew_Term_Months__c =1;
            AgmtRecord.APTPS_Contract_Manager__c = relatedValueMap.get(ContJun.Id).get('Contract_Manager');
            AgmtRecord.APTPS_Commercial_Manager__c = relatedValueMap.get(ContJun.Id).get('Commercial_Manager');
            AgmtRecord.Agreement_Owner__c=relatedValueMap.get(ContJun.Id).get('Contract_Manager');
            AgmtRecord.Agreement_Owner__c=relatedValueMap.get(ContJun.Id).get('Contract_Manager');
            AgmtRecord.Apttus__Requestor__c = UserInfo.getUserId();
            AgmtRecord.APTPS_Customer_Primary_Contact__c = ContJun.DocuSign_Signer_2__c;
            AgmtRecord.Apttus__Account__c = ContJun.Account__c;
            AgmtRecord.Apttus__Total_Contract_Value__c = Decimal.valueOf(relatedValueMap.get(ContJun.Id).get('Opportunity_Amount'));
            AgmtRecord.Auto_Created_by_Basket__c = true;
            AgmtRecord.Related_Basket__c = ContJun.Related_Basket__c;
            //AgmtRecord.Apttus__Status_Category__c = 'Requestor';
            //AgmtRecord.Apttus__Status__c = 'Requestor';
            AgmtRecord.Apttus__Contract_End_Date__c = ContJun.Original_End_Date__c;
            AgmtRecord.APTPS_Effective_End_Date__c = ContJun.Effective_End_Date__c;
            AgmtRecord.Apttus__Contract_Start_Date__c = ContJun.Contract_Start_Date__c;
            AgmtRecord.Related_Contract__c = ContJun.Id;
            //AgmtRecord.APTPS_Company_Signed_By__c=relatedValueMap.get(ContJun.Id).get('Account_Owner_Name');
            AgmtRecord.APTPS_Company_Signed_By__c=String.valueOf(ContJun.CreatedById);
            AgmtRecord.Apttus__Other_Party_Signed_By__c=ContJun.Customer_Primary_Contact__c;
            AgmtRecord.APTPS_Payment_Terms_days__c = 30;
            if(signeddate!=null){
             AgmtRecord.Apttus__Company_Signed_Date__c=signeddate;
             }
            if(otherPartySingedDate!=null){
             AgmtRecord.Apttus__Other_Party_Signed_Date__c=otherPartySingedDate;
            }
            if(Recname!=null){
            AgmtRecord.APTPS_Other_Party_Signed_By__c=Recname;
            }
            agreementChildRecord.add(AgmtRecord);
        }
        return agreementChildRecord;
    }
    
    private static Map < String, String > getConfiguration(String configName) {
        
        Map < String, String > configMap = new Map < String, String > ();
        try {
            Contract_Generation_Setting__mdt config = getContractGenerationSettings(configName);
            if (config != null) {
                configMap.put(AGREEMENT_CATEGORY, config.Agreement_Category__c);
                configMap.put(AGREEMENT_SUBCATEGORY, config.Agreement_Subcategory__c);
                configMap.put(AGREEMENT_Subtype, config.Apttus_Subtype__c);
                configMap.put(APPROVAL_STATUS, config.Approval_Status__c);
                configMap.put(AUTO_RENEWAL, ConversionUtils.booleanToString(config.Auto_Renew__c));
                configMap.put(VARIATION_SUMMARY_PAGE_NEEDED, ConversionUtils.booleanToString(config.Variation_Summary_Page_Needed__c));
                configMap.put(SOURCE, config.Source__c);
                configMap.put(TELSTRA_LEGAL_ENTITY, config.Addresses_for_Notices__c);
            }
        }
        catch(Exception e) {
            return null;
        }
        return configMap;
    }
    private static Contract_Generation_Setting__mdt getContractGenerationSettings(String hName) {
        
        Contract_Generation_Setting__mdt contractGenerationSettingRecord = New Contract_Generation_Setting__mdt();
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Contract_Generation_Setting__mdt')) + '\n ' + ' FROM Contract_Generation_Setting__mdt \n ' + ' WHERE DeveloperName = \'' + String.escapeSingleQuotes(hName) + '\' LIMIT 1 ';
        List < Contract_Generation_Setting__mdt > contractGenerationSettingRecordList = Database.query(queryStr);
        if (contractGenerationSettingRecordList != null && !contractGenerationSettingRecordList.isEmpty() && contractGenerationSettingRecordList.get(0) != null) {
            contractGenerationSettingRecord = contractGenerationSettingRecordList.get(0);
        }
        return contractGenerationSettingRecord;
    }
    private static map < String, map < string,  string >> relatedValue(list < ContractJunction__c > ContractJunction) {
        Map < String, map < string, string >> relatedValueMap = new Map < String, map < string, string >> ();
        for (ContractJunction__c CJ: cjRelatedvalueMp.values()) {
            if (!relatedValueMap.containskey(CJ.ID)) {
                Map < String, string > tempValue = new Map < String, string > ();
                tempValue.put('Account_Owner', CJ.Account__r.Owner.Id);
                tempValue.put('Contract_Manager', CJ.Account__r.APTPS_Contract_Manager__c);
                tempValue.put('Commercial_Manager', CJ.Account__r.APTPS_Commercial_Manager__c);
                tempValue.put('Opportunity_Amount', String.valueOf(CJ.Related_Opportunity__r.Amount));
                tempValue.put('Account_Owner_Name', CJ.Account__r.Owner.Name);
                tempValue.put('Contact_Name', CJ.Customer_Primary_Contact__r.name);
               //tempValue.put('Agrement_Value', String.ValueOf(CJ.Related_Basket__r.cscfga__total_contract_value__c));
                relatedValueMap.put(CJ.Id, tempValue);
            }
        }
        return relatedValueMap;
    }
    
    private static list<Apttus__agreementlineitem__c> createAgreementLineItem(list<cscfga__Product_Configuration__c> productConfig, Id parentId) 
    {
        Apttus__agreementlineitem__c AgreementLineItem;
        list<Apttus__agreementlineitem__c> insertAgreementlineitems = new list<Apttus__agreementlineitem__c>();
        Product2 prodRec = [SELECT id, Name FROM Product2 where name=:prodname LIMIT 1];
        if(prodRec!=null){
            prodRecord=prodRec.Id;
        }
        if(productConfig.size()>0){
            for (cscfga__Product_Configuration__c prodlst: productConfig) {
                AgreementLineItem = new Apttus__agreementlineitem__c();
                AgreementLineItem.Apttus__AgreementId__c =parentId;
                AgreementLineItem.Apttus__ProductId__c = prodRecord;
                insertAgreementlineitems.add(AgreementLineItem);
            }
            // if(insertAgreementlineitems.size() > 0)
            // insert insertAgreementlineitems;
        }
        return insertAgreementlineitems ;
        
    }
    
    public static void generateContentFileforAgmt(Boolean doInsert, list<id> listSourceRecord) {
        map<String, Apttus__APTS_Agreement__c> agreementOnContactRecord = new map<String, Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agreementRecord: [SELECT ID, NAME, Related_Service_Term__r.ServiceTermTemplateName__c,RecordTypeId, RecordType.DeveloperName FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c IN: listSourceRecord]){
            agreementOnContactRecord.put(agreementRecord.Id, agreementRecord);
        }
        system.debug('*************> agmt '+agreementOnContactRecord);
        if(agreementOnContactRecord.keySet().size() > 0){
            List<ContentDocumentLink> ContentDocumentLinkList = attachExistingFileToRecord(doInsert, listSourceRecord[0], agreementOnContactRecord);
            system.debug('*************> link '+ContentDocumentLinkList);
            if (doInsert && ContentDocumentLinkList.size() > 0) {
                Insert ContentDocumentLinkList;
            }
        }     
    }
    
    public static list<ContentDocumentLink> attachExistingFileToRecord(Boolean doInsert, id CopyfromId, map<String, Apttus__APTS_Agreement__c> agreementOnContactRecord) {   
        
        List<ContentDocumentLink> ContentDocumentLinkListSigned = New list<ContentDocumentLink>();
        // - to be deleted    
        AllCQEnvironmentVariable cqVariables = new AllCQEnvironmentVariable();
        contractFileName = new List<String>(AllCQEnvironmentVariable.getValueAsList('DSAFilename')); 
        
        fileNameDSAFormat fileNameDSA = new fileNameDSAFormat();
        String jsonString = String.valueOf(contractFileName[0].replace(';', ','));
        fileNameDSA = (fileNameDSAFormat)System.JSON.deserialize(jsonstring, fileNameDSAFormat.class); 
        system.debug('*************>>>>>>>'+fileNameDSA);  
        DSAfileNameSigned = fileNameDSA.singed_DSA;
        PriceSchedulefileNameSigned = fileNameDSA.singed_PriceSchedule;
        OrderFormfileNameSigned = fileNameDSA.singed_OrderForm; 
        List<ContentDocumentLink> ContentDocumentLinkList = New list<ContentDocumentLink>();           
        for(ContentDocumentLink CDLink : [SELECT ID, ContentDocumentId,ContentDocument.Title, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE (LinkedEntityId =:CopyfromId)]){
            
            If(CDLink.Id != NULL){
                system.debug('CDLink.ContentDocument.Title.contains:'+ CDLink.ContentDocument.Title);
                System.debug('Content:'+CDLink.ContentDocument.Title);
                ContentDocumentLink cdl = new ContentDocumentLink();
                for (Id key : agreementOnContactRecord.keySet()) {
                    if(agreementOnContactRecord.get(key).RecordType.DeveloperName == 'SA' && CDLink.ContentDocument.Title.contains('BSA') == true){
                        cdl.ContentDocumentId = CDLink.ContentDocumentId;
                        cdl.LinkedEntityId = agreementOnContactRecord.get(key).Id;   
                    }
                    else if(agreementOnContactRecord.get(key).RecordType.DeveloperName == 'SA' && CDLink.ContentDocument.Title.contains(DSAfileNameSigned.split(' - <contractName>_')[0]) == true && isDSAPresentInPc.containsKey('isAgreementGeneratedDSA') && isDSAPresentInPc.get('isAgreementGeneratedDSA') == false){
                        cdl.ContentDocumentId = CDLink.ContentDocumentId;
                        cdl.LinkedEntityId = agreementOnContactRecord.get(key).Id;   
                    }
                    else if(agreementOnContactRecord.get(key).RecordType.DeveloperName == 'Schedule' && CDLink.ContentDocument.Title.contains(PriceSchedulefileNameSigned.split(' - <contractName>_')[0]) == true && isDSAPresentInPc.containsKey('isAgreementGeneratedPS') && isDSAPresentInPc.get('isAgreementGeneratedPS') == false){
                        cdl.ContentDocumentId = CDLink.ContentDocumentId;
                        cdl.LinkedEntityId = agreementOnContactRecord.get(key).Id;   
                    }
                }
                system.debug('****cdl'+ cdl);
                cdl.ShareType = 'V';
                if(cdl.ContentDocumentId != NULL)
                    ContentDocumentLinkList.add(cdl);
            }  
        }
        return ContentDocumentLinkList;
    }
    
    @Future
    private static void updateCJStatus(String ContractJunctionJSON, String ParentId) {
        System.debug('inside future method');
        LIST<ContractJunction__c> ContractJunction = (List<ContractJunction__c>) JSON.deserialize(ContractJunctionJSON,List<ContractJunction__c>.class);
        Apttus__APTS_Agreement__c ApttusAgreement = [SELECT Id,Apttus__FF_Agreement_Number__c FROM Apttus__APTS_Agreement__c WHERE Id =: ParentId];
        for(ContractJunction__c ContJun : ContractJunction){
            ContJun.Status__c = 'In Effect';
            ContJun.Agreement_Number__c = ApttusAgreement.Apttus__FF_Agreement_Number__c;
        }
        if(!Test.isRunningTest())
            update ContractJunction;
        System.debug('after update method');
    }
    public class fileNameDSAFormat
    {
        public string unsigned_PriceSchedule { get; set; }
        public string singed_PriceSchedule { get; set; }
        public string unsigned_DSA { get; set; }
        public string singed_DSA { get; set; }
        public string unsigned_OrderForm { get; set; }
        public string singed_OrderForm { get; set; }
    }
    
}