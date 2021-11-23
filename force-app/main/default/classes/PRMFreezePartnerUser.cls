public with sharing class PRMFreezePartnerUser {
    @invocableMethod
    public static void freezeUsers(list<id> setContactIds){
        System.debug('In PRMFreezePartnerUser freeze method');
        System.debug('freezeuserids size:' + setContactIds.size());
        updateUser(setContactIds, true);  
    }
    public static void unfreezeUsers(list<id> setContactIds){
        System.debug('In PRMFreezePartnerUser unfreeze method');
        System.debug('unfreezeuserids size:' + setContactIds.size()); 
        updateUser(setContactIds, false);     
    } 
    public static void updateUser(list<id> setContactIds, Boolean userStatus){
    System.debug('In updateUser method');
    System.debug('setContactIds size:' + setContactIds.size());
     list<UserLogin> userList=new list<UserLogin>();
       for(UserLogin Ul:[select id,isFrozen 
                          from UserLogin 
                          where userid IN (select id from user where contactid IN:setContactIds)]){
                              Ul.isFrozen=userStatus;
                              userList.add(Ul);
                          }
        if(userList.size()>0)
            update userList;
            System.debug('userList' + userList);
    } 
    /* @invocableMethod
public static void freezeActiveUser(list<id> ids){
System.debug('In PRMFreezePartnerUser freeze method');
System.debug('freezeuserids size:' + ids.size());
list<id> accountIds=new list<id>();
list<id> contactIds=new list<id>();
list<UserLogin> userList=new list<UserLogin>();

for(account acc:[select id,(select id from contacts) 
from account 
where id IN:ids]){
for(contact con:acc.contacts){
contactIds.add(con.id);    
}   
}

for(UserLogin Ul:[select id,isFrozen 
from UserLogin 
where userid IN (select id from user where contactid IN:contactIds)]){
Ul.isFrozen=true;
userList.add(Ul);
}

if(userList.size()>0)
update userList;
}

public static void unFreezeActiveUser(list<id> ids){ //added by saran
System.debug('In PRMFreezePartnerUser unfreeze method');
System.debug('unfreezeuserids size:' + ids.size());
list<id> accountIds=new list<id>();
list<id> contactIds=new list<id>();
list<UserLogin> userList=new list<UserLogin>();

for(account acc:[select id,(select id from contacts) from account where id IN:ids]){
for(contact con:acc.contacts){
contactIds.add(con.id);    
} 
system.debug('list of acc ids and con ids' + contactIds);
}

for(UserLogin Ul:[select id,isFrozen from UserLogin where userid IN (select id from user where contactid IN:contactIds)]){
Ul.isFrozen=false;
userList.add(Ul);
}
system.debug('list of user ids' + userList);
if(userList.size()>0)
update userList;
system.debug('PRM freeze or unfreeze list' + userList);
} */   
}