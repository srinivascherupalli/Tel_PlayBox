/**
 * (c) Telstra
 * Domain logic implementation for AccountContactRelation object
 * 03 Jul 2019	Amitabh Basu Original
 */ 
public class AccountContactRelationDomain extends fflib_SObjectDomain {
    public AccountContactRelationDomain(List<AccountContactRelation> sObjectList){
        super(sObjectList);
	}
    
	//The Constructor inner class allows the base class method 
	//SObjectDomain.triggerHandler to create a new instance of the domain class 
	//passing in the sObject list
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<sObject> sObjectList){
        return new AccountContactRelationDomain(sObjectList);
        }
    }
}