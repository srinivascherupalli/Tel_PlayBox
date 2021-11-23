({
     getCommunityUrl: function(component, event) {
        var action = component.get("c.getCommunityUrl");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                 component.set("v.CommunityUrl", result);
                }
            
        });
        $A.enqueueAction(action);
    },
    //SaveRecord will be called withoud leadId as per updated controller method
    // - Story P2OB-7585 - Ayush(Appirio)
     SaveRecord: function(component, event,lead,step) {
                 component.set("v.spinner",true);
                var lead=component.get("v.leadRec");
                var action = component.get("c.saveLead");
                action.setParams({
                    "lead":lead,
                    "CatpchToken":component.get("v.CaptchaToken")
                });

                action.setCallback(this, function(response){
                    var state = response.getState();

                    if (state === "SUCCESS") {
                       var result = response.getReturnValue();
                         result=JSON.parse(result);
                        
        				component.set("v.spinner",false);
                        if(result.Status=='SUCCESS'){
                        component.set('v.LeadrecordId',result.Leadid);
                        component.set('v.step',step);
                            if(step!==5)
                                 component.set('v.currentStep',String(step));
                            
                            if(step==5)
                                component.set('v.FormSubmitted',true);

                            
                        component.set('v.showMessage',false);
                            this.setselectedvalues(component, event,step);
                        }
                        else if(result.Status=='Error')
                            
                        {
                            var errors = result.getError();
                            this.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_SAVE_ERROR'),$A.get('$Label.c.PRM_EOI_SAVE_ERROR_INSTRUCTION'));
                        }
                    }
   			 });
                 $A.enqueueAction(action);

     },
	 //get Industry Picklist Value
    getIndustryVerticalpicklist: function(component, event) {
        var action = component.get("c.getIndustryVertical");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var industryMap = [];
                for(var key in result){
                    industryMap.push({key: key, value: result[key]});
                }
                component.set("v.industryMap", industryMap);
            }
        });
        $A.enqueueAction(action);
    },
       showToast : function(component, event, helper,Message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Error!",
        "message":Message,
		"type":"error"
    });
    toastEvent.fire();
},
    validateABN: function(component, event) {
        component.set("v.spinner",true);

        var action = component.get("c.callABNService");
        action.setParams({ "ABN" : component.get("v.leadRec.ABN__c") });
  

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.spinner",false);
                result=JSON.parse(result);
                component.set("v.leadRec.ABN_Registered_Name__c",result.entityName);
                component.set("v.leadRec.Entity_Age_Years__c",result.noOfYrsInBusiness);
                var businessNames=result.listBusinessName;
                 var businessNamesmap= [];
                
                if(businessNames.length>0)
                    businessNamesmap.push({key:'' , value: "- Please Select -"});
                
                for(var key in businessNames){                    
                                	businessNamesmap.push({key: businessNames[key], value: businessNames[key]});
                }
                component.set("v.BusinessnamelistMap", businessNamesmap);

            }
        });
        $A.enqueueAction(action);
    },
      
 setselectedvalues : function(component, event,step) {
     
     if(step==1)
     {
         window.setTimeout(
            $A.getCallback(function() {
                var OTPphone= component.get("v.phonenumber");
         		document.querySelector('#phone').value=OTPphone;
            }), 3000
        );
     }
     else if(step==2){
          var selectcustSeg=component.get("v.leadRec.Customer_Segment__c");
         if(selectcustSeg!=undefined){
        		var strlist=selectcustSeg.split(';')
                var plValues=[];
                      if(strlist.length>0)
                      {
                		 for(var key in strlist){
                    		 plValues.push(strlist[key]);}
                	}
  				component.find("companyInfo").set("v.selectedcustseg",plValues);
         }
     }
      	else if(step==3){
          var partnerCategories=component.get("v.leadRec.Partner_categories__c");
            if(partnerCategories!=undefined){
        		var strlist=partnerCategories.split(';')
                var plValues=[];
                      if(strlist.length>0)
                      {
                		 for(var key in strlist){
                    		 plValues.push(strlist[key]);}
                	}
  				component.find("partnerinfo").set("v.SelectedPartnercategoriesList",plValues); 
            }
            var SourceInfo=component.get("v.leadRec.Source_Info_Telstra_Channel_Partner_prog__c");
            if(SourceInfo!=undefined){
        		var SourceInfolist=SourceInfo.split(';')
                var SourceplValues=[];
                      if(SourceInfolist.length>0)
                      {
                		 for(var key in SourceInfolist){
                    		 SourceplValues.push(SourceInfolist[key]);}
                	}
  				component.find("partnerinfo").set("v.TCPProgramoptionsselectedVal",SourceplValues); 
     }
        }
},
        showErrorMessage: function(component,Message,Instruction) {
            		component.set('v.showMessage',true);
                    component.set('v.message',Message);
                    component.set('v.instruction',Instruction);
                    component.set('v.severity','error');
                    window.scrollTo(0, 50);
    },
   
})