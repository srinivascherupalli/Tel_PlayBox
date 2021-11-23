/* ****************************************************************************
* Class Name    : UpdateServiceAndSpecs
* Author        : Ankit Goswami : EDGE-143015 New
* Date          : 22 may 2020
* Description   : update specs, service obj and number obj via Phython Script
* TestClass     : UpdateServiceAndSpecsTest 
* *****************************************************************************/
public without sharing class UpdateServiceAndSpecs {
/****************************************************************************************************
* Method Name : UpdateServiceObject
* Description : Update Service object field
* Parameters  : Map<string,map<string,string>>  -   inputMap passed from the python script
* Return      : void     
* Devloper    : Ankit Goswami 
****************************************************************************************************/
    public static void UpdateServiceObject(Map<string,map<string,string>>ScriptMap) {
    system.debug('Inside Method'+ScriptMap);
      list<csord__Service__c> serviceList=new  list<csord__Service__c> ();
      set<id> serviceIdset=new  set<id> ();
      map<string,string>specMap=new map<string,string>();
       for (csord__Service__c serviceatt:[select id,Sim_Serial_Number__c,csordtelcoa__Service_Number__c from csord__Service__c where csordtelcoa__Service_Number__c IN : ScriptMap.keySet()]){
           if(ScriptMap.containsKey(serviceatt.csordtelcoa__Service_Number__c)){
                serviceatt.Sim_Serial_Number__c=ScriptMap.get(serviceatt.csordtelcoa__Service_Number__c).get('SIMSerialNumber');
                serviceList.add(serviceatt);
                serviceIdset.add(serviceatt.id);
                specMap.put(ScriptMap.get(serviceatt.csordtelcoa__Service_Number__c).get('guid'),ScriptMap.get(serviceatt.csordtelcoa__Service_Number__c).get('SIMSerialNumber'));
            }   
        }
        if(!serviceList.isEmpty()){
            update serviceList;
        }
        string IMSINumber=UpdateServiceSpecs(serviceIdset,specMap);
        UpdateNumberObject(ScriptMap,IMSINumber);
    }
    /****************************************************************************************************
    * Method Name : UpdateServiceAndSpecs
    * Description : Update Service specs
    * Parameters  : set<id>,Map<string,string>  -   inputMap passed from the UpdateServiceObject method
    * Return      : string 
    * Devloper    : Ankit Goswami 
    ****************************************************************************************************/
    public static string UpdateServiceSpecs(set<id>serviceIdset,Map<string,string>GuidMap){
        string IMSINumber;
        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE parentId IN : serviceIdset AND name = 'ServiceSpecifications.json'];
        for(Attachment att: atts){
            String attbody = String.valueOf(att.body.toString());
                List<Script_AttributeSpecsDTO.ServiceScriptSpecification > specs = Script_AttributeSpecsDTO.parseSpec(attbody);
                for(Script_AttributeSpecsDTO.ServiceScriptSpecification spec: specs){
                    Map<String, String> additionalAttrs = new Map<String, String>();
                        if(GuidMap.ContainsKey(spec.guid)){
                            additionalAttrs.put('SIMSerialNumber', GuidMap.get(spec.guid));
                            IMSINumber=spec.attributes.IMSI;   
                            if(!additionalAttrs.isEmpty()) {
                                System.debug('spec.serviceId, spec.guid::'+spec.serviceId + ' --- '+spec.guid+'--'+additionalAttrs);
                                csedm.API_1.addCharacteristic(spec.serviceId, spec.guid, additionalAttrs);
                            }
                        }
                }
        }
        return IMSINumber;
    }
     /****************************************************************************************************
    * Method Name : UpdateNumberObject
    * Description : Update number object field
    * Parameters  : Map<string,map<string,string>>,string-inputMap passed from the python script and string from UpdateServiceAndSpecs
    * Return      : void     
    * Devloper    : Ankit Goswami 
    ****************************************************************************************************/
    public static void UpdateNumberObject(map<String,Map<String,String>> ServiceNumberMap,string IMSINumber) {
        list<Number__c> NumberList=new  list<Number__c> ();
         for (Number__c Numberatt:[select id,Sim_Serial_Number__c,Service_Id__c,IMSI__c,Service_Number__c from Number__c where Service_Id__c IN : ServiceNumberMap.keyset()]){
           if(ServiceNumberMap.containsKey(Numberatt.Service_Id__c)){
                Numberatt.Sim_Serial_Number__c=ServiceNumberMap.get(Numberatt.Service_Id__c).get('SIMSerialNumber');
                if(!String.isBlank(IMSINumber)){
                    Numberatt.IMSI__c=IMSINumber;
                }
                NumberList.add(Numberatt);
            }   
        }
        if(!NumberList.isEmpty()){
            update NumberList;
        }
    }
}