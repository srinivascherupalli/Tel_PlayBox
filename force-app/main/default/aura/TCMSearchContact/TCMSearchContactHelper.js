({
    dotcmsearch: function(component,next,prev,firstname,lastname,birthDate,emailid,uuid) {
        var action = component.get("c.getStartSearch");
  
    action.setParams({
        "fname": firstname,
        "lname": lastname,
        "bdate": birthDate,
        "email" :emailid,
        "conuuid":uuid,
        "next" : next,
        "prev": prev
    });    
    action.setCallback(this, function(response){
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
            var result = response.getReturnValue();
            if(result.data != null){
             
            console.log('test'+JSON.stringify(response.getReturnValue()));
            
            if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset!='0'){
                component.set("v.next", true);
            }
            if(result.data!=null&&result.data.paging!=null&&result.data.paging.lastPage!='Y'){
                component.set("v.prev", true);
            }
                component.set("v.expenses", result.data.contacts);
            }
            else {
                 component.set("v.message", 'This Contact cannot be found in TCM - Follow new Contact Creation process');
            }
        }
        else if(component.isValid() && state === "ERROR"){
            component.set("v.message", response.getError()[0].message);
           
            
        }
    });
    $A.enqueueAction(action);
    },
    
    insertselectedContact: function(component, event, impid) {
    var action = component.get('c.contactsave');
    
      action.setParams({
       "lstRecordId": JSON.stringify(impid)
      });
     
      action.setCallback(this, function(response) {
       //store state of response
       var arrayOfMapKeys = [];
       var state = response.getState();
       var value = '';
       var contactid = '';
       if (state === "SUCCESS") {
        console.log(state);
        if (response.getReturnValue() != '') {
         var errormap =  response.getReturnValue();
            for( var singlekey in errormap){
                arrayOfMapKeys.push(singlekey);
                console.log(errormap[singlekey]);
                if(errormap[singlekey] != ''){
                    value = errormap[singlekey];
                    contactid = value.substring(18);
                    value = value.substring(0,18);
                    console.log(contactid);
                    console.log(value);
                    component.set("v.view", 'Done');
                    component.set("v.valueid", value);
                    component.set("v.contactid", contactid);
                 }
                 //alert(singlekey);
            	console.log(singlekey);
         		component.set("v.message", singlekey);
            }
 		} else {
         console.log('This Contact cannot be found in TCM - Follow new Customer Creation process');
        }
        
       }
      });
      $A.enqueueAction(action);
    },
    
     helperValidateString: function(component, event, helper){
        var isValidName = true; 
        var nameField = component.find("Lastname");
       	
    	var lastname = nameField.get("v.value");
        var regExpEmailformat =/[a-zA-Z]{3}[*]{1}/;
        if(!$A.util.isEmpty(lastname) && (lastname.includes("*")|| lastname.includes("!")||lastname.includes("?")||lastname.includes("@")||lastname.includes("#")||lastname.includes(",")||lastname.includes(".")||lastname.includes(">")||lastname.includes("<")||lastname.includes("/")||lastname.includes("?")||lastname.includes("#")||lastname.includes("$")||lastname.includes("%")||lastname.includes("^")||lastname.includes("&")||lastname.includes("(")||lastname.includes(")")||lastname.includes("_")||lastname.includes("-")||lastname.includes("+")||lastname.includes("|")||lastname.includes("~")||lastname.includes("`")||lastname.includes("{")||lastname.includes("}")||lastname.includes("[")||lastname.includes("]")||lastname.includes("/")||lastname.includes("="))) {
          var countOfStr=0;
          var checkSpecialChar=false;
          if(lastname.includes("*")){
              for (var i=0; i<lastname.length; i += 1) {
                  if (lastname[i] === '*') {
                      countOfStr += 1;
                  }
              }
          }
          if(lastname.includes("!")||lastname.includes("?")||lastname.includes("@")||lastname.includes("#")||lastname.includes(",")||lastname.includes(".")||lastname.includes(">")||lastname.includes("<")||lastname.includes("/")||lastname.includes("?")||lastname.includes("#")||lastname.includes("$")||lastname.includes("%")||lastname.includes("^")||lastname.includes("&")||lastname.includes("(")||lastname.includes(")")||lastname.includes("_")||lastname.includes("-")||lastname.includes("+")||lastname.includes("|")||lastname.includes("~")||lastname.includes("`")||lastname.includes("{")||lastname.includes("}")||lastname.includes("[")||lastname.includes("]")||lastname.includes("/")||lastname.includes("=")){
              checkSpecialChar=true;
          }
          if(lastname.match(regExpEmailformat) && countOfStr==1 && !checkSpecialChar){
              nameField.set("v.errors", [{message: null}]);
              $A.util.removeClass(nameField, 'slds-has-error');
              //nameField.set("v.errors", [{message: null}]);   
              isValidName = true;
              component.set("v.message", '');
              
            }
            else{
            
             $A.util.addClass(nameField, 'slds-has-error');
             nameField.set("v.errors", [{message: "Valid LastName is like abc*"}]);
             component.set("v.message", 'Special characters are invalid search parameters. Update search parameters and try again, minimum of 3 preceding characters before * are required for wild card search. Please try again');
             
             isValidName = false;
        }
        
        
    }
        else{
           nameField.set("v.errors", [{message: null}]); 
           component.set("v.message", '');
            
        }
    },
    
    
     helperValidateStringfname: function(component, event, helper){
        var isValidName = true; 
        var nameField = component.find("firstname");
       	
    	var firstname = nameField.get("v.value");
        var regExpEmailformat =/[a-zA-Z]{3}[*]{1}/;
       if(!$A.util.isEmpty(firstname) && (firstname.includes("*")|| firstname.includes("!")||firstname.includes("?")||firstname.includes("@")||firstname.includes("#")||firstname.includes(",")||firstname.includes(".")||firstname.includes(">")||firstname.includes("<")||firstname.includes("/")||firstname.includes("?")||firstname.includes("#")||firstname.includes("$")||firstname.includes("%")||firstname.includes("^")||firstname.includes("&")||firstname.includes("(")||firstname.includes(")")||firstname.includes("_")||firstname.includes("-")||firstname.includes("+")||firstname.includes("|")||firstname.includes("~")||firstname.includes("`")||firstname.includes("{")||firstname.includes("}")||firstname.includes("[")||firstname.includes("]")||firstname.includes("/")||firstname.includes("="))) {
          var countOfStr=0;
          var checkSpecialChar=false;
          if(firstname.includes("*")){
              for (var i=0; i<firstname.length; i += 1) {
                  if (firstname[i] === '*') {
                      countOfStr += 1;
                  }
              }
          }
          if(firstname.includes("!")||firstname.includes("?")||firstname.includes("@")||firstname.includes("#")||firstname.includes(",")||firstname.includes(".")||firstname.includes(">")||firstname.includes("<")||firstname.includes("/")||firstname.includes("?")||firstname.includes("#")||firstname.includes("$")||firstname.includes("%")||firstname.includes("^")||firstname.includes("&")||firstname.includes("(")||firstname.includes(")")||firstname.includes("_")||firstname.includes("-")||firstname.includes("+")||firstname.includes("|")||firstname.includes("~")||firstname.includes("`")||firstname.includes("{")||firstname.includes("}")||firstname.includes("[")||firstname.includes("]")||firstname.includes("/")||firstname.includes("=")){
              checkSpecialChar=true;
          }
          if(firstname.match(regExpEmailformat) && countOfStr==1 && !checkSpecialChar){
              nameField.set("v.errors", [{message: null}]);
              $A.util.removeClass(nameField, 'slds-has-error');
              //nameField.set("v.errors", [{message: null}]);   
              isValidName = true;
              component.set("v.message", '');
              
            }
            else{
            
             $A.util.addClass(nameField, 'slds-has-error');
             nameField.set("v.errors", [{message: "Valid FirstName is like abc*"}]);
             component.set("v.message", 'Special characters are invalid search parameters. Update search parameters and try again, minimum of 3 preceding characters before * are required for wild card search. Please try again');
             isValidName = false;
        }
        
        
    }
        else{
           nameField.set("v.errors", [{message: null}]); 
           component.set("v.message", '');
            
        }
    }, 
})