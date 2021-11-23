/*
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

public with sharing class SharepointAccRelatedlistController {
    @AuraEnabled
    public Account acc;
    @AuraEnabled
    public User users;
    @AuraEnabled
    public static SharepointAccRelatedlistController getAccRecord(Id AccountId){
        SharepointAccRelatedlistController s = new SharepointAccRelatedlistController();
        
        try{
			s.acc= [select id,SharePoint_Account_Folder__c,name,Fax,ownerId,Owner.Id from account where id =: AccountId];
			s.users = [select id from user where id =: userinfo.getUserId()];
			
		}catch(Exception ex){
			system.debug('Exception:::: SharepointAccRelatedlistController Class:::: getAccRecord Method'+ Ex.getMessage());
		}
		return s;
    }
    
   
    @AuraEnabled
    public static SharePointEvent__c createAccMemberSyncEvent(Id AccountId){
        SharePointUtility spu=new SharePointUtility();
        
        list<Account> accLst = new list<Account>();
        list<SharePointEvent__c> sharePointEventinsertionLst = new list<SharePointEvent__c>();
        try{
            accLst = [select id,name,cidn__c,lastmodifieddate,owner.email,owner.FederationIdentifier,owner.profileId,Customer_ID__c from account where recordtype.name = :Label.Account_RecordType_Enterprise and id =:AccountId];
            for(Account Acc : accLst){
                SharePointEvent__c speObj = spu.createSharePointEvent('SPAccountTeamMemberSync',spu.getAccountPayload(Acc));
                sharePointEventinsertionLst.add(speObj);
            }
            
            if(!sharePointEventinsertionLst.isEmpty())
                insert sharePointEventinsertionLst;
        }catch(Exception Ex){
            system.debug('Exception:::: SharepointAccRelatedlistController Class:::: createAccMemberSyncEvent Method'+ Ex.getMessage());
        }
        return sharePointEventinsertionLst.get(0);
    }
    
    @AuraEnabled
    public static SharePointEvent__c createAccRequestAccess(Id AccountId){
        SharePointUtility spu = new SharePointUtility();
        
        list<Account> accLst = new list<Account>();
        list<SharePointEvent__c> sharePointEventinsertionLst = new list<SharePointEvent__c>();
        
        user userInfo= [select id,FederationIdentifier,email from user where id =: userinfo.getUserId()];
        
        
        try{
            accLst = [select id,name,cidn__c,lastmodifieddate,owner.email,owner.FederationIdentifier,owner.profileId,Customer_ID__c from account where recordtype.name = :Label.Account_RecordType_Enterprise and id =:AccountId];
            for(Account Acc : accLst){
                SharePointEvent__c speObj = spu.createSharePointEvent('SPAccountRequestAccess',spu.getAccountMemberPayload(Acc,userInfo));
                sharePointEventinsertionLst.add(speObj);
            }
            
            if(!sharePointEventinsertionLst.isEmpty())
                insert sharePointEventinsertionLst;
        }catch(Exception Ex){
            system.debug('Exception:::: SharepointAccRelatedlistController Class:::: createAccRequestAccess Method'+ Ex.getMessage());
        }
        return sharePointEventinsertionLst.get(0);
    }
}