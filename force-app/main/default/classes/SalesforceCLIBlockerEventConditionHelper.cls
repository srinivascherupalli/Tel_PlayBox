/*
Developer Name : Manish Dundelu
Team : Tokyo
Date : 3/10/2019 
Feature : Transaction Security policy for Salesforce CLI access.
*/
public class SalesforceCLIBlockerEventConditionHelper {
    
    Set<String> setPermissionSetName = new Set<String>();
    public Boolean evaluate(String userAgent, User u )
    {
        //System.debug('Entered Helper!');
        if(userAgent.equalsIgnoreCase('sfdx toolbelt'))    //enforces this policy to work only for salesforce cli, for all others eg, workbench the execution will not be affected.
        {
            //System.debug('userAgent.equalsIgnoreCase(sfdx toolbelt)! --- '+u.PermissionSetAssignments);
            if(!u.PermissionSetAssignments.isEmpty())
            {
                for(PermissionSetAssignment permission : u.PermissionSetAssignments)
                {
                    //system.debug(permission.PermissionSet.name);
                    setPermissionSetName.add(permission.PermissionSet.name); // fetching and adding the permission sets for the user to the list 
                }
                
                if ( ( setPermissionSetName.contains('Salesforce_DX') && setPermissionSetName.contains('SFDX_Packaging') ) || setPermissionSetName.contains('Salesforce_CLI_Permission')  ) 
                {
                    System.debug('Condition met ! Permission sets assigned -- setPermissionSetName -- '+setPermissionSetName);
                    return false;
                }
                else 
                {
                    System.debug('Condition not met ! Permission sets not assigned -- setPermissionSetName -- '+setPermissionSetName);
                    return true;
                }
            }
            else
            {
                return true;
            }
            
        }
        return false;
    }
    
}