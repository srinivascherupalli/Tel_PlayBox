/*------------------------------------------------
EDGE        -150891
Class       -GeneratePORAgreement
Description - This class is called from the Flow and it will update the CONGA URL in POR Record.
Author      -Purushottam Sahu
*  ** Change Log **
*  Sl. No.  Developer Name      Date            Story           Description
*  1.       Ajith               24/06/2021      EDGE-216822     Removal of LOA field and Validations on LOA field from New POR creation lightning component screen
--------------------------------------------------*/
public without sharing class GeneratePORAgreement {
    Private final static String POR_Query='PORDetails';
    Private final static String POR_Categories_Query='PORCategories';
    Private final static String POR_Template='POR Agreement Form';
    
    @InvocableMethod
    public static void updatePORCongaURL(List<Id> porId){
        String result='Failure';
        String queryId =NULL;
        String categoryQueryId =NULL;
        String templateid=NULL;
        Interface_Activation__c iActivation = Interface_Activation__c.getValues(Label.DocuSign_Interface);
        Map<Id,String> PORAttachments = new Map<Id,String>();
        List<Partner_of_Record__c> updatedPORList= new List<Partner_of_Record__c>();
        List<String> queryNameList = new  List<String>{POR_Query,POR_Categories_Query};
            
            try{
                List<APXTConga4__Conga_Merge_Query__c> queryList = [SELECT id,APXTConga4__Name__c 
                                                                    FROM APXTConga4__Conga_Merge_Query__c 
                                                                    WHERE APXTConga4__Name__c IN :queryNameList];
                System.debug('queryList'+queryList);
                List<APXTConga4__Conga_Template__c> templateList = [SELECT id FROM APXTConga4__Conga_Template__c 
                                                                    WHERE APXTConga4__Name__c=:POR_Template];
                
                for(APXTConga4__Conga_Merge_Query__c congaQuery : queryList){
                    if(congaQuery.APXTConga4__Name__c==POR_Query){
                        queryId = congaQuery.id;
                    }else if(congaQuery.APXTConga4__Name__c==POR_Categories_Query){
                        categoryQueryId = congaQuery.id;
                    }
                }
                templateid= !templateList.isEmpty()?templateList[0].id:'';
                
               //Removed the existing attachements getting added as part of EDGE-216822
                for(Partner_of_Record__c POR : [SELECT Id,Conga_URL__c,Name,Partner_Signatories__c,customer_Signatories__c,Customer__r.APTPS_DocuSign_Restricted__c,customer__r.APTPS_Off_Shore_Restricted__c from Partner_of_Record__c where Id IN :porId])
                {                    
                    String porAgreement = 'Partner+Authorisation'+'+-+'+(POR.Name).replace('-', '+-+');
                    String URL;
                    if(POR.Customer__r.APTPS_DocuSign_Restricted__c ||POR.Customer__r.APTPS_Off_Shore_Restricted__c || (iActivation != null && !iActivation.Status__c)){
                       URL ='&Id='+POR.Id+'&TemplateId='+'['+porAgreement+']'+templateid+'&ZipFiles=0'+'&QueryId=['+POR_Query+']'+queryId+'?pv0='+POR.Id+'&QueryId=['+POR_Categories_Query+']'+categoryQueryId+'?pv0='+POR.Id+
                        '&AttachmentParentId='+POR.Id+'&QMode=SalesforceFile&DefaultPDF=1&SC0=1&SC1=SalesforceFile';
                    }else
                     URL ='&Id='+POR.Id+'&TemplateId='+'['+porAgreement+']'+templateid+'&ZipFiles=0'+
                        '&DocuSignR1Id='+POR.customer_Signatories__c+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR1EmailSubject=Signature required: Telstra partner authorisation ('+POR.Name+
                        ')&QueryId=['+POR_Query+']'+queryId+'?pv0='+POR.Id+'&QueryId=['+POR_Categories_Query+']'+categoryQueryId+'?pv0='+POR.Id+
                        '&DocuSignR2Id='+POR.partner_Signatories__c+'&DocuSignR2Type=Signer&DocuSignR2Role=Signer+2&DocuSignR2RoutingOrder=2&DocuSignR2EmailSubject= Signature required: Telstra partner authorisation ('+POR.Name+')' +
                        '&DocuSignEndpoint='+Label.DocusignEndpoint+
                        '&AttachmentParentId='+POR.Id+'&QMode=DocuSign&DefaultPDF=1&SC0=1&SC1=SalesforceFile&DocuSignRemindIn=2&DocuSignRemindAgainIn=5';
                    POR.conga_URL__c=URL;
                    System.debug('GeneratePORAgreement:'+URL);
                    updatedPORList.add(POR);
                }
                if(!updatedPORList.isEmpty()){
                    update updatedPORList;
                }
           }
        catch(Exception e){
            for(Partner_of_Record__c POR : [SELECT Id,Conga_URL__c,Name,Partner_Signatories__c,customer_Signatories__c from Partner_of_Record__c where Id IN :porId]) {
                System.debug('Exception in updatePORCongaURL: '+e.getStackTraceString()+' '+e.getMessage());
                POR.addError('Exception in URL Updating : '+e.getMessage());
            }
        }
    }
}