({
	doInit: function (component, event, helper) {
        console.log('Inside discount');
		var accountId = component.get('v.accountId');
		var basketId = component.get('v.basketId');
        var solutionId = component.get('v.solutionId');
        var configId=component.get('v.configId');
        var tabName = component.get('v.tabName');
        //var solutionName=component.get('v.solutionName');
       	var discountDataList=component.get('v.discountDataList');
        var mapJsonString=component.get('v.mapJsonString');//Added by Aman Soni as a part of EDGE-143527
        //console.log('accountId'+accountId+'solutionId'+solutionId+'configId'+configId+'tabName'+tabName);
        //console.log('mapJsonString--->'+mapJsonString);//Added by Aman Soni as a part of EDGE-143527
        var action = component.get("c.getDiscountdata");
		action.setParams({
			"accountID": accountId,
            "solutionID": solutionId,
            "configGuid" : configId,
            "tabName" : tabName,
            "mapJsonString":mapJsonString
		});//Added mapJsonString by Aman Soni as a part of EDGE-143527
		action.setCallback(this, function (response) {
			var state = response.getState();
            console.log(state);
            if (state == "SUCCESS") {
				var res = response.getReturnValue();
				console.log('Response dto--->');
				//console.log(res);
				component.set("v.discountDataList", res);
                
                //Added by laxmi  - If no response then set the flag to false
                  if(res==null  || res ==''){
                    component.set("v.isDiscountDataListEmpty", true);
                    //console.log('isDiscountDataListEmpty--->'+ component.get('v.isDiscountDataListEmpty'));
                }else{
                     component.set("v.isDiscountDataListEmpty", false);
                }
                    }
		});
        $A.enqueueAction(action);
     }
})