/*
 * Updates - 
 * 1.   Ritika Jaiswal - EDGE - 81135 : Updating Opportunity-type and stage when basket has Cancel-products
   2.   Aditya Pareek  - EDGE - 144971: Updated for NGUC Full Cancel
   3. 	Shubhi Vijayvergia	EDGE-151654 navigationfix
 * */
public with sharing class CancellationReasonController {
    // Controller class for CancelaltionReason Lightning Component
    // Get Account Details
    // EDGE-77981  Change for NBN Story - new method: isCancelationNBN(String basketId) 
    // Changes for Solution Console Deployment
    @AuraEnabled
    public static Account acc{get;set;}
        @AuraEnabled
        public static Account getAccountDetails(String basketId, String accountId){
        if (basketId != ''){
            cscfga__Product_Basket__c bas = [Select id, csbb__Account__c 
                                             from cscfga__Product_Basket__c 
                                             where Id=:basketId];
            acc = [Select id, name from Account where Id=:bas.csbb__Account__c];
        }
        else if(accountId != ''){
            acc = [Select id, name from Account where Id=:accountId];
        }

        return acc ;
    }
    // Get Opportunity ID from Basket ID
    @AuraEnabled
    public static Id getOpportunityId (Id basketId){
        Id opportunityId = [ 
                                SELECT cscfga__Opportunity__c
                                FROM cscfga__Product_Basket__c
                                WHERE Id = :basketId 
                           ].cscfga__Opportunity__c;
        return opportunityId;
    }
    // Create opportunity Contact Role
    @AuraEnabled
    public static void createContactInOpportunity(Id OppId, Id conId){
    system.debug('Contact Obj--------'+ conId );
        //String mailId = (String)con.get('Email');
     List<OpportunityContactRole> ocrOld = new List<OpportunityContactRole>
                                ([Select Id , ContactId 
                                  from OpportunityContactRole 
                                    where OpportunityId =: OppId ]);
      if(!ocrOld.isEmpty())
          delete ocrOld;
     OpportunityContactRole ocr = new OpportunityContactRole(ContactId = conId,OpportunityId = OppId,Role='Decision Maker');
      system.debug('New OCR--------'+ ocr);
    insert ocr;
    }
    @AuraEnabled
    public static Boolean isCancelationNBN(String basketId) {
        if (basketId != '') {
            cscfga__Product_Basket__c bas = [Select id, Cancellation_Reason__c from cscfga__Product_Basket__c where Id =: basketId];
            System.debug('CancellationReasonController Cancellation_Reason__c: ' + bas);
            if (bas.Cancellation_Reason__c == 'NBN Transfer Out')
            {
                return true;
            }
        }
        return false;       
    }

    /*New method to update opportunity and basket based on basket content i.e. if all PCs are cancelled then oppty = disconnect and ccanccelled and basket us submitted
    //Map<Id, String> = PccId, Type__c
            //if all are cancel 
            
            //Update the Basket to Submitted
            //Update the opportunity type from MAC () to Disconnect, stage Cancelled
    */
     // Update Opportunity as Disconnect if all PC ChangeType='Cancel'
    @AuraEnabled
    public static void updateOpportunityTypeDisconnect(Id OppId, Id basketId){
    
    List<cscfga__Product_Configuration__c> pcListSOQL = new List<cscfga__Product_Configuration__c>();
    // Adding check on configuration-type of PC
    // Updated for EDGE-144971 Start--->
    pcListSOQL = [SELECT id, Name, Type__c, cssdm__solution_association__c, cscfga__Product_Basket__r.csbb__Account__c,cscfga__Product_Basket__r.cscfga__Opportunity__c from cscfga__Product_Configuration__c  WHERE cscfga__Product_Basket__c = :basketId and Type__c != '' and cscfga__Root_Configuration__c = null];
    Boolean isAnyNonCancel = false;
        
        for (cscfga__Product_Configuration__c pc : pcListSOQL){
            if (pc.Type__c != 'Cancel' && pc.Type__c != 'PaidOut' && pc.Type__c !='PayOut') //EDGE-151654 added /&& code was overriden
                isAnyNonCancel = true;
        }
    // Updated for EDGE-144971 End--->
    cscfga__Product_Basket__c pb = [select id , csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where id = :basketId];
    
    Opportunity opp = [select id , Type ,StageName from Opportunity where id = :OppId];
        if (!isAnyNonCancel){
            opp.Cancel_Opp_Automatically_closed__c = true; // EDGE : 81135 : Prevent validation rule from blocking Oppty-update //EDGE-127601
            
            pb.csordtelcoa__Basket_Stage__c = 'Submitted';
            opp.Type = 'Disconnect';
            opp.StageName = 'Cancelled';        
        }
        else
        {
            System.debug('final else');
            pb.csordtelcoa__Basket_Stage__c = 'Enriched';          
        }
        pb.csordtelcoa__Synchronised_with_Opportunity__c = true;
        pb.csbb__Synchronised_With_Opportunity__c = true; 
        pb.cscfga__Basket_Status__c = 'Valid';

    system.debug('Contact Obj--------'+ opp);    
    update opp;
    system.debug('Contact Obj--------'+ pb);
    update pb;
    
    }
    // Get ACR ID for Cancellation Reason Pop up
        @AuraEnabled
    public static AccountContactRelation acr {
        get;
        set;
    }
    @AuraEnabled
    public static AccountContactRelation getACRId(Id basketId) {
        If (basketId != null || basketId != ''){
        List < cscfga__Product_Basket__c > basket = new List < cscfga__Product_Basket__c > ([select csbb__Account__r.id, cscfga__Opportunity__r.id from cscfga__Product_Basket__c where id =: basketId]);
        List < OpportunityContactRole > ocr = new List < OpportunityContactRole > ([Select Id, ContactId from OpportunityContactRole where OpportunityId =: basket[0].cscfga__Opportunity__r.id]);
        if (!ocr.IsEmpty()) {
            List < AccountContactRelation > listACR = new List < AccountContactRelation > ([select id, ContactId, AccountId, Contact_Name__c, Roles from AccountContactRelation where AccountId =: basket[0].csbb__Account__r.id and ContactId =: ocr[0].ContactId]);

            if (!listACR.IsEmpty())
                AccountContactRelation acr = new AccountContactRelation();
            acr = listACR[0];
            return acr;
        }
        return null;
    }
        return null;
}
    //EDGE-151654 start
    @AuraEnabled
    public static string GetSiteId(){
    	return Site.getSiteId();
  	}
    @AuraEnabled
    public static String organizationInfo() {
        String currentOrg = '';
        List<organization> lstOrganization =
            [
                Select id, instanceName, isSandbox
                from Organization
            ];
        if (lstOrganization.size() > 0) {
            if (lstOrganization[0].isSandbox)
                currentOrg = 'Sandbox';
            else
                currentOrg = 'Production';
            return currentOrg;
        }
        return currentOrg;
    }
	//EDGE-151654 end
}