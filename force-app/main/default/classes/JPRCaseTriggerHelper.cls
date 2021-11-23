/*****************************************************************************
@Author: Mofit
@CreateDate: 16/08/2020
@ModifiedByandDate: 
/*
=====================================================================================================================================================
Sr.No.    Developer Name      Date                 Story                     Description
1.	   Durga Nagarajan	  16/08/2021(Jaipur) 	   DIGI-2050		Updates Rules to ensure record sharing is done in a way onshore and offshore
2.     Durga Nagarajan	  07/10/2021(Jaipur) 	   DIGI-12640		As a Governance Team member I need to return a case to CPE Purple Service Queue so they can perform work on it  
=====================================================================================================================================================
*/
public class JPRCaseTriggerHelper {
  
    public static String recId_ChannelCareWorkOrder = workorder.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Channel_Care_Bulk_Request').getRecordTypeId();
    public static String recId_salesSupportChild=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
   	public static String recId_CBS = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
    public static String recId_Mobile_MAC = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('mm_Mobile_Support_Request').getRecordTypeId();
    public static String recId_CPE = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CPE_Requests').getRecordTypeId();
    public static String recId_Service_Support = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('srvsup_Service_Support').getRecordTypeId();
    public static String recId_SFD_Request = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('SFD_Request').getRecordTypeId();
    public static String recId_SFD_WorkOrder_Request = workorder.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('SFD_Work_Order_Request').getRecordTypeId();
    public static String recId_Channel_care_partners_Request = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Channel_Care_for_Partners').getRecordTypeId();
    
