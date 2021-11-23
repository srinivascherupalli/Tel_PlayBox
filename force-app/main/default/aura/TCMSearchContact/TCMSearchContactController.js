({  
    formatDate : function (component,expense, event, helper) {
        var str=component.find("BirthDate").get("v.value");
        component.set("v.checkDate",false);
        if(str.length!=10||(str.includes("!")||str.includes("?")||str.includes("@")||str.includes("#")||str.includes(",")||str.includes(".")||str.includes(">")||str.includes("<")||str.includes("?")||str.includes("#")||str.includes("$")||str.includes("%")||str.includes("^")||str.includes("&")||str.includes("(")||str.includes(")")||str.includes("_")||str.includes("+")||str.includes("|")||str.includes("~")||str.includes("`")||str.includes("{")||str.includes("}")||str.includes("[")||str.includes("]")||str.includes("=")))
        {	
        	component.set("v.checkDate",true);

        }
    },
    
    showSpinner : function (component,expense, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    hideSpinner : function (component,expense, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
    // @Description : EDGE-3858|Javascript method to validate Email @Author : Shambo Ray
    validateEmail : function(component, event, helper) {
       
		var isValidEmail = true; 
        var emailField = component.find("email");
        var emailFieldValue = emailField.get("v.value");
       
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
     
        if(!$A.util.isEmpty(emailFieldValue)){   
            if(emailFieldValue.match(regExpEmailformat)){
			  emailField.set("v.errors", [{message: null}]);
              $A.util.removeClass(emailField, 'slds-has-error');
              component.set("v.message", '');
              //component.set("v.nmfld",false);  
              isValidEmail = true;
        }else{
             $A.util.addClass(emailField, 'slds-has-error');
             emailField.set("v.errors", [{message: "Valid Email is Like  ab@xyz.com"}]);
             component.set("v.message", 'Please Enter A Valid Email Address');
             //component.set("v.nmfld",true);	
             isValidEmail = false;
        }
       }
         else{
             emailField.set("v.errors", [{message: null}]); 
             component.set("v.message", '');
             //component.set("v.nmfld",false);  
        }
        
    
	},
    // @Description : EDGE-3858|Javascript method to validate LastName @Author : Shambo Ray
        validateString: function(component, event, helper){
            
            helper.helperValidateString(component, event, helper);
            
        },
      
    
      // @Description : EDGE-3858|Javascript method to validate FirstName @Author : Shambo Ray
      validateStringfname: function(component, event, helper){
          
          helper.helperValidateStringfname(component, event, helper);
          
      },
      
    Clear:function(component,expense){
        component.set("v.prev",false);
        component.set("v.next",false);
        component.set("v.clearflag",true);
        
        component.set("v.expenses","");
        component.set("v.message","");
        component.set("v.checkDate",false);
        component.find("firstname").set("v.value","");
        component.find("firstname").set("v.errors",[{message: null}]);
        component.find("Lastname").set("v.value","");
        component.find("Lastname").set("v.errors",[{message: null}]);
       
        component.find("BirthDate").set("v.value","");
        component.find("email").set("v.value","");
        component.find("email").set("v.errors",[{message: null}]);
       
        //component.find("fnn").set("v.value","");
	}   ,
   tcmSearch: function(component, expense) {
    var validExpense = true;
    var nameField = component.find("firstname");
    var firstname = nameField.get("v.value");
    var lastnameField = component.find("Lastname");
    var lastname = lastnameField.get("v.value");
    var birthDateField = component.find("BirthDate");
    var birthDate = birthDateField.get("v.value");
    var emailField = component.find("email");
    var emailid = emailField.get("v.value");
    //var uuidfield = component.find("uuid");
    var uuid = '';
       //Commented As EDGE-76 is cancelled:In Future When TCM Is Ready It May Require
        /*if(!$A.util.isEmpty(firstname) && !$A.util.isEmpty(lastname) && !$A.util.isEmpty(birthDate)){
			 component.set("v.message", '');
         	 validExpense = true;            
        }      
        else if(!$A.util.isEmpty(firstname) && !$A.util.isEmpty(lastname) && !$A.util.isEmpty(birthDate) && !$A.util.isEmpty(emailid) )
        {	 component.set("v.message", '');
         	 validExpense = true;   
            
        }
        else if($A.util.isEmpty(firstname) && $A.util.isEmpty(lastname) && $A.util.isEmpty(birthDate) && !$A.util.isEmpty(emailid) ){
                 component.set("v.message", '');
         	 	 validExpense = true;   
            }
        
            else{
                
          component.set("v.message", 'Please provide valid search criteria valid combinations are First name, Last Name and DOB or First Name, Last Name, DOB and Work Email or Work Email (only)');                                                               
          validExpense = false;
          component.set("v.errDivv",false);  
                
            }*/
       
     if((!$A.util.isEmpty(firstname) && !$A.util.isEmpty(lastname)&&$A.util.isEmpty(emailid) && $A.util.isEmpty(birthDate))
     || (!$A.util.isEmpty(emailid) && $A.util.isEmpty(firstname) && $A.util.isEmpty(lastname)&&$A.util.isEmpty(birthDate)) 
     || (!$A.util.isEmpty(birthDate)&& $A.util.isEmpty(emailid) && $A.util.isEmpty(firstname) && $A.util.isEmpty(lastname)) 
     || (!$A.util.isEmpty(birthDate) && !$A.util.isEmpty(lastname)&& $A.util.isEmpty(emailid) && $A.util.isEmpty(firstname)))
     {
         component.set("v.message", '');
         validExpense = true;
         component.set("v.errDivv",true);
         
     }
     else
       {
          component.set("v.message", 'TCM Search cannot be performed due to invalid combination of fields.Check using valid combination of fields.');                                                               
          validExpense = false;
          component.set("v.errDivv",false);                                                            
           
       }  
       
   
       
	 if(JSON.stringify(lastnameField.get("v.errors"))!='[{"message":null}]' && !$A.util.isEmpty(lastname)){
            //alert(JSON.stringify(lastnameField.get("v.errors")));
        	validExpense=false;
        	component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }     
    if(JSON.stringify(emailField.get("v.errors"))!='[{"message":null}]' && !$A.util.isEmpty(emailid)){
            //alert(JSON.stringify(emailField.get("v.errors")));
        	validExpense=false;
        	component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }  
    if(JSON.stringify(nameField.get("v.errors"))!='[{"message":null}]' && !$A.util.isEmpty(firstname)){
            //alert(JSON.stringify(emailField.get("v.errors")));
        	validExpense=false;
        	component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }
    if(component.get("v.checkDate")){
           validExpense=false;
           component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');   
       }
        
    if(validExpense){ 
    
  	var na=[];
    component.set("v.expenses", na);
    
        
    var action = component.get("c.getStartSearch");
  	
    action.setParams({
        "fname": firstname,
        "lname": lastname,
        "bdate": birthDate,
        "email" :emailid
        
    });    
    action.setCallback(this, function(response){
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
            var result = response.getReturnValue();
             
            if(result.data != null){
                	 
                     if(result.data.paging!=null&&result.data.paging.offset!='0')
                                {	//alert("in 2");
                                    component.set("v.next", true);
                                }
                     if(result.data.paging!=null&&result.data.paging.offset=='0')
                                {	//alert("in 3");
                                    component.set("v.prev", true);
                                    
                                }
                     if(result.data.paging!=null&&result.data.paging.offset=='0'&& result.data.paging.lastPage=='Y')
                                {
                                    component.set("v.prev", true);
                                    component.set("v.next", true);
                                    //component.set("v.flag", true); 
                                }  
                component.set("v.expenses", result.data.contacts);
                component.set("v.errDivv",true); 
            }
            else {
                 component.set("v.message", 'This Contact cannot be found in TCM - Follow new Contact Creation process');
                 component.set("v.expenses",'');
                 component.set("v.errDivv",false); 
            }
            //component.set("v.expenses", response.getReturnValue());
        }
        else if(component.isValid() && state === "ERROR"){
           component.set("v.message", response.getError()[0].message);
            
        }
    
    });
    $A.enqueueAction(action);
    }
},
Next:function(cmp,event,helper){
      
        var next = true;
        var prev = false;
        var nameField = cmp.find("firstname");
        var firstname = nameField.get("v.value");
        var lastnameField = cmp.find("Lastname");
        var lastname = lastnameField.get("v.value");
        var birthDateField = cmp.find("BirthDate");
        var birthDate = birthDateField.get("v.value");
        var emailField = cmp.find("email");
        var emailid = emailField.get("v.value");
        //var uuidfield = cmp.find("uuid");
        //var uuid = uuidfield.get("v.value");
        var uuid = '';
        helper.dotcmsearch(cmp,next,prev,firstname,lastname,birthDate,emailid,uuid); 
    },
Previous:function(cmp,event,helper){
        var next = false;
        var prev = true;
        var nameField = cmp.find("firstname");
        var firstname = nameField.get("v.value");
        var lastnameField = cmp.find("Lastname");
        var lastname = lastnameField.get("v.value");
        var birthDateField = cmp.find("BirthDate");
        var birthDate = birthDateField.get("v.value");
        var emailField = cmp.find("email");
        var emailid = emailField.get("v.value");
        //var uuidfield = cmp.find("uuid");
        //var uuid = uuidfield.get("v.value");
        var uuid = '';
        helper.dotcmsearch(cmp,next,prev,firstname,lastname,birthDate,emailid,uuid); 
},    
    
checkboxSelect : function(component, event, helper) {
    	
	var selectedRec = event.getSource().get("v.value");
    var getAllId = component.find("boxPack");
    var tabname = event.getSource();
   console.log(getAllId);
    if(getAllId.length != undefined){
  		for (var i = 0; i < getAllId.length ; i++) {
       	if (getAllId[i].get("v.value") == true) {
        	getAllId[i].set("v.value", false);
        }
      }
     } 
    event.getSource().set("v.value", true);	
	},
    
  
 importContact: function(component, event, helper) {
      var impid = [] ;
      //var getAllId = [];
      var getAllId = component.find("boxPack");
      console.log(getAllId.length);
     if(getAllId.length != undefined){
   	  console.log( component.find("boxPack")[0].get("v.value"));
      for (var i = 0; i < getAllId.length ; i++) {
       if (getAllId[i].get("v.value") == true) {
        impid.push(getAllId[i].get("v.text"));
       }
      }
     } else{
          impid.push(getAllId.get("v.text"));
     }
     // impid.push(getAllId.get("v.text"));
      console.log(impid);
      helper.insertselectedContact(component, event, impid);
     
 },    
})