/****
* Created By : Vijay
* Date : 26/02/018
* Description: helper class to handle logic for lead trigger.
* Last Modify : SFO SPRINT-19.04 EDGE-68196 To update Customer Name And Contact Name on Update of CIDN and 
*               Contact ID Respectively
                Modified on 10/03/2020 as part of P2OB-5238 Sprint 20.04
* Last MOdified BY : Padma Pallavi
*Updates - 
* 1. 1-May-2020    Team Hawaii    P2OB-6059 : Team Hawaii : Adding one more condition for allowing lead-conversion by partner-users 
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.

* 2. 29-Jan-2021   Team Hawaii P2OB-11658 As a Partner Principal/Partner Sales Manager, I should receive an email listing all leads shared with my partner account
* 3. 25/08/2021    Team SFO    DIGI-3187(S21.12)      Created method of assignAccTeamMemToOwnerId method.
@Last Modified	:   15/09/2021 21.13 by Chhaveel, Team SFO
					as part of DIGI-5740, E&G Leads to be assigned based on the new FY22 rules
                    29/10/2021 21.15 by Pallavi B, Team SFO
					as part of DIGI-34437

* *****/
public without sharing class LeadTriggerHelper {
    public static boolean isRec=false;
    public static boolean isRecACR=false;
    public static boolean isRecupdateCustomerContactName=false;
    public static set<Id> setLeadsProcessedInTransaction = new set<Id>();
    
    //Added as part of DIGI-3187 and DIGI-33489.Starts here
    public static boolean isRecinsertupdateassignOwnerId=false;
    private static Map<Id,Account> accontIdsMap = new Map<Id,Account>();
    private static Map<Id,Id> accmUserId = new Map<Id,Id>();
    //Ends here.
    
    //Migration Lead Record Type.Added as part of DIGI-34437 S21.15
    public static Id leadMigrationRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Migration).getRecordTypeId();

    // Variables created as part of vantageLeadOwnerAssignment(Method) for P2OB-6755 sprint 20.08
    map<id,Account> accontIdMap = new map<id,Account>();
    map<string,Account> accCIDNMap = new map<string,Account>();
    List<ID> leadAccountId = new List<ID>();
    List<String> strCIDN = new List<String>();
    List<Account> accDetails = new List<Account>();
    
    //helper Method to map country and region
    public static void mapCountryAndRegion(list<lead> newLeads){
        Map<String, Countries_region__c> countryRegionMap=Countries_region__c.getAll();//get all country and region mapping
        for(lead l:newLeads){
            if(l.country__c!=null){
                if(countryRegionMap.containsKey(l.country__c.toUpperCase('en_AU')))// check if country present in the mapping
                {
                    l.Region__c=countryRegionMap.get(l.country__c.toUpperCase('en_AU')).region__c;//assign region to lead
                }
            }
        }
    }
    
    /* SFO EDGE-37935  */
    Public void createCamInflOnLeadconvert (List<Lead> leadList){
        Map<Id,Lead> ledMap = New Map<Id,Lead>();
        List<CampaignInfluence> camInfluenceList = new List<CampaignInfluence>();
        List<Lead> convertedLeadLst = new  List<Lead>();
        try{
            if(isRec!=true){
                isRec=true;
                if(leadList.size()>0){
                    for(lead led:leadList){
                        if(led.IsConverted && led.ConvertedDate!=null && (date.today().isSameDay(led.ConvertedDate))){
                            convertedLeadLst.add(led);
                            ledMap.put(led.id,led);
                        }                    
                    }
                    if(ledMap.keyset().size()>0){
                        List<CampaignMember> memLst1 = [SELECT CampaignId,LeadId FROM CampaignMember WHERE LeadId = :ledMap.keyset()];
                        if(memLst1.size()>0){
                            Map<Id,List<id>> leadCamListMap=new  Map<Id,List<id>>();
                            for(CampaignMember cm:memLst1){
                                if(!String.isEmpty(cm.LeadId)&& cm.LeadId!=null){
                                    List<id> cmlist=leadCamListMap.get(cm.LeadId);
                                    if(null==cmlist){
                                        cmlist=new List<id>();
                                        leadCamListMap.put(cm.LeadId,cmlist);
                                    }
                                    cmlist.add(cm.CampaignId);
                                }
                            }
                            
                            if(memLst1.size()>0 && leadCamListMap.values().size()>0){                                
                                Set<Id> setCamIdset=new Set<Id>();
                                for(Lead lead:leadList){
                                    if(lead.IsConverted && lead.ConvertedDate!=null && (date.today().isSameDay(lead.ConvertedDate))){                                        
                                        setCamIdset.addAll(leadCamListMap.get(lead.Id));                                         
                                    }
                                }                                
                                List<CampaignInfluence> oldListCamInflu=new  List<CampaignInfluence>();
                                if(setCamIdset.size()>0){
                                    oldListCamInflu=[SELECT CampaignId,ContactId,Id,Influence,IsDeleted,ModelId,OpportunityId FROM CampaignInfluence WHERE IsDeleted=false AND CampaignId In : setCamIdset];
                                }
                                for(Lead lead:leadList){
                                    if(lead.IsConverted && lead.ConvertedDate!=null && (date.today().isSameDay(lead.ConvertedDate))){
                                        Set<Id> setCamIds=new Set<Id>();                                        
                                        setCamIds.addAll(leadCamListMap.get(lead.Id));                                
                                        if(setCamIds.size()>0){                                            
                                            Double influence=100.00/setCamIds.size();
                                            for(ID id : setCamIds){                                                
                                                if(!String.isEmpty(lead.ConvertedOpportunityId) && lead.ConvertedOpportunityId!=null){                                                                                                      
                                                    If(oldListCamInflu.size()>0 && !oldListCamInflu.isEmpty()){                                                        
                                                        if(isContain(id,lead.ConvertedOpportunityId,lead.ConvertedContactId,oldListCamInflu)==true){
                                                            CampaignInfluence newCI = new CampaignInfluence();
                                                            newCI.modelId = System.Label.SecondaryCampaignSourceModel;//'03V2P0000000006UAA';
                                                            newCI.campaignId = id;                                                            
                                                            newCI.opportunityId = lead.ConvertedOpportunityId;                                                            
                                                            newCI.Influence = influence;
                                                            newCI.contactId = lead.ConvertedContactId;                                                            
                                                            camInfluenceList.add(newCI);                                                            
                                                        }
                                                    }                                                    
                                                    if(oldListCamInflu.isEmpty()){
                                                        CampaignInfluence newCI = new CampaignInfluence();
                                                        newCI.modelId = System.Label.SecondaryCampaignSourceModel;//'03V2P0000000006UAA';
                                                        newCI.campaignId = id;                                                        
                                                        newCI.opportunityId = lead.ConvertedOpportunityId;                                                        
                                                        newCI.Influence = influence;
                                                        newCI.contactId = lead.ConvertedContactId;                                                        
                                                        camInfluenceList.add(newCI);
                                                    }
                                                }
                                            }
                                        }
                                    }  
                                }
                                //P2OB-6059 : Team Hawaii : Adding one more condition for allowing lead-conversion by partner-users 
                                if(camInfluenceList.size()>0 && (Schema.sObjectType.CampaignInfluence.isCreateable() || (UserInfo.getUserType().equalsIgnoreCase('PowerPartner')))){
                                    set<CampaignInfluence> ciset=new set<CampaignInfluence>();
                                    ciset.addAll(camInfluenceList);
                                    List<CampaignInfluence> ciList=new List<CampaignInfluence>();
                                    ciList.addAll(camInfluenceList);
                                    Database.insert(ciList,false); 
                                }
                            }
                        }
                    }
                }
            }
        }catch(QueryException Ex){
            system.debug('QueryException:--->LeadTriggerHelper Class,createCamInflOnLeadconvert Method'+ Ex.getMessage());
        }
        catch(DMLException Ex){
            system.debug('DMLException:--->LeadTriggerHelper Class,createCamInflOnLeadconvert Method'+ Ex.getMessage());
        }
    }  
    
    public boolean isContain(Id campaignId,Id contactId,Id opportunityId,List<CampaignInfluence> oldListCamInflu){
        boolean iscreateCmInfluenceRec=false;
        if(oldListCamInflu.size()>0){
            for(CampaignInfluence cif : oldListCamInflu){
                if(cif.CampaignId==campaignId  ){
                    if(cif.OpportunityId==opportunityId && cif.ContactId!=contactId){
                        iscreateCmInfluenceRec=true;                        
                    }
                    else if(cif.OpportunityId==opportunityId && cif.ContactId==contactId){
                        iscreateCmInfluenceRec=false;                        
                    }
                    else if(cif.OpportunityId!=opportunityId && cif.ContactId!=contactId){
                        iscreateCmInfluenceRec=true;                        
                    }
                    else if(cif.OpportunityId!=opportunityId && cif.ContactId==contactId){
                        iscreateCmInfluenceRec=false;                        
                    }
                }
                if(cif.CampaignId!=campaignId && cif.OpportunityId!=opportunityId ){
                    if(cif.OpportunityId!=opportunityId && cif.ContactId!=contactId){
                        iscreateCmInfluenceRec=true;                        
                    }
                    else if(cif.OpportunityId==opportunityId && cif.ContactId==contactId){
                        iscreateCmInfluenceRec=false;                        
                    }
                    else if(cif.OpportunityId!=opportunityId && cif.ContactId==contactId){
                        iscreateCmInfluenceRec=true;                        
                    }
                    else if(cif.OpportunityId==opportunityId && cif.ContactId!=contactId){
                        iscreateCmInfluenceRec=true;                        
                    }                    
                } 
            }
        }
        return iscreateCmInfluenceRec;
    }
    
        
