/*****************************************************************************
@Author: Karan Jugtawat
@CreateDate: 25/08/2020
@Description: This Class will be used to call assignment rule while creating case recrods from Flows Make sure salesup_Routing_Enabled__c field is set to "true"
@ModifiedByandDate:
@NOTE : To handel the DML errors the method processCaseCreation returns the error which is concatinated with the string "Error :- "
you can check if the output string begins with "Error :- " then it is an error else it will be the ID of the newly created record.
*******************************************************************************/
Public With Sharing Class CaseAssignmentRuleHandler{
    //This method will be used to call assignment rule while creating recrods from Flows
    @InvocableMethod
    public static List<String> processCaseCreation(List<case> lstCase){
        //List of string to Return
        List<String> LstStr = new List<String>();
        
        // checking caseList for Null or Empty
        if(lstCase==null || lstCase.size()==0 ){
            LstStr.add('Error :- Case List is Null or Empty');
            return LstStr;
        }
        
        //Creating DML Option record and setting the Default Assignment rule while Record creation only if salesup_Routing_Enabled__c is true on case
        if(lstCase.get(0).salesup_Routing_Enabled__c == true){
            Database.DMLOptions dmloptsCaseAssignmentRule = new Database.DMLOptions();
            dmloptsCaseAssignmentRule.assignmentRuleHeader.useDefaultRule = true;
        
            lstCase.get(0).setOptions(dmloptsCaseAssignmentRule);
        }
        
        //Getting all the Field Name and their data type on Case Object
        Map<String, Schema.SobjectField> fieldMap = Case.sObjectType.getDescribe().fields.getMap();
        
        //Getting all the Field Name and their Value of Case record provided to this method
        Map<String,Object> fieldToValue = lstCase.get(0).getPopulatedFieldsAsMap();
        
        //Iterating each field to check for Picklist or Milti-Picklist field
        for (String fieldName : fieldToValue.keySet()){
            String datatype = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());
            
            //skip the iteration if the Field is not Picklist or Multipicklist, if Picklist or Multipicklist check for null.
            if( (datatype !='Picklist' && datatype !='Multipicklist') || fieldToValue.get(fieldName) == null){
                continue;
            }
            
            //get the field value(data)
            String data = String.valueOf(fieldToValue.get(fieldName));
            //remove the '[' , ']' from the field value(data) 
            data= data.removeStart('[').removeEnd(']');
            lstCase.get(0).put(fieldname,data);
        }
        Database.SaveResult SR = Database.insert(lstCase.get(0),false); 
        
        if (SR.isSuccess()){
            LstStr.add(SR.getId());
            return LstStr;
        }
        else{
            Database.Error err= SR.getErrors().get(0);
            LstStr.add('Error :- '+ err.getStatusCode() +' - ' + err.getMessage());
            return LstStr;
        } 
    }
}