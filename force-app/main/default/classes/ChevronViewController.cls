public with sharing class ChevronViewController {
    @AuraEnabled
    public static String getChevronData(String recId,String fieldName){  
         System.debug('recId:: '+recId);
           System.debug('fieldName:: '+fieldName);
         System.debug('in getChevronData ');
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        List<chevronData> lstRet = new List<chevronData>();
        Map<String,String> objectMap = new Map<String,String>();
        
        Map<String,Provisioning_Stage__mdt> stageAttMap=new Map<String,Provisioning_Stage__mdt>();
            
        String queryStageMdtStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Provisioning_Stage__mdt')) + '\n ' +
                          ' FROM Provisioning_Stage__mdt \n ';
        List<Provisioning_Stage__mdt> stageAttrRecordList = Database.query(queryStageMdtStr); 
        if(stageAttrRecordList == null || stageAttrRecordList.isEmpty()){
            System.debug('No stage settings found.');
           
        } else if(!stageAttrRecordList.isEmpty()){
            for(Provisioning_Stage__mdt stageAtt: stageAttrRecordList){
                stageAttMap.put(stageAtt.Sequence__c, stageAtt);
            }
    
        }
        system.debug('=====stageAtt-===='+stageAttMap.keyset());
        
        for(Schema.SObjectType f : gd)
        {
             objectMap.put(f.getDescribe().getKeyPrefix(), f.getDescribe().getName());
        }
        System.debug('objectMap:: '+objectMap);
        String prefix =  recId.left(3); 
         System.debug('prefix:: '+prefix);
        String objectName = objectMap.get(prefix);
        String selVal = null;
        List<String> stageValue = new List<String>();
        Map<String, String> stageNotifiMap = new Map<String, String>();        
        if(objectName == 'csord__Order__c'){
            String query = 'SELECT '+String.escapeSingleQuotes(fieldName)+' ,csord__Order_Request__c, csord__Primary_Order__c,csordtelcoa__Opportunity__c FROM '+String.escapeSingleQuotes(objectName)+' WHERE Id =: recId';
            System.debug('query:: '+query);
            List<SOBject> lstObj = Database.query(query);   
            System.debug('lstObj:: '+lstObj);
            selVal =  String.valueOf(lstObj[0].get('csord__Primary_Order__c')) ;    
            System.debug('selVal:: '+selVal);
            if(selVal != null && selVal!='' && selVal!=' '){
                return JSON.serialize(lstRet);
            }else {
                selVal =  String.valueOf(lstObj[0].get(fieldName));
                String orderRequestId =  String.valueOf(lstObj[0].get('csordtelcoa__Opportunity__c')) ;
                
                List<csord__Service__c> serviceList = [SELECT Id, Name, csord__Status__c, csord__Subscription__c, csord__Order__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,
                                                               (Select Id, Name,GUID__c, Service__c FROM Service_Specifications__r)
                                                               FROM csord__Service__c
                                                               WHERE csord__Order__r.csordtelcoa__Opportunity__c  = :orderRequestId Order By CreatedDate];
                

                stageValue = getSubStageList(serviceList, fieldName, stageAttMap);               
            }
        }
        else if(objectName == 'csord__Subscription__c'){
           String query = 'SELECT '+String.escapeSingleQuotes(fieldName)+' FROM '+String.escapeSingleQuotes(objectName)+' WHERE Id =: recId';
            System.debug('query:: '+query);
           List<SOBject> lstObj = Database.query(query);
           System.debug('lstObj:: '+lstObj);
           selVal =  String.valueOf(lstObj[0].get(fieldName)) ;

            List<csord__Service__c> serviceList = [SELECT Id, Name, csord__Status__c, csord__Subscription__c, csord__Order__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,
                                                              (Select Id, Name,GUID__c, Service__c FROM Service_Specifications__r)
                                                              FROM csord__Service__c
                                                              WHERE csord__Subscription__c  = :recId Order By CreatedDate];


           stageValue = getSubStageList(serviceList, fieldName, stageAttMap); 
        }else if(objectName == 'csord__Service__c'){
            String query = 'SELECT '+String.escapeSingleQuotes(fieldName)+' FROM '+String.escapeSingleQuotes(objectName)+' WHERE Id =: recId';
            System.debug('query:: '+query);
           List<SOBject> lstObj = Database.query(query);
           System.debug('lstObj:: '+lstObj);
           selVal =  String.valueOf(lstObj[0].get(fieldName)) ;
            List<csord__Service__c> serviceList = [SELECT Id, Name, csord__Status__c, csord__Subscription__c, csord__Order__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,
                                                               (Select Id, Name,GUID__c, Service__c FROM Service_Specifications__r)
                                                               FROM csord__Service__c
                                                               WHERE Id =: recId Order By CreatedDate];
                                                               
            stageValue = getSubStageList(serviceList, fieldName, stageAttMap); 
            if(fieldName == 'substage__c'){
                List<Id> serviceSpecIds = new list<Id>();
                for(csord__Service__c srv :  serviceList)
                {
                    for(Service_Specification__c servcList : srv.Service_Specifications__r){
                        serviceSpecIds.add(servcList.Id);
                    }
                }
                
                List<subStageNotification__c> stageNotification  = [Select Name,Id,Substage_Completion_Date__c from subStageNotification__c where Service_Specification__c IN: serviceSpecIds order by Substage_Completion_Date__c desc];
                
                for(subStageNotification__c stageNotif : stageNotification){
                    if(!stageNotifiMap.containsKey(stageNotif.Name)){
                    stageNotifiMap.put(stageNotif.Name,string.valueOf(stageNotif.Substage_Completion_Date__c));
                    }
                }
                system.debug('stageNotification'+stageNotification);
            }
        }
        
        System.debug('selVal:: '+selVal);
        System.debug('stageValue:: '+stageValue);
       
        Boolean curValMatched = false;
        Integer widthPerItem = 100/stageValue.size() ;
                
        for( String f : stageValue)
        {
            String helptexts = f;
            if(f.containsIgnoreCase('Product Requirements Validation')){
                helptexts = stageAttMap.get('1').MasterLabel + '-- '+f;
            }
            else if(f.containsIgnoreCase('Product Preparation') || f.containsIgnoreCase('Site Visit and Installation') || f.containsIgnoreCase('Product Activation and Testing')) {
                helptexts =stageAttMap.get('2').MasterLabel + '-- '+f; 
            }
            else if(f.containsIgnoreCase('Customer Order Acceptance')){
                helptexts = stageAttMap.get('3').MasterLabel+ '-- '+f; 
            }
            else if(f.containsIgnoreCase('Product Completion Notice')) {
                helptexts = stageAttMap.get('4').MasterLabel+ '-- '+f; 
            }
            
            chevronData obj = new chevronData();
            obj.val = f;
            obj.width = widthPerItem+'%';            
            if(obj.val == selVal){
                obj.cssClass = 'active';
                curValMatched = true;
            }
            else if(curValMatched){
                obj.cssClass = '';
            }else if(selVal == null || selVal == ''){
                 obj.cssClass = '';
            }else{
                obj.cssClass = 'visited'; 
                if(stageNotifiMap.containsKey(f)){
                    obj.helptext = helptexts+'-- '+stageNotifiMap.get(f);
                }else{
                    obj.helptext = helptexts;
                }
            } 
            lstRet.add(obj);
        } 
        System.debug('lstRet:: '+lstRet);
        return JSON.serialize(lstRet);
    }    
    public class chevronData{
        public String val{get;set;}
        public String cssClass{get;set;}
        public String width {get;set;}
        public String helptext{get;set;}
    }
    
    public static List<String> getSubStageList(List<csord__Service__c> serviceList, String fieldAPIName, Map<String,Provisioning_Stage__mdt> stageAttMap){
        
            Set<String> parentIds = new Set<String>();                                                 
            for(csord__Service__c srv :  serviceList)
            {
                List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(srv.Id),'FULFILMENT');
                system.debug('srvspecList:::' + srvspecList);
                for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList)
                    {
                        if(srvSpec.additionalAttributes.size()!=0){
                            for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                                system.debug('attr===='+attr+'----='+attr.name);
                                if(attr.name != 'parentSpec'){
                                        parentIds.add(srvSpec.code.removeEnd('_Fulfilment'));
                                }            
                                }
                                
                                
                        }
                    }
            }
            
            system.debug('parentIds:::: '+parentIds);
            
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.substage_matrix__mdt.fields.getMap();
            List<String> fieldLabelMap = new List<String>();
            Map<String,String> fieldNameMap = new Map<String,String>();
            string fieldNames = '';
            for(String fieldName: fieldMap.keySet()) {
                fieldLabelMap.add(fieldName);
                fieldNameMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
                if(fieldNames == ''){
                    fieldNames = fieldName + ',';
                }else{
                    fieldNames = fieldNames +fieldName+ ',';
                }
                            
            }
            system.debug('fieldNameMap:: '+fieldNameMap);
            fieldNames = fieldNames.removeEnd(',');
            system.debug('fieldNames:: '+fieldNames);
            String qry = 'Select '+ String.escapeSingleQuotes(fieldNames) + ' from Substage_Matrix__mdt where DeveloperName IN :parentIds ';
                        System.debug('qry::' + qry);
            List<Substage_Matrix__mdt> subStageMatrixList = Database.Query(qry);
            system.debug('subStageMatrixList::: '+subStageMatrixList);
            List<String> stageList = new List<String>();
            List<WrapperCompare> testadd = new List<WrapperCompare>();
             for(Substage_Matrix__mdt subStageMatrix : subStageMatrixList) {
                for(String key : fieldNames.split(','))
                {
                    
                    if(subStageMatrix.get(key)== true){
                        system.debug(subStageMatrix.get(key) +'key=='+key);
                        WrapperCompare test0 = new WrapperCompare(fieldNameMap.get(key));
                        testadd.add(test0);
                    }
                    
                }          
            }
            if(!testadd.isEmpty()){
                testadd.sort();
            }
            system.debug('testadd::: '+testadd);
            Set<String> stageValueSet = new Set<String>();
            List<String> stage = new List<String>();
            
            Set<String> setSubStage = new Set<String>();
            List<String> finalSubStage = new List<String>();
            for(WrapperCompare subStageName : testadd){
                if(subStageName.order != -1){
                   stageList.add(subStageName.sob);
                   if(setSubStage.add(subStageName.sob)){
                    finalSubStage.add(subStageName.sob);
                  }
                }
            }

            for(String stages : finalSubStage){
                    stageList.add(stages);
                    system.debug('stages::: '+stages);
                    if(stages.containsIgnoreCase('Product Requirements Validation')){
                        stageValueSet.add(stageAttMap.get('1').MasterLabel);
                    }
                    else if(stages.containsIgnoreCase('Product Preparation') || stages.containsIgnoreCase('Site Visit and Installation') || stages.containsIgnoreCase('Product Activation and Testing')) {
                        stageValueSet.add(stageAttMap.get('2').MasterLabel); 
                    }
                    else if(stages.containsIgnoreCase('Customer Order Acceptance')){
                        stageValueSet.add(stageAttMap.get('3').MasterLabel); 
                    }
                    else if(stages.containsIgnoreCase('Product Completion Notice')) {
                        stageValueSet.add(stageAttMap.get('4').MasterLabel); 
                    }
            }

            system.debug(stageList);
            system.debug('stageList:::: '+stageList);
            
            system.debug('stageValueSet:::: '+stageValueSet);
            
            if(stageValueSet.contains(stageAttMap.get('1').MasterLabel)){
                    stage.add(stageAttMap.get('1').MasterLabel);
                } 
                if(stageValueSet.contains(stageAttMap.get('2').MasterLabel)){
                    stage.add(stageAttMap.get('2').MasterLabel);
                } 
                if(stageValueSet.contains(stageAttMap.get('3').MasterLabel)){
                    stage.add(stageAttMap.get('3').MasterLabel);
                } 
                if(stageValueSet.contains(stageAttMap.get('4').MasterLabel)){
                    stage.add(stageAttMap.get('4').MasterLabel);
                }
            
            if(fieldAPIName == 'stage__c'){
                return stage; 
            }else{
                return finalSubStage;
            }
            
      }
}