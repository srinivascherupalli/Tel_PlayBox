/**
 * Created by tihomir.baljak on 9/19/2019.
 * Updates parent subscription RTS trigger when all child subscriptions are canceled but only if parent subscription have toBeCancelled__c = true
 */

global with sharing class UpdateParentTriggerRtsHandler implements CSPOFA.ExecutionHandler {

    public List<sObject> process(List<sObject> data) {
        List<sObject> result = new List<sObject>();
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>) data;
        List<Id> subsIds = new List<Id>();
        List<Id> parentSubsIds = new List<Id>();
        List<Id> parentSolutionIds = new List<Id>();
        List<Id> mainProductDefinitionsIds = new List<Id>();
        List<Id> orchesIds = new List<Id>();
        List<Id> pdIds = new List<Id>();
        List<csord__Subscription__c> subscriptionsToUpdate = new List<csord__Subscription__c>();

        for(CSPOFA__Orchestration_Step__c step: stepList){
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }

        system.debug('orchesIds: ' + orchesIds);
        //first get all subscription ids from orchestration steps
        List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
        for(CSPOFA__Orchestration_Process__c  orch : orchList){
            subsIds.add(orch.csordtelcoa__Subscription__c);
        }
        system.debug('subsIds: ' + subsIds);
        //get subscription data like associated solution so we can find parent subscriptions for every solution
        List<csord__Subscription__c> subsRecord=[Select id,  cssdm__solution_association__c from csord__Subscription__c where Id IN: subsIds];
        for(csord__Subscription__c sr: subsRecord){
            if (sr.cssdm__solution_association__c != null) {
                if (!parentSolutionIds.contains(sr.cssdm__solution_association__c))
                    parentSolutionIds.add(sr.cssdm__solution_association__c);
            }
        }
        system.debug('parentSolutionIds: ' + parentSolutionIds);
        //now we need to find all subscriptions for every solution
        subsRecord=[Select id, cssdm__solution_association__c , csordtelcoa__Product_Configuration__c, Trigger_RTS__c, toBeCancelled__c from csord__Subscription__c where cssdm__solution_association__c IN: parentSolutionIds];

        for(csord__Subscription__c sr: subsRecord) {
            if (!pdIds.contains(sr.csordtelcoa__Product_Configuration__c)) {
                pdIds.add(sr.csordtelcoa__Product_Configuration__c);
            }
        }

        system.debug('pdIds: ' + pdIds);

        //to find main subscription we need to look at isMainComponent attribute of PC conencted to this subscription
        List <cscfga__Attribute__c> attributes = [SELECT cscfga__Product_Configuration__c, cscfga__Value__c FROM cscfga__Attribute__c WHERE Name = 'isMainComponent'  AND cscfga__Product_Configuration__c in :pdIds];

        for(cscfga__Attribute__c att: attributes) {
            if (att.cscfga__Value__c != 'Yes')
                continue;
            if (!mainProductDefinitionsIds.contains(att.cscfga__Product_Configuration__c))
                mainProductDefinitionsIds.add(att.cscfga__Product_Configuration__c);
        }

        system.debug('mainProductDefinitionsIds: ' + mainProductDefinitionsIds);

        //lets filter all subscriptions to find main one to be updated
        List<csord__Subscription__c> parentSubscriptions = new List<csord__Subscription__c>();
        for(csord__Subscription__c sr: subsRecord) {
            if (sr.toBeCancelled__c == 'true' && mainProductDefinitionsIds.contains(sr.csordtelcoa__Product_Configuration__c)) {
                parentSubscriptions.add(sr);
            }
        }

        system.debug('parentSubscriptions: ' + parentSubscriptions);
        //check to see if all child subscription for parent subscriptions are completed
        Map<Id, Boolean> statuses = new Map<Id, Boolean>();
        for (csord__Subscription__c parentSub: parentSubscriptions) {
            for (csord__Subscription__c sr : subsRecord) {
                if (parentSubscriptions.contains(sr))
                    continue;

                if (sr.cssdm__solution_association__c == parentSub.cssdm__solution_association__c) {
                    if (statuses.containsKey(parentSub.id)) {
                        statuses.put(parentSub.id, sr.Trigger_RTS__c);
                    } else {
                        if (sr.Trigger_RTS__c == false)
                        statuses.remove(parentSub.id);
                        statuses.put(parentSub.id, false);
                    }
                }
            }
        }

        system.debug('statuses: ' + statuses);

        for (Id key : statuses.keySet()) {
            if (statuses.get(key) == true){
                csord__Subscription__c s = new  csord__Subscription__c();
                s.id = key;
                s.Trigger_RTS__c = true;
                subscriptionsToUpdate.add(s);
            }
        }

        system.debug('subscriptionsToUpdate: ' + subscriptionsToUpdate);

        if (subscriptionsToUpdate.size() > 0) {
            update subscriptionsToUpdate;
        }

        for (CSPOFA__Orchestration_Step__c step : stepList) {

            //mark step Status, Completed Date, and write optional step Message
            step.CSPOFA__Status__c =  Constants.orchestrationProcessComplete;
            step.CSPOFA__Completed_Date__c = Date.today();
            step.CSPOFA__Message__c = 'UpdateParentTriggerRts succeeded';
            result.add(step);
        }
        //do post processing tasks, for example bulk update/insert operations
        return result;
    }
}