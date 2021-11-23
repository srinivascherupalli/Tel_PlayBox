@istest
public class CustomMetadataCallbackTest{ 
  @IsTest   
   static void testMyCallback() {
        
        // Instantiate the callback.
        Metadata.DeployCallback callback = new CustomMetadataCallback ();
       
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        
        // Invoke the callback's handleResult method.
        callback.handleResult(result, context);
         system.assertEquals(result.numberComponentErrors, 1); 
    }
    }