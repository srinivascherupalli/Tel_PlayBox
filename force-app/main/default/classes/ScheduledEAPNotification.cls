/*
 * Name : ScheduledEAPNotification
 * Description : This scheduled class sends chatter notification on EAP discount expiry
 * Team : Napier
 * EDGE-144224
 * AUTHOR : Tejes Mahajan
*/

global with sharing class ScheduledEAPNotification implements Schedulable{
    
    global void execute(SchedulableContext sc){
        sendChatterNotification();        
    }
    
    
/*
 * Method : sendChatterNotification
 * Description : Sends chatter notification,update status of contract record on EAP discount expiry
 * Team : Napier
 * EDGE-144224
 * AUTHOR : Tejes Mahajan
*/
  
    public static void sendChatterNotification(){
        
        List<ContractJunction__c> contractList=[SELECT ID,Name,Related_Basket__c,Status__c,Related_Opportunity__r.OwnerId,IsNotificationTriggered__c 
                                                FROM ContractJunction__c WHERE Status__c  in ('Initiated','Pending Approval','Customer Review') 
                                                AND Related_Basket__r.csordtelcoa__Basket_Stage__c = 'Contract Initiated' 
                                                AND CIS_Dispatched_Offers__c = 'Telstra Collaboration' AND EAP_Discount_End_Date__c <> null 
                                                AND EAP_Discount_End_Date__c <:Date.Today() AND IsNotificationTriggered__c = false];
        
        system.debug('List: '+contractList);

        If(contractList.size() > 0){                        
            Set<Id> contractSet=new Set<Id>();
            List<FeedItem> postList=new List<FeedItem>();
            List<cscfga__Product_Basket__c> basketList=new List<cscfga__Product_Basket__c>();
            
            for(ContractJunction__c conRec:contractList){                
                
                //Sending EAP Expiry chatter notification to Opportunity Owner
                FeedItem post = new FeedItem();
                post.ParentId = conRec.Related_Opportunity__r.OwnerId;
                post.Body = conRec.Name+' '+Label.EAP_ChatterNotification;
                postList.add(post);
                
                //Updating Contract Junction Record Staus
                conRec.IsNotificationTriggered__c=true;
                conRec.Status__c='Cancelled';
                contractSet.add(conRec.Id);
                
                //Updating Basket Stage
                cscfga__Product_Basket__c basket=new cscfga__Product_Basket__c();
                basket.id=conRec.Related_Basket__c;
                basket.csordtelcoa__Basket_Stage__c='Contract Rejected';
                basketList.add(basket);            
            }
        	
            //Calling method to Void DocuSign Envelope
            docuSignVoidEnvelope(contractSet);
            
            database.insert(postList,false);
            database.update(basketList,false);
            database.update(contractList,false);
            
        }
    }

/*
 * Method : docuSignVoidEnvelope
 * Description : Voids the Docusign envelope related to Contract Record on EAP discount expiry
 * Team : Napier
 * EDGE-144224
 * AUTHOR : Tejes Mahajan
*/
    
    @Future(callout=true)
	public static void docuSignVoidEnvelope(Set<Id> contractSet){
        
        //Getting docusign envelope list.
        List<dsfs__DocuSign_Envelope__c> envelopeList=[SELECT id,dsfs__DocuSign_Envelope_ID__c,dsfs__Source_Object__c FROM dsfs__DocuSign_Envelope__c 
                                                       where dsfs__Source_Object__c IN: contractSet];
        List<String> envIdList=new List<String>();
        for(dsfs__DocuSign_Envelope__c envelope:envelopeList){
            envIdList.add(envelope.dsfs__DocuSign_Envelope_ID__c);                
        }
        Organization OrgDetails = [select id,IsSandbox, InstanceName from Organization LIMIT 1];
        String DeveloperNameDocuSign = '';
        if(OrgDetails.IsSandbox){
            DeveloperNameDocuSign = 'DocuSign_Sandbox_Org';
        }
        else{
            DeveloperNameDocuSign = 'DocuSign_Prod_Org';
        }
        DocuSign_REST_API__mdt docuSignAPIDetails = RetractContractComponent.getDocuSignMataDataType(DeveloperNameDocuSign);
        String voidReason = Label.EAP_VoidReason;
        
        for(String envelopeId:envIdList){
            DocusignClientRESTCall docuSignRestCall = new DocusignClientRESTCall();
            HttpResponse res = docuSignRestCall.voidEnvelope(envelopeId,voidReason,docuSignAPIDetails);
            system.debug('Response: '+res);
        }
    }
    
}