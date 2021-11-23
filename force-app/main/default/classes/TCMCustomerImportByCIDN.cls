/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
*/

public class TCMCustomerImportByCIDN {
    public static boolean importFlag=true;
    public Account tcmCustomer{private set; get;}
    public CustomerObject.Customer selectedCustomer{set; private get;}
    public Boolean isAccountRetired{set;get;}
    
	private TCMGetCustomerContact tcmGetContactObj = null;
    private TCMGetCustomer tcmGetCustomerObj = null;
	private TCMGetInterface getTCMInterface = null;
    
    static{
     AccountContactRelationshipTriggerHandler.importFlag=true;
	}
    
    public TCMCustomerImportByCIDN(){
    	tcmGetCustomerObj = new TCMGetCustomer();
    	tcmGetContactObj = new TCMGetCustomerContact();
        getTCMInterface = TCMGetInterface.getInstance();
        
    }
    
    public void createTCMCustomer(String cidn){
    	//tcmObjects(cidn);
    	System.debug('TCMCustomerImportByCIDN - Creating Account/cscrm__Account_Address_Relationship__c for : '  + cidn);
    	tcmCustomer = tcmGetCustomerObj.createAccountAndAddress(selectedCustomer);
        if(selectedCustomer != null && selectedCustomer.masterID != null && String.isNotBlank(selectedCustomer.masterID)){
        	System.debug('TCMCustomerImportByCIDN - Creating Contact/AccountContactRelation for : '  + selectedCustomer.masterID);
        	tcmGetContactObj.createContacts(getTCMInterface.tcmContactObject.get(selectedCustomer.masterID), tcmCustomer);
        }
    }
    
    public void tcmObjects(String cidn){
        if(selectedCustomer == null){
        	System.debug('TCMCustomerImportByCIDN - GetCustomer callout : '  + cidn);
            getTCMInterface.getCustomer(cidn);
            selectedCustomer = getTCMInterface.tcmCustomerObject.get(cidn);
            isAccountRetired = (selectedCustomer.accountStatus != null && 
             	String.isNotBlank(selectedCustomer.accountStatus) && selectedCustomer.accountStatus == 'RETIRED') ? true : false;
        }
        if(selectedCustomer != null && selectedCustomer.masterID != null && String.isNotBlank(selectedCustomer.masterID)){
        	System.debug('TCMCustomerImportByCIDN - GetCustomer callout : '  + selectedCustomer.masterID);
        	getTCMInterface.getCustomerContact(selectedCustomer.masterID);
        }
    }
   
}