/****************************************************************************
    @Method Name: vantageLeadOwnerAssignment
    @Author: SFO/Amar,pallavi
    @Sprint :sprint 20.08 [P2OB-6755]
    @CreateDate: 12/06/2020
    @Description: <Vantage><Marketing> As A Sales User I want Enterprise & Government leads to be assigned to a Domain queue 
                   and notification will be sent to queue owners
	Input parameters:  List<Lead> leadlist,
                       Map<id,Lead> oldLeadMap
	Output: Assigninf Account owner to Lead Owner.
    @Modified Sprint & Reason : 10/03/2021 Sprint 20.04 P2OB-12075. MOdified the record type calling with developer name.
    @Modified Author : SFO/Pallavi
	@Last Modified	:   15/09/2021 21.13 by Chhaveel, Team SFO
						as part of DIGI-5740 , Commented out the below method
******************************************************************************/     
/*
public void vantageLeadOwnerAssignment(List<Lead> leadlist, Map<id,Lead> oldLeadMap){
    if(stopRecursiveOnInsertUpdate != true)   { 
         stopRecursiveOnInsertUpdate =true;
		try{
			Id leadEnterpriseRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
			for(lead objLead : leadlist){
				if(objLead.RecordTypeId == leadEnterpriseRecordType){
					string ownerId = objLead.ownerid;
					boolean userCheck =(oldLeadMap!=null && (!oldLeadMap.isEmpty() && ownerId.LEFT(3) == '005'));
					boolean nameCidnNotNullCheck = (objLead.Customer_Name__c == null && objLead.cidn__c == null);

                    
					if(userCheck){
						objLead.Lead_Owner_Check__c = True;
					}
					if(!nameCidnNotNullCheck){
						if(objLead.Customer_Name__c !=null){
							leadAccountId.add(objLead.Customer_Name__c);
						}
                        
						else if(objLead.cidn__c != null){
							strCIDN.add(objLead.cidn__c);
						}
					}
				}
			}
			            vantageLeadRelatedAcc();
		              	vantageLeadDomainSegCheck(leadlist);
						
		}catch(Exception Ex){
			system.debug('Exception:--->LeadTriggerHelper Class,vantageLeadOwnerAssignment'+ Ex.getMessage());
		}
    }
}
*/
    
