({
    // Fetch sites from replicator and display on lightning page
    getSites: function(component) {
        console.log("Record Id: " + component.get('v.recordId'));
        console.log("CIDN: " + component.get('v.fields'));
        var url = window.location.href;
        console.log(component.getLocalId());
        console.log(window.document.getElementById(component.getGlobalId()));
        var sURLVariables = url.split('&'); 
        var sParameterName;
        var params=[];
        var i;
        var j;
        for (i = 0; i < sURLVariables.length; i++) {          
            sParameterName = sURLVariables[i].split('=');
            for(j = 0; j < sParameterName.length; j++){
                if(sParameterName[j].match(/\d+$/)){
                    params[i]=sParameterName[j];
                }
                else{
                    params[i]=sParameterName[1];
                }
            }                
        }
      
        if(params[1]==undefined){
            component.set('v.oppId',null);
        }
        else{
            component.set('v.oppId',params[1]);
        }

        if(params){
            var cidnValue;
            if(component.get('v.cidn') != 'empty'){
                cidnValue = component.get('v.cidn');
            }else{
                cidnValue = params[0];
            }
            var action = component.get('c.getCustomerSites');
            action.setParams({"finCIDN" : cidnValue});
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();                
                if(data==null || (data.Error_Code!='' && data.Error_Code!='200')){   
                var staticLabel = $A.get("$Label.c.Replicator_Technical_Error_Message");
            	this.showToast(component, 'Failure', staticLabel);                  
                }
                component.set('v.sites',data);
                });
            $A.enqueueAction(action);
        }else{
            this.showToast(component, 'Error!',  "CIDN does not exist");              
        }
    },
    //code to enable/disable proceed button on change of checkbox
      enableTransitionButton : function(component) {
	  var checkboxes = component.find("multiSelect");
	  var chkflag=false;
	  if(checkboxes.length != undefined){
		for (var i = 0; i < checkboxes.length; i++){
			if(checkboxes[i].get("v.value")==true){
				chkflag=true;
			}
		}
	  }else{
		  checkboxes = [component.find("multiSelect")];
		  if(checkboxes[0].get("v.value")==true)
			chkflag=true;
	  }
	   component.find("proceedButton").set("v.disabled",!chkflag);

    },
 
    // Save selected address in SFDC and will navigate to getservices page
    saveSites: function(component){
        console.log('saveSites<><><>   111');
        var action = component.get("c.upsertAddress");
        var adborId = component.get("v.selectedAdborIdArray");
        console.log('Selected Adbor Id from GUI for site saving = ' + adborId);
        var replicatorData = component.get("v.sites");
        action.setParams({"adborIdList":adborId,"replicatorAddress" : JSON.stringify(replicatorData)});
        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");
            var data = response.getState();
            if(data == "SUCCESS"){
                var result = response.getReturnValue();
                console.log(result);
                if(result!=null && result.isSuccess){
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": result.successMsg
                    });
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:GetServices",
                        componentAttributes: {
                            adborid:component.get("v.selectedAdborIdArray"),
                            siteName:component.get("v.siteName"),
                            siteNameArray:component.get("v.siteNameArray"),
                            cidn:component.get("v.sites.CIDN"),
                            oppId:component.get("v.oppId")
                        }
                    });
                    toastEvent.fire();
                    evt.fire();
                }
                else{
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": result.errorMsg
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }, 
    //Checking for in-flight order and then passing then calling savesite method
    getServices: function(component){
        
        /****I have commented this part as  inFlightCheck method id not present in the manager*/
        
      	 var action = component.get("c.inFlightCheck");
       // console.log("action : "+action);
        var adborId = component.get("v.selectedAdborId");
        console.log("adborId : "+adborId);
        var CIDN = component.get("v.sites.CIDN");
        //CIDN="1891494118";
        console.log('Selected Adbor Id from GUI = ' + adborId);
        action.setParams({"adbor_id":adborId,"cidn":CIDN});
        action.setCallback(this, function(response) {
            console.log("Inside getServices");
            var data = response.getState();
            console.log("data :"+data);
            if(data == "SUCCESS"){
                var result = response.getReturnValue();
                if(result.isSuccess){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": result.errorMsg
                    });
                    toastEvent.fire();
                }
                else{
                    console.log("Inside else");
                    this.saveSites(component);
               }
            }
        });
        $A.enqueueAction(action);
        
    }  
    ,
    showToast : function(component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 2500,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
	}
})