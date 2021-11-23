public with sharing class CS_SolutionManagementObserver {
    /**
     * Links subscriptions with solution if present. This will be called from
     * O&S close won observer.
     *
     * @param subscriptionIds
     */
    public static void linkSubscriptions(List<Id> subscriptionIds) {
        Map<String, SObjectType> globalSchema = Schema.getGlobalDescribe();
        Map<Id, Id> solutionAccountMap = new Map<Id, Id>();
        if (subscriptionIds != null && !subscriptionIds.isEmpty()) {
            String serviceQuery = 'select id, cssdm__solution_association__c, csord__subscription__c, name, csord__subscription__r.csord__account__c, ';
            if (globalSchema.get('csordtelcoa__Orders_Subscriptions_Options__c') != null) {
                serviceQuery += 'csordtelcoa__product_configuration__r.cssdm__solution_association__c, csordtelcoa__product_configuration__r.cscfga__product_definition__r.name, ';
                serviceQuery += 'csordtelcoa__product_configuration__c ';
            } /*else if (globalSchema.get('csordmedia__Orders_Subscriptions_Options__c') != null) {
                serviceQuery += 'csordmedia__product_configuration__r.cssdm__solution_association__c, csordmedia__product_configuration__r.cscfga__product_definition__r.name, ';
                serviceQuery += 'csordmedia__product_configuration__c ';
            }*/
            serviceQuery += 'from csord__Service__c where csord__subscription__c in :subscriptionIds';
            List<csord__Service__c> services = (List<csord__Service__c>) Database.query(serviceQuery);
            Map<Id, csord__Subscription__c> subscriptionsToUpdate = new Map<Id, csord__Subscription__c>();
            Map<Id, csord__Service__c> servicesToUpdate = new Map<Id, csord__Service__c>();
            for (csord__Service__c service : services) {
                csord__Service__c srv = new csord__Service__c(id = service.id);
                csord__Subscription__c sub = new csord__Subscription__c(id = service.csord__subscription__c);
                if (globalSchema.get('csordtelcoa__Orders_Subscriptions_Options__c') != null) {
                    if (service.getSobject('csordtelcoa__product_configuration__r') != null && service.getSobject('csordtelcoa__product_configuration__r').get('cssdm__solution_association__c') != null) {
                        srv.cssdm__solution_association__c = (Id) service.getSobject('csordtelcoa__product_configuration__r').get('cssdm__solution_association__c');
                        sub.cssdm__solution_association__c = (Id) service.getSobject('csordtelcoa__product_configuration__r').get('cssdm__solution_association__c');
                        solutionAccountMap.put(sub.cssdm__solution_association__c, service.csord__subscription__r.csord__account__c);
                    }
                } /*else {
                    if (service.getSobject('csordmedia__product_configuration__r') != null && service.getSobject('csordmedia__product_configuration__r').get('cssdm__solution_association__c') != null) {
                        srv.cssdm__solution_association__c = (Id) service.getSobject('csordmedia__product_configuration__r').get('cssdm__solution_association__c');
                        sub.cssdm__solution_association__c = (Id) service.getSobject('csordmedia__product_configuration__r').get('cssdm__solution_association__c');
                        solutionAccountMap.put(sub.cssdm__solution_association__c, service.csord__subscription__r.csord__account__c);
                    }
                }*/
                servicesToUpdate.put(service.id, srv);
                subscriptionsToUpdate.put(service.csord__subscription__c, sub);
            }
            system.debug(subscriptionsToUpdate);
            if (!subscriptionsToUpdate.isEmpty()) {
                update subscriptionsToUpdate.values();
            }
            system.debug(servicesToUpdate);
            if (!servicesToUpdate.isEmpty()) {
                update servicesToUpdate.values();
            }
            system.debug(solutionAccountMap);
            if (!solutionAccountMap.isEmpty()) {
                linkSubsToAccount(solutionAccountMap);
                updateSubscriptionReferencesToMACSolutions(solutionAccountMap.keySet(), globalSchema);
            }
        }
    }

    public static void updateSubscriptionReferencesToMACSolutions(Set<Id> solutionIds, Map<String, SObjectType> globalSchema) {
        List<csord__Solution__c> sols = [
            select id, cssdm__replaced_solution__c, csord__status__c
            from csord__Solution__c
            where id in :solutionIds
            and cssdm__replaced_solution__c != null
        ];
        if (!sols.isEmpty()) {
            Map<Id, Id> replacedSolutionMap = new Map<Id, Id>();
            Set<Id> replacedSolutions = new Set<Id>();
            for (csord__Solution__c solution : sols) {
                replacedSolutionMap.put(solution.cssdm__replaced_solution__c, solution.id);
                replacedSolutions.add(solution.cssdm__replaced_solution__c);
            }
            system.debug('replacedSolutions===='+replacedSolutions);
            String serviceQuery = 'select id, cssdm__solution_association__c, csord__subscription__c, ';
            if (globalSchema.get('csordtelcoa__Orders_Subscriptions_Options__c') != null) {
                serviceQuery += 'csordtelcoa__product_configuration__c ';
                serviceQuery += 'from csord__Service__c where cssdm__solution_association__c in :replacedSolutions';
                serviceQuery += ' and csord__Subscription__r.csordtelcoa__Replacement_Subscription__c = null';
            } /*else if (globalSchema.get('csordmedia__Orders_Subscriptions_Options__c') != null) {
                serviceQuery += 'csordmedia__product_configuration__r.cssdm__solution_association__c, csordmedia__product_configuration__c ';
                serviceQuery += 'from csord__Service__c where cssdm__solution_association__c in :replacedSolutions';
                serviceQuery += ' and csord__Subscription__r.csordmedia__Replacement_Subscription__c = null';
            }*/
            List<csord__Service__c> services = (List<csord__Service__c>) Database.query(serviceQuery);
            if (!services.isEmpty()) {
                Map<Id, csord__Subscription__c> subsToUpdate = new Map<Id, csord__Subscription__c>();
                List<cscfga__Product_Configuration__c> pcsToUpdate = new List<cscfga__Product_Configuration__c>();
                for (csord__Service__c service : services) {
                    if (globalSchema.get('csordtelcoa__Orders_Subscriptions_Options__c') != null) {
                        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
                            id = (Id) service.get('csordtelcoa__product_configuration__c'),
                            cssdm__solution_association__c = replacedSolutionMap.get(service.cssdm__solution_association__c)
                        );
                        pcsToUpdate.add(pc);
                    } else {
                        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
                            id = (Id) service.get('csordmedia__product_configuration__c'),
                            cssdm__solution_association__c = replacedSolutionMap.get(service.cssdm__solution_association__c)
                        );
                        pcsToUpdate.add(pc);
                    }
                    csord__Subscription__c sub = new csord__Subscription__c(
                        id = service.csord__Subscription__c,
                        cssdm__solution_association__c = replacedSolutionMap.get(service.cssdm__solution_association__c)
                    );
                    subsToUpdate.put(sub.id, sub);
                    service.cssdm__solution_association__c = replacedSolutionMap.get(service.cssdm__solution_association__c);
                }
                update services;
                update pcsToUpdate;
                update subsToUpdate.values();
            }
        }
    }

    private static void linkSubsToAccount(Map<Id, Id> solutionAccountMap) {
        List<csord__Solution__c> solutionsToUpdate = new List<csord__Solution__c>();
        for (Id solId : solutionAccountMap.keySet()) {
            solutionsToUpdate.add(new csord__Solution__c(
                id = solId,
                csord__Account__c = solutionAccountMap.get(solId)
            ));
        }
        if (!solutionsToUpdate.isEmpty()) {
            update solutionsToUpdate;
        }
    }
}