/****************************************************************************
    @Method Name: vantageLeadRelatedAcc
    @Author: SFO/Amar,pallavi
    @Sprint :sprint 20.08 [P2OB-6755]
    @CreateDate: 15/06/2020
    @Description: <Vantage><Marketing> As A Sales User I want Enterprise & Government leads to be assigned to a
                   Domain queue and notification will be sent to queue owners
	Input parameters: NA
	Output: Getting Account Name and CIDN from Account Related to Lead.
	@Last Modified	:   15/09/2021 21.13 by Chhaveel, Team SFO
						as part of DIGI-5740 , Commented out the below method
******************************************************************************/   
/*
public void vantageLeadRelatedAcc(){
			if(!leadAccountId.isEmpty()){
				accontIdMap.putall([SELECT id,name,cidn__c,ownerid,APTPS_Tier__c FROM account WHERE id IN :leadAccountId]);
					}
			if(!strCIDN.isEmpty()){
				accDetails = [SELECT id,name,cidn__c,ownerid,APTPS_Tier__c FROM account WHERE cidn__c IN :strCIDN];
			}
			if(!accDetails.isEmpty()){
				for(Account acc : accDetails){
					accCIDNMap.put(acc.cidn__c,acc);
				}  
			}
}
*/
    
/****************************************************************************
    @Method Name: vantageLeadDomainSegCheck
    @Author: SFO/Amar,pallavi
    @Sprint :sprint 20.08 [P2OB-6755]
    @CreateDate: 15/06/2020
    @Description: <Vantage><Marketing> As A Sales User I want Enterprise & Government leads to be assigned to a 
                   Domain queue and notification will be sent to queue owners
	Input parameters: List<Lead> leadlist
	Output: Making Lead Owner Check too true along with Assignment of Account Owner to Lead Owner
	@Last Modified	:   15/09/2021 21.13 by Chhaveel, Team SFO
						as part of DIGI-5740 , Commented out the below method
******************************************************************************/       
/*
public void vantageLeadDomainSegCheck(List<Lead> leadlist){
        Boolean leadAccNameCheck = False;
        Boolean leadAccCidnCheck = False;
		for(lead leadassign : leadlist){
            if(!accontIdMap.isEmpty() && accontIdMap.containsKey(leadassign.Customer_Name__c)){
                leadAccNameCheck = (leadassign.Customer_Name__c != null && leadassign.domains__c == null && accontIdMap.get(leadassign.Customer_Name__c).APTPS_Tier__c == System.Label.AccountSegmentEntAndGovt);
                if(leadAccNameCheck){
                leadassign.OwnerId = accontIdMap.get(leadassign.Customer_Name__c).OwnerId;                
                leadassign.Lead_Owner_Check__c = True;
                }
            }
            else if(!accCIDNMap.isEmpty() && accCIDNMap.containsKey(leadassign.cidn__c)){
                leadAccCidnCheck =(leadassign.cidn__c != null && leadassign.domains__c == null && accCIDNMap.get(leadassign.cidn__c).APTPS_Tier__c == System.Label.AccountSegmentEntAndGovt);
                if(leadAccCidnCheck){
                    leadassign.OwnerId = accCIDNMap.get(leadassign.cidn__c).OwnerId;
                    leadassign.Lead_Owner_Check__c = True;
                }
            }
        }
}
*/    
    
    /****************  Sprint 19.04 EDGE-68196 To update Customer Name And Contact Name on Update of CIDN and Contact ID Respectively   ********************/
    Public void updateCustomerContactName(List<Lead> leadlist, Map<id,Lead> oldLeadMap){ 
        try{
            if(isRecupdateCustomerContactName!=true){
                isRecupdateCustomerContactName=TRUE;
                if(leadlist.size()>0){
                    List<String> lCIDN = new List<String>();
                    List<Account> accDetails = new List<Account>();
                    Map<String,Account> accCIDNMap = new Map<String,Account>();
                    
                    List<ID> contactId = new List<ID>();
                    List<Contact> conDetails = new List<Contact>();
                    Map<ID,Contact> conMap = new Map<ID,Contact>();
                    
                    List<ID> leadAccountId = new List<ID>();
                    List<Account> leadAccountDetails = new List<Account>();
                    Map<ID,Account> accIDMapgetCIDN = new Map<ID,Account>();
                    
                    List<ID> leadContactID = new List<ID>();
                    
                    Id leadEnterpriseRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
                    
                    
                    for(lead nl : leadlist){
                        if(nl.RecordTypeId == leadEnterpriseRecordType){
                            
                            if(nl.cidn__c != null && ((oldLeadMap == Null || nl.cidn__c != oldLeadMap.get(nl.Id).cidn__c) || (oldLeadMap == Null || nl.Customer_Name__c != oldLeadMap.get(nl.Id).Customer_Name__c))){
                                lCIDN.add(nl.cidn__c);
                            }
                            if(nl.Contact_Id__c != null && ((oldLeadMap == Null || nl.Contact_Id__c != oldLeadMap.get(nl.Id).Contact_Id__c ) || (oldLeadMap == Null || nl.Contact_Name__c != oldLeadMap.get(nl.Id).Contact_Name__c ))){
                                contactId.add(nl.Contact_Id__c);
                            }
                            if(nl.Customer_Name__c !=null && (oldLeadMap == Null || nl.Customer_Name__c != oldLeadMap.get(nl.Id).Customer_Name__c) || (oldLeadMap == Null || nl.cidn__c != oldLeadMap.get(nl.Id).cidn__c)){
                                leadAccountId.add(nl.Customer_Name__c);
                            }
                            if(nl.Contact_Name__c != null && ((oldLeadMap == Null || nl.Contact_Name__c != oldLeadMap.get(nl.Id).Contact_Name__c) || (oldLeadMap == Null || nl.Contact_Id__c != oldLeadMap.get(nl.Id).Contact_Id__c) )){
                                leadContactID.add(nl.Contact_Name__c);
                            }
                        }
                    }
                    
                    if(!lCIDN.isEmpty()){
                        accDetails = [SELECT id,name,cidn__c,ownerid,APTPS_Tier__c FROM account WHERE cidn__c IN :lCIDN];
                    }
                    if(!contactId.isEmpty()){
                        conDetails = [SELECT id FROM contact WHERE id IN :contactId];
                    }
                    if(!leadAccountId.isEmpty()){
                        leadAccountDetails = [SELECT id,name,cidn__c,ownerid,APTPS_Tier__c FROM account WHERE id IN :leadAccountId];
                    }
                    /******Fetching Details if exists putting the same in Map variable to refer further******/
                    if(!accDetails.isEmpty()){
                        for(Account acc : accDetails){
                            accCIDNMap.put(acc.cidn__c,acc);
                        }                  
                    }
                    
                    if(!conDetails.isEmpty()){
                        for(Contact con : conDetails){
                            conMap.put(con.id,con);
                        }  
                    }
                    
                    if(!leadAccountDetails.isEmpty()){
                        for(Account lacc : leadAccountDetails){
                            accIDMapgetCIDN.put(lacc.id,lacc);
                        }
                    }
                    
                    for(lead nLead : leadlist){
                        if(nlead.RecordTypeId == leadEnterpriseRecordType){

                            /********Populating CIDN, Tier Values based on Account Name Selected and Changing Lead Owner Based on Tier Values **********/
                            if((nLead.Customer_Name__c != null && nLead.cidn__c == null && accIDMapgetCIDN.containsKey(nlead.Customer_Name__c))|| (nLead.Customer_Name__c != null && nLead.cidn__c != null && accIDMapgetCIDN.containsKey(nlead.Customer_Name__c))){
                                nlead.cidn__c = accIDMapgetCIDN.get(nLead.Customer_Name__c).cidn__c;
                                
                            }
                            /********Populating Account/Customer Name based on CIDN value selected and Changing Lead Owner Based on Tier Values****************/
                            else if(nLead.cidn__c != null && accCIDNMap.containskey(nLead.cidn__c)){
                                nlead.Customer_Name__c = accCIDNMap.get(nLead.cidn__c).Id;
                                
                            }
                            /********* Populating Contact ID based on COntact Name Selected ****************/
                            if(nLead.Contact_Name__c != null && nLead.Contact_Id__c == null && leadContactID.contains(nLead.Contact_Name__c) || (nLead.Contact_Id__c != null && nLead.Contact_Name__c != null && leadContactID.contains(nLead.Contact_Name__c))){
                                nlead.contact_id__c = nlead.Contact_Name__c;
                            }
                            /**********Populating Contact Name Based on Contact ID ************************************/
                            else if((nLead.Contact_Id__c != null && nLead.Contact_Name__c == null && conMap.containsKey(nLead.Contact_Id__c))){
                                nlead.Contact_Name__c = conMap.get(nLead.Contact_Id__c).Id;
                            }
                        }
                    }
                }
            }
        }catch(QueryException Ex){
            system.debug('QueryException:--->LeadTriggerHelper Class,updateCustomerContactName'+ Ex.getMessage());
        }
        catch(DMLException Ex){
            system.debug('DMLException:--->LeadTriggerHelper Class,updateCustomerContactName'+ Ex.getMessage());
        }
    }

    /* Sprint 21.02 P2OB-11658 As a Partner Principal/Partner Sales Manager, I should receive an email listing all leads shared with my partner account */
    public void proessBulkEmailDuringInsert(map<Id,Lead> newLeadMap){ 
        list<Id> lstLeadsToProcess = new list<Id>();
        for(Lead objL : newLeadMap.values()){
            if(objL.Trigger_Share_with_Partner__c && !objL.isBulkSharedLead__c 
            && objL.PartnerAccountId != null){
                lstLeadsToProcess.add(objL.Id);
            }
        }
        if(!lstLeadsToProcess.isEmpty()){
            Database.executeBatch(new PRMLeadBulkShareNotificationBatch(lstLeadsToProcess));
        }
    } // end of afterInsert

    /* Sprint 21.02 P2OB-11658 As a Partner Principal/Partner Sales Manager, I should receive an email listing all leads shared with my partner account */
    public void proessBulkEmailDuringUpdate(list<Lead> newLead, map<Id,Lead> oldLeadMap){ 
        list<Id> lstLeadsToProcess = new list<Id>();
        for(Lead led : newLead){
            if(!setLeadsProcessedInTransaction.contains(led.Id)){
                if(led.Trigger_Share_with_Partner__c && led.PartnerAccountId != null && !led.isBulkSharedLead__c
                && led.Trigger_Share_with_Partner__c != oldLeadMap.get(led.Id).Trigger_Share_with_Partner__c){
                    lstLeadsToProcess.add(led.Id);
                    setLeadsProcessedInTransaction.add(led.Id);
                }
            }
        }
        if(!lstLeadsToProcess.isEmpty()){
            Database.executeBatch(new PRMLeadBulkShareNotificationBatch(lstLeadsToProcess));
        }
    } // end of afterUpdate
    
  
