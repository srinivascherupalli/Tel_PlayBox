public without  sharing class PORuplodecontroller {
    @AuraEnabled
    public static Partner_of_Record__c checkvalue(String accountIds){
      Partner_of_Record__c   partner_list=null;
        try{
        partner_list= [select id,customer__r.APTPS_DocuSign_Restricted__c,Status__c,customer__r.APTPS_Off_Shore_Restricted__c from Partner_of_Record__c WHERE  Id= :accountIds ];
        return partner_list;    
        }
        catch(Exception e){
        System.debug('Exception in updatePartner'+e.getStackTraceString());
        }
        return partner_list;
}  
    
	@AuraEnabled
    public static boolean changestatus(String PatnerId){
      boolean statuschange =  PORUpdateStatusclass.changestatus(PatnerId);
        
      return statuschange;
    }

    

}