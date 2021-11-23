/*************************************************************************************************
Name : SyncBasketOnClosedWonAndProposeOppty
Description : class called from Opportunity trigger,
              Used to sync  basket for non modular opportunity when opportunity stage is Propose or
              Closed Won

***************************************************************************************************/
public with sharing class SyncBasketOnClosedWonAndProposeOppty {
    
    //variable to prevent the running of the trigger twice
    public static Boolean isFirstRun = false;
    
    // method to call sync for non modular baskets, when Opportunity status is set to Propose or Closed Won
    public void synctheValidBasket(Set<Id> oppIdSet, List<Opportunity> oppList)
    {
        if(!isFirstRun)
        {
            isFirstRun = true;
            Set<Id> oppErrorIdSet = new Set<Id>();
            List<cscfga__Product_Basket__c> validBasketList = [Select id, cscfga__Basket_Status__c,cscfga__Opportunity__c,cscfga__Opportunity__r.stageName,primary_basket__c, csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where Primary_Basket__c=TRUE AND cscfga__Opportunity__c IN: oppIdSet];
            //List<cscfga__Product_Basket__c> validBasketList = [Select id, cscfga__Basket_Status__c,cscfga__Opportunity__c,cscfga__Opportunity__r.stageName,primary_basket__c, csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where cscfga__Basket_Status__c = 'Valid' AND Primary_Basket__c=TRUE AND cscfga__Opportunity__c IN: oppIdSet];
            String syncMsg = '';
            String displayMsg = '';
            Id profileId=userinfo.getProfileId();
            List<profile> profileList =[Select Id,Name from Profile where Id=:profileId];   
            String profileName = '';
            if(profileList !=null && profileList.size()>0)
              {
                profileName= profileList[0].Name;
              }
            for(cscfga__Product_Basket__c bas: validBasketList)
            {
                CustomButtonOpportunitySync sync= new CustomButtonOpportunitySync();
                syncMsg = sync.syncMessage(bas.Id,false);
                displayMsg = CustomButtonOpportunitySync.displayMessage;
                if(syncMsg.contains('error'))
                {
                    oppErrorIdSet.add(bas.cscfga__Opportunity__c);
                }else{
                    if(bas.cscfga__Opportunity__r.stageName == 'Develop'){
                        system.debug('New opp stage for non modular is develop');
                        bas.cscfga__Basket_Status__c = 'Valid';
                        bas.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
                    }else if(bas.cscfga__Opportunity__r.stageName == 'Propose' && !(profileName == 'Sales - Enterprise' || profileName == 'Sales Manager - Enterprise')){
                        system.debug('New opp stage for non modular is Propose');
                        bas.cscfga__Basket_Status__c = 'Valid';
                        bas.csordtelcoa__Basket_Stage__c = 'Quote';
                    }
                    update bas;
                }
            }
            
            if(oppErrorIdSet !=null && oppErrorIdSet.size()>0)
            {
                for(Opportunity opp: oppList)
                {
                    if(oppErrorIdSet.contains(opp.Id) && displayMsg!='')
                    {
                        opp.addError(displayMsg);
                    }
                }
            }
                 
        }
        
        
    }
    
}