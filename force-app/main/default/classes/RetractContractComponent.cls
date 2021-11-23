/**
* @Author   :   Maqsood Alam
* @Date     :   18 Feb 2019
* @Desc     :   Controller for ContractRetractComponent Lightning Component
* */

public with sharing class RetractContractComponent {
    @AuraEnabled
    public static sObject recordDetails(String recordId)
    {
        ContractJunction__c CJ = [SELECT ID, NAME, Status__c FROM ContractJunction__c WHERE ID =: recordId LIMIT 1];
        if(CJ != NULL)
            return CJ; 
        else
            return null;
    }
    
    @AuraEnabled
    public static boolean updateRecord(String recordId, String retractReason, String Othertext)
    {
        boolean isContractUpdated = false;
        if(recordId != ''){
            ContractJunction__c CJ = New ContractJunction__c();
            CJ.Id = recordId;
            CJ.Status__c = 'Void';
            if((retractReason.contains('Other') == true) && (retractReason.contains('text') == true))
                CJ.Retract_Reason__c =  'Other ('+ Othertext+')';
            else
                CJ.Retract_Reason__c = retractReason; 
            CJ.Contract_Decline_reason__c = CJ.Retract_Reason__c;
            Update CJ;
            isContractUpdated = true;
            updateBasketStage(recordId, isContractUpdated);
            updateDocuSignStatus(recordId, isContractUpdated);
            updateRelatedAgreementStatus(recordId, isContractUpdated);
            return true;
        } 
        return false;
    }
    
    @Future
    public static void updateBasketStage(String recordId, Boolean isContractUpdated)
    {
        if(recordId != '' && isContractUpdated == true){
            ContractJunction__c CJ = [SELECT ID,Retract_Reason__c, Related_Basket__c FROM ContractJunction__c WHERE ID = : recordId LIMIT 1];
            if(CJ.Related_Basket__c != NULL){
                cscfga__Product_Basket__c PB = New cscfga__Product_Basket__c();
                PB.Id = CJ.Related_Basket__c;
                PB.csordtelcoa__Basket_Stage__c = 'Contract Rejected';
                Update PB;
                
            }
            
        } 
    }
    
    @Future(callout=true)
    public static void updateDocuSignStatus(String recordId, Boolean isContractUpdated)
    {
        if(recordId != '' && isContractUpdated == true){
            ContractJunction__c CJ = [SELECT ID,Retract_Reason__c, Related_Basket__c FROM ContractJunction__c WHERE ID = : recordId LIMIT 1];
            if(CJ.id != NULL){
                // --- Call DocuSign REST API to Valid the Envolope
                Organization OrgDetails = [select id,IsSandbox, InstanceName from Organization LIMIT 1];
                String DeveloperNameDocuSign = '';
                if(OrgDetails.IsSandbox){
                    DeveloperNameDocuSign = 'DocuSign_Sandbox_Org';
                }
                else{
                    DeveloperNameDocuSign = 'DocuSign_Prod_Org';
                }
                DocuSign_REST_API__mdt docuSignAPIDetails = getDocuSignMataDataType(DeveloperNameDocuSign);
                if(docuSignAPIDetails.IsDocuSignEnable__c == true){
                    
                    dsfs__DocuSign_Recipient_Status__c[] DRS = [SELECT dsfs__Envelope_Id__c, dsfs__DocuSign_Routing_Order__c, dsfs__Date_Signed__c FROM dsfs__DocuSign_Recipient_Status__c WHERE ContractJunction__c =:CJ.Id AND dsfs__Date_Signed__c = null ORDER BY dsfs__DocuSign_Routing_Order__c asc LIMIT 1];  
                    if(DRS.size() > 0){
                        if(DRS[0].dsfs__Envelope_Id__c != ''){
                            DocusignClientRESTCall DC = new DocusignClientRESTCall();  
                            //DC.voidEnvelope(DRS[0].dsfs__Envelope_Id__c,CJ.Retract_Reason__c,docuSignAPIDetails);
                            if(!Test.isRunningTest())
                            DC.voidEnvelope(DRS[0].dsfs__Envelope_Id__c,'test',docuSignAPIDetails);
                        }
                    }
                }
                
            }
            
        } 
    }
    // ----------- DIGI-687 : Retract agreement when contract is retracted ------------------
    // Maq | Eureka
    public static void updateRelatedAgreementStatus(String recordId, Boolean isContractUpdated)
    {
        if(recordId != '' && isContractUpdated == true){
            Apttus__APTS_Agreement__c relatedAgreement = [SELECT ID, RecordType.DeveloperName, Apttus__Parent_Agreement__c, Related_Contract__c FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c = : recordId AND Related_Contract__c != NULL ORDER BY createddate desc LIMIT 1];
            if(relatedAgreement.ID != NULL){
                ContentDocumentLinkContract.updateAgreementOnRetract(relatedAgreement);
            }
            
        } 
    }
    
    public static DocuSign_REST_API__mdt getDocuSignMataDataType(String DeveloperName)
    {
        if(DeveloperName != ''){
            DocuSign_REST_API__mdt DocuSign_REST_API_Details = [select id,ACCOUNT_ID__c,BASE_URL__c,INTEGRATOR_KEY__c,IsDocuSignEnable__c,PASSWORD__c,STATUS__c,USERNAME__c from DocuSign_REST_API__mdt where DeveloperName=: DeveloperName LIMIT 1];       
            return DocuSign_REST_API_Details;
        }
        return null;
    }
    @AuraEnabled
    public static boolean userInfoPRM(){
        boolean isPRMuser = false;
        Profile p = [select id,Name from Profile where id=:Userinfo.getProfileid()];
        if(p.Name  == 'PRM Admin - Australia' || p.Name  == 'PRM Community User - Australia')
            isPRMuser = true;  
        return isPRMuser;                              
    }
    
    @AuraEnabled
    public static String organizationInfo(){
        String currentOrg = '';
        List<organization> lstOrganization = [Select id,instanceName,isSandbox from Organization];
        if(lstOrganization.size()>0) {
            if(lstOrganization[0].isSandbox) {
                currentOrg = 'Sandbox';
            } else {
                currentOrg = 'Production';
            }
            return currentOrg;
        } 
        return currentOrg;
    }
}