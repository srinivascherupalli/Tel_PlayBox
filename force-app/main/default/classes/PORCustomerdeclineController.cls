public class PORCustomerdeclineController {
    @AuraEnabled
    public static Partner_of_Record__c checkvalue(String accountIds){
       // list<Partner_of_Record__c> partner_list =new list <Partner_of_Record__c>();
       Partner_of_Record__c   partner_list=null;
        try{
        partner_list= [select id,customer__r.APTPS_DocuSign_Restricted__c,Status__c from Partner_of_Record__c WHERE  Id= :accountIds ];
   		return partner_list;
           
        }
        catch(Exception e){
        System.debug('Exception in updatePartner'+e.getStackTraceString());
           
        }
        return partner_list;
		} 
    
    @AuraEnabled
	public static boolean customerdecline (String aIds){
      boolean changestatus = PORUpdateStatusclass.customerdecline(aIds);
      return changestatus;
    
	}

}