/*------------------------------------------------
EDGE        - TED-383
Class       - GetEchosignAgreementTemplate
Description - This class used to fetch Adobe agreement template records.
Author      - Vamsi Krishna Vaddipalli
Date        - 07OCT2021
--------------------------------------------------*/
public class GetEchosignAgreementTemplate {
    
    public static List<echosign_dev1__Agreement_Template__c> getEchoSignAgreementTemplateIds()
    {
        List<echosign_dev1__Agreement_Template__c> eSignTemplateids = new List<echosign_dev1__Agreement_Template__c>();
        eSignTemplateids = [Select id,name from echosign_dev1__Agreement_Template__c LIMIT 50]; //TED-383
        system.debug('List template'+eSignTemplateids);
        
        if(!eSignTemplateids.isEmpty())
        {
            return eSignTemplateids;   
        }

          return null;
    }
    

}