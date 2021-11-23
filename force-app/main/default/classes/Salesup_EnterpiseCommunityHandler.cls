/*****************************************************************************
@Author: Chandrakant Wani
@CreateDate: 16-July-2020
@Description: This class contains logic to fetch case number created by guest user 
on community and show on flow screen
@References
Story : P2OB-8340
*******************************************************************************/
public Without Sharing class Salesup_EnterpiseCommunityHandler {

    /**
    * This method is used to fetch case number from Case Record.
    * @Author: Chandrakant
    * @Date: 16-July-2020
    */
    @InvocableMethod
    public static List<String> getCaseNumber(List<ID> CaseId) {
        List<String> lstCaseInfo = new List<String>();
        List<Case> lstCase =[SELECT CaseNumber from Case WHERE id in :CaseId];
        if(!lstCase.isEmpty())
        { 
            lstCaseInfo.add(lstCase[0].CaseNumber); 
        }
        return lstCaseInfo;
    }
}