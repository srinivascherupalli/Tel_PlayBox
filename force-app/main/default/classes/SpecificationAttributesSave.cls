/* Class Name: SpecificationAttributesSave

ChagneSet No    Name            Date                    Description
CH-1            Rohit         11/15/2018              EDGE-51344  ( apex script to automatically map attributes in Specifications) 
Spring 20       Sandeep Y       18/08/2020              SM Spirng package upgrade csedm__Product_Definition__c is deprecated use new field csedm__Source__c          
*/
public with sharing class SpecificationAttributesSave {
    
Public Static List<csedm__Specification__c> lstSpecification = new List<csedm__Specification__c> ();
    
    public static List<csedm__Specification__c> specRecordResult() {
        system.debug('Inside specRecordResult>>');
        if(lstSpecification.isEmpty()){
            system.debug('Inside lstSpecification>>');
            lstSpecification = [SELECT External_Id__c, csedm__Value__c 
                                FROM csedm__Specification__c WHERE csedm__Active__c = true 
                                //AND csedm__Product_Definition__c != NULL AND External_Id__c != NULL]; // Spring 20 commented
                                AND csedm__Source__c != NULL AND External_Id__c != NULL];  // Spring 20
        }
        
        return lstSpecification;
    }
    
    public static void SpecificationAttributes() {
        List <Specification_Value_BKP__c> specObjList = new List <Specification_Value_BKP__c> ();
        for (csedm__Specification__c specRecord: specRecordResult()) {
            Specification_Value_BKP__c specObj = new Specification_Value_BKP__c();
            specObj.Ext_Id__c = specRecord.External_Id__c;
            specObj.Value__c = specRecord.csedm__Value__c;
            specObjList.add(specObj);
        }
        system.debug('Inside specObjList>>' + specObjList);
        if (specObjList != null && !specObjList.isEmpty()) {
            upsert specObjList Ext_Id__c;
        }
    }
    
    public static Map<String, String> getSpecificationAttributes() {
        map<String, String> mapSpecValue = new Map<String,String>();
        List <Specification_Value_BKP__c> specObjList = new List <Specification_Value_BKP__c> ();
        for (csedm__Specification__c specRecord: specRecordResult()) {
            Specification_Value_BKP__c specObj = new Specification_Value_BKP__c();
            specObj.Ext_Id__c = specRecord.External_Id__c;
            specObj.Value__c = specRecord.csedm__Value__c;
            specObjList.add(specObj);
            mapSpecValue.put(specObj.Ext_Id__c, specObj.Value__c);
        }
        system.debug('Inside specObjList>>' + specObjList);
        if (specObjList != null && !specObjList.isEmpty()) {
            upsert specObjList Ext_Id__c;
        }
        return mapSpecValue;
    }
    
    public static void SpecificationUpdate() {
        
		system.debug(Logginglevel.ERROR ,'Inside SpecificationUpdate>>>>>>>>');
            
        Map<String,String> specMap = new Map<String,String> ();
        for (Specification_Value_BKP__c objCS: [SELECT Ext_Id__c, Value__c FROM Specification_Value_BKP__c
                                               WHERE Ext_Id__c != NULL]) {
                                                    specMap.put(objCS.Ext_Id__c, objCS.Value__c);
        }
        List<csedm__Specification__c> specRecord = new List<csedm__Specification__c>();
        if(!specMap.isEMpty()){
            for (csedm__Specification__c eachRecord: specRecordResult()) {   
                if (specMap.containsKey(eachRecord.External_Id__c)) {
                    eachRecord.csedm__Value__c = specMap.get(eachRecord.External_Id__c);
                    specRecord.add(eachRecord);
                }
            }
        }
        system.debug(Logginglevel.ERROR ,'Inside specRecord>>>>>>>>' + specRecord);
        if(specRecord != null && !specRecord.isEmpty()){
            update specRecord;
        }
    }
}