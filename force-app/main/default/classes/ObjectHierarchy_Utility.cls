/**
 * (c) Telstra
 * Creates object hierarchy
 * 04 Jul 2019	Amitabh Basu Original
 */ 
public with sharing class ObjectHierarchy_Utility{

	//Constant Declarations
	public static final Integer WIDTH_FOR_MAIN_TREE_NODE = 30;
	public static final String RECORD_NOT_FOUND = 'Record not found.';
	public static final String SOQL_LIMIT_REACHED_MSG = 'SOQL Governor limit reached. You will only be able to see limited records.';
	public static final String INVALID_TITLE_FIELD = 'Invalid Title field: ';
    public static final String INVALID_PARENT_FIELD = 'Invalid Parent field: ';
   
	//Flag used to validate SOQL Limit in iterative while loop
	public static Boolean SOQLLimitReached = false; 
    
	/**
	 * Method used to get the Complete Object Hierarchy
	 * @param queryConfig QueryConfig
	 * @param hierarchyLevel String
	 * @return ObjectWrapper List
	 */ 
	public static List<ObjectWrapper> getHierarchyData(QueryConfig queryConfig, String hierarchyLevel){
		List<ObjectWrapper> hierarchyData = new List<ObjectWrapper>();
		SObject rootNode;

		//Collect ParentFieldAPIName for temporary purpose
		String originalParentFieldAPIName = queryConfig.parentFieldAPIName;
        System.debug('originalParentFieldAPIName' +originalParentFieldAPIName);
		//Change queryConfig parentField to Id to get current record
		queryConfig.parentFieldAPIName = 'Id';
		//Add parentFieldAPIName in set so that it would also be queried
		queryConfig.fieldsToDisplay.add(originalParentFieldAPIName);

		SObject currentNode = getCurrentNode(queryConfig);
		//Check if Current Node is not null
		if(currentNode!=null){
			//If hierarchy level is set to full & current node's parent field is not null
			if(hierarchyLevel == 'full' && currentNode.get(originalParentFieldAPIName) != null){
				queryConfig.filterIds.clear();
				queryConfig.filterIds.add(Id.valueOf(String.valueOf(currentNode.get(originalParentFieldAPIName))));
				rootNode = getRootNode(queryConfig, originalParentFieldAPIName);
			}
			//Consider Current Node as root node if rootnode is null
            if(rootnode == null){
                rootNode = currentNode;
            }
			hierarchyData.add(new ObjectWrapper(rootNode, '#', queryConfig.nameFieldAPIName));
			//Reset ParentFieldAPIName to original value
			queryConfig.parentFieldAPIName = originalParentFieldAPIName;
			
			//Validate SOQL Limit Flag
			if(!SOQLLimitReached){
				//Collect all child records
				populateChildRecords(queryConfig, hierarchyData);
			}
		}
		else{
			throw new HierarchyException(RECORD_NOT_FOUND);
		}
		return hierarchyData;
	}

	/**
	 * Method used to get current node record based on passed current record Id
	 * @param queryConfig QueryConfig
	 * @return currentNode SObject
	 */ 
	public static SObject getCurrentNode(QueryConfig queryConfig){
		SObject currentNode;
		List<SObject> records = queryConfig.getRecords();
        
		if(!records.isEmpty()){
			currentNode = records[0];
		}
		return currentNode;
	}

	/**
	 * Method used to get the top level root element if hierarchy type is full
	 * @param queryConfig QueryConfig
	 * @param parentFieldAPIName String
	 * @return rootNode SObject
	 */ 
	public static SObject getRootNode(QueryConfig queryConfig, String parentFieldAPIName){
		SObject rootNode;
		Boolean rootRecordNotFound = true;
		List<SObject> records;
		while(rootRecordNotFound){
			//Validate SOQL Limits before executing next query
			if((Limits.getLimitQueries() - Limits.getQueries())<=0 
				|| (Limits.getLimitQueryRows() - Limits.getQueryRows())<=0){
				SOQLLimitReached = true;
				rootRecordNotFound = false;
				break;
			}
			else{
				records = queryConfig.getRecords();
				//Validate if resulting record list is empty then break the loop.
				if(records.isEmpty()){
					rootRecordNotFound = false;
					break;
				}
				else if(records[0].get(parentFieldAPIName) == null){
					rootNode = records[0];
					rootRecordNotFound = false;
					break;
				}
				else{
					rootNode = records[0];
					queryConfig.filterIds.clear();
					queryConfig.filterIds.add(Id.valueOf(String.valueOf(rootNode.get(parentFieldAPIName))));
				}
			}
		}
		return rootNode;
	}
 
	/**
	 * Method used to collect all child in the list
	 * @param queryConfig QueryConfig
	 * @param hierarchyData List
	 * @return void
	 */
	public static void populateChildRecords(QueryConfig queryConfig, List<ObjectWrapper> hierarchyData){
		Boolean childRecordFound = true;
		List<SObject> records;
		//While Loop to get all child records hierarchically
		while(childRecordFound){
			//Validate SOQL Limits before executing next query
			if((Limits.getLimitQueries() - Limits.getQueries())<=0 
				|| (Limits.getLimitQueryRows() - Limits.getQueryRows())<=0){
				SOQLLimitReached = true;
				childRecordFound = false;
				break;
			}
			else{
				records = queryConfig.getRecords();
				//Validate if resulting record list is empty then break the loop.
				if(records.isEmpty()){
					childRecordFound = false;
					break;
				}
				else{
					queryConfig.filterIds.clear();
					for(SObject record : records){
						queryConfig.filterIds.add(record.Id);
					    Id parentId = Id.valueOf(String.valueOf(record.get(queryConfig.parentFieldAPIName)));
						hierarchyData.add(new ObjectWrapper(record, String.valueOf(parentId), queryConfig.nameFieldAPIName));
					}
				}
			}
		}
	}

	/**
	 * Method used to get only valid/accessible fields in from the given CSV
	 * @param objectDescribe Schema.DescribeSObjectResult
	 * @param fieldsToDisplayCSV String
	 * @return fieldsToDisplay Set
	 */ 
	public static Set<String> getValidFieldsToDisplay(Schema.DescribeSObjectResult objectDescribe, String fieldsToDisplayCSV){
		Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
		Set<String> fieldsToDisplay = new Set<String>();
		String fieldName;
		for(String fieldAPIName : fieldsToDisplayCSV.split(',')){
			fieldAPIName = fieldAPIName.trim();
			if(fieldMap.containsKey(fieldAPIName) && fieldMap.get(fieldAPIName).getDescribe().isAccessible()){
				fieldsToDisplay.add(fieldAPIName);	
			}
		}
		return fieldsToDisplay;
	}

	/**
	 * Method used to collect column configurations for jstree
	 * @param objectDescribe Schema.DescribeSObjectResult
	 * @param nameFieldAPIName String
	 * @param fieldsToDisplay Set
	 * @return columnConfigs List
	 */ 
	public static List<ColumnWrapper> getColumnConfig(Schema.DescribeSObjectResult objectDescribe, String nameFieldAPIName, Set<String> fieldsToDisplay){
		List<ColumnWrapper> columnConfigs = new List<ColumnWrapper>();
		columnConfigs.add( new ColumnWrapper(WIDTH_FOR_MAIN_TREE_NODE + '%', objectDescribe.getLabel(), null, 'dataCell', 'headerMainCell'));
        if(fieldsToDisplay.size()>0){
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            fieldsToDisplay.remove(nameFieldAPIName);
            if(fieldsToDisplay.size()>0){
                Double perColumnWidth = (100 - WIDTH_FOR_MAIN_TREE_NODE)/fieldsToDisplay.size();
                for(String fieldAPIName : fieldsToDisplay){
                    columnConfigs.add(new ColumnWrapper(perColumnWidth + '%', 
                                                            fieldMap.get(fieldAPIName).getDescribe().getLabel(), 
                                                            fieldAPIName, 'dataCell', 'headerCell'));	
                }
            }	
        }
		return columnConfigs;
	}
	
    /**
     * Method used to check if given field is valid and accessible
     * @param objectDescribe Schema.DescribeSObjectResult
     * @param fieldAPIName String
     * @return isValid Boolean
     */ 
    public static Boolean validateField(Schema.DescribeSObjectResult objectDescribe, String fieldAPIName){
        Boolean isValid = false;
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        fieldAPIName = fieldAPIName.trim();
        if(fieldMap.containsKey(fieldAPIName) && fieldMap.get(fieldAPIName).getDescribe().isAccessible()){
			isValid = true;
        }
        return isValid;
    }
	
    //ObjectWrapper used to manage records
	public class ObjectWrapper{
		@AuraEnabled 
		public Id id {get;set;}
		@AuraEnabled 
		public String parent {get;set;}
		@AuraEnabled 
		public String text {get;set;}
		@AuraEnabled 
		public SObject data {get;set;}
		public ObjectWrapper(SObject record, String parentId, String nameFieldAPIName){
			this.id = record.Id;
			parent = parentId;
			data = record;
			text = String.valueOf(record.get(nameFieldAPIName));
		}
	}

	//Query Configuration Class to manage fields & query records
	public class QueryConfig{
		public String objectAPIName {get;set;}
		public String nameFieldAPIName {get;set;}
		public String parentFieldAPIName {get;set;}
		public Set<String> fieldsToDisplay {get;set;}
		public Set<Id> filterIds {get;set;}

		public QueryConfig(String objectAPIName, String nameFieldAPIName, String parentFieldAPIName){
			this.objectAPIName = objectAPIName;
			this.nameFieldAPIName = nameFieldAPIName;
			this.parentFieldAPIName = parentFieldAPIName;
			fieldsToDisplay = new Set<String>();
			fieldsToDisplay.add('Id');
		}

		public String getQuery(){
			if(String.isNotBlank(nameFieldAPIName)) fieldsToDisplay.add(nameFieldAPIName);
			if(String.isNotBlank(parentFieldAPIName)) fieldsToDisplay.add(parentFieldAPIName);
			
			String query = 'SELECT ' + string.escapeSingleQuotes(String.join(new List<String>(fieldsToDisplay), ', ')) + ' FROM ' + string.escapeSingleQuotes(objectAPIName) + ' ';
			if(!filterIds.isEmpty()){
			  query += ' WHERE ' + parentFieldAPIName + ' IN :filterIds ';   
			} 
            
			return query;
		}

		public List<SObject> getRecords(){
			return Database.query(getQuery());
		}
	}

	//ColumnWrapper used as a wrapper class for Column Configurations
	public class ColumnWrapper{
		@AuraEnabled 
		public String width {get;set;}
		@AuraEnabled 
		public String header {get;set;}
		@AuraEnabled 
		public String value {get;set;}
		@AuraEnabled
		public String wideCellClass {get;set;}
		@AuraEnabled
		public String headerClass {get;set;}
		public ColumnWrapper(String width, String header, String value, String wideCellClass, String headerClass){
			this.width = width;
			this.header = header;
			this.value = value;
			this.wideCellClass = wideCellClass;
			this.headerClass = headerClass;
		}
	}

	//Custom Exception Class
	public class HierarchyException extends Exception{}

}