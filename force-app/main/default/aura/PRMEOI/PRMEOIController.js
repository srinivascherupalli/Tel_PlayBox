({
    afterScriptsLoaded : function(component, event, helper) {
    },
    doInit : function(component, event, helper) {
        console.log('company size valid default -->' + component.get("v.companySizeValid"));
        helper.getCommunityUrl(component,event);
        // DIGI-15298 replacing custom labels with metadata
        var visualforceDomain;
        var action = component.get("c.getPRMEOIVisualforceDomain");
        action.setParams({ recordName : 'PRM_EOI_Visualforce_Domain' });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                visualforceDomain = JSON.parse(response.getReturnValue());
            } 
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        //Using Custom Label to get the URL EDGE-80392
        //var visualforceDomain = "https://" +  $A.get("{!$Label.c.PRM_EOI_Visualforce_Domain}");
        /**
         * Adding a new event listner on window object
         * to listen for message event
         **/
        window.addEventListener("message", function(event) {
            //Check if origin is not your org's my domain url, in this case, simply return out of function
            if (visualforceDomain.indexOf(event.origin) == -1) {
                // Not the expected origin: reject message!
                console.error('Discarding Message | Message received from invalid domain: ',event.origin);
                return;
            }
            // Handle the message event here
            // //store n send to server

            // Updated by Ayush for JIRA Story P2OB:7585
            if(event.data == 'true'){
                component.set('v.captchaVerified',false);
            }else {

            component.set('v.CaptchaToken',event.data);
            component.set('v.captchaVerified',true);
            }
        }, false);
    },      
    handleApplicationEvent : function(component, event, helper) {
        //Application event to show the Error popups to users
        var step = event.getParam("data");
        var Isinvalidemail = event.getParam("InvalidEmail");
        var IsinvalidABN = event.getParam("IsinvalidABN");
        var ABNresult = event.getParam("ABNResult");
       var Bnameslist = event.getParam("Bnameslist");

        //Below if statement Added by team Hawaii for P2OB 8478
        var IsValidCompanySize = event.getParam("IsValidCompanySize");
        if(IsValidCompanySize != undefined){
            console.log('inside if of is valid company size 1');
            if(IsValidCompanySize){
                console.log('inside if of is nvalid company size 2');
                component.set('v.companySizeValid',true);
            }else{
                component.set('v.companySizeValid',false);
            }
        }
        console.log('company size is->' + component.get('v.companySizeValid'));
        
        if(Bnameslist!=undefined)
        { 
            component.set('v.BusinessnamelistMap',Bnameslist);
        }
        //ABN errors
        if(ABNresult!=undefined){
            if(ABNresult.status!='Active'){
                component.set('v.InvalidABN',true);
                helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_ABN_Not_Valid'),$A.get('$Label.c.PRM_EOI_ABN_Not_Valid_Instruction'));
			 } 
            else if(ABNresult.noOfYrsInBusiness<2){
                component.set('v.InvalidABN',true);                       
                helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Number_of_Years_Error'),$A.get('$Label.c.PRM_EOI_NoOf_Years_Instruction'));
                } 
                else {
                    component.set('v.InvalidABN',false); 
                    component.set('v.showMessage',false);
                }
        }
        if(Isinvalidemail!=undefined){
            if(Isinvalidemail){
                component.set('v.Isvalidemail',false);                
                helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Email_Error'),$A.get('$Label.c.PRM_EOI_Email_Instruction'));
            }
            else{
                component.set('v.Isvalidemail',true);
                component.set('v.showMessage',false);
            }
        }
        if(step!=undefined){
            var formComplete=component.get("v.FormCompleted");
            var FormSubmitted=component.get("v.FormSubmitted");
            if(!FormSubmitted){
            if(formComplete){
                component.set("v.step",parseInt(step));
            }
            else if(parseInt(step)==1){
 				component.set("v.step",parseInt(step));
            }
           else if(parseInt(step)==2){
                var leadrecid=component.get("v.LeadrecordId");
                if(leadrecid){component.set("v.step",parseInt(step)); }
           }
           else if(parseInt(step)==3){
                var allValid = component.find("companyInfo").find('Leadform').reduce(function (validFields, inputCmp) {
                        return validFields && inputCmp.get('v.validity').valid;
                    }, true);
               		if(allValid || formComplete){
                        component.set("v.step",parseInt(step)); }
            	}
           else if(parseInt(step)==4){
                 //var selectedTCPProgramoptions=component.find("partnerinfo").get("v.TCPProgramoptionsselectedVal");
                 var allValid = component.find("partnerinfo").find('Leadform').reduce(function (validFields, inputCmp) {
                        return validFields && inputCmp.get('v.validity').valid;
                    }, true);	 
               if(allValid){
                     component.set("v.step",parseInt(step));
                }
            }
          }
            helper.setselectedvalues(component, event,parseInt(step)); 
        }
        //Below line commented by Team Hawaii for P2OB-8478
        //window.scrollTo(0, 50);
    },
    handleContinue : function(component,event,helper){
        switch(component.get("v.step")) {
            case 1:              
                {       
                    var allValid = component.find("contactInfo").find('Leadform').reduce(function (validFields, inputCmp) {
                        inputCmp.showHelpMessageIfInvalid();
                        return validFields && inputCmp.get('v.validity').valid;
                    }, true);
                    if(allValid){
                        var phone =document.getElementById("phone2").value;
                        var phone1 =document.getElementById("phone").value;
                        if(phone1)
                        	component.set("v.phonenumber",phone1);
                        component.set("v.leadRec.OTP_Mobile_Phone_Number__c",phone);
                        if(!phone)
                       	 helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Value_Required_Error'),'');                    
                        else{
                        //SaveRecord will be called at final step - Story P2OB-7585 - Ayush(Appirio)
                        component.set("v.step",2);
                        component.set("v.currentStep",String(2));
                        //helper.SaveRecord(component,event,helper,2)
                        }
                        window.scrollTo(0, 50);
                    }
                    else{                        
                        helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Value_Required_Error'),'');                    
                    }
                }
            case 2:{ 
                var allValid = component.find("companyInfo").find('Leadform').reduce(function (validFields, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validFields && inputCmp.get('v.validity').valid;
                }, true);
                if(allValid){
                    var hasaggriment=component.get('v.leadRec.Has_Telstra_Agreement__c');
                    var Current_agreements=component.get("v.leadRec.Current_agreements_with_telstra__c");
                    var isworkingwithrep=component.get('v.leadRec.Working_with_Telstra_Partner_Sales_rep__c');
                    var ExistingPartner=component.get("v.leadRec.Existing_Telstra_Partner_Sales_rep__c");                
                    var lead=component.get("v.leadRec");
                    var selectedcustomersegment=component.find("companyInfo").get("v.selectedcustseg");
                    var customersegment='';
                    if(selectedcustomersegment.length>0){
                        for(var key in selectedcustomersegment){
                            customersegment+=selectedcustomersegment[key]+';'; }                         
                        customersegment= customersegment.substring(0, customersegment.length - 1);
                    }
                    component.set("v.leadRec.Customer_Segment__c",customersegment);
                    if(customersegment.length==0)
                    {
                        helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Value_Required_Error'),'');
                    }                                
                    else if(hasaggriment=='Yes' && Current_agreements==undefined)
                    {
                        helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Agreement_Type_Required'),'');
                    }
                        else if(isworkingwithrep=='Yes' && ExistingPartner==undefined)
                        {
                            helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Representative_required'),'');
                        }                
                            else{
                                //SaveRecord will be called at final step - Story P2OB-7585 - Ayush(Appirio)
                                component.set('v.showMessage',false); 
                                component.set("v.step",3);
                                component.set("v.currentStep",String(3));
                                //helper.SaveRecord(component,event,helper,3)
                            }               
                }
                else{
                    helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Value_Required_Error'),'');
                }
                window.scrollTo(0,50);
                break;}
            case 3:{ 
                var PartnercategoriesOther=component.get("v.leadRec.Partner_categories_Other_Comments__c");
                var TCPOther=component.get("v.leadRec.Telstra_Channel_Partner_program_Comments__c");                
                var selectedTCPProgramoptions=component.find("partnerinfo").get("v.TCPProgramoptionsselectedVal");
                var SelectedPartnercategories=component.find("partnerinfo").get("v.SelectedPartnercategoriesList");
                var businessCapabilities = component.get("v.leadRec.Lead_Description__c");
                //Added by Ayush for story P2OB-7471
                var TCPSourceName=component.get("v.leadRec.TPC_Source_Distributor_Name__c");
                var allValid = component.find("partnerinfo").find('Leadform').reduce(function (validFields, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validFields && inputCmp.get('v.validity').valid;
                }, true);
                //Added businessCapabilities as part of EDGE-88429
                if(SelectedPartnercategories.length>0 && selectedTCPProgramoptions.length>0 && businessCapabilities != undefined)
                {							
                    var TCPProgramoptions='';
                    var PartnercategoriesList='';                            
                    if(selectedTCPProgramoptions.length>0){
                        for(var key in selectedTCPProgramoptions){
                            TCPProgramoptions+=selectedTCPProgramoptions[key]+';'; 
                        }
                        TCPProgramoptions= TCPProgramoptions.substring(0, TCPProgramoptions.length - 1);
                    } 
                    if(SelectedPartnercategories.length>0){
                        for(var key in SelectedPartnercategories){
                            PartnercategoriesList+=SelectedPartnercategories[key]+';'; 
                        }
                        PartnercategoriesList= PartnercategoriesList.substring(0, PartnercategoriesList.length - 1);
                    } 
                    component.set("v.leadRec.Partner_categories__c",PartnercategoriesList);
                    component.set("v.leadRec.Source_Info_Telstra_Channel_Partner_prog__c",TCPProgramoptions);
                    if(PartnercategoriesList.includes("Other")  && PartnercategoriesOther==undefined){
                        helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_company_specialises_Other'),'');
                    }
                    else if(TCPProgramoptions.includes("Other")  && TCPOther==undefined){
                        helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_TCP_program_Other'),'');
                    }
                    //Added by Ayush for Story P2OB-7471
                    
                    else if(TCPProgramoptions.includes("A Channel Partner or Distributor") && TCPSourceName==undefined){
                                helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_TCP_Source_Partner_Distributor'),'');
                    }

                    //Added by Ayush for Story P2OB-7471
                    else if(TCPProgramoptions.includes("A Channel Partner or Distributor") && TCPSourceName==undefined){
                                helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_TCP_Source_Partner_Distributor'),'');
                    }

                        else{
                            //SaveRecord will be called at final step - Story P2OB-7585 - Ayush(Appirio)
                            component.set('v.showMessage',false);
                            component.set("v.step",4);
                            
                            
                            component.set("v.currentStep",String(4));
                            //helper.SaveRecord(component,event,helper,4)
                        }
                    window.scrollTo(0, 50);
                  component.set('v.FormCompleted',true);
                }
                else{
                    helper.showErrorMessage(component,$A.get('$Label.c.PRM_EOI_Value_Required_Error'),'');
                }
                break;
            }          
            case 4:{
                component.set("v.leadRec.Status",'Open');
                helper.SaveRecord(component,event,helper,5);
                window.scrollTo(0, 50);
                break;
            }
            default:
                // code block
        }   
    },
    handleBacknavigation : function(component, event, helper) {
        var step=component.get("v.step");
        step=step-1;
        component.set('v.step',step);
        component.set('v.currentStep',String(step));
        helper.setselectedvalues(component, event,step);
    },
    handleCancel : function(component, event, helper) {
        var url=component.get("v.CommunityUrl");
        window.open(url,'_top')
    },
    closeToast : function(component, event, helper) {
        component.set('v.showMessage',false);
    },
})