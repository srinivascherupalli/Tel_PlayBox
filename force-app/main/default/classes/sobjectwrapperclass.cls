public class sobjectwrapperclass implements Comparable{
    
    @AuraEnabled
    public String Id {get;set;}
    @AuraEnabled
    public String Contact_Name {get;set;}
    @AuraEnabled
    public String Contact_Email {get;set;}
    @AuraEnabled
    public String ContactId {get;set;}
    @AuraEnabled
    public String Roles {get;set;}
    @AuraEnabled
    public Datetime createdDateFCR {get;set;}
    
    // Constructor
    public sobjectwrapperclass(String i, String CN, String CE, String CI,String Role, Datetime cdFCR) {
        id = i;
        Contact_Name = CN;
        Contact_Email = CE;
        ContactId = CI;
        Roles = Role;
        createdDateFCR = cdFCR;       
    }
    // Implement the compareTo() method
    public Integer compareTo(Object objToCompare) {
		sobjectwrapperclass that = (sobjectwrapperclass) objToCompare;
        if (createdDateFCR < that.createdDateFCR) return 1;
        else if(createdDateFCR > that.createdDateFCR) return -1;   
        else return 0;
    }
}