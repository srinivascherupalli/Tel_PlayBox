public with sharing class AccountValidateABNController {

    private Account acct;
    public boolean isError {get;set;}

    public AccountValidateABNController(ApexPages.StandardController controller) {
        this.acct = (Account)controller.getRecord();
    }

    public void callout() {
        ABNService abnService = new ABNService();
        isError = abnService.callout(this.acct);
    }
    
}