/*****************************************************************************
@Name: ContentDocumentLinkTriggerHandler
@Author: Shaik Mahaboob Subani
@CreateDate: 15/01/2017
@Description: This Class is Helper for ContentDocumentLinkTrigger Trigger
@Modified : On 10/04/2018 for updating Attachment count on opportunity. 
@Modified by : Sravanthi velagapudi
@Modified by : Vamshi (Napier Team) as part of EDGE-135560

* Ankush Rana      25/06/2021  EDGE-220767 As a Customer when I create a Case via T-connect, When I input comments or attach document, Then Case queue assignment should not change
*******************************************************************************/
public without sharing class ContentDocumentLinkTriggerHandler{
    /*
* @Method Name : modifiedDateUpdate
* @Parameters  : list<ContentDocumentLink> newList , UpdOrDelOrIns
* @Description : When new file/Files are added to opportunity, 
*                opportunity lastmodified date will update and to count the attachments on a given opportunity.
* */
    @testvisible private ContentDocumentLinkTriggerHandler(){}

    public static void modifiedDateUpdate(list<ContentDocumentLink> newList , string UpdOrDelOrIns) { 
        try{  
            
            set<id> opptyId = new set<id>();
            set<id> contractIdSet = new Set<Id>();        
            // newList Contains contentdocumentLink records which are newly inserted
            for(ContentDocumentLink nt : newList){            
                // pId stores the object code related to contentdocumentLink
                string pId = string.valueOf(nt.linkedentityid).substring(0,3);            
                if(pid == '006'){ // checking whether the record is opportunity or not
                    opptyId.add(nt.linkedentityid);
                }
                if (pid == 'a7W') {
                    contractIdSet.add(nt.linkedentityid);
                }             
            }   
            List<Opportunity> opplist=new List<Opportunity>();
            Map<Id,List<ContentDocumentLink>> conDocCountMap=new Map<Id,List<ContentDocumentLink>>();
            if(!opptyId.isEmpty()){       
                List<ContentDocumentLink> oppcdLks=[Select id,linkedentityid from ContentDocumentLink where linkedentityid=:opptyId];
                for(ContentDocumentLink cdl : oppcdLks){
                    List<ContentDocumentLink> cdlList=conDocCountMap.get(cdl.linkedentityid);
                    if(null==cdlList){
                        cdlList=new  List<ContentDocumentLink>();
                        conDocCountMap.put(cdl.linkedentityid,cdlList);
                    }
                    cdlList.add(cdl);
                }
                //querying opportunity record 
                opplist = [select id,Last_Attachment_Upload_Date__c,Attachment_Count__c from Opportunity  where Id IN: opptyId];
                
                if(!opplist.isEmpty()){
                    
                    for(opportunity op : opplist){    
                        
                        if(UpdOrDelOrIns == 'AttachDate'){
                            
                            //Updating the Last_Attachment_Upload_Date__c in opportunity
                            op.Last_Attachment_Upload_Date__c= System.now();
                        }
                        //Updates the Attachment_Count__c field on Opportunity whenever the attachment is inserted/deleted
                        else if(UpdOrDelOrIns == 'Attachcountinsert' ){
                            
                            //String oppid = op.id;
                            Integer Attachmentcount =  conDocCountMap.get(op.id).size();//[Select count() from ContentDocumentLink where linkedentityid=:oppid];
                            op.Attachment_Count__c= Attachmentcount;
                        }
                        else if( UpdOrDelOrIns == 'Attachcountdelete'){
                            
                            //String oppid = op.id;
                            Integer Attachmentcount =  conDocCountMap.get(op.id).size();//[Select count() from ContentDocumentLink where linkedentityid=:oppid];
                            op.Attachment_Count__c= Attachmentcount-1;
                        }
                        
                    }   
                }   
            } 
            
            if(!opplist.isEmpty()){
                update opplist;
            }
            controlAutoRefreshStatus(contractIdSet);
        }
        catch(Exception e){
            system.debug('Exception -->'+e.getMessage());
        }
    }
    private static void controlAutoRefreshStatus(set<id> contractIdSet)
    {
        List<ContractJunction__c> contractList=new List<ContractJunction__c>();
        if(!contractIdSet.isEmpty()){
            contractList = [select Id, AutoRefreshStatus__c from ContractJunction__c where id in :contractIdSet];
            for (ContractJunction__c c: contractList ) 
                c.AutoRefreshStatus__c = 'Ready';
            update contractList ;
        }       
    }
    
    
    public static void ownerUpdate(list<ContentDocumentLink> newList) {
        try{
            set<id> bidIds = new set<id>();
            set<id> CDIds = new set<id>();
            
            Bid_Information__mdt bidInfo = [SELECT Bid_Orb_Doc_Title__c FROM Bid_Information__mdt];
            String bidTitle = bidInfo.Bid_Orb_Doc_Title__c;
            
            Phoenix_Configurations__c pc = Phoenix_Configurations__c.getInstance();
            String bidIDStart = pc.Bid_ID__c;
            Id CALMsIntUserID = pc.CALMS_Int_User_ID__c;            
            system.debug('bidIDStart '+ bidIDStart + 'CALMsIntUserID '+ CALMsIntUserID);
            
            if(newList!=null && newList.size()>0){
                for(ContentDocumentLink cdl : newList){
                    String recIdentity = string.valueOf(cdl.linkedentityid).substring(0,3); 
                    system.debug('linkedentityid ' +cdl.linkedentityid);
                    if(recIdentity == bidIDStart){
                        bidIds.add(cdl.linkedentityid);
                        CDIds.add(cdl.ContentDocumentId);
                    }
                }
                
                List<ContentDocument> wonUpdate = new List<ContentDocument>();
                List<Bid__c> bidList=new List<Bid__c>();
                if(bidIds!=null && bidIds.size()>0){
                    bidList = [SELECT Id, OwnerId, Current_ORB_Generated_User__c FROM Bid__c WHERE Id IN: bidIds];
                    if(CDIds!=null && CDIds.size()>0){
                        List<ContentDocument> CDListIds=[Select id,OwnerId,Title from ContentDocument where Id IN:CDIds];            
                        
                        if(bidList.size() > 0){
                            for(ContentDocument cd :CDListIds){
                                if(cd.title.startsWith(bidTitle) && bidList.get(0).Current_ORB_Generated_User__c !=null && CALMsIntUserID == cd.OwnerId ){
                                    cd.OwnerId = bidList.get(0).Current_ORB_Generated_User__c ;
                                    wonUpdate.add(cd);
                                }
                            }
                            if(wonUpdate.size()>0){
                                update wonUpdate;
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: ContentDocumentLinkTriggerHandler Class:::: ownerUpdate Method'+ Ex.getMessage());
        }
    }
    
    public static void modifyFileVisibility(list<ContentDocumentLink> newList , string UpdOrDelOrIns) {
        for(ContentDocumentLink nt : newList){            
            // pId stores the object code related to contentdocumentLink
            String sObjName = nt.linkedentityid.getSObjectType().getDescribe().getName();
            if(sObjName == 'Quote' && UpdOrDelOrIns == 'ChangeVisibility'){ // checking whether the record is Quote or not
                nt.Visibility = 'AllUsers';
            }            
        }
    }
/*
* @Method Name : attachmentCountUpdate
* @Parameters  : list<ContentDocumentLink> newList , UpdOrDelOrIns
* @Description : When new file/Files are added to Case,count the attachments on a given case.
* @Developer : Vamshi (Napier Team) Added as part of EDGE-135560.
*/
        public static void attachmentCountUpdate(list<ContentDocumentLink> newList , string UpdOrDelOrIns) { 
            set<id> caseId = new set<id>();
            for(ContentDocumentLink nt : newList){            
                string pId = string.valueOf(nt.linkedentityid).substring(0,3);            
                if(pid == '500'){ // checking whether the record is Case or not
                    caseId.add(nt.linkedentityid);
                }
            }
            
            List<Case> caseList =new List<Case>();
            Map<Id,List<ContentDocumentLink>> conDocCountMap=new Map<Id,List<ContentDocumentLink>>();
            if(!caseId.isEmpty()){       
                List<ContentDocumentLink> casecdLks=[Select id,linkedentityid from ContentDocumentLink where linkedentityid=:caseId];
                for(ContentDocumentLink cdl : casecdLks){
                    List<ContentDocumentLink> cdlList=conDocCountMap.get(cdl.linkedentityid);
                    if(null==cdlList){
                        cdlList=new  List<ContentDocumentLink>();
                        conDocCountMap.put(cdl.linkedentityid,cdlList);
                    }
                    cdlList.add(cdl);
                    system.debug('conDocCountMap is ==> '+conDocCountMap);
                }
                //EDGE-220767 excluding Cases where RecordType.DeveloperName =‘salesup_Sales_Child_Support' AND Origin = 'Telstra Connect’
                caseList = [select id,Attachment_Count__c from Case where Id IN: caseId and (Origin !='Telstra Connect' or RecordType.DeveloperName !='salesup_Sales_Child_Support')];  
                system.debug('caseList is ==> '+caseList);
                if(!caseList.isEmpty()){
                    for(Case caserecord : caseList){
                        system.debug('UpdOrDelOrIns'+UpdOrDelOrIns);
                        if(UpdOrDelOrIns == 'Attachcountinsert' ){
                            Integer Attachmentcount =  conDocCountMap.get(caserecord.id).size();
                            system.debug('Attachmentcount adding is ==> '+Attachmentcount);
                            caserecord.Attachment_Count__c= Attachmentcount;
                        }else if(UpdOrDelOrIns == 'Attachcountdelete'){
                            Integer Attachmentcount =  conDocCountMap.get(caserecord.id).size();
                            system.debug('Attachmentcount reducing is ==> '+Attachmentcount);
                            caserecord.Attachment_Count__c= Attachmentcount-1;
                        }
                    }  
                    update caseList;                    
                }
            }  
        }  
    /*-------------------------------------------------------- 
EDGE-140813 
Method: modifyCAVisibility
Description: Method to change visibilty of CAF document
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static void modifyCAVisibility(list<ContentDocumentLink> newList ) {
        Schema.sObjectType sObjType = Schema.getGlobalDescribe().get(Label.CAFormSobject);
        String keyPrefix=sObjType.getDescribe().getKeyPrefix();
        String keyPrefix2=(Schema.getGlobalDescribe().get(Label.PORSobject)).getDescribe().getKeyPrefix(); // Added Purushottam : EDGE-150891
        for(ContentDocumentLink cdl:newList){
            if((String.valueOf(cdl.LinkedEntityId)).startsWith(keyPrefix) || (String.valueOf(cdl.LinkedEntityId)).startsWith(keyPrefix2)){ // Added Purushottam : EDGE-150891
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
            } 
        }
    }
    
    
     /*-------------------------------------------------------- 
EDGE-170431
Method: priceScheduleOFormFile
Description: Method to attach the order form file to PS
Author:Divya Chilakabathini
--------------------------------------------------------*/
    public static void priceScheduleOFormFile(list<ContentDocumentLink> newList) {
        system.debug('newList:'+newList);
        ContentDocumentLinkTriggerHelper.attachOrderFormFilePS(newList);
    }
}