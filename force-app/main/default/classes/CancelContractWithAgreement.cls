public with sharing class CancelContractWithAgreement {
    
    @InvocableMethod(label='Cancel Contract' description='Cancel Contract and Agreement')
    public static void processCancellation(List<Id>ContractId){
        map<id,integer> contactwithsubmap= new map<id,integer>();
        map<id,integer> contactwithcansubmap=new map<id,integer>();
        list<csord__Subscription__c> currentCancelSub= new list<csord__Subscription__c>();
        
        if(EnvironmentVariable__c.getValues('Cancel_Contract_With_Agreement').Value__c=='True'){
            try{
                
                if(ContractId.size()>0){
                    for(csord__Subscription__c subsloop:[select id,ContractJunction__c,csord__Status__c from csord__Subscription__c where ContractJunction__c in :ContractId]){
                        currentCancelSub.add(subsloop);
                        if(contactwithsubmap.get(subsloop.ContractJunction__c)==null)
                            contactwithsubmap.put(subsloop.ContractJunction__c,1);
                        else
                            contactwithsubmap.put(subsloop.ContractJunction__c,contactwithsubmap.get(subsloop.ContractJunction__c)+1);
                        if(subsloop.csord__Status__c=='Closed Replaced'){
                            if(contactwithcansubmap.get(subsloop.ContractJunction__c)==null)
                                contactwithcansubmap.put(subsloop.ContractJunction__c,1);
                            else
                                contactwithcansubmap.put(subsloop.ContractJunction__c,contactwithcansubmap.get(subsloop.ContractJunction__c)+1);
                        }
                        
                    }
                    
                    system.debug('contactwithsubmap'+contactwithsubmap+'contactwithcansubmap'+contactwithcansubmap);
                    map<id,ContractJunction__c> mapcancontract= new map<id,ContractJunction__c>();
                    for(ContractJunction__c conj:[Select id,Status__c from ContractJunction__c where id in:ContractId]){
                        if(contactwithsubmap.get(conj.id)==contactwithcansubmap.get(conj.id)){
                            conj.Status__c='Cancelled';
                            mapcancontract.put(conj.id,conj);
                        }
                    }
                    if(mapcancontract.size()>0){
                        update mapcancontract.values();
                        /* Checking parent contract cencelation if all the child contract is cancelled*/
                        processContractCancellation(currentCancelSub[0]);
                    }
                    /* User Story  : EDGE-66499 */
                    /*
                        if(!mapcancontract.isEmpty()){
                        for(Apttus__APTS_Agreement__c  agrm:[SELECT ID,Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c IN:mapcancontract.keySet()] ){
                        system.debug('Agreement Name'+agrm.id);
                        Apttus.AgreementWebService.cancelAgreement(agrm.id);
                        }    
                        }
                    */
                }
            }
            catch(Exception e){
                system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
            }
        }
    }
    /* 
Description : Function to Cancel parent Contract when all the child contract/subscription are cancelled
*/
    public static boolean processContractCancellation(csord__Subscription__c subscription) {
        /*  Fetching parent Id from Child Contract related to subscription  */
        boolean isAllSubscriptionCancelled = true;
        list < csord__Subscription__c > relatedSubscriptions = new list < csord__Subscription__c >();
        list < ContractJunction__c > allRelatedContract = new list < ContractJunction__c >();
        list < ContractJunction__c > parentContract = new list < ContractJunction__c > (); 
        /*    list < ContractJunction__c > parentContract = [SELECT Id, Name, Related_Contract__c FROM ContractJunction__c WHERE Id =: subscription.ContractJunction__r.Related_Contract__c AND Related_Contract__c = NULL]; */
        try{
            list <ContractJunction__c> currentContract = [SELECT Id, Name, Related_Contract__c FROM ContractJunction__c WHERE Id =: subscription.ContractJunction__c Limit 1]; 
            
            if(currentContract.size()> 0){
                if(currentContract[0].Related_Contract__c == NULL){
                    /* Subscription Cancellation done on Parent Contract */
                    parentContract = [SELECT Id, Name, Related_Contract__c,isAgreementGenerated__c, Agreement_Number__c  FROM ContractJunction__c WHERE Id =: currentContract[0].Id]; 
                }
                else{
                    /* Subscription Cancellation done on one of the child Contract */
                    parentContract = [SELECT Id, Name, Related_Contract__c,isAgreementGenerated__c, Agreement_Number__c  FROM ContractJunction__c WHERE Id =: currentContract[0].Related_Contract__c]; 
                    
                }
            }
            
            if (parentContract.size() > 0) {
                /*  Fetching all child contracts related to parent Contract  */
                allRelatedContract = [SELECT Id, Name FROM ContractJunction__c WHERE Related_Contract__c IN: parentContract AND Related_Contract__c != NULL];
            }
            if (allRelatedContract.size() > 0) {
                /*  Fetching all subscriptions(Parent and Child Contract) together in an array related to all the child contract  */
                relatedSubscriptions = [SELECT Id, csord__Status__c, csordtelcoa__Replaced_Subscription__c, toBeCancelled__c FROM csord__Subscription__c WHERE(ContractJunction__c IN: allRelatedContract OR ContractJunction__c IN: parentContract) AND ContractJunction__c != NULL];            
            }
            else{
                /*  Fetching all subscriptions(Parent) together in an array related to parent only  */    
                relatedSubscriptions = [SELECT Id, csord__Status__c, csordtelcoa__Replaced_Subscription__c, toBeCancelled__c FROM csord__Subscription__c WHERE  ContractJunction__c IN: parentContract AND ContractJunction__c != NULL];
            }
            
            if (relatedSubscriptions.size() > 0) {
                for (csord__Subscription__c forEachSub: relatedSubscriptions) {
                    /*  Using counter i to check if all subscriptions have been canceled on or not related to parent as well as child contract  */
                    if (forEachSub.csord__Status__c != 'Closed Replaced' && forEachSub.toBeCancelled__c != 'true') {
                        isAllSubscriptionCancelled = false;
                        break;
                    }
                }
            }
            system.debug('ValueofisAllSubscriptionCancelled'+isAllSubscriptionCancelled+'relatedSubscriptions'+relatedSubscriptions.size());
            /* Checking If all the subscription are Cancelled or Not */
            if (isAllSubscriptionCancelled && relatedSubscriptions.size() > 0) {
                ContractJunction__c cjParentContract = new ContractJunction__c();
                cjParentContract.Id = parentContract[0].Id;
                cjParentContract.Status__c = 'Cancelled';
                UPDATE cjParentContract;
                /* 
                User Story  : EDGE-66499
                Description : Calling Function to Terminate the Calms agreement related to Contract - When parent contract is cancelled
                */               
                processAgreementCancellation(subscription, parentContract);
            }
        }
        catch(exception e){
            
        }
        
        return isAllSubscriptionCancelled;
    }
        /* 
    		User Story  : EDGE-66499
    		Description : Function to Terminate the Calms agreement related to Contract - When parent contract is cancelled
    	*/
    public static void processAgreementCancellation(csord__Subscription__c subscription, list<contractJunction__c> parentContract) {

        list<Apttus__APTS_Agreement__c> agreementRecordParent = new list<Apttus__APTS_Agreement__c>();
        if(parentContract.size()> 0){
            system.debug('subscriptionvalue'+subscription+parentContract);
            if(parentContract[0].isAgreementGenerated__c == true && parentContract[0].Agreement_Number__c != ''){
                
                /* Fetching all the child contract related to the parent */
                list<ContractJunction__c> getAllChildContract = [SELECT Id, Name FROM ContractJunction__c WHERE Related_Contract__c IN: parentContract AND Related_Contract__c != NULL];
                 /* Fetching related agreements for the contracts */
                list<Apttus__APTS_Agreement__c> agreementRecord = [SELECT ID, Name,Apttus__Status__c,Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c WHERE (Related_Contract__c IN : parentContract OR Related_Contract__c IN :getAllChildContract)];
                for(Apttus__APTS_Agreement__c agmt : agreementRecord){
                    if(agmt.Name.contains('BSA')){
                        Apttus__APTS_Agreement__c updateAgmt = new Apttus__APTS_Agreement__c();   
                        updateAgmt.Id = agmt.Id;
                        updateAgmt.Apttus__Status__c = 'Terminated';
                        updateAgmt.Apttus__Status_Category__c = 'Terminated';
                        agreementRecordParent.add(updateAgmt);
                    }
                }
                UPDATE agreementRecordParent;
            }  
        }
    }
    
}