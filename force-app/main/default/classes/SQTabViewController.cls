/*
* @Author : Ajith Kumar
* @Date : 2 AUG 2021
* @Desc : Service Qualification Tab controller  
* @Jira : DIGI-333/559
* @test class : SQTabViewControllerTest

DIGI-29002  | Modified | Sowmya      - modified the query to retrieve the data for new fields(device type and device domain) 
*/
public with Sharing class SQTabViewController {
     
    private static final List<String> nbnTechnologyTypes = System.Label.NBN_Technology_Type.Split(',');
     /*************************************************************************************************
    Name : getServiceQualificationRecords
    DIGI-333/559
    Author:Ajith, Nitin Kumar
    Description : Method to retrieve SQ and its related details to show on Site Detail page
    Related LWC: serviceQualifiactionTabView
    ***********************************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static SQTabWrapper getServiceQualificationRecords(Id recordId){
        SQTabWrapper serviceQualificationwrapper = new SQTabWrapper();
        try{ 
            List<Service_Qualification__c> sqRecordslst =  [SELECT Id,isLatestValidResult__c,Status__c,Status_Reason__c,LastModifiedDate,Location_ID__c,
                                                        Technology_Type__c,Max_Downstream_Speed__c,Max_Upstream_Speed__c,Max_Backhaul__c,Max_Spare_Copper_Pair__c,
                                                        NBN_TC1_Speed__c,Ready_for_Service_Date__c,Appointment_Required__c,CSA_ID__c,Serviceability_Class__c,
                                                        Cease_Sale_Date__c,Service_Type__c,NBN_Estimated_Availability_Date__c,
                                                        (SELECT Id,Name,maximumESABandwidth__c,carriageSolutionStatus__c,maximumDeviceBandwidth__c,interfaceType__c,
                                                        spareSlotIndicator__c,deviceBuildIndicator__c,Device_Type__c,Device_Domain__c FROM Carriage_Solutions__r WHERE Name='Telstra Fibre Access'
                                                        ORDER BY LastModifiedDate Desc),
                                                        (SELECT Id,Copper_Pair_ID__c,Copper_Path__c,Resource_Type__c,SIC_Indicator__c,SIC_Code__c,SIC_Reason__c
                                                        FROM Service_Qualification_Provider_Resources__r order by lastmodifieddate DESC LIMIT 1),
                                                        (SELECT NTD_ID__c,NTD_Power_Type__c,NTD_Location__c,NTD_Type__c FROM Service_Qualification_Resource_Details__r)
                                                        FROM Service_Qualification__c WHERE Site__c=:recordId AND isLatestValidResult__c = true LIMIT 3];
            List<Service_Qualification_Port_Detail__c> sqPortDetails = [SELECT Id,Uni_Port_Type__c,Port_ID__c,Port_Status__c from Service_Qualification_Port_Detail__c WHERE Service_Qualification_Resource_Detail__r.Service_Qualification__r.Site__r.Id =: recordId and Service_Qualification_Resource_Detail__r.Service_Qualification__r.isLatestValidResult__c = true and Service_Qualification_Resource_Detail__r.Service_Qualification__r.Technology_Type__c in : nbnTechnologyTypes];                                     
           
            if(!sqRecordslst.isEmpty()){
                           
                for(Service_Qualification__c record: sqRecordslst){
                    if(record.Technology_Type__c== Label.Telstra_Fibre ){
                        serviceQualificationwrapper.TelstraFibreSQ = record;
                        serviceQualificationwrapper.carriageSolutionsRecord=record.Carriage_Solutions__r;
                    }
                    else if(record.Technology_Type__c== Label.NBN_Ethernet_Technology_Type ){
                        serviceQualificationwrapper.NBNEthernertSQ = record;
                    } 
                    else{
                        serviceQualificationwrapper.NBESFibreSQ = record;
                        if(record.Service_Qualification_Provider_Resources__r != null && !record.Service_Qualification_Provider_Resources__r.isEmpty()) 
                            serviceQualificationwrapper.serviceQualificationProviderRecord = record.Service_Qualification_Provider_Resources__r;
                        
                        if (record.Service_Qualification_Resource_Details__r != null && !record.Service_Qualification_Resource_Details__r.isEmpty())
                            serviceQualificationwrapper.serviceQualificationResourceDetailRecords =  record.Service_Qualification_Resource_Details__r;
                        
                        if(sqPortDetails!= null && !sqPortDetails.isEmpty())
                            serviceQualificationwrapper.serviceQualificationPortDetailRecords = sqPortDetails;       
                    }                    
                }
            }            
        }
        catch(Exception ex){
            GenericUtilityClass.logException('ServiceQualificationTabViewController','getServiceQualificationRecords','',recordId,ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString(),'Exception occured during retrieving the service Qualification records',C2O_ExceptionHandler.Capability.ORD);
        }
        return serviceQualificationwrapper;
    }
    
    public class SQTabWrapper{
        @AuraEnabled
        public Service_Qualification__c TelstraFibreSQ{get;set;}
        @AuraEnabled
        public Service_Qualification__c NBESFibreSQ{get;set;}
        @AuraEnabled
        public Service_Qualification__c NBNEthernertSQ{get;set;}
        @AuraEnabled
        public List<Carriage_Solutions__c> carriageSolutionsRecord{get;set;}
        @AuraEnabled
        public Service_Qualification_Provider_Resource__c serviceQualificationProviderRecord{get;set;}
        @AuraEnabled
        public List<Service_Qualification_Resource_Detail__c> serviceQualificationResourceDetailRecords{get;set;}
        @AuraEnabled
        public List<Service_Qualification_Port_Detail__c> serviceQualificationPortDetailRecords{get;set;}
        
    }

}