/*
** @Author   :   Maqsood Alam
** @Date     :   June 2020
** @Desc     :   Class to Capture all the environment Vairable
**
*/
public with sharing class AllCQEnvironmentVariable {
    public static Map < String,  Q_C_Environment_Variable__mdt> qNcEnvironmentVariable = new Map < String,  Q_C_Environment_Variable__mdt > ();

    public AllCQEnvironmentVariable() {
        // Fetch custom metadata value ----
        for (Q_C_Environment_Variable__mdt qNcEnvironmentVar: [SELECT Key__c, Label, Reference__c, Value__c, DeveloperName FROM Q_C_Environment_Variable__mdt where IsActive__c= true]) {
            qNcEnvironmentVariable.put(qNcEnvironmentVar.Key__c, qNcEnvironmentVar);
        }
        system.debug('qNcEnvironmentVariable##11' + qNcEnvironmentVariable);
        system.debug('qNcEnvironmentVarMapMain#######>>>>>************* qNcEnvironmentVarMapMain: ' + JSON.serialize(qNcEnvironmentVariable));
    }

    public static list < String > getValueAsList(String keyVariable) {
        system.debug('keyVariable@@::' + keyVariable);
        if(keyVariable == null || keyVariable == '')
        return null;
        system.debug('qNcEnvironmentVariable@@::' + qNcEnvironmentVariable);
        //system.debug('qNcEnvironmentVariable.get(keyVariable)@@::' + qNcEnvironmentVariable.get(keyVariable) +'@@::'+ qNcEnvironmentVariable.get(keyVariable).Value__c);
        if(qNcEnvironmentVariable.get(keyVariable) != null && qNcEnvironmentVariable.get(keyVariable).Value__c != ''){
            return qNcEnvironmentVariable.get(keyVariable).Value__c.split(',');
            //system.debug('qNcEnvironmentVariable.get(keyVariable).Value__c.spli' + qNcEnvironmentVariable.get(keyVariable).Value__c.split(','));
        }         
        return null;
}

public static set < String > getValueAsSet(String keyVariable) {
    if(keyVariable == null || keyVariable == '')
    return null;
    if(qNcEnvironmentVariable.get(keyVariable) != null && qNcEnvironmentVariable.get(keyVariable).Value__c != ''){
        return  new Set<String>(qNcEnvironmentVariable.get(keyVariable).Value__c.split(',')) ;
    }         
    return null;
}
}