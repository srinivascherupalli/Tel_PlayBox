/*
===============================================================================================================================
Class : InvokeInventoryPublishEvents
Developer Name : Prajakta Patil
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.       Vaibhav Deshpande   02/04/2020     EDGE-139164 - Change Platform Event type to High Volume
===============================================================================================================================
*/

public class PublishInventoryEvents
{

//-----Publish Platform Event for every update of Subscription
   
    //public static PublishSubscriptionChange__e publishSubscriptionEvent(String subId,String operation,String subNumber){
        //updated method defination as part of EDGE-139164
    public static PublishSubscriptionChangeHV__e publishSubscriptionEvent(String subId,String operation,String subNumber){
      //PublishSubscriptionChange__e subEvent= new PublishSubscriptionChange__e(); //code commented as part of EDGE-139164
        PublishSubscriptionChangeHV__e subEvent= new PublishSubscriptionChangeHV__e(); //code added as part of EDGE-139164
        
        subEvent.Object_Name__c = 'Subscription';
        subEvent.Entity_ID__c = subId;
        subEvent.Subscription_Number__c = subNumber;
        subEvent.Operation__c = operation;
        subEvent.CorrelationID__c = subNumber;
        System.debug('Subscription_Event::' + subEvent);
        return subEvent;
    }

//-----Publish Platform Event for every update of Service Specification
    public static PublishServiceSpecificationChange__e publishServiceSpecificationEvent(String correlationId,String GUID){
        PublishServiceSpecificationChange__e specEvent =new PublishServiceSpecificationChange__e();
        specEvent.Object_Name__c = 'Specification';
        specEvent.Entity_ID__c = GUID;
        specEvent.Operation__c = 'U';
        specEvent.CorrelationID__c = correlationId;
        System.debug('Service_specEvent::' + specEvent);
        return specEvent;
    }

    /**
    * @description : This Platform event is used to parse the attachment data and used to create Technical object for order orchestration 
    * @author Rohit Pal | 08-24-2021 
    * @param strAttachmentId 
    * @return Technical_Object_Creation_Event__e 
    **/
    public static Technical_Object_Creation_Event__e publishTechnicalObjectCreationEvent(string strAttachmentId,
                                                                                         string strServiceId){
        Technical_Object_Creation_Event__e objTechnicalObjectCreationEvent = new Technical_Object_Creation_Event__e();
        objTechnicalObjectCreationEvent.Attachment_Id__c = strAttachmentId;
        objTechnicalObjectCreationEvent.Service_Id__c = strServiceId;
        return objTechnicalObjectCreationEvent;
    }
}