	/*
    Jaipur :: Mofit Pathan
    Sprint & US: 21.11 & DIGI-2050
    Description: 21.11 & DIGI-2050 : Updates Rules to ensure record sharing is done in a way onshore and offshore
    */    
 	public static void handleOffshoreCase(List<Case> newCases,Map<ID,Case> oldCaseMap){
        List<Case> CaseSFDOffShoreRestrictedFalse = new List<Case>();
        List<Case> lstCase = new List<Case>();
        List<OpportunityShare> oppSharelist = new list<OpportunityShare>();
        List<OpportunityShare> oppsharedeletelist = new list<OpportunityShare>();
        List<OpportunityShare> oppShareCheck = new List<OpportunityShare>();
        Set<Id> oppIds = new Set<Id>();
        for(case c1 : newCases){
            if (c1.AccountId != null && c1.OpportunityId__c != null && c1.soc_SFD_Offshore_Restricted__c == false && 
                ((oldCaseMap.get(c1.id).OwnerId != c1.OwnerId) || (c1.status != oldCaseMap.get(c1.id).Status && (c1.Status == 'Closed' || c1.Status == 'Withdrawn' || c1.Status == 'Rejected'))) && 
                (c1.RecordTypeId == recId_salesSupportChild || c1.RecordTypeId == recId_Mobile_MAC || c1.RecordTypeId == recId_CPE || c1.RecordTypeId == recId_CBS || c1.RecordTypeId == recId_Service_Support || c1.RecordTypeId == recId_SFD_Request))
            {
                    CaseSFDOffShoreRestrictedFalse.add(c1);
            }
        }
 
        if(CaseSFDOffShoreRestrictedFalse != null && CaseSFDOffShoreRestrictedFalse.size() > 0){
            
            for(case c : [select Id, RecordTypeId, AccountId, OpportunityId__c, Account.APTPS_Off_Shore_Restricted__c,
                          soc_SFD_Offshore_Restricted__c, OwnerId, Status 
                          from Case where Id in: CaseSFDOffShoreRestrictedFalse]){
                if(c.Account.APTPS_Off_Shore_Restricted__c == true)
                {
               		 oppIds.add(c.OpportunityId__c);
                     lstCase.add(c);
                }
			}
        }
      if(oppIds.size() > 0 && lstCase != null && lstCase.size() > 0)
        {
           //Retrieving all opportunity share records based on opportunity Ids
           List<OpportunityShare> OppList = [Select Id, OpportunityId, OpportunityAccessLevel, UserOrGroupId, RowCause
                                             from OpportunityShare where OpportunityId =: oppIds and (OpportunityAccessLevel = 'Read' or OpportunityAccessLevel =  'Edit')];
            
           for(Case cs : lstCase)
            {
                    //Sharing Opportunity record with new Case Owner, if new owner is user and old owner was queue
                    if(oldCaseMap.get(cs.id).OwnerId != cs.OwnerId && String.valueOf(cs.OwnerId).startsWith('005') &&
                       String.valueOf(oldCaseMap.get(cs.id).OwnerId).startsWith('00G')){
                           if(OppList != null && OppList.size() > 0){
                           for(OpportunityShare OS : OppList){
                               if(OS.OpportunityId == cs.OpportunityId__c && OS.UserOrGroupId == cs.OwnerId)
                               {
                                  oppShareCheck.add(OS);    
                               }
                            }
                       }
                           if (oppShareCheck.size()==0) {
                                OpportunityShare oppShare = new OpportunityShare();
                                oppShare.OpportunityId = cs.OpportunityId__c;
                                oppShare.UserOrGroupId = cs.OwnerId;
                                oppShare.OpportunityAccessLevel = 'Read';
                                oppshare.RowCause = 'Manual';
                                oppSharelist.add(oppShare);
                            }                                
                    } 
                    //Sharing Opportunity record with new Case Owner and revoking opportunity record access from old case owner, if new owner is user and old owner was user
                    else if (oldCaseMap.get(cs.id).OwnerId != cs.OwnerId && String.valueOf(cs.OwnerId).startsWith('005') &&
                       		String.valueOf(oldCaseMap.get(cs.id).OwnerId).startsWith('005') ) {
                          if(OppList != null && OppList.size() > 0){
                        	for(OpportunityShare OS : OppList){
                               if(OS.OpportunityId == cs.OpportunityId__c && OS.UserOrGroupId == oldCaseMap.get(cs.id).OwnerId
                                 	&& OS.RowCause == 'Manual')
                                   {
                                      oppsharedeletelist.add(OS);    
                                   }
                               if(OS.OpportunityId == cs.OpportunityId__c && OS.UserOrGroupId == cs.OwnerId)
                                   {
                                      oppShareCheck.add(OS);    
                                   }
                            }        
                          }
                            if (oppShareCheck.size()==0) {
                                OpportunityShare oppShare = new OpportunityShare();
                                oppShare.OpportunityId = cs.OpportunityId__c;
                                oppShare.UserOrGroupId = cs.OwnerId;
                                oppShare.OpportunityAccessLevel = 'Read';
                                oppshare.RowCause = 'Manual';
                                oppSharelist.add(oppShare);
                            }
                    }
                    //Revoking opportunity record access from old case owner, if new owner is queue and old owner was user
                    else if (oldCaseMap.get(cs.id).OwnerId != cs.OwnerId && String.valueOf(cs.OwnerId).startsWith('00G') 
                             && String.valueOf(oldCaseMap.get(cs.id).OwnerId).startsWith('005') ) {
                                if(OppList != null && OppList.size() > 0){
                                for(OpportunityShare OS : OppList){
                               if(OS.OpportunityId == cs.OpportunityId__c && OS.UserOrGroupId == oldCaseMap.get(cs.id).OwnerId
                                 	&& OS.RowCause == 'Manual')
                                   {
                                      oppsharedeletelist.add(OS);    
                                   }
                               }
                            }
                    }
                    //Revoking opportunity record access from case owner, if case status is closed, withdrawn or rejected
                    else if (String.valueOf(cs.OwnerId).startsWith('005') &&
                            cs.Status != oldCaseMap.get(cs.id).status && (cs.Status == 'Closed' || cs.Status == 'Withdrawn' || cs.Status == 'Rejected' )) {
                                 if(OppList != null && OppList.size() > 0){
                          		for(OpportunityShare OS : OppList){
                                if(OS.OpportunityId == cs.OpportunityId__c && OS.UserOrGroupId == cs.OwnerId && OS.RowCause == 'Manual')
                                   {
                                      oppsharedeletelist.add(OS);    
                                   }
                           }
                        }
                    }
            }
        
            try{
            if (oppSharelist.size() > 0) {
                insert oppSharelist;
                system.debug('oppSharelist'+oppSharelist);
            }
            if(oppsharedeletelist.size() > 0) {
                delete oppsharedeletelist;
                system.debug('oppsharedeletelist'+oppsharedeletelist);
            }
            }
            catch(Exception e){
                System.debug('ExceptionMessage '+e.getMessage());
            }
        }
    }
    /*
    Jaipur :: DURGA
    Sprint & US: 21.11 & DIGI-2050
    Description: 21.11 & DIGI-2050 : Update Work Order Sharing
    */   
    public static void handleWorkOrder(List<Case> newCases,Map<ID,Case> oldCaseMap){  
        List<workorder> workOrderUpdateList = new List<workorder>();
        List<Case> lstCase = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
        if(newCases != null && newCases.size() > 0)
        {
        for(Case c : newCases){  
            if(c.soc_SFD_Offshore_Restricted__c != oldCaseMap.get(c.id).soc_SFD_Offshore_Restricted__c && 
               (c.RecordTypeId == recId_salesSupportChild || c.RecordTypeId == recId_SFD_Request)) {
        			caseIds.add(c.Id);
                    lstCase.add(c);
            }
          }
        }
        if(caseIds.size() > 0 && lstCase != null && lstCase.size() > 0){
        //Retrieving workorder records based on case with offshore flag    
        List<workorder> lstWorkOrder = [select id,sfd_Offshore_Restricted__c,RecordTypeId,case.soc_SFD_Offshore_Restricted__c 
                                        from workorder where CaseId =: caseIds
                        				AND (RecordTypeId =: recId_ChannelCareWorkOrder OR RecordTypeId =: recId_SFD_WorkOrder_Request)];
    
            if(lstWorkOrder != null && lstWorkOrder.size() > 0){
            	for (workorder wo:lstWorkOrder)
                  {
                     //Set the workorder offshore flag if case offshore flag is set.
                     if(wo.case.soc_SFD_Offshore_Restricted__c == true && wo.sfd_Offshore_Restricted__c== false){
                      		wo.sfd_Offshore_Restricted__c=true;
                      		workOrderUpdateList.add(wo);
                     }
                      //Uncheck the workorder offshore flag if case offshore flag is unchecked.
                      else if(wo.case.soc_SFD_Offshore_Restricted__c == false && wo.sfd_Offshore_Restricted__c== true){
                       		wo.sfd_Offshore_Restricted__c=false;
                       		workOrderUpdateList.add(wo);
                     }
                  }
            try
            	{
                    if(workOrderUpdateList.size() > 0) {
                        update workOrderUpdateList;
                        system.debug('workOrderUpdateList-->'+workOrderUpdateList);
            	}
            }
            catch(Exception e){
                System.debug('ExceptionMessage '+e.getMessage());
            }
         }
     }
   }


