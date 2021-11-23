/*=========================================================================================================================
EDGE       -EDGE-170949/170948
class      -NotificationPreferenceHelper 
Description-helper Class for notification prefernece functionality
Author     -Dheeraj Bhatt/Veena Putta
===========================================================================================================================*/    
public class NotificationPreferenceHelper {
    
/*=========================================================================================================================
EDGE       -EDGE-170949/170948
Method     -createNotificationPreference 
Description-Capture Service Level Preference for all voice and voice + data plans as SMS and service MSISDN 
as default during order generation for New and MAC orders
Author     -Dheeraj Bhatt/Veena Putta
===========================================================================================================================*/    
    public static List<Notification_Preference__c> createNotificationPreference(csord__Service__c serviceRec, Map<string,List<Plan__mdt>> mapOfProductAndPlan){ 
        List<Notification_Preference__c> notificationPreferenceList =new List<Notification_Preference__c>();
        if(!mapOfProductAndPlan.isEmpty() && mapOfProductAndPlan.containsKey(serviceRec.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c)){
            for(Plan__mdt plan : mapOfProductAndPlan.get(serviceRec.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c) ){                                              
                if(plan.Label == serviceRec.mainCharge__r.Type__c){
                    Notification_Preference__c nfIRWelcome = new Notification_Preference__c();
                    Notification_Preference__c nfIRUsage = new Notification_Preference__c();
                    //Notification Record Preference Record creation for IRWelcome
                    nfIRWelcome.Account_Id__c = serviceRec.csord__Subscription__r.csord__Account__c;
                    nfIRWelcome.Category__c	= 'Service';	

                    if(plan.Communication_Method__c == 'Email'){
                        nfIRWelcome.Contact_Id__c = serviceRec.Billing_Account__r.Billing_Account_Owner__c;
                    }
      
                    nfIRWelcome.IsActive__c	= True;
                    nfIRWelcome.Notification_Type__c = 'IR Welcome';
                    nfIRWelcome.Service_Id__c = serviceRec.id;
                    nfIRWelcome.Service_Number__c = serviceRec.csordtelcoa__Service_Number__c;   
                    nfIRWelcome.Communication_Method__c = plan.Communication_Method__c;	
                    
                    //Notification Record Preference Record creation for IRUsage
                    nfIRUsage = nfIRWelcome.clone(); 
                    nfIRUsage.Notification_Type__c = 'Usage'; 
                    notificationPreferenceList.add(nfIRWelcome);
                    notificationPreferenceList.add(nfIRUsage);
                }
            }
        }
        return notificationPreferenceList;        
    }
/*=========================================================================================================================
EDGE       -EDGE-170949/170948
Method     -fetchProductandPlanMetadata 
Description-get all the Products and its related Plans from CustomMetadata
Author     -Dheeraj Bhatt/Veena Putta
===========================================================================================================================*/
    public static  Map<string,List<Plan__mdt>> getProductandPlanMetadata(){
        return ConstantMetadataUtility.fetchProductandPlanMetadata();
    }
}