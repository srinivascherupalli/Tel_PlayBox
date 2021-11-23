public class CaseAssignmentHelper {
    
    public static void linkCBSCase(String caseId, String opportunityId){
        String cbsRecordtypeid  = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('CBS').RecordTypeId;
        String custDealRecordtypeid  = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('cusdl_Custom_Deal').RecordTypeId;
        List<Case> caseListOnOpp = [SELECT Id, RecordTypeId, srvsup_Categories__c FROM Case 
                                    WHERE OpportunityId__c=: opportunityId AND 
                                    (RecordTypeId =: cbsRecordtypeid  OR RecordTypeId =: custDealRecordtypeid)];
        
        Case cbsContractCase = new Case();
        Case cbsDesignCase = new Case();
        Case custDealCase = new Case();
        system.debug('caseListOnOpp'+caseListOnOpp);
        for(Case caseRecord:caseListOnOpp){
            if(caseRecord.RecordTypeId == cbsRecordtypeid && caseRecord.srvsup_Categories__c == 'Billing Solution Contract Implementation'){
                cbsContractCase.Id = caseRecord.Id;
            }else if(caseRecord.RecordTypeId == cbsRecordtypeid && caseRecord.srvsup_Categories__c == 'Billing Solution Design'){
                cbsDesignCase.Id = caseRecord.Id;
            }else if(caseRecord.RecordTypeId == custDealRecordtypeid){
                custDealCase.Id = caseRecord.Id;
            }
        }
        List<Case> caseListToUpdate = new List<Case>();
        system.debug('cbsDesignCase condition'+cbsDesignCase.Id != null);  
        system.debug('cbsDesignCase'+cbsDesignCase);
        if(cbsDesignCase != null && cbsDesignCase.Id != null){
            cbsContractCase.salesup_Link_Case__c = cbsContractCase.Id;
            cbsContractCase.salesup_isFirstCase__c = true;
            cbsDesignCase.salesup_Link_Case__c = cbsContractCase.Id;
            if(custDealCase.id != null){
               custDealCase.salesup_Link_Case__c = cbsContractCase.Id;
               caseListToUpdate.add(custDealCase);
            }
            caseListToUpdate.add(cbsContractCase);
            caseListToUpdate.add(cbsDesignCase);
        }
         system.debug('caseListToUpdate'+caseListToUpdate);
        if(!caseListToUpdate.isEmpty())
        	update caseListToUpdate;        
        
    }
    
    public static void attachFileToCBSCase(String caseId, String opportunityId){
        System.debug('inside Attachmethod');
        List<ContentDocumentLink> updateListContDocLink = new List<ContentDocumentLink>();
        String customLabelValue = System.Label.CBS_Attach_File_Time_In_Min;
		DateTime dateLessThan5 = (datetime.now()).addMinutes(-Integer.valueof(customLabelValue.trim()));
        List<ContentDocumentLink> lstContDocLink = new List<ContentDocumentLink>([ SELECT ContentDocumentId, LinkedEntityId 
                                                         FROM ContentDocumentLink Where LinkedEntityId =: UserInfo.getUserId() 
                                                                                  AND  SystemModstamp >: dateLessThan5]) ;
            
        for(ContentDocumentLink contentDoc : lstContDocLink){
            ContentDocumentLink updateContentDoc = new ContentDocumentLink(ContentDocumentId = contentDoc.ContentDocumentId,
                                                                          LinkedEntityId = caseId);
            updateListContDocLink.add(updateContentDoc);
        }
        if(!updateListContDocLink.isEmpty())
        	insert updateListContDocLink;
    }

}