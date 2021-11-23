/* **************************************************************************
EDGE        -88306
component   -paymentsController
Description -JS Controller for payment component
Author      -Dheeraj Bhatt
//22-Feb-2021 Ravi Shankar added EDGE-194644 changes PaymentType
//20-May-2021 Kamlsh Kumar added EDGE-212793 changes Telstra Id from text to button
//03-Jun-2021 Pooja Bhat added EDGE-215989 changes to Dormant Payment related changes
**********************************************************************************/
({
    doInit : function(component, event, helper) {
        helper.checkDormance(component); //Added:EDGE-215989
        helper.setDefaultDate(component, event, helper);
        helper.init(component, event, helper);
    },
    // validation check and calling serach method for getting the payments
    searchPayments:function(component, event, helper){
        var from_cmp = component.find('from_field');
        var from_date = from_cmp.get("v.value");
        var to_Cmp = component.find('to_field');
        var to_date = to_Cmp.get("v.value");
        var today = component.get("v.todayDate");
        if(from_date != null && to_date == null){
            component.set("v.errorMessage",$A.get("$Label.c.To_Date_Required"));
            component.set("v.IsError",true);
        }
        else if(from_date == null && to_date != null){
            component.set("v.errorMessage",$A.get("$Label.c.From_Date_Required"));
            component.set("v.IsError",true); 
        }
        else if(to_date < from_date){
                component.set("v.errorMessage",$A.get("$Label.c.To_Date_Greater_Equal_To_From_Date"));
                component.set("v.IsError",true);  
            }
        else if(to_date > today || from_date > today){
            component.set("v.errorMessage",$A.get("$Label.c.Select_Past_Date_For_From_Date_And_To_Date"));
                    component.set("v.IsError",true);   
                }
        else {
                helper.searchPayments(component, event, helper);
                 }
        
    },
    // setting the column name and direction for sorting data table column
        handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    },
    
    /*
     * @Created By : Kamlesh Kumar
     * @Created Date : 20-May-2021
     * @Breif : EDGE-212793, On click of Telstra id button method gets called which will enable the LWC modal
     */ 
    handlePaymentAction : function(component,event,helper){
        var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        component.set("v.displayModal",true);
        component.set("v.showSpinner",true);
        component.set("v.transactionId",row.transactionId);
        component.find('modal').showModal();
        
    }
    
})