      /*
    Jaipur :: Chandrakant
    Sprint & US: 21.12 & DIGI-9990
    Description: 21.12 & DIGI-9990 : Set Basket Number, Opportunity, Contract before case insert/update
                                     for 'Channel care for Partners' recordtype
    */    
 	public static void handlePartnerCase(List<Case> newCases,Map<ID,Case> oldCaseMap){
        if(newCases != null && !newCases.isEmpty()){
           // List<Id> optyList = new List<Id>();
            List<Id> orderList = new List<Id>();
          //  Map<Id,Id> contractMap = new Map<Id,Id>();
            Map<Id,csord__Order__c> orderMap = new Map<Id,csord__Order__c>();

            //create opportunity list related to cases
            for(Case cs:newCases){
                if(cs.ss_Order__c != null)
                orderList.add(cs.ss_Order__c);
            }

            // Query on Order object
            if(!orderList.isEmpty()){
                List<csord__Order__c> orders =  [Select id,Product_Basket__c,Product_Basket__r.Name,csordtelcoa__Opportunity__c from csord__Order__c where id IN :orderList] ;
                for(csord__Order__c ord: orders){
                    orderMap.put(ord.id, ord);
                }
            }

            //Before Case Insert logic
            if(oldCaseMap == Null){
                for(Case cs : newCases){                 
                    if(!orderMap.isEmpty() && cs.RecordTypeId == recId_Channel_care_partners_Request && cs.ss_Type__c=='Digital Product Technical Support')
                    {   
                        //set Basket Number and Opportunity from Order object lookups
                        if(cs.ss_Category__c =='Order Support' && cs.ss_Order__c!=null){
                            if(orderMap.get(cs.ss_Order__c).Product_Basket__c != null)
                            cs.ss_Basket_Number__c = orderMap.get(cs.ss_Order__c).Product_Basket__r.Name;
                            cs.OpportunityId__c = orderMap.get(cs.ss_Order__c).csordtelcoa__Opportunity__c;
                        }
                    }
                }
            }
            
            // Before Case Update logic
            if(oldCaseMap != Null){
                for(Case cs : newCases){
                    if(cs.RecordTypeId == recId_Channel_care_partners_Request && cs.ss_Type__c=='Digital Product Technical Support')
                    {   
                        //set Basket Number and Opportunity from Order object lookups
                        if(cs.ss_Category__c =='Order Support' && cs.ss_Order__c !=oldCaseMap.get(cs.id).ss_Order__c){
                            if(cs.ss_Order__c != null){
                                if(orderMap.get(cs.ss_Order__c).Product_Basket__c != null)
                                cs.ss_Basket_Number__c = orderMap.get(cs.ss_Order__c).Product_Basket__r.Name;
                                cs.OpportunityId__c = orderMap.get(cs.ss_Order__c).csordtelcoa__Opportunity__c;
                            }
                            else{
                                cs.ss_Basket_Number__c = null;
                                cs.OpportunityId__c = null;
                            }                               
                        }
                    }   
                }
            }
        }        
    }
    
    /*
    Jaipur :: DURGA
    Sprint & US: 21.13 & DIGI-12640
    Description: 21.13 & DIGI-12640 : As a Governance Team member I need to return a case to CPE Purple Service Queue so they can perform work on it
    */ 
    @InvocableMethod
    public static void cpePurpleGovernanceOffshoreNotRestricted(List<Id> caseId){
        List<Case> updateCase = new List<Case>();
        If(caseId.size()>0){
            List<Case> caseLst = [Select id,cpe_Governance_Status__c,cpe_CPE_Skills_Set__c,OwnerId,Account.APTPS_Off_Shore_Restricted__c FROM Case WHERE id=:caseId];
            List<Group> QueueId = [Select Id from Group WHERE developerName = 'cpe_Ordering_Hardware' LIMIT 1];
            for(case cs: caseLst){
                if(cs.cpe_Governance_Status__c == 'Sales Support Required'){
                    cs.OwnerId = QueueId[0].id;
                    cs.cpe_CPE_Skills_Set__c = 'Purple - General Enquiry';
                    updateCase.add(cs);
                }
            }
            if(updateCase.size()>0){
                update updateCase;
            }
        }
    }

/*
    Jaipur :: HARSHITA VERMA
    Sprint & US: 21.14 & DIGI-21815
    Description: 21.14 & DIGI-21815 : On Channel care record type for any case created from Telstra Connect the Contact Customer option must be set to YES.
    */ 
    public static void handleTelstraConnectCases(List<Case> newCases){
        for(Case cs : newCases){
            if(cs.RecordTypeId == recId_salesSupportChild && cs.Origin == 'Telstra Connect') {                   
            cs.salesup_Contact_Customer__c = 'Yes';
            }
        }
    }

    /*
    Jaipur :: Chandrakant
    Sprint & US: 21.15 & DIGI-27314
    Description: DIGI-27314: Add Invoice Apex sharing record AFTER CASE INSERT/UPDATE
    */   
    public static void addInvoiceApexShareRecord(List<Case> newCases, Map<ID,Case> oldCaseMap){ 

        List<Invoice__share> invoiceShareList = new List<Invoice__share>();
        List<Invoice__share> deleteInvoiceShareList = new List<Invoice__share>();

        // Invoice record list which mapped to case earlier
        List<Id> existingInvId = new List<Id>();
        // Case Requestor Id list
        List<Id> requestorList = new List<Id>();    

        for(Case cs : newCases){
            
            //check new/old case values type,category, work required
            if((oldCaseMap!=null && oldCaseMap.get(cs.id).ss_Invoice_number__c != cs.ss_Invoice_number__c) ||
               (oldCaseMap ==null && !(String.isBlank(cs.ss_Invoice_number__c))) 
               && cs.RecordTypeId == recId_salesSupportChild && cs.Origin == 'TPC' &&
            cs.ss_Type__c == 'Billing' && (cs.ss_Category__c == 'Request billing changes for the customer' ||
            cs.ss_Category__c == 'Raise a billing query') &&
            (cs.ss_Work_Required__c == 'Goods and Services Tax (GST) requirements' ||
            cs.ss_Work_Required__c == 'Credit transfer' ||
            cs.ss_Work_Required__c == 'Register Electronic Fund Transfer (EFT)' ||
            cs.ss_Work_Required__c == 'Payment transfer' ||
            cs.ss_Work_Required__c == 'Extend bill payment date' ||
            cs.ss_Work_Required__c == 'Request a refund' ||
            cs.ss_Work_Required__c == 'Missing payment enquiry')){

                if(!(String.isBlank(cs.ss_Invoice_number__c)) && !(String.isBlank(cs.Requestor__c))){

                //Create Invoice share record
                Invoice__share invShareRecord =  new Invoice__share();
                //Invoice Number record Id
                invShareRecord.ParentId = cs.ss_Invoice_number__c;
                //Partner User record Id
                invShareRecord.UserOrGroupId = cs.Requestor__c;
                //Access Level 
                invShareRecord.AccessLevel = 'Read';
                //Apex sharing reason
                invShareRecord.RowCause = Schema.Invoice__share.RowCause.TPC_Partner_Access__C;

                invoiceShareList.add(invShareRecord);

                }

                //Create List of existing Invoice record Id assigned to case
                if(oldCaseMap!=null && oldCaseMap.get(cs.id).ss_Invoice_number__c !=null){
                    existingInvId.add(oldCaseMap.get(cs.id).ss_Invoice_number__c);
                    requestorList.add(cs.Requestor__c);
                }
            }
        }
        if(invoiceShareList.size() > 0){
            insert invoiceShareList;
        }

        //Logic to Delete InvoiceShare record After Case Update
        if(oldCaseMap!=null && existingInvId.size()>0 && requestorList.size()>0){           

            //Invoice record list which not mapped to any case
            List<Id> noMappedInvoiceIdList = new List<Id>();
            
            AggregateResult[] groupedResults = [Select ss_Invoice_number__c, count(id)casecount, Requestor__c from Case 
                            Group BY ss_Invoice_number__c, Requestor__c 
                            HAVING ss_Invoice_number__c IN :existingInvId
                            AND Requestor__c IN :requestorList];
            System.debug('groupedResults' + groupedResults);

            //List of invoice id which mapped to multiple cases
            List<Id> commonInvIdList = new List <id>();            
            for (AggregateResult ar : groupedResults)  {
                String str = String.valueOf(ar.get('casecount')) ;
                Integer varCaseCount = Integer.valueOf(str) ;
                if(varCaseCount > 0){
                    String str1 = String.valueOf(ar.get('ss_Invoice_number__c')) ;
                    Id invId = (Id) str1 ;
                    commonInvIdList.add(invId);
                }
            }			
            System.debug('commonInvIdList:'+commonInvIdList);
            //Filter common Invoice record id from all invoice list
            if(commonInvIdList.size() > 0){
                for(Id varId : existingInvId){
                    if(!(commonInvIdList.contains(varId))){
                        noMappedInvoiceIdList.add(varId);
                    }
                }
            }else{
                noMappedInvoiceIdList.addAll(existingInvId);
            }
            System.debug('noMappedInvoiceIdList:'+noMappedInvoiceIdList);
			
            //Query to fetch InvoiceShare record which shared with partner earlier
            if(noMappedInvoiceIdList.size()>0){
                deleteInvoiceShareList = [Select id,ParentId,RowCause from Invoice__share where parentId =: noMappedInvoiceIdList 
                AND RowCause =: Schema.Invoice__share.RowCause.TPC_Partner_Access__C];
            }
			 System.debug('deleteInvoiceShareList:'+deleteInvoiceShareList);
            //delete apex invoiceShare record
            if(deleteInvoiceShareList.size() > 0){
                delete deleteInvoiceShareList;
            }
        }
    }
}