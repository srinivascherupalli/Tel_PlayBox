/**
 * (c) Telstra
 * Manages service operations related to BillingAccount
 * 03 Jul 2019  Amitabh Basu Original
 */ 
public class BillingAccountService {

    /**
     * Returns a list of AccountContactRelations records 
     * @param searchKey String
     * @param accountId String
     * @param secondaryConList List
     * @param isAllCon Boolean
     * @return List of AccountContactRelation
     */ 
    public static List<AccountContactRelation> fetchAccountOperation(String searchKey, 
        String accountId, List<AccountContactRelation> secondaryConList, Boolean isAllCon){
                                                                         
        List<id> secondaryConListId = new List<id>();
        for(AccountContactRelation acrChild: secondaryConList) {
            secondaryConListId.add(acrChild.id);
        }
                                                                
       List<Id> allParentIds = new List<Id>();
       List<AccountContactRelation> lstOfAccountContactRel = new List<AccountContactRelation>();
            
       if(accountId != null){
       		allParentIds.add(accountId);
       }
       if(! isAllCon){
           allParentIds = getParentIds(allParentIds, accountId);
        }
            
       if (searchKey == '%') {
           lstOfAccountContactRel = AccountContactRelationSelector.getAccountContactRelation(
                   										allParentIds, secondaryConListId);
           System.debug('lstOfAccountContactRel' +lstOfAccountContactRel);
      }else{                                
          	//searchKey = '%' + searchKey;
       	   	lstOfAccountContactRel = AccountContactRelationSelector.getAccountContactRelation(
                   								allParentIds, secondaryConListId, searchKey);
          
      }
       return lstOfAccountContactRel;                                                                  
    }
    
     /**
     * Returns a list of Account Parent IDs 
     * @param allParentIds List
     * @param accountId String
     * @return List of Id
     */ 
    private static List<Id> getParentIds(List<Id> allParentIds, String accountId){
        
        Set<Id> Ids = new Set<Id>{Id.valueOf(accountId)};
        List<Account> accounts = new AccountsSelector().selectById(Ids);
        Map<String, Object> treeData = new AccountDomain(accounts).getAllParentIds();
           
        //Store all parentIds
        if(treeData.ContainsKey('data')){
        	List<Object> hierarchyData = (List<Object>)treeData.get('data');
            for(Object obj : hierarchyData){
            	if(obj instanceof ObjectHierarchy_Utility.ObjectWrapper){
                	ObjectHierarchy_Utility.ObjectWrapper objWrapper = (ObjectHierarchy_Utility.ObjectWrapper)obj;
                    
                    //If the Account record has parent value null it is substituted by value # in algo in getHierarchyData()
                    //in that case if allParentIds list is not populated with account id that is passed in param then substitute
                    //parent id with account id that is wrapped in ObjectWrapper
                    if(objWrapper.parent == '#'){
                        System.debug('allParentIds.size()' +allParentIds.size());
                        if(allParentIds.size() < 0){
                    		allParentIds.add(objWrapper.id);
                        }else{
                            //Do nothing
                        }
                    }else{
                        allParentIds.add(objWrapper.parent);
                    }
                }
            }
               
        }else{
        	//TODO: Report back error in the treeData collection
        }
        return allParentIds;
    }
}