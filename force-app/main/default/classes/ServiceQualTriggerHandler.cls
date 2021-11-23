/********************************************************************/
// Name:    ServiceQualTriggerHandler
// Description: EDGE-84619 Update the SQ Results Record with Flag to display 
// the latest record so that it can be used by Sales users and Business processes
// Author:  V Ravi Shankar, Nitin Kumar
// Date Created:    17-May-2019
// Revision History: DIGI-335 
// Changes made for DIGI-26327 
/*********************************************************************/
public with sharing class ServiceQualTriggerHandler {

    private static String className     =   'ServiceQualTriggerHandler'; 
    private static String correlationId =   GuidUtil.NewGuid();

    /*************************************************************************************************
    Name : resetLatestRecFlgSrvQual
    EDGE-> 119161 && DIGI-335
    Author:Ila, Nitin Kumar
    Description : Method to update T_Fibre_Serviceability_Status__c, NBN_EE_Serviceability_Status__c, NBN_Serviceability_Status__c
                  on Site 
    ***********************************************************************************************/
    public static void resetLatestRecFlgSrvQual(Map<Id, Service_Qualification__c> newSqMap) {        
        try{
            set<id> siteIdSet = new set<id>();
            Set<String> techType = new Set<String>();
            List<String> technologyType = System.Label.NBN_Technology_Type.Split(','); //EDGE-> 119161; Author:Ila

            Map<Id,cscrm__Site__c> sitesToUpdate = new Map<Id,cscrm__Site__c>(); //Digi-335
            for(Service_Qualification__c sq: newSqMap.values()){
                
                siteIdSet.add(sq.Site__c);
                
            /*************************************************************************************************
            EDGE-> 119161
            Author:Ila
            Description : Set Latest Valid flag as false as per Technology type
            ***********************************************************************************************/ 
                
                // P2OB-7333 modified for the NBN Ethernet Changes
                // Changes for DIGI-335 
                
                cscrm__Site__c tempSite;
                if(sitesToUpdate.containsKey(sq.Site__c)){
                    tempSite = sitesToUpdate.get(sq.Site__c);
                }else{
                    tempSite = new cscrm__Site__c(Id = sq.Site__c);
                }
                if((sq.Technology_Type__c== Label.Telstra_Fibre) || (sq.Technology_Type__c== Label.NBN_Ethernet_Technology_Type)){
                    techType.add(sq.Technology_Type__c);
                    //DIGI-335
                    if(sq.Technology_Type__c == Label.Telstra_Fibre){
                        tempSite.T_Fibre_Serviceability_Status__c = sq.Status__c;
                    }else{
                        tempSite.NBN_EE_Serviceability_Status__c = sq.Status__c;
                        tempSite.NBN_Location_ID__c = sq.Location_ID__c; // DIGI-26327
                    } //DIGI-335
                }
                else if(technologyType.contains(sq.Technology_Type__c)){
                    techType.addAll(technologyType);
                    //DIGI-335
                   tempSite.NBN_Serviceability_Status__c= sq.Status__c;
                   tempSite.NBN_Location_ID__c = sq.Location_ID__c; // DIGI-26327
                }
                sitesToUpdate.put(sq.Site__c,tempSite); //DIGI-335
            }
            
            list<Service_Qualification__c> updSqLst = [select id, isLatestValidResult__c,Technology_Type__c from Service_Qualification__c where Site__c IN :siteIdSet AND Technology_Type__c IN :techType AND Id NOT IN :newSqMap.keyset()];
            if(updSqLst != null && !updSqLst.isEmpty()){
                List<Service_Qualification__c> sqToUpdateList = new List<Service_Qualification__c>();
                for(Service_Qualification__c sq: updSqLst){
                    if (sq.isLatestValidResult__c) {
                        sq.isLatestValidResult__c = false;
                        sqToUpdateList.add(sq);
                    }
                }
                update sqToUpdateList;
            } 
            if(sitesToUpdate!= null  && sitesToUpdate.size() > 0){
                upsert sitesToUpdate.values();
            }
        }
        catch(Exception e){
            GenericUtilityClass.logException(className,'resetLatestRecFlgSrvQual','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during update of Service Qualificatio Or Site',C2O_ExceptionHandler.Capability.SYS_TRG);
        }
    }
}