public with sharing class transactionLogCapture{
    @InvocableMethod(label='transactionLogCapture')
       public static void transactionLogCaptureMethod(list<Opportunity> opportunityList){
           system.debug('opportunityList'+opportunityList);
           Set<String> oppIdSet = new Set<String>();
           for(Opportunity opp: opportunityList){
               oppIdSet.add(opp.Id);
               //insertOpportunityTransactionLogsCRM(string.valueOf(tran.opptyId));
           }
           
           if(!oppIdSet.isEmpty() && (FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion')
                                     && FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')))
               insertOpportunityTransactionLogsCRM(oppIdSet);
       }
       public static void insertOpportunityTransactionLogsCRM(Set<String> oppIdSet) {
           system.debug('insertOpportunityTransactionLogsCRM--->');
           Map<String,Object> loggerdetailsMap=new Map<String,Object>();
           //get basket records
           for(cscfga__Product_Basket__c basket: [Select Id, cscfga__Opportunity__c, cscfga__Opportunity__r.Type, 
                                                  cscfga__Opportunity__r.Name,cscfga__Opportunity__r.StageName,
                                                  cscfga__Opportunity__r.isClosed
                                                  From cscfga__Product_Basket__c
                                                  Where cscfga__Opportunity__c In: oppIdSet
                                                  And csordtelcoa__Synchronised_with_Opportunity__c= true
                                                  And Primary_Basket__c=true
                                                  LIMIT 10000]){
           
                      
           String event = basket.cscfga__Opportunity__r.isClosed == false ? 'Opportunity Closure Initiated' : 'Opportunity Closure Completed';
           String basketId = basket.Id != null && String.ValueOf(basket.Id).length()>= 15?
           String.ValueOf(basket.Id).subString(0,15) : '';
           string correlationId = basket.cscfga__Opportunity__c +'-'+ basketId;
           loggerdetailsMap.put('event',event);
           loggerdetailsMap.put('OpportunityName',basket.cscfga__Opportunity__r.Name);
           loggerdetailsMap.put('OpportunityType',basket.cscfga__Opportunity__r.Type);
           loggerdetailsMap.put('OpportunityStage',basket.cscfga__Opportunity__r.StageName);
           
           
           TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'CloseOppFlowValidations');
           }
       
       }
        public class transactionRequest{
           
           @InvocableVariable
           public Id opptyId;
        }
     }