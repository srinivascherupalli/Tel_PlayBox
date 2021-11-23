/*
 *Version     Author                         Last Modified Date      Description
  v1.1        Vivian Charlie (Team Hawaii)   20 July 2020            Do not display notification for closed opportunities
  v1.2        Manish Berad(Team Amsterdam)   24th nov 2020           EDGE-177925 Allow Partner users (both Active POR and Non-Active POR) 
                                   to create a Delegated Pricing Request (Deal Opportunity)
  v1.3        Ayush Goyal (Team Hawaii)      11th January 2021       P2OB-11846 - Update warning message conditions
* ModifiedBy     ModifiedDate     Edge          Description
* Ankush Rana    05/08/2021       DIGI-721      As a Sales or partner user I should not be allowed to create a Product Basket from a Deal Opportunity. This is because Deal opportunities should only have Frame agreements created against them
*/
public with sharing class NewBasketButtonController {
    @AuraEnabled
    public static String getPathPrefix(){
        System.debug('getPathPrefix...'+Site.getPathPrefix());
        return Site.getPathPrefix();
    }
    @AuraEnabled
    public static map<string,string> getValidOpportunity(id oppId){
        system.debug('intoooooo');
        set<string> validValues=new set<string>();
        Map<string, string> statusMap = new Map<string, string>{'status'=>'success','message'=>'Success','warning'=>'success'};
        string msg = Label.PRM_Opportunity_Custom_Messages;
        system.debug(msg); 
        Map<String, Object> deserializederrormsg = (Map<String, Object>)json.deserializeUntyped(msg);
        string OpptyWarning = (String)deserializederrormsg.get('OpptyWarning');
        
        //Added lines 24-25 by Team Hawaii for P2OB-11846
        String approvalPendingMsg = Label.PRM_Opportunity_Pending_For_Closure;
        Map<String, Object> approvalPendingErrMsgs = (Map<String, Object>)json.deserializeUntyped(approvalPendingMsg);
        //system.debug(OpptyWarning);
        //Query updated by Ayush(Hawaii) for P2OB - 8462
        //Query updated by Team Hawaii for P2OB - 11846 - Added Account.Owner.Name, Account.Owner.MobilePhone 
        opportunity opp=[select id,Name,recordtypeid, Submit_for_Closure_Status__c, Account.Owner.Name,
                         Account.Owner.MobilePhone,
                         RecordType.developername,RecordType.Name,Product_Type__c,Pricing_Method__c,Opportunity_Source__c, 
                         Partner_Opportunity_Verification__c,SubmittoPartnerStatus__c, IsClosed,isPOROpportunity__c 
                         from opportunity where id=:oppId]; // v1.1 adding isClosed to query
        PRM_Default__c pd=PRM_Default__c.getValues(userinfo.getProfileId());
        
        system.debug(opp);
        system.debug(pd);
        if(!opp.IsClosed){ // v1.1 if opportunity is not closed display messages
            //if(pd!= null && pd.Valid_Opportunity_Basket_Verification__c != null)
            validValues.addAll(pd.Valid_Opportunity_Basket_Verification__c.split(','));
            system.debug(validValues);
            if(pd!=null && opp.Opportunity_Source__c!='Partner' && !validValues.contains(opp.SubmittoPartnerStatus__c)){
                system.debug('inside first if');
                statusMap.put('warning','false');
                statusMap.put('message',(String)deserializederrormsg.get('OpptyNotAcceptedByPartner'));
                statusMap.put('status','error');
                statusMap.put('isDelegatedPricing','false');//EDGE-177925
                //return statusMap;

            }else if(pd!=null && opp.isPOROpportunity__c == false && opp.Opportunity_Source__c=='Partner' 

            && !validValues.contains(opp.Partner_Opportunity_Verification__c) && opp.RecordType.developername=='Defined' 
            && opp.Product_Type__c=='Modular' && opp.Pricing_Method__c=='Delegated Pricing'){
                //EDGE-177925 added by Manish B Team Amsterdam
                statusMap.put('message',(String)deserializederrormsg.get('delegatedPricingOpptyWarning'));
                statusMap.put('status','error');
                statusMap.put('warning','true');
                statusMap.put('isDelegatedPricing','true');//EDGE-177925
            }

            else if(pd!=null && opp.isPOROpportunity__c == false && opp.Opportunity_Source__c=='Partner' 
            && !validValues.contains(opp.Partner_Opportunity_Verification__c) &&
            (opp.RecordType.developername == 'Defined' || opp.RecordType.developername == 'MAC')){

                //Bhargava 20/05 -MAC Condition Added for Partner created opportunity ,EDGE-146794/EDGE-149337
                //PRM_Default__c pd1=PRM_Default__c.getOrgDefaults();
                //validValues.addAll(pd1.Valid_Opportunity_Basket_Verification__c.split(','));
                system.debug('inside second if');
                String warningMsg ='';
                statusMap.put('message',(String)deserializederrormsg.get('OpptyNotApprovedByTelstra'));
                statusMap.put('status','error');
                statusMap.put('warning','true');
                statusMap.put('isDelegatedPricing','false');//EDGE-177925
                //Updated by Hawaii for P2OB-11846
                if(opp.Account.Owner.MobilePhone != NULL && opp.Account.Owner.MobilePhone !=''){
                    warningMsg = (String)deserializederrormsg.get('opptySubmittedCEAvl');
                    warningMsg = warningMsg.replace('<Account Owner Mobile number>', opp.Account.Owner.MobilePhone);
                }else{
                    warningMsg = (String)deserializederrormsg.get('opptySubmittedCENotAvl');
                }
                warningMsg = warningMsg.replace('<Account Owner Full Name>', opp.Account.Owner.Name);
                statusMap.put('submittedWarningMessage',warningMsg);
                statusMap.put('isInitialApproval','true');
                //return statusMap;
            }
            // Ayush(Hawaii) for Jira Story P2OB-8462
            else if(opp.Submit_for_Closure_Status__c == 'Submitted'){
                statusMap.put('approvalPending','true');
                String warningMsg ='';
                // Updated by Hawaii for P2OB-11846
                if(opp.Account.Owner.MobilePhone != NULL && opp.Account.Owner.MobilePhone !=''){
                    warningMsg = (String)approvalPendingErrMsgs.get('PendingApprovalCEAvl');
                    //warningMsg.replace('<Account Owner Full Name>', opp.Account.Owner.Name);
                    warningMsg = warningMsg.replace('<Account Owner Mobile number>', opp.Account.Owner.MobilePhone);
                    //statusMap.put('approvalPendingMsg',warningMsg);
                } else{
                    warningMsg = (String)approvalPendingErrMsgs.get('PendingApprovalCENotAvl');
                    warningMsg = warningMsg.replace('<Full Name>', opp.Account.Owner.Name);
                    //warningMsg.replace('<Account Owner Full Name>', opp.Account.Owner.Name);
                }
                warningMsg = warningMsg.replace('<Account Owner Full Name>', opp.Account.Owner.Name);
                statusMap.put('approvalPendingMsg',warningMsg);
            }
			//DIGI-721 starts
			 else if(opp.RecordType.DeveloperName =='Defined' && opp.Product_Type__c == 'Modular' && opp.Pricing_Method__c == 'Delegated Pricing'){
                 statusMap.put('warning','false');
                statusMap.put('message','New product basket cannot be created from Digitised Deal opportunity');
                statusMap.put('status','error');
            }
            //DIGI-721 ends
            else{
                    
            }
        }
        return statusMap;
        //(opp.Partner_Opportunity_Verification__c=='Approved' || opp.Partner_Opportunity_Verification__c=='Not Applicable') || opp.SubmittoPartnerStatus__c=='Approved')
        //return (validValues.contains(opp.Partner_Opportunity_Verification__c) || validValues.contains(opp.SubmittoPartnerStatus__c))?true:false;
    }
    @AuraEnabled
    public static string caseRecordId(){
        string recId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Partner Sales Support').getRecordTypeId();
        system.debug(recId);
        return recId;
        }
        @AuraEnabled
        public static String createBasketRecord ( String jsonBasketMap) {
            
                system.debug('Print the basketMap-->'+jsonBasketMap);
                Map<String, String> basketMap = (Map<String, String>)JSON.deserialize(jsonBasketMap, Map<String, String>.class);
                
                cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
                basket.name = 'New Basket ' + DateTime.now();
                
                for (String fieldName : basketMap.keySet()) {
                    basket.put(fieldName, basketMap.get(fieldName));
                }
                
                insert basket;
                system.debug('print the basket id-->'+basket.id);
                
                return basket.id;
           
        }
}