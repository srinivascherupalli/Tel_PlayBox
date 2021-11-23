public class CSVReader {
    public static List<Event_log__c> readURIlog(List<String> file)
    {
        List<Event_log__c> lstElog = New list<Event_log__c>();
        //Map to store User-profile
        Map<Id, User> mapUserProfile = Util_PLR.getuserProfilemap();
        Map<string, String> mapObjPrefix = Util_PLR.getObjPrefixmap();
                
        if(file != null && file.size() > 0) {
            Map<String, Integer> headerIndexMap = populateHeaderIndexMap(file[0]);
            
            for(Integer i = 1; i < file.size(); i++) {
                String csvRow = file[i];
                String row = csvRow;
                System.debug('Row: ' + row);
                List<String> tempColumns = new List<String>(row.split('\",\"'));
                List<String> columns = new List<String>();
                for(String col : tempColumns) {
                    columns.add(col.replace('"',''));
                }
                System.debug('Columns: ' + columns);
                if(headerIndexMap.containsKey('URI_ID_DERIVED')) {
                    String derivedEntity = columns.get(headerIndexMap.get('URI_ID_DERIVED'));
                    System.debug('Derived Entity: ' + derivedEntity);
                    System.debug('Entity Prefix: ' + derivedEntity.mid(0,3));

                    if(mapObjPrefix.containsKey(derivedEntity.mid(0,3))) {
                        Event_log__c Elog = New Event_log__c();
                        Elog.EVENT_TYPE__c = columns.get(headerIndexMap.get('EVENT_TYPE'));
                        Elog.REQUEST_ID__c = columns.get(headerIndexMap.get('REQUEST_ID'));
                        Elog.ORGANIZATION_ID__c = columns.get(headerIndexMap.get('ORGANIZATION_ID'));
                        Elog.USER_ID__c = columns.get(headerIndexMap.get('USER_ID'));
                        Elog.RUN_TIME__c = Integer.valueof(columns.get(headerIndexMap.get('RUN_TIME')));
                        Elog.CLIENT_IP__c = columns.get(headerIndexMap.get('CLIENT_IP'));
                        Elog.URI__c = columns.get(headerIndexMap.get('URI'));
                        Elog.REQUEST_STATUS__c = columns.get(headerIndexMap.get('REQUEST_STATUS'));
                        Elog.REFERRER_URI__c = columns.get(headerIndexMap.get('REFERRER_URI'));
                        Elog.TIMESTAMP_DERIVED__c =  Util_PLR.getGmtTime(columns.get(headerIndexMap.get('TIMESTAMP_DERIVED')));
                        Elog.USER_ID_DERIVED__c = columns.get(headerIndexMap.get('USER_ID_DERIVED'));
                        Elog.PROFILE_NAME__c = mapUserProfile.get(columns.get(headerIndexMap.get('USER_ID_DERIVED'))).Profile.Name;
                        Elog.URI_ID_DERIVED__c = columns.get(headerIndexMap.get('URI_ID_DERIVED'));
                        Elog.Object_Name__c = mapObjPrefix.get(columns.get(headerIndexMap.get('URI_ID_DERIVED')).mid(0,3));
                        if ((Elog.URI__c).substringAfterLast('/') == 'm')
                        {
                            Elog.READ_EVENT__c = 'Mini Layout';
                        }
                        else if ((Elog.URI__c).substringAfterLast('/') == 'e')
                        {
                            Elog.READ_EVENT__c = 'Edit';
                        }
                        else
                        {
                            Elog.READ_EVENT__c = 'Detail';
                        }
                        lstElog.add(Elog);
                    }   
                }
            }
        }
        System.debug('LstElog: ' + lstElog);
        return lstElog;
    }

    public static List<Event_log__c> readVFlog(List<String> file)
    {
        List<Event_log__c> lstElog = New list<Event_log__c>();
        //Map to store User-profile
        Map<Id,User> mapUserProfile = Util_PLR.getuserProfilemap();
        Map<string,String> mapObjPrefix = Util_PLR.getObjPrefixmap();
        System.debug('mapObjPrefix=='+mapObjPrefix);
        
        if(file != null && file.size() > 0) {
            Map<String, Integer> headerIndexMap = populateHeaderIndexMap(file[0]);
            
            for(Integer i = 1; i < file.size(); i++) {
                String csvRow = file[i];
                String row = csvRow;
                System.debug('Row: ' + row);
                List<String> tempColumns = new List<String>(row.split('\",\"'));
                List<String> columns = new List<String>();
                for(String col : tempColumns) {
                    columns.add(col.replace('"',''));
                }
                System.debug('Columns: ' + columns);
                if(headerIndexMap.containsKey('QUERY')) {
                    String query = columns.get(headerIndexMap.get('QUERY'));
                    String derivedEntity = query.mid(query.indexof('id=')+3,15);
                    System.debug('Derived Entity: ' + derivedEntity);
                    System.debug('Entity Prefix: ' + derivedEntity.mid(0,3));
                    
                    if(mapObjPrefix.containsKey(derivedEntity.mid(0,3))) {                  
                        Event_log__c Elog = New Event_log__c();
                        Elog.EVENT_TYPE__c = columns.get(headerIndexMap.get('EVENT_TYPE'));
                        Elog.REQUEST_ID__c = columns.get(headerIndexMap.get('REQUEST_ID'));
                        Elog.ORGANIZATION_ID__c = columns.get(headerIndexMap.get('ORGANIZATION_ID'));
                        Elog.USER_ID__c = columns.get(headerIndexMap.get('USER_ID'));
                        Elog.RUN_TIME__c = Integer.valueof(columns.get(headerIndexMap.get('RUN_TIME')));
                        Elog.CLIENT_IP__c = columns.get(headerIndexMap.get('CLIENT_IP'));
                        Elog.URI__c = columns.get(headerIndexMap.get('URI'));
                        Elog.REQUEST_STATUS__c = columns.get(headerIndexMap.get('REQUEST_STATUS'));
                        Elog.PAGE_NAME__c = columns.get(headerIndexMap.get('PAGE_NAME')).substringAfterLast('/');
                        Elog.TIMESTAMP_DERIVED__c =  Util_PLR.getGmtTime(columns.get(headerIndexMap.get('TIMESTAMP_DERIVED')));
                        Elog.USER_ID_DERIVED__c = columns.get(headerIndexMap.get('USER_ID_DERIVED'));
                        if(mapUserProfile.get(Elog.USER_ID_DERIVED__c) != null && mapUserProfile.get(Elog.USER_ID_DERIVED__c).Profile != null) {
                            Elog.PROFILE_NAME__c = mapUserProfile.get(Elog.USER_ID_DERIVED__c).Profile.Name;
                        }
                        Elog.URI_ID_DERIVED__c = derivedEntity;
                        Elog.Object_Name__c = mapObjPrefix.get(derivedEntity.mid(0,3));
                        lstElog.add(Elog);
                    }
                }
            }
        }
        return lstElog;
    }

    public static List<Event_log__c> readUIlog(List<String> file)
    {
        List<Event_log__c> lstElog = New list<Event_log__c>();
        //Map to store User-profile
        Map<Id,User> mapUserProfile = Util_PLR.getuserProfilemap();
        Map<string,String> mapObjPrefix = Util_PLR.getObjPrefixmap();
        Set<String> externalkey = New Set<String>();
        
        if(file != null && file.size() > 0) {
            Map<String, Integer> headerIndexMap = populateHeaderIndexMap(file[0]);
            
            for(Integer i = 1; i < file.size(); i++) {
                String csvRow = file[i];
                String row = csvRow;
                System.debug('Row: ' + row);
                List<String> tempColumns = new List<String>(row.split('\",\"'));
                List<String> columns = new List<String>();
                for(String col : tempColumns) {
                    columns.add(col.replace('"','').replace('KHTML,','KHTML;'));
                }
                System.debug('Columns: ' + columns);
                if(headerIndexMap.containsKey('RECORD_ID')) {
                    String derivedEntity = columns.get(headerIndexMap.get('RECORD_ID'));
                    System.debug('Derived Entity: ' + derivedEntity);
                    System.debug('Entity Prefix: ' + derivedEntity.mid(0,3));
                    
                    String location = columns.get(headerIndexMap.get('LOCATION'));
                    String action = columns.get(headerIndexMap.get('ACTION'));
                    if(mapObjPrefix.containsKey(derivedEntity.mid(0,3)) && location == 'one:recordHomeFlexipage' && action == 'PageView' && !externalkey.contains(columns.get(headerIndexMap.get('REQUEST_ID')))) {
                        Event_log__c Elog = New Event_log__c();
                        Elog.EVENT_TYPE__c = columns.get(headerIndexMap.get('EVENT_TYPE'));
                        Elog.REQUEST_ID__c = columns.get(headerIndexMap.get('REQUEST_ID'));
                        Elog.ORGANIZATION_ID__c = columns.get(headerIndexMap.get('ORGANIZATION_ID'));
                        Elog.USER_ID__c = columns.get(headerIndexMap.get('USER_ID'));
                        Elog.CLIENT_IP__c = columns.get(headerIndexMap.get('CLIENT_IP'));
                        Elog.URI__c = columns.get(headerIndexMap.get('REFERRER'));
                        Elog.TIMESTAMP_DERIVED__c =  Util_PLR.getGmtTime(columns.get(headerIndexMap.get('TIMESTAMP_DERIVED')));
                        String usrId = columns.get(headerIndexMap.get('USER_ID_DERIVED'));
                        Elog.USER_ID_DERIVED__c = usrId.trim();
                        Elog.PROFILE_NAME__c = mapUserProfile.get(Elog.USER_ID_DERIVED__c).Profile.Name;
                        Elog.URI_ID_DERIVED__c = columns.get(headerIndexMap.get('RECORD_ID'));
                        Elog.Object_Name__c = columns.get(headerIndexMap.get('OBJECT_TYPE'));
                        Elog.READ_EVENT__c = 'Detail';
                        lstElog.add(Elog);
                        externalkey.add(columns.get(headerIndexMap.get('REQUEST_ID')));
                    }
                }
            }
        }

        return lstElog;
    }

    public static List<Event_log__c> readLightningInteractionLog(List<String> file)
    {
        List<Event_log__c> lstElog = New list<Event_log__c>();
        //Map to store User-profile
        Map<Id, User> mapUserProfile = Util_PLR.getuserProfilemap();
        Map<string, String> mapObjPrefix = Util_PLR.getObjPrefixmap();
        System.debug('Size: ' + file.size());
        if(file != null && file.size() > 0) {
            Map<String, Integer> headerIndexMap = populateHeaderIndexMap(file[0]);
            
            for(Integer i = 1; i < file.size(); i++) {
                String csvRow = file[i];
                String row = csvRow;
                System.debug('Row: ' + row);
                List<String> tempColumns = new List<String>(row.split('\",\"'));
                List<String> columns = new List<String>();
                for(String col : tempColumns) {
                    columns.add(col.replace('"',''));
                }
                System.debug('Columns: ' + columns);

                if(headerIndexMap.containsKey('PAGE_ENTITY_ID')) {
                    String pageEntity = columns.get(headerIndexMap.get('PAGE_ENTITY_ID'));
                    System.debug('PageEntity: ' + pageEntity);
                    System.debug('PageEntity Prefix: ' + pageEntity.mid(0,3));

                    if(mapObjPrefix.containsKey(pageEntity.mid(0,3))) {
                        Event_log__c Elog = New Event_log__c();
                        Elog.EVENT_TYPE__c = Constants_PLR.URI;
                        Elog.REQUEST_ID__c = columns.get(headerIndexMap.get('REQUEST_ID'));
                        Elog.ORGANIZATION_ID__c = columns.get(headerIndexMap.get('ORGANIZATION_ID'));
                        Elog.USER_ID__c = columns.get(headerIndexMap.get('USER_ID'));
                        Elog.CLIENT_IP__c = columns.get(headerIndexMap.get('CLIENT_IP'));
                        Elog.URI__c = '/' + columns.get(headerIndexMap.get('PAGE_ENTITY_ID'));
                        Elog.TIMESTAMP_DERIVED__c =  Util_PLR.getGmtTime(columns.get(headerIndexMap.get('TIMESTAMP_DERIVED')));
                        String usrId = columns.get(headerIndexMap.get('USER_ID_DERIVED'));
                        Elog.USER_ID_DERIVED__c = usrId.trim();
                        Elog.PROFILE_NAME__c = mapUserProfile.get(Elog.USER_ID_DERIVED__c).Profile.Name;
                        Elog.URI_ID_DERIVED__c = columns.get(headerIndexMap.get('PAGE_ENTITY_ID'));
                        Elog.Object_Name__c = mapObjPrefix.get(pageEntity.mid(0,3));
                        Elog.READ_EVENT__c = columns.get(headerIndexMap.get('UI_EVENT_SOURCE'));
                        lstElog.add(Elog);
                    }
                }
            }
        }

        return lstElog;
    }
    
    private static Map<String, Integer> populateHeaderIndexMap(String header) {
        Map<String, Integer> headerIdxMap = new Map<String, Integer>();
        String headerStr = header;
        Integer idx = 0;
        for(String headerToken : headerStr.split(',')) {
            headerIdxMap.put(headerToken.replace('"','').trim(), idx);
            idx++;
        }
        for(String key: headerIdxMap.keySet()) {
            System.debug('Key: ' + key + ', Value: ' + headerIdxMap.get(key));
        }
        
        return headerIdxMap;
    }

}