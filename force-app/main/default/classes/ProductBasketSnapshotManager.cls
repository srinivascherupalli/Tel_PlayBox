global with sharing class ProductBasketSnapshotManager {
	public static Map<sObjectType,Schema.DescribeSObjectResult> mapObjectDescribe = new Map<sObjectType,Schema.DescribeSObjectResult>();
    public static Map<sObjectType,Map<String,Schema.DescribeFieldResult>> mapFieldDescribeToObject = new Map<sObjectType,Map<String,Schema.DescribeFieldResult>>();
    public static Map<sObjectType,Map<String,Schema.SObjectField>> mapFieldsToObject = new Map<sObjectType,Map<String,Schema.SObjectField>>();

   
    /*******************************************************************************************************
    * @description Outputmaps configuration attribute value (and attribute fields values - depending on selected Output Strategy) to configurable object(s) and field(s)
    * Enables snapshot functionality on basket content - Product Configuration attribute values or attribute fields
    * Cleaning old snapshot records is optional if only last transaction needs to be stored
    * Main logic is in this method
    * Wrapper around TakeBasketSnapshot
    * @param Product Basket List
    * @return void
    */
    public static List<sObject> TakeBasketSnapshotData(List<cscfga__Product_Basket__c> pbList,Map<String,String> subfilters){
        Set<String> pbSet = (new Map<String,cscfga__Product_Basket__c>(pbList)).keySet();
       
       //US - 10811
        System.debug('pbSet:'+pbSet);
        String pcListQuery= 'SELECT name,cscfga__Product_Basket__c, cscfga__Product_Definition__c, cscfga__Product_Definition__r.Snapshot_Object__c, cscfga__Product_Definition__r.cscfga__Product_Category__c, cscfga__Product_Basket__r.cscfga__Opportunity__c,cscfga__Parent_Configuration__c, cscfga__Root_Configuration__c,cscfga__Description__c,cscfga__Contract_Term__c,Commercial_Config__c,(SELECT Id, Name, cscfga__Key__c, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Price__c, CreatedDate, cscfga__Recurring__c, CreatedById, cscfga__is_active__c, cscfga__Line_Item_Description__c, LastModifiedDate, cscfga__Billing_Price__c, cscfga__Cascade_value__c, IsDeleted, cscfga__Value__c,cscfga__Hidden__c, SystemModstamp, LastModifiedById, cscfga__Is_Line_Item__c, cscfga__Annualised_Price__c,cscfga__Line_Item_Sequence__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r WHERE cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c != null),(SELECT Id FROM cscfga__Related_Configurations__r) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.Snapshot_Object__c != null AND cscfga__Product_Basket__c IN :pbSet ';      
         if(!subfilters.isEmpty() && subfilters!=null ){
            for(String key:subfilters.keySet()){
                pcListQuery = pcListQuery + ' AND '+  String.escapeSingleQuotes(key) + '__c =\''+String.escapeSingleQuotes(subfilters.get(key))+'\'';
            }
                
        }   
               
          pcListQuery= pcListQuery+' LIMIT 5000';
        System.debug('Query:'+pcListQuery);
     
        // Select all required product configurations
   /*     List<cscfga__Product_Configuration__c> pcList =[
            SELECT name,cscfga__Product_Basket__c, cscfga__Product_Definition__c, cscfga__Product_Definition__r.Snapshot_Object__c,
            cscfga__Product_Definition__r.cscfga__Product_Category__c, cscfga__Product_Basket__r.cscfga__Opportunity__c,
            cscfga__Parent_Configuration__c, cscfga__Root_Configuration__c,cscfga__Description__c,cscfga__Contract_Term__c,Commercial_Config__c,
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
   */
        List<cscfga__Product_Configuration__c> pcList = Database.query(pcListQuery);
        System.debug('PCList:'+pcList);     
        // Prepare attribute fields
        Set<Id> attributeSet = new Set<Id>();
        Set<Id> parentConfiguration = new Set<Id>();
        
        list<ID> opportunityID = New list<ID>();
        list<String> productBasketOppList = New list<String>();
        
        for(cscfga__Product_Basket__c pb : pbList){
            for(cscfga__Product_Configuration__c pc : pcList){
            	parentConfiguration.add(pc.cscfga__Parent_Configuration__c);
                if(pc.cscfga__Attributes__r != null && !pc.cscfga__Attributes__r.IsEmpty()){
                    if(pb.Id == pc.cscfga__Product_Basket__c){
                        attributeSet.addAll(new Map<Id,cscfga__Attribute__c>(pc.cscfga__Attributes__r).keySet());
                    }
                }
            }
            /* JIRA -EDGE-25920 -Enhance external basket snapshot to ensure we capture metadata needed for contract generation : Maq*/
            if(pb.cscfga__Opportunity__c <> NULL){
                opportunityID.add(pb.cscfga__Opportunity__c);
                productBasketOppList.add(pb.Id+'~!@!~'+pb.cscfga__Opportunity__c);
            } 
        }
        /* JIRA -EDGE-25920 -Enhance external basket snapshot to ensure we capture metadata needed for contract generation : Maq*/
        map<Id,string> primaryContactMap=new Map<Id,String>();
        list<OpportunityContactRole> oppContactRole = [SELECT ContactId, Contact.Name,Contact.ID, IsPrimary, Role,Opportunity.name, OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN: opportunityID AND IsPrimary = true ORDER BY IsPrimary DESC];
        if(oppContactRole.size() > 0){
            for(OpportunityContactRole OCR : oppContactRole){
                if(OCR.IsPrimary == true){
                   // contactID = OCR.Contact.ID;
                    for(String PBOpp :  productBasketOppList){
                        if(OCR.OpportunityId == PBOpp.split('~!@!~')[1]){
                          primaryContactMap.put(PBOpp.split('~!@!~')[0],OCR.Contact.ID);  
                        }
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

        List<sObject> lstReturn = new List<sObject>();

        map<Id,string> sitemap=new Map<Id,String>();
        map<Id,string> siteAddressMap=new Map<Id,String>();
        //US-33959
        map<Id,String> serviceabilityLocationMap = new Map<Id, String>();
        map<Id,String> responseTimeMap = new Map<Id, String>();
        map<Id,String> restorationTimeMap = new Map<Id, String>();
        //End US-33959
		
		for(cscfga__Product_Configuration__c pc : pcList){
            if(pc.Name.equalsIgnoreCase('IP Site')){
                for(cscfga__Attribute__c att : pc.cscfga__Attributes__r){
                    if(att.name.equalsIgnoreCase('Site name')){
						sitemap.put(pc.id,att.cscfga__Value__c);
                    }
                    if(att.name.equalsIgnoreCase('Site Address')){
                       siteAddressMap.put(pc.id,att.cscfga__Value__c); 
                    }
					if(att.name.equalsIgnoreCase('ServiceabilityLocation')){
                        serviceabilityLocationMap.put(pc.id,att.cscfga__Value__c);
                    }
                    if(att.name.equalsIgnoreCase('ResponseTime')){
                       responseTimeMap.put(pc.id,att.cscfga__Value__c); 
                    }
                    if(att.name.equalsIgnoreCase('RestorationTime')){
                       restorationTimeMap.put(pc.id,att.cscfga__Value__c); 
                    }
                }
            }           
        }

           //US - 10811 
		if(!subfilters.isEmpty() && subfilters!=null ){
			List<cscfga__Attribute__c> pcattrList1 = [SELECT cscfga__Product_Configuration__c,Name,cscfga__Display_Value__c,cscfga__Value__c  FROM cscfga__Attribute__c WHERE cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c != null and cscfga__Product_Configuration__c IN :parentConfiguration LIMIT 5000];
        	System.debug('PCList:'+pcattrList1);  
            for(cscfga__Attribute__c att : pcattrList1){
                    if(att.name.equalsIgnoreCase('Site name')){
						sitemap.put(att.cscfga__Product_Configuration__c,att.cscfga__Value__c);
                    }
                    if(att.name.equalsIgnoreCase('Site Address')){
                       siteAddressMap.put(att.cscfga__Product_Configuration__c,att.cscfga__Value__c); 
                    }
					if(att.name.equalsIgnoreCase('ServiceabilityLocation')){
                        System.debug('here:'+att.cscfga__Value__c);
                        serviceabilityLocationMap.put(att.cscfga__Product_Configuration__c,att.cscfga__Value__c);
                        
                    }
                    if(att.name.equalsIgnoreCase('ResponseTime')){
                        System.debug('ResponseTime:'+att.cscfga__Value__c);
                       responseTimeMap.put(att.cscfga__Product_Configuration__c,att.cscfga__Value__c); 
                    }
                    if(att.name.equalsIgnoreCase('RestorationTime')){
                       restorationTimeMap.put(att.cscfga__Product_Configuration__c,att.cscfga__Value__c); 
                    }
                }
          }
          
        for(cscfga__Product_Basket__c pb : pbList){
            if(pb.Used_Snapshot_Objects__c != null) pb.Used_Snapshot_Objects__c = '';
            Set<String> usedSnapshotObjectSet = new Set<String>();
            for(cscfga__Product_Configuration__c pc : pcList){
           //     if(pc.cscfga__Parent_Configuration__c != null){
                System.debug('PC LIST 1'+pc+' Attribute size'+pc.cscfga__Attributes__r.size());
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
 						so.put('Site_Name__c',sitemap.containsKey(pc.cscfga__Parent_Configuration__c)?sitemap.get(pc.cscfga__Parent_Configuration__c):'');
						so.put('Site_Address__c',siteAddressMap.containsKey(pc.cscfga__Parent_Configuration__c)?siteAddressMap.get(pc.cscfga__Parent_Configuration__c):'');
                        
						//US-33959
                        so.put('Response_time__c',responseTimeMap.containsKey(pc.cscfga__Parent_Configuration__c)?responseTimeMap.get(pc.cscfga__Parent_Configuration__c):'');
                        so.put('Restoration_time__c',restorationTimeMap.containsKey(pc.cscfga__Parent_Configuration__c)?restorationTimeMap.get(pc.cscfga__Parent_Configuration__c):'');
                        so.put('Serviceability_Location__c',serviceabilityLocationMap.containsKey(pc.cscfga__Parent_Configuration__c)?serviceabilityLocationMap.get(pc.cscfga__Parent_Configuration__c):'');
                        //end US-33959
						
						so.put('Product_Module_Name__c',pc.cscfga__Description__c);
                        so.put('Term__c',String.valueOf(pc.cscfga__Contract_Term__c));
                         //US - 10811
                        so.put('Commercial_Config__c',pc.Commercial_Config__c);
                        System.debug('Commercial Config:'+pc.Commercial_Config__c+ ' and name:'+pc.Name);
                       
                        for(cscfga__Attribute__c att : pc.cscfga__Attributes__r){
                            Boolean firstRun = true;
                            String mappingField = att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c;
                            // Check Output Mapping Strategy set on custom setting
                            if(CS_Basket_Snapshot_Settings__c.getInstance().Output_Strategy__c == 'Attribute'){
                                so = targetType.newSObject();
                                so.put('Name','Snapshot: '+formattedDt);
                                if(pc.cscfga__Product_Basket__r.cscfga__Opportunity__c != null) so.put('Opportunity__c',pc.cscfga__Product_Basket__r.cscfga__Opportunity__c);
                                so.put('Product_Basket__c',pb.Id);
                                /* JIRA -EDGE-25920 -Enhance external basket snapshot to ensure we capture metadata needed for contract generation : Maq*/
                                so.put('Total_Contract_Value__c',pb.cscfga__total_contract_value__c);
                                so.put('Account_Owner__c',pb.cscfga__Opportunity__r.account.ownerid);
                                so.put('Primary_contact__c',primaryContactMap.get(pb.Id));
                              
                                so.put('Product_Configuration__c',pc.Id);
                                if(pc.cscfga__Parent_Configuration__c != null) so.put('Parent_Product_Configuration__c',pc.cscfga__Parent_Configuration__c);
                                if(pc.cscfga__Root_Configuration__c != null) so.put('Root_Product_Configuration__c',pc.cscfga__Root_Configuration__c);
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
                                   	/* JIRA -EDGE-25920 -Enhance external basket snapshot to ensure we capture metadata needed for contract generation : Maq*/
                                   	so.put('Total_Contract_Value__c',pb.cscfga__total_contract_value__c);
                                   	so.put('Account_Owner__c',pb.cscfga__Opportunity__r.account.ownerid);
                                    so.put('Primary_contact__c',primaryContactMap.get(pb.Id));
                                   
                                    so.put('Product_Configuration__c',pc.Id);
                                    if(pc.cscfga__Parent_Configuration__c != null) so.put('Parent_Product_Configuration__c',pc.cscfga__Parent_Configuration__c);
                                    if(pc.cscfga__Root_Configuration__c != null) so.put('Root_Product_Configuration__c',pc.cscfga__Root_Configuration__c);
                                    so.put('Product_Definition__c',pc.cscfga__Product_Definition__r.Id);
                                    if(pc.cscfga__Product_Definition__r.cscfga__Product_Category__c != null) so.put('Product_Category__c',pc.cscfga__Product_Definition__r.cscfga__Product_Category__c);
                                    firstRun = false;
                                }
                                	so.put('Product_Basket__c',pb.Id);
                                	/* JIRA -EDGE-25920 -Enhance external basket snapshot to ensure we capture metadata needed for contract generation : Maq*/
                                	so.put('Total_Contract_Value__c',pb.cscfga__total_contract_value__c);
                                	so.put('Account_Owner__c',pb.cscfga__Opportunity__r.account.ownerid);
                                	so.put('Primary_contact__c',primaryContactMap.get(pb.Id));
                                
                                	so.put('Product_Definition__c',pc.cscfga__Product_Definition__r.Id);
                                	Object value = getCorrespondingType(targetType, mappingField, att.cscfga__Value__c);
                                    so.put(mappingField, value);
                                if(CS_Basket_Snapshot_Settings__c.getInstance().Use_Field_Type_Conversion__c || Test.isRunningTest()){
                                    Object value1 = getCorrespondingType(targetType, mappingField, att.cscfga__Value__c);
                                    so.put(mappingField, value1);
                                } else so.put(mappingField, att.cscfga__Value__c);
                            }
                        }
                        // Check Output Mapping Strategy set on custom setting
                        if(CS_Basket_Snapshot_Settings__c.getInstance().Output_Strategy__c == 'Attribute')  lstReturn.addAll(soList);
                        // Check Output Mapping Strategy set on custom setting
                        else if(CS_Basket_Snapshot_Settings__c.getInstance().Output_Strategy__c == 'Product Configuration') lstReturn.add(so);
                        
                        usedSnapshotObjectSet.add(mappingObject);
                    }
                }
        //    }
        }
        }
        System.debug('lstReturn :'+lstReturn);
        return lstReturn;

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
            else if(fieldValue.equalsIgnoreCase('no')) return false;
            else if(fieldValue.equalsIgnoreCase('yes')) return true;
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