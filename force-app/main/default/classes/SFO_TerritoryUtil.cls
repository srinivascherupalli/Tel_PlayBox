/********************************************************************************
* Class Name  : SFO_TerritoryUtil
* Description : SFO_TerritoryUtil contains methods which are used for get the respective Territory details
* Test class  : SFO_TerritoryUtilTest
* Created By  : Sri (Team SFO)   
* Modified By : Pallavi B(Team SFO) Sprint 21.13 DIGI-8909
********************************************************************************/
public class SFO_TerritoryUtil {
    /*******************************************************************
    @Method Name    :   getTerritoryUsersByRole
    @Sprint         :   20.12  & P2OB-6044
    @Author         :   SFO Team (Sri)
    @CreateDate     :   31/08/2021
    @Description    :   To get the users for the given Territory Codes
    @TestCoverage   :   SFO_TerritoryUtilTest
    @Updated        :   
    *********************************************************************/
    public static list<UserTerritory2Association> getTerritoryUsersByRole(String portCode, String userRole, Boolean isTravelHirarchy){
        list<UserTerritory2Association> usersListInTerritory; // = new list<UserTerritory2Association>();
        if(portCode == null || portCode == ''){
            return new list<UserTerritory2Association>(); //if portCode is empty return empty list no need of running query
        }

        usersListInTerritory = getTerritoryUsersByRole(portCode, userRole);

        if(usersListInTerritory.isEmpty() && isTravelHirarchy){
            usersListInTerritory = getTerritoryUsersByRole(getParentPortfolioCode(portCode), userRole,isTravelHirarchy);
        }
        system.debug(':: usersListInTerritory size ::'+usersListInTerritory.size());
        return usersListInTerritory;
    }
    
    /*******************************************************************
    @Method Name    :   getParentPortfolioCode
    @Sprint         :   20.12  & P2OB-6044
    @Author         :   SFO Team (Sri)
    @CreateDate     :   31/08/2021
    @Description    :   To get the parent Territory Code for the given Territory Code
    @TestCoverage   :   SFO_TerritoryUtilTest
    @Updated        :   
    *********************************************************************/
    public static String getParentPortfolioCode(String portfolioCode){
        String parentPortfolioCode = null;
        List<Territory2> territoryRecs = [select Id, DeveloperName, ParentTerritory2.Name from Territory2 where DeveloperName = :portfolioCode LIMIT 1];
        if(!territoryRecs.isEmpty()){
            parentPortfolioCode = territoryRecs[0].ParentTerritory2.Name;
        }
        return parentPortfolioCode;
    }

    /*******************************************************************
    @Method Name    :   getTerritoryUsersByRole
    @Sprint         :   20.12  & P2OB-6044
    @Author         :   SFO Team (Sri)
    @CreateDate     :   31/08/2021
    @Description    :   To get the users for the given Territory Codes
    @TestCoverage   :   SFO_TerritoryUtilTest
    @Updated        :   
    *********************************************************************/
    public static list<UserTerritory2Association> getTerritoryUsersByRole(String portCode, String userRole){
        list<UserTerritory2Association> usersListInTerritory = new list<UserTerritory2Association>();
        String usersListInTerritoryQuery = 'select id, userid, user.Name, RoleInTerritory2, Territory2.Name from UserTerritory2Association ';
        if(portCode <> null && userRole <> null){
            usersListInTerritoryQuery += 'where Territory2.Name =\'' +string.escapeSingleQuotes(portCode) +'\' and RoleInTerritory2 =\'' +string.escapeSingleQuotes(userRole) +'\'';
        }else if(portCode <> null && userRole == null){
            usersListInTerritoryQuery += 'where Territory2.Name =\'' +string.escapeSingleQuotes(portCode) +'\' ';
        }
        usersListInTerritory = Database.query(usersListInTerritoryQuery);
        return usersListInTerritory;
    }


    /*******************************************************************
    @Method Name    :   getTerritoryUsers
    @Sprint         :   20.12  & P2OB-6044
    @Author         :   SFO Team (Sri)
    @CreateDate     :   31/08/2021
    @Description    :   To get the users for the given Territory Codes
    @TestCoverage   :   SFO_TerritoryUtilTest
    @Updated        :   21.13 & DIGI-8909 (Pallavi B) SFO Team. 
    *********************************************************************/
    public static Map<String, list<Id>> getTerritoryUsers(list<String> portCodes){
        Map<String, list<Id>> mapOfPortCodeUserTerritories = new Map<String, list<Id>>();
        for(UserTerritory2Association user:[select id, userid, user.Name, RoleInTerritory2, Territory2.Name, user.Email from UserTerritory2Association where Territory2.Name =:portCodes]){
            if(!mapOfPortCodeUserTerritories.isEmpty() && mapOfPortCodeUserTerritories.containsKey(user.Territory2.Name)){
                mapOfPortCodeUserTerritories.get(user.Territory2.Name).add(user.userid);
            }
            else{
                mapOfPortCodeUserTerritories.put(user.Territory2.Name, new list<Id>{user.userid});
            }
        }
        return mapOfPortCodeUserTerritories;
    }
    

}