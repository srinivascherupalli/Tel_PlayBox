/**
*  Description of the purpose of the method.
*  @name PrmMACDPOR
*  @description               : This Class is to Create or Modify Partner of Record and POR Domain in PRM.
*  @param                     : Partner of Record Record Details.
*  @return                    : Partner of Record Record ID. 
*  @Jira Story Ref            : EDGE-210146
*  @createdBy                 : Purushottama Sahu, Alexandria
*
*  ** Change Log **
*  Sl. No.  Developer Name      Date            Story           Description
*  1.       Pooja               12/05/2021      EDGE-202803     UI Domain View - Multi POR in TPC view # 1
**/
public without sharing class PRM_MACDPORCtrl {
    public static final String MODIFICATION_IN_PROGRESS_STRING = 'Modification in progress';
    public static final String CANCELLED_STRING = 'Cancelled';
    public static final String DECLINED_STRING = 'Declined';


    public static List<String> DECLINEDLIST = new List<String>{'Cancelled','Declined','Customer Declined','Partner Declined','Withdraw'};
    @AuraEnabled
    public static String createPOR(String porDetails){
        String result; 
        list<string> inflightStatus= new list<string>{'Initiated','Pending Approval','Partner review','Customer Review'};
            try{
                
                PORDetails details = (PORDetails)System.JSON.deserialize(porDetails, PORDetails.Class);


                system.debug('createPOR*** ' + details);
                
                if(details!=null){
                    //Create Partner of Record
                    Partner_of_Record__c porRecord = new Partner_of_Record__c(
                        Partner__c=details.partnerAccountId,
                        Partner_Signatories__c=details.partnerContactId,
                        Customer__c=details.accountRecordId,
                        Customer_Signatories__c= details.contactId,
                        Agreement_Duration__c=details.duration,

                        TLS_ProductDomain__c = (details.domain).replace(';',','),
                        Is_Duration_Changed__c = true
                    );


                    list<Partner_of_Record_Domain__c> porList = [select id,name,Status__c,Partner_of_Record__c,Partner_of_Record__r.por_status__c from Partner_of_Record_Domain__c where Partner_of_Record__r.Partner__c=:details.partnerAccountId AND Partner_of_Record__r.Customer__r.id=:details.accountRecordId and Domain_Name__c =:details.domain

                                                                 and Status__c in: inflightStatus and Partner_of_Record__r.por_status__c = 'Active'];
                    system.debug('*******'+porList);
                    system.debug('porList@@@'+details.accountRecordId);


                    if(porList.size() >0){
                        result = porList[0].Status__c;
                    }else{
                        insert porRecord;
                        result=porRecord.id;
                        
                        //Create ContentDocumentLink and Generate CongaURL
                        createContentDocumentLink(porRecord.Id, details.documentId);
                        
                        //Create Partner of Record Domain Records
                        upsertPORDomainRecords(details,porRecord.Id);
                        
                        // Submitting request for Partner Of Record Agreement Approval
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setComments('Submitting request for approval.');
                        req.setObjectId(porRecord.id);
                        req.setProcessDefinitionNameOrId('Partner_Of_Record_Agreement_Approval');
                        Approval.ProcessResult approvalResult = Approval.process(req);
                    }
                }
            }
        catch(Exception e){
            System.debug('Exception in createPOR'+e.getStackTraceString());
            result= e.getMessage();
        }
        return result;
    }
    @AuraEnabled
    public static Partner_of_Record__c getPORRecord(Id recordId){
        Partner_of_Record_Domain__c porDomainRecord = new Partner_of_Record_Domain__c();
        Partner_of_Record__c porRecord = new Partner_of_Record__c();
        if(recordId!=null){
            porRecord = [Select Id,Name,End_Date__c,POR_End_Date__c,Customer__c,Customer__r.Name,Customer_Signatories__c,Customer_Signatories__r.Name,
                         (Select Id,Name,Domain_Name__c from Partner_of_Record_Domain__r where Status__c='Active') from Partner_of_Record__c where Id=:recordId];
        }
        return porRecord;
    }

    

    @AuraEnabled
    public static String updatePOR(String porDetails){
        String result;
        try{
            PORDetails details = (PORDetails)System.JSON.deserialize(porDetails, PORDetails.Class);

            system.debug('updatePOR*** ' + details);

            if(details!=null){
                //Update Partner of Record
                Partner_of_Record__c porRecord = new Partner_of_Record__c(
                    Id=details.porRecordId,
                    Partner__c=details.partnerAccountId,
                    Partner_Signatories__c=details.partnerContactId,
                    Customer__c=details.accountRecordId,
                    Customer_Signatories__c= details.contactId,
                    Status__c = MODIFICATION_IN_PROGRESS_STRING,
                    Is_Domain_Cancelled__c = false,
                    Is_Duration_Changed__c = details.duration =='NoChange' ? false : true
                );

                if(!String.isEmpty(details.duration) && details.duration !='NoChange'){
                porRecord.Agreement_Duration__c= details.duration;
                }

                //porRecord.TLS_ProductDomain__c = details.domain;
                update porRecord;
                result=porRecord.id;
                
                //upsert PORDomain Records
                upsertPORDomainRecords(details,porRecord.Id);
                
                //Generate Conga URL
                GeneratePORAgreement.updatePORCongaURL(new List<Id>{porRecord.Id});
                
                // Submitting request for Partner Of Record Agreement Approval
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for Modification approval.');
                req.setObjectId(porRecord.id);
                req.setProcessDefinitionNameOrId('Partner_Of_Record_Modify_Approval');
                Approval.ProcessResult approvalResult = Approval.process(req);
            }
        }
        catch(exception e){
            result= e.getMessage();
            system.debug('debug'+e.getMessage());
            if(!Test.isRunningTest()){
                throw new AuraHandledException(result);
            }
        }
        return result;
        
    }
    @AuraEnabled


    public static String PORDomainValidation(String accountRecordId,String partnerAccountId,String selecteddomain,String porRecordId ){

        String result;
        list<string> inflightStatus= new list<string>{'Initiated','Pending Approval','Partner review','Customer Review','Active'};
            system.debug('accountRecordId'+accountRecordId);
        system.debug('selecteddomain'+selecteddomain.replace('"',''));
        
        list<Partner_of_Record_Domain__c> porList = [select id,name,Status__c from Partner_of_Record_Domain__c where Partner_of_Record__r.Customer__r.id=:accountRecordId AND Domain_Name__c =: selecteddomain.replace('"','') AND Partner_of_Record__c != :porRecordId
                                                     and ((Status__c in: inflightStatus) OR (Status__c ='Active' AND Sub_Status__c in: inflightStatus ))];
        
        system.debug('porList'+porList );                                                    
        if(porList.size() >0){
            result = porList[0].Status__c;
        }
        return result;          
    }
    
     
    
    @TestVisible
    private static void createContentDocumentLink(Id porRecordId, Id cdlId){
        // Commenting createContentDocumentLink as part of Digi-1553
        /*
        if(String.isNotBlank(cdlId)) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = porRecordId;
            cdl.ContentDocumentId = cdlId;
            cdl.shareType = 'V';
            Insert cdl;
        }*/
        //Generate Conga URL
        GeneratePORAgreement.updatePORCongaURL(new List<Id>{porRecordId});
    } 
    
    @TestVisible
    private static void upsertPORDomainRecords(PRM_MACDPORCtrl.PORDetails details, Id porRecordId){

        system.debug('***upsertPORDomainRecords*** ' + details + ' ' + porRecordId);
        list<Partner_of_Record_Domain__c> P_list1 =new list <Partner_of_Record_Domain__c>();
        List<String> cancelDomain = String.isBlank(details.cancelDomain) ? new List<String>() : details.cancelDomain.split(';');
        List<Partner_of_Record_Domain__c> upsertList = new List<Partner_of_Record_Domain__c>();
        List<String> lstDomain = details.domain.replace('null;','').replace('null','').split(';');
        Map<String,Partner_of_Record_Domain__c> porDomainNameMap = new Map<String,Partner_of_Record_Domain__c>();
        List<Partner_of_Record__c> porToUpdate = new List<Partner_of_Record__c>();
        try{

            for(Partner_of_Record_Domain__c porDomain : [SELECT Id,Domain_Name__c,Partner_of_Record__c,Partner_of_Record__r.Is_Duration_Changed__c,Status__c,Sub_Status__c FROM Partner_of_Record_Domain__c 
                                                         WHERE Partner_of_Record__c=:porRecordId]){
                                                             porDomainNameMap.put(porDomain.Domain_Name__c,porDomain);
                                                         }          



            system.debug('***porDomainNameMap*** ' + porDomainNameMap.size() + ' ' + porDomainNameMap);
            system.debug('***lstDomain*** ' + lstDomain.size() + ' ' + lstDomain);                                                
            system.debug('***cancelDomain*** ' + cancelDomain.size() + ' ' + cancelDomain);                                                
            for(String domainStr: lstDomain){

            

      
              if(!porDomainNameMap.isEmpty() && porDomainNameMap.containsKey(domainStr) && !DECLINEDLIST.contains(porDomainNameMap.get(domainStr).Status__c) &&  porDomainNameMap.get(domainStr).partner_of_Record__r.Is_Duration_Changed__c == true ){
                    upsertList.add(new Partner_of_Record_Domain__c(Id=porDomainNameMap.get(domainStr).Id, Sub_Status__c = 'Initiated'));
                }else{
                    if((!porDomainNameMap.isEmpty() && porDomainNameMap.containsKey(domainStr) && DECLINEDLIST.contains(porDomainNameMap.get(domainStr).Status__c)) ||


                        !porDomainNameMap.containsKey(domainStr))
                       {
                        upsertList.add(new Partner_of_Record_Domain__c(Domain_Name__c=domainStr,Partner_of_Record__c=porRecordId,Status__c='Initiated'));
                       }
                }
                
            }
            if(!cancelDomain.isEmpty()){
                for(String cancelStr : cancelDomain){
                    if(porDomainNameMap.containsKey(cancelStr) && !DECLINEDLIST.contains(porDomainNameMap.get(cancelStr).Status__c)){
                        // start Digi-1891
                        if(upsertList.isEmpty() && porDomainNameMap.get(cancelStr).partner_of_Record__r.Is_Duration_Changed__c != true ){
                            porToUpdate.add(new Partner_of_Record__c(Id=porRecordId,Is_Domain_Cancelled__c=true));
                        } // end  Digi-1891
                        upsertList.add(new Partner_of_Record_Domain__c(Id=porDomainNameMap.get(cancelStr).Id,Sub_Status__c = 'In Review - Cancellation'));
                     }
                }
            }
            P_list1 = [SELECT Id,Domain_Name__c,Partner_of_Record__c,Partner_of_Record__r.Is_Duration_Changed__c,Status__c,Sub_Status__c FROM Partner_of_Record_Domain__c 
                                                         WHERE Partner_of_Record__c=:porRecordId];
                    for(Partner_of_Record_Domain__c list1 :P_list1){
                            if(list1.Status__c == 'Cancelled'){
                        upsertList.add(new Partner_of_Record_Domain__c(Id=list1.Id,Sub_Status__c = 'Point of no return'));
                    }
                    }

            system.debug('upsertList*** ' + upsertList.size() + ' ' + upsertList);
            if(upsertList.size()>0 && !upsertList.isEmpty()){
                upsert upsertList;
            }
            if(porToUpdate.size() > 0)    upsert porToUpdate;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**********************************************************************************************************************************************
     * Method       :   fetchProductDomainData
     * Created By   :   Pooja Bhat
     * Description  :   Added as part of EDGE-202803
     *                  Used to display the Product Domain on UI - fetching the Marketable Offer and Product Categories details
     ***********************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, List<String>> fetchProductDomainData() {
        Map<String,List<String>> mapProdCtgryMarketOffr = new Map<String,List<String>>();
        for(Marketable_Offer__c oOffer : [SELECT Name,Product_Category__c,Product_Category__r.Product_Family_Level_1__c  
                                            FROM Marketable_Offer__c WHERE Product_Category__r.POR_Disabled__c = false ORDER BY NAME DESC]) {
            if(oOffer.Product_Category__c != null && oOffer.Product_Category__r.Product_Family_Level_1__c != null) {
                List<String> offerNameLst   =   new List<String>{oOffer.Name};
                String prodFamily           =   oOffer.Product_Category__r.Product_Family_Level_1__c;
                if(mapProdCtgryMarketOffr.containsKey(prodFamily)) {
                    offerNameLst.addAll(mapProdCtgryMarketOffr.get(prodFamily));
                    mapProdCtgryMarketOffr.put(prodFamily, offerNameLst);
                } else {
                    mapProdCtgryMarketOffr.put(prodFamily, offerNameLst);
                }
            }
        }
        return mapProdCtgryMarketOffr ;
    }



    @InvocableMethod
    public static void updatePORCancellation(List<Id> porId){
        List<Partner_of_Record__c>  porList = new List<Partner_of_Record__c>();
        
        for(Partner_of_Record__c por:[Select Id,Name,End_Date__c,POR_End_Date__c,Customer__c,Customer__r.Name,Customer_Signatories__c,Customer_Signatories__r.Name,


                                      (Select Id,Name,Domain_Name__c,Status__c,Sub_Status__c from Partner_of_Record_Domain__r) from Partner_of_Record__c where Id IN :porId]){
                                          Boolean isActive=false, isModificationProgress=false;
                                          for(Partner_of_Record_Domain__c domainRecord: por.Partner_of_Record_Domain__r){

                                              if(domainRecord.Status__c =='Active' && (domainRecord.Sub_Status__c== null || DECLINEDLIST.contains(domainRecord.Sub_Status__c) || domainRecord.Sub_Status__c == 'Active') ){

                                                  isActive=true;
                                              }else if((domainRecord.Status__c == 'Active' && (domainRecord.Sub_Status__c != null && ! DECLINEDLIST.contains(domainRecord.Sub_Status__c)) ) ||
                                                 (domainRecord.Status__c != 'Active' && ! DECLINEDLIST.contains(domainRecord.Status__c))){
                                                     isModificationProgress=true;
                                                 }
                                          }       


                                          if(!isModificationProgress && isActive){
                                                  por.Status__c = 'Active';
                                                  por.Sub_Status__c = 'Active';
                                                  porList.add(por);
                                          }else if(!isModificationProgress && !isActive){
                                              por.Status__c = 'Cancelled';


                                              porList.add(por);
                                          }
                                      }
        if(porList.size()>0){
            update porList;
        }
        
    }


    //Track updates on bulk updation
    public class PORDetails{
        @AuraEnabled
        public string cancelDomain;
        @AuraEnabled
        public string actionName;
        @AuraEnabled
        public Id porRecordId;
        @AuraEnabled
        public Id partnerAccountId;
        @AuraEnabled
        public Id partnerContactId ;
        @AuraEnabled
        public Id accountRecordId;
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public String domain;
        @AuraEnabled
        public String duration;
        @AuraEnabled
        public Id documentId;
    }
    
}