/**
* Author: Shreyansh Sharma
* Team: Jaipur
* Sprint: 21.07
* JIRA Story: P2OB-13643
* Date: 5/18/2021 
* Description: This class maintains the pre-requisite validations/checks before triggering CBS and CPE flows
**/
Global with sharing class csGetCaseValidationsHelper { 
    // P2OB:9669 : Check for existing CBS Cases on opportunity 
  
  
     /* Screen Flow to send Input parameters*/
    global class ScreenInputs {
        @InvocableVariable(required=false) 
        global String flowName; 
        
        @InvocableVariable(required=true) 
        global String categoryValue; 
        
        @InvocableVariable(required=true)
        global ID oppId;
        
        @InvocableVariable(required=false)
        global ID AccountId;
        
        @InvocableVariable(required=false)
        global boolean UserPermission;
        
        @InvocableVariable(required=false)
        global boolean PurpleUserPermission;
    }
    
    public static Map<String,Object> existingCBSCaseValidation(String oppId){
        //String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
        Opportunity opp;
        Map<String,Object> results=new Map<String,Object>();          
        results.put('status','NoCaseExist');  
        opp=fetchOpportunity(oppId);
        List<case> caseLst =    [Select Id, CaseNumber from Case where recordtype.name='CBS' AND srvsup_Categories__c = 'Billing Solution Design' AND OpportunityId__c =: oppID Limit 1];
        If(caseLst.size() > 0){
            results.put('CaseAlreadyExist','yes');
            results.put('caseRec',caseLst.get(0));
        }
        Else{
            results.put('CaseAlreadyExist','no');
            results.put('oppDetails',opp);
        }
        
        return results; 
        
    }
    // P2OB:11749 : Check for existing CBS Contract Cases on opportunity
    public static Map<String,Object> existingCBSCaseContractValidation(String oppId){
        
        //String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
        Opportunity opp;
        Map<String,Object> results=new Map<String,Object>();          
        results.put('status','NoCaseExist');  
        
        opp=fetchOpportunity(oppId);
        system.debug(opp);
        List<case> caseLst =    [Select Id, CaseNumber from Case where recordtype.name='CBS' AND srvsup_Categories__c = 'Billing Solution Contract Implementation' And Status IN ('New','In Progress','On Hold') AND OpportunityId__c =: oppID Limit 1];
        If(caseLst.size() > 0){
            results.put('CaseAlreadyExist','yes');
            results.put('caseRec',caseLst.get(0));
        }
        Else{
            results.put('CaseAlreadyExist','no');
            results.put('oppDetails',opp);
        }
        return results; 
    }
    
    public static Opportunity fetchOpportunity(String oppId) {    
        
        //Opportunity o=new Opportunity();
        List<Opportunity> opplist=[select id,Name,Product_Domain__c ,CIDN__c,Owner.Name,Opportunity_Record_Type__c,
                                   Contract_Type__c,Expected_TCV_Range__c,Will_this_require_integration__c,Number_of_Additional_Domains_if_any__c,
                                   Customer_Accepted__c, //Account.Offshore_Data_Hosting_Restricted__c, //Dependency with EDGE-47352
                                   Account.id,Account.Name,Account.CIDN__c,Account.Parent_CIDN__c,
                                   AccountId, OwnerId, Account.Ultimate_Parent_CIDN__c,StageName,
                                   Product_Type__c,Product_Count_Status_Won__c,Probability,  // Karan P2OB:9108 : Check Description for more info 
                                   (SELECT Id, Domain__c FROM OpportunityLineItems)
                                   from Opportunity where id=:oppId LIMIT 1];

                             
        if(opplist.size()==1){
            
            return opplist[0];
        }else{
          
            return null;
        }
    }
    //check product domain value in aura controller in callback
    public static Map<String,Object> getProductDomain(String oppId){        
        //Opportunity o=new Opportunity();
        Map<String,Object> results=new Map<String,Object>();
        Opportunity opp = fetchOpportunity(oppId);
        if(opp != NULL){
            results.put('oppDetails', opp);
        }
        
        system.debug('@@@@'+results);
        if(results != NULL){
            return results;
        }
        else {return NULL;}
    }
    
    //Added by Sanjay Thakur as a part of P2OB-14486
    //Adding validation for Presales type as per the Opportunity stages
    
    public static Map<String,Object> presalesOpportunityStageValidation(String oppId){
        Map<String,Object> results=new Map<String,Object>();
        Opportunity opp = fetchOpportunity(oppId);
        if(opp != NULL){
            results.put('oppDetails', opp);
        }
        
        if(results != NULL){
            return results;
        }
        else {return NULL;}
    }
    /* P2OB-14492 - Added Validation logic for Presales Opportunities */
    /* This method is getting calling from Get Solutiion Support Flow */
    @InvocableMethod
    public static List<String> OppStageValidation(List<ScreenInputs> lstScreenInputs){
        List<String> LstStr = new List<String>();
     
        System.debug('Account Id:=>'+lstScreenInputs[0].AccountId);
        
        
        List<opportunity> opplist=[select id,Name,AccountId,StageName,Product_Type__c,Opportunity_Record_Type__c,Contract_Type__c,
                                   Expected_TCV_Range__c,Will_this_require_integration__c,Number_of_Additional_Domains_if_any__c from Opportunity WHERE ID =:lstScreenInputs[0].oppId LIMIT 1];
        List<account> AccList=[select id,Credit_Health__c,Override_Credit_Health__c from Account where id =:lstScreenInputs[0].AccountId LIMIT 1];
        if(opplist != null && opplist.size() > 0){
            
            if(AccList[0].Credit_Health__c == 'High Risk' && AccList[0].Override_Credit_Health__c == false){
                LstStr.add('High risk: This opportunity cannot progress while there is a high credit risk on the account. For more information on credit health and what you can do to get an exemption,'+'<a href="https://phoenix.inside.telstra.com/s/article/QRG-How-to-request-an-override-when-customer-credit-risk-is-high-No-Sell">Click here.</a>');
            }else if(opplist[0].Opportunity_Record_Type__c == 'Enterprise - Custom' && lstScreenInputs[0].UserPermission == false){
                LstStr.add('Standard Solutions cases cannot be raised for a Custom opportunity. Please follow the '+'<a href = "https://phoenix.inside.telstra.com/s/article/Custom-Deals-Success-Guide"> Custom Deal process</a> or contact your Bid Manager.');
            }else if(lstScreenInputs[0].PurpleUserPermission == false && opplist[0].Opportunity_Record_Type__c != 'Enterprise - Custom'){
                LstStr.add('This option is temporarily unavailable. We appreciate your patience as we progressively roll this out.');
            }else if(opplist[0].StageName == 'Closed Won' || opplist[0].StageName == 'Closed Lost' || opplist[0].StageName == 'Define'){
                LstStr.add('Standard Solutions request cannot be raised when the opportunity is in Define or Closed. Please move the opportunity to another stage.');
            }else if(opplist[0].Opportunity_Record_Type__c == 'Enterprise - In Contract'
                     && (opplist[0].Contract_Type__c == null || opplist[0].Expected_TCV_Range__c == null || opplist[0].Will_this_require_integration__c == null || opplist[0].Number_of_Additional_Domains_if_any__c == null)){
                             LstStr.add('One or some of the below fields are empty. Please ensure all of them are completed prior to engaging solution support:\n 1) Contract Type\n 2) Expected TCV Range\n 3) Number of Additional Domains (if any)\n 4) Will this require integration?');
            }
        }
        
        return LstStr;
    }

    
    
    
      
    
    
}