/****************************************************************************
    @Method Name: assignAccTeamMemToOwnerId
    @Author: SFO/pallavi
    @Sprint :sprint 21.12 [DIGI-3187]
    @CreateDate: 23/08/2021
    @Description: 
	Input parameters: List<Lead> leadlist ,Map<id,Lead> oldLeadMap
	Output: Making Lead Owner to Account Team Member with Role Opportunity Approver or NBC Engage Lead Queue.
    @Modified Info: DIGI-33489 S21.15
******************************************************************************/ 
    public void assignAccTeamMemToOwnerId(List<Lead> leadlist, Map<id,Lead> oldLeadMap){
        Set<Id> accIdOnLead = new Set<Id>();
        List<Group> queueList = new List<Group>();
        List<AccountTeamMember> acctTeamMemUsersLst = new List<AccountTeamMember>();
        //Added as part of DIGI-33489 S21.15.starts here
        Boolean checkAccScenrio;
        Boolean checkforInsert;
        Boolean checkforUpdate;
        //ends here
        Id leadEnterpriseRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        if(!isRecinsertupdateassignOwnerId){//Added as part of DIGI-33489 S21.15
        try{
            for(lead objLead : leadlist){
                if(objLead.RecordTypeId == leadEnterpriseRecordType && objLead.Customer_Name__c != null){
                    accIdOnLead.add(objLead.Customer_Name__c);
                }
            }
            
            if(!accIdOnLead.isempty()){
                accontIdsMap = getAccountMap(accIdOnLead);
            }
            if(!accontIdsMap.isempty()){
                acctTeamMemUsersLst = SFO_TeamMemberUtil.getAccountTeamMembers(accontIdsMap.keyset(),System.Label.AccountTeamMemberOpportunityApprover);
                for(AccountTeamMember atm:acctTeamMemUsersLst){
                    if(accmUserId.containsKey(atm.AccountId)){
                        accmUserId.get(atm.AccountId); 
                    }else{
                        accmUserId.put(atm.AccountId, atm.userId);
                    }
                }
            }
            
            queueList = [select Id from Group where Type = 'Queue' AND developerName =:System.Label.QueueBCSLeadQueue];
            
            for(lead la : leadlist){
                //Added as part of DIGI-33489 S21.15.starts here
                checkAccScenrio = ( !accontIdsMap.isEmpty() && accontIdsMap.containsKey(la.Customer_Name__c) && accontIdsMap.get(la.Customer_Name__c) != null && 
                                   accontIdsMap.get(la.Customer_Name__c).APTPS_Tier__c !=null && accontIdsMap.get(la.Customer_Name__c).APTPS_Tier__c ==System.Label.AccountSegmentMidMarket && 
                                   accontIdsMap.get(la.Customer_Name__c).Vertical__c != null && accontIdsMap.get(la.Customer_Name__c).Vertical__c ==System.Label.AccountVerticalNBCGrowth );

                checkforInsert = (oldLeadMap==null);
                checkforUpdate =  (oldLeadMap!= null && 
                                   oldLeadMap.containsKey(la.Id) && 
                                   oldLeadMap.get(la.Id).Customer_Name__c != la.Customer_Name__c);
                //ends here.
                    if(checkAccScenrio && (checkforInsert || checkforUpdate)){ //Added as part of DIGI-33489 S21.15
                        if(accmUserId.get(la.Customer_Name__c) != null){
                            la.OwnerId = accmUserId.get(la.Customer_Name__c);
                            la.Lead_Owner_Check__c = True; //Added as part of DIGI-33489 S21.15

                        }else{
                            if(!queueList.isEmpty()){
                            la.OwnerId = queueList[0].id;
                            la.Lead_Owner_Check__c = True; //Added as part of DIGI-33489 S21.15

                        }
                    }
                }                
            }
        } catch(Exception ex){
            system.debug('Exception in LeadTriggerHelper Class :: assignAccTeamMemToOwnerId  method ::: '+ex.getMessage());
        } 
        
        isRecinsertupdateassignOwnerId = true; //Added as part of DIGI-33489 S21.15
       }
    }
    
