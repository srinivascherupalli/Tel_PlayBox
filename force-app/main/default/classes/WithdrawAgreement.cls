/* EDGE-216035 : As a Partner, I want the ability to Withdraw an inflight POR
    B2B-1677 :Team Alexandria 
    @createdBy    - Yogesh Chavan
*/
public  without sharing class  WithdrawAgreement {
    static Integer count;
    @AuraEnabled
    public static Partner_of_Record__c checkstatus(String accountIds){
         
        Partner_of_Record__c  partner_list1;
        try{
            if(accountIds != null){
                Partner_of_Record__c  partner_list;
       			partner_list =[select id, status__c from Partner_of_Record__c where Id= :accountIds];
            return partner_list;
            }
        }
        catch (Exception e){
            
            System.debug('Exception in : '+e.getStackTraceString());
        }
        return partner_list1;
    }
    @AuraEnabled
    public static boolean changestatus (String accountIds,String Reson ){
        Boolean statuschange;
        List<Partner_of_Record_Domain__c> upsertList = new List<Partner_of_Record_Domain__c>();
       
        if(accountIds != null) {
            if(Approval.isLocked(accountIds)){
        Approval.unlock(accountIds);
            }
        list<Partner_of_Record__c> P_list =new list <Partner_of_Record__c>();
        
        P_list=[select id,Status__c,Withdraw_Reason__c from Partner_of_Record__c WHERE  Id= :accountIds];
           
        
        Partner_of_Record__c p = new Partner_of_Record__c();
        p.id=P_list[0].id;
        p.Status__c='Withdraw';
        p.Withdraw_Reason__c= Reson;
        update p;
        list<Partner_of_Record_Domain__c> P_list1 =new list <Partner_of_Record_Domain__c>();
        
        P_list1=[select id,	Domain_Name__c ,Status__c from Partner_of_Record_Domain__c where Partner_of_Record__c  = :accountIds];
		for(Partner_of_Record_Domain__c list1 :P_list1){
   		        statuschange =     WithdrawAgreementHelper.changeStatusvalue(list1.id,'Withdraw');
            

 			}
           
        return statuschange;
        }
        
       
        return false;
    
    }
     @auraenabled
    public Static boolean changetoPreviousValue (String accountIds){
        Boolean statuschange;
        List<Partner_of_Record_Domain__c> upsertList1 = new List<Partner_of_Record_Domain__c>();
        
        try{
        if(accountIds != null) {
        if(Approval.isLocked(accountIds)){
        Approval.unlock(accountIds);
            }
        list<Partner_of_Record__History > P_list =new list <Partner_of_Record__History >();
        P_list=[Select ParentId,Field,CreatedById ,OldValue,NewValue From Partner_of_Record__History   
                 Where Field ='status__c'and ParentId= :accountIds ORDER BY CreatedDate DESC Limit 1];
            Partner_of_Record__c p = new Partner_of_Record__c();
            if(!P_list.isEmpty() ){
        p.id=P_list[0].ParentId;
        p.Status__c=String.valueof(P_list[0].OldValue);
        update p;
            }
            
                 list<Partner_of_Record_Domain__c> P_list2 =new list <Partner_of_Record_Domain__c>();
             P_list2=[select id,	Domain_Name__c ,Status__c,Sub_Status__c from Partner_of_Record_Domain__c where Partner_of_Record__c  = :accountIds];
		for(Partner_of_Record_Domain__c list1 :P_list2)
        	{
                if( list1.Status__c == 'Pending Approval' || list1.Status__c == 'Partner Review' ||list1.Status__c == 'Customer Review' ){
                   statuschange= WithdrawAgreementHelper.changeStatusvalue(list1.id,'Withdraw');
                   
                }
                if( (list1.Status__c == 'Cancelled' && !(list1.Sub_Status__c =='Point of no return')) ||(list1.Status__c == 'Active' && list1.Sub_Status__c =='In Review - Cancellation') )
                   {
                      statuschange=  WithdrawAgreementHelper.changeStatusvalue(list1.id,'Active');
                             }
                if(list1.status__c=='Pending Approval' || (list1.Status__c == 'Active' && list1.Sub_Status__c =='In Review - Cancellation') ){
                    
                     if(count == null) {
             List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: accountIds];
        			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        			req.setAction('Removed');       
        			req.setWorkitemId(piwi.get(0).Id);
            		Approval.process(req,false);
                    }  
					count++ ;
                
                }
 			}
           
             
 return  statuschange;
        }
        }
        catch (Exception e){
            
            System.debug('Exception in : '+e.getStackTraceString());
        }
       return false;  
    }
}