/*******************************************************************
@Class Name     :   SFOGenerateRecommendations_CBSnSFD
@Sprint         :   P2OB-14469 & P2OB-15094, Sprint 21.10
@Author         :   SFO Team (Sri)
@CreateDate     :   20/07/2021
@Description    :   To fetch the NBA recommendations for opportunity 
@References     :   Approve Partner Opportunities(Next Best Action strategy)
@TestCoverage   :   SFOGenerateRecommendations_CBSnSFDTest
@Last Modified  : 	Updated to use custom metadata labels as part of DIGI-11922 on 13/08/2021 by Sri (SFO)
@Last Modified  : 	

*********************************************************************/
global class SFOGenerateRecommendations_CBSnSFD {
    public static boolean isSFDCaseExists = false;
    public static boolean isCBSCaseExists = false;
    
    /*
    @Method Name: getRecommendations
    @Description: P2OB-14469 & P2OB-15094, Sprint 21.10
				  to create the recommendation for given opportunityid
    @Author		: Sri (Team SFO)
    */
    @InvocableMethod
    global static List<List<Recommendation>> getRecommendations(List<String> inputData){
        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
        List<Recommendation> recs = new List<Recommendation>(); 
        try {
            Opportunity opp = [SELECT Id, StageName, Product_Type__c,sfd_Opt_Out_Reason__c, Owner.UserType  FROM Opportunity WHERE  Id =:inputData LIMIT 1 ];
            //if opportunity is a non parnter, non modular and in propose stage then need to check for whether the CBS or SFD case available
            //if not no recommendations required
            if(opp?.StageName == 'Propose' && opp?.Product_Type__c == Label.Opp_ProductType_NonModular && opp.Owner.UserType != 'PowerPartner'){
                checkCaseExistence(opp.Id);
            }else{
                return outputs;
            }
            //check the recommendation eligibility and create the corresponding Recommendation
            if(!isSFDCaseExists && String.isBlank(opp?.sfd_Opt_Out_Reason__c)){
                Recommendation rec = new Recommendation(
                    Name = SFO_Custom_Labels__mdt.getInstance('SFD_name')?.Label_Value__c,
                    Description = SFO_Custom_Labels__mdt.getInstance('SFD_Description')?.Label_Value__c,                       
                    ActionReference = 'CBS_Billing_Contract',
                    AcceptanceLabel = SFO_Custom_Labels__mdt.getInstance('SFD_AcceptanceLabel')?.Label_Value__c,
                    //RejectionLabel = 'Do not Engage SFD', 
                    Recomendation_Purpose__c = 'SFD'
                );
                recs.add(rec);
            }
            if(!isCBSCaseExists){
                Recommendation rec = new Recommendation(
                    Name = SFO_Custom_Labels__mdt.getInstance('CBS_name')?.Label_Value__c,
                    Description = SFO_Custom_Labels__mdt.getInstance('CBS_Description')?.Label_Value__c,                       
                    ActionReference = 'CBS_Billing_Contract',
                    AcceptanceLabel = SFO_Custom_Labels__mdt.getInstance('CBS_AcceptanceLabel')?.Label_Value__c,
                    //RejectionLabel = 'Do not Engage CBS',
                    Recomendation_Purpose__c = 'CBS'
                );
                recs.add(rec);
            }
            outputs.add(recs);
        }
        catch (Exception ex) {
            system.debug('Exception:::: SFOGenerateRecommendations_CBSnSFD :::: getRecommendations Method'+ ex.getMessage());
        }
        return outputs;
    }
    
    /*
    @Method Name: checkCaseExistence
    @Description: P2OB-14469 & P2OB-15094, Sprint 21.10
				  to check is there any CBS or SFD cases for given opportunityid
    @Author		: Sri (Team SFO)
    */
    public static void checkCaseExistence(Id oppId){
        boolean result;
        string recordTypeSFD = 'SFD_Request';
        string recordTypeCBS = 'CBS';
        try{
            for(Case oppCase: [select id, recordType.developername, srvsup_Categories__c from case where OpportunityId__c =:oppId AND (recordType.developername =:recordTypeSFD OR recordType.developername =:recordTypeCBS)]){
                if(oppCase.recordType.developername == recordTypeCBS && oppCase.srvsup_Categories__c == 'Billing Solution Contract Implementation'){
                    isCBSCaseExists = true;
                }
                if(oppCase.recordType.developername == recordTypeSFD){
                    isSFDCaseExists = true;
                }
            }
        }
        catch (Exception ex) {
            system.debug('Exception:::: SFOGenerateRecommendations_CBSnSFD :::: checkCaseExistence Method'+ ex.getMessage());
        }
    }
}