/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 17/Oct/2017
* @Story : EDGE-1212
* @Changes : EDGE-4090 - 14/Nov/2017
*/
public class ImportTCMCustomerByCIDN {
    
    public enum SourceFrom {SEEDING,SFDC_UI}
    private ImportTCMCustomerResult tcmCustomerResult;
    private TCMGetInterface getTCMInterface = null;
    
    public ImportTCMCustomerByCIDN(){
        tcmCustomerResult = new ImportTCMCustomerResult();
		getTCMInterface = TCMGetInterface.getInstance();
    }
    
    public ImportTCMCustomerResult importCustomerAndContactbyCIDN(String cidn, SourceFrom sourceflow) {
        Logger2 logger = Logger2.getLogger('TCMCUSTOMERSEEDING');
        try{
            CustomerObject.Customer selectedCustomer = tcmObjects(cidn);
            JSON2TCMCustomerContactObject.ErrorMessage errorMessage = getTCMInterface.tcmCustomerError.get(cidn);
            if(errorMessage == null){
                Account tcmCustomer = createCustomer(selectedCustomer);
                if(selectedCustomer != null && selectedCustomer.masterID != null && tcmCustomer != null
                   && tcmCustomer.Id != null && String.isNotBlank(tcmCustomer.Id)
                   && !tcmCustomerResult.errorCode.equals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE)){
                       errorMessage = getTCMInterface.tcmCustomerError.get(selectedCustomer.masterID);
                       if(errorMessage == null){
                           createContact(selectedCustomer,tcmCustomer);
                       } else {
                           tcmCustomerResult.errorDescription= errorMessage.message+ ' ' + errorMessage.code;
                           tcmCustomerResult.errorCode= TCMCustomerContactConstants.TCMERRORCODE_FAILURE;
                       }
                   } 
            } else {
                tcmCustomerResult.errorDescription= errorMessage.message+ ' ' + errorMessage.code;
                tcmCustomerResult.errorCode= TCMCustomerContactConstants.TCMERRORCODE_FAILURE;
            }
        } catch(TCMException.TCMCallOutException tcmException){
            tcmCustomerResult.errorDescription= tcmException.getMessage();
            tcmCustomerResult.errorCode= TCMCustomerContactConstants.TCMERRORCODE_FAILURE;
        } catch(Exception ex){
			tcmCustomerResult.errorDescription= ex.getMessage();
            tcmCustomerResult.errorCode= TCMCustomerContactConstants.TCMERRORCODE_FAILURE;
		}finally {
            for(String keys : getTCMInterface.callOutDataCapture.keyset()){
                TCMGetInterface.TCMRequestResponseCapture reqResCapture = getTCMInterface.callOutDataCapture.get(keys);
                logger.logMessages(reqResCapture.url, reqResCapture.httpResponse.getBody(), '', '', '', '', false, false);
            }
        }
        return tcmCustomerResult;
    }
    
    public CustomerObject.Customer tcmObjects(String cidn){
        getTCMInterface.getCustomer(cidn);
        CustomerObject.Customer selectedCustomer = null;
        if(getTCMInterface.tcmCustomerError.get(cidn) == null){
            selectedCustomer = getTCMInterface.tcmCustomerObject.get(cidn);
            if(selectedCustomer != null && selectedCustomer.masterID != null && String.isNotBlank(selectedCustomer.masterID)){
                System.debug('masterId : ' + selectedCustomer.masterID);
                getTCMInterface.getCustomerContact(selectedCustomer.masterID);
            }
        }
        return selectedCustomer;
    }
    
    private Account createCustomer(CustomerObject.Customer selectedCustomer){
        TCMGetCustomer tcmGetCustomerObj = null;
        Savepoint sp = Database.setSavepoint();
        Account tcmCustomer = null;
        try{
            tcmGetCustomerObj = new TCMGetCustomer();
            tcmCustomer = tcmGetCustomerObj.createAccountAndAddress(selectedCustomer);
            tcmCustomerResult.errorDescription = 'Customer and Customer Address imported successfully';
            tcmCustomerResult.errorCode = TCMCustomerContactConstants.TCMERRORCODE_SUCCESS;
        } catch(TCMException.TCMCustomerCreationException tcmException){
            Database.rollback(sp);
			TCMBusinessErrorCode.getInstance().logCustomerExcepction(selectedCustomer.cidn,'TCMCUSTOMERSEEDING',tcmException);
            tcmCustomerResult.errorDescription= tcmException.getMessage();
            tcmCustomerResult.errorCode= TCMCustomerContactConstants.TCMERRORCODE_FAILURE;
        }
        return tcmCustomer;
    }
    
    private void createContact(CustomerObject.Customer selectedCustomer, Account tcmCustomer){
        TCMGetCustomerContact tcmGetContactObj = null;
        Savepoint sp = Database.setSavepoint();
        try{
            tcmGetContactObj = new TCMGetCustomerContact();
            tcmGetContactObj.createContacts(getTCMInterface.tcmContactObject.get(selectedCustomer.masterID), tcmCustomer);
            tcmCustomerResult.errorDescription = 'Customer, Customer Address and Customer Contact imported successfully';
            tcmCustomerResult.errorCode = TCMCustomerContactConstants.TCMERRORCODE_SUCCESS;
            if(tcmGetContactObj.contactUUIDs != null && !tcmGetContactObj.contactUUIDs.isEmpty()){
                System.enqueueJob(new TCMContactHandlerQueueable(tcmGetContactObj.contactUUIDs));    
            }
        } catch(TCMException.TCMContactCreationException tcmException){
            Database.rollback(sp);
			TCMBusinessErrorCode.getInstance().logCustomerExcepction(selectedCustomer.cidn,'TCMCUSTOMERSEEDING',tcmException);     
            tcmCustomerResult.errorDescription= tcmException.getMessage();
            tcmCustomerResult.errorCode= TCMCustomerContactConstants.TCMERRORCODE_FAILURE;
        }
    }
    
}