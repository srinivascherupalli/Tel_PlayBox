/**
* @Author   :   Maqsood Alam
* @Date     :   10 Oct 2018
* @Desc     :   Controller for sObject Lookup Lightning Component
* */
//1.            Gunjan Aswani           16/12/2020              EDGE-190520 FAM Contract Initiation 
//2.            Payal                   5/2/2021                EDGE-198027 Change Async Process of createOLI from future to batch
//3.            Gunjan Aswani           24/02/2021              EDGE-206173  EDGE-192931 - In-Flight : Stop sync process for Quote/Contract/Skip Contract

//4.       Gokul R              23/02/21            EDGE-195270 Monitor Async status for Source basket - Chown

//5.            Pooja /Kshitiz          26/02/2021              EDGE-191759  Order Form generation for CHOWN 
//6.            Pooja Gupta             10/03/2021              Revert EDGE-191759  Order Form generation for CHOWN changes
//7.            Lokesh Thathuru                                 DIGI-434 to create case feature
public with sharing class sObjectLookupController {
    
    public static list<string> invalidResponse = new list<String>();
    @AuraEnabled public String selectedFCRContactId;
    @AuraEnabled
    public static List<sObject> searchRecord(String objectAPIName, String fieldAPIName,
                                             List<String> moreFields, String searchTextPara,
                                             Integer recordLimit, String rawSOQLcriteria, String dyamicVariable) {
                                                 List<sObject> objectList =  new List<sObject>();
                                                 Integer recordLimitSOQL = 5;
                                                 String searchText = '\'%' + String.escapeSingleQuotes(searchTextPara.trim()) + '%\'';
                                                 String rawSOQLcriteriaString =  String.escapeSingleQuotes(rawSOQLcriteria);
                                                 
                                                 if (String.isBlank(rawSOQLcriteriaString)) {
                                                     String soqlQuery = 'SELECT Id, Name';
                                                     String OrderBy = 'Order By LastName ASC';
                                                     if (!moreFields.isEmpty()) {
                                                         soqlQuery = String.escapeSingleQuotes(soqlQuery) + ',' + String.escapeSingleQuotes(String.join(moreFields, ',')) ;
                                                     }
                                                     soqlQuery = String.escapeSingleQuotes(soqlQuery) + ' FROM ' + String.escapeSingleQuotes(objectAPIName) + ' WHERE ' +
                                                         + String.escapeSingleQuotes(fieldAPIName) + ' LIKE ' + searchText + ' ' + OrderBy + ' LIMIT ' + recordLimitSOQL;
                                                     System.debug(LoggingLevel.INFO, 'sObjectLookupController.soqlQuery = ' + soqlQuery);
                                                     objectList = Database.query(soqlQuery);
                                                     return objectList;
                                                 } else {
                                                     if (String.isNotBlank(dyamicVariable)) {
                                                         rawSOQLcriteriaString = String.escapeSingleQuotes(rawSOQLcriteriaString.replace('dyamicVariable', dyamicVariable));
                                                     }
                                                     
                                                     rawSOQLcriteriaString = String.escapeSingleQuotes(rawSOQLcriteriaString).replaceAll('\\\\', '');
                                                     String soqlQuery = 'SELECT Id, Contact_Name__c, ContactId, Contact_Email__c ';
                                                     if (!moreFields.isEmpty()) {
                                                         soqlQuery = String.escapeSingleQuotes(soqlQuery) + ',' + String.escapeSingleQuotes(String.join(moreFields, ',')) ;
                                                     }
                                                     soqlQuery = String.escapeSingleQuotes(soqlQuery) + ' FROM ' + String.escapeSingleQuotes(objectAPIName) + ' WHERE ' +
                                                         + String.escapeSingleQuotes(fieldAPIName) + ' LIKE ' + searchText + ' AND  ' + rawSOQLcriteriaString + ' LIMIT ' + recordLimitSOQL;
                                                     System.debug(LoggingLevel.INFO, 'sObjectLookupController.soqlQuery = ' + soqlQuery);
                                                     objectList = Database.query(soqlQuery);
                                                     return objectList;
                                                 }
                                                 //  return null;
                                             }
    @AuraEnabled
    public static String createRecord(String basketId, String signer2, String signer3,
                                      boolean isDigBsaPSVarApplicableForRA, AgreementUtilities.AgreementDecision decision) {
        GenerateContract genContract = New GenerateContract();
        String response = '';
        map<string, Id> ContractSignatories = new map<string, Id>();
        ContractSignatories.put('signer2', signer2);
        ContractSignatories.put('signer3', signer3);
        //Added for FDR deployment
        if(!Test.isRunningTest())
            response = genContract.createContract(basketId, ContractSignatories, 'basket',isDigBsaPSVarApplicableForRA,decision);
        
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.response = ' + response);
        
        return response;
    }
    
    /**
      * DIGI-16609
      * Order first Journey/Contract Signatory: As a Sales or Partner user I want to check an active 
      * contract (Dig BSA) at the RC Hierarchy level 
      * */
    @AuraEnabled
    public static AgreementUtilities.AgreementDecision resolveSATypeOnInit(String basketId,String oppId){
        cscfga__Product_Basket__c prodBasket=[Select Id,csordtelcoa__Previous_Product_Basket__c,BasketType__c,csbb__Account__c 
                                              From cscfga__Product_Basket__c Where Id=:basketId limit 1];
        Opportunity oppObj=[Select Id,contract_type__c From Opportunity Where Id=:oppId limit 1];
        AgreementUtilities.AgreementDecision decision =AgreementOrderUtilities.resolveSAType(null,prodBasket,oppObj);
        return decision;
    }
    
    // method to get decision in deal jurney
    @AuraEnabled
    public static AgreementUtilities.AgreementDecision resolveSATypeDealJurney(String famId){
        csconta__Frame_Agreement__c frameAgreement = [select id,Name,Delegated_Pricing_Request__c from csconta__Frame_Agreement__c where id =: famId ];
        Delegated_Pricing_Request__c dprRequest = [select id,name,Opportunity__c,Account__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c where id =:frameAgreement.Delegated_Pricing_Request__c]; 
        AgreementUtilities.AgreementDecision decision =AgreementDealUtilities.resolveSAType(dprRequest);
        return decision;
    }
    
    @AuraEnabled
    public static boolean userInfoPRM() {
        boolean isPRMuser = false;
        Profile p = [select id, Name from Profile where id = :Userinfo.getProfileid()];
        if (p.Name  == 'PRM Admin - Australia' || p.Name  == 'PRM Community User - Australia')
            isPRMuser = true;return isPRMuser;
    }
    
    @AuraEnabled
    public static String organizationInfo() {
        String currentOrg = '';
        List<organization> lstOrganization =
            [
                Select id, instanceName, isSandbox
                from Organization
            ];
        if (lstOrganization.size() > 0) {
            if (lstOrganization[0].isSandbox)
                currentOrg = 'Sandbox';
            else
                currentOrg = 'Production';
            return currentOrg;
        }
        return currentOrg;
    }
    //195270 - This method will return Jobs ids of the basket
    public static list<string> getbasketJobIds(set<string>basketIds){
        list<string> jobids = new list<string>();
        for(cscfga__Product_Basket__c pb :[SELECT Id,sync_job_Id__c FROM cscfga__Product_Basket__c WHERE Id IN : basketIds]){
            if(pb.sync_job_Id__c != null)
                jobids.add(pb.sync_job_Id__c);
        }
        return jobids;
    }
    //195270 - This method will return Jobs ids and its status
    public static map<string,string> jobStatus(list<string> jobids){
        map<string,string> jobStatusMap = new map<string,string>();
        for(AsyncApexJob asy:[SELECT id,Status FROM AsyncApexJob WHERE Id IN:jobids AND JobType='BatchApex' AND Status != 'Completed' AND CreatedById=:UserInfo.getUserId() ORDER BY CreatedDate DESC]){
            if(jobStatusMap.get('jobId')!= null){
                string jobidset = jobStatusMap.get('jobId');
                jobidset = jobidset+','+asy.id;
                jobStatusMap.put('jobId',jobidset);
            }else{
                jobStatusMap.put('jobId',asy.id);
            }
            
            jobStatusMap.put('jobStatus',asy.status);
        }
        return jobStatusMap;
    }
    //195270 - Modified this method to handle bulk baskets
    @AuraEnabled
    public static Map<String,String> toCheckSyncJobCompletion(String basketId,String jobId) {
        //EDGE-198027
        
        
        Map<String,String> returnVal = new Map<String,String>();
        list<string> jobids = new list<string>();
        if(string.isNotBlank(jobId)){
            jobids.addall(jobId.split(','));
            returnVal  =   jobStatus(jobIds);
        }else if(string.isNotBlank(basketId)){
            set<string> pbids = new set<string>();
            pbids.add(basketId);
            for(Migration_Change_Request__c mcr : [select id,macd_basket_ids__c from Migration_Change_Request__c where macd_basket_ids__c like :'%'+basketId+'%'  limit 10000]){
                for(string st : mcr.macd_basket_ids__c.split(',')){
                    pbids.add(st);     
                    
                }  
            }
            
            list<string> basketJobIds = new list<string>();
            basketJobIds = getbasketJobIds(pbids);
            returnVal = jobStatus(basketJobIds);
        }
        
        
        return returnVal;
    }
    
    
    @AuraEnabled
    public static void updateBasketStage(String basketId, String contractId) {
        // EDGE-206173 EDGE-192931 - In-Flight : Stop sync process for Quote/Contract/Skip Contract added recordTypeName != 'Inflight Change'- By Gunjan    
        
        cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);       
        //EDGE-191759 changes start
        /*if(productBasket!=null){

if(productBasket.BasketType__c == 'Incoming'){
chownProductBasketUtil.changeBasketStageForChown(productBasket); 
}            
//Added else condition
else{
String recordTypeName = productBasket.recordType.Name;
productBasket.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c;                                 
if (recordTypeName != 'Inflight Change' ){
productBasket.csordtelcoa__Synchronised_with_Opportunity__c = true;
productBasket.csbb__Synchronised_with_Opportunity__c = true;
productBasket.Primary_Basket__c = true;
}
update productBasket;
}
}*/
        
        String recordTypeName = productBasket.recordType.Name;
        productBasket.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c;                                 
        if (recordTypeName != 'Inflight Change' ){
            productBasket.csordtelcoa__Synchronised_with_Opportunity__c = true;
            productBasket.csbb__Synchronised_with_Opportunity__c = true;
            productBasket.Primary_Basket__c = true;
        }
        update productBasket;
        
        //EDGE-191759 changes end
        //(21-Oct-2020) Commented by Pooja Bhat: EDGE-181255 
        //To resolve Error: "System.DmlException: Update failed. first error: UNABLE_TO_LOCK_ROW, unable to obtain exclusive access to this record or 1 records" on opportunity record            
        //OpportunitySyncUtil.updateOpptInfo(productBasket, 'ContractInitiate');
        
        
        Id userId = UserInfo.getProfileId();
        /*--- Create FCR Record ---*/
        contractjunction__c contractRecord =
            [
                SELECT Id, DocuSign_Signer_2__c, Account__c
                FROM contractjunction__c
                WHERE Id = : contractId
            ];
        if (contractRecord != NULL && contractRecord.DocuSign_Signer_2__c != '') {
            createFCRRecord(basketId, contractRecord);
        }
    }
    
    @AuraEnabled
    public static void createFCRRecord(String basketId, contractjunction__c contractRecord) {
        list<Functional_Contact_Role__c> FCRRecord = [SELECT Id, ContactID__c, Role_Type__c FROM Functional_Contact_Role__c WHERE ContactID__c = :contractRecord.DocuSign_Signer_2__c AND Contract__c = :contractRecord.Id];
        list<Functional_Contact_Role__c> newFCRRecord = New list<Functional_Contact_Role__c>();
        if (FCRRecord.size() == 0) {
            Id contractRecordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Contract Role').getRecordTypeId();
            Functional_Contact_Role__c newFCRForContract = New Functional_Contact_Role__c();
            newFCRForContract.Contract__c = contractRecord.Id;
            newFCRForContract.ContactID__c = contractRecord.DocuSign_Signer_2__c;
            newFCRForContract.Role_Type__c = 'Contract Role';
            newFCRForContract.Role__c = 'Contract Signatory Role';
            newFCRForContract.RecordTypeId = contractRecordTypeId;
            newFCRRecord.add(newFCRForContract);
        }
        if (newFCRRecord.size() > 0) {
            Insert newFCRRecord;
        }
    }
    
    public static Map<String, dateTime> fetchCustomerContractSignatory(String basketId, String contractId, List<AccountContactRelation> objectList) {
        Map<String, dateTime> mergedFCR_ACR_Map = New Map<String, dateTime>();
        list<Id> listContactIdFCR = New list<Id>();
        for (AccountContactRelation ACR : objectList) {
            if (ACR.ContactId != NULL) {
                listContactIdFCR.add(ACR.ContactId);
            }
        }
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.objectList = ' + objectList);
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.listContactIdFCR = ' + listContactIdFCR);
        Date todayDate = System.TODAY() - 1;
        list<Functional_Contact_Role__c> FCRRecord =
            [
                SELECT Id, ContactID__c, Role_Type__c, createddate
                FROM Functional_Contact_Role__c
                WHERE Role_Type__c = 'Contract Role' AND ContactID__c IN: listContactIdFCR AND
                (
                    Relationship_End_Date__c > :todayDate OR Relationship_End_Date__c = NULL
                )
                order by createddate DESC NULLS LAST
            ];
        system.debug('******>>>FCRRecord-->++++  ' + FCRRecord);
        if (FCRRecord.size() == 1) {
            for (Functional_Contact_Role__c FCRInstance : FCRRecord) {
                if (!mergedFCR_ACR_Map.containsKey(FCRInstance.ContactID__c)) {
                    mergedFCR_ACR_Map.put(FCRInstance.ContactID__c, FCRInstance.createddate);
                    // selectedFCRContactId = FCRInstance.ContactID__c;
                }
            }
            return mergedFCR_ACR_Map;
        } else if (FCRRecord.size() > 1) {
            for (Functional_Contact_Role__c FCRInstance : FCRRecord) {
                if (!mergedFCR_ACR_Map.containsKey(FCRInstance.ContactID__c)) {
                    mergedFCR_ACR_Map.put(FCRInstance.ContactID__c, FCRInstance.createddate);
                }
            }
            system.debug('******>>>mergedFCR_ACR_Map-->  ' + mergedFCR_ACR_Map);
            return mergedFCR_ACR_Map;
        }
        return mergedFCR_ACR_Map;
    }
    @AuraEnabled
    public static String OnloadCustomerContractSignatory(String AccountId, String OppId, String cancelOrderVar) {
        String AccId = String.escapeSingleQuotes(AccountId);
        String OpprtyId = String.escapeSingleQuotes(OppId);
        list<Id> listContactIdFCR = New list<Id>();
        String contactNameId = '';
        /*-- EDGE-66515 : default contract recipient as Order requestor for Modify and Cancel --*/
        //EDGE-76402 added or condition for Pure Modify
        if (cancelOrderVar == 'None' || cancelOrderVar == 'PureModify') {
            list<OpportunityContactRole> oppConRole = [Select o.ContactId, o.Id, o.Contact.Name From OpportunityContactRole o where o.OpportunityId = : OpprtyId AND Role = 'Decision Maker'];
            if (oppConRole.size() > 0) {
                // return contactNameId = oppConRole[0].ContactId +'!@@!@@!'+ oppConRole[0].Contact.Name;
                for (AccountContactRelation ACR_Cancel : [SELECT Id, ContactId FROM AccountContactRelation WHERE ( Roles = 'Full Authority' OR Roles = 'Legal Lessee') AND ContactId = : oppConRole[0].ContactId Order By Contact.Name ASC]) {
                    if (ACR_Cancel.ContactId != NULL) {
                        return contactNameId = oppConRole[0].ContactId + '!@@!@@!' + oppConRole[0].Contact.Name;
                    }
                }
            }
        }
        /*-- EDGE-66515  End*/
        for (AccountContactRelation ACR : [SELECT Id, ContactId FROM AccountContactRelation WHERE ( Roles = 'Full Authority' OR Roles = 'Legal Lessee') AND AccountId = : AccId Order By Contact.Name ASC]) {
            if (ACR.ContactId != NULL) {
                listContactIdFCR.add(ACR.ContactId);
            }
        }
        Date todayDate = System.TODAY() - 1;
        list<Functional_Contact_Role__c> FCRRecord =
            [
                SELECT Id, ContactID__c, ContactID__r.name
                FROM Functional_Contact_Role__c
                WHERE Role_Type__c = 'Contract Role' AND ContactID__c IN: listContactIdFCR AND
                (
                    Relationship_End_Date__c > : todayDate OR Relationship_End_Date__c = NULL
                )
                order by createddate DESC
                LIMIT 1
            ];
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.FCRRecord = ' + FCRRecord);
        
        if (FCRRecord.size() > 0) {
            // contactNameId = FCRRecord[0].Id +'!@@!@@!'+ FCRRecord[0].ContactID__r.name;
            contactNameId = FCRRecord[0].ContactID__c + '!@@!@@!' + FCRRecord[0].ContactID__r.name;
            return contactNameId;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<sobjectwrapperclass> searchRecordWithSequence(String objectAPIName, String fieldAPIName,
                                                                     List<String> moreFields, String searchTextPara,
                                                                     Integer recordLimit, String rawSOQLcriteria, String dyamicVariable) {
                                                                         List<sObject> objectList =  new List<sObject>();
                                                                         Integer recordLimitSOQL = 5;
                                                                         String searchText = '\'%' + String.escapeSingleQuotes(searchTextPara.trim()) + '%\'';
                                                                         String rawSOQLcriteriaString =  String.escapeSingleQuotes(rawSOQLcriteria);
                                                                         String fieldAPINameString = fieldAPIName + '__c';
                                                                         String fieldAPINameStringFixed = 'Contact.Name';
                                                                         List<sobjectwrapperclass> sobjectwrapper = new List<sobjectwrapperclass>();
                                                                         Map<String, dateTime> FCR_Map = New Map<String, dateTime>();
                                                                         //   list<sObject> consolitedFCR_ACR_List= New list<sObject>();
                                                                         if (String.isNotBlank(dyamicVariable)) {
                                                                             rawSOQLcriteriaString = String.escapeSingleQuotes(rawSOQLcriteriaString.replace('dyamicVariable', dyamicVariable));
                                                                         }
                                                                         System.debug(LoggingLevel.INFO, 'sObjectLookupController.rawSOQLcriteriaString = ' + rawSOQLcriteriaString);
                                                                         
                                                                         rawSOQLcriteriaString = String.escapeSingleQuotes(rawSOQLcriteriaString).replaceAll('\\\\', '');
                                                                         String soqlQuery = 'SELECT Id, Contact_Name__c,Contact.Name, ContactId, Contact_Email__c, Job_Title__c ';
                                                                         if (!moreFields.isEmpty()) {
                                                                             soqlQuery = String.escapeSingleQuotes(soqlQuery) + ',' + String.escapeSingleQuotes(String.join(moreFields, ',')) ;
                                                                         }
                                                                         soqlQuery = String.escapeSingleQuotes(soqlQuery) + ' FROM ' + String.escapeSingleQuotes(objectAPIName) + ' WHERE ' +
                                                                             + String.escapeSingleQuotes(fieldAPINameStringFixed) + ' LIKE ' + searchText + ' AND  ' + rawSOQLcriteriaString + ' LIMIT ' + recordLimitSOQL;
                                                                         objectList = Database.query(soqlQuery);
                                                                         FCR_Map = fetchCustomerContractSignatory('', '', objectList);
                                                                         System.debug(LoggingLevel.INFO, 'sObjectLookupController.soqlQuery = ' + soqlQuery);
                                                                         System.debug(LoggingLevel.INFO, 'sObjectLookupController.objectList = ' + objectList);
                                                                         /*-- EDGE-34646 --*/
                                                                         for (sObject objList : objectList) {
                                                                             AccountContactRelation ACRInstance = (AccountContactRelation)objList;
                                                                             ACRInstance.Roles = ACRInstance.Roles + '';
                                                                             ACRInstance.FCR_Association_Date__c = System.today().addDays(-99999);
                                                                             System.debug(LoggingLevel.INFO, 'sObjectLookupController.FCRDate = ' + FCR_Map.get(ACRInstance.ContactId));
                                                                             if (FCR_Map.get(ACRInstance.ContactId) != NULL && FCR_Map.get(ACRInstance.ContactId) != NULL) {
                                                                                 ACRInstance.Roles = ACRInstance.Roles + ', Contract Signatory';
                                                                                 ACRInstance.FCR_Association_Date__c = FCR_Map.get(ACRInstance.ContactId);
                                                                             }
                                                                             sobjectwrapperclass wrap = new sobjectwrapperclass(ACRInstance.Id, ACRInstance.Contact.Name, ACRInstance.Contact_Email__c, ACRInstance.ContactId, ACRInstance.Roles, ACRInstance.FCR_Association_Date__c);
                                                                             sobjectwrapper.add(wrap);
                                                                         }
                                                                         sobjectwrapper.sort();
                                                                         if (sobjectwrapper.size() == 0) {
                                                                             sobjectwrapperclass wrap = new sobjectwrapperclass('', 'Legal Lessee or Full Authority contacts not found', '~!!!!~Error~!!!!~', 'Error', '', system.today());
                                                                             sobjectwrapper.add(wrap);
                                                                         }
                                                                         System.debug(LoggingLevel.INFO, 'sObjectLookupController.sobjectwrapper = ' + sobjectwrapper);
                                                                         System.debug(LoggingLevel.INFO, 'sObjectLookupController.sobjectwrapper.size() = ' + sobjectwrapper.size());
                                                                         
                                                                         /*-- EDGE-34646 --*/
                                                                         // return objectList;
                                                                         return sobjectwrapper;
                                                                     }
    //EDGE-76151 : Callout to SiteSQ to get the response for given AdboreId
    @AuraEnabled
    public static String siteSQWebCallout(String basketId, Integer recordCount, Integer batchSize, Integer offSetValue, String stringErrorIds, String AccountId) {
        SiteSQContractCallout stCallout = new SiteSQContractCallout();
        Map<String, Object> objRetrun = new Map<String, Object>();
        objRetrun.put('updateCount', true);
        boolean isSQQualified = false;
        Integer processedRecordCount = 0;
        List<String> eligibleAdboreIdList = new List<String>();
        // EDGE-88536 : Added Type__c in where clause : Manoj Kumar
        List<cscfga__Product_Configuration__c> prdConfList =
            [
                SELECT id, Name, type__c, Technology_Type__c
                FROM cscfga__Product_Configuration__c
                WHERE cscfga__Product_Basket__c = : basketId AND
                Name = 'IP Site' AND Technology_Type__c = 'NBN Access' AND Type__c = 'New'
            ];
        
        if (!prdConfList.IsEmpty()) {
            Set<Id> pcIdSet = new Set<Id>();
            for (cscfga__Product_Configuration__c pc : prdConfList) {
                pcIdSet.Add(pc.Id);
            }
            List<String> adborId_List = new List<String>();
            List<cscfga__Attribute__c> attList = [
                SELECT id, name, cscfga__Value__c
                FROM cscfga__Attribute__c
                WHERE Name = 'AdborID' AND cscfga__Product_Configuration__c in :pcIdSet
                Order By CreatedDate DESC
                Limit: batchSize
                Offset :offSetValue
            ];
            
            if (!attList.IsEmpty()) {
                for (cscfga__Attribute__c att : attList) {
                    if (att.cscfga__Value__c != null)
                        adborId_List.add(att.cscfga__Value__c);
                }
            }
            System.debug(LoggingLevel.INFO, 'sObjectLookupController.adborId_List = ' + adborId_List);
            if (!adborId_List.IsEmpty()) {
                eligibleAdboreIdList = stCallout.getConfigurableAddressIdList(adborId_List, AccountId);
                if (!eligibleAdboreIdList.IsEmpty()) {
                    try {
                        System.debug(LoggingLevel.INFO, 'eligibleAdboreIdList---- ' + eligibleAdboreIdList);
                        Map<String, HttpResponse> addressToResponseMap = new  Map<String, HttpResponse>();
                        SiteSQContractCallout SQctrl = new SiteSQContractCallout();
                        addressToResponseMap = SQctrl.initiateSQService(eligibleAdboreIdList,AccountId);
                        System.debug(LoggingLevel.INFO, 'addressToResponseMap## ' + addressToResponseMap);
                        
                        if (addressToResponseMap.IsEmpty() || addressToResponseMap == null) {
                            // return '{"status":"error","text":"'+Label.Site_SQ_Failed+'"}';
                        } else {
                            
                            /* Irritrate over response to get all the errors if any*/
                            for (String aId : eligibleAdboreIdList) {
                                if ( addressToResponseMap.ContainsKey(aId) ) {
                                    if (addressToResponseMap.get(aId).getStatusCode() != 200) {
                                        invalidResponse.add(aId);
                                    } else {
                                        if (addressToResponseMap.get(aId).getStatusCode() == 200) {
                                            HttpResponse res = addressToResponseMap.get(aId);
                                            SqResponseDTO responseDTO = SqResponseDTO.parse(res.getBody());
                                            
                                            if (responseDTO != null && responseDTO.data != null) {
                                                List<SqResponseDTO.ServiceTypeQualifications> srvQualificationList = responseDTO.data.serviceTypeQualifications;
                                                if (!srvQualificationList.isEmpty()) {
                                                    for (SqResponseDTO.ServiceTypeQualifications sq : srvQualificationList) {
                                                        System.debug(LoggingLevel.INFO, 'sq.Status ' + sq.Status);
                                                        if (sq.Status == 'Unavailable' || sq.copperPairIndicator == 'No') {
                                                            invalidResponse.add(aId);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } catch (Exception ex) {
                        System.debug(LoggingLevel.INFO, 'Error occurred## ' + ex.getMessage());
                        System.debug(LoggingLevel.INFO, 'Error Line## ' + ex.getLineNumber());
                        System.debug(LoggingLevel.INFO, 'Error Trace## ' + ex.getStackTraceString());
                        System.debug(LoggingLevel.INFO, 'Error Cause## ' + ex.getCause());
                    }
                    processedRecordCount = eligibleAdboreIdList.size();
                } else {
                    /*-- Logic to Update In-Progress Record --*/
                    objRetrun.put('updateCount', false);
                }
            } else {
                /*-- Logic to Update In-Progress Record --*/
                objRetrun.put('updateCount', false);
            }
        }
        //  invalidResponse.add('141671381');
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.offSetValue = ' + offSetValue);
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.invalidResponse = ' + invalidResponse);
        offSetValue = offSetValue + batchSize;
        stringErrorIds = + stringErrorIds + ',' + String.join(invalidResponse, ', ');
        Set<String> setInvalidAdboreId = new Set<String>(stringErrorIds.removeStart(',').removeEnd(',').split(','));
        objRetrun.put('offSetValue', offSetValue);
        objRetrun.put('stringErrorIds', stringErrorIds);
        objRetrun.put('ErrorCount', invalidResponse.size());
        objRetrun.put('showError', false);
        if (invalidResponse.size() > 0 || setInvalidAdboreId.size() > 0) {
            objRetrun.put('showError', true);
        }
        objRetrun.put('processedRecordCount', processedRecordCount);
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.objRetrun = ' + objRetrun);
        return JSON.Serialize(objRetrun);
    }
    
    // Update PC status to incomplete if there is any error in the response from SiteSQ
    @AuraEnabled
    public static Boolean UpdateRelatedDataForSQSite(String basketId, String stringErrorIds) {
        stringErrorIds = stringErrorIds.removeStart(',').removeEnd(',');
        List<String> lstErrorIds  = stringErrorIds.split(',');
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.lstErrorIds = ' + lstErrorIds);
        cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
        System.debug(LoggingLevel.INFO, 'sObjectLookupController.productBasket.csbb__Account__r = ' + productBasket.csbb__Account__r);
        // invalidResponse.add('141671381');
        if (lstErrorIds.size() > 0) {
            Set<String> setInvalidAdboreId = new Set<String>(lstErrorIds);
            List<String> adborId_List = new List<String>();
            list<cscfga__Product_Configuration__c> invalidPC = New list<cscfga__Product_Configuration__c>();
            List<cscfga__Product_Configuration__c> prdConf_genericList =
                [
                    SELECT id, Name, type__c, Technology_Type__c, (
                        select id, name, cscfga__Value__c
                        from cscfga__Attributes__r
                        where Name = 'AdborID'
                    )
                    FROM cscfga__Product_Configuration__c
                    // EDGE-88536 : Added Type__c in where clause : Manoj Kumar
                    WHERE cscfga__Product_Basket__c = : basketId AND
                    Name = 'IP Site' AND
                    Technology_Type__c = 'NBN Access' AND
                    Type__c = 'New'
                ];
            if (!prdConf_genericList.IsEmpty()) {
                System.debug(LoggingLevel.INFO, 'sObjectLookupController.prdConf_genericList = + ' + prdConf_genericList);
                for (cscfga__Product_Configuration__c pcRec : prdConf_genericList) {
                    
                    if (!pcRec.cscfga__Attributes__r.IsEmpty() && pcRec.Name == 'IP Site' && pcRec.Technology_Type__c == 'NBN Access') {
                        for (cscfga__Attribute__c att : pcRec.cscfga__Attributes__r) {
                            if (att.cscfga__Value__c != null)
                                adborId_List.add(att.cscfga__Value__c);
                            if (setInvalidAdboreId.contains(att.cscfga__Value__c)) {
                                cscfga__Product_Configuration__c iPC = new cscfga__Product_Configuration__c();
                                iPC.Id = pcRec.Id;
                                iPC.cscfga__Configuration_Status__c = 'Incomplete';
                                invalidPC.add(iPC);
                            }
                        }
                    }
                }
                if (!invalidPC.IsEmpty()) {
                    System.debug(LoggingLevel.INFO, 'sObjectLookupController.adborId_List = ' + adborId_List);
                    update invalidPC;
                }
            }
        }
        return null;
    }
    //EDGE-190520 FAM Contract Initiation  //DIGI-434 Changed the return type form  FA_DefaultRecipients__c to String
    @AuraEnabled
    public static String createRecordFA(Id famID, String signer2, String signer3,AgreementUtilities.AgreementDecision agreementDecision) {
        
        List<csconta__Frame_Agreement__c> famList=[SELECT Id,is_Deal_Escalated__c, Name,csconta__Agreement_Name__c,csconta__Status__c, Opportunity__c, Opportunity__r.AccountId,Opportunity__r.Account.APTPS_Contract_Manager__c, Delegated_Pricing_Request__c,Delegated_Pricing_Request__r.Name,Delegated_Pricing_Request__r.Deal_Status__c,Deal_Approver__c,Final_Delegation_Outcome__c FROM csconta__Frame_Agreement__c
                                                   WHERE Id = :famID LIMIT 1]; // Opportunity__r.AccountId,Opportunity__r.Account.manager, Added as a part of DIGI-434
        
        if(famList[0].Delegated_Pricing_Request__c != null){            
            //Update FAM record status
            Delegated_Pricing_Request__c dpr = [Select Id,Opportunity__r.Contract_Type__c, Account__c,Name,Opportunity__c From Delegated_Pricing_Request__c where id =:famList[0].Delegated_Pricing_Request__c];
            csconta__Frame_Agreement__c fa = new csconta__Frame_Agreement__c(
                Id = famList[0].Id,
                csconta__Status__c = 'Contract Initiated');
            update fa;
            
            //Insert default Recepient record
            FA_DefaultRecipients__c fdr = new FA_DefaultRecipients__c(
                Signatory_1__c= signer2,
                Signatory_2__c = signer3,
                Deal_Pricing_Request__c = famList[0].Delegated_Pricing_Request__c);
            insert fdr;
            
            //Update DPR record status
            dpr.Deal_Status__c = 'Contract Initiated';
            update dpr; 
            
            //DIGI-434 Started
            if(agreementDecision == null){
                agreementDecision = AgreementDealUtilities.resolveSAType(dpr);   // ResolveSAType will helps to handl the Logic and Identify Case creation is required or Not   
            }
            Apttus__APTS_Agreement__c agmtSA;
            Apttus__APTS_Agreement__c agmtPS;
            List<Id> aliIds ; 
            List<Apttus__APTS_Agreement__c> agmts;
            List<Apttus__APTS_Agreement__c> saagmts = new List<Apttus__APTS_Agreement__c>();
            List<FA_DefaultRecipients__c> faDefaultRecordlst;
            OpportunityContactRole oppContactRole ; 
            String message='';
            if(agreementDecision.caseCreation != null && agreementDecision.caseCreation == true ){
                //Case Creation Logic 
                /** if the Legacy Agreement Detected then create case */
                /** DIGI-434 STARTED - Added the below code to create the Case by Lokesh Thathuru */
                List<String> listOfLegacyMatchedProductFamilies = new List<String>(agreementDecision.legacyPFMatchedSet);
                System.debug('listOfLegacyMatchedProductFamilies => '+listOfLegacyMatchedProductFamilies);
                String caseDescription='Legacy agreement detected for product families: '+String.join(listOfLegacyMatchedProductFamilies,',') +'. '+
                    ' A digital contract executed for product families:'+String.join(listOfLegacyMatchedProductFamilies,',') +'  through Basket '+ famList[0].Delegated_Pricing_Request__r.Name +' could not be continued,'+ //DRP.NAME
                    ' as there is an active legacy agreement for product families:'+String.join(listOfLegacyMatchedProductFamilies,',') +'.'+
                    ' The existing Agreement needs to be updated for the digital contract to proceed.';
                String subject='Action required: Legacy Agreements containing '+String.join(listOfLegacyMatchedProductFamilies,',') +' undergoing digitization';
                Id aCMUserIdorCMGUserId=null;
                if(famList[0].Opportunity__r.Account.APTPS_Contract_Manager__c!=null){ // query on DPR 
                    aCMUserIdorCMGUserId=famList[0].Opportunity__r.Account.APTPS_Contract_Manager__c;
                }else{
                    aCMUserIdorCMGUserId=[SELECT id,UserName, Name, Email from User WHERE Name = 'Contract Management Group'].Id;
                }
                Case caseInstance = AgreementUtilities.generateContractSupportCase(caseDescription, aCMUserIdorCMGUserId,subject,famList[0].Opportunity__c); // Delegated_Pricing_request__r.Opportunity__c from 
                
                // Case Insertion for Legacy Contracts. and check the access and perform the DML
                if(caseInstance!=null &&  Case.sObjectType.getDescribe().isAccessible() && Case.sObjectType.getDescribe().isCreateable()){
                    if(Test.IsRunningTest())
                        caseInstance.soc_Request_Type__c = 'Contract Queries';
                    insert caseInstance;
                    //delete [SELECT id,Name FROM FA_DefaultRecipients__c WHERE Id=: fdr.id];
                }
                agreementDecision.caseNumber = [SELECT id,CaseNumber FROM Case WHERE id =: caseInstance.id].CaseNumber;
                Delegated_Pricing_Request__c drpInstance1 = new Delegated_Pricing_Request__c(
                    Id = famList[0].Delegated_Pricing_Request__c,
                    Deal_Status__c = 'Approved');
                update drpInstance1;
                csconta__Frame_Agreement__c faInstance = new csconta__Frame_Agreement__c(
                    Id = famList[0].Id,
                    csconta__Status__c = 'Approved');
                update faInstance;
                String matchedPFamilies=String.join(new List<String>(agreementDecision.legacyPFMatchedSet), ',');
                message=  ' Contract cannot be proceeded, as an existing Legacy Agreement '+
                            +' was detected for '+matchedPFamilies +' . A case '+
                            + agreementDecision.caseNumber +' has been assigned to the contracting manager for action.'
                            +' This contract can be continued after this legacy agreement is updated';
        
              return message;
            }else{
                GenerateDelegatedPricingContract.createContract(new List<Delegated_Pricing_Request__c>{dpr},agreementDecision);
                message = 'Agreement has been created.';
                return message;
            }
           /* DIGI-434 END */
        }   
        else{
            return null;
        }        
        
    }
    // Commented out : EDGE-88536
    // Update attribute values based on the successfull response from SiteSQ
    public static void mapResponseToField(String basketId, Map<String,HttpResponse> addressToResponseMap){
        
    /* EDGE-83086 - 17/05/2019
    System.debug('mapResponseToField');
List<cscfga__Attribute__c> attToUpdateList = new List<cscfga__Attribute__c>();
Map<String,List<cscfga__Attribute__c>> attMap = new Map<String,List<cscfga__Attribute__c>>();
Map<String,Service_qualification__c> serviceQmap = new Map<String,Service_qualification__c>();

List<cscfga__Product_Configuration__c> prdConfList = [SELECT id, Name, type__c,Technology_Type__c,
                                                      (select id,name,cscfga__Value__c from cscfga__Attributes__r where Name in 
                                                       ('AdborID','NBNAvailability','ServiceabilityClass','NBNTechnologyType','BandwidthType','MaxUploadSpeed','MaxDownloadSpeed','ServiceStartDate')
                                                       Order by Name)
                                                      FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND Name = 'IP Site' AND Technology_Type__c = 'NBN Access'];
System.debug('***prdConfList '+prdConfList[0].cscfga__Attributes__r);
//Site service qualification list
List<cscrm__Site__c> siteList = [SELECT id,AdborID__c,
                                 (SELECT Address_ID__c,Serviceability_Class__c,Ready_for_Service_Date__c,CreatedDate,Copper_Pair_Indicator__c,Status__c,Technology_Type__c,Max_Downstream_Speed__c,Max_Upstream_Speed__c
                                  from Service_qualifications__r WHERE CreatedDate = Today ORDER BY CreatedDate LIMIT 1)
                                 FROM cscrm__Site__c WHERE AdborID__c IN  :addressToResponseMap.Keyset()];
System.debug('***siteList '+siteList[0].Service_qualifications__r);
If(!siteList.IsEmpty()) {
    For(cscrm__Site__c cs : siteList){
        if(!cs.Service_qualifications__r.IsEmpty()){
            serviceQmap.put(cs.AdborID__c,cs.Service_qualifications__r[0]);
        }
    }
    
}

System.debug('***serviceQmap '+serviceQmap);

if(!prdConfList.IsEmpty()){
    for(cscfga__Product_Configuration__c pcRec : prdConfList){
        if(!pcRec.cscfga__Attributes__r.IsEmpty()){
            for(cscfga__Attribute__c att : pcRec.cscfga__Attributes__r){
                if(Att.Name == 'AdborID' && Att.cscfga__Value__c != null){
                    attMap.put(Att.cscfga__Value__c,pcRec.cscfga__Attributes__r);
                    break;
                }
                
            }}}}
System.debug('***attMap '+attMap);
System.debug('***serviceQmap '+serviceQmap);
if(!attMap.IsEmpty() && !serviceQmap.IsEmpty()){
    
    for(Service_qualification__c sqRec : serviceQmap.Values()){
        for(String attAboreId : attMap.Keyset()){
            if(attAboreId == sqRec.Address_ID__c){
                for(cscfga__Attribute__c attRec : attMap.get(attAboreId)){
                    if(attRec.Name == 'ServiceabilityClass')
                    {
                        attRec.cscfga__Value__c = sqRec.Serviceability_Class__c;
                        attToUpdateList.add(attRec);
                    } 
                    
                    if(attRec.Name == 'MaxUploadSpeed')
                    {
                        attRec.cscfga__Value__c = sqRec.Max_Upstream_Speed__c;
                        attToUpdateList.add(attRec);
                    }     
                    
                    if(attRec.Name == 'MaxDownloadSpeed')
                    {
                        attRec.cscfga__Value__c = sqRec.Max_Downstream_Speed__c;
                        attToUpdateList.add(attRec);
                    }    
                    
                    if(attRec.Name == 'NBNAvailability')
                    {
                        attRec.cscfga__Value__c = sqRec.Status__c;
                        attToUpdateList.add(attRec);
                    } 
                    if(attRec.Name == 'ServiceStartDate')
                    {
                        attRec.cscfga__Value__c = String.valueOf(sqRec.Ready_for_Service_Date__c);
                        attToUpdateList.add(attRec);
                    } 
                }
            }
            
        }
        
    }
    
    if(!attToUpdateList.IsEmpty()){
        System.debug('attToUpdateList ##' +attToUpdateList);
        update attToUpdateList;
    }
}*/
    }
    
    /*  
    * Method Name : insertTransactionLogs
    * Author : Gautam Kumar
    * Jira : DIGI-11211
   */
    @AuraEnabled
    public static void insertTransactionLogs(String oppId, String basketId, String accountId, String basketName, String type, String famID){
        
    system.debug('G*G insertTransactionLogs sObjectLookupController outer called '+ oppId);
    if(type == 'FAM' && String.isNotBlank(famID)) 
    {
        csconta__Frame_Agreement__c frmAgrmt = Model_FrameAgreement.getFrameAgreements(famID);
        oppId = frmAgrmt.Opportunity__c;
    }

    if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion')
    && FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion') 
    && String.isNotBlank(type) && String.isNotBlank(oppId)){
        Opportunity opp = [Select Id, Type From Opportunity Where Id =: oppId LIMIT 1];
        Map<String,Object> loggerdetailsMap=new Map<String,Object>();
        if(type == 'FAM' && accountId != null){
            system.debug('G*G insertTransactionLogs sObjectLookupController FAM called ');
            loggerdetailsMap.put('event','FAM Contract generation initiated');
            loggerdetailsMap.put('OrderType', opp.Type);
            TransactionLogger.insertTransactionLogs(oppId + '-' + accountId,loggerdetailsMap,'sObjectLookupController');
        }
        else if(type == 'CONTRACT' && basketId != null){
            system.debug('G*G insertTransactionLogs CONTRACT called ');
            loggerdetailsMap.put('event','Contract generation initiated');
            loggerdetailsMap.put('OrderType', opp.Type);
            loggerdetailsMap.put('basketName', basketName);
            TransactionLogger.insertTransactionLogs(oppId + '-' + basketId,loggerdetailsMap,'sObjectLookupController');
            }
        }

    }
    
    
}