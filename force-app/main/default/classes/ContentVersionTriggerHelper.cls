/*****************************************************************************
@Name : ContentVersionTriggerHelper
@Description : This Class is Helper for ContentVersionTrigger Trigger 
@Created by : Chandrakant Wani as part of  P2OB-12607.
@Description : Logic to attach file upload by integartion user to record.
*******************************************************************************/

public without sharing class ContentVersionTriggerHelper {
  
    public static void attachFileToRecord(list<ContentVersion> cvList){

        //System.debug('Inside ContentVersionTriggerHelper '+ cvList.size());
        Id profileId = UserInfo.getProfileId();
        //System.debug('User Name '+ UserInfo.getName());
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //System.debug('profileName '+ profileName);      
        
        if(cvList != null && (profileName == 'Integration - TConnect' && 
        (UserInfo.getName() == Label.Integration_User_1 || 
        UserInfo.getName() == Label.Integration_User_2)))
        {
            List<ContentDocumentLink> lstConDocLink =  new List<ContentDocumentLink>();
            for (ContentVersion cv : cvList ) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                //System.debug('isnide if '+ cv.ContentDocumentId);
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = cv.Record_Id__c;
                lstConDocLink.add(cdl);
            }
            if(lstConDocLink != null)
            insert lstConDocLink;
            //System.debug('lstConDocLink if '+ lstConDocLink);
        }
    }
}