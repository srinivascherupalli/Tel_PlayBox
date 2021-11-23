/*********************************************************************************************************************************
 *Class Name      :   parallelChangeValidationResponse
Test Class : CoBAProcessHelperTest
Ch.No.    Developer Name          Date          Story Description
1.         Gokul                21/04/2021      EDGE-210200 - Using this wrapper class in CoBA parallel change validation      
*********************************************************************************************************************************
*/
public with sharing class parallelChangeValidationResponse {
    
    public string BasketName;
    public string BasketOwnerName;
    public string BasketOwnerEmailId;
    public boolean ChangeAllowed;
    public string ErrorMessage;
    
    public static void doNothing() {
        
    }
    
}