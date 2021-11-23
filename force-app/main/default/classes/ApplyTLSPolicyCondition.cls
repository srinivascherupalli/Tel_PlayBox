global without sharing class ApplyTLSPolicyCondition implements TxnSecurity.PolicyCondition {
    //This method is to trigger the policy when a user who is not a system administrator tries to login from a TLS '1.1'
    public boolean evaluate(TxnSecurity.Event loginEvent) {
        try  {
            if (loginEvent.action == 'Login' && loginEvent.data.get('LoginHistoryId') != null) {    
                List<LoginHistory> eObj = [Select TlsProtocol,UserId FROM LoginHistory WHERE Id = :loginEvent.data.get('LoginHistoryId')];
                if ( !eObj.isEmpty() && eObj.size() > 0 ){
                    //LoginHistory instance contains the information regarding user who is trying to login, so we are trying to capture that user Id.
                    Id userid= eObj[0].UserId;
                    system.debug('eObj[0].TlsProtocol' + eObj[0].TlsProtocol);
                    //To retrieve the profile of the user logging in
                    List<User> userList = [Select Id ,Profile.Name , ProfileId, Email  from User where Id=:userid];
                    Set<String> profileNameSet = new Set<String>();
 
                    for(User user : userList ) {
                        profileNameSet.add(user.Profile.Name);               
                    } 
                    //If profile is not of System Administrator and user is logging in with a TLS 1.1, we trigger this policy, or else do not trigger it.          
                    if(!profileNameSet.isEmpty() && !profileNameSet.contains('System Administrator') ) { /// here change the id current org id       
                        if (eObj[0].TlsProtocol == 'TLS 1.1') {
                            return true;
                        } 
                        else{
                            return false;
                        }
                    }
                }
            }
        }
        
        catch(Exception ex) {
           system.debug('Exception thrown, invalid transaction' + ex.getTypeName() );
           system.debug('Exception message' +ex.getMessage() );
           return true;
        }                
        return false;
    }
}