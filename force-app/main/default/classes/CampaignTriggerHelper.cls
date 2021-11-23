public with sharing class  CampaignTriggerHelper {
    private static Diamond_Campaign_Status__mdt[] diamondCampaignStatus =[SELECT Id,Label,MasterLabel,NamespacePrefix,QualifiedApiName,HasResponded__c,SortOrder__c FROM Diamond_Campaign_Status__mdt];
    private static Default_Campaign_Status__mdt[] defaultCampaignStatus =[SELECT Id,Label,MasterLabel,NamespacePrefix,QualifiedApiName,HasResponded__c,SortOrder__c FROM Default_Campaign_Status__mdt];

    public void insertCampaignMemberStatusValues(List<Campaign> CampaignList){
        list<CampaignMemberStatus> newCMStatus = new list<CampaignMemberStatus>();
        Set<Id> removeCampaignIDs = new Set<ID>(); 
        
        Id diamondCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Diamond Campaign').getRecordTypeId();
        Id defaultCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        
        try{
            for (Campaign cItem : CampaignList) {
                if(diamondCampRecordTypeId!=null && diamondCampRecordTypeId==cItem.RecordTypeId){
                    removeCampaignIDs.add(cItem.id); 
                    newCMStatus=(getDiamondCampaignMemberStatusValues(cItem,newCMStatus));         
                    
                } else if(defaultCampRecordTypeId != null && defaultCampRecordTypeId==cItem.RecordTypeId){         
                    newCMStatus=(getDefaultCampaignMemberStatusValues(cItem,newCMStatus)); 
                }
            }
            
            if(!newCMStatus.isEmpty() && !newCMStatus.isEmpty()){
                insert newCMStatus; 
            }
            deleteCampaignStatusforDiamondCam(removeCampaignIDs);
        }catch(Exception Ex){
            system.debug('Exception::::  CampaignTriggerHelper Class:::: insertCampaignMemberStatusValues Method'+ Ex.getMessage());
        }
    }
    /*
    Sprint & US: 19.17 & P2OB-4310
    Description: Delete Sent,Responded CampaignMemberStatus for Diamond Campaign record type.
     */
    public void deleteCampaignStatusforDiamondCam(Set<Id> removeCampaignIDs){
        //Removing Sent and Responded Status Values For Dimond Campaign Record Type.
        list<CampaignMemberStatus> oldCMStatus1 = new list<CampaignMemberStatus>();
        list<CampaignMemberStatus> oldCMStatus = new list<CampaignMemberStatus>();
        if( !removeCampaignIDs.isEmpty()){
            oldCMStatus1=[SELECT CampaignId,Id,Label,SortOrder,IsDeleted FROM CampaignMemberStatus WHERE CampaignId in :removeCampaignIDs];
            for(CampaignMemberStatus cms:oldCMStatus1){
                if(cms.Label=='Sent'){
                    oldCMStatus.add(cms);
                }
                if(cms.Label=='Responded'){
                    system.debug('------------>'+cms.Label);
                    oldCMStatus.add(cms);
                }
            }
        }
        
        if( !oldCMStatus.isEmpty()){
            delete oldCMStatus;
        }
    }
    /*
    Sprint & US: 19.17 & P2OB-4310
    Description: Returns all the CampaignMemberStatus of Diamond Campaign record type based on the custom metadata Default_Campaign_Status__mdt.
     */
    public list<CampaignMemberStatus> getDiamondCampaignMemberStatusValues(Campaign cItem,list<CampaignMemberStatus> newCMStatus){
        //This is a Custom Setting that can be managed dynamically by the Salesforce Admin.
        for(Diamond_Campaign_Status__mdt csItem : diamondCampaignStatus){ 
            //Make sure the sort order does not match any existing sort order or a Duplicate error will occur 
           
                newCMStatus.add(getCampaignStatusRec(csItem.Label,cItem.id,csItem.HasResponded__c,csItem.SortOrder__c)); 
            }
        return newCMStatus;
    }  

    /*
    Sprint & US: 19.17 & P2OB-4310
    Description: Returns all the CampaignMemberStatus of Default Campaign record type based on the custom metadata Default_Campaign_Status__mdt.
     */
    public list<CampaignMemberStatus> getDefaultCampaignMemberStatusValues(Campaign cItem,list<CampaignMemberStatus> newCMStatus){
        //This is a Custom Setting that can be managed dynamically by the Salesforce Admin. 
        for(Default_Campaign_Status__mdt csItem : defaultCampaignStatus){ 
            //Make sure the sort order does not match any existing sort order or a Duplicate error will occur 
           
                newCMStatus.add (getCampaignStatusRec(csItem.Label,cItem.id,csItem.HasResponded__c,csItem.SortOrder__c)); 
            }
        return newCMStatus;
    }
    /*
    Sprint & US: 19.17 & P2OB-4310
    Description: Returns  CampaignMemberStatus for the parameters passed.
     */    
    
     private CampaignMemberStatus getCampaignStatusRec(String campaignStatus, Id cItemid,Boolean HasResponded , String SortOrder){
        CampaignMemberStatus newCMStatus=null;
        if(campaignStatus=='Nominated'){
            newCMStatus = new CampaignMemberStatus( 
                CampaignId = cItemid, 
                HasResponded = HasResponded, 
                IsDefault = True, 
                Label = campaignStatus,
                SortOrder = integer.valueOf(SortOrder)
            ); 
        }
        else{
            newCMStatus = new CampaignMemberStatus( 
                CampaignId = cItemid, 
                HasResponded = HasResponded, 
                //IsDefault = True, 
                Label = campaignStatus ,
                SortOrder = integer.valueOf(SortOrder)
            ); 
        }
        return newCMStatus;
    }
}