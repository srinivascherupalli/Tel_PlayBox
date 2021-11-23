public without sharing class QueueableRmngLicenseonAccount implements Queueable  {
    
    set<id> sAccountId;
    List<AccountShare> lstShare;
    map<String,string> ContactupdateMap;

    
    public QueueableRmngLicenseonAccount(set<id> sAccountId,List<AccountShare> lstShare,map<string,string> ContactupdateMap) {
            this.sAccountId = sAccountId;
            if(lstShare != null && !lstShare.isEmpty())
            	this.lstShare = lstShare;
        
        	if(ContactupdateMap!=null)
        		this.ContactupdateMap=ContactupdateMap;
        }
    
    public void execute(QueueableContext context) {

        if(!sAccountId.isEmpty())
            UserTriggerHelperPRM.UpdateLicenses(sAccountId);
        
        if(lstShare != null && !lstShare.isEmpty())
            upsert lstShare;
        
        if(ContactupdateMap!=null){
           	 system.debug('ContactupdateMap'+ContactupdateMap);
               UserTriggerHelperPRM.futureUpdates(ContactupdateMap);
            }

        }
}