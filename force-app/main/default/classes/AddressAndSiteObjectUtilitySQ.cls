/*
* @Author : Shubhi
* @Date : 3 October 2019
* @Desc : Get Address data from East using adbor id and Upsert it in salesforce 
* @Jira : Edge-113351
*@Desc: Test class for NBNEastCallout 
*@TestClass: AddressAndSiteObjectUtilitySQTest */
public class AddressAndSiteObjectUtilitySQ {
    
    Public static void upsertEastAddressAndSiteAndSQ(String[] adborID,String CIDN,ReplicatorGetSiteDataObject replicatorAddress,Map<String, Service_Qualification__c> sqRecordToBeInsertedForReplicatorMap,Map<String,List<Service_Qualification_Provider_Resource__c>> providerresourceListMap){
        AddressRequestDTO req;
        //AddressResponseDTO res;
        try{
            
            for (String adborIDs:adborID ){
                System.debug('****in here utility'+adborIDs);
                req=AddressAndSiteObjectUtility.createRequestDTO(adborIDs);
                Service_Qualification__c sqRecordToBeInsertedForReplicator=new Service_Qualification__c();
                List<Service_Qualification_Provider_Resource__c> providerList=new List<Service_Qualification_Provider_Resource__c>();
                if(sqRecordToBeInsertedForReplicatorMap!=null && sqRecordToBeInsertedForReplicatorMap.containskey(adborIDs)){
                    sqRecordToBeInsertedForReplicator=sqRecordToBeInsertedForReplicatorMap.get(adborIDs);
                    if(providerresourceListMap!=null && providerresourceListMap.containskey(adborIDs)){
                        providerList.addAll(providerresourceListMap.get(adborIDs));
                    }
                }                    
                System.debug('***req :'+req);
                ID JobId= System.enqueueJob(new NBNEastCalloutNew(req,adborIDs,CIDN,replicatorAddress,sqRecordToBeInsertedForReplicator,providerList));
                //  AddressValidateManager.searchAddressByAdborIdAsync(req); 
                // AddressAndSiteObjectUtility.upsertReplicatorAddressAndSite(adborIDs,replicatorAddress);                
            }                           
        }catch(Exception e){
            System.debug('Exception occured in Async East callout:'+e);
            Logger.getLogger(AddressAndSiteObjectUtilitySQ.class).debug(e);
            throw(e);
        }
        
    }

}