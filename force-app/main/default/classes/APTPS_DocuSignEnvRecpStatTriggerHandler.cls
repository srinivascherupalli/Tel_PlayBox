public with sharing class APTPS_DocuSignEnvRecpStatTriggerHandler {
    public void handleAfterInsertEvents(List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> statusList){
        Set<id> idSet = new Set<Id>();
        for(Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c status : statusList)
        {
            if(status.Apttus_DocuApi__Status__c == 'completed' && status.Apttus_DocuApi__SignedDateTime__c != null &&
                (status.Apttus_DocuApi__RoutingOrder__c == '2' || status.Apttus_DocuApi__RoutingOrder__c == '3' 
                || status.Apttus_DocuApi__RoutingOrder__c == '4'))
            {
                idSet.add(status.id);
            }
        }
        
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> updatedStatusList = [Select id,Apttus_DocuApi__RoutingOrder__c,Apttus_DocuApi__RecipientName__c, Apttus_DocuApi__SignedDateTime__c, Apttus_DocuApi__DocuSignEnvelopeId__r.id from Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c where id In : idSet];
        Map<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c, id> statusEnvelopeMap = new Map<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c, id>();
        Set<Id> envelopeIdSet = new Set<Id>();      
        
        for(Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c status : updatedStatusList)
        {
            statusEnvelopeMap.put(status,status.Apttus_DocuApi__DocuSignEnvelopeId__r.id);
            envelopeIdSet.add(status.Apttus_DocuApi__DocuSignEnvelopeId__r.id);
        }
        List<Apttus_DocuApi__DocuSignEnvelope__c> envelopeList = [Select id,(SELECT Id,RecordType.Name, Apttus__Agreement_Category__c, Apttus__Other_Party_Signed_Date__c, Apttus__Company_Signed_Date__c, APTPS_Other_Party_Signed_By__c, APTPS_Company_Signed_By__c FROM Apttus_CMDSign__Agreements__r) From Apttus_DocuApi__DocuSignEnvelope__c where id In : envelopeIdSet];
        Map<id, List<Apttus__APTS_Agreement__c>> envelopeAgreementsMap = new Map<id, List<Apttus__APTS_Agreement__c>>();
        
        for(Apttus_DocuApi__DocuSignEnvelope__c env : envelopeList)
        {   
            envelopeAgreementsMap.put(env.id, env.Apttus_CMDSign__Agreements__r);
        }
        
        Map<id, Apttus__APTS_Agreement__c> updatedAgmtMap = new Map<id, Apttus__APTS_Agreement__c>();
        
        for(Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c status : statusEnvelopeMap.keyset())
        {
            for(Apttus__APTS_Agreement__c agmt : envelopeAgreementsMap.get(statusEnvelopeMap.get(status)))
            {
                if(updatedAgmtMap.containsKey(agmt.id)){
                    agmt = updatedAgmtMap.get(agmt.id);
                    updatedAgmtMap.remove(agmt.id);
                }
                if(agmt.RecordType.Name == 'NDA' && agmt.Apttus__Agreement_Category__c == 'Multi-Party')
                {
                    if(status.Apttus_DocuApi__RoutingOrder__c == '3')
                    {
                        agmt.Apttus__Other_Party_Signed_Date__c = status.Apttus_DocuApi__SignedDateTime__c.date();
                        agmt.APTPS_Other_Party_Signed_By__c = status.Apttus_DocuApi__RecipientName__c;
                    }
                    if(status.Apttus_DocuApi__RoutingOrder__c == '4')
                    {
                        agmt.Apttus__Company_Signed_Date__c = status.Apttus_DocuApi__SignedDateTime__c.date();
                        agmt.APTPS_Company_Signed_By__c = status.Apttus_DocuApi__RecipientName__c;
                    }
                }
                else
                {
                    if(status.Apttus_DocuApi__RoutingOrder__c == '2')
                    {
                        agmt.Apttus__Other_Party_Signed_Date__c = status.Apttus_DocuApi__SignedDateTime__c.date();
                        agmt.APTPS_Other_Party_Signed_By__c = status.Apttus_DocuApi__RecipientName__c;
                    }
                    if(status.Apttus_DocuApi__RoutingOrder__c == '3')
                    {
                        agmt.Apttus__Company_Signed_Date__c = status.Apttus_DocuApi__SignedDateTime__c.date();
                        agmt.APTPS_Company_Signed_By__c = status.Apttus_DocuApi__RecipientName__c;
                    }
                }
                agmt.APTPS_Is_Custom_Update__c = true;
                updatedAgmtMap.put(agmt.id, agmt);
            }
        }
        
        if(updatedAgmtMap.size() > 0){
            update updatedAgmtMap.values();
            for(Apttus__APTS_Agreement__c agmt : updatedAgmtMap.values()){
                agmt.APTPS_Is_Custom_Update__c = false;
            }
            update updatedAgmtMap.values();
        }
    
    }
}