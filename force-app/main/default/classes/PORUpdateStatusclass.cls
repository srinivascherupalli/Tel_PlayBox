public without sharing  class PORUpdateStatusclass {
    @AuraEnabled
    public static boolean changestatus(String PatnerId){
        if(PatnerId!= null) {
    List<Partner_of_Record_Domain__c> upsertList = new List<Partner_of_Record_Domain__c>();
    list<Partner_of_Record__c> P_list =new list <Partner_of_Record__c>();
    P_list=[select id,Status__c,Agreement_Duration__c from Partner_of_Record__c WHERE  Id= :PatnerId];
        Partner_of_Record__c p = new Partner_of_Record__c();
        p.id=P_list[0].id;
        p.Status__c='Active';
        p.Start_Date__c=system.today();
        Date Enddate=Date.today();
        p.POR_End_Date__c=Enddate.addMonths(Integer.valueof(P_list[0].Agreement_Duration__c));
    update p;
    list<Partner_of_Record_Domain__c> P_list2 =new list <Partner_of_Record_Domain__c>();
            P_list2=[select id,Domain_Name__c ,Status__c,Sub_Status__c from Partner_of_Record_Domain__c where Partner_of_Record__c  = :PatnerId];
                for(Partner_of_Record_Domain__c list1 :P_list2){
                         
                    upsertList.add(new Partner_of_Record_Domain__c(Id=list1.Id,Status__c = 'Active'));
                                }
            if(upsertList.size()>0 && !upsertList.isEmpty()){
            upsert upsertList;
        }
                    
    return true;
    }
    return false;

}

@AuraEnabled
public static boolean customerdecline (String aIds){
    if(aIds!= null) {
    list<Partner_of_Record__c> P_list =new list <Partner_of_Record__c>();
    P_list=[select id,Status__c from Partner_of_Record__c WHERE  Id= :aIds];
    Partner_of_Record__c p = new Partner_of_Record__c();
    p.id=P_list[0].id;
    p.Status__c='Customer Declined';
    update p;
    return true;
    }
    return false;  
}

}