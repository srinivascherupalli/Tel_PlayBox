/**
* Factory class for Unit Testing
* 
* @author  	Prerna Rahangdale / Nandan Narasappa
* @version 	2.0
* @since   	10/03/2020 
*
* @credits 	Daniel Hoechst
* @link    	https://github.com/dhoechst/SaleFactosforce-Test-Factory
*
*/
@isTest
public with sharing class SYS_TestFactory {

	//constants
	private static final String STR_OBJ_PREFIX = '__(c|C)$|__';
	private static final String STR_EMPTY = '';
	private static final String WHITE_SPACE = ' ';
	private static final String STR_DEFAULTS = 'Defaults';
	private static final String DEFAULTS_CLASS = 'SYS_TestFactoryDefaults.';
	private static final String ERR_MSG_INVALID_DEFAULT_CLASS = 'Invalid defaults class.';
	private static final String FLD_Name = 'Name';

	// variables

	// When we create a list of SObjects, we need to have a unique field for the insert if there isn't an autonumber field.
	// Usually we use the Name field, but some objects don't have a name field.
	private static Map<Schema.SObjectType, Schema.SObjectField> nameFieldMap = new Map<Schema.SObjectType, Schema.SObjectField> {
		Contact.sObjectType => Contact.LastName,
		Case.sObjectType => Case.CaseNumber 		//this is the autonumber field
	};

    //custom exception class for throwing error to consumer
	public class SYS_TestFactoryException extends Exception {}

	// Use the FieldDefaults interface to set up values you want to default in for all objects.
	public interface FieldDefaults {
		Map<Schema.SObjectField, Object> getFieldDefaults();
	}

	/**
	* This method returns the instance of sObject type with default values defined in field
	* default class
	*
	* Note: Explicit DML statement required by the calling class to commit to database
    * 
    * @param    objType     sobject type
    * @return   SObject     returns the Sobject record with default values
    */
	public static SObject createSObject(Schema.SObjectType objType){
		return createSObject(objType.newSObject());
	}
	
	/**
	* This method returns the instance of sObject with default values defined in field
	* default class
	*
	* Note: Explicit DML statement required by the calling class to commit to database
    * 
    * @param    sObj        instance of sobject type
    * @return   SObject     returns the Sobject record with default values
    */
    public static SObject createSObject(SObject sObj) {
		// Check what type of object we are creating and add any defaults that are needed.
		String objectName = String.valueOf(sObj.getSObjectType());
		// Construct the default values class. Salesforce doesn't allow '__' in class names
		String defaultClassName = objectName.replaceAll(STR_OBJ_PREFIX, STR_EMPTY) + STR_DEFAULTS;
		// If there is a class that exists for the default values, then use them
		if (Type.forName(DEFAULTS_CLASS + defaultClassName) != null) {
			sObj = createSObject(sObj, DEFAULTS_CLASS + defaultClassName);
		}
		return sObj;
	}

	/**
	* This method returns the instance of sObject with default values defined in field
	* default class and push to database
	*
    * @param    objType     sobject type
	* @param    doInsert    boolean to save record if true
    * @return   SObject     returns the Sobject record with default values
	*/
	public static SObject createSObject(Schema.SObjectType objType,Boolean doInsert){
		return createSObject(objType.newSObject(),doInsert);
	}
	
	/**
	* This method returns the instance of sObject with default values defined in field
	* default class and push to database
	*
    * @param    sObj        instance of sobject type
	* @param    doInsert    boolean to save record if true
    * @return   SObject     returns the Sobject record with default values
    */
    public static SObject createSObject(SObject sObj,Boolean doInsert) {
		SObject retObject = createSObject(sObj);
		save(new List<Sobject>{sObj},doInsert);
		return retObject;
	}

	/**
	* This method returns the instance of sObject with default values defined in field
	* default class
	*
    * @param    objType        		sobject type
	* @param    defaultClassName    class name for default field values
    * @return   SObject     		returns the Sobject record with default values
    */
    public static SObject createSObject(Schema.SObjectType objType,String defaultClassName) {
		return createSObject(objType.newSObject(),defaultClassName);
	}

	/**
	* This method returns the instance of sObject with default values defined in field
	* default class
	*
    * @param    sObj        		instance of sobject type
	* @param    defaultClassName    class name for default field values
    * @return   SObject     		returns the Sobject record with default values
    */
    public static SObject createSObject(SObject sObj,String defaultClassName) {
		// Create an instance of the defaults class so we can get the Map of field defaults
		Type defaultClassType = Type.forName(defaultClassName);
		if(defaultClassType == null){
			throw new SYS_TestFactoryException(ERR_MSG_INVALID_DEFAULT_CLASS);
		}
		FieldDefaults defaults = (FieldDefaults) defaultClassType.newInstance();
		addFieldDefaults(sObj,defaults.getFieldDefaults());
		return sObj;
	}

	/**
	* This method returns the instance of sObject with default values defined in field
	* default class and push to database
	*
    * @param    objType        		sobject type
	* @param    defaultClassName    class name for default field values
	* @param    doInsert    		boolean to save record if true
    * @return   SObject     		returns the Sobject record with default values
    */
    public static SObject createSObject(Schema.SObjectType objType,String defaultClassName,Boolean doInsert) {
		return createSObject(objType.newSObject(),defaultClassName,doInsert);
	}

	/**
	* This method returns the instance of sObject with default values defined in field
	* default class and push to database
	*
    * @param    sObj        		instance of sobject type
	* @param    defaultClassName    class name for default field values
	* @param    doInsert    		boolean to save record if true
    * @return   SObject     		returns the Sobject record with default values
    */
    public static SObject createSObject(SObject sObj,String defaultClassName,Boolean doInsert) {
		SObject retObject = createSObject(sObj,defaultClassName);
		save(new List<Sobject>{retObject},doInsert);
		return retObject;
	}

	/**
	* This method returns the collection of sObject instance with default values defined in field
	* default class
	*
    * @param    objType        		sobject type
	* @param    numberOfObjects    	number of records to be created
    * @return   List<SObject>     	returns the list of Sobject records with default values populated
    */
    public static List<SObject> createSObjectList(Schema.SObjectType objType,Integer numberOfObjects) {
		return createSObjectList(objType.newSObject(),numberOfObjects);
	}

	/**
	* This method returns the collection of sObject instance with default values defined in field
	* default class
	*
    * @param    sObj        		instance of sobject type
	* @param    numberOfObjects    	number of records to be created
    * @return   List<SObject>     	returns the list of Sobject records with default values populated
    */
    public static List<SObject> createSObjectList(SObject sObj,Integer numberOfObjects) {
		// setting null to use default class for field defaults, typecasted to String to avoid Ambiguous method signature
		return createSObjectList(sObj,numberOfObjects, (String) null);
	}

	/**
	* This method returns the collection of sObject instance with default values defined in field
	* default class and push to database
	*
    * @param    objType        		sobject type
	* @param    numberOfObjects    	number of records to be created
	* @param    doInsert    		boolean to save record if true
    * @return   List<SObject>     	returns the list of Sobject records with default values populated
    */
    public static List<SObject> createSObjectList(Schema.SObjectType objType,Integer numberOfObjects,Boolean doInsert) {
		return createSObjectList(objType.newSObject(),numberOfObjects,doInsert);
	}

	/**
	* This method returns the collection of sObject instance with default values defined in field
	* default class and push to database
	*
    * @param    sObj        		instance of sobject type
	* @param    numberOfObjects    	number of records to be created
	* @param    doInsert    		boolean to save record if true
    * @return   List<SObject>     	returns the list of Sobject records with default values populated
    */
    public static List<SObject> createSObjectList(SObject sObj,Integer numberOfObjects,Boolean doInsert) {
		// setting null to use default class for field defaults, typecasted to String to avoid Ambiguous method signature
		List<SObject> retList = createSObjectList(sObj,numberOfObjects, (String) null);	
		save(retList,doInsert);
		return retList;
	}

	/**
	* This method returns the collection of sObject instance with default values defined in field
	* default class and push to database
	*
    * @param    objType        		sobject type
	* @param    numberOfObjects    	number of records to be created
	* @param    defaultClassName    class name for default field values
	* @param    doInsert    		boolean to save record if true
    * @return   List<SObject>     	returns the list of Sobject records with default values populated
    */
    public static List<SObject> createSObjectList(Schema.SObjectType objType,Integer numberOfObjects,String defaultClassName,Boolean doInsert) {
		return createSObjectList(objType.newSObject(),numberOfObjects,defaultClassName,doInsert);
	}

	/**
	* This method returns the collection of sObject instance with default values defined in field
	* default class and push to database
	*
    * @param    sObj        		instance of sobject type
	* @param    numberOfObjects    	number of records to be created
	* @param    defaultClassName    class name for default field values
	* @param    doInsert    		boolean to save record if true
    * @return   List<SObject>     	returns the list of Sobject records with default values populated
    */
    public static List<SObject> createSObjectList(SObject sObj,Integer numberOfObjects,String defaultClassName,Boolean doInsert) {
		List<SObject> retList = createSObjectList(sObj,numberOfObjects,defaultClassName);
		save(retList,doInsert);
		return retList;
	}

	/**
	* This method returns the collection of sObject instance with default values defined in field
	* default class
	*
    * @param    objType        		sobject type
	* @param    numberOfObjects    	number of records to be created
	* @param    defaultClassName    class name for default field values
    * @return   List<SObject>     	returns the list of Sobject records with default values populated
    */
    public static List<SObject> createSObjectList(Schema.SObjectType objType,Integer numberOfObjects,String defaultClassName) {
		return createSObjectList(objType.newSObject(),numberOfObjects,defaultClassName);
	}

	/**
	* This method returns the collection of sObject instance with default values defined in field
	* default class
	*
    * @param    sObj        		instance of sobject type
	* @param    numberOfObjects    	number of records to be created
	* @param    defaultClassName    class name for default field values
    * @return   List<SObject>     	returns the list of Sobject records with default values populated
    */
    public static List<SObject> createSObjectList(SObject sObj,Integer numberOfObjects,String defaultClassName) {
		List<SObject> sObjs = new List<SObject>();
		SObject newObj;

		// Get one copy of the object
		if(String.isEmpty(defaultClassName)){
			newObj = createSObject(sObj);
		}
		else{
			newObj = createSObject(sObj,defaultClassName);
		}

		String nameField = String.valueOf(nameFieldMap.get(sObj.getSObjectType()));
		if(String.isEmpty(nameField)){
			nameField = FLD_Name;
		}

        Boolean nameIsAutoNumber, isCreateable ;
        // check if unique field is createable
        Schema.SObjectField nameFields = sObj.getSobjectType().getDescribe().fields.getMap().get(nameField);
        if(nameFields != null){
            Schema.DescribeFieldResult fieldDescribe =  nameFields.getDescribe();
            nameIsAutoNumber = fieldDescribe.isAutoNumber();
            isCreateable = fieldDescribe.isCreateable();
        }

		// Clone the object the number of times requested. Increment the name field so each record is unique
        for (Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedSObj = newObj.clone(false, true);
            if(nameIsAutoNumber != null){
                if (!nameIsAutoNumber && isCreateable) {
                    clonedSObj.put(nameField, (String) clonedSObj.get(nameField) + WHITE_SPACE + i);
                }
            }
            sObjs.add(clonedSObj);
        }
        return sObjs;
	}

	/**
	* This method commits record to database
	*
    * @param    objList        	collection of sobject
	* @param    doInsert    	boolean to indicate if save required or not
    */
	private static void save(List<sObject> objList,Boolean doInsert){
		if(doInsert){
			Database.insert(objList);
		}
	}

	/**
	* This method populates default value to fields if not populated
	*
    * @param    sObj        	instance of sobject type
	* @param    defaults    	number of records to be created
    */
    private static void addFieldDefaults(SObject sObj,Map<Schema.SObjectField, Object> defaults) {
		// Loop through the map of fields and if they weren't specifically assigned, fill them.
        Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
        for (Schema.SObjectField field : defaults.keySet()) {
            if (!populatedFields.containsKey(String.valueOf(field))) {
                sObj.put(field, defaults.get(field));
            }
        }
	}
}