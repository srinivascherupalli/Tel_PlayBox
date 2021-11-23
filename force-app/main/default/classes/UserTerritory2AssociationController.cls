/**
 * Author: Sandeep Soni
 * Team: Jaipur
 * Sprint: 20.12
 * JIRA Story: P2OB-8394
 * Date: 25 Aug 2020
 * Class Name: UserTerritory2AssociationControllers
 * Description: Create Custom Lightning Component to display Users in Territory Related List.
 * @Last Modified	:   02/09/2021 21.12 by Chhaveel, Team SFO
					    as part of DIGI-14600 Sales Territory to reflect the same recursive model as the Service Territory
 * @Last Modified	:   18/10/2021 21.14 by Chhaveel, Team SFO
					    as part of DIGI-26135 do not want to show Standard Solution Support roles in the Users in Assigned Territories component
 **/
public without sharing class UserTerritory2AssociationController {

    public static Map<ID, Territory2> mapTerritory = new Map<ID, Territory2>() ;
    public static List<ID> lstTerritoryId = new List<ID>();

    /**
     * Method Name:         getUserTerritory2Association()
     * Input Parameter:     accountId
     * Output Paramater:    List<UserTerritoryWrapper>
     * Description:         For fetching the list of all UserTerritoryAssociation records based on accountid.
     */
    @AuraEnabled(cacheable = true)
    public static List < UserTerritoryWrapper > getUserTerritory2Association(Id accountId) {
        //List of userterritory wrapper
        List < UserTerritoryWrapper > lstUserTerritories = new List < UserTerritoryWrapper > ();
        List < String > pickListValuesList = new List < String > ();
        UserTerritoryWrapper userTerritoryWrap = null;
        //SET of TerritoryIds
        SET < Id > setTerritory2Ids = new SET < Id > ();
        //Create the Map<String, List<UserTerritory2Association>> mapRoleToUsers Where Key String = RoleInTerritory2
        Map < String, List < UserTerritory2Association >> mapUseToTerritories = new Map < String, List < UserTerritory2Association >> ();
        List < UserTerritory2Association > lstTerritories = new List < UserTerritory2Association > ();
        //validate accountid is not null
        if (accountId != null) {
            // Get the UserTerritory2Association picklist in display order
            Schema.DescribeFieldResult fieldResult = UserTerritory2Association.RoleInTerritory2.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            //Iterate all RoleInTerritory2 picklist values and store labels in list of Schema.PicklistEntry
            for (Schema.PicklistEntry pickListVal: ple) {
                // To Exclude Standard Solution Support Role from Users in Assigned Territories component : Added for DIGI-26135
                if( pickListVal.getLabel() != Label.Territory_Role_SSS){
                    pickListValuesList.add(pickListVal.getLabel());
                }
            }

            //validate pickListValuesList is not null and size is greater than zero.
            if (pickListValuesList != null && pickListValuesList.size() > 0) {
                List<Id> lstTrrIds = new List<Id>();
                lstTrrIds.add('0MI5P00000002xeWAA');
                //Fetching Territory2Id from ObjectTerritory2Association records based on accountId
                mapTerritory = new Map<ID, Territory2>([SELECT Id, DeveloperName, ParentTerritory2Id FROM Territory2 ]);
                List<ObjectTerritory2Association> lstObjTerrAssociation = [SELECT Territory2Id, Territory2.Name FROM ObjectTerritory2Association Where ObjectId =: accountId];
                String strServiceCode;
                // 21.12 SFO Added as a Part of DIGI-14600
                String strSalesCode;
                for (ObjectTerritory2Association trObj: lstObjTerrAssociation) {
                    if(setTerritory2Ids!=null){
                        if(trObj.Territory2.Name.startsWith('CSD') || trObj.Territory2.Name.startsWith('BCS')){
                            // Service Portfolio Code
                            setTerritory2Ids.add(trObj.Territory2Id);
                            strServiceCode = trObj.Territory2Id;
                        }
                        else{
                            // Sales Portfolio Code
                            setTerritory2Ids.add(trObj.Territory2Id);
                //21.12 SFO Added as a Part of DIGI-14600
                            strSalesCode = trObj.Territory2Id;
                        }
                    }
                }
                if(!string.isblank(strServiceCode)){
                    setTerritory2Ids.addAll(fetchParentTerritory(strServiceCode));
                }
                //21.12 SFO Added as a Part of DIGI-14600
                if(!string.isblank(strSalesCode)){
                    setTerritory2Ids.addAll(fetchParentTerritory(strSalesCode));
                }
                system.debug('---setTerritory2Ids---' + setTerritory2Ids);

                if(setTerritory2Ids!=null && setTerritory2Ids.size()>0){
                    //Fetching all UserTerritory2Association records based on TerritoryId
                    for (UserTerritory2Association uta: [SELECT User.Name, User.Email, toLabel(RoleInTerritory2), User.isActive, Territory2.Name
                        FROM UserTerritory2Association WHERE Territory2Id
                        IN: setTerritory2Ids Order by RoleInTerritory2 ASC
                    ]) {
                        //storing list of UserTerritory2Association records in map based on role.
                        if (mapUseToTerritories!=null && mapUseToTerritories.containsKey(uta.RoleInTerritory2))
                        {
                            lstTerritories = mapUseToTerritories.get(uta.RoleInTerritory2);
                            lstTerritories.add(uta);
                            mapUseToTerritories.put(uta.RoleInTerritory2, lstTerritories);
                        } else
                        {
                            lstTerritories = new List < UserTerritory2Association > {uta};
                            mapUseToTerritories.put(uta.RoleInTerritory2, lstTerritories);
                        }
                    }
                }
                System.debug('mapUseToTerritories::'+mapUseToTerritories);
                /*Fetching all userterritory2Association records based on Role that's defined in picklist and store in wrapper class.
                **/
                for (String rolename: pickListValuesList) {
                    //validating map contains specified role's records
                    if (mapUseToTerritories!=null && mapUseToTerritories.containsKey(rolename)) {
                        for (UserTerritory2Association uta: mapUseToTerritories.get(rolename)) {
                            userTerritoryWrap = new UserTerritoryWrapper();
                            userTerritoryWrap.userName = uta.User.Name;
                            userTerritoryWrap.userEmail = uta.User.Email;
                            userTerritoryWrap.territory2Name = uta.Territory2.Name;
                            userTerritoryWrap.isActive = uta.User.isActive;
                            userTerritoryWrap.roleInTerritory2 = uta.RoleInTerritory2;
                            //adding userTerritoryWrap in list of userTerritoryWrap
                            lstUserTerritories.add(userTerritoryWrap);
                        }
                    }
                }
                System.debug('lstUserTerritories::'+lstUserTerritories);
            }
        }
        //system.debug('----lstUserTerritories-' + lstUserTerritories);
        return lstUserTerritories;
    }

    public static List<Id> fetchParentTerritory(ID territoryId){
        system.debug('---territoryId--' + territoryId);
            String strTerritoryId;
            for(Territory2 tr :mapTerritory.values()){
                if(tr.id == territoryId ){
                    if(!string.isblank(tr.ParentTerritory2Id)){
                        lstTerritoryId.add(tr.ParentTerritory2Id);
                    }
                    strTerritoryId = tr.ParentTerritory2Id;
                }
            }
            system.debug('---lstTerritoryId--' + lstTerritoryId);
            if(string.isblank(strTerritoryId)){
                return lstTerritoryId;
            }
            return fetchParentTerritory(strTerritoryId);          
    }

    /**
     * Inner Class Name: UserTerritoryWrapper
     * Description: For storing all required field's value in a list.
     */
    public class UserTerritoryWrapper {
        //username is a variable of userterritory2association record
        @AuraEnabled
        public string userName {
            get;
            set;
        }
        //userEmail is a variable of userterritory2association record
        @AuraEnabled
        public string userEmail {
            get;
            set;
        }
        //territory2Name is a variable of userterritory2association record
        @AuraEnabled
        public string territory2Name {
            get;
            set;
        }
        //roleInTerritory2 is a variable of userterritory2association record
        @AuraEnabled
        public string roleInTerritory2 {
            get;
            set;
        }
        //isActive is a variable of userterritory2association record
        @AuraEnabled
        public Boolean isActive {
            get;
            set;
        }
    }
}