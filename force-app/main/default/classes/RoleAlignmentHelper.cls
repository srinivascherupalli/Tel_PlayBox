/*
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

public with sharing class RoleAlignmentHelper {
	
    public static boolean recursivecheck = False;
	public void RoleAligmentLV6NameUniquenessCheck(list<Role_Alignment__c> roleAlgnmtList){
		set<ID> roleAlgnmentSet = new set<ID>();
		
		try{
		    
			if(!recursivecheck){
			    
				for(Role_Alignment__c rolealgnment : roleAlgnmtList){
					if(rolealgnment.LV6_Name__c != null){
						roleAlgnmentSet.add(rolealgnment.LV6_Name__c);
					}
				}
			
				if(!roleAlgnmentSet.isEmpty() && roleAlgnmentSet.size() > 0 && roleAlgnmentSet != null){
					
					list<Role_Alignment__c> rolealgnmentList = new list<Role_Alignment__c>();
					map<id,Role_Alignment__c> RoleAlgnmentMap = new map<id,Role_Alignment__c>();	
						
					rolealgnmentList = [select id,LV6_Name__c from Role_Alignment__c where LV6_Name__c in :roleAlgnmentSet];
					
					if(!rolealgnmentList.isEmpty()){
						for(Role_Alignment__c ralgnmet : rolealgnmentList){
							RoleAlgnmentMap.put(ralgnmet.LV6_Name__c,ralgnmet);
						}
						for(Role_Alignment__c rolealgnment1 : roleAlgnmtList){
							if(RoleAlgnmentMap.containsKey(rolealgnment1.LV6_Name__c)){
								rolealgnment1.addError(Label.RoleAlignemtLV6Name_Unique);
							}
						}
					}
				}
				if(!test.isrunningTest()){
				    recursivecheck = True;
				}
				
			}
		    
		}catch(Exception Ex){
			system.debug('Exception:::: RoleAlignmentHelper Class:::: RoleAligmentLV6NameUniquenessCheck Method'+ Ex.getMessage());
		}
	}
	
	
	/*LV6 Uniquness Check on Role Alignment Record Update*/
	
	public void RoleAligmentLV6NameUniquenessCheckOnUpdate(list<Role_Alignment__c> oldRoleAlgnmnt, map<id,Role_Alignment__c> oldRoleAlgnmntMap, list<Role_Alignment__c> roleAlgnmtList, map<id,Role_Alignment__c> newRoleAlgnmetMap){
		set<ID> roleAlgnmentSet = new set<ID>();
		system.debug(roleAlgnmtList);
		try{
			if(!recursivecheck){
			    
				for(Role_Alignment__c rolealgnment : roleAlgnmtList){
					if(rolealgnment.LV6_Name__c != null && rolealgnment.LV6_Name__c!= oldRoleAlgnmntMap.get(rolealgnment.id).LV6_Name__c){
						roleAlgnmentSet.add(rolealgnment.LV6_Name__c);
					}
				}
				
			
				if(!roleAlgnmentSet.isEmpty() && roleAlgnmentSet.size() > 0 && roleAlgnmentSet != null){
					
					list<Role_Alignment__c> rolealgnmentList = new list<Role_Alignment__c>();
					map<id,Role_Alignment__c> RoleAlgnmentMap = new map<id,Role_Alignment__c>();	
						
					rolealgnmentList = [select id,LV6_Name__c from Role_Alignment__c where LV6_Name__c in :roleAlgnmentSet];
					
					if(!rolealgnmentList.isEmpty()){
						for(Role_Alignment__c ralgnmet : rolealgnmentList){
							RoleAlgnmentMap.put(ralgnmet.LV6_Name__c,ralgnmet);
						}
						for(Role_Alignment__c rolealgnment1 : roleAlgnmtList){
							if(RoleAlgnmentMap.containsKey(rolealgnment1.LV6_Name__c)){
								rolealgnment1.addError(Label.RoleAlignemtLV6Name_Unique);
							}
						}
					}
				}
				if(!test.isRunningTest()){
				    recursivecheck = True;
				}
			}
		    
		}catch(Exception Ex){
			system.debug('Exception:::: RoleAlignmentHelper Class:::: RoleAligmentLV6NameUniquenessCheckOnUpdate Method'+ Ex.getMessage());
		}
	}
}