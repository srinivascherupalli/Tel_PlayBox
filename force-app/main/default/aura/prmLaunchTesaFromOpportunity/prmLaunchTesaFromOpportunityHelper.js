({	
    checkFeatureEnabled : function(component, event, helper){
        var getBooleanValue = component.get("c.checkFeatureEnabled");
        getBooleanValue.setParams({
        });
        getBooleanValue.setCallback(this, function(response) {
            var state = response.getState();
            //if state is success
            if(state === "SUCCESS"){
                console.log('response value is'+response.getReturnValue());
                if(response.getReturnValue() == false){
                    component.set("v.spinner",false);
                    component.set("v.showPopUp",false);
                    let errorLocalList = [];
                    errorLocalList.push($A.get("$Label.c.PRM_Lead_Feature_Not_Enable"));
                    component.set("v.errorList",errorLocalList);
                }else if(response.getReturnValue() == true){
            		//call getData method in helper
            		helper.getData(component, event, helper);
                }
            }
        });
        $A.enqueueAction(getBooleanValue);
    },
    
	getData : function(component, event, helper) {
        //call apex class to get data from server
        var getOpportunityDetails = component.get("c.getOpportunityData");
        getOpportunityDetails.setParams({
        	"oppId": component.get("v.recordId")
        });
        //callback function
        getOpportunityDetails.setCallback(this, function(response) {
            var state = response.getState();
            //if state is success
            if(state === "SUCCESS"){
                var data = response.getReturnValue();
                if(data.length > 0){
                    for(var i=0;i<data.length;i++){
                        if(data[i].showError){
                            var errorLocalList = [];
                            for(var j=0;j<data[i].errorMsgs.length;j++){
                                errorLocalList.push(data[i].errorMsgs[j]);
                            }
                            //set show spinner true
                            component.set("v.spinner",false);
                            //set all error messages in errorList variable to display on ui
                            component.set("v.errorList",errorLocalList);
                            //set showPopup false
                            component.set("v.showPopUp",false);
                            //if there is no error then launch tesa
                        }else if(!data[i].showError){
                            var baseUrl = JSON.parse($A.get("$Label.c.PRMTesaBaseURL"));
                            var userType = data[i].metaData['UserType__c'];
                            //set show spinner false
                            component.set("v.spinner",false);
                        	if(data[i].oppInfo['CIDN__c'] != undefined && data[i].oppInfo['CIDN__c'] != null){
                                console.log('vaue is'+baseUrl[userType] +'?CIDN='+data[i].oppInfo['CIDN__c']+'&OppNum='+data[i].oppInfo['Opportunity_Number__c']+'&OpportunityId='+data[i].oppInfo['Id']);

                                let tesaLaunchUrl = baseUrl[userType] +'?CIDN='+data[i].oppInfo['CIDN__c']+'&OppNum='+data[i].oppInfo['Opportunity_Number__c']+'&OpportunityId='+data[i].oppInfo['Id'];
                            	console.log('tesaLaunchurl is'+tesaLaunchUrl);
                                //Navigate to tesa in new Tab
                                var urlEvent = $A.get("e.force:navigateToURL");
    								urlEvent.setParams({
      								"url": tesaLaunchUrl
    								});
    							urlEvent.fire();

                            }
                        }
                    }
            	}
            }
        });
        $A.enqueueAction(getOpportunityDetails);
	}
})