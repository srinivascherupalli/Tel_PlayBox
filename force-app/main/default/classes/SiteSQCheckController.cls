/*************************************************************************************************
Name : SiteSQCheckController
EDGE-> 71662
Description : To Make Callout To Initiate SQ for Site from Site detail page
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Ravi Shankar     15/04/2019  	To initiate the NBN SQ from the site detail page on button click
2.        Nitin Kumar      10/08/2021   Commenting view url as part of DIGI-335 
3.        Ajith Kumar      29/08/2021   Code Refactoring changes
===============================================================================================================================
***************************************************************************************************/
public with sharing class SiteSQCheckController {
    
    private static string NBN_Fiber='NBN Fibre';
    private static string NBN_Ethernet='NBN Ethernet';   
    private static final string className='SiteSQCheckController';
    /*************************************************************************************************
    Name : triggerSQCheck
    EDGE-> 119161
    Author:Ila
    Description : Method to trigger SQ Site
    ***********************************************************************************************/
    @AuraEnabled
	public static String triggerSQCheck(String addressId, String siteId,String tech){
        String resultStr = '';
        try{            
            // P2OB-7333 to differenciate between NBN Fibre and NBN Ethernet passing tech too
            SQcheckCalloutHandler sdlc = new SQcheckCalloutHandler(new list<String>{addressId}, siteId, true,tech);
            resultStr = sdlc.syncExecute(tech);        
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return resultStr;
    }

    /*************************************************************************************************
    Name : getLatestSq
    EDGE-> 119161
    Author:Ila
    Description : Method to get the latest SQ on site
    ***********************************************************************************************/   
    @AuraEnabled
    public static List<SubWrapper> getLatestSq(String siteId){
        List<SubWrapper> lstwrap= new List<SubWrapper>();
        try{
            String url =  URL.getSalesforceBaseUrl().toExternalForm();
            List<String> technologyType = System.Label.NBN_Technology_Type.Split(',');            
            SubWrapper wrap_NBN_Fibre = new SubWrapper(NBN_Fiber);
            SubWrapper wrapNew = new SubWrapper(Label.Telstra_Fibre);
            SubWrapper wrap_NBN_Ethernet = new SubWrapper(NBN_Ethernet);
                for(Service_Qualification__c objSQ: [SELECT id,Status__c,isLatestValidResult__c,LastModifiedDate,Technology_Type__c 
                FROM Service_Qualification__c WHERE Site__c =:siteId 
                AND (Technology_Type__c IN :technologyType OR Technology_Type__c =:Label.Telstra_Fibre OR Technology_Type__c =:Label.NBN_Ethernet_Technology_Type ) 
                AND isLatestValidResult__c=True]){                    
                    if(technologyType.contains(objSQ.Technology_Type__c)){
                        wrap_NBN_Fibre.Status = objSQ.Status__c;
                        wrap_NBN_Fibre.VerficationDt=objSQ.LastModifiedDate;
                    }
                    if(objSQ.Technology_Type__c==Label.Telstra_Fibre){
                        wrapNew.Status = objSQ.Status__c;
                        wrapNew.VerficationDt= objSQ.LastModifiedDate;
                    }
                    if(objSQ.Technology_Type__c==Label.NBN_Ethernet_Technology_Type){
                        wrap_NBN_Ethernet.Status = objSQ.Status__c;
                        wrap_NBN_Ethernet.VerficationDt= objSQ.LastModifiedDate;                        
                    }                    
                }
            lstwrap.add(wrap_NBN_Fibre);
            lstWrap.add(wrap_NBN_Ethernet);
            lstWrap.add(wrapNew);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return lstwrap;
    }
 /*************************************************************************************************
    Name : logException
    DIGI-> 2540
    Author: Ila
    Description : Method to log the Aura Handled Exceptions
    ***********************************************************************************************/
    @AuraEnabled
    public static void logException(String error,String methodName){
        try{
            GenericUtilityClass.logException(className,methodName,'',null,error+ ' - ' +' ' + ' - ' +'','Exception occured during retrieving the Latest service Qualification records',C2O_ExceptionHandler.Capability.ORD);
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /*************************************************************************************************
    Name : SubWrapper
    EDGE-> 119161
    Author: Ila
    Description : Wrapper to display on UI
    ***********************************************************************************************/
     public class SubWrapper{
        @AuraEnabled
        public String techType{get;set;}
        @AuraEnabled
        public String Status{get;set;}
        @AuraEnabled
        public Datetime VerficationDt{get;set;}
        @AuraEnabled
        public Boolean isSelected{get;set;}
         
        public SubWrapper(string display_tech){             
            this.techType= display_tech;
            this.Status = '';
            this.VerficationDt=null;
            this.isSelected=false;            
         }
    }
}