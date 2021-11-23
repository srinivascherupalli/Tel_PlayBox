/*
* Updates:
* 1. Vaibhav : EDGE-98386 - Suspend order related changes
@Modified Date & Description: 22/10/2020, P2OB-9978[Sprint 20.14] updated version to 50
@Last Modified	: 07/01/2020 21.01 by Sri, Team SFO
				  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified	: 
*/ 
public with sharing class PortfolioCodeController {
    set<string> setPortfoliocodes = new set<string>();
    public boolean prtfcode {set;get;}
    public boolean suspendedSub{set;get;}
    public PortfolioCodeController(ApexPages.StandardController stdController){
        String strAccountId = apexpages.currentpage().getparameters().get('id');
        for(PortfolioCodes__mdt objCodes : [select DeveloperName,MasterLabel from PortfolioCodes__mdt])
        {
            setPortfoliocodes.add(objCodes.DeveloperName);
        }

        if(strAccountId != null) {
            for(Account objAcc : [Select Id,Portfolio_Code__c FROM Account WHERE Id =: strAccountId])
            {
                if(setPortfoliocodes.contains(objAcc.Portfolio_Code__c))
                {
                    Prtfcode = true;
                }
                else
                {
                    Prtfcode = false;
                }
            }
            //EDGE-98386 -start
            for(csord__Subscription__c sub:[select id,csord__Status__c from csord__Subscription__c where csord__Account__c=:strAccountId] ){
                if(sub.csord__Status__c.containsIgnoreCase('Suspended')){suspendedSub = true; break;}else{suspendedSub = false;}
            }//EDGE-98386- end
        }
    }
}