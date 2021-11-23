/**
     Description :  P2OB-7583 Controller for aura component prmKArticlefeedback
     Author      :  Ritika Jaiswal, Team Hawaii 
     Created Date:  10 August 2020 
     Jira        :  P2OB-7583
 **/
public without sharing class  prmKArticlefeedbackController {
    //Method to get custom-metadata associated with given article's record-type
    @AuraEnabled
    public static PRM_KArticle_Feedback__mdt getCustomMdt(String urlName){
        system.debug('***Telstra:prmKArticlefeedbackController:getCustomMdt:inputs:'+urlName);
        PRM_KArticle_Feedback__mdt mdt_record;
        //Query on Article to find record-type name
        String queryStrArticle = ' SELECT id,recordtype.developerName,urlName \n ' +
                          ' FROM Knowledge__kav \n ' +
                          ' WHERE urlname = \'' + String.escapeSingleQuotes(urlName) + '\' and PublishStatus =\'Online\'  LIMIT 1 ';
                          
        List<Knowledge__kav> articleDetails = Database.query(queryStrArticle);
        
        if(articleDetails !=null && !articleDetails.isEmpty()){
            
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('PRM_KArticle_Feedback__mdt')) + '\n ' +
                          ' FROM PRM_KArticle_Feedback__mdt \n ' +
                          ' WHERE Article_Record_Type__c = \'' + articleDetails.get(0).recordtype.developerName + '\' LIMIT 1 ';
        List<PRM_KArticle_Feedback__mdt> mdList = Database.query(queryStr);
        if(mdList!= null && !mdList.isEmpty()){
            mdt_record = mdList.get(0); 
            System.debug('***Telstra:prmKArticlefeedbackController:getCustomMdt:mdt_record :'+mdt_record +' articleDetails :'+articleDetails );            
            }    
        }
        return mdt_record ;
    }
    
}