/*
* @Author : Rahul Asarma
* @Date : 27 Oct 2020
* @Desc : Quote Generation class for Delegated Pricing
* @Jira Cloud : EDGE-176683 & EDGE-185984
*/
public with sharing class GenerateDelegatedPricingQuote {
      static final String delegatedPricingTemplateid = system.label.DelegatedPricingTemplateid;
    
    //This method has written to create Delegated Pricing Quote
   public static GenerateQuoteResult createQuote(Id frameAgreementId){
         GenerateQuoteResult returnVal = new GenerateQuoteResult();
    if(/*frameAgreementId == ''){ || */frameAgreementId == null){
            returnVal.errorMessage = 'Quote generation failed: Frame Agreement Id is Null';
            return returnVal;
    }
    
        String queryParams='&QueryId=';
         String delimiter=',';  
        Map<id, APXTConga4__Conga_Merge_Query__c> congaQueriesRecords = new Map<id, APXTConga4__Conga_Merge_Query__c>([select id,APXTConga4__Name__c from APXTConga4__Conga_Merge_Query__c]);
        if(!congaQueriesRecords.isEmpty()){
            Map<String,APXTConga4__Conga_Merge_Query__c> congaRecordMap= new Map<String,APXTConga4__Conga_Merge_Query__c> ();
            for(APXTConga4__Conga_Merge_Query__c congaQueryLoop:congaQueriesRecords.values()){
                congaRecordMap.put(congaQueryLoop.APXTConga4__Name__c,congaQueryLoop);
            }
            String congaQueryResult=DelegatedPricingCongaUrlBuilder.congaURLCreater(congaRecordMap,frameAgreementId);
            
            if(congaQueryResult!=null)
                queryParams = queryParams +congaQueryResult;
             
        }
        queryParams=queryParams.substringBeforeLast(delimiter);
        system.debug('queryParamsvalues'+queryParams);
        csconta__Frame_Agreement__c frameAgreement = fetchFrameAgreement(frameAgreementId); 
        System.debug(' frameAgreement '+frameAgreement);
        
    //return null;
     return insertQuote(frameAgreement,queryParams);
   }
    
    public static GenerateQuoteResult insertQuote(csconta__Frame_Agreement__c frameAgreement,String queryParams){
        GenerateQuoteResult returnVal = new GenerateQuoteResult();
        String congaUrl= '&Id=';
        Quote quote;
        String quotePresent='SELECT '+ String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Quote')) +' FROM Quote WHERE Frame_Agreement__c=\''+ String.escapeSingleQuotes(frameAgreement.Id) +'\'';
            List <Quote> listquote = Database.query(quotePresent);
            System.debug('GenerateQuoteHelper : listquote ..'+listquote );                   
            if(listquote !=null && !listquote.isEmpty()){ //to check if quote already present{
                System.debug('Quote exists, updating it');
                quote = listquote[0]; 
                returnVal.Id = listquote[0].Id;
                returnVal.success = 'Quote Generated Sucessfully';
            }
            else{
                 try{
        
                        Quote dealQuote = new Quote();
                        dealQuote.Name = frameAgreement.name;
                        dealQuote.Frame_Agreement__c = frameAgreement.Id;
                        dealQuote.opportunityid=frameAgreement.Opportunity__c;
                        dealQuote.ExpirationDate =system.today()+30;
                        dealQuote.Conga_Status__c ='InProgress' ;
                        dealQuote.ContactId = fetchDelegatedQuoteRecipient(frameAgreement);
                        dealQuote.Conga_Request_Time__c = System.now();
                        insert dealQuote;
                        
                        String soqlQuery = SObjectHelper.getFieldListForSOQL('Quote');
                        String quoteQuery='SELECT '+ String.escapeSingleQuotes(soqlQuery) +' FROM Quote WHERE Id=\'' +dealQuote.Id + '\'';
                        quote = Database.query(quoteQuery);
                        congaUrl=congaUrl+ quote.Id +'&TemplateId='+delegatedPricingTemplateid+'&FP0=1'+'&QMode=Attachments';
                        //congaUrl=congaUrl+queryParams+ '&OFN=' + EncodingUtil.urlEncode(quote.QuoteNumber, 'UTF-8')+'&AttachmentParentId='+quote.Id;
                        congaUrl=congaUrl+queryParams+ '&OFN=' + EncodingUtil.urlEncode(frameAgreement.name, 'UTF-8')+'&AttachmentParentId='+quote.Id;
                        quote.Conga_URL__c =congaUrl;
                        if (quote.Conga_Status__c =='Error'){
                            System.debug('Updating conga status and time:'+quote.Conga_Status__c);
                            quote.Conga_Status__c ='InProgress' ;
                            quote.Conga_Request_Time__c = System.now();   
                        }
                        
                        if(quote!=null)
                        upsert quote;
                    
                        returnVal.Id = quote.Id;
                        returnVal.success = 'Quote Generated Sucessfully';
                        
                        frameAgreement.csconta__Status__c='Quote';
                        update frameAgreement;
                    }
                    catch(DMLException e){
                        returnVal.Id = quote.Id;
                        returnVal.errorMessage = 'Quote generation failed: Please try again and contact your admin if the issue persist';
                    }
            }
            
            //return quote.Id;
            return returnVal;
                
    }
   //This method has written to fetch Frame Agreement Record
   public static csconta__Frame_Agreement__c fetchFrameAgreement(String frameAgreementId) {
        String queryFrameAgreement ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('csconta__Frame_Agreement__c'))+ '  FROM csconta__Frame_Agreement__c WHERE Id =: frameAgreementId'; 
        return Database.query(queryFrameAgreement);
    }
    //This method has written to fetch Quote Recipient
    public static String fetchDelegatedQuoteRecipient(csconta__Frame_Agreement__c frameAgreement) {
        if(Limits.getQueries() < 101){
            list<AccountContactRelation> All_ACR = new list<AccountContactRelation>();
            list<Id> listContactIdFCR = New list<Id>();    
            for(AccountContactRelation ACR : [SELECT Id, ContactId FROM AccountContactRelation 
                                              WHERE ( Roles= 'Full Authority' OR Roles = 'Legal Lessee') 
                                              AND AccountId =: frameAgreement.csconta__Account__c Order By CreatedDate DESC]){
                if(ACR.ContactId != NULL){
                    listContactIdFCR.add(ACR.ContactId);
                    All_ACR.add(ACR);
                } 
            }
            Date todayDate = System.TODAY()-1;
            list<Functional_Contact_Role__c> FCRRecord = [SELECT Id, ContactID__c FROM Functional_Contact_Role__c 
                                                          WHERE Role__c = 'Contract Signatory Role' AND ContactID__c IN: listContactIdFCR 
                                                          AND (Relationship_End_Date__c >: todayDate OR Relationship_End_Date__c = NULL) order by createddate DESC LIMIT 1]; 
            if(FCRRecord.size()>0){
                return FCRRecord[0].ContactID__c;
            }
            else{
                // return NULL;
                if(All_ACR.size() > 0){
                    return All_ACR[0].ContactId;
                }
            }
        }
        return NULL;
    }
    
    public class GenerateQuoteResult{
       public String Id = '';
        public String success = '';
        public String errorMessage = '';
    }

}