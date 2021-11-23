/*This class is written for changing the status of agreement Records,Contract Junction and Product basket.
Name                        Date          Description
Divya Chilakabathini    9/11/2020       changing the status of agreement Records
*/
/* History of Updates 
* Yash Rathod:  05/07/2021  INC000096322931  Send email only one time
*/
public without sharing class AgreementRecordStatusChange {
    static final STRING DSA_RECORD_TYPE = 'SA';
    //EDGE-171301 
    private Static String conStatus = 'In Effect';
    // EDGE-171301 This method is called from the process to builder to change the status of the DSA and PS Agreement records to Activate
    @InvocableMethod
    public static void changeAgreementStatus(list<Apttus__APTS_Agreement__c> agreementRec){
        try{
            List<Id> dsaAgrIds = new List<Id>();
            List<Id> psIds = new List<Id>();
            set<Id> cjActiveId = new set<Id>();
            list<Id> cjId = new list<id>();
            Boolean dprAgreementRecord= false;// Added for EDGE-184432
            Boolean variationRecord=false;
            for(Apttus__APTS_Agreement__c agId :agreementRec){
                dsaAgrIds.add(agId.Apttus__Parent_Agreement__c);
                psIds.add(agId.Id);
                system.debug('agId.Related_Contract__c::' + agId.Related_Contract__c + 'agId.Apttus__Version_Number__c' + agId.Apttus__Version_Number__c);
                if(agId.Related_Contract__c!=null && agId.Apttus__Version_Number__c ==0.0){//EDGE-193826 - Added version number
                cjId.add(agId.Related_Contract__c);
                    
                if(agId.Related_Contract__r.Status__c == conStatus && agId.Related_Contract__r.Agreement_Number__c!=null){
                    cjActiveId.add(agId.Related_Contract__c);
                }
            }
            
            if(agId.Apttus__Version_Number__c>0){//EDGE-193826 - Added version number
                variationRecord=true;
            }
                // Added changes for EDGE-184432
                if(agId.Delegated_Pricing_Request__c!=null && agId.Apttus__Version_Number__c ==0.0)//EDGE-193826 - Added version number
                dprAgreementRecord=true;
            }
            if(cjId.size()>0){
            activateAgreementDocuments(dsaAgrIds,psIds,cjId,cjActiveId);
            }
            else{//Added Changes for EDGE-184432
                if(dprAgreementRecord)
                activateDPRAgreementDocuments(dsaAgrIds,psIds);
                //EDGE-193826 Start
                else if(variationRecord){
                    list<id> variationionDsaIdlist= new list<id>();
                    activateDPRAgreementDocuments(variationionDsaIdlist,psIds);
                }//EDGE-193826 End
                
            }
            
            
        }catch(Exception ex){
            System.debug('Agreement Status:changeAgreementStatus method ' + ex);
        }
    }
    
    //EDGE-171301 Method to change the status of Agreement records to Activate through WebCall method
    public static void activateAgreementDocuments(list<Id> dsaAgrIds,list<Id> psIds,list<Id> cjId,set<Id> cjActiveId){
        try{
            Integer emailSend = 0; //INC000096322931
            Map<id, List<String>> contDocMap = new Map<id, List<String>>(); 
            List<id> removeidlist= new List<id>();
            // for Price schedule recods
            //Attachment Fix
            //Get the PS agreements and prepare the mapOfPSAgreements
            Map<Id,Apttus__APTS_Agreement__c> mapOfPSAgreements=new Map<Id,Apttus__APTS_Agreement__c>();
            Set<String> setOfDsaAndPS=new Set<String>();
            for(Apttus__APTS_Agreement__c  agrm:[SELECT ID,Name, Related_Contract__c,(SELECT ID, ContentDocumentId,ContentDocument.Title,ContentDocument.FileExtension, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLinks) FROM Apttus__APTS_Agreement__c WHERE (Related_Contract__c IN: cjId OR Apttus__Parent_Agreement__r.Related_Contract__c IN: cjActiveId) AND Id IN:  psIds] ){
                setOfDsaAndPS.add(agrm.Id);//Add PS record in mapOfPSAgreements
                for(ContentDocumentLink cdl:agrm.ContentDocumentLinks){
                    if(!contDocMap.containsKey(cdl.LinkedEntityId)){
                        contDocMap.put(cdl.LinkedEntityId, new List<String>{cdl.ContentDocumentId});
                    }else{
                        contDocMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                    }
                }
            }
            System.debug('$$$$$:contDocMap11:'+contDocMap);
            System.debug('$$$$$:mapOfPSAgreements:'+mapOfPSAgreements);
            
            for(String dsaID:dsaAgrIds){
                setOfDsaAndPS.add(dsaID);
            }
            //Get PS agreements attachments
            for(Attachment attachmentRecord : [SELECT Id,ParentId FROM Attachment where ParentId IN: setOfDsaAndPS]){
                if(!contDocMap.containsKey(attachmentRecord.ParentId)){
                    contDocMap.put(attachmentRecord.ParentId, new List<String>{attachmentRecord.Id});
                }
            }
            system.debug('$$$$$:contDocMap11'+contDocMap);
            /*
            //for DSA records
            for(Attachment a : [SELECT Id,ParentId FROM Attachment where ParentId IN: dsaAgrIds]){
                if(!contDocMap.containsKey(a.ParentId)){
                    contDocMap.put(a.ParentId, new List<String>{a.Id});
                }
                
            }
            
            system.debug('contDocMap22'+contDocMap);
            */
            if(contDocMap.size()>0){
                for(string contt:contDocMap.keyset()){
                    system.debug('contDocMap2'+contDocMap.get(contt));
                    system.debug('LIMIT'+Limits.getCallouts());
                    //Due to Apttus Limitation we are calling there API In Loop
                    if(Limits.getCallouts()<10){
                        Boolean response = Apttus.AgreementWebService.activateAgreement(contt, contDocMap.get(contt), removeidlist);
                        system.debug('valueofresponse'+response );
                        //EDGE-202386
                        if(response != null && response == true && emailSend == 0){ //INC000096322931 Send email only one time
                            generateChatterPost(contt);
                            emailSend++; //INC000096322931
                        }
                        // END EDGE-202386 
                                                
                    }
                }
            }

        }catch(Exception ex){
            System.debug('Agreement Status AgreementRecordStatusChange:activateAgreementDocuments method ' + ex + 'Line number' + ex.getLineNumber());
        }

    }
      /**
     * @Author   :   Rahul Asarma
     * @Date     :   08 Dec 2020
     * @Desc     :   This Method has written to move status of Agreement to InEffect in case of Delegate Agreement
     * @US       :   EDGE-184432
     * @Status   :   Development
     * */
    public static void activateDPRAgreementDocuments(list<Id> dsaAgrIds,list<Id> psIds){
        try{
            Integer emailSend = 0; //INC000096322931
            Map<id, List<String>> contDocMap = new Map<id, List<String>>(); 
            List<id> removeidlist= new List<id>();
            // for Price schedule recods
            
            //for DSA records & PS
            if(dsaAgrIds.size()>0 || psIds.size()>0){
            //EDGE-193826 Start
                list<id> agreementIds= new list<id>();
                if(dsaAgrIds.size()>0)
                    agreementIds.addall(dsaAgrIds);
                if(psIds.size()>0)
                    agreementIds.addall(psIds);
                //EDGE-193826 End
                for(Attachment a : [SELECT Id,ParentId FROM Attachment where ParentId IN: agreementIds]){//EDGE-193826
                    if(!contDocMap.containsKey(a.ParentId)){
                        contDocMap.put(a.ParentId, new List<String>{a.Id});
                    }
                    
                }
            }
            
            system.debug('contDocMap22'+contDocMap);
            
            if(contDocMap.size()>0){
                for(string contt:contDocMap.keyset()){
                    system.debug('contDocMap2'+contDocMap.get(contt));
                    system.debug('LIMIT'+Limits.getCallouts());
                    //Due to Apttus Limitation we are calling there API In Loop
                    if(Limits.getCallouts()<10){
                        Boolean response = Apttus.AgreementWebService.activateAgreement(contt, contDocMap.get(contt), removeidlist);
                        system.debug('valueofresponse'+response );
                        //EDGE-202386 
                        if(response != null && response == true && emailSend == 0){ //INC000096322931 Send email only one time
                            generateChatterPost(contt);
                            emailSend++; //INC000096322931
                        }
                        // END EDGE-202386 
                    }
                }
            }

        }catch(Exception ex){
            System.debug('Agreement Status AgreementRecordStatusChange:activateAgreementDocuments method ' + ex + 'Line number' + ex.getLineNumber());
        }
    }
    /**
     * @Author   :   Lokesh D 
     * @Date     :   03/05/2021 
     * @Desc     :   This Method has written to send email notification for Activated Agreements . 
     * @US       :   EDGE-202386
     * @Status   :   Development
     * */
    public static void generateChatterPost(Id aggId){
        
         
     System.debug('Agreement Status AgreementRecordStatusChange:generateChatterPost' + aggId);
     
    Apttus__APTS_Agreement__c ag = [select id , name , Apttus__FF_Agreement_Number__c, Apttus__Parent_Agreement__r.Name, Apttus__Parent_Agreement__r.Id, APTPS_Customer_Primary_Contact__r.FirstName,  APTPS_Customer_Primary_Contact__r.LastName ,Apttus__Related_Opportunity__r.Id ,Apttus__Related_Opportunity__r.OwnerId,Apttus__Account__r.Name  ,Apttus__Version_Number__c , APTPS_Record_Type_Name__c,Related_Contract__c ,Related_Contract__r.Related_Opportunity__r.OwnerId,Related_Contract__r.Customer_Primary_Contact__r.FirstName, Related_Contract__r.Customer_Primary_Contact__r.LastName, Related_Contract__r.Id, Related_Contract__r.Name  from Apttus__APTS_Agreement__c   Where Id =: aggId ];
  User userId= [SELECT id, Profile.Name, Profile.Id,email FROM User WHERE id=: ag.Apttus__Related_Opportunity__r.OwnerId];
    
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
    if(userId.email != null && ag != null){
    
    if(ag.Apttus__Version_Number__c > 0 || ag.APTPS_Record_Type_Name__c == DSA_RECORD_TYPE){
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
      List<String> sendTo = new List<String>();
        sendTo.add(userId.email);
        mail.setToAddresses(sendTo);
        mail.setSaveAsActivity(false);
      
      mail.subject='Update for Telstra Agreement : '+ag.Apttus__FF_Agreement_Number__c+' ';
      
      String body = 'The Agreement for '+ag.APTPS_Customer_Primary_Contact__r.FirstName+' '+ag.APTPS_Customer_Primary_Contact__r.LastName+' ';
        body += 'from '+ag.Apttus__Account__r.Name+' has been executed. ';
        body += 'You can now access this customer’s Agreement documents ';
        body += '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ag.Id+'">'+ag.Name+'</a></html>';
        
      mail.setHtmlBody(body);
      mails.add(mail);
    }
    if(ag.Related_Contract__c != null){
      
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
      List<String> sendTo = new List<String>();
        sendTo.add(userId.email);
        mail.setToAddresses(sendTo);
        mail.setSaveAsActivity(false);
      
      mail.subject='Update for Telstra Agreement : '+ag.Apttus__FF_Agreement_Number__c+' ';
      
      String body = 'An update to the Agreement for '+ag.Related_Contract__r.Customer_Primary_Contact__r.FirstName+' '+ag.Related_Contract__r.Customer_Primary_Contact__r.LastName+' ';
        body += 'from '+ag.Apttus__Account__r.Name+' has been executed. ';
        body += 'You can now access this customer’s latest Order Request ';
        body += '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ag.Related_Contract__r.Id+'">'+ag.Related_Contract__r.Name+'</a></html>';
        
      mail.setHtmlBody(body);
      mails.add(mail);
      
    }
  }
    if(!mails.isEmpty()){
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            system.debug('@@@@@@'+results);
        }
            
}                                     
  
}