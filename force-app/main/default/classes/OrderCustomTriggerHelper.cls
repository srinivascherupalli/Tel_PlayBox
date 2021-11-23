/******************************************************************************************************
    *Class Name     : OrderCustomTriggerHelper
    *Decription     : Hanlder class Invoked from OrderCustomTriggerHandler
    *Test Class     : OrderCustomTriggerHandlerTest
    
   Sr.No.      Developer Name          Date            Story           Description
    1.         Jagadeswary            31/3/21          EDGE-209486    Publish new platform event
    2.          Gokul                   14/05/21        EDGE-215986     Post chatter notification based on order status
**************************************************************************************************/
public class OrderCustomTriggerHelper {
    
    static final String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    static String orderOwnerProfileName;
    static String oppOwnerProfileName;
    static string recordUrl;
    static string FeedMessageInprogress;
    static string FeedMessageCompleted;

    //EDGE-209486 - This method will create new OrderGenerationMSEvent__e
    public static OrderGenerationMSEvent__e createEvent(csord__Order__c order){
        
        //DIGI-30251 starts
        String correlationId;
        OrderGenerationMSEvent__e orderEvent = new  OrderGenerationMSEvent__e();
        Map<String,String> jsonData = new Map<String,String>();
        jsonData.put('code','200');	
        jsonData.put('status','Success');
        jsonData.put('Order_Rec_Id', order.Id);
        jsonData.put('description','Order created successfully');
        //DIGI-30251 ends
        orderEvent.cidn__c = order.csord__Account__r.CIDN__c;
        orderEvent.orderNum__c = order.csord__Order_Number__c;
        orderEvent.status__c = order.csord__Status2__c;
        orderEvent.reference_number__c = order.referenceNumber__c;
        //DIGI-30251 starts
        csord__Subscription__c orderSub = [SELECT Id, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.channelFrom__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.correlation_id__c FROM csord__Subscription__c where csord__Order__c =: order.id and csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent'];
		if(orderSub.csordtelcoa__Product_Configuration__c != null && orderSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c != null && orderSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.channelFrom__c == 'TED-81 onlineAPI'){
   			correlationId = orderSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.correlation_id__c;
            orderEvent.CorrelationId__c = correlationId;
            OC_SessionPayloadValidation.addSessionData(correlationId, 'basketEnrichment', jsonData); 
       		OC_SessionPayloadValidation.stepResult(correlationId, 'basketEnrichment' , true);
		}//DIGI-30251 ends
        return orderEvent;
    }

    /********************************************************************************************************************************************
    * Method Name:  postChatterNotification
    * Description:  Post chatter notification based on order status. This method is called from OrderCustomTrigger
    * Edge - 215986
    ********************************************************************************************************************************************/     
   
    public static void postChatterNotification(List<csord__Order__c> orderNewList,Map<Id,csord__Order__c> oldOrderMap,Sync_Control_and_Constants__c syncConstMap){
        List<String> params = new List<String>();
        List<ChatterUtilityClass.ChatterFeedWrapper> feedsLst = new List<ChatterUtilityClass.ChatterFeedWrapper>();
        set<Id> orderIds = new set<Id>();
		string userlist ;
        string feedMessage ='';
        
        if(syncConstMap != null){
            FeedMessageInprogress = syncConstMap.Order_In_Progress_Chatter_Notification__c != null ? syncConstMap.Order_In_Progress_Chatter_Notification__c :'';
            FeedMessageCompleted = syncConstMap.Order_Completed_Chatter_Notification__c != null ? syncConstMap.Order_Completed_Chatter_Notification__c : '';
        }
        for(csord__Order__c ord : orderNewList){
            if((ord.csord__Status2__c == 'In Progress' || ord.csord__Status2__c == 'Completed') && ord.csord__Status2__c != oldOrderMap.get(ord.id).csord__Status2__c){
                orderIds.add(ord.Id);
            }  
        }
        for(csord__Order__c ord : [select id,csord__Order_Number__c,csord__Status2__c,csordtelcoa__Opportunity__r.owner.id,
                                    csord__Account__r.name,owner.id,csordtelcoa__Opportunity__r.owner.profile.name, owner.profile.name 
                                    from csord__Order__c where Id IN : orderIds]){

            recordUrl = baseUrl+'/'+ord.Id;
            orderOwnerProfileName = ord.owner.profile.name;
            oppOwnerProfileName = ord.csordtelcoa__Opportunity__r.owner.profile.name;
            params.add(ord.csord__Order_Number__c);  
            params.add(ord.csord__Account__r.name);
            params.add(recordUrl);
            feedMessage = (ord.csord__Status2__c == 'In Progress')? FeedMessageInprogress: FeedMessageCompleted;
            if(orderOwnerProfileName != null && !system.label.PRMProf.contains(orderOwnerProfileName)){
                userlist = '{'+ord.owner.id+'}';
            }
            if(oppOwnerProfileName != null && !system.label.PRMProf.contains(oppOwnerProfileName) && ord.owner.id != ord.csordtelcoa__Opportunity__r.owner.id ){
                
                userlist= (userlist != null)? userlist +' {'+ord.csordtelcoa__Opportunity__r.owner.id+'}' : '{'+ord.csordtelcoa__Opportunity__r.owner.id+'}';
            }
            if(userlist != null){
                params.add(userlist);
                system.debug('params---'+params);
                feedsLst.add(new ChatterUtilityClass.ChatterFeedWrapper(null,ord.id,String.format(feedMessage, params)));

            }
            
        }
        ChatterUtilityClass.chatterNotificationHelper(feedsLst);  
    }
}