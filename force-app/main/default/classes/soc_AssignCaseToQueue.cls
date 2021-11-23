public with sharing class soc_AssignCaseToQueue {
    @AuraEnabled
    public static Map<String,Object> assignCase(String caseId){
        //Modified this for code optimization to reduce SOQL on Record Type and Group object
        String recId_OrderRequest= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        String recId_SupportRequest=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('soc_Support_Request').getRecordTypeId();
        String recId_SupportRequestWO=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
        String queueId_Concierge ;        
        String queueId_ConciergeSupport ;              
        String queueId_SMESupport ;       
        String queueId_SFDOffshoreConcierge ;       
        String queueId_ConciergeSupportOffshore;       
        String queueId_MediumComplexSupportRequest;
        Set<String> setConciergeQueues = new Set<String>{Label.soc_ConciergeQueueName,'soc_Concierge_Support_requests','soc_SME_Support_requests',
                                                        'soc_SFD_Concierge_Offshore','soc_Concierge_Offshore_Support_request','soc_Medium_Complex_Support_Requests'};
        for(Group groupM: [select Id, DeveloperNAME from Group where Type = 'Queue' AND DeveloperNAME IN : setConciergeQueues]){
            if(groupM.DeveloperNAME == Label.soc_ConciergeQueueName){
                queueId_Concierge =groupM.Id; 
            }else if(groupM.DeveloperNAME == 'soc_Concierge_Support_requests'){
                queueId_ConciergeSupport =groupM.Id; 
            }else if(groupM.DeveloperNAME == 'soc_SME_Support_requests'){
                queueId_SMESupport =groupM.Id; 
            }else if(groupM.DeveloperNAME == 'soc_SFD_Concierge_Offshore'){
                queueId_SFDOffshoreConcierge =groupM.Id; 
            }else if(groupM.DeveloperNAME == 'soc_Concierge_Offshore_Support_request'){
                queueId_ConciergeSupportOffshore =groupM.Id; 
            }else if(groupM.DeveloperNAME == 'soc_Medium_Complex_Support_Requests'){
                queueId_MediumComplexSupportRequest =groupM.Id; 
            }
        }
        Map<String,Object> results=new Map<String,Object>();          
        results.put('status','fail');       
        try{             
            list<Case> caseList = [SELECT id,subject,Stage__c,Requestor__c,OpportunityId__c,
                                   soc_Customer_Required_Date_CRD__c,
                                   soc_Customer_Acceptance_Evidence__c,soc_Additional_Technical_Contact__c,
                                   soc_Additional_Technical_Contact_Email__c,soc_FNNs__c,soc_Number_of_Sites__c,
                                   soc_Billing_Account_Number__c,soc_Support_Category__c,soc_Support_Category_WO__c,
                                   Status,OwnerId,RecordTypeId,ContactId,Contact.AccountId,AccountId,ContactEmail,soc_SFD_Offshore_Restricted__c,
                                   Network_FNN__c, MDN_Network_FNN__c, soc_Request_Type__c
                                   FROM case where id =: caseId limit 1];
            if(caseList[0].RecordTypeId == recId_OrderRequest){
                List<String> validationResults=validate(caseList[0]);
            	if(validationResults.size()==0){
                    if(caseList[0].soc_SFD_Offshore_Restricted__c){
                		caseList[0].OwnerId = queueId_Concierge;
                    }
                    else{
                      	caseList[0].OwnerId = queueId_SFDOffshoreConcierge;  
                    }
                    update(caseList);
                   results.put('status','pass');
            	}
                else{
                    results.put('status','fail');
                    results.put('response',validationResults);
                }
            }
            else if(caseList[0].RecordTypeId == recId_SupportRequest){
                if(caseList[0].soc_SFD_Offshore_Restricted__c){
                		caseList[0].OwnerId = queueId_ConciergeSupport;
                    }
                else{
                      	caseList[0].OwnerId = queueId_ConciergeSupportOffshore;  
                    }
         		update(caseList);
                results.put('status','pass');
            }
            else if(caseList[0].RecordTypeId == recId_SupportRequestWO){
                //Karan Jugtawat	P2OB-5586	added below condition to assign cace to MediumComplexSupportRequest Queue. 
                if(caseList[0].soc_Support_Category_WO__c != NULL && caseList[0].soc_Support_Category_WO__c  == system.label.SDWAN_Early_Engagement || caseList[0].soc_Support_Category_WO__c  == system.label.BCS_MAC_Early_Engagement ){
                		caseList[0].OwnerId = queueId_MediumComplexSupportRequest;
                    }   
                else if(caseList[0].soc_SFD_Offshore_Restricted__c){
                		caseList[0].OwnerId = queueId_ConciergeSupport;
                    }
                else{
                      	caseList[0].OwnerId = queueId_ConciergeSupportOffshore;  
                    }          
                update(caseList);
                results.put('status','pass');
            }            
        }
        catch(Exception e){
            results.put('status','fail');
            results.put('response',e.getMessage());            
        }    
        return results;        
    }    
    @AuraEnabled
    public static Map<String,Object> checkVisibile(String caseId){        
        Map<String,Object> results=new Map<String,Object>();
        List<Case> caseList= [SELECT id,subject,Stage__c,
                              Status,OwnerId,requestor__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName
                              FROM case where id =:caseId limit 1];
				String name=[select Name from profile where id = :userinfo.getProfileId()].Name;
        results.put('case',caseList[0]);
        results.put('profileName',name);
        return results;                
    }
    public static List<String> validate(Case cs){
        String recId_OrderRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();	  
        List<String> validationResults=new List<String>();
        if(String.isBlank(cs.subject)){
           validationResults.add('Subject');
        } 
        if(String.isBlank(cs.Requestor__c)){
           validationResults.add('Requestor');
        } 
        if(String.isBlank(cs.OpportunityId__c)){
           validationResults.add('Opportunity');
        } 
        /*if(String.isBlank(cs.soc_Offshore_Data_Hosting_Restricted__c)){
           validationResults.add('Offshore Data Hosting Restricted');
        }*/ 
        if(cs.soc_Customer_Acceptance_Evidence__c==null){
           validationResults.add('Customer Acceptance Evidence');
        } 
        if(cs.soc_Customer_Required_Date_CRD__c==null){
           validationResults.add('Customer Required Date');
        } 
        if(String.isBlank(cs.soc_Additional_Technical_Contact__c) && String.isBlank(cs.ContactId) ){
           validationResults.add('Additional Technical Contact or Contact');
        } 
        /*if(String.isBlank(cs.soc_Additional_Technical_Contact__c) && !String.isBlank(cs.ContactId)){
            if(cs.Contact.AccountId != cs.AccountId && cs.RecordTypeId == recId_OrderRequest)
                validationResults.add('Select Contact Name associated from the current case Account only.');
        }*/
        if(String.isBlank(cs.soc_Additional_Technical_Contact_Email__c) && String.isBlank(cs.ContactEmail)) {
           validationResults.add('Additional Technical Contact Email Or Contact Email'); 
        } 
         if(String.isBlank(cs.soc_FNNs__c) && String.isBlank(cs.MDN_Network_FNN__c) && String.isBlank(cs.Network_FNN__c)){
           validationResults.add('One of the FNN fields'); 
        } 
         if(String.isBlank(cs.soc_Number_of_Sites__c)){
           validationResults.add('Number of Sites'); 
        } 
        if(String.isBlank(cs.soc_Request_Type__c)){
           validationResults.add('Request Type'); 
        } 
         if(String.isBlank(cs.soc_Billing_Account_Number__c)){
           validationResults.add('Billing Account Number'); 
        } 
        return validationResults;
    }
}