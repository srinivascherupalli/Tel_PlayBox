/*
* @Author : Rahul Asarma
* @Date :  27 Oct 2020
* @Desc :  To create Conga URL for DelegatedPricing
* @Jira Cloud : EDGE-176683 & EDGE-185984
*/
public with sharing class DelegatedPricingCongaUrlBuilder{
    public static string congaURLCreater(Map<String,APXTConga4__Conga_Merge_Query__c>congaQueriesRecordsMap,String frameAgreementId){
    try{ 
        if(frameAgreementId != '' || frameAgreementId != null){
            List<id> dprIDs= new List<id>();
            List<csconta__Frame_Agreement__c> faList = [SELECT id,Delegated_Pricing_Request__r.id FROM csconta__Frame_Agreement__c WHERE id=:frameAgreementId];
             if(faList != null && faList.Size() > 0){
                 for(csconta__Frame_Agreement__c faRecord:faList){
                    dprIDs.add(faRecord.Delegated_Pricing_Request__r.id);
                }
             }
            Map<String,APXTConga4__Conga_Merge_Query__c> congaRecordMap= new Map<String,APXTConga4__Conga_Merge_Query__c> ();
            if(!congaQueriesRecordsMap.isEmpty()){
            
                for(APXTConga4__Conga_Merge_Query__c congaQueryLoop:congaQueriesRecordsMap.values()){
                    congaRecordMap.put(congaQueryLoop.APXTConga4__Name__c,congaQueryLoop);
                }
                system.debug('congaRecordMap'+congaRecordMap);
                //String urlvalue= DelegatedPricingCongaUrlBuilder(congaRecordMap,frameAgreementId);
        
                String congaURL='';
                for(DPR_Deal_Query_Mapping__mdt dprQrMappingLoop:[Select  id,Query_Name__c from DPR_Deal_Query_Mapping__mdt]){
                   if(dprIDs[0]!=null){

                    if(congaRecordMap.keyset().contains(dprQrMappingLoop.Query_Name__c)){
                        congaURL=congaUrl+'['+dprQrMappingLoop.Query_Name__c+']'+congaRecordMap.get(dprQrMappingLoop.Query_Name__c).id+'?'+'pv0'+'='+dprIDs[0]+',';
                       }
                   }
                }

                system.debug('-->COngaURL'+congaURL);
                return congaURL;
        
            }
        }
            return null;
      }
   catch(Exception ex){
            System.debug('Error Caught '+ex.getMessage());
            return null;
        }
    }

}