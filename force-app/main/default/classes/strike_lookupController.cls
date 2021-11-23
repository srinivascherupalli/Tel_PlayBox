public with sharing class strike_lookupController {
	
	private static string objectVar = 'object';
	private static String searchFieldVar = 'searchField';
	private static String searchTermVar = 'searchTerm';
	private static String IdVar = 'Id';
	private static String filterVar = 'filter';
	private static String subtitleFieldVar = 'subtitleField';
	private strike_lookupController(){
		
	}
    @AuraEnabled
    public static String getRecentRecords(String jsonString) {
        strike_responseData responseData = new strike_responseData();

        try {
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<Id, RecentlyViewed> recentlyViewedMap = new Map<Id, RecentlyViewed>([SELECT Id
                                                                                     FROM RecentlyViewed
                                                                                     WHERE Type = :((String)jsonMap.get(objectVar))]);
            List<Id> idList = new List<Id>(recentlyViewedMap.keySet());

            if (idList.isEmpty()) {
            	responseData.results = new Map<String, Object>{
                    'data' => new List<String>(),
                    searchTermVar => ''
                };
            } else {
            	String filter = 'Id IN (\'' + String.join(idList, '\',\'') + '\')';

                if (strike_lookupController.fieldNotEmpty(jsonMap, filterVar)) {
                    filter += ' AND (' + jsonMap.get(filterVar) + ')';
                }

                jsonMap.put(filterVar, filter);

                responseData.results = strike_lookupController.getData(jsonMap);
                
            }
        } catch (Exception e) {
            responseData.addError(e.getMessage());
        }

        return responseData.getJsonString();
    }

    @AuraEnabled
    public static String getRecordLabel(String jsonString) {
        strike_responseData responseData = new strike_responseData();

        try {
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

            String obj = (String)jsonMap.get(objectVar);
            String objectLabel = Schema.describeSObjects(new List<String>{obj})[0].getLabel();

            responseData.results.put('objectLabel', objectLabel);
        } catch (Exception e) {
            responseData.addError(e.getMessage());
        }

        return responseData.getJsonString();
    }

    @AuraEnabled
    public static String getRecords(String jsonString) {
        strike_responseData responseData = new strike_responseData();
		
        
        try {
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            responseData.results = strike_lookupController.getData(jsonMap);
        } catch (Exception e) {
            responseData.addError(e.getMessage());
        }
            system.debug('responseData ' + responseData.getJsonString());
        return responseData.getJsonString();
    }

    private static Map<String, Object> getData(Map<String, Object> jsonMap) {
        List<Map<String, Object>> data = new List<Map<String, Object>>();

        String objType = String.escapeSingleQuotes((String)jsonMap.get(objectVar));
        String query = strike_lookupController.getQuery(jsonMap).replaceAll('\'','\\\'');
        String searchField = String.escapeSingleQuotes((String)jsonMap.get(searchFieldVar));
        String searchTerm = '';
        String subtitleField = '';

        if (strike_lookupController.fieldNotEmpty(jsonMap, subtitleFieldVar)) {
            subtitleField = String.escapeSingleQuotes((String)jsonMap.get(subtitleFieldVar));
        }

        if (strike_lookupController.fieldNotEmpty(jsonMap, searchTermVar)) {
            searchTerm = String.escapeSingleQuotes((String)jsonMap.get(searchTermVar));
        }

        if (String.isEmpty(subtitleField)) {
            for (sObject obj : Database.query(query)) {
                data.add(new Map<String, Object>{
                    'label' => strike_lookupController.getValue(obj, objType, searchField),
                    'value' => obj.get(IdVar)
                });
            }
        } else {
            for (sObject obj : Database.query(query)) {
                data.add(new Map<String, Object>{
                    'label' => strike_lookupController.getValue(obj, objType, searchField),
                    'sublabel' => strike_lookupController.getValue(obj, objType, subtitleField),
                    'value' => obj.get(IdVar)
                });
            }
        }

        return new Map<String, Object>{
                   'data' => data,
                   searchTermVar => searchTerm
        };
    }

    private static String getQuery(Map<String, Object> jsonMap) {
        Set<String> queryFields = new Set<String>{IdVar};
        List<String> filters = new List<String>();
        List<String> orders = new List<String>();

        String query;
        String obj = String.escapeSingleQuotes((String)jsonMap.get(objectVar));
        String subtitleField;

        if (strike_lookupController.fieldNotEmpty(jsonMap, subtitleFieldVar)) {
            subtitleField = String.escapeSingleQuotes((String)jsonMap.get(subtitleFieldVar));
            queryFields.add(subtitleField);
        }

        if (strike_lookupController.fieldNotEmpty(jsonMap, searchFieldVar)) {
            queryFields.add(String.escapeSingleQuotes((String)jsonMap.get(searchFieldVar)));

            if (strike_lookupController.fieldNotEmpty(jsonMap, searchTermVar)) {
                String searchField = String.escapeSingleQuotes((String)jsonMap.get(searchFieldVar));
                String searchTerm = String.escapeSingleQuotes((String)jsonMap.get(searchTermVar));

                filters.add(searchField + ' LIKE \'%' + searchTerm + '%\'');
            }
        }

        if (strike_lookupController.fieldNotEmpty(jsonMap, filterVar)) {
            filters.add('(' + (String)jsonMap.get(filterVar) + ')');
        }

        if (strike_lookupController.fieldNotEmpty(jsonMap, 'order')) {
            orders.add(String.escapeSingleQuotes((String)jsonMap.get('order')));
        }

        query = 'SELECT ' + String.join(new List<String>(queryFields), ', ');
        query += ' FROM ' + obj;

        if (!(filters.isEmpty())) {
            query += ' WHERE ' + String.join(filters, ' AND ');
        }

        if (!(orders.isEmpty())) {
            query += ' ORDER BY ' + String.join(orders, ', ');
        }

        if (strike_lookupController.fieldNotEmpty(jsonMap, 'limit')) {
            query += ' LIMIT ' + String.escapeSingleQuotes((String)jsonMap.get('limit'));
        }

        return query;
    }

    private static Boolean fieldNotEmpty(Map<String, Object> jsonMap, String field) {
        return jsonMap.containsKey(field) && !String.isEmpty((String)jsonMap.get(field));
    }

    private static String getValue(SObject obj, String objectType, String field) {
        List<String> fieldPath = field.split('[.]');
        Object label = strike_utilities.convertObjectToMap(obj);
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();

        for (String fieldName : fieldPath) {
            fieldName = fieldName.replaceAll('__r$', '__c');

            label = ((Map<String, Object>)label).get(fieldName);

            if (label == null) {
                return '';
            }

            if (fieldMap.containsKey(fieldName + IdVar)) {
                fieldName = fieldName + IdVar;
            }

            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            String fieldType = String.valueOf(fieldDescribe.getType()).toUpperCase();

            if (fieldType == 'REFERENCE') {
                fieldMap = Schema.getGlobalDescribe().get(String.valueOf(fieldDescribe.getReferenceTo().get(0))).getDescribe().fields.getMap();
            } else if (fieldType == 'ADDRESS') {
                List<String> addressComponents = new List<String>();
                Map<String, Object> addr = (Map<String, Object>)label;

                if (addr.containsKey('street') && addr.get('street') != null) {
                    addressComponents.add((String)addr.get('street'));
                }

                if (addr.containsKey('city') && addr.get('city') != null) {
                    addressComponents.add((String)addr.get('city'));
                }

                if (addr.containsKey('state') && addr.get('state') != null) {
                    addressComponents.add((String)addr.get('state'));
                }

                if (addr.containsKey('country') && addr.get('country') != null) {
                    addressComponents.add((String)addr.get('country'));
                }

                if (addr.containsKey('postalCode') &&addr.get('postalCode') != null) {
                    addressComponents.add((String)addr.get('postalCode'));
                }

                // change later for user formatting?
                label = String.join(addressComponents, ', ');
            }
        }

        return String.valueOf(label);
    }
}