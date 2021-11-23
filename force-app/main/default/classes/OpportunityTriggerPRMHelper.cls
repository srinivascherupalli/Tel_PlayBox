/*****************************************************************************
@Name: OpportunityTriggerPRMHelper
@Author: Hawaii Team 
@CreateDate: 16/03/2020
@Description: This Class is created for PRM related funtionality
P2OB-5047 - ReInserting the Opportunity Team Member if Partner User change the opportunity Owner
P2OB-6584 - Post chatter to Opportunity Owner when Opportunity is closed by CE ( This is added in Trigger because tech dept is required on process builder)
12.       Tirth             29/10/2021     Sprint 21.14 - DIGI-18800 As a Purple Presales chapter lead, when an Opportunity is closed then all the related Solutions requests should get autoclosed to maintain data hygiene.
13.       Vivian            06/11/2021     Sprint 21.15 - DIGI-18800 Added filter for purple presales cases
*******************************************************************************/
public without sharing class OpportunityTriggerPRMHelper{
    public static Map<Id, List<OpportunityTeamMember>> existingTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>();
    public static Boolean isPreventRecCall = FALSE; // Prevent recursive call
    public static Boolean isPreventChatterRecCall = false; // P2OB-6584 - Prevent cust Rep chatter recursive call
    private static final String PRODUCT_DOMIAN_MOBILES ='Mobiles';//P2OB-6584 - product domain
    private static final String CONTACT_FULL_AUTHORITY ='Full Authority';//P2OB-6584 - product domain
    private static final String CONTACT_STATUS_ACTIVE ='Active';//P2OB-6584 - product domain
    private static final String PRM_OPTY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String USER_TYPE_POWER_PARTNER = 'PowerPartner';
    
    
    public static void prepareOpportunityTeamMemberList(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
      Set<Id> opptyIds = new Set<Id>();
      if(checkKeepOpportunityTeamRequired() && !isPreventRecCall){
          for(Opportunity opp : newList){
              if(opp.OwnerId != oldMap.get(opp.Id).OwnerId && UserInfo.getUserType() == 'PowerPartner'){
                  opptyIds.add(opp.Id);
              }
          }
          if(!opptyIds.isEmpty()){
                  // get existing opportunity Team Members
                  for(Opportunity opp : [select id , (Select id, OpportunityId, OpportunityAccessLevel, TeamMemberRole, UserId from OpportunityTeamMembers) from Opportunity where id in : opptyIds]){
                      if(!opp.OpportunityTeamMembers.isEmpty()){
                          existingTeamMembersMap.put(opp.Id, opp.OpportunityTeamMembers);
                         }
                  }
                  System.debug('::existingTeamMembersMap'+existingTeamMembersMap);
          }
       }
    }
    
     public static void reinsertOpportunityTeamMembers(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
         List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
         if(checkKeepOpportunityTeamRequired() && !isPreventRecCall){
             if(!existingTeamMembersMap.isEmpty()){
                 // Reinsert the Opportunity Team Member
                 for(Opportunity opp : newList){
                     if(existingTeamMembersMap.containsKey(opp.Id)){
                         for(OpportunityTeamMember otm : existingTeamMembersMap.get(opp.Id)){
                             OpportunityTeamMember otmClone = otm.clone();
                             otmClone.isTeamMemberReinsert__c = TRUE;
                             oppTeamList.add(otmClone);
                         }
                     }
                 }
                 System.debug('::oppTeamList'+oppTeamList);
                 // Reinsert the Opportunity Team Member
                 if(!oppTeamList.isEmpty()){
                     Database.insert(oppTeamList, false);
                 }
             }
             isPreventRecCall = TRUE;
        }
     
     }
     
     private static Boolean checkKeepOpportunityTeamRequired(){
         PRM_Opportunity_Team_Member_Default__c prm = PRM_Opportunity_Team_Member_Default__c.getInstance();
         return (prm != null && prm.Keep_Opportunity_Team__c);
     }
     
     /* P2OB-6584  - post cust Rep details chatter to opportunity */ 
     public static void postCustRepChatter(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
         Set<Id> accountIds = new Set<Id>();
         
         Map<Id, List<Contact>> accountContactMap = new Map<Id, List<Contact>>();
         Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
         PRM_Default__c prmDefault = PRM_Default__c.getInstance(); 
         if(!isPreventChatterRecCall && prmDefault != null && prmDefault.is_PRM_Opportunity_Porting_Verification__c != null && prmDefault.is_PRM_Opportunity_Porting_Verification__c == TRUE){
             String productDomain = prmDefault != null && !String.isEmpty(prmDefault.Opportunity_Product_Domain__c) ? prmDefault.Opportunity_Product_Domain__c : 'Mobiles';
             System.debug('::productDomain'+productDomain);
             // get Patner closed opportunity
             for(Opportunity opp : newList){
                  if( opp.StageName != oldMap.get(opp.Id).StageName && opp.StageName == PRM_OPTY_STAGE_CLOSED_WON && opp.AccountId != null && opp.Product_Domain__c != null && opp.Product_Domain__c == productDomain){
                    opportunityMap.put(opp.Id, opp);
                    accountIds.add(opp.AccountId);
                      
                  }
              }
              System.debug('::opportunityMap'+opportunityMap);
              System.debug('::accountIds'+accountIds);
              // get active contact details for cust Rep
              if(!opportunityMap.isEmpty()){
                opportunityMap = loadPartnerOwnedOpportunity(opportunityMap);
                System.debug('::opportunityMap after ::'+opportunityMap);
                if(!opportunityMap.isEmpty() && !accountIds.isEmpty()){
                    for(Account acc : [select id,Name, (select id, Name, MobilePhone,Account.Name from Contacts where Authority__c = :CONTACT_FULL_AUTHORITY AND Contact_Status__c = :CONTACT_STATUS_ACTIVE AND MobilePhone != null) from Account where id in :accountIds ]){
                        if(!acc.contacts.isEmpty()){
                            accountContactMap.put(acc.Id, acc.contacts);
                        }
                    }
                  }
              }
              if(!accountContactMap.isEmpty()){
                // post chatter
                postCustRepChatterToOpportunity(opportunityMap, accountContactMap);
              }
              isPreventChatterRecCall = true;
         }
         
     }
     
     /* P2OB-6584  - load Partner Owned Opportunity */
     private static Map<Id, Opportunity> loadPartnerOwnedOpportunity(Map<Id,Opportunity>  opportunityMap){
         Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
         for(Opportunity opp :[select id, AccountId, Owner.UserType from Opportunity where id in : opportunityMap.keySet() AND Owner.UserType = : USER_TYPE_POWER_PARTNER]){
             opptyMap.put(opp.Id, opp);
         }
         return opptyMap;
     }
     
     /* P2OB-6584  - post cust Rep details chatter to opportunity */ 
     public static void postCustRepChatterToOpportunity(Map<Id, Opportunity> opportunityMap, Map<Id, List<Contact>> accountContactMap ){
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        try{
            for(Opportunity opp : opportunityMap.values()){
                if(accountContactMap.containsKey(opp.AccountId)){
                    batchInputs.add(createFeadItemElement(opp.Id, opp.OwnerId, Label.PRM_Cust_Auth_Rep_Message, null));
                    batchInputs.add(createFeadItemElement(opp.Id, null, null, accountContactMap.get(opp.AccountId)));
                }
            }
            
            if(!batchInputs.isEmpty()){
                ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchInputs);
            }
          }catch(Exception ex){
              system.debug('Exception:--->OpportunityTriggerPRMHelper Class, onAfterUpdate cust Rep Method'+ Ex.getMessage());
          }
    }
     
     /* P2OB-6584  - create Feed Items */ 
     public static ConnectApi.BatchInput createFeadItemElement(Id oppId, Id ownerId, String message, List<Contact> contactList){
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
        ConnectApi.MarkupEndSegmentInput markupEndSegment;
        // generate the message body 
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        if(ownerId != null){
            ConnectApi.MentionSegmentInput input = new ConnectApi.MentionSegmentInput();
            input.Id = ownerId;
            messageBodyInput.messageSegments.add(input);
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = message;
            messageBodyInput.messageSegments.add(textSegmentInput);

       }else if(contactList != null && !contactList.isEmpty()){
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = Label.PRM_Cust_Auth_Rep_Detail_Message.replace('{0}', contactList.get(0).Account.Name);
            messageBodyInput.messageSegments.add(textSegmentInput);
           
           for(Contact contact : contactList){ 
            markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
            messageBodyInput.messageSegments.add(markupBeginSegment);


            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = contact.Name + ' ' + contact.MobilePhone;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
            messageBodyInput.messageSegments.add(markupEndSegment);
          }
           textSegmentInput = new ConnectApi.TextSegmentInput();
           textSegmentInput.text = Label.PRM_Cust_Rep_End_Message;
           messageBodyInput.messageSegments.add(textSegmentInput);
      }
        
      feedItemInput.body = messageBodyInput;
      feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
      feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

      //SubjectId indicates to which record this feed item will be tagged to. 
      feedItemInput.subjectId = oppId;
      return new ConnectApi.BatchInput(feedItemInput);
             
    }
    
    // DIGI-18800 ( Team Hawaii 21.14 )
    // As a Purple Presales chapter lead, when an Opportunity is closed then all the related Solutions requests should get autoclosed 
    // to maintain data hygiene.
    public void createPlatformEvents(List<Opportunity> newOpps){
        List<Id> OppIdList = new List<Id>();
        for(Opportunity opp : newOpps){
            if(opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost' || opp.StageName == 'Cancelled'){
                
                OppIdList.add(opp.Id);
            }
        }
        if(OppIdList.size() > 0){
            Set<Case_and_Work_Order_Data__e> eventSet = new Set<Case_and_Work_Order_Data__e>();
            List<Case_and_Work_Order_Data__e> eventList = new List<Case_and_Work_Order_Data__e>();
            
            List<Case> CaseList = new List<Case>();
            CaseList = [ SELECT Id, Recordtype.DeveloperName, Technology_Specialisation__c, ( SELECT Id FROM WorkOrders ) FROM Case 
                         WHERE OpportunityId__c =: OppIdList 
                         and Recordtype.Developername = 'Presales_Solution'
                         and Technology_Specialisation__c != null
                         and Technology_Specialisation__c != ''];
            
            for(Case cs : CaseList){
                Case_and_Work_Order_Data__e events = new Case_and_Work_Order_Data__e();
                events.Object_Name__c = 'Case';
                events.Record_Id__c = cs.Id;
                eventSet.add(events);
            }
            
            for(Case cs : CaseList){
                for(WorkOrder wo : cs.WorkOrders){
                    Case_and_Work_Order_Data__e events = new Case_and_Work_Order_Data__e();
                    events.Object_Name__c = 'WorkOrder';
                    events.Record_Id__c = wo.Id;
                    eventSet.add(events);
                }
            }
            eventList.addAll(eventSet);
            List<Database.SaveResult> results = EventBus.publish(eventList);
        }
    }
}