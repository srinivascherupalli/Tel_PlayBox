({
	doInit: function (component, event, helper) {
        console.log('Inside doInit');
		//$A.util.addClass(component.find("mySpinner"), "slds-hide");

		//component.set("v.showSpinner1", true);
		var featureLevel = component.get('v.featureLevel');
        var techSupport = component.get('v.techSupport');
        var offerid = component.get('v.offerid');
		var vendor = component.get('v.vendor');
        if(featureLevel != null){
        var filteredColumn = featureLevel.concat(techSupport);
    }
        if(vendor != null && vendor.includes('"')){
            var newvendor = vendor.split('"',2);
            vendor = newvendor[0];
        }
        console.log(filteredColumn);
        component.set("v.filteredColumn", filteredColumn);
        //component.set("v.filteredColumn", 'StandardBus Hrs');
        
        var type = component.get('v.type');
        var externalId = '';
        console.log(featureLevel);
        console.log(techSupport);
        console.log(type);
        console.log(offerid);
        //console.log(!v.filteredColumn);
        if(type != null && type.includes('T-MDM')){
            externalId = 'Charge_000948';
        }
        //EDGE-123914
        else if (type != null && type.includes('User')) {
        	externalId = 'Charge_000852';
        }
        console.log('externalId--->'+externalId);
		var action = component.get("c.getRateCard");
		action.setParams({
            "externalId": externalId,
            "offerId": offerid,
            "vendor": vendor
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
			var res = response.getReturnValue();
                console.log('Res  --->'+res);
                console.log('Res ->',res);
             component.set("v.commericalProductData", res.sort());
            var commericalProductData = component.get('v.commericalProductData');
            
            console.log('commericalProductData--->',JSON.stringify(commericalProductData));
            }
		});

		$A.enqueueAction(action);

		
	}
})