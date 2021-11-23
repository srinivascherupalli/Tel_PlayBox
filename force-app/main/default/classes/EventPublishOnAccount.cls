public with sharing class EventPublishOnAccount {
        public static boolean isFutureUpdate=false;

    // Publishing Events On Account Creatrion.
        public  void eventPublishOnAccCreation(list<Account> newAcc){
		SharePointUtility spu=new SharePointUtility();
		boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointAccountCreate');
        list<Account> accLst = new list<Account>();
        list<SharePointEvent__c> sharePointEventinsertionLst = new list<SharePointEvent__c>();
        set<ID> accId = new set<ID>();
        list<Account> storageLst = new list<Account>();
       
        try{
            for(Account ac : newAcc){
                Account accStorage = new Account(id = ac.id);
                accStorage.Storage_Requested_Date__c = DateTime.now();
                storageLst.add(accStorage);
            }
			for(Account acc : newAcc){
                accId.add(acc.id);
            }
        
			accLst = [select id,name,cidn__c,lastmodifieddate,owner.email,owner.FederationIdentifier,owner.profileId,Customer_ID__c from account where recordtype.name = 'Enterprise' and id in :accId];
			
			if(!accLst.isEmpty()){
			    if(hasCustomPermissionSet){
				for(Account Acc : accLst){

                        SharePointEvent__c speObj = spu.createSharePointEvent('SPAccount',spu.getAccountPayload(Acc));
						sharePointEventinsertionLst.add(speObj);
					}
				}
			}

			if(!sharePointEventinsertionLst.isEmpty())
			    insert sharePointEventinsertionLst;
			
			if(!storageLst.isEmpty()){
			    update storageLst;
			}
        }catch(Exception Ex){
            system.debug('Exception:::: EventPublishOnAccount Class:::: eventPublishOnAccCreation Method'+ Ex.getMessage());
        }
    }
    
    //Publish Event On Account Name or Owner Change
    public void eventPublishOnAccChange(list<Account> oldAccs, map<id,Account> oldAccsMap, list<Account> newAccs, map<id,Account> newAcccsMap){
        
	SharePointUtility spu=new SharePointUtility();
    boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointAccountChange');//spu.checkUserHasCustomPermissionAccess('SharePointAccountChange',UserInfo.getUserId());
    
    list<Account> accLst = new list<Account>();
    list<SharePointEvent__c> spe = new list<SharePointEvent__C>();   
	set<ID> accId = new set<ID>();
    try{
        if(isFutureUpdate != True){
		list<SharePointEvent__c> sharePointEventAccUpdateLst = new list<SharePointEvent__c>();

    
			for(Account acc : newAccs){
                accId.add(acc.id);
            }
			accLst = [select id,name,cidn__c,lastmodifieddate,owner.email,owner.FederationIdentifier,owner.profileId,Customer_ID__c from account where recordtype.name = 'Enterprise' and id in :accId];
            
			for(Account acc : accLst){
				if(oldAccsMap.containsKey(acc.Id)){
					if((acc.Name != oldAccsMap.get(acc.Id).Name || acc.ownerId != oldAccsMap.get(acc.Id).OwnerId) && hasCustomPermissionSet == True){
						
						SharePointEvent__c speObj = spu.createSharePointEvent('SPAccount',spu.getAccountPayload(acc));
						sharePointEventAccUpdateLst.add(speObj);
					}
				}
			}
    
			if(!sharePointEventAccUpdateLst.isEmpty()){
			    
			    insert sharePointEventAccUpdateLst;
			}
            isFutureUpdate = True;
        }
		}catch(Exception ex){
			system.debug('Exception:::: EventPublishOnAccount Class:::: eventPublishOnAccUpdate Method'+ Ex.getMessage());
		}
    }
    
}