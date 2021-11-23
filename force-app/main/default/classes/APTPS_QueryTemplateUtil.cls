/*************************************************************************************************************************
 @Name: APTPS_QueryTemplateUtil
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This class is created for giving the template as per the defined query template
 @Used By: APTS_OneClickAgrmntGenerationController Controller 
*************************************************************************************************************************/

public class APTPS_QueryTemplateUtil {
    public Apttus__APTS_Agreement__c agreement {get; set;}
    public RecordType agreementRecordType {get; set;}
   
/*************************************************************************************************************************
 @Name: getTemplateByQueryTemplates
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This method returns the template Id as per the agreement record
*************************************************************************************************************************/
   public Id getTemplateByQueryTemplates(Id agreementId){
        //Populating agreement data
        agreement = APTPS_CommonUtilities.getAgreementData(agreementId);
        
        //Getting the record type
        agreementRecordType = [select Id, Name from RecordType where Id =:agreement.RecordTypeId];
        
        //Getting the applicable templates based on Query template
        Set<String> tempIds = getQueryTemplates();
        List<Apttus__APTS_Template__c> lstTemplates = new List<Apttus__APTS_Template__c>();
        
        if(tempIds.isEmpty()){
             lstTemplates = [SELECT Id, Name, Apttus__Guidance__c, Apttus__Category__c, Apttus__Subcategory__c, Apttus__Keywords__c, (Select Id,Name from Attachments)
                            FROM Apttus__APTS_Template__c WHERE Apttus__IsActive__c = true AND 
                            Apttus__Type__c = 'Agreement' AND
                            Apttus__Agreement_Types__c INCLUDES ('Default', :agreementRecordType.Name)];
                           
        }else{
        
            lstTemplates = [SELECT Id, Name, Apttus__Guidance__c, Apttus__Category__c, Apttus__Subcategory__c, Apttus__Keywords__c, (Select Id,Name from Attachments)
                            FROM Apttus__APTS_Template__c WHERE Apttus__IsActive__c = true AND 
                            Apttus__Type__c = 'Agreement' AND
                            Apttus__Agreement_Types__c INCLUDES ('Default', :agreementRecordType.Name) AND
                            Id IN :tempIds and Apttus__Category__c != 'Variation'];
           
        }
        
        //TODO: Discuss with Punit. Return just the first template ID
        if(lstTemplates.size() > 0)
        {
            return lstTemplates[0].Id;
        }
        
        return null;
    }
  
/*************************************************************************************************************************
 @Name: getTemplateByQueryTemplates
 @Author: Shishir Bose
 @Created Date: 03/06/2017
 @Descripton: This method returns the templates as per the agreement record
*************************************************************************************************************************/
   public List<Apttus__APTS_Template__c> getAllTemplatesByQueryTemplates(Id agreementId){
        //Populating agreement data
        agreement = APTPS_CommonUtilities.getAgreementData(agreementId);
        
        //Getting the record type
        agreementRecordType = [select Id, Name from RecordType where Id =:agreement.RecordTypeId];
        
        //Getting the applicable templates based on Query template
        Set<String> tempIds = getQueryTemplates();
        List<Apttus__APTS_Template__c> lstTemplates = new List<Apttus__APTS_Template__c>();
        
        
        if(tempIds.isEmpty()){
             lstTemplates = [SELECT Id, Name, Apttus__Guidance__c, Apttus__Category__c, Apttus__Subcategory__c, Apttus__Keywords__c, (Select Id,Name from Attachments)
                            FROM Apttus__APTS_Template__c WHERE Apttus__IsActive__c = true AND 
                            Apttus__Type__c = 'Agreement' AND
                            Apttus__Agreement_Types__c INCLUDES ('Default', :agreementRecordType.Name)];
                           
        }else{
        
            lstTemplates = [SELECT Id, Name, Apttus__Guidance__c, Apttus__Category__c, Apttus__Subcategory__c, Apttus__Keywords__c, (Select Id,Name from Attachments)
                            FROM Apttus__APTS_Template__c WHERE Apttus__IsActive__c = true AND 
                            Apttus__Type__c = 'Agreement' AND
                            Apttus__Agreement_Types__c INCLUDES ('Default', :agreementRecordType.Name) AND
                            Id IN :tempIds];
        }
        
        //TODO: Discuss with Punit. Return just the first template ID
        if(lstTemplates.size() > 0)
        {
            return lstTemplates;
        }
        
        return null;
    }  
 /*************************************************************************************************************************
 @Name: getQueryTemplates
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This method returns the template Id's for the applicable query templates
*************************************************************************************************************************/
    private Set<String> getQueryTemplates(){
        
        Set<String> qualifierFields = new Set<String>();
        Set<String> templatesId = new Set<String>();
        System.debug('getQueryTemplates ----->>>>>');
        
        //Get the query template and qualifier data for Agreement Query Templates
        Map<Id, Apttus__QueryTemplate__c> mapQueryTemplates = new Map<Id, Apttus__QueryTemplate__c>(
                                                            [SELECT Id, Name, (SELECT Id, Name, Apttus__SObjectType__c, Apttus__Field__c,
                                                             Apttus__CompOper__c, Apttus__Value__c
                                                             FROM Apttus__QueryTemplateQualifiers__r
                                                             WHERE Apttus__SObjectType__c = 'Apttus__APTS_Agreement__c')
                                                             FROM Apttus__QueryTemplate__c
                                                             WHERE Apttus__Active__c = true AND 
                                                             Apttus__SObjectLabel__c = 'Agreement Template' AND
                                                             Apttus__Type__c = 'Agreement Template Filter' 
                                                             ORDER BY Apttus__Sequence__c]);
                                                             
        System.debug('mapQueryTemplates ----->>>>>'+mapQueryTemplates);                                                  
        
        //Creating the list of fields to be used by the qualifier for agreement filtering                                                     
        for(Apttus__QueryTemplate__c qTemplate : mapQueryTemplates.values()){
            
            for(Apttus__QueryTemplateQualifier__c qualifier : qTemplate.Apttus__QueryTemplateQualifiers__r){
                
                qualifierFields.add(qualifier.Apttus__Field__c);
            }
        }
        System.debug('qualifierFields ----->>>>>'+qualifierFields);     
        
        String agreementId = agreement.Id;
        List<String> temp = new List<String>(qualifierFields);
        Set<Id> qualifiedTemplates = new Set<Id>();
        Set<Id> disQualifiedTemplates = new Set<Id>();
        Set<String> filterSobjectNames = new Set<String>();
        
        List<sObject> lstTempaltes = getTemplates();
        List<sObject> lstTemplatesIteration = new List<sObject>();
        lstTemplatesIteration = lstTempaltes;
        List<sObject> lstTemplatesToBeFilledForNextIteration = new List<sObject>();
        System.debug('lstTemplatesIteration ----->>>>>'+lstTemplatesIteration);        
                
        for(Apttus__QueryTemplate__c qTemplate : mapQueryTemplates.values()){
            
            Boolean isQualified = true;
           
            for(Apttus__QueryTemplateQualifier__c qualifier : qTemplate.Apttus__QueryTemplateQualifiers__r){
               
                filterSobjectNames.add(qualifier.Apttus__SObjectType__c);
                
                //Get the agreement field value that is used by qualifier
                String val = getSobjectFieldValue(agreement, qualifier.Apttus__Field__c);
                System.debug('val ----->>>>>'+val);
                //Perform appropriate operation on the Agreement field value and Qualifier value based on qualifier selected operation
                if(!matchExpression(val, qualifier.Apttus__CompOper__c, qualifier.Apttus__Value__c)){
                    isQualified = false;
                    break;
                }
            }
            System.debug('filterSobjectNames ----->>>>>'+filterSobjectNames);            
            System.debug('isQualified ----->>>>>'+isQualified);
            
            //Make a list of applicable query templates
            if(isQualified){
                 //If the Query template is qualified match the template filters
                lstTemplatesIteration = new List<sObject>();
                lstTemplatesIteration = lstTempaltes;
                lstTemplatesToBeFilledForNextIteration = new List<sObject>();
                
                /*****************************************************************************************************************************************/
                /*****************************************************************************************************************************************/
                
                Map<Id, sobject> andOperatorTemplates = new Map<Id, sobject>();
                Map<Id, sobject> orOperatorTemplates = new Map<Id, sobject>();
                for(Apttus__QueryTemplateFilter__c filter : [SELECT Id, Name, Apttus__Field__c, Apttus__Value__c, Apttus__CompOper__c,
                                                    Apttus__BooOper__c
                                                    FROM Apttus__QueryTemplateFilter__c
                                                    WHERE Apttus__QueryTemplate__c = :qTemplate.Id
                                                    ORDER BY Apttus__Sequence__c]){
                
                System.debug('filter1 ----->>>>>'+filter);
                    
                    string booleanOperator = filter.Apttus__BooOper__c;
                    System.debug('booleanOperator ----->>>>>'+booleanOperator);
                    
                    if(filter.Apttus__BooOper__c == 'AND')
                    {   
                        lstTemplatesToBeFilledForNextIteration = new List<sobject>();
                        andOperatorTemplates = new Map<Id, sobject>();
                        System.debug('lstTemplatesIteration1 ----->>>>>'+lstTemplatesIteration);
                        for(sObject template : lstTemplatesIteration) 
                        {
                            System.debug('filter.Apttus__Field__c ----->>>>>'+filter.Apttus__Field__c);
                            System.debug('filter.Apttus__CompOper__c ----->>>>>'+filter.Apttus__CompOper__c);
                            if(template.get(filter.Apttus__Field__c) != null && filter.Apttus__CompOper__c != null){
                                //Check if the value contains a Sobject Reference
                                String filterValStr;
                                
                                //Getting the Template field data to be compared
                                System.debug('filter.Apttus__Value__c ----->>>>>'+filter.Apttus__Value__c);
                                if(filter.Apttus__Value__c.contains('.')){
                                    String fieldAPIName = filter.Apttus__Value__c.substring(filter.Apttus__Value__c.indexOf('.')+1,filter.Apttus__Value__c.length());
                                    System.debug('fieldAPIName ----->>>>>'+fieldAPIName);
                                    if(agreement.get(fieldAPIName) != null){
                                        filterValStr = String.valueOf(agreement.get(fieldAPIName));
                                    }
                                    
                                }else{
                                    filterValStr = filter.Apttus__Value__c;
                                }
                                System.debug('filterValStr ----->>>>>'+filterValStr);
                                //Comparing the template data with the query template filter
                                boolean testBollean = matchExpression(String.valueOf(template.get(filter.Apttus__Field__c)), filter.Apttus__CompOper__c, filterValStr);
                                System.debug('testBollean ----->>>>>'+testBollean);
                                if(matchExpression(String.valueOf(template.get(filter.Apttus__Field__c)), filter.Apttus__CompOper__c, filterValStr)){
                                    //Create the list of filtered templates for subsequent iteration if any
                                    System.debug('template ----->>>>>'+template);
                                    System.debug('template.Id ----->>>>>'+template.Id);
                                    lstTemplatesToBeFilledForNextIteration.add(template);
                                    andOperatorTemplates.put(template.Id, template);
                                }
                            }
                            
                        }
                        //Creating the list of templates selected in the current iteration
                        //Note all the filters of query template should match to select the template. So if the first one fails do not include for
                        //subsequent iteration
                        lstTemplatesIteration = lstTemplatesToBeFilledForNextIteration;
                                                            
                    }       
                    else if(filter.Apttus__BooOper__c == 'OR')
                    {   
                        lstTemplatesIteration = lstTempaltes;
                        for(sObject template : lstTemplatesIteration) 
                        {
                            if(template.get(filter.Apttus__Field__c) != null && filter.Apttus__CompOper__c != null){
                                //Check if the value contains a Sobject Reference
                                String filterValStr;
                                
                                //Getting the Template field data to be compared
                                if(filter.Apttus__Value__c.contains('.')){
                                    String fieldAPIName = filter.Apttus__Value__c.substring(filter.Apttus__Value__c.indexOf('.')+1,filter.Apttus__Value__c.length());
                                
                                    if(agreement.get(fieldAPIName) != null){
                                        filterValStr = String.valueOf(agreement.get(fieldAPIName));
                                    }
                                    
                                }else{
                                    filterValStr = filter.Apttus__Value__c;
                                }
                                //Comparing the template data with the query template filter
                                boolean testBollean = matchExpression(String.valueOf(template.get(filter.Apttus__Field__c)), filter.Apttus__CompOper__c, filterValStr);
                                
                                if(matchExpression(String.valueOf(template.get(filter.Apttus__Field__c)), filter.Apttus__CompOper__c, filterValStr)){
                                    //Create the list of filtered templates for subsequent iteration if //any                                   
                                    if(!orOperatorTemplates.containsKey(template.Id))
                                    {
                                        orOperatorTemplates.put(template.Id, template);
                                    }
                                }
                            }
                            
                        }
                        
                                                            
                    }   
                }
                
                for(Id tempId : andOperatorTemplates.keySet())
                {
                    if(!orOperatorTemplates.containsKey(tempId))
                    {
                        orOperatorTemplates.put(tempId, andOperatorTemplates.get(tempId));
                    }
                }
                //Create list of qualified templates
                for(Id sObjectId : orOperatorTemplates.keySet())
                {
                    templatesId.add(sObjectId);
                }
                
                
                
                /*****************************************************************************************************************************************/
                /*****************************************************************************************************************************************/
                
            }
        }
        
        return templatesId;    
    }
    
