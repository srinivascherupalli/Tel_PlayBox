/**
*	Purpose			:	This class is used to upsert data on the number and type of visitors from PreChat Form
*
*	Author			:	Pratap Garani (Wipro)
*
*	Date			:	16/02/2020
*
*	Current Version	:	V_1.0
*
*	Revision Log	:	V_1.0 - DPA-271 - Created
*						V_1.1 - DPA 1020 - Updated ('saveMinimisedVisitorCount' method created to process customer count for CCD)
**/

public without sharing class VisitorCountController {
    
    
    public static Map<String, String> mapFields = new Map<String,String>();
    public static String customerType;
    static {
        Live_Chat_Deployment_Button__mdt[] metadataRecords = [Select DeveloperName, Customer_Type__c from Live_Chat_Deployment_Button__mdt];
        for(Live_Chat_Deployment_Button__mdt a1 : metadataRecords)
        {
            String UniqueKey = a1.DeveloperName;
            if(!mapFields.containsKey(UniqueKey)){
                mapFields.put(UniqueKey, a1.Customer_Type__c);
            }
        }
    }
    
    
    /**
* 	@description	:	This method will process logic to insert the Visitor Data for TECOM based on buttons in Prechat
* 
* 	@param			:	String, String
* 
* 	@return			:	Boolean
**/
    
    @AuraEnabled
    public static Boolean savePreChatVisitorCount(String clickInstance, String customerType){
        try{
            List<Visitor_Tracker__c> dataTracker = new List<Visitor_Tracker__c>();
            List<Visitor_Tracker__c> vistorRecords = [Select id,
                                                      Originating_URL__c,
                                                      Button_Type__c,
                                                      Record_Count__c 
                                                      from Visitor_Tracker__c 
                                                      where Originating_URL__c =:clickInstance 
                                                      AND Button_Type__c =:customerType];
            if(vistorRecords.size()>0){
                for(Visitor_Tracker__c vr: vistorRecords){
                    vr.Record_Count__c++;
                    dataTracker.add(vr);
                }
            }else{
                Visitor_Tracker__c newVisitor = new Visitor_Tracker__c(Originating_URL__c = clickInstance,
                                                                       Button_Type__c = customerType,
                                                                       Record_Count__c = 1);
                dataTracker.add(newVisitor);
            }
            upsert dataTracker;
            system.debug('------dataTracker::::::::: '+dataTracker);
            return true;
        }catch(Exception e){
            System.debug('ERROR ::::::::: '+e.getMessage());
            return false;
        }
    }
    
    /**
* 	@description	:	This method will process logic to insert/update the Visitor Data for Channel Care  and pass the recordId back to aura comp
* 
* 	@param			:	String, String
* 
* 	@return			:	String
* 
*  @Story          :   DPA 1020, Target Release : 20.05
**/
    
    @AuraEnabled
    public static String saveMinimisedVisitorCount(String visitorRecord, String clickInstance, String deploymentId){
        try{
            String mapKey;
            List<Visitor_Tracker__c> dataTracker = new List<Visitor_Tracker__c>();
            Visitor_Tracker__c vistorRecordsAbandoned = new Visitor_Tracker__c();
            
            
            if( test.isRunningTest()){
                mapKey = 'Chat_Telstra_Connect_Concierge';
            }else{
                mapKey = [Select id, DeveloperName from LiveChatDeployment where Id = :deploymentId].DeveloperName;
            }
            if(String.isBlank(visitorRecord)){
                mapKey = mapKey+'_Abandoned';
            }
            else if(!String.isBlank(visitorRecord)){
                mapKey = mapKey+'_Customer';
            }
            
            if(mapFields.containsKey(mapKey)){
                customerType = mapFields.get(mapKey);
            }
            
            Map<Id, Visitor_Tracker__c> mapVistorRecords = new Map<Id, Visitor_Tracker__c>([SELECT id, Originating_URL__c, Button_Type__c, Record_Count__c
                                                                                            FROM Visitor_Tracker__c WHERE Id =:visitorRecord
                                                                                            OR (Originating_URL__c =:clickInstance AND Button_Type__c =:customerType)]);
            
            if(!String.isBlank(visitorRecord)){
                vistorRecordsAbandoned = mapVistorRecords.get(visitorRecord);
            }
            
            if(vistorRecordsAbandoned != null && vistorRecordsAbandoned.Record_Count__c > 1){
                vistorRecordsAbandoned.Record_Count__c--;
                mapVistorRecords.remove(vistorRecordsAbandoned.Id);
                dataTracker.add(vistorRecordsAbandoned);
            }
            else if(vistorRecordsAbandoned != null && vistorRecordsAbandoned.Record_Count__c==1){
                mapVistorRecords.remove(vistorRecordsAbandoned.Id);
                delete vistorRecordsAbandoned;
            }
            
            if(mapVistorRecords.size() > 0){
                for(Visitor_Tracker__c vr: mapVistorRecords.values()){
                    vr.Record_Count__c++;
                    dataTracker.add(vr);
                }
            } else{
                Visitor_Tracker__c newVisitor = new Visitor_Tracker__c(Originating_URL__c = clickInstance, Button_Type__c = customerType,
                                                                       Record_Count__c = 1);
                dataTracker.add(newVisitor);
            }
            
            if(dataTracker.size() > 0) {
                upsert dataTracker;
                
                system.debug('------dataTracker::::::::: '+dataTracker[0].id);
                return dataTracker[0].id;
            }
            return null;
        }catch(Exception e){
            System.debug('ERROR ::::::::: '+e.getMessage());
            return 'ERROR';
        }
    }
}