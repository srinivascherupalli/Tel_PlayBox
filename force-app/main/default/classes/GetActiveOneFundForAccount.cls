public class GetActiveOneFundForAccount {
    public static String getOneFundId(String AccountId){ 
        List<string> parentCidnId = new List<string>();
        List<string> uCidnId = new List<string>();
        String pCidn = null;
        String uCidn = null;
        String cCidn = null;
        String Cidn = null;
        Map<string,string> OFCidn = new  Map<string,string>();
        
        Account accountDetails = [select id,CIDN__c,Parent_CIDN__c,Ultimate_Parent_CIDN__c From Account where Id =: AccountId];                 
        
        cCidn = accountDetails.CIDN__c;
        pCidn = accountDetails.Parent_CIDN__c;
        uCidn = accountDetails.Ultimate_Parent_CIDN__c;
        
        List<OneFund__c> OFCidnList1 = [select id,CIDN__r.CIDN__c From OneFund__c where OneFund_Status__c = 'Active' AND CIDN__r.CIDN__c != null AND CIDN__r.CIDN__c =:accountDetails.CIDN__c];
        
        if(!OFCidnList1.isEmpty()){
            for(OneFund__c ofaccount : OFCidnList1){
                if(cCidn!= null && cCidn.contains(ofaccount.CIDN__r.CIDN__c)){
                    Cidn = ofaccount.Id;
                    return Cidn;
                } 
            }   
        }            
        
        
        List<OneFund__c> OFCidnList2 = [select id,CIDN__r.CIDN__c  From OneFund__c where OneFund_Status__c = 'Active' AND CIDN__r.CIDN__c != null AND CIDN__r.CIDN__c =:accountDetails.Parent_CIDN__c];
        
        if(!OFCidnList2.isEmpty()){
            for(OneFund__c ofaccount : OFCidnList2){
                if(pCidn!= null && pCidn.contains(ofaccount.CIDN__r.CIDN__c)){
                    Cidn = ofaccount.Id;
                    return Cidn;
                } 
            }   
        }
        List<OneFund__c> OFCidnList3 = [select id,CIDN__r.CIDN__c  From OneFund__c where OneFund_Status__c = 'Active' AND CIDN__r.CIDN__c != null AND CIDN__r.CIDN__c =:accountDetails.Ultimate_Parent_CIDN__c];
        
        if(!OFCidnList3.isEmpty()){
            for(OneFund__c ofaccount : OFCidnList3){
                if(uCidn!= null && uCidn.contains(ofaccount.CIDN__r.CIDN__c)){
                    Cidn = ofaccount.Id;
                    return Cidn;
                } 
            }   
        }    
        
        system.debug('returned onefund: ' +Cidn);
        return Cidn;
        
    }
    
}