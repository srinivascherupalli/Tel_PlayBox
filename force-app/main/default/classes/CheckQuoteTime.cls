public with sharing class CheckQuoteTime {
//Returns status of Quote pdf generation    
@auraenabled
    public static String displayError(string recordId){
    	Quote quo;
        try{
        System.debug('recordId'+recordId);
        quo=[select createddate,Conga_Request_Time__c,Conga_Status__c from Quote where id=:recordId];
        System.debug('quo'+quo);
        list<Quotedocument> quoteDoc=[select id from quotedocument where quoteid=:recordId];
        System.debug(quo.createddate<=system.now());
		System.debug(system.today()+' today '+quo.CreatedDate.Hour()+'<='+system.now().hour());      
        System.debug((quo.CreatedDate.Date()<=system.today()) +' here '+ (quo.CreatedDate.Hour()<=system.now().hour()));
        if(!quoteDoc.isEmpty()){
            return 'Success';        
        }
        else if(quo.Conga_Request_Time__c.Date()<=system.today() && quo.Conga_Status__c !='Success'){
            DateTime myDateTime = quo.Conga_Request_Time__c.addMinutes(15); 
            System.debug(quo.createddate);
            System.debug('myDateTime'+myDateTime);
            System.debug('system.now()'+system.now());
            System.debug(myDateTime>system.now());            
            if(myDateTime>system.now())
            	return 'InProgress';              
        }
        }catch(QueryException e){
            System.debug(e.getMessage());
            Logger.getLogger(CheckQuoteTime.class).debug(e);
            Logger.exitLogger();
        }catch(Exception e){
            System.debug(e.getMessage());
            Logger.getLogger(CheckQuoteTime.class).debug(e);
            Logger.exitLogger();
        }
        if(quo!=null){
        	quo.Conga_Status__c = 'Error';
        	upsert quo;
        }
        return 'Failure';
    }
    
     @AuraEnabled
    public static boolean userInfoPRM(){
        boolean isPRMuser = false;
        Profile p = [select id,Name from Profile where id=:Userinfo.getProfileid()];
        if(p.Name  == 'PRM Admin - Australia' || p.Name  == 'PRM Community User - Australia')
            isPRMuser = true;  
        return isPRMuser;                              
    }
    
     @AuraEnabled
    public static boolean getNotificationMsgOnStatus(){
        boolean isPRMuser = false;
        Profile p = [select id,Name from Profile where id=:Userinfo.getProfileid()];
        if(p.Name  == 'PRM Admin - Australia' || p.Name  == 'PRM Community User - Australia')
            isPRMuser = true;  
        return isPRMuser;                              
    }
    
    @AuraEnabled
    public static quote getQuoteStatus(string recordId){
        Quote quo=[select status from Quote where id=:recordId];
        return quo;                              
    }
}