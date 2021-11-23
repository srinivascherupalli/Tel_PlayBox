({
	initialize : function(component) {
        var recordId = component.get("v.recordId");
        var childRelationship = component.get("v.childRelationship");
        var parentField = component.get("v.parentField");
        var fieldsToBeDisplayed = component.get("v.FieldsToBeDisplayed");
        var action = component.get("c.getRelatedListData");
        action.setParams({"recordId":recordId,
                          "childObject": childRelationship,
                          "parentField" : parentField,
                          "fieldsToBeDisplayed" : fieldsToBeDisplayed});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                var responseResult = response.getReturnValue();
                if(responseResult.indexOf('Error:') == 0 ){
                    console.log(result);
                }else{
                    var result = JSON.parse(responseResult);
                    var tableColumns = [{
                    "label": "Product Basket Name",
                    "fieldName": "linkName",
                    "type": "url",
                     "cellAttributes": {
                            "class": {
                                "fieldName": "showClass"
                            }
                    },
                    "typeAttributes": {
                        "label": {
                            "fieldName": "Name"
                        },
                        "target": "_self"
                    }
                    }];
                    for(var i =0 ;i < result.fieldWrapperList.length;i++){
                        console.log('::result.fieldWrapperList[i].type'+result.fieldWrapperList[i].type);
                        if(result.fieldWrapperList[i].type == 'date' || result.fieldWrapperList[i].type == 'dateTime'){
                            tableColumns.push({label: result.fieldWrapperList[i].label, fieldName: result.fieldWrapperList[i].fieldName, type: 'date', typeAttributes: {  
                                 day: 'numeric',  
                                 month: 'numeric',  
                                 year: 'numeric'}});
                         }else{
                             tableColumns.push(result.fieldWrapperList[i]);
                         }
                    }
                    var records = result.listData;
                    var pageSize = component.get("v.size");
                    var prefixURL = $A.get("$Label.c.PRM_Basket_URL"); 
                    var linkprefix = childRelationship == 'cscfga__Product_Basket__c' ?  prefixURL : '/';
                    for(var i =0 ;i < records.length;i++){
                        var r = records[i];
                        if(result.isEditAccess == true){
                            
                            r.linkName = linkprefix + r.Id;
                        }else{
                            r.linkName = '#';
                            r.showClass = 'productBasketDisabled'; 
                        }
                     }
                     var displayData = [];
                     if(pageSize > records.length){
                         pageSize = records.length;
                         component.set("v.isViewVisible", false);
                     }else{
                         component.set("v.isViewVisible", true);
                     }
                     for(var i = 0; i< pageSize; i++){
                         displayData.push(records[i]);
                     }
                    component.set("v.fieldColumns", tableColumns);
                    component.set("v.dataList", records);
                    component.set("v.displayDataList", displayData);
                    //component.set("v.isEdit", result.isEdit);
                    component.set("v.isEdit", result.isRead);
				}
        	}
        });
        $A.enqueueAction(action);
	},
    viewAll :  function(component, event, helper) {
        var displayData = [];
        var records = component.get("v.dataList");
        var pageSize = component.get("v.size");
		for(var i = 0; i< records.length; i++){
            displayData.push(records[i]);
        }
        component.set("v.displayDataList", displayData);
        component.set("v.isViewVisible", false);
        component.set("v.isLessRequired", true);
        var showItemBtn = component.find("showItemButton");
        showItemBtn.set("v.label", "Show " + pageSize + " Items");
        
    },
    lessRecords :  function(component, event, helper) {
        var displayData = [];
        var records = component.get("v.dataList");
        var pageSize = component.get("v.size");
		for(var i = 0; i< pageSize; i++){
            displayData.push(records[i]);
        }
        component.set("v.displayDataList", displayData);
        component.set("v.isViewVisible", true);
        component.set("v.isLessRequired", false);
	}
})