({
	
   doInit : function(component, event, helper) {
     var OTPphone= component.get("v.phonenumber");
       if(OTPphone){
             //document.getElementById("phone").value=OTPphone;
               		//console.log("OTPphone@@"+OTPphone);
       }
       


},
    handleemailvalidation : function(component, event, helper) {       
        var email=component.get("v.leadRec.Email");  
        var invalidemail='';
        var re = new RegExp(/^([\w-\.]+@(?!gmail.com)(?!yahoo.com)(?!hotmail.com)(?!yahoo.co.in)(?!aol.com)(?!abc.com)(?!xyz.com)(?!pqr.com)(?!rediffmail.com)(?!live.com)(?!outlook.com)(?!me.com)(?!msn.com)(?!ymail.com)([\w-]+\.)+[\w-]{2,4})?$/);
         if (!re.test(email))
            invalidemail=true;
        else
        	invalidemail=false;
        
        var allValid = component.find('Leadform').reduce(function (validFields, inputCmp) {
            //inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        
               		console.log("allValid"+allValid);

        
           //Event to Show toast message when email is personal email
            var appEvent = $A.get("e.c:PRMEOIEvent");
       		console.log("firing");
        	appEvent.setParams({
            "InvalidEmail" : invalidemail
            });
        	appEvent.fire(); 
        
           
    },
    validatePhone : function(component, event, helper) {       
       
    },
    
    

         
})