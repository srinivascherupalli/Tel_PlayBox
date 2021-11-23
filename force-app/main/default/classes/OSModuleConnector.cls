public class OSModuleConnector implements OSLogic {
    @TestVisible
    private static Type apiClass;
    private static String extension = 'csordtelcoa';

    public static List<cscfga__Product_Configuration__c> getPCList(List<Id> macdBasketList) {
        String pcQuery = 'select id, cscfga__Product_Basket__c, '
                + ' cscfga__Parent_Configuration__c, cscfga__product_definition__c, '
                + ' cssdm__solution_association__r.cssdm__solution_definition__r.cssdm__product_definition__c, '
                + ' cssdm__solution_association__r.cssdm__replaced_solution__r.cssdm__solution_definition__r.cssdm__product_definition__c, '
                + ' cssdm__solution_association__r.cssdm__replaced_solution__c, '
                + ' (select Id,name, '
                + ' cscfga__Value__c '
                + ' from cscfga__Attributes__r '
                + ' where name = \'GUID\'), '
                + extension + '__cancelled_by_change_process__c, '
                + extension + '__Replaced_Subscription__c, '
                + extension + '__Ignore_For_Order_Decomposition__c '
            + ' from cscfga__Product_Configuration__c '
            + ' where cscfga__Product_Basket__c in :macdBasketList '
            + ' order by cscfga__package_guid__c ';

        return (List<cscfga__Product_Configuration__c>) Database.query(pcQuery);
    }

    public static List<csord__Subscription__c> getSubList(
        List<cscfga__Product_Configuration__c> pcList,
        List<String> orignalReplacedSubList
    ) {
        String subQuery = ' select id, name, '
                + extension +'__cancelled_by_change_process__c, '
                + extension +'__Product_Configuration__c, '
                + extension + '__Product_Configuration__r.'+ extension +'__Replaced_Subscription__c '
            + ' from csord__Subscription__c '
            + ' where ' + extension + '__Product_Configuration__c in :pcList '
            + ' or id in :orignalReplacedSubList';
        List<csord__Subscription__c> subList = (List<csord__Subscription__c>) Database.query(subQuery);

        return subList;
    }

    public static Map<String, Map<String, csord__Subscription__c>> getSubscriptionMap (
        List<csord__Subscription__c> subList,
        Map<Id, String> guidMap
    ) {
        Map<String, csord__Subscription__c> oldSubMap = new Map<String, csord__Subscription__c>();
        Map<String, csord__Subscription__c> newSubMap = new Map<String, csord__Subscription__c>();

        for (csord__Subscription__c sub : subList) {
            Boolean isCancelledByChangeProcess = (Boolean)sub.get(
                extension + '__Cancelled_By_Change_Process__c'
            );
            String guidAttrValue = (String)sub.get(extension + '__Product_Configuration__c');
            if (
                !isCancelledByChangeProcess &&
                (String)sub.getSObject(extension + '__Product_Configuration__r').get(
                    extension +'__Replaced_Subscription__c'
                ) != null
            ) {
                oldSubMap.put(guidMap.get(guidAttrValue), sub);
            }
            else if (isCancelledByChangeProcess) {
                oldSubMap.put(guidMap.get(guidAttrValue), sub);
            }
            else if (guidMap.get(guidAttrValue) != null) {
                    newSubMap.put(guidMap.get(guidAttrValue), sub);
                }
        }

        return new Map<String, Map<String, csord__Subscription__c>> {
            'fetchNewMap' => newSubMap,
            'fetchOldMap' => oldSubMap
        };
    }

    public static List<csord__Subscription__c> getSubscriptionsList(List<String> selectedSubList) {
        String subQuery = 'select id, '
            + extension + '__product_configuration__c '
            + 'from csord__Subscription__c '
            + 'where id in :selectedSubList';
        List<csord__Subscription__c> subList = (List<csord__Subscription__c>) Database.query(subQuery);

        return subList;
    }

    public static List<cscfga__Product_Basket__c> getBaskets(List<Id> macdBasketIds) {
        String basketQuery = 'select id, name, cscfga__Opportunity__c, '
            + ' cscfga__Opportunity__r.StageName, '
            + extension + '__Basket_Stage__c '
            + ' from cscfga__Product_Basket__c '
            + ' where id in: macdBasketIds ';
        List<cscfga__Product_Basket__c> basketList = (List<cscfga__Product_Basket__c>) Database.query(basketQuery);

        return basketList;
    }

    public static List<cscfga__Attribute__c> getAttributeList(List<Id> pcList) {
        List<cscfga__Attribute__c> sourceGUIDAttributeList = [
            select id, name, cscfga__Value__c
            from cscfga__Attribute__c
            where name = 'GUID'
            and cscfga__Product_Configuration__c in :pcList
        ];

        return sourceGUIDAttributeList;
    }

    public static Boolean checkSourceValid(
        List<cscfga__Product_Configuration__c> configList,
        List<Id> subIdList
    ) {
        Boolean isSourceValid = true;
        system.debug('configList$$$$ '+configList);
        system.debug('sublist$$$ '+subIdList);
        for (cscfga__Product_Configuration__c pc : configList) {
            system.debug('pc configList$$$$ '+pc);
            String mainProduct;
            if(pc.cssdm__solution_association__r.cssdm__replaced_solution__c != null)
                mainProduct = pc.cssdm__solution_association__r.cssdm__replaced_solution__r.cssdm__solution_definition__r.cssdm__product_definition__c;
            else
                mainProduct = pc.cssdm__solution_association__r.cssdm__solution_definition__r.cssdm__product_definition__c;
            system.debug('pc mainProduct$$$$ '+mainProduct);
            if (pc.get(extension + '__Replaced_Subscription__c') != null &&
                pc.cscfga__Parent_Configuration__c == null &&
                pc.cscfga__product_definition__c != mainProduct
            ) {
                if (!subIdList.contains((Id) pc.get(extension + '__Replaced_Subscription__c'))) {
                    system.debug('inside this condition');
                    isSourceValid = false;
                }
            }
        }

        return isSourceValid;
    }

    public static List<String> getTargetGUIDList(List<cscfga__Product_Configuration__c> configList) {
        List<String> guidTargetList = new List<String>();
        for (cscfga__Product_Configuration__c pc : configList) {
            if (pc.get(extension + '__Replaced_Subscription__c') == '' &&
                pc.get(extension + '__cancelled_by_change_process__c') == false) {
                    for (cscfga__Attribute__c attRec : pc.cscfga__Attributes__r) {
                        guidTargetList.add(attRec.cscfga__Value__c);
                    }
                }
        }

        return guidTargetList;
    }

    public static Map<String, Object> createEmptyMacBasketRecord(
        Map<String, Object> args,
        Map<String, Object> basketMap
    ) {
        String className = extension + '.API_V1';
        apiClass = Type.forName(className);

        Map<String, Object> bsktSolutionMap = new Map<String, Object>();
        for (String str : basketMap.keySet()) {
            Callable api = (Callable) apiClass.newInstance();
            Id basketId = (Id) api.call('createEmptyMacBasket', args);
            bsktSolutionMap.put(basketId, basketMap.get(str));
        }

        return bsktSolutionMap;
    }

    public static Map<String, Object> createEmptyMacOppRecord(
        Map<String, Object> args,
        Map<String, Object> basketMap
    ) {
        String className = extension + '.API_V1';
        apiClass = Type.forName(className);
        Map<String, Object> oppSolMap = new Map<String, Object>();
        for (String str : basketMap.keySet()) {
            Callable api = (Callable) apiClass.newInstance();
            Id oppId = (Id) api.call('createEmptyMacOpportunity', args);
            oppSolMap.put(oppId, basketMap.get(str));
        }

        return oppSolMap;
    }

    public static List<cscfga__Product_Basket__c> updateBasketAccount(
        List<cscfga__Product_Basket__c> basketList,
        Migration_Change_Request__c mcrInstance,
        Map<String, Object> basketCreationResponseMap
    ) {
        for (cscfga__Product_Basket__c bsk : basketList) {
            bsk.put((extension + '__Account__c'), mcrInstance.account_id__c);
            if (basketCreationResponseMap.containsKey(bsk.Id)) {
                List<Id> solIds = (List<Id>) basketCreationResponseMap.get(bsk.Id);
                if (
                    mcrInstance.account_id__c != mcrInstance.target_account__c &&
                    (
                        solIds.contains(mcrInstance.target_solution_id__c) ||
                        solIds.contains(mcrInstance.solution_definition__c)
                    )
                ) {
                    bsk.put((extension + '__Account__c'), mcrInstance.target_account__c);
                }
            }
        }

        return basketList;
    }

    public static List<Id> getPCIds(List<csord__Subscription__c> subList) {
        List<Id> pcIds = new List<Id>();
        for (csord__Subscription__c sub : subList) {
            pcIds.add((Id) sub.get(extension + '__product_configuration__c'));
        }

        return pcIds;
    }

    public static List<csord__Service__c> getServiceList(List<Id> subscriptionList) {
        String query = ' select id, name, csord__subscription__c, '
            + extension + '__product_configuration__c '
            + ' from csord__Service__c '
            + ' where csord__subscription__c in :subscriptionList';

        return (List<csord__Service__c>) Database.query(query);
    }

    public static List<Id> getServicePCIds(List<csord__Service__c> serviceList) {
        List<Id> pcIds = new List<Id>();
        for (csord__Service__c service : serviceList) {
            pcIds.add((Id) service.get(extension + '__product_configuration__c'));
        }

        return pcIds;
    }

}