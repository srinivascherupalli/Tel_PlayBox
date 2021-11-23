/*******************************************************************
Created By          :   Team Hawaii (Paresh)
Created Date        :   23/9/2019
Desc                :   This Class is called from 'PRMCaseDetailComponent' to fetch data from custom metadata types.
Modified Date       :   P2OB-12617(16/2/2021) : Updated class to get dynamic data based on metadata name and object name and get the value of
						field displayed field
03 July 2021    Vivian Charlie    P2OB-15264 Team Hawaii : SOQL Injection Fix
***********************************************************************/
public without sharing class PRMCaseDetail {
	
	Public static final String prmCustomPermission = Label.PRM_Permission_Set_Name;
	
	@AuraEnabled
	public static Boolean checkUserCustomPermission(){
		Boolean hasCustomPermission = FeatureManagement.checkPermission(prmCustomPermission);
        return hasCustomPermission;
    }
    
    //Modified method to accept additional parameters and compare values from metadata and case object using json passed
    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>> getCaseFieldList(String recordId,String objectName,String metaDataName,String objectMetadataJson){
        System.debug('recordId: '+recordId);
        System.debug('objectName: '+objectName);
        System.debug('metaDataName: '+metaDataName);
        System.debug('objectMetadataJson: '+objectMetadataJson);
        //map of master label and list of fields to be displayed
        Map<String,List<String>> stringMap = new Map<String,List<String>>();
        //deserialize json
        List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(objectMetadataJson);
        //List of object fields
        List<String> objectFields = new List<String>();
        
        //Iteration on fieldList
        if(fieldList != null && fieldList.size() > 0){
            for(Object fld : fieldList){    
                Map<String,Object> data = (Map<String,Object>)fld;
                //get api name of object fields
                objectFields.add(String.valueof(data.get('objectField')));
            }
        }
        
        //Store CaseDate
        Sobject objectList;
        if(objectFields.size() > 0){
            //dynamic query based on object name and fields from json
        	String objectQuery = 'Select '+string.join(objectFields,',')+' From '+objectName+' where id=:recordId limit 1';
            System.debug('objectQuery: '+objectQuery);
            objectList = Database.query(String.escapeSingleQuotes(objectQuery)); // SOQL injection fix
        }
        
        //Get Map of Labels and API Names
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
        List<String> fieldApiName = new List<String>();
        if(fieldMap != null && fieldMap.size() > 0){
            //list of api name of fields associated with object
            for(Schema.SObjectField fld: fieldMap.values()){
               fieldApiName.add(fld.getDescribe().getName());
            }
    	}
		
		//Query metadata records        
        String metadataQuery = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL(metaDataName)) + ' \n' +
                          ' FROM '+ metaDataName;
        System.debug('metadataQuery: '+metadataQuery);
        String subQuery = ''; 
		
        Map<String,String> numQueryMap= new Map<String,String>();
        
        List<Sobject> matchMetadataRecord;
        if(objectList != null && fieldList != null && fieldList.size() > 0){
            for(Integer i=0; i < fieldList.size() ;i++){
                Map<String,Object> data = (Map<String,Object>)fieldList[i];
				String num = String.valueof(data.get('Value'));
                //generate condition for filtering metadata record
                String val = String.valueof(objectList.get(String.valueof(data.get('objectField'))));
				if(numQueryMap.containsKey(num)){
					subQuery = numQueryMap.get(num) + ' AND ' + data.get('metadataField') + '='+ '\''+val+'\'';
				}else{
					subQuery = ' Where '+ data.get('metadataField') + '='+ '\''+val+'\'';
				}
                //store num and subQuery values in map
                numQueryMap.put(num,subQuery);
            }
            System.debug('numQueryMap: '+numQueryMap);
            if(numQueryMap.size() > 0 && numQueryMap.get('1') != Null){
                //get matched metadata record
                matchMetadataRecord = Database.query( metadataQuery + numQueryMap.get('1') + ' Limit 1');               
                if(matchMetadataRecord.isEmpty() && numQueryMap.get('2') != Null){
                 	//get matched metadata record
                	matchMetadataRecord = Database.query( metadataQuery + numQueryMap.get('2')+ ' Limit 1');
                }
            }
        }
        
        //generate filter condition for default and system information metadatarecord
        String defaultMetadata = ' Where MasterLabel=\'Default\' OR MasterLabel=\'System Information\'';
        
        //get filter metadata record
        List<Sobject> defaultRecord = Database.query(metadataQuery + defaultMetadata);
        
        //Create combine list 
        List<Sobject> combineList = new List<Sobject>();
        
        if(matchMetadataRecord != null && matchMetadataRecord.size() > 0){
            combineList.addAll(matchMetadataRecord);
        }
        
        if(defaultRecord != null && defaultRecord.size() > 0){
            combineList.addAll(defaultRecord);
        }
        
        //create map of master label and List of fields to be displayed
        if(combineList != null && combineList.size() > 0){
            for(Sobject obj : combineList){
                stringMap.put(String.valueof(obj.get('MasterLabel')),getValuesFromSchema(String.valueof(obj.get('FiedsToBeDisplayed__c')),fieldApiName));
            }
        }
        
        return stringMap;
    }
    
    //method to check if the fields we are trying to display are associated with object provided
    private static List<String> getValuesFromSchema(String metadataFieldsToBeFiltered,List<String> fieldApiNameList){
        List<String> filteredList = new List<String>(); 
		List<String> strList =	metadataFieldsToBeFiltered.split(',');
        for(String str : strList){
            //check field is available in associated object fields
            if(fieldApiNameList.contains(str)){
                filteredList.add(str);
            }
        }
        return filteredList;
    }
}