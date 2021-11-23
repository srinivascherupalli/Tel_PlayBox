/**
* Description : Apex Action to be invoked from flows. This apex class will execute the batch for stamping secondary numbers.                   
* Jira        : P2OB - 11651
* Author      : Team Hawaii : Ritika Jaiswal
* Date        : 1-Feb-2021 
**/
public without sharing class PRM_PPV_Invocable_For_ExecuteBatch {
    
    //P2OB-11651 : Invocable method to start thePRMPrePortVerificationBatch execution from flow 
    @InvocableMethod(label='Execute the specified batch class' description='This method will be execute a PRMPrePortVerificationBatch-class from process-builder/flow.')
    public static void executeBatchMethod(List<FlowInputParameter> flowInputs) {
        /*
        //P2OB-11651 : Creating the class-instance at runtime using input-parameter
        Type tClass = Type.forName(flowInputs[0].batchClass_to_execute);
        Database.Batchable<sObject> batchClass = (Database.Batchable<sObject>)tClass.newInstance();
        */
        for(FlowInputParameter fip:flowInputs){
        //P2OB-11651 : Executing batch class and setting the batch-size
            Database.executeBatch(new PRMPrePortVerificationBatch(fip.reference_recordID), fip.batch_size);
        }
    }
    
    /*P2OB-11651 : Wrapper class to pass input-paramters from flow to apex-action 
    */
    public Class FlowInputParameter{        
        //@InvocableVariable
        //public String batchClass_to_execute;
        @InvocableVariable
        public Integer batch_size;
        @InvocableVariable
        public String reference_recordID;
    }
}