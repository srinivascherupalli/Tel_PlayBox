/*******************************************************************
@Class Name     :   SFOIdentifyPortfolioCodeInfo
@Sprint         :   20.10  & P2OB-6270
@Author         :   SFO Team (Sri)
@CreateDate     :   14/07/2020
@Description    :   To Identify Gaining GM and Losing GM when revenue targets are maintained at Portfolio Level, CIDN Level
@References     :   Miscellaneous MVDs(Flow)
@TestCoverage   :   SFOIdentifyPortfolioCodeInfoTest
@Last Modified    :     07/01/2020 21.01 by Sri, Team SFO
                    as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified    :   30/08/2021 21.01 by Chhaveel, Team SFO
                    as part of DIGI-8998 Replacing ‘Owner' role in the SOQL query to 'General Manager’ in method getOwnerId
*********************************************************************/
public without sharing class SFOIdentifyPortfolioCodeInfo {
    
    private static List<String> portCodesList = new List<String>();
    private static List<String> userIdList = new List<String>();
    private static Map<String, Portfolio_Code__c> mapOfPortCodesWithRevTarget = new Map<String, Portfolio_Code__c>();
    private static String parentPortfolioCode;
    
    /*******************************************************************
@Method Name    :   identifyPortfolioCodeInfo
@Sprint         :   20.10  & P2OB-6270
@Author         :   SFO Team (Sri)
@CreateDate     :   14/07/2020
@Description    :   To Identify Gaining GM and Losing GM when revenue targets are maintained at Portfolio Level, CIDN Level
@References     :   Miscellaneous MVDs(Flow)
@TestCoverage   :   SFOIdentifyPortfolioCodeInfoTest
@Updated        :   
*********************************************************************/
    @InvocableMethod
    public static list<String> identifyPortfolioCodeInfo(List<String> portfolioCodes){
        try{            
            //get the list of PortCodes with RevTarget
            mapOfPortCodesWithRevTarget = getPortCodesWithRevTarget(); 
            
            //find the parent portfolio code
            parentPortfolioCode = getParentPortfolioCode(portfolioCodes);

 

            //find the owner by passing parent portfolio code
            userIdList = new List<String>();
            userIdList.add(getOwnerId(parentPortfolioCode));
        }
        catch(Exception ex){
            system.debug('Exception in identifyPortfolioCodeInfo method ::: '+ex.getMessage());
        }
        return userIdList;
    }    

 

    /*******************************************************************
@Method Name    :   getPortCodesWithRevTarget
@Sprint         :   20.10  & P2OB-6270
@Author         :   SFO Team (Sri)
@CreateDate     :   14/07/2020
@Description    :   To get the list of portfolio codes which are having 'revenue target' in 'Portfolio codes (Revenue Targets)' object
@References     :   identifyPortfolioCodeInfo
@TestCoverage   :   SFOIdentifyPortfolioCodeInfoTest
@Updated        :   
*********************************************************************/
    public static Map<String, Portfolio_Code__c> getPortCodesWithRevTarget(){
            //get the list of portfolio codes which are having 'revenue target' in 'Portfolio codes (Revenue Targets)' object
            // P2OB-9666 : As per AC2 including Portfolio_Code__c negative Revenue_Target__c
            for(Portfolio_Code__c portCode:[select id, name, Revenue_Target__c from Portfolio_Code__c where Revenue_Target__c != null]){
                mapOfPortCodesWithRevTarget.put(portCode.name, portCode);
            }
        return mapOfPortCodesWithRevTarget;
    }
    /*******************************************************************
@Method Name    :   getParentPortfolioCode
@Sprint         :   20.10  & P2OB-6270
@Author         :   SFO Team (Sri)
@CreateDate     :   14/07/2020
@Description    :   To get the Parent for the given PortfolioCode 
@References     :   identifyPortfolioCodeInfo
@TestCoverage   :   SFOIdentifyPortfolioCodeInfoTest
@Updated        :   
*********************************************************************/
    public static String getParentPortfolioCode(List<String> portfolioCodes){
        try{
            List<String> territoryPortName;
            parentPortfolioCode = '';
            for(Territory2 territoryPortCode: 
                [select Id, DeveloperName, ParentTerritory2.Name from Territory2 where DeveloperName = :portfolioCodes]){
                    if(!mapOfPortCodesWithRevTarget.containsKey(territoryPortCode.DeveloperName)){
                        territoryPortName = new List<String>();
                        territoryPortName.add(territoryPortCode.ParentTerritory2.Name);
                        getParentPortfolioCode(territoryPortName);
                    }else{
                        parentPortfolioCode = territoryPortCode.DeveloperName;
                        return parentPortfolioCode;
                    }
                }
        }
        catch(Exception ex){
            system.debug('Exception in getTerritoryInfo method ::: '+ex.getMessage());
        }
        return parentPortfolioCode;
    }
    /*******************************************************************
@Method Name    :   getOwnerId
@Sprint         :   20.10  & P2OB-6270
@Author         :   SFO Team (Sri)
@CreateDate     :   14/07/2020
@Description    :   To get the Owner for the given PortfolioCode 
@References     :   identifyPortfolioCodeInfo
@TestCoverage   :   SFOIdentifyPortfolioCodeInfoTest
@Updated        :   30/08/2021 21.01 by Chhaveel, Team SFO
                    as part of DIGI-8998 Replacing ‘Owner' role in the SOQL query to 'General Manager'
*********************************************************************/
    public static String getOwnerId(String parentPortfolioCode){
        try{
            if(parentPortfolioCode != null){
                list<SFO_Custom_Labels__mdt> gmValue = [SELECT Label_Value__c FROM SFO_Custom_Labels__mdt where MasterLabel  = 'Role In The Territory' LIMIT 1];
                UserTerritory2Association terUser = [select id, userid, user.Name, RoleInTerritory2, Territory2.Name 
                                                     from UserTerritory2Association where RoleInTerritory2 =: gmValue[0].Label_Value__c and Territory2.Name = :parentPortfolioCode LIMIT 1];  
                if(terUser != null){
                    return terUser.userId;
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception in getTerritoryInfo method ::: '+ex.getMessage());
        }
        return null;
        
    }    
}