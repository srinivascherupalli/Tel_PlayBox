/*
* This class is written for Creating agreement Records.
* Revisions : 
* RaviTeja 20/09/2019   EDGE-107935: Create Agreement Record for Multiple offers 

*/


public with sharing class AgreementRecordCreation {
    private static final Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
    private static final Id AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Product_Key_Facts').getRecordTypeId();
    private static final Id GENERAL_PRODUCT_TERMS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('General_Product_Terms').getRecordTypeId();
    private static final Id APPLICATION_FORM_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Application_Form').getRecordTypeId();

        
    private static final String AGREEMENT_CATEGORY = 'Agreement Category'; 
    private static final String AGREEMENT_SUBCATEGORY = 'Agreement Subcategory';
    private static final String APPROVAL_STATUS = 'Approval Status';
    private static final String AUTO_RENEWAL = 'Auto Renewal';
    private static final String SOURCE = 'Source';
    private static final String TELSTRA_LEGAL_ENTITY = 'Telstra Legal Entity';
    private static final String VARIATION_SUMMARY_PAGE_NEEDED = 'Variation Summary Page Needed';
    public static list<Apttus__APTS_Agreement__c> agreementSA = New list<Apttus__APTS_Agreement__c>();
    public static list<Apttus__APTS_Agreement__c> AgreementChildList = New list<Apttus__APTS_Agreement__c>();
    public static list<Id> CJ_Id = new list<id>();
    public static set<Id> CJactive_Id = new set<id>();//Variable Added for EDGE-39832
    public static integer countOfFiles = 9;
    public static Date signeddate;//variable added related to EDGE-40654
    public static Date otherPartySingedDate;
    
    @InvocableMethod(label='Create agreement record' description='Inserts the parent agreement specified and related child agreement')
    public static void createAgreementData(list<ContractJunction__c> ContractJunction){
        try{
        system.debug('#######--->'+ContractJunction);
        for(ContractJunction__c CId : ContractJunction){
            if(CId.Status__c=='In Effect' && CId.Agreement_Number__c!=null){//Added condition for EDGE-39832
                    CJactive_Id.add(CId.Id);
            }
            else{
            CJ_Id.add(CId.Id);}
        }
        if(CJactive_Id.size()>0){
            activateAgreementDocuments(CJactive_Id);//Calling Function for Added condition for EDGE-39832
        }
        else{                    
                list<Apttus__APTS_Agreement__c> ApttusAgreement = [SELECT ID, Related_Contract__c FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c IN: CJ_Id];
                
                //EDGE-107935: Create Agreement Record for Multiple offers
                Map<Id,Service_Term__c> ServiceTermMap= new Map<Id,Service_Term__c>([SELECT id,Name,ParentContract__c FROM Service_Term__c  WHERE ParentContract__c in :CJ_Id]);
                
                list<ContentDocumentLink> CDLink = [SELECT ID, ContentDocumentId,ContentDocument.Title,ContentDocument.FileExtension, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE (LinkedEntityId IN: CJ_Id  OR LinkedEntityId IN :ServiceTermMap.KeySet())];
                list<dsfs__DocuSign_Recipient_Status__c> signedOnPaper = [SELECT SignedOnPaper__c,dsfs__Date_Signed__c  FROM dsfs__DocuSign_Recipient_Status__c WHERE ContractJunction__c IN: CJ_Id];
                ContractJunction__c objConj = [SELECT Account__c,Parent_Contract__c,account__r.APTPS_DocuSign_Restricted__c,BSAVersion__c,GPTVersion__c,OFTVersion__c,Related_Basket__c,(SELECT id,OFTVersion__c from Service_Terms5__r) from ContractJunction__c WHERE id IN: CJ_Id];
                
                //Changes start for EDGE -40152
                countOfFiles=countOfFilesExpected(objConj);
                System.debug('CountOfFiles:'+countOfFiles);
                
                Boolean GenServiecTermAgreemnsts=false;
                for(Service_Term__c ST:objConj.Service_Terms5__r){
                    if(ST.OFTVersion__c > 0){
                        GenServiecTermAgreemnsts=true;
                        break;
                    }
                }
                
                //if((objConj.BSAVersion__c == 0 && objConj.GPTVersion__c == 0 && objConj.OFTVersion__c == 0)) // no agreements to generate
                if((objConj.BSAVersion__c == 0 && objConj.GPTVersion__c == 0 && !GenServiecTermAgreemnsts )) // no agreements to generate
                    return;                  
                
                    
                    
            
                    if(signedOnPaper.size() > 0 && (signedOnPaper[1].SignedOnPaper__c == 'yes')){
                        countOfFiles = countOfFiles+1;
                        system.debug('countOfFiles condition 1 :' + countOfFiles);
                    }
                    if(signedOnPaper.size() > 0 && (signedOnPaper[2].SignedOnPaper__c == 'yes')){
                        countOfFiles = countOfFiles+1;
                        system.debug('countOfFiles condition 2 :' + countOfFiles);
                    } 
                  System.debug('count:'+countOfFiles);
                   /* if(objConj.account__r.APTPS_DocuSign_Restricted__c){
                        countOfFiles = 5;
                    }*/
                //Changes end for EDGE -40152   
                
                    //Changes Start for EDGE-40654
                     if(signedOnPaper.size() > 0 && (signedOnPaper[2].dsfs__Date_Signed__c!=null)){
                        signeddate = Date.valueof(signedOnPaper[2].dsfs__Date_Signed__c);
                        system.debug('signeddate :' + signeddate);
                    }
          if(signedOnPaper.size() > 0 && (signedOnPaper[1].dsfs__Date_Signed__c!=null)){
                    otherPartySingedDate=Date.valueof(signedOnPaper[1].dsfs__Date_Signed__c);
                    system.debug('signeddate :' + signeddate);
                    }
                    //Changes Start for EDGE-40654
                    system.debug('************>'+CDLink);
                    boolean pdfGenerated = false;
                    for(ContentDocumentLink CDL : CDLink){
                        system.debug('CDL.ContentDocument.Title:'+CDL.ContentDocument.Title);
                        if(CDL.ContentDocument.Title.contains('.pdf') || CDL.ContentDocument.FileExtension == 'pdf'){
                            
                            pdfGenerated = true;
                            break;
                        }
                    }    
                    String AgreementGenerateContractFlag = EnvironmentVariable__c.getValues('AgreementGenerateContract').Value__c;
                    system.debug('***********>'+pdfGenerated +'$$$$$'+ApttusAgreement.size()+'******'+AgreementGenerateContractFlag+'#########'+CDLink.size());
                    if(ContractJunction.size() > 0 && ApttusAgreement.size() == 0 && AgreementGenerateContractFlag == '1' && CDLink.size() >= countOfFiles && pdfGenerated == true){                        
                    //changes start for EDGE - 40152
                    System.debug('parent:'+objConj.Parent_Contract__c);
                    if(ContractJunction[0].Parent_Contract__c!=null){
                        System.debug('Checking version updates');
                        Map<String,Apttus__APTS_Agreement__c> mapOfActiveAgreements=updateAgreementsWithLatestVersion(objConj);
                        System.debug('Agreements with new versions:'+mapOfActiveAgreements);
                        
                        //EDGE-107935: Create Agreement Record for Multiple offers
                        list<Apttus__APTS_Agreement__c> STAgreementKeyFacts = New list<Apttus__APTS_Agreement__c>();
                        STAgreementKeyFacts = mapAgreementsWithServiceTerms(ContractJunction, AGREEMENT_KEYFACTS_RECORDTYPEID, 'Agreement_Key_Facts', true, null);

                        //Database.SaveResult[] agmtList = performDML(STAgreementKeyFacts); 

                        if(mapOfActiveAgreements.values().size() > 0 || STAgreementKeyFacts.size() > 0 ){
                                GenerateContentFile.generateContentFileRecord(true, CJ_Id);
                                 updateCJStatus(JSON.serialize(ContractJunction),String.valueOf(mapOfActiveAgreements.get('SA').id));

                        }
                        
                     
                    }
                    //changes end for EDGE - 40152
                    else{
                    agreementSA = mapAgreementWithContractSA(ContractJunction, AGREEMENT_SA_RECORDTYPEID, 'Agreement_Head_Term', false, NULL);
                    Database.SaveResult[] agmt = performDML(agreementSA);
                    
                        system.debug('agmt'+agmt);
                    if(agmt.size() > 0){                        
                        id parentAgreement = agmt[0].getId();
                        if(parentAgreement != NULL) {
                            // Create Agreement_KeyFacts & Agreement_GeneralTerms record
                            list<Apttus__APTS_Agreement__c> AgreementKeyFacts = New list<Apttus__APTS_Agreement__c>();
                            list<Apttus__APTS_Agreement__c> AgreementGeneralTerms = New list<Apttus__APTS_Agreement__c>();
                            
                            /*EDGE-107935: Create Agreement Record for Multiple offers-Stared*/
                            system.debug('AgreementKeyFacts');
                            AgreementKeyFacts = mapAgreementsWithServiceTerms(ContractJunction, AGREEMENT_KEYFACTS_RECORDTYPEID, 'Agreement_Key_Facts', true, parentAgreement);
                            system.debug('AgreementKeyFacts'+AgreementKeyFacts);

                           //AgreementKeyFacts = mapAgreementWithContractSA(ContractJunction, AGREEMENT_KEYFACTS_RECORDTYPEID, 'Agreement_Key_Facts', true, parentAgreement);
                            /*EDGE-107935: Create Agreement Record for Multiple offers-Ended*/
                            
                            AgreementGeneralTerms = mapAgreementWithContractSA(ContractJunction, GENERAL_PRODUCT_TERMS_RECORDTYPEID, 'Agreement_General_Terms', true, parentAgreement);
                            //AgreementChildList.addAll(AgreementKeyFacts);
                            AgreementChildList.addAll(AgreementGeneralTerms);
                            Database.SaveResult[] agmtchildList = performDML(AgreementChildList); 
                            if(agmtchildList.size() > 0 || AgreementKeyFacts.size()>0 ){
                                GenerateContentFile.generateContentFileRecord(true, CJ_Id);
                                    updateCJStatus(JSON.serialize(ContractJunction),String.valueOf(parentAgreement));
                            }
                        } 
                    } 
                        }
            }
        }
      } 
      catch(Exception e) {
             
      }  
    }

    //changes start for EDGE - 40152     
    public static Map<String,Apttus__APTS_Agreement__c> updateAgreementsWithLatestVersion(ContractJunction__c objConj){
        Map<String,Boolean> agreementsToGenerate = getAgreementsToGenerate(objConj);
        Map<String,Apttus__APTS_Agreement__c> mapOfActiveAgreements = new Map<String,Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> ApttusAgreementsForAccount = [SELECT Id,recordtype.developername,name,Apttus__FF_Agreement_Number__c,Apttus__Status__c,Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__c=:objConj.Account__c and Apttus__Status__c='Activated' and Apttus__Status_Category__c ='In Effect'];
        for(Apttus__APTS_Agreement__c a:ApttusAgreementsForAccount)
                mapOfActiveAgreements.put(a.recordtype.developername,a);
        System.debug('map:'+mapOfActiveAgreements);
        if(agreementsToGenerate.get('GST')){
             Apttus__APTS_Agreement__c GSTAgreementToAmend = mapOfActiveAgreements.get('General_Product_Terms');
             Apttus__APTS_Agreement__c amendagreement1 = Apttus.ComplyWebService.amendAgreement(GSTAgreementToAmend.Id);
             amendagreement1.Related_Basket__c = objConj.Related_Basket__c;
             amendagreement1.Apttus__Status_Category__c = 'In Effect';
             amendagreement1.Apttus__Status__c = 'Activated';
             amendagreement1.Related_Contract__c = objConj.id;
             upsert amendagreement1;
             System.debug('amendagreement'+amendagreement1);
             Apttus.ComplyWebService.afterAmend(GSTAgreementToAmend.Id,amendagreement1.Id); 
             mapOfActiveAgreements.put(amendagreement1.recordtype.developername,amendagreement1) ;        
         }
        if(agreementsToGenerate.get('ST')){
             Apttus__APTS_Agreement__c STAgreementToAmend = mapOfActiveAgreements.get('Product_Key_Facts');
             Apttus__APTS_Agreement__c amendagreement2 = Apttus.ComplyWebService.amendAgreement(STAgreementToAmend.Id);
             amendagreement2.Related_Basket__c = objConj.Related_Basket__c;
             amendagreement2.Apttus__Status_Category__c = 'In Effect';
             amendagreement2.Apttus__Status__c = 'Activated';
             amendagreement2.Related_Contract__c = objConj.id;
             upsert amendagreement2;
             System.debug('amendagreement'+amendagreement2);
             Apttus.ComplyWebService.afterAmend(STAgreementToAmend.Id,amendagreement2.Id); 
             mapOfActiveAgreements.put(amendagreement2.recordtype.developername,amendagreement2) ;  
         }
        return mapOfActiveAgreements;
    }
    //changes end for EDGE - 40152
   
    public static void createChildAgreementData(String BasketId, Apttus__APTS_Agreement__c parentAgreement){
        
    }
    private static list<Apttus__APTS_Agreement__c> mapAgreementWithContractSA(list<ContractJunction__c> ContractJunction,Id AGREEMENT_RECORDTYPEID, String configKey, Boolean isChildRecord, Id parentId){
        list<Apttus__APTS_Agreement__c> agreementNewRecord =New list<Apttus__APTS_Agreement__c>();
        Map<String, map<string,string>> relatedValueMap = relatedValue(ContractJunction);
        system.debug('******>>>'+relatedValueMap);
        Map<String, String> configMap = getConfiguration(configKey);
        for(ContractJunction__c ContJun : ContractJunction){
            Apttus__APTS_Agreement__c Agmt = new Apttus__APTS_Agreement__c();
            if(isChildRecord == true){
            Agmt.Apttus__Parent_Agreement__c = parentId;
            }
            Agmt.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
            Agmt.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
            Agmt.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
            Agmt.APTPS_Agreement_Subcategory__c =  configMap.get(AGREEMENT_SUBCATEGORY);
            Agmt.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
            Agmt.Apttus__Source__c = configMap.get(SOURCE);
            Agmt.Apttus__Agreement_Category__c = configMap.get(AGREEMENT_CATEGORY);
            /* EDGE-43747 */
            if(ContJun.DocuSign_Signer_3__c != '' && String.isNotBlank(ContJun.DocuSign_Signer_3__c))
            Agmt.APTPS_Sales_Account_Executive__c =  ContJun.DocuSign_Signer_3__c;
            else
            Agmt.APTPS_Sales_Account_Executive__c =  relatedValueMap.get(ContJun.Id).get('Account_Owner');
            Agmt.APTPS_Customer_Primary_Contact__c =  ContJun.DocuSign_Signer_2__c;
            Agmt.Apttus__Related_Opportunity__c = ContJun.Related_Opportunity__c;
            Agmt.Apttus__Term_Months__c = ContJun.Contract_Term_Months__c;
            //Agmt.Apttus__Term_Months__c = 36;  // HardCoded for flow to work
            Agmt.Apttus__Auto_Renew_Term_Months__c =1;
            Agmt.APTPS_Contract_Manager__c = relatedValueMap.get(ContJun.Id).get('Contract_Manager');
            Agmt.APTPS_Commercial_Manager__c = relatedValueMap.get(ContJun.Id).get('Commercial_Manager');
            Agmt.Apttus__Requestor__c = UserInfo.getUserId();
            Agmt.APTPS_Customer_Primary_Contact__c = ContJun.Customer_Primary_Contact__c;
            Agmt.Apttus__Account__c = ContJun.Account__c;
            Agmt.RecordTypeId = AGREEMENT_RECORDTYPEID;
            Agmt.Apttus__Total_Contract_Value__c = Decimal.valueOf(relatedValueMap.get(ContJun.Id).get('Opportunity_Amount'));
            Agmt.Auto_Created_by_Basket__c = true;
            Agmt.Related_Basket__c = ContJun.Related_Basket__c;
            Agmt.Apttus__Status_Category__c = 'Requestor';
            Agmt.Apttus__Status__c = 'Requestor';
            Agmt.Apttus__Contract_End_Date__c = ContJun.Original_End_Date__c;
            Agmt.APTPS_Effective_End_Date__c = ContJun.Effective_End_Date__c;
            Agmt.Apttus__Contract_Start_Date__c = ContJun.Contract_Start_Date__c;
            Agmt.Related_Contract__c = ContJun.Id;
            //Changes Start for EDGE-40654
            Agmt.Agreement_Owner__c=relatedValueMap.get(ContJun.Id).get('Contract_Manager');
            if(signeddate!=null){
              Agmt.APTPS_Company_Signed_By__c=relatedValueMap.get(ContJun.Id).get('Account_Owner_Name');
              Agmt.Apttus__Company_Signed_Date__c=signeddate;
            }
            Agmt.Apttus__Other_Party_Signed_By__c=ContJun.Customer_Primary_Contact__c;
            Agmt.APTPS_Other_Party_Signed_By__c=relatedValueMap.get(ContJun.Id).get('Contact_Name');
            if(otherPartySingedDate!=null){
                Agmt.Apttus__Other_Party_Signed_Date__c=otherPartySingedDate;
            }
            //Changes End for EDGE-40654
            if(isChildRecord == false){
                if(Agmt.Apttus__Related_Opportunity__c==null){
                Agmt.APTPS_Legacy_opportunity_ID__c = ContJun.Related_Opportunity__c;
                }
                Agmt.APTPS_Payment_Terms_days__c = 30;
            }
            agreementNewRecord.add(Agmt);
        } 
        return agreementNewRecord;
    }
    private static map<String, map<string,string>> relatedValue(list<ContractJunction__c> ContractJunction){
         Map<String, map<string,string>> relatedValueMap = new Map<String, map<string,string>>();
        for(ContractJunction__c CJ : [SELECT Id, Account__r.Owner.Id,Account__r.Owner.Name,Customer_Primary_Contact__r.name,Account__r.APTPS_Contract_Manager__c,Account__r.APTPS_Commercial_Manager__c,Related_Opportunity__r.Amount FROM ContractJunction__c WHERE ID IN: CJ_Id]){
            if(!relatedValueMap.containskey(CJ.ID)) {
            Map<String, string> tempValue = new Map<String,string>();
                tempValue.put('Account_Owner',CJ.Account__r.Owner.Id);
                tempValue.put('Contract_Manager',CJ.Account__r.APTPS_Contract_Manager__c);
                tempValue.put('Commercial_Manager',CJ.Account__r.APTPS_Commercial_Manager__c);
                tempValue.put('Opportunity_Amount',String.valueOf(CJ.Related_Opportunity__r.Amount));
                tempValue.put('Account_Owner_Name',CJ.Account__r.Owner.Name);
                tempValue.put('Contact_Name',CJ.Customer_Primary_Contact__r.name);
                relatedValueMap.put(CJ.Id, tempValue);
            }
        }
        return relatedValueMap;
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
    
    private static Contract_Generation_Setting__mdt getContractGenerationSettings(String hName) {
        Contract_Generation_Setting__mdt contractGenerationSettingRecord = New Contract_Generation_Setting__mdt();
        
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Contract_Generation_Setting__mdt')) + '\n ' +
                          ' FROM Contract_Generation_Setting__mdt \n ' +
                          ' WHERE DeveloperName = \'' + String.escapeSingleQuotes(hName) + '\' LIMIT 1 ';
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
        /*  Lock a record for editing*/
        lockRecord(ContractJunction);
    }
    
    private static Database.SaveResult[] performDML(list<sObject> agmtSA) {
        Database.SaveResult[] agmtList = Database.insert(agmtSA, true);
        return agmtList;
    }
    
    private static void activateAgreementDocuments(set<id> CJactive_Id){//Added new fuction for EDGE-39832
       //this code has written for ActivateAgreement Document by APTUS API.
        try{
            system.debug('#######CJactive_Id--->'+CJactive_Id);
            
            Map<id, List<String>> secondMap = new Map<id, List<String>>(); 
            List<id> removeidlist= new List<id>();
                for(Apttus__APTS_Agreement__c  agrm:[SELECT ID,Name, Related_Contract__c,(SELECT ID, ContentDocumentId,ContentDocument.Title,ContentDocument.FileExtension, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLinks where ContentDocument.FileExtension='pdf') FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c IN: CJ_Id OR Apttus__Parent_Agreement__r.Related_Contract__c IN: CJactive_Id] ){
                    system.debug('Agreement Name'+agrm.name);
                     for(ContentDocumentLink cdl:agrm.ContentDocumentLinks){

                      system.debug('attachmentdetails'+cdl.ContentDocumentId);
                      if(!secondMap.containsKey(cdl.LinkedEntityId)){
                         secondMap.put(cdl.LinkedEntityId, new List<String>{cdl.ContentDocumentId});

                        }else{
                         secondMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                        }
                    }
                }
                system.debug('valueofMAP'+secondMap);
            if(secondMap.size()>0){
                for(string scloop:secondMap.keyset()){
                    system.debug('valueofloop'+secondMap.get(scloop));
                    system.debug('LIMIT'+Limits.getCallouts());
                    //Due to Apttus Limitation we are calling there API In Loop
                    if(Limits.getCallouts()<10){
                    Boolean response = Apttus.AgreementWebService.activateAgreement(scloop, secondMap.get(scloop), removeidlist);
                    system.debug('valueofresponse'+response );
                    }
                    
                }
            }
            
        }
        catch(Exception e) {
            
        }
    }
    private static void lockRecord(list<sObject> lstRecordId) {
        list<Id> Ids = new list<Id>();
        for(sObject record : lstRecordId){
            Ids.add(record.Id);
        }
        // Query the record to lock
        ContractJunction__c[] CJRecord = [SELECT Id from ContractJunction__c WHERE Id IN :Ids];
        // Lock the record
        Approval.LockResult[] lrList = Approval.lock(CJRecord, false);
        
        // Iterate through each returned result
        for(Approval.LockResult lr : lrList) {
            if (lr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully locked account with ID: ' + lr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : lr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
        
    }
    
    private static integer countOfFilesExpected(ContractJunction__c contract){
        integer count = 1; 
        if(contract.BSAVersion__c > 0)
            count++;
        if(contract.GPTVersion__c > 0)
            count++;
        if(contract.OFTVersion__c > 0)
            count++;
        if(!contract.account__r.APTPS_DocuSign_Restricted__c)
            count = count * 2 + 1;
        else 
            count = count + 1;
        return count;
    }
    
    public static Map<String,Boolean> getAgreementsToGenerate(ContractJunction__c contract){
        Map<String,boolean> agreementsToGenerate = new Map<String,Boolean>{'BSA' => false, 'GST' => false, 'ST' => false};
        if(contract.GPTVersion__c > 0)
            agreementsToGenerate.put('GST',true);
        if(contract.OFTVersion__c  > 0)
            agreementsToGenerate.put('ST',true);
        if(contract.BSAVersion__c  > 0)
            agreementsToGenerate.put('BSA',true);
        return agreementsToGenerate;
    }
    
    
/*
    EDGE-107935: Create Agreement Record for Multiple offers 
    Description: Create Agreements based on Service Terms related to contract New Case 
*/
private static list<Apttus__APTS_Agreement__c> mapAgreementsWithServiceTerms(list<ContractJunction__c> ContractJunction,Id AGREEMENT_RECORDTYPEID, String configKey, Boolean isChildRecord, Id parentId){
        list<Apttus__APTS_Agreement__c> agreementNewRecord =New list<Apttus__APTS_Agreement__c>();
        Map<String, map<string,string>> relatedValueMap = relatedValue(ContractJunction);
        Map<String,Apttus__APTS_Agreement__c> mapOfActiveAgreements = new Map<String,Apttus__APTS_Agreement__c>();
        list<service_term__c> updatelistst= new list<service_term__c>();

    list<Apttus__APTS_Agreement__c> agreementAmendRecords= new list<Apttus__APTS_Agreement__c>();
    Map<string,Apttus__APTS_Agreement__c> mapAmendAgmts= new Map<string,Apttus__APTS_Agreement__c>();
        system.debug('******>>>'+relatedValueMap);
        Map<String, String> configMap = getConfiguration(configKey);
        
        //Check for the Existing Agreements tagged to the corresponding account to amend the new agreement        
        List<Apttus__APTS_Agreement__c> ApttusAgreementsForAccount = [SELECT Id,recordtype.developername,name,Apttus__FF_Agreement_Number__c,Apttus__Status__c,Related_Service_Term__r.ServiceTermName__c,Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__c=:ContractJunction[0].Account__c and Apttus__Status__c='Activated' and Apttus__Status_Category__c ='In Effect'];
        for(Apttus__APTS_Agreement__c a:ApttusAgreementsForAccount){
             mapOfActiveAgreements.put(a.Related_Service_Term__r.ServiceTermName__c,a); 
    }       

    system.debug('mapOfActiveAgreements'+mapOfActiveAgreements);        
        list<ContractJunction__c> ContractJunctionlst= [SELECT id,DocuSign_Signer_3__c,DocuSign_Signer_2__c,Related_Opportunity__c,Contract_Term_Months__c,Customer_Primary_Contact__c,Account__c,Related_Basket__c,Original_End_Date__c,Effective_End_Date__c,Contract_Start_Date__c,(SELECT id,ServiceTermName__c,Name,DocuSign_Signer_3__c,DocuSign_Signer_2__c,Related_Opportunity__c,Contract_Term_Months__c,Account__c,Related_Basket__c FROM Service_Terms5__r) FROM ContractJunction__c WHERE id =:ContractJunction[0].id ];
        
                            system.debug('******>>>ContractJunctionlst'+ContractJunctionlst);            

    for(ContractJunction__c ContJun : ContractJunctionlst){
        for(service_term__c sc: ContJun.Service_Terms5__r){
                    system.debug('@@@sc.Name'+sc.ServiceTermName__c);
                    //Check for the Existing Agreements
          if(mapOfActiveAgreements.containsKey(sc.ServiceTermName__c)){ 
                        Apttus__APTS_Agreement__c AgreementToAmend = mapOfActiveAgreements.get(sc.ServiceTermName__c);
                        system.debug('@@@@AgreementToAmend'+AgreementToAmend);

                        Apttus__APTS_Agreement__c amendagreement1 = Apttus.ComplyWebService.amendAgreement(AgreementToAmend.Id);
                        amendagreement1.Related_Basket__c = ContractJunction[0].Related_Basket__c;
                        amendagreement1.Apttus__Status_Category__c = 'In Effect';
                        amendagreement1.Apttus__Status__c = 'Activated';
                        amendagreement1.Related_Contract__c = ContractJunction[0].id;
                        amendagreement1.Related_Service_Term__c = sc.id;
                        mapAmendAgmts.put(AgreementToAmend.id,amendagreement1);
                        agreementAmendRecords.add(amendagreement1);
            //upsert amendagreement1 ;
                        System.debug('amendagreement'+amendagreement1);
                        //Apttus.ComplyWebService.afterAmend(AgreementToAmend.Id,amendagreement1.Id); 
                        //agreementNewRecord.add(amendagreement1);
                        system.debug('mapAmendAgmts'+mapAmendAgmts);

                    }
                else{           
                    system.debug('******>>>sc'+sc);            
                    Apttus__APTS_Agreement__c Agmt = new Apttus__APTS_Agreement__c();
                    if(isChildRecord == true){
                        Agmt.Apttus__Parent_Agreement__c = parentId;
                    }
                    Agmt.Related_Service_Term__c = sc.id;
                    Agmt.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
                    Agmt.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
                    Agmt.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
                    Agmt.Apttus__Agreement_Category__c = configMap.get(AGREEMENT_CATEGORY);                 
                    Agmt.APTPS_Agreement_Subcategory__c =configMap.get(AGREEMENT_SUBCATEGORY);
                    Agmt.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
                    Agmt.Apttus__Source__c = configMap.get(SOURCE);
                    /* EDGE-43747 */
                    if(sc.DocuSign_Signer_3__c != '' && String.isNotBlank(sc.DocuSign_Signer_3__c))
                    Agmt.APTPS_Sales_Account_Executive__c =  sc.DocuSign_Signer_3__c;
                    else
                    Agmt.APTPS_Sales_Account_Executive__c =  relatedValueMap.get(ContJun.Id).get('Account_Owner');
                    Agmt.APTPS_Customer_Primary_Contact__c =  sc.DocuSign_Signer_2__c;
                    Agmt.Apttus__Related_Opportunity__c = sc.Related_Opportunity__c;
                    Agmt.Apttus__Term_Months__c = sc.Contract_Term_Months__c;
                    //Agmt.Apttus__Term_Months__c = 36;  // HardCoded for flow to work
                    Agmt.Apttus__Auto_Renew_Term_Months__c =1;
                    Agmt.APTPS_Contract_Manager__c = relatedValueMap.get(ContJun.Id).get('Contract_Manager');
                    Agmt.APTPS_Commercial_Manager__c = relatedValueMap.get(ContJun.Id).get('Commercial_Manager');
                    Agmt.Apttus__Requestor__c = UserInfo.getUserId();
                    Agmt.APTPS_Customer_Primary_Contact__c = ContJun.Customer_Primary_Contact__c;
                    Agmt.Apttus__Account__c = sc.Account__c;
                    Agmt.RecordTypeId = AGREEMENT_RECORDTYPEID;
                    Agmt.Apttus__Total_Contract_Value__c = Decimal.valueOf(relatedValueMap.get(ContJun.Id).get('Opportunity_Amount'));
                    Agmt.Auto_Created_by_Basket__c = true;
                    Agmt.Related_Basket__c = sc.Related_Basket__c;
                    Agmt.Apttus__Status_Category__c = 'Requestor';
                    Agmt.Apttus__Status__c = 'Requestor';
                    Agmt.Apttus__Contract_End_Date__c = ContJun.Original_End_Date__c;
                    Agmt.APTPS_Effective_End_Date__c = ContJun.Effective_End_Date__c;
                    Agmt.Apttus__Contract_Start_Date__c = ContJun.Contract_Start_Date__c;
                    Agmt.Related_Contract__c = ContJun.Id;
                    //Changes Start for EDGE-40654
                    Agmt.Agreement_Owner__c=relatedValueMap.get(ContJun.Id).get('Contract_Manager');
                    if(signeddate!=null){
                      Agmt.APTPS_Company_Signed_By__c=relatedValueMap.get(ContJun.Id).get('Account_Owner_Name');
                      Agmt.Apttus__Company_Signed_Date__c=signeddate;
                    }
                                        system.debug('******>>>Agmt middle');

                    Agmt.Apttus__Other_Party_Signed_By__c=ContJun.Customer_Primary_Contact__c;
                    Agmt.APTPS_Other_Party_Signed_By__c=relatedValueMap.get(ContJun.Id).get('Contact_Name');
                    if(otherPartySingedDate!=null){
                        Agmt.Apttus__Other_Party_Signed_Date__c=otherPartySingedDate;
                    }
                    //Changes End for EDGE-40654
                    if(isChildRecord == false){
                        if(Agmt.Apttus__Related_Opportunity__c==null){
                        Agmt.APTPS_Legacy_opportunity_ID__c = sc.Related_Opportunity__c;
                        }
                        Agmt.APTPS_Payment_Terms_days__c = 30;
                    }
                    system.debug('******>>>Agmt'+Agmt);
                    
                    
                    //For Professionsal Service populate values 
                    if(Sc.ServiceTermName__c==System.Label.ProfessionalServices)
                    {
                         Agmt.RecordTypeId = APPLICATION_FORM_RECORDTYPEID;
                         Agmt.APTPS_Agreement_Subcategory__c='Professional Services';

                    }
                    
                    
                    agreementNewRecord.add(Agmt);
                } 
                }
              }
          
    if(agreementAmendRecords.size()>0){
          upsert agreementAmendRecords;
    }
        
    if(agreementNewRecord.size()>0){
          upsert agreementNewRecord;
    }
    

           
        if(agreementAmendRecords.size()>0){
            agreementNewRecord.addall(agreementAmendRecords);
          }
    
    system.debug('@@@agr@@@@@');
    //Defect Fix :EDGE-114688: Agreement Number is blank in Contract details of Service Terms
    for(Apttus__APTS_Agreement__c agr:[select id,Related_Service_Term__c,Apttus__FF_Agreement_Number__c from Apttus__APTS_Agreement__c where id in :agreementNewRecord and Related_Service_Term__c!=null]){
            system.debug('agr'+agr);
            service_term__c stm= new service_term__c(id=agr.Related_Service_Term__c);
            stm.Agreement_Number__c=agr.Apttus__FF_Agreement_Number__c;
            updatelistst.add(stm);
    }
     
    if(updatelistst.size()>0){
            upsert updatelistst;
        }
    //End: EDGE-114688        
        system.debug('mapAmendAgmts'+mapAmendAgmts);
      for(string amendid:mapAmendAgmts.keyset()){
                        if(mapAmendAgmts.get(amendid)!=null){
                            system.debug('@@amendid'+amendid+ 'value'+mapAmendAgmts.get(amendid).id);
                            Apttus.ComplyWebService.afterAmend(amendid,mapAmendAgmts.get(amendid).id);
                        }
        }      
           
    
      return agreementNewRecord;
}
}