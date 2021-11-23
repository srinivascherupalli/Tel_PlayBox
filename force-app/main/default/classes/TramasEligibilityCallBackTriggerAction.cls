/*
* @Author : Robin Chawla 
* @Date : 20 May 2019
* @Desc : It contains all the actions for Handler class TramasElgibilityCallbackTriggerHandler for Trigger class TramasElgibilityCallbackResponseTrigger
* @Jira : EDGE-84282 Notify Sales user when TM1 check has completed.
* @Test class:TramasEligibilityCallbackTriggerTest
*/
public with sharing class TramasEligibilityCallBackTriggerAction {
    
   //EDGE-84282 Send notication to opportunity owner if all records of TramasEligibilityCallBackResponse having same Basket id
   // have Eligibility_Criteria__c field as Eligible or Not Eligible
    Public void sendNotification(List<TramasElgibilityCallbackResponse__c> newList,Map<ID, TramasElgibilityCallbackResponse__c> oldMap){
        try{
        List<String> basketIdList=new List<String>();
        Set<String> invalidBasketIdSet=new Set<String>();
          
        
        for(TramasElgibilityCallbackResponse__c res:newList){
            
            if(  res.Eligibility_Criteria__c!=oldMap.get(res.id).Eligibility_Criteria__c && res.Eligibility_Criteria__c!='Not Accessed' && res.Eligibility_Criteria__c!=null){
                
                basketIdList.add(res.Product_Basket__c);
                
            }
        }
         // Basket will not empty if there is change in   Eligibility_Criteria__c field of 
         // TramasElgibilityCallbackResponse__c object
        if(!basketIdList.isEmpty()){
            

            for(TramasElgibilityCallbackResponse__c res:[select id,Product_Basket__c,Eligibility_Criteria__c from TramasElgibilityCallbackResponse__c where Product_Basket__c in :basketIdList and (Eligibility_Criteria__c=null or Eligibility_Criteria__c= 'Not Accessed')]){
                invalidBasketIdSet.add(res.Product_Basket__c);
                
            }
           
            for(String id:invalidBasketIdSet){
                Integer result= basketIdList.indexOf(id);
                if(result!=-1){
                    
                    basketIdList.remove(result);
                }
            }
            
            List<cscfga__Product_Basket__c> productBasketList=[SELECT id,Name,cscfga__Opportunity__c,cscfga__Opportunity__r.OwnerId FROM cscfga__Product_Basket__c where id in :basketIdList];
            List<ConnectApi.BatchInput> batchInputs=new List<ConnectApi.BatchInput>();
            for(cscfga__Product_Basket__c basket:productBasketList){
                
                //Collect all chatter feeds
                batchInputs.add(createChatterNotification(basket));
                
                
                
            }
            if(!batchInputs.IsEmpty()){
              
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
                
            }
            
            
        }
        }
        catch(Exception e){
            
        }
    }
    
    //  EDGE-84282 Code to send notification
    Public ConnectApi.BatchInput createChatterNotification(cscfga__Product_Basket__c basket){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        //Mention user here
        mentionSegmentInput.id = basket.cscfga__Opportunity__r.OwnerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        textSegmentInput.text = ' The transition eligibility check for product basket '+basket.Name+' is now complete. View Details :'; 
        
       
        
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = basket.cscfga__Opportunity__c;
        ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
        linkInput.url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + basket.Id;
        linkInput.urlName = 	basket.Name;
        
        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.link = linkInput;
        
        feedItemInput.capabilities = feedElementCapabilitiesInput;
        
        
        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        return batchInput;
    }
    
    
}