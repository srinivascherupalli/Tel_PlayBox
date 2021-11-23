/**
 * (c) Telstra
 * Encapsulates the logic for querying Account object 
 * 04 Jul 2019	Amitabh Basu Original
 */ 
public class AccountsSelector extends fflib_SObjectSelector{
	/**
	 * Initializes the fields to return
	 */ 
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            Account.Id,
            Account.ParentId
        };
    }
    
    /**
     * Returns the Account object type
     * @return sObjectType
     */ 
    public Schema.SObjectType getSObjectType(){
        return Account.sObjectType;
    }
    
    /**
     * Returns List of Acccount records identified by set of Ids
     * @param Id Set
     * @returns Account List
     */ 
    public List<Account> selectById(Set<Id> Id){
        return (List<Account>) selectSObjectsById(Id);
    }
}