/**
 * (c) Telstra
 * Domain logic implementation for Account object
 * 04 Jul 2019	Amitabh Basu Original
 */ 
public class AccountDomain extends fflib_SObjectDomain {
    private static final String HIERARCHY_LEVEL = 'full';
    private static final String FIELDS_TO_DISPLAY = 'ParentId';
    private static final String PARENT_FIELD_API_NAME = 'ParentId';
    private static final String NAME_FIELD_API_NAME = 'Title__c';
        
    public AccountDomain(List<Account> sObjectList){
        super(sObjectList);
    }

    //The Constructor inner class allows the base class method 
	//SObjectDomain.triggerHandler to create a new instance of the domain class 
	//passing in the sObject list
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<sObject> sObjectList){
            return new AccountDomain(sObjectList);
        }
    }
    
    /**
     * Returns Map of ObjectWrapper records. If SOQL limit is reached it returns warning message, 
     * error in case of exception
     * @returns Map ds.
     */ 
    public Map<String, Object> getAllParentIds(){
        Map<String, Object> treeData = new Map<String, Object>();
        
		try{
			//Get Object Description
            Schema.DescribeSObjectResult objectDescribe = getSObjectType().getDescribe();
            //Schema.DescribeSObjectResult objectDescribe = Id.valueOf(recordId).getSobjectType().getDescribe();
			
            //Validate Name Field
            if(!ObjectHierarchy_Utility.validateField(objectDescribe, NAME_FIELD_API_NAME)){
               throw new ObjectHierarchy_Utility.HierarchyException(
                   ObjectHierarchy_Utility.INVALID_TITLE_FIELD + NAME_FIELD_API_NAME); 
            }
            
            //Validate Parent Field
            if(!ObjectHierarchy_Utility.validateField(objectDescribe, PARENT_FIELD_API_NAME)){
               throw new ObjectHierarchy_Utility.HierarchyException(
                   ObjectHierarchy_Utility.INVALID_PARENT_FIELD + PARENT_FIELD_API_NAME); 
            }
            
            //Filter fields which are accessible
			Set<String> validFieldsToDisplay = ObjectHierarchy_Utility.getValidFieldsToDisplay(
                objectDescribe, FIELDS_TO_DISPLAY);
           
            //Create Query Configuration 
			ObjectHierarchy_Utility.QueryConfig queryConfig = 
                			new ObjectHierarchy_Utility.QueryConfig(objectDescribe.getName(),
																	NAME_FIELD_API_NAME,												
                                                        			PARENT_FIELD_API_NAME);

         	//Add filtered accessible fields to query configuration
			queryConfig.fieldsToDisplay.addAll(validFieldsToDisplay);
            
            //Add Current Record as the base filterId
            List<Account> accounts = getRecords();
            if(accounts.size() > 0){
                String recordId = accounts.get(0).Id;
				queryConfig.filterIds = new Set<Id>{Id.valueOf(recordId)};
             }
            
            //Collect Column Configuration (just check if this method is required in current context)
			//treeData.put('columns', ObjectHierarchy_Utility.getColumnConfig(objectDescribe, 
                                                      //NAME_FIELD_API_NAME, validFieldsToDisplay));
			
            //Collect Hierarchy Data
			treeData.put('data', ObjectHierarchy_Utility.getHierarchyData(queryConfig, HIERARCHY_LEVEL));
            
            //If SOQL Limit has reached, inform end user as a warning
			if(ObjectHierarchy_Utility.SOQLLimitReached){
				treeData.put('warning', ObjectHierarchy_Utility.SOQL_LIMIT_REACHED_MSG);
                
				//Reset Limit reached flag
				ObjectHierarchy_Utility.SOQLLimitReached = false;
			}
            
        }catch(ObjectHierarchy_Utility.HierarchyException e){
			treeData.put('error', e.getMessage());
		}
		catch(Exception e){
			throw new ObjectHierarchy_Utility.HierarchyException(e.getMessage());                                           
		}               
        
        return treeData;                                          
    }
}