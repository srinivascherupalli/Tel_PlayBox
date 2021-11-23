({
    retryContract : function(component) {
        if(component.get("v.displayError") != 'Success'){
            if(action != undefined){   
                var action = component.get("c.retryContractGeneration");
                action.setParams({ recordId : component.get("v.recordId") });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.displayError",response.getReturnValue());                
                    }
                    else if (state === "INCOMPLETE") {
                        console.log("Processing...");
                    }
                        else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " + 
                                                errors[0].message);
                                }
                            } else {
                                console.log("Unknown error");
                            }
                        }
                });
                $A.enqueueAction(action);
            }
        }	   
    },
    
    getContractName : function(component){
        var action = component.get("c.getcontractName");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            component.set("v.contractName",response.getReturnValue());
            component.set("v.DocuSign_Restricted_Message", component.get("v.DocuSign_Restricted_Message").replace("contractNameVar", response.getReturnValue()));
            
        });
        $A.enqueueAction(action);
    },
    
    getContractStatus : function(component){
        var action = component.get("c.getcontractStatus");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            component.set("v.contractStatus",response.getReturnValue());
            this.getContractStatusMsg(component, response.getReturnValue());
          //  component.set("v.contractStatusMsg",component.get("v.statusMsgMap")[response.getReturnValue().replace(' ', '')]);
		  console.log('getContractStatus contractStatusMsg'+component.get("v.contractStatusMsg"));
        });
        $A.enqueueAction(action);
    },
    //EDGE-187048 :to fetch the details about the restrict conga flag from Contractjunction record
    getcontractDocusignEnabled : function(component){
        var action = component.get("c.getcontractDocusignEnabledStatus");
        
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
           
			var state = response.getState();
            if(state === "SUCCESS")
			{
              console.log('Restrict Conga Flow  >> '+response.getReturnValue());
                var responseval = response.getReturnValue();
                component.set("v.isRestrictCongaFlow",responseval['restrictCongaFlag']);
                component.set("v.isDSAFlag",responseval['isDSAFlag']);
                console.log('key '+responseval['restrictCongaFlag']);
			}
        });
        $A.enqueueAction(action);
    },
	
	//to fetch the details about the restrict conga flag from Contractjunction record EDGE-187048
    getcontractRestrictCongaStatus : function(component,isRestrictCongaFlow){
        //alert('In Restricted flag enabled  '+component.get("v.isRestrictCongaFlow") + 'display errror ' +component.get("v.displayError"));
        if(component.get("v.isRestrictCongaFlow") == true && component.get("v.displayError") == 'Success'){
                component.set("v.restrictCongaFlow",'Initiate Docusign');
            }
            else if(component.get("v.isRestrictCongaFlow") == true && component.get("v.displayError") == 'Docusign Restricted'){
                 component.set("v.restrictCongaFlow",'Raise a Case');
            }
            else if(component.get("v.isRestrictCongaFlow") == false && component.get("v.displayError") == 'Docusign Restricted'){
                 component.set("v.restrictCongaFlow",'Wet Signatures');
            }
			else if(component.get("v.isRestrictCongaFlow") == true && component.get("v.displayError") == 'Failure'){
                 component.set("v.restrictCongaFlow",'Wait for orderForm');
            }
        	/*else if(component.get("v.isRestrictCongaFlow") == true && component.get("v.isDSAFlag") == false && component.get("v.displayError") == 'Success'){
                 component.set("v.restrictCongaFlow",'DSA');
            }*/
			
			console.log('Status >>  '+component.get("v.restrictCongaFlow"));
			
    },
    
    updateContractStatus : function(component,actionToPerform,recordid){
        var action = component.get("c.updateContractStatus");
        action.setParams({ recordId : recordid,"changeaction" : ''+actionToPerform });
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            component.set("v.contractStatus",response.getReturnValue()); 
            this.getContractStatusMsg(component, response.getReturnValue());
          //  component.set("v.contractStatusMsg",component.get("v.statusMsgMap")[response.getReturnValue().replace(' ', '')]);
		  console.log('updateContractStatus contractStatusMsg'+component.get("v.contractStatusMsg"));
        });
        $A.enqueueAction(action);
    },
    
    getContractDocumentStatus : function(component){
        if(component.get("v.displayError") != 'Success'){
            var action = component.get("c.checkContractDocumentGeneration");
            if(action!=undefined){    
                action.setParams({recordId : component.get("v.recordId")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS")
                    {
                        var retvalue = response.getReturnValue();
                        var currentStatus = component.get("v.contractDocumentStatus");
                        console.log(retvalue);
                        if(currentStatus != retvalue)
                        {
                            console.log('contractjunction changed');
                            component.set("v.contractDocumentStatus",retvalue);
                            component.set("v.displayError",retvalue);
                            $A.get('e.force:refreshView').fire();
                        }
                        
                    }
                    else if(state === "INCOMPLETE")
                    { 
                        console.log(response.getReturnValue());
                        if(response.getReturnValue() === 'notReady')
                            console.log("Document not yet generated");
                    }
                        else
                        {
                            console.log("Some error occurred: "+state);
                        }
                    
                });
                $A.enqueueAction(action);
            }
        }
    },
     //the method is to call the docusign vf page after creating Contract record EDGE-187048
	callDocuSignurl : function(component){
       // console.log('contractStatusMsg'+component.get("v.contractStatusMsg"));
        if(component.get("v.recordId")!= null && component.get("v.displayError")=='Success' && component.get("v.contractStatus") == 'Initiated'){
            var action = component.get("c.checkDocumentGenerated");
           // alert(component.get("v.recordId"));
                action.setParams({recordId : component.get("v.recordId")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS")
                    {
                        console.log('Inside call docusign url ::');
                       if(response.getReturnValue()!= null &&  component.get("v.isDSAFlag")){
                            var vfURL = '/apex/APTPS_ValidationOnESignature?id='+response.getReturnValue();
                           var baseurl = window.location.href;
                           console.log('vfurl == '+vfURL);
                           //INC000094761793-Fix by SJ
							if(baseurl.includes('partners.enterprise.telstra.com.au'))
								component.set("v.docusignUrl",'/s/sfdcpage/'+encodeURIComponent(vfURL));
							else if(baseurl.includes('/partners/s'))
								component.set("v.docusignUrl",'/partners/s/sfdcpage/'+encodeURIComponent(vfURL));
                           	else
                                component.set("v.docusignUrl",encodeURI(vfURL));
                           //INC000094761793-Fix by SJ
                           
                        component.set("v.docusignUrlShow",false);
                           component.set("v.docusignUrlShowTrue",true);
                        /*var navEvt = $A.get("e.force:navigateToURL");
                            navEvt.setParams({
                                "recordId": '/apex/APTPS_ValidationOnESignature?id=a074Y0000016l5KQAQ'
                                
                            });
                            navEvt.fire();*/
                            //console.log('fire event to call docusign url'+navEvt.setParams);
                        }else{
                            
                        component.set("v.docusignUrl","Fetching Documents related to Agreements");
                        component.set("v.docusignUrlShow",false);
                    }
                        
                        
                    }else{
                        component.set("v.docusignUrl","Please try after Sometime");
                        component.set("v.docusignUrlShow",false);
                    }
                    
                    
                });
                $A.enqueueAction(action);
            
        }
    },
	
    getContractStatusMsg: function(component, cStatusText){
     
       var cStatus = cStatusText;
        var keyVal = ''
        if(cStatus == 'Pending Approval'){
            	keyVal = 'PA';
        }
        else if(cStatus == 'Customer Review'){
            keyVal = 'CR';
        }
        else if(cStatus == 'Pending Countersign'){
            keyVal = 'PC';
        }
        else if(cStatus == 'Contract Accepted'){
            keyVal = 'CA';
        }
        else if(cStatus == 'Signature Declined'){
            keyVal = 'SD';
        }
        else if(cStatus == 'In Effect'){
            keyVal = 'IE';
        }
        else if(cStatus == 'Cancelled'){
            keyVal = 'CE';
        }
        else if(cStatus == 'Void'){
            keyVal = 'CV';
        }
        else {
               keyVal = 'CI'; 
            }
        var labelString = $A.get("$Label.c.ContractNotificationMsg");
        
        var statusMsg = labelString.substring(labelString.lastIndexOf('['+keyVal+']') + 4, labelString.lastIndexOf("["+keyVal+"e]"));
       // alert(statusMsg);   
         component.set('v.contractStatusMsg',statusMsg);   
		// console.log('getContractStatusMsg contractStatusMsg'+component.get("v.contractStatusMsg"));
    }
})