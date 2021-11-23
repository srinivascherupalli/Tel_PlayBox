public with sharing class ImportTCMCustomerResult { 
	   
	public enum error { Error1, Error2 }
  	public String errorType {get;set;}
    public String errorDescription {get;set;}
    public String errorCode {get;set;}
    
    public ImportTCMCustomerResult() {
        errorDescription='';
        errorCode='';               
    }    
}