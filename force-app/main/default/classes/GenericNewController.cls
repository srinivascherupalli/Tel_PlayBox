/**
     Description :  P2OB-6525 Creating a generic component to launch any flow
     Author      :  Ritika Jaiswal, Team Hawaii 
     Created Date:  15 May 2020 
     Jira        :  P2OB-6525
 **/
public without sharing class  GenericNewController {
    @AuraEnabled
    public static String getCmpNameFromMetadata(String sObjectName, String pageType,String keyPrefix){
        system.debug('***Telstra:GenericNewController:getCmpNameFromMetadata:inputs:'+sObjectName+pageType+keyPrefix);
        String cmpName='';
        //Query on custom-metadata to find flowName
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('GenericComponentInvocation__mdt')) + '\n ' +
                          ' FROM GenericComponentInvocation__mdt \n ' +
                          ' WHERE ObjectName__c = \'' + String.escapeSingleQuotes(sObjectName) + '\' and PageType__c = \''+ String.escapeSingleQuotes(pageType) + '\' LIMIT 1 ';
        List<GenericComponentInvocation__mdt> genericComponentInvocationMDList = Database.query(queryStr);
        if(genericComponentInvocationMDList!= null && !genericComponentInvocationMDList.isEmpty() && genericComponentInvocationMDList.get(0) != null && genericComponentInvocationMDList.get(0).FlowName__c !=null){
            cmpName = genericComponentInvocationMDList.get(0).FlowName__c; 
            System.debug('***Telstra:GenericNewController:getCmpNameFromMetadata:cmpName:'+cmpName);
        }
        return cmpName;
    }
}