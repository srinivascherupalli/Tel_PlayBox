global with sharing class CustomButtonSolutionManagement extends csbb.CustomButtonExt {

    global String performAction(String basketId, String pcrIds) {
        system.debug('pcrIds------>'+pcrIds);
        List<String> prodConfigRequestIds = (List<String>) System.JSON.deserialize(pcrIds, List<String>.class);
        String redirectURI = null;
        List<csbb__product_configuration_request__c> pcrs = [
                select id, csbb__product_configuration__c,
                        csbb__product_configuration__r.cssdm__solution_association__c
                from csbb__product_configuration_request__c
                where id in :prodConfigRequestIds
        ];
        Set<String> selectedSolutions = new Set<String>();
        for (csbb__product_configuration_request__c pcr : pcrs) {
            if (pcr.csbb__product_configuration__r.cssdm__solution_association__c != null) {
                selectedSolutions.add(pcr.csbb__product_configuration__r.cssdm__solution_association__c);
            }
        }
       Boolean orgType = runningInASandbox();
       if(Site.getSiteId() == null){
            // Standard
            redirectURI = cssmgnt.API_1.getSolutionManagementURL() + '?basketId=';
        }else{
            // Community
			
			if(!orgType){
						redirectURI = '/s/sfdcpage/%2Fapex%2Fcssmgnt__sceditor%3FbasketId%3D';
            }
            else {

                    redirectURI = '/partners/s/sfdcpage/%2Fapex%2Fcssmgnt__sceditor%3FbasketId%3D';   
                //redirectURI = '/partners/apex/cssmgnt__sceditor?basketId=';  
        
            }
        }
        system.debug('URL----------?'+redirectURI);
        if (!selectedSolutions.isEmpty() && selectedSolutions.size() > 1) {
            return '{"status":"error","title":"More than one network is selected","text":""}';
        } else if (!selectedSolutions.isEmpty()) {
            List<String> solutionList = new List<String>(selectedSolutions);
            return '{"status":"ok", "redirectURL":"' + redirectURI + basketId + '&selectedSolution=' + solutionList[0] + '"}';
        } else {
            return '{"status":"ok", "title":"Opening Solution Console...", "redirectURL": "' + redirectURI + basketId + '" }';
        }
    }
    public static Boolean runningInASandbox() {
      return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

}