   /*************************************************************************************************************************
 @Name: getSobjectFieldValue
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This method returns the field values for the object
*************************************************************************************************************************/
     private String getSobjectFieldValue(sObject obj, String field){
        
        if(field.contains('.')){
            list<string> tempLst = field.split('\\.');
            return String.valueOf(obj.getSobject(tempLst[0]).get(tempLst[1]));
        }
        return String.valueOf(obj.get(field));
    }
    
    /*************************************************************************************************************************
 @Name: matchExpression
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This method is used for performing operations betweeb two values
*************************************************************************************************************************/
    public Boolean matchExpression(String qualiferValue, String compOperator, String comprisonValue){

       if(comprisonValue == null)
       {
         return false;   
       }
       
        if(compOperator == 'equal to')
            return qualiferValue == comprisonValue;
            
        else if(compOperator == 'not equal to')
            return qualiferValue != comprisonValue;
            
        else if(compOperator == 'less than')
            return qualiferValue < comprisonValue;
        
        else if(compOperator == 'less than or equal to')
            return qualiferValue <= comprisonValue;
        
        else if(compOperator == 'greater than')
            return qualiferValue > comprisonValue;
        
        else if(compOperator == 'greater than or equal to')
            return qualiferValue >= comprisonValue;
        
        else if(compOperator == 'in')
            return qualiferValue.contains(comprisonValue);
        
        else if(compOperator == 'not in')
            return !qualiferValue.contains(comprisonValue);
        
        else if(compOperator == 'like')
            return qualiferValue.contains(comprisonValue);
        
        else if(compOperator == 'not like')
            return !qualiferValue.contains(comprisonValue);
        
        else if(compOperator == 'includes')
            return qualiferValue.contains(comprisonValue);
        
        else if(compOperator == 'excludes')
            return !qualiferValue.contains(comprisonValue);
        
        else if(compOperator == 'starts with')
            return qualiferValue.startsWith(comprisonValue);
        
        else if(compOperator == 'contains')
            return qualiferValue.contains(comprisonValue);

        else if(compOperator == 'does not contain')
            return !qualiferValue.contains(comprisonValue);
            
        else
            return false;
    }
    
   
    
    
    /*************************************************************************************************************************
 @Name: getTemplates
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This method is used for getting all the field of template object
*************************************************************************************************************************/
    private List<Apttus__APTS_Template__c> getTemplates()
    {
        // Initialize setup variables
        String objectName = 'Apttus__APTS_Template__c';  
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
        }
      
        
        query = query.subString(0,query.Length()-2);
        // Add FROM statement
        query += ' FROM ' + objectName;
        
        query += ' where  Apttus__Type__c = \'Agreement\'';
        
       
          List<Apttus__APTS_Template__c> templates = database.query(query);
                return templates;
    }
   
}