/****************************************************************************
    @Method Name: customLeadRouting
    @Author: SFO/Chhaveel
    @Sprint :sprint 21.13 [DIGI-5740]
    @CreateDate: 15/09/2021
    @Description: E&G Leads to be assigned based on the new FY22 rules
******************************************************************************/       
    public void customLeadRouting(List<Lead> leadlist,Map<id,Lead> oldLeadMap){
        Set<Id> accIdLeadNS = new Set<Id>(); // for account of Leads with Network Solutions Domain
        Set<Id> accIdLeadMMS = new Set<Id>(); // for account of Leads with Mobility & Managed Services or NULL Domain
        List<Lead> leadDomainNS = new List<Lead>(); //Leads with Network Solutions Domain
        List<Lead> leadDomainMMS = new List<Lead>(); //Leads with Mobility & Managed Services or NULL Domain
        Id leadEnterpriseRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        try{
            //START  For Loop 
            for(lead objLead : leadlist){
                if(objLead.RecordTypeId == leadEnterpriseRecordType){
                    //Added as part of DIGI-33489 S21.15.starts here
                    boolean beforeInsert = (oldLeadMap ==null);
                    boolean beforeUpdate = (oldLeadMap!=null && objLead.Customer_Name__c!= oldLeadMap.get(objLead.Id).Customer_Name__c);
                    //ends here
                    if(objLead.Domains__c == System.Label.Lead_Domain_Network_Solutions && objLead.Customer_Name__c!=null && (beforeInsert||beforeUpdate)){
                        // Filtering out the Leads with Network Solutions Domain
                        accIdLeadNS.add(objLead.Customer_Name__c);
                        leadDomainNS.add(objLead);
                    }
                    if(((objLead.Domains__c == System.Label.LeadDomainMobility_Managed_Services || objLead.Domains__c == '' 
                        || objLead.Domains__c == null ) && objLead.Customer_Name__c != null ) && (beforeInsert||beforeUpdate)){//Added as part of DIGI-33489 S21.15.
                            // Filtering out the Leads with Mobility & Managed Services or NULL Domain
                            accIdLeadMMS.add(objLead.Customer_Name__c);
                            leadDomainMMS.add(objLead);
                        }
                }            
            } // END For Loop

            if(!accIdLeadNS.isEmpty()){
                // Calling the method to route Lead with Network Solution Domain 
                customLeadRoutingNS(leadDomainNS,accIdLeadNS);
            }
            if(!accIdLeadMMS.isEmpty()){
                // Calling the method to route Lead with Mobility & Managed Services or NULL Domain 
                customLeadRoutingMMS(leadDomainMMS,accIdLeadMMS);
            }
        } catch(Exception ex){
            system.debug('Exception in LeadTriggerHelper Class :: customLeadRouting  method ::: '+ex.getMessage());
        }
    }
