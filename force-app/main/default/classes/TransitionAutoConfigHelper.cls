/*
===============================================================================================================================
Class : TransitionAutoConfigHelper
Developer Name : Dheeraj Bhatt|| Nirvana Team
Test Class : TransitionAutoConfigHelperTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1.        Dheeraj Bhatt         06 Sept 2021   DIGI-1940 - Enable Chatter notifications to Opportunity Owner upon initiation/completion/Failure of auto configuration
===============================================================================================================================*/
public without sharing class TransitionAutoConfigHelper {
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');
    public static void checkBasketAutoConfigStatus(List<id> basketId){
        try{ 
             String message='';
            for(cscfga__Product_Basket__c basket:[SELECT id,Name,AutoConfigStage__c,cscfga__Opportunity__c,cscfga__Opportunity__r.OwnerId FROM cscfga__Product_Basket__c WHERE Id IN:basketId]){
                if(customMetadataNameValueMap.containsKey('AutoConfigstageInProgress') &&  basket.AutoConfigStage__c.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('AutoConfigstageInProgress').get('Label')))){
                    message=String.valueOf(customMetadataNameValueMap.get('AutoConfigstageInProgress').get('value__c')).replace('{Basket Id}', '{record:' +basket.Id+'}');
                    postChatterNotification(null,basket.cscfga__Opportunity__c ,'{'+ basket.cscfga__Opportunity__r.ownerId + '} '+ message);   
                }
                else if(customMetadataNameValueMap.containsKey('AutoConfigstageCompleted') &&  basket.AutoConfigStage__c.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('AutoConfigstageCompleted').get('Label')))){
                    message=String.valueOf(customMetadataNameValueMap.get('AutoConfigstageCompleted').get('value__c')).replace('{Basket Id}', '{record:' +basket.Id+'}');
                    postChatterNotification(null,basket.cscfga__Opportunity__c ,'{'+ basket.cscfga__Opportunity__r.ownerId + '} '+ message);   
                }
                else if(customMetadataNameValueMap.containsKey('AutoConfigstageFailed') &&  basket.AutoConfigStage__c.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('AutoConfigstageFailed').get('Label')))){
                    //Start of DIGI-24543 by Pradeep Mudenur(Osaka)
                    case feedbackCase= TransitionControllerHelper.createFeedbackCase(basketId);
                    system.debug('FeedbackCase@@@' + feedbackCase );
                    message=String.valueOf(customMetadataNameValueMap.get('AutoConfigstageFailed').get('value__c')).replace('{Basket Id}', '{record:' +basket.Id+ '}').replace('{Case Id}', '{record:' +feedbackCase.Id+ '}');
                    //Enf of DIGI-24543
                     postChatterNotification(null,basket.cscfga__Opportunity__c ,'{'+ basket.cscfga__Opportunity__r.ownerId + '} '+ message);   
                }
            }
        }
        catch(exception ex){
            system.debug('Exception occured at line no '+ex.getLineNumber()+' due to '+ex.getMessage());
        }
    }
    
    public static void postChatterNotification(String communityId, String subjectId, String textWithMentions){
        ConnectApiHelper.postFeedItemWithMentions(communityId, subjectId, textWithMentions);
    }
}