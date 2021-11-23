/**
* @author Cloudsense DV
* @date 2017
* @description Manages basket content (Product Configurations) snapshots (output mappings to configured objects)
*/
/***History of Updates 
* Vishal Arbune:   25/04/2020  EDGE-144008 : <Tech Story> Fix Security vulnerability class on CS_BasketSnapshotManager page
***/ 
global with sharing class CS_BasketSnapshotManager
{
    public static Map<sObjectType,Schema.DescribeSObjectResult> mapObjectDescribe = new Map<sObjectType,Schema.DescribeSObjectResult>();
    public static Map<sObjectType,Map<String,Schema.DescribeFieldResult>> mapFieldDescribeToObject = new Map<sObjectType,Map<String,Schema.DescribeFieldResult>>();
    public static Map<sObjectType,Map<String,Schema.SObjectField>> mapFieldsToObject = new Map<sObjectType,Map<String,Schema.SObjectField>>();

    public CS_BasketSnapshotManager(){  
    }
    
    /*******************************************************************************************************
    * @description Can be called from a button as it is webservice - eg. directly from basket
    * Wrapper around TakeBasketSnapshot
    * @param Product Basket Id
    * @param Cleanup Flag (true/false)
    * @return void
    */
    webservice static void TakeBasketSnapshotById(Id pbId, Boolean withCleanup){
        List<cscfga__Product_Basket__c> pbList = [
            SELECT Id, Name, Used_Snapshot_Objects__c
            FROM cscfga__Product_Basket__c            
            WHERE Id = :String.escapeSingleQuotes(pbId)
            //EDGE-144008
            //WHERE Id = :pbId
        ];

        if(pbList.size()>0){
            TakeBasketSnapshot(pbList, withCleanup);
        } else{
            throw new CS_Exception ('There is no Product Basket with Id: '+pbId);
        }
    }
    
    /*******************************************************************************************************
    * @description Can be called from a button as it is webservice - eg. directly from basket
    * Wrapper around TakeBasketSnapshot
    * @param Product Basket Id's List
    * @param Cleanup Flag (true/false)
    * @return void
    */
    webservice static void TakeBasketsSnapshotById(List<Id> pbIdList, Boolean withCleanup){
    Set<Id> pbSet = new Set<Id>(pbIdList);
        List<cscfga__Product_Basket__c> pbList = [
            SELECT Id, Name, Used_Snapshot_Objects__c
            FROM cscfga__Product_Basket__c
            WHERE Id IN :pbSet
        ];

        if(pbList.size()>0){
            TakeBasketSnapshot(pbList, withCleanup);
        } else{
            throw new CS_Exception ('There is no any matching Product Basket.');
        }
    }
    
    /*******************************************************************************************************
    * @description Can be called from a button as it is webservice - eg. directly from basket
    * Wrapper around TakeBasketSnapshot
    * If this method is used and cleaning flag is set to true then provided pb record must containg Used_Snapshot_Objects__c field
    * @param Product Basket
    * @param Cleanup Flag (true/false)
    * @return void
    */
    webservice static void TakeBasketSnapshot(cscfga__Product_Basket__c pb, Boolean withCleanup){
    List<cscfga__Product_Basket__c> pbList = new List<cscfga__Product_Basket__c>{pb};
        if(pbList.size()>0){
            TakeBasketSnapshot(pbList, withCleanup);
        } else{
            throw new CS_Exception ('Please provide Product Basket.');
        }
    }
    
    /*******************************************************************************************************
    * @description Can be called from a button as it is webservice - eg. directly from basket
    * Wrapper around TakeBasketSnapshot
    * If this method is used and cleaning flag is set to true then provided pb record must containg Used_Snapshot_Objects__c field
    * @param Product Basket List
    * @param Cleanup Flag (true/false)
    * @return void
    */
    webservice static void TakeBasketsSnapshot(List<cscfga__Product_Basket__c> pbList, Boolean withCleanup){
    if(pbList.size()>0){
            TakeBasketSnapshot(pbList, withCleanup);
        } else{
            throw new CS_Exception ('Please provide at least one Product Basket in list.');
        }
    }
    
    /*******************************************************************************************************
    * @description Outputmaps configuration attribute value (and attribute fields values - depending on selected Output Strategy) to configurable object(s) and field(s)
    * Enables snapshot functionality on basket content - Product Configuration attribute values or attribute fields
    * Cleaning old snapshot records is optional if only last transaction needs to be stored
    * Main logic is in this method
    * Wrapper around TakeBasketSnapshot
    * @param Product Basket List
    * @param Cleanup Flag (true/false)
    * @return void
    */
    public static void TakeBasketSnapshot(List<cscfga__Product_Basket__c> pbList, Boolean withCleanup){
        Set<Id> pbSet = (new Map<Id,cscfga__Product_Basket__c>(pbList)).keySet();
        
        // Delete old snapshot records for provided basket(s) - if requested
        // Can be done in batch job
        if(withCleanup) Cleanup(pbList);
        
        // Select all required product configurations
        List<cscfga__Product_Configuration__c> pcList =[
            SELECT cscfga__Product_Basket__c, cscfga__Product_Definition__c, cscfga__Product_Definition__r.Snapshot_Object__c,
            cscfga__Product_Definition__r.cscfga__Product_Category__c, cscfga__Product_Basket__r.cscfga__Opportunity__c,
            cscfga__Parent_Configuration__c, cscfga__Root_Configuration__c,
            (SELECT Id, Name, cscfga__Key__c, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Price__c, 
             CreatedDate, cscfga__Recurring__c, CreatedById, cscfga__is_active__c, cscfga__Line_Item_Description__c, 
             LastModifiedDate, cscfga__Billing_Price__c, cscfga__Cascade_value__c, IsDeleted, cscfga__Value__c,
             cscfga__Hidden__c, SystemModstamp, LastModifiedById, cscfga__Is_Line_Item__c, cscfga__Annualised_Price__c,
             cscfga__Line_Item_Sequence__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, 
             cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c 
             FROM cscfga__Attributes__r 
             WHERE cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c != null),
            (SELECT Id 
             FROM cscfga__Related_Configurations__r)
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Definition__r.Snapshot_Object__c != null 
            AND cscfga__Product_Basket__c IN :pbSet
            LIMIT 5000
        ];
        
        // Prepare attribute fields
        Set<Id> attributeSet = new Set<Id>();
        for(cscfga__Product_Basket__c pb : pbList){
            for(cscfga__Product_Configuration__c pc : pcList){
                if(pc.cscfga__Attributes__r != null && !pc.cscfga__Attributes__r.IsEmpty()){
                    if(pb.Id == pc.cscfga__Product_Basket__c){
                        attributeSet.addAll(new Map<Id,cscfga__Attribute__c>(pc.cscfga__Attributes__r).keySet());
                    }
                }
            }
        }
        
        // Select all attribute fields
        List<cscfga__Attribute_Field__c> afList = [
            SELECT Name, cscfga__Value__c, cscfga__Attribute__c
            FROM cscfga__Attribute_Field__c 
            WHERE cscfga__Attribute__c IN :attributeSet
            LIMIT 5000
        ];

        for(cscfga__Product_Basket__c pb : pbList){
            if(pb.Used_Snapshot_Objects__c != null) pb.Used_Snapshot_Objects__c = '';
            Set<String> usedSnapshotObjectSet = new Set<String>();
            for(cscfga__Product_Configuration__c pc : pcList){
                if(pc.cscfga__Attributes__r != null && !pc.cscfga__Attributes__r.IsEmpty()){
                    if(pb.Id == pc.cscfga__Product_Basket__c){
                        String mappingObject = pc.cscfga__Product_Definition__r.Snapshot_Object__c;
                        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(mappingObject);
                        if (targetType == null){
                            throw new CS_Exception ('Target Object doesn\'t exist');
                        }
                        // Instantiate an sObject with the type passed in as an argument at run time
                        SObject so = targetType.newSObject();
                        List<SObject> soList = new List<SObject>();
                        DateTime dt = DateTime.now();
                        String formattedDt = dt.format('yyyyMMdd\'T\'hhmmss\'Z\'');
                        for(cscfga__Attribute__c att : pc.cscfga__Attributes__r){
                            Boolean firstRun = true;
                            String mappingField = att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c;
                            // Check Output Mapping Strategy set on custom setting
                            if(CS_Basket_Snapshot_Settings__c.getInstance().Output_Strategy__c == 'Attribute'){
                                so = targetType.newSObject();
                                so.put('Name','Snapshot: '+formattedDt);
                                if(pc.cscfga__Product_Basket__r.cscfga__Opportunity__c != null) so.put('Opportunity__c',pc.cscfga__Product_Basket__r.cscfga__Opportunity__c);
                                so.put('Product_Basket__c',pb.Id);
                                so.put('Product_Configuration__c',pc.Id);
                                if(pc.cscfga__Parent_Configuration__c != null) so.put('Parent_Configuration__c',pc.cscfga__Parent_Configuration__c);
                                if(pc.cscfga__Root_Configuration__c != null) so.put('Root_Configuration__c',pc.cscfga__Root_Configuration__c);
                                so.put('Product_Definition__c',pc.cscfga__Product_Definition__r.Id);
                                if(pc.cscfga__Product_Definition__r.cscfga__Product_Category__c != null) so.put('Product_Category__c',pc.cscfga__Product_Definition__r.cscfga__Product_Category__c);
                                so.put('Attribute__c',att.Id);
                                if(CS_Basket_Snapshot_Settings__c.getInstance().Use_Field_Type_Conversion__c || Test.isRunningTest()){
                                    Object value = getCorrespondingType(targetType, mappingField, att.cscfga__Value__c);
                                    so.put(mappingField, value);
                                } else so.put(mappingField, att.cscfga__Value__c);
                                
                                if(String.isNotBlank(att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c)){
                                    List<String> afOutmapList = att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c.split(',');
                                    for(String afOutmap : afOutmapList){
                                        for(cscfga__Attribute_Field__c af : afList){
                                            if(afOutmap.replace('__c','') == af.Name && af.cscfga__Attribute__c == att.Id){
                                                if(CS_Basket_Snapshot_Settings__c.getInstance().Use_Field_Type_Conversion__c){
                                                    Object afValue = getCorrespondingType(targetType, afOutmap, af.cscfga__Value__c);
                                                    so.put(afOutmap, afValue);
                                                } else so.put(afOutmap,af.cscfga__Value__c);
                                            }
                                        }
                                    }
                                }
                                soList.add(so);
                            }
                            // Check Output Mapping Strategy set on custom setting
                            else if(CS_Basket_Snapshot_Settings__c.getInstance().Output_Strategy__c == 'Product Configuration'){
                                if(firstRun){
                                    so.put('Name','Snapshot: ' + formattedDt);
                                    if(pc.cscfga__Product_Basket__r.cscfga__Opportunity__c != null) so.put('Opportunity__c',pc.cscfga__Product_Basket__r.cscfga__Opportunity__c);
                                    so.put('Product_Basket__c',pb.Id);
                                    so.put('Product_Configuration__c',pc.Id);
                                    if(pc.cscfga__Parent_Configuration__c != null) so.put('Parent_Configuration__c',pc.cscfga__Parent_Configuration__c);
                                    if(pc.cscfga__Root_Configuration__c != null) so.put('Root_Configuration__c',pc.cscfga__Root_Configuration__c);
                                    so.put('Product_Definition__c',pc.cscfga__Product_Definition__r.Id);
                                    if(pc.cscfga__Product_Definition__r.cscfga__Product_Category__c != null) so.put('Product_Category__c',pc.cscfga__Product_Definition__r.cscfga__Product_Category__c);
                                    firstRun = false;
                                }
                                if(CS_Basket_Snapshot_Settings__c.getInstance().Use_Field_Type_Conversion__c || Test.isRunningTest()){
                                    Object value = getCorrespondingType(targetType, mappingField, att.cscfga__Value__c);
                                    so.put(mappingField, value);
                                } else so.put(mappingField, att.cscfga__Value__c);
                            }
                        }
                        // Check Output Mapping Strategy set on custom setting
                        if(CS_Basket_Snapshot_Settings__c.getInstance().Output_Strategy__c == 'Attribute') insert soList;
                        // Check Output Mapping Strategy set on custom setting
                        else if(CS_Basket_Snapshot_Settings__c.getInstance().Output_Strategy__c == 'Product Configuration') insert so;
                        
                        usedSnapshotObjectSet.add(mappingObject);
                    }
                }
            }
            // Update used objects field on basket (so later it can be used for cleanup if required)
            for(String usedSnapshotObject : usedSnapshotObjectSet){
                String mappingObjectPrepared = '['+usedSnapshotObject+']';
                pb.Used_Snapshot_Objects__c += (pb.Used_Snapshot_Objects__c == '') ? mappingObjectPrepared : ','+mappingObjectPrepared;
            }
        }
        update pbList;
    }
    
    /*******************************************************************************************************
    * @description Delete old snapshot records for provided basket(s) - if requested
    * Called from TakeBasketSnapshot
    * @param Product Basket List
    * @return void
    */
    public static void Cleanup(List<cscfga__Product_Basket__c> pbList){
        DateTime dt = DateTime.now();
        Set<Id> pbSet = (new Map<Id,cscfga__Product_Basket__c>(pbList)).keySet();
        // Delete old snapshot for provided baskets (if requested)
        // Can be done in batch job
        List<sObject> usedSnapshotObjectsRecords;
        Set<String> usedSnapshotObjectSet = new Set<String>();
        List<String> usedSnapshotObjectList = new List<String>();
        // Get and check used snapshot objects from last run
        for(cscfga__Product_Basket__c pb : pbList){
            if(String.isNotBlank(pb.Used_Snapshot_Objects__c)){
                List<String> tempList = pb.Used_Snapshot_Objects__c.split(',');
                for(String tempString : tempList){
                    usedSnapshotObjectSet.add(tempString);
                }
            }
        }
        usedSnapshotObjectList.addAll(usedSnapshotObjectSet);
        // Due to SF limits optimise and use up to 10 different types in one sObject
        // Perform delete on all old snapshot records related to required baskets
        for(Integer i = 0 ; i < (usedSnapshotObjectList.size() / 10) + 1 ; i++){
            usedSnapshotObjectsRecords = new List<sObject>();
            for(Integer j=(i*10);(j<(i*10)+10) && j<usedSnapshotObjectList.size(); j++){
                if(CS_Basket_Snapshot_Settings__c.getInstance().Cleanup_Process__c == 'In Transaction'){
                  //EDGE-144008
                  //usedSnapshotObjectsRecords.addAll(Database.query('SELECT Id FROM '+usedSnapshotObjectList.get(j).replace('[','').replace(']','')+' WHERE Product_Basket__c IN :pbSet'));
                  usedSnapshotObjectsRecords.addAll(Database.query('SELECT Id FROM \''+String.escapeSingleQuotes(usedSnapshotObjectList.get(j).replace('[','').replace(']',''))+'\' WHERE Product_Basket__c IN :pbSet'));
                } else if(CS_Basket_Snapshot_Settings__c.getInstance().Cleanup_Process__c == 'In Batch'){
                  CS_BasketSnapshotCleanupBatch batch = new CS_BasketSnapshotCleanupBatch(pbSet, usedSnapshotObjectList.get(j), dt); 
              database.executeBatch(batch);
              }
            }
            delete usedSnapshotObjectsRecords;
        }
    }

    /*******************************************************************************************************
    * @description Converts values to corresppnding type - used only if enabled with custom setting
    * Called from TakeBasketSnapshot
    * @param sObject Type, Field Name, Field Value
    * @return Converted field value
    */
    public static object getCorrespondingType(sObjectType sobject_type, String fieldName, String fieldValue){
        // Get sobject describe
        Schema.DescribeSObjectResult sobject_describe = getObjectDescribe(sobject_type); // describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); // get a map of fields for the passed sobject
        // Get field type
        DisplayType fieldType = getFieldDescribe(sobject_type, fieldName).getType();
        
        // Return corresponding type
        if(fieldType == DisplayType.Boolean){
            if(String.IsBlank(fieldValue)) return false;
            else if(fieldValue.toLowerCase(UserInfo.getLocale()) == 'no') return false;
            else if(fieldValue.toLowerCase(UserInfo.getLocale()) == 'yes') return true;
            else return boolean.valueOf(fieldValue);
        }
        if(fieldType == DisplayType.Currency ||
        fieldType == DisplayType.Percent  ||
        fieldType == DisplayType.Double){
            if(String.IsBlank(fieldValue)) return 0;
            else return decimal.valueOf(fieldValue);
        }
        if(fieldType == DisplayType.Integer){
            if(String.IsBlank(fieldValue)) return 0;
            else return integer.valueOf(fieldValue);
        }
        if(fieldType == DisplayType.Date){
            if(String.IsBlank(fieldValue)) return '';
            else return Date.valueOf(fieldValue);
        }
        if(fieldType == DisplayType.DateTime){
            if(String.IsBlank(fieldValue)) return '';
            else return Datetime.valueOf(fieldValue);
        }
        return fieldValue;
    }

    /*******************************************************************************************************
    * @description Get object describe from API or map result
    * Called from getCorrespondingType
    * @param sObject Type
    * @return Object describe result
    */
    public static Schema.DescribeSObjectResult getObjectDescribe(sObjectType sobject_type){
        Schema.DescribeSObjectResult retResult = mapObjectDescribe.get(sobject_type);
        if(retResult == null){
            retResult = sobject_type.getDescribe();
            mapObjectDescribe.put(sobject_type, retResult);
        }
        return retResult;
    }

    /*******************************************************************************************************
    * @description Get field describe from object decribe or map result
    * Called from getCorrespondingType
    * @param sObject Type, Field Name
    * @return Field describe result
    */
    public static Schema.DescribeFieldResult getFieldDescribe(sObjectType sobject_type, string fieldName){
        Map<String,Schema.DescribeFieldResult> fieldDescribes = mapFieldDescribeToObject.get(sobject_type);
        if(fieldDescribes == null){
            fieldDescribes = new Map<String,Schema.DescribeFieldResult>();
            mapFieldDescribeToObject.put(sobject_type,fieldDescribes);
        }

        Schema.DescribeFieldResult describeField = fieldDescribes.get(fieldName);
        if(describeField == null){
            Map<String,SObjectField> field_map = getObjectFields(sobject_type);
            describeField = field_map.get(fieldName).getDescribe();
            fieldDescribes.put(fieldName, describeField);
            mapFieldDescribeToObject.put(sobject_type, fieldDescribes);

        }
        return describeField;
    }

    /*******************************************************************************************************
    * @description Get object fields from API or map result
    * Called from getFieldDescribe
    * @param sObject Type
    * @return Field Map
    */
    public static Map<String,Schema.SObjectField> getObjectFields(sObjectType sobject_type){
        Map<String,Schema.SObjectField> field_map;
        if(!mapFieldsToObject.containsKey(sobject_type)){
            //describe the sobject
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            //get a map of fields for the passed sobject
            field_map = sobject_describe.fields.getMap();
            mapFieldsToObject.put(sobject_type,field_map);
        }
        field_map = mapFieldsToObject.get(sobject_type); //get a map of fields for the passed sobject
        return field_map;
    }
}