/****************************************************************************
    @Method Name: customLeadRoutingNS
    @Author: SFO/Chhaveel
    @Sprint :sprint 21.13 [DIGI-5740]
    @CreateDate: 15/09/2021
    @Description: Routing the leads with Network Solutions Domain
******************************************************************************/       
    public void customLeadRoutingNS(List<Lead> nsLeads, Set<Id> accIDNS){
        List<AccountTeamMember> accTeamMemLst = new List<AccountTeamMember>();// for user in related account's team
        List<Group> queueList = new List<Group>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Id> accmUserIdNS = new Map<Id,Id>();
        try{
            if(!accIDNS.isempty()){
                accMap = getAccountMap(accIDNS);
            }
            if(!accMap.isempty()){
                // Fetching the Account Team Member with Network Sales Specialist Role
                accTeamMemLst = SFO_TeamMemberUtil.getAccountTeamMembers(accMap.keyset(),System.Label.Account_Team_Member_Role_Network_Sales_Specialist);
                // START
                for(AccountTeamMember atm:accTeamMemLst){  
                    if(accmUserIdNS.containsKey(atm.AccountId)){
                        accmUserIdNS.get(atm.AccountId); 
                    }else{
                        accmUserIdNS.put(atm.AccountId, atm.userId);
                    }
                }//END
            }
            
            queueList = [select Id,developerName from Group where Type = 'Queue' and developerName  =: System.Label.Queue_Network_Solutions_Lead_Queue];
            for(lead leadNS : nsLeads){
                // Checking if the Lead Domain is Network_Solutions with related account's Segment value Enterprise & Government
                if(!accMap.isEmpty() && accMap.containsKey(leadNS.Customer_Name__c) && accMap.get(leadNS.Customer_Name__c) != null
                   && accMap.get(leadNS.Customer_Name__c).APTPS_Tier__c == System.Label.AccountSegmentEntAndGovt
                   && leadNS.Domains__c != null && leadNS.Domains__c == System.Label.Lead_Domain_Network_Solutions){ 
                       if(accmUserIdNS.get(leadNS.Customer_Name__c) != null){
                           //  Making user in Account Team with Network Sales Specialist Role the Lead Owner
                           leadNS.OwnerId = accmUserIdNS.get(leadNS.Customer_Name__c);
                            leadNS.Lead_Owner_Check__c = True;
                       }else{
                           if(!queueList.isEmpty()){
                               //  if usernot in account Team then assigning lead to Network_Solutions_Lead_Queue queue
                               leadNS.OwnerId = queueList[0].id;
                                leadNS.Lead_Owner_Check__c = True;
                           }
                       }
                   }
            }   
        } catch(Exception ex){
            system.debug('Exception in LeadTriggerHelper Class :: customLeadRoutingNS  method ::: '+ex.getMessage());
        }
    }
    
