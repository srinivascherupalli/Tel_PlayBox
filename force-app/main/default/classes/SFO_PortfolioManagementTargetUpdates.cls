/*******************************************************************
@Class Name:SFO_PortfolioManagementTargetUpdates
@Sprint :20.09  & P2OB-6272 , 20.12 &  P2OB-8608 && P2OB-7201 && 20.13 P2OB-9016
@Author:SFO Team (Sri,Pallavi,Sravanthi)
@CreateDate: 15/09/2020
@description: Calculates the Revenue updates requied for the case record.
@Related Test Class : SFO_PortfolioManagementCaseHelperTest
*********************************************************************/
public without sharing class SFO_PortfolioManagementTargetUpdates {
    /*******************************************************************
@Method Name    :   setPortfolioCodeRevTargets
@Sprint         :   20.10  & P2OB-6272
@Author         :   SFO Team (Pallavi,Sravanthi)
@CreateDate     :   09/07/2020
@description    :   To set  the revenue target for the Portfolio_Code__c records
@References     :   SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod
@TestCoverage   :   SFO_PortfolioManagementCaseHelperTest
@Updated        :   20.11  & P2OB-8414, P2OB-8415, P2OB-8416,20.12 &  P2OB-8608 && P2OB-7201 && 20.13 P2OB-9016 &&20.14 P2OB-6280
*********************************************************************/
    public static List<Portfolio_Code__c> setPortfolioCodeRevTargets(Case caseRecord,Boolean caseEnterpriseToSB ,Boolean caseSBToEnterprise){
        List<Portfolio_Code__c> lstofPortCodeRevtoUpdate = new List<Portfolio_Code__c>();
        try{
            //to get the Portfolio_Code__c records which are having revenue targert greater then zero
            Map<String, Portfolio_Code__c> mapOfPortCodesWithRevTargets = new Map<String, Portfolio_Code__c>();
            Portfolio_Code__c gainingPortCodeRec; // gainingPortCodeRec which need the Revenue Target adjustment
            Portfolio_Code__c losingPortCodeRec;  // losingPortCodeRec which need the Revenue Target adjustment
            Boolean doPortcodeUpdate; //to check proceed with the Revenue Target adjustment or not
            Boolean doPortcodeUpdateENTtoSB;// to check if portcode & target update required for ENTtoSB
            Boolean doPortcodeUpdateSBtoENT;// to check if portcode & target update required for SBtoENT
            
            mapOfPortCodesWithRevTargets = SFOIdentifyPortfolioCodeInfo.getPortCodesWithRevTarget();
            system.debug('map values with revenue targets'+mapOfPortCodesWithRevTargets);
            gainingPortCodeRec = getPortcodeRec(caseRecord.salesup_Gaining_Portfolio_Code__c , mapOfPortCodesWithRevTargets);
            losingPortCodeRec = getPortcodeRec(caseRecord.salesup_Portfolio_Code__c , mapOfPortCodesWithRevTargets);
            
            doPortcodeUpdate =(gainingPortCodeRec <> null && losingPortCodeRec <> null && caseRecord.New_Revenue_Target__c !=null && gainingPortCodeRec != losingPortCodeRec);
            //20.13 P2OB-9016 Losing Portcode Update for Move Accounts to Insolvency TransferType
            doPortcodeUpdateENTtoSB = ( losingPortCodeRec <> null && caseRecord.New_Revenue_Target__c !=null && (caseEnterpriseToSB || caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Account_to_Insolvency ));
            //P2OB-6280 : Gaining Portcode Update for Move Accounts out of Insolvency TransferType
			doPortcodeUpdateSBtoENT = ( gainingPortCodeRec <> null && caseRecord.New_Revenue_Target__c !=null && (caseSBToEnterprise || caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Account_Out_of_Insolvency)); 
            
            if(doPortcodeUpdate || doPortcodeUpdateSBtoENT){
                gainingPortCodeRec.Revenue_Target__c += caseRecord.New_Revenue_Target__c;
                lstofPortCodeRevtoUpdate.add(gainingPortCodeRec);
            }
            if(doPortcodeUpdate || doPortcodeUpdateENTtoSB){
                losingPortCodeRec.Revenue_Target__c -= caseRecord.New_Revenue_Target__c;
                lstofPortCodeRevtoUpdate.add(losingPortCodeRec); 
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'setPortfolioCodeRevTargets Exception ::: ' +ex.getMessage());
        }
        return lstofPortCodeRevtoUpdate;
    }
    /*******************************************************************
@Method Name    :   getPortcodeRec
@Sprint         :   20.12  & P2OB-7201
@Author         :   SFO Team (Sravanthi)
@CreateDate     :   14/9/2020
@description    :   To fetch Portfolio_Code__c records with revenue targets
@References     :   setPortfolioCodeRevTargets
@TestCoverage   :   SFO_PortfolioManagementCaseHelperTest
*********************************************************************/   
    public static Portfolio_Code__c getPortcodeRec(String portcode,Map<String, Portfolio_Code__c> mapOfPortCodesWithRevTargets) {
        Portfolio_Code__c recPortCode;
        Boolean isPortCodeWithRevTargetContains = false;
        String portcodeWithRevTarget = ''; //to hold the PortCode value which is having the Revenue Target
        
        if(String.isNotBlank(portcode)){
            portcodeWithRevTarget = SFOIdentifyPortfolioCodeInfo.getParentPortfolioCode(new list<String> {portcode});
            system.debug(portcode +'portcode with Revenue Target'+ portcodeWithRevTarget);
        }
        
        isPortCodeWithRevTargetContains = String.isNotBlank(portcodeWithRevTarget) && mapOfPortCodesWithRevTargets.containsKey(portcodeWithRevTarget);
        
        if(isPortCodeWithRevTargetContains){
            recPortCode = mapOfPortCodesWithRevTargets.get(portcodeWithRevTarget); 
        }
        
        return recPortCode;
    }   
}