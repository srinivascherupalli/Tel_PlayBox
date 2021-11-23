({
    doInit: function (component,event,helper) {
        helper.initialize(component,event,helper);
    },
       
    saveTable: function(component, event, helper) {
        var colorMap=component.get('v.colorMap');
        console.log('============colorMap==================');
        console.log(colorMap);
        var caseArray = [];
        var valid=true;
 		var recId=component.get('v.recordId');      
        var productList=component.get('v.products');
        console.log('products');
        console.log(productList);
         
        for(var i=0;i<productList.length;i++){
            productList[i].soc_Parent_SFD_Reference__c=recId;
            if(productList[i].soc_SFD_Product_Status__c=='--- None ---'){
                productList[i].soc_SFD_Product_Status__c="";
            }
            if(productList[i].soc_SFD_Sub_Status__c=='--- None ---'){
                productList[i].soc_SFD_Sub_Status__c="";
            }
            if(productList[i].soc_SFD_Product_Status__c=='On-Hold Pending ITAM resolution' &&
               ($A.util.isUndefinedOrNull(productList[i].soc_Order_Number__c) || productList[i].soc_Order_Number__c.trim().length<1 )){
                valid=false;
            }
            console.log('Row Number : '+(i+1));
            console.log(helper.validateSaveData(colorMap,productList[i].soc_SFD_Product_Status__c,productList[i].soc_SFD_Sub_Status__c));

            var isValidData=helper.validateSaveData(colorMap,productList[i].soc_SFD_Product_Status__c,productList[i].soc_SFD_Sub_Status__c);
            if(!isValidData){
                productList[i].soc_SFD_Sub_Status__c="";
            }
            
        }
        console.log('#########Save Array###########');
        console.log(productList);
        if(valid){
        	helper.saveData(component,event,helper,productList);
        }
        else{
            helper.showErrorToast(component, event, helper, 'ITAM number mandatory')
        }
           },
       
})