/*************************************************************************************************
Name : NewBasketOverrideRedirectPageController
Description : Used to restrict the number of Baskets under opportunity to 1. If it is 0, redirects
              to BasketbuilderApp page

* ModifiedBy     ModifiedDate     Edge          Description
* Ankush Rana    05/08/2021       DIGI-721      As a Sales or partner user I should not be allowed to create a Product Basket from a Deal Opportunity. This is because Deal opportunities should only have Frame agreements created against them
***************************************************************************************************/


global with sharing class NewBasketOverrideRedirectPageController{

    public static cscfga__Product_Basket__c basket {get;set;}
    public static String oppId{get;set;}
    public static String basketId{get;set;}
    public static boolean isNotError{get;set;}
    public static boolean isOppRedirect{get;set;}
    private static boolean isCPC;
       
    public NewBasketOverrideRedirectPageController(ApexPages.StandardController ctrl) {
        basket = (cscfga__Product_Basket__c)ctrl.getRecord();
        system.debug('****'+basket);
        oppId=findLinkedId();
        System.debug('****'+oppId);
        isNotError = true;
        isOppRedirect = false;
        isCPC = false;
       }
          
       
       public void init() {
           
          Integer count=0;
          AggregateResult[] result = [SELECT COUNT(Id), cscfga__Opportunity__c  FROM cscfga__Product_Basket__c where  cscfga__Opportunity__c=:oppId  GROUP BY cscfga__Opportunity__c];
          System.debug('result&&&&'+result);
           for(AggregateResult ar: result) {
             count = (INTEGER)ar.get('expr0');
             }
             System.debug('count&&&&'+count); 
             Id profileId= UserInfo.getProfileId();            
               Phoenix_Profiles__c pf = Phoenix_Profiles__c.getInstance(profileId);           
              List<cscfga__Product_Basket__c> basketList = [Select cscfga__Opportunity__r.Product_Type__c FROM cscfga__Product_Basket__c where  cscfga__Opportunity__c=:oppId];
               for(cscfga__Product_Basket__c bas: basketList)
               {
                   if(pf.isPhoenixProfile__c)
                   {
                       isCPC = true;
                       break;
                   }
                      
               }
           //EDGE-22590 ---to return error message if Opportunity is Closed Won or Closed Lost.
           List<Opportunity> opptyList = [select StageName,RecordType.DeveloperName,Product_Type__c,Pricing_Method__c 
                                         from Opportunity where Id = :oppId];
           for(Opportunity oppty : opptyList){
               if(oppty.StageName == 'Closed Won' || oppty.StageName == 'Closed Lost')
               {
                   isNotError = false;
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'New baskets cannot be created as the Opportunity is now closed.');
                   ApexPages.addMessage(myMsg);
                   break;
                   //DIGI-721 start
               }else if(oppty.RecordType.DeveloperName =='Defined' && oppty.Product_Type__c == 'Modular' && oppty.Pricing_Method__c == 'Delegated Pricing'){
                   isNotError = false;
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'New product basket cannot be created from Digitised Deal opportunity');
                   ApexPages.addMessage(myMsg);
                   break;
                   //DIGI-721 end
               }
   
           }
           if(isNotError == true)
           {     
               if(count>=1 && basket.id == null && isCPC)
               {
                   isNotError = false;
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Only one Basket can be created for opportunity');
                   ApexPages.addMessage(myMsg);
   
               }
               else
               {
                  
                   if (basket == null || basket.id == null) {
                        basket = new cscfga__Product_Basket__c(
                            cscfga__opportunity__c = findLinkedId()
                        );
                        upsert basket;
                        basketId = basket.Id;
                        isNotError = true;
                    }
                   else if (basket.id!=null)
                   {
                      
                      oppId =[Select cscfga__Opportunity__c from cscfga__Product_Basket__c where id=:basket.id].cscfga__Opportunity__c;
                      isNotError = true;
                      isOppRedirect = true;
                      
                   } 
                 
               }
             
               
           }            
       }
   
       private static String findLinkedId() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String retVal = params.get('linkedId');
        System.debug('****'+retVal);
        if (!String.isBlank(retVal)) {
            return retVal;
        }
        for (String key : params.keySet()) {
            if (key.endsWith('_lkid')) {
                retVal = params.get(key);
                break;
            }
        }
        System.debug('****'+retVal);
        return retVal;
       }
     
   
   }