/****************************************************************************
    @Method Name: customLeadRouting
    @Author: SFO/Chhaveel
    @Sprint :sprint 21.13 [DIGI-5740]
    @CreateDate: 15/09/2021
    @Description: Routing the leads with 'Mobility & Managed Services' or 'Blank' or 'NULL' Domain
******************************************************************************/       
    public void customLeadRoutingMMS(List<Lead> leadlst, Set<Id> accIDMMS){
        List<Account> accIdLst = new List<Account>();
        Set<String> accPortCodes = new Set<String>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<String,Id> CPUser = new Map<String,Id>();
        Map<String,Id> GMUser = new Map<String,Id>();
        Map<String,Id> GAOUser = new Map<String,Id>();
        list<UserTerritory2Association> userToAssignOwner = new list<UserTerritory2Association>();
        try{
            if(!accIDMMS.isEmpty()){
                accMap = getAccountMap(accIDMMS);
            }
            if(!accMap.isEmpty()){
                for(Account acc : accMap.Values()){
                    accPortCodes.add(acc.Portfolio_Code__c);
                }			
            }
            // Fetching the User from territory with role 'Client_Partner' & 'General_Manager' & 'Group_Account_Owner'
            userToAssignOwner = [SELECT id, userid, user.Name, RoleInTerritory2, Territory2.Name FROM UserTerritory2Association
                                 WHERE Territory2.Name IN :accPortCodes AND (RoleInTerritory2 =: System.Label.Territory_Role_Client_Partner 
                                                                             OR RoleInTerritory2 =: System.Label.Territory_Role_General_Manager
                                                                             OR RoleInTerritory2 =: System.Label.Territory_Role_Group_Account_Owner) ];
            if(!userToAssignOwner.isempty()){
                //START for loop
                for(UserTerritory2Association uta : userToAssignOwner){
                    // updating the Map with Account portfolio code and Client_Partner Territory Role
                    if(uta.RoleInTerritory2 == System.Label.Territory_Role_Client_Partner){
                        CPUser.put(uta.Territory2.Name , uta.UserId);
                    } 
                    // updating the Map with Account portfolio code and General_Manager Territory Role
                    else if(uta.RoleInTerritory2 == System.Label.Territory_Role_General_Manager){
                        GMUser.put(uta.Territory2.Name , uta.UserId);
                    } 
                    // updating the Map with Account portfolio code and Group_Account_Owner Territory Role
                    else if(uta.RoleInTerritory2 == System.Label.Territory_Role_Group_Account_Owner){
                        GAOUser.put(uta.Territory2.Name , uta.UserId);
                    }
                } //END for loop
            }
            
             //START for loop
            for(lead leadMMS : leadlst){
                // Checking if the Lead Domain is Mobility & Managed Services or NULL with related account's Segment value Enterprise & Government
               
                if(!accMap.isEmpty() && accMap.containsKey(leadMMS.Customer_Name__c) && accMap.get(leadMMS.Customer_Name__c) != null
                   && accMap.get(leadMMS.Customer_Name__c).APTPS_Tier__c == System.Label.AccountSegmentEntAndGovt
                   && (leadMMS.Domains__c == System.Label.LeadDomainMobility_Managed_Services
                       ||  leadMMS.Domains__c == null ||  leadMMS.Domains__c == '')) {
                           String portCode=accMap.get(leadMMS.Customer_Name__c).Portfolio_Code__c;
                           if(CPUser.containsKey(portCode)){
                               //if user with Client Partener role is present in Territory making that lead owner
                               leadMMS.OwnerId = CPUser.get(portCode);
                               leadMMS.Lead_Owner_Check__c = True;
                           }else if(GMUser.containsKey(portCode)){
                               //if user with General Manager role is present in Territory making that lead owner
                               leadMMS.OwnerId = GMUser.get(portCode);
                               leadMMS.Lead_Owner_Check__c = True;
                           }else if(GAOUser.containsKey(portCode)){
                               //if user with Account Owner role role is present in Territory making that lead owner
                               leadMMS.OwnerId = GAOUser.get(portCode);
                               leadMMS.Lead_Owner_Check__c = True;
                           }
                       }
            }
            //END for loop
        } catch(Exception ex){
            system.debug('Exception in LeadTriggerHelper Class :: customLeadRoutingMMS  method ::: '+ex.getMessage());
        }
    }
    
/****************************************************************************
    @Method Name: getAccountMap
    @Author: SFO/Chhaveel
    @Sprint :sprint 21.12 [DIGI-3187]
    @CreateDate: 21/09/2021
	Input parameters: Set<Id> accId
	return type:	  Map<id,Account>
	Output: Returing map of the accounts
******************************************************************************/     
    public Map<Id,Account> getAccountMap(Set<Id> accId){
        Map<Id,Account> accMap = new Map<Id,Account>();
        if(!accId.isempty()){
        	accMap = new Map<Id,Account>([SELECT id,name,cidn__c,ownerid,APTPS_Tier__c,Vertical__c,Portfolio_Code__c FROM account WHERE id IN :accId]);
        }
        return accMap;
    }
    
/****************************************************************************
    @Method Name: MigrationLeadConversion
    @Author: SFO/Pallavi B
    @Sprint :sprint 21.15 [DIGI-34437]
    @CreateDate: 25/10/2021
    @Description : This method is used to throw error in migration lead conversion process 
                   when there is no Digital Ready Date/No task with first bill subject and completed status,lead status is not migrated
    @LastModified :  AS part of DIGI-11413(Bug) S21.15 to throw error message when converting enterprising lead status is not in aceepted 
******************************************************************************/     
public void ErrorsOnLeadConversion(Map<id,Lead> newLeadMap,Map<id,Lead> oldLeadMap){
    List<Id> MigratedLeadLst = new  List<Id>();//holds lead records lead migration met critieria
    List<Lead> lstLead = new List<Lead>();//Captures Lead records that are in lead migration process
    Id leadEnterpriseRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
    List<Lead> EnterpriseLeadLst = new List<Lead>();
    try{
        //Lead Loop Iterates on new lead map to get records that are getting converted and old and new status values are not same   
        for(lead objLead : newLeadMap.values()){
                       if(oldLeadMap!=null && objLead.IsConverted == true && oldLeadMap.containskey(objLead.Id) && objLead.Status == System.Label.Lead_Status_Converted && oldLeadMap.get(objLead.Id).Status != objLead.Status){
                           if( objLead.RecordTypeId == leadMigrationRecordType){
                               MigratedLeadLst.add(objLead.Id);
                               lstLead.add(objLead);
                            }
                           //Added as part of DIGI-11413(Bug) S21.15.
                           //Gets only the enterpries lead records that are in lead conversion process but previous status is not accepted
                         if(objLead.RecordTypeId == leadEnterpriseRecordType && oldLeadMap.get(objLead.Id).Status != system.Label.Lead_Status_Accepted){
                               EnterpriseLeadLst.add(objLead); //holds lead record that are not satisfying above criteria
                               EnterpriseLeadConversionErrorOnStage(EnterpriseLeadLst); //method to throw error on enterprise leads
                            }
                               
                        }
                }
               //If there are no records that are converting,exists the method
                if( MigratedLeadLst.isEmpty()){
                           return;
                  }
              //Loops through Lead for checking critiera on Migration Lead Conversion
               for(lead currLead : lstLead){
                       if((oldLeadMap.get(currLead.Id).Status != System.Label.Lead_Status_Migrated && currLead.Status == System.Label.Lead_Status_Converted) || currLead.Digital_ready_date__c ==null || !currLead.FirstBillTaskOnLead__c ){
                           newLeadMap.get(currLead.Id).adderror(System.Label.ErrMsgForMigrationLeadConversion);
                       }
                }
 }catch(Exception ex){
     system.debug('Exception:::: LeadTriggerHelper Class:::: MigrationLeadConversion Method'+ Ex.getMessage());            

}
} 
    
    /****************************************************************************
    @Method Name: FirstBillTaskOnUpdate
    @Author: SFO/Pallavi B
    @Sprint :sprint 21.15 [DIGI-34437]
    @CreateDate: 25/10/2021
    @Description : This method triggers when lead record type changed from Enterprise to Migration ,
                   if any task is there on the lead with subject first bill and status is completed
                   then FirstBillTaskOnLead__c(lead field) will be true  
    ******************************************************************************/     
    public void FirstBillTaskOnUpdate(List<Lead> leadlst,Map<id,Lead> oldLeadMap){
        List<Id> MigratedLeadLst = new  List<Id>();
        Map<Id,Task> mapofTasks = new  Map<Id,Task>();
        List<Lead> lstLead = new List<Lead>();
        try{
            //Iterates over list of updates leads 
            for(lead objLead : leadlst){
                //when the modified lead is matching critieria like record type is changes from enterprise to migration
                if(oldLeadMap!=null && objLead.RecordTypeId == leadMigrationRecordType && oldLeadMap.containskey(objLead.Id) && oldLeadMap.get(objLead.Id).RecordTypeId != objLead.RecordTypeId ){
                    MigratedLeadLst.add(objLead.id); //Captures lead ids that getting migrated
                    lstLead.add(objLead);
                }
            }
            
            if( MigratedLeadLst.isEmpty()){// methods ends when there is no lead reord changing to migration
                return;
            }
            
            //while looking whther the lead is convertable or not based on the field '' along with the MIGRATED record type
            // no need to updating this field '' while conveting from migrated to other record types
            
            //fro the leads getting migrated, will get all the tasks
            if(!MigratedLeadLst.isEmpty()){
                //iterates over all tasks and check if any task subject is first bill and status completed
                for(Task objTask : [Select Id, Subject,WhoId from Task where Subject like '%FIRST BILL%' and WhoId =:MigratedLeadLst and Status = :System.Label.Task_Status_Completed]){
                    mapofTasks.put(objTask.WhoId,objTask);  
                }
            }
            
            //Iterates on only migrated leads
            if(!lstLead.isEmpty()){ 
                for(lead currLead : lstLead){
                    //if there are no such tasks on that lead.then it will make it as true
                    if(mapofTasks.get(currLead.id)!=null){
                        currLead.FirstBillTaskOnLead__c =True;
                    }else {//if there are  such tasks on that lead.then it will make it as false
                        currLead.FirstBillTaskOnLead__c =false;
                    }
                }
         }    
            
        }catch(Exception ex){
            system.debug('Exception:::: LeadTriggerHelper Class:::: FirstBillTaskOnUpdate Method'+ Ex.getMessage());            
        }
    }
 /****************************************************************************
    @Method Name: EnterpriseLeadConversionErrorOnStage
    @Author: SFO/Pallavi B
    @Sprint :sprint 21.15 [DIGI-11413]
    @CreateDate: 08/11/2021
    @Description : Throws on Enterprise Lead conversion process whose last status is not in accepted
  ******************************************************************************/     
public void EnterpriseLeadConversionErrorOnStage(List<Lead> enterpriseLeadLst){
    try{
        //Lead Loop Iterates on list of enterprise lead whose last status is not accepted and now changing to converted status in conversion process   
        for(lead objLead : enterpriseLeadLst){
            objLead.adderror(System.Label.ErrMsgOnEnterpriseLeadConversion);
        }
    }catch(Exception ex){
        system.debug('Exception:::: LeadTriggerHelper Class:::: EnterpriseLeadConversionErrorOnStage Method'+ Ex.getMessage());            
        
    }
} 


    
}