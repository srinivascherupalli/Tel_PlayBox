/**
* @Description : EDGE 36. Customer Search By lightning
* @Author : Shambo Ray
* @Date : 11/11/2017
* @Story : EDGE-36
* @Changes : DEFECT FIXES- 19/11/2017
* @Changes : DEFECT - P2OB-4921 18/02/2020 - Megha 
* @Changes : P2OB-10414 - Update invalid search error message - Dheeraj
*/

({ dotcmSearch: function(component,expense,lastname,abn,acn,cac,cidn,birthDate,email,masterId,prev,next) {
    
    var validExpense = true;
var offset=component.get("v.offset");
    
        
                                                                                                                                                                                                        
    if(validExpense)
      {  
         component.set("v.errDiv",true);
    
         var na = [];
         var size=[];
          
          component.set("v.expenses", na);
          var action = component.get("c.getTCMSearch");
        action.setParams({
            "lname": lastname,
            "abn": abn,
            "bdate": birthDate,
            "email": email,
            "acn": acn,
            "cac": cac,
            "cidn": cidn,
            "masterId": masterId,
            
            "offset":offset,
            "prev":prev,
            "next":next
            
          
            
            
        });
      
            action.setCallback(this, function(response)
            {
            
                
             var state = response.getState();
           
             if (state === "SUCCESS") 
             {
                   
            var result = JSON.parse(response.getReturnValue());
           
            console.log('Result'+result);
             if (result==null || result.length==0 ){
                    
                     component.set("v.message","No matching record has been found. Please try again");
                     component.set("v.errDiv",false); 
                 }
              else
              {   
                  console.log('test'+JSON.stringify(result.data));
                  if(result.data!=null)
                  {   
                      if(result.data.paging.offset==0){
                         
                          var k=parseInt(result.data.paging.offset);
                          k=k+1;
                          
                          component.set("v.offset", result.data.paging.offset);
                          size.push('  Page '+k+':');
                          size.push('Showing records from '+k);
                          size.push('To '+parseInt(result.data.paging.resultBlockSize));
                          
                          component.set("v.listsize",size.join(" "));
                          if(k==1){
                              component.set("v.prev",true);
                          }                      
                          
                      }
                        
                        else if(result.data.paging.offset!=null && result.data.paging.offset!=0){
                         
                            
                            component.set("v.offset", result.data.paging.offset);
                            var k=parseInt(result.data.paging.offset)/parseInt(result.data.paging.resultBlockSize);
                            k=k+1;
                            var m=parseInt(result.data.paging.offset)+1;
                            var l=parseInt(result.data.paging.offset)+parseInt(result.data.paging.resultBlockSize);
                                
                            
                            size.push('  Page '+k+':');
                            size.push('Showing Records From '+m);
                            size.push('To '+l);
                            component.set("v.listsize",size.join(" "));
                             } 
                      
                    if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset!='0')
                    {
                    component.set("v.next", true);
                    }
                    if(result.data!=null&&result.data.paging!=null)
                    {
                    component.set("v.prev", false);
                    }            
                      if(k==1){
                          component.set("v.prev",true);
                      }  
                      
                      
                      component.set("v.expenses",result.data.customers);
                                    
                     
                  }
                  else
                  {    component.set("v.expenses","");
                       component.set("v.message","No matching record has been found. Please try again");
                       component.set("v.errDiv",false); 
                  }
                 
              }  
              
              
            }
             
          
            
            else if(state === "ERROR")
            {
                
               component.set("v.message", response.getError()[0].message);
            }
        
        });
     $A.enqueueAction(action);
      
  }},
  
  dotcmSearchPRM: function(component,expense,lastname,abn,acn,cidn,prev,next) {
    
    var validExpense = true;
var offset=component.get("v.offset");
    var inputCIDN = component.find('cidnPRM');
    var CIDNValue = inputCIDN.get('v.value');
    
    var inputLastName = component.find('LastnamePRM');
    var lastNameValue = inputLastName.get('v.value');
    
    var inputabn = component.find('abnPRM');
    var abnValue = inputabn.get('v.value');
    
    var inputacn = component.find('acnPRM');
    var acnValue = inputacn.get('v.value');
      
      if(validExpense)
      {  
         component.set("v.errDiv",true);
    
         var na = [];
         var size=[];
          
          component.set("v.expenses", na);
          var action = component.get("c.getTCMSearchPRM");
        action.setParams({
            "lname": lastname,
            "abn": abn,
            "acn": acn,
            "cidn": cidn,
           
            "offset":offset,
            "prev":prev,
            "next":next
            
          
            
            
        });
      
            action.setCallback(this, function(response)
            {
            
                
             var state = response.getState();
           
             if (state === "SUCCESS") 
             {
                   
            var result = JSON.parse(response.getReturnValue());
           
            console.log('Result'+result);
             if (result==null || result.length==0 ){
              /*   if(!$A.util.isEmpty(CIDNValue)){
                     component.set("v.message","No results found for" +CIDNValue".");
                     component.set("v.errDiv",false); 
                     
                 }
                 else if(!$A.util.isEmpty(lastNameValue))
                 {
                     component.set("v.message","No results found for" +lastNameValue".");
                     component.set("v.errDiv",false); 
                 }
                 else if(!$A.util.isEmpty(abnValue))
                 {
                     component.set("v.message","No results found for" +abnValue".");
                     component.set("v.errDiv",false); 
                 } 
                 else { */
                     component.set("v.message","No results found for" );
                     component.set("v.errDiv",false); 
                 
             }
              else
              {   
                  console.log('test'+JSON.stringify(result.data));
                  if(result.data!=null)
                  {   
                      if(result.data.paging.offset==0){
                         
                          var k=parseInt(result.data.paging.offset);
                          k=k+1;
                          
                          component.set("v.offset", result.data.paging.offset);
                          size.push('  Page '+k+':');
                          size.push('Showing records from '+k);
                          size.push('To '+parseInt(result.data.paging.resultBlockSize));
                          
                          component.set("v.listsize",size.join(" "));
                          if(k==1){
                              component.set("v.prev",true);
                          }                      
                          
                      }
                        
                        else if(result.data.paging.offset!=null && result.data.paging.offset!=0){
                         
                            
                            component.set("v.offset", result.data.paging.offset);
                            var k=parseInt(result.data.paging.offset)/parseInt(result.data.paging.resultBlockSize);
                            k=k+1;
                            var m=parseInt(result.data.paging.offset)+1;
                            var l=parseInt(result.data.paging.offset)+parseInt(result.data.paging.resultBlockSize);
                                
                            
                            size.push('  Page '+k+':');
                            size.push('Showing Records From '+m);
                            size.push('To '+l);
                            component.set("v.listsize",size.join(" "));
                             } 
                      
                    if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset!='0')
                    {
                    component.set("v.next", true);
                    }
                    if(result.data!=null&&result.data.paging!=null)
                    {
                    component.set("v.prev", false);
                    }            
                      if(k==1){
                          component.set("v.prev",true);
                      }  
                      
                      
                      component.set("v.expenses",result.data.customers);
                                    
                     
                  }
                  else
                  {    component.set("v.expenses","");
                       component.set("v.message","No matching record has been found. Please try again");
                       component.set("v.errDiv",false); 
                  }
                 
              }  
              
              
            }
             
          
            
            else if(state === "ERROR")
            {
                
               component.set("v.message", response.getError()[0].message);
            }
        
        });
     $A.enqueueAction(action);
      
  }},
  //MOVED TO helper.js for refactoring
  helperTCMSearch:function(component,event,helper){
    
  	var whichOne = event.getSource().getLocalId();
      
        component.set("v.whichButton", whichOne);
        if(whichOne=='button1'){
            component.set("v.clearflag",false);
        }
        
        var validExpense = true;
            
        var nameField = component.find("Lastname");
        var lastname = nameField.get("v.value");
           
        var abnField = component.find("abn");
        var abn = abnField.get("v.value");
        
            
        var acnField = component.find("acn");
        var acn = acnField.get("v.value");
        
        
        var cacField = component.find("cac");
        var cac = cacField.get("v.value");    
                
        var cidnField = component.find("cidn");
        var cidn = cidnField.get("v.value");   
            
            
        var birthDateField = component.find("birthDate");
        var birthDate = birthDateField.get("v.value");
            
        var emailField = component.find("email");
        var email = emailField.get("v.value");
                      
        var masterIdField = component.find("masterId");
        var masterId = masterIdField.get("v.value");
         
      /* var fnnField = component.find("fnn");
        var fnn = fnnField.get("v.value"); */  
      
        var offset='0';
  
        
        
        if(!$A.util.isEmpty(abn)) {
            if((!$A.util.isEmpty(acn)) ||(!$A.util.isEmpty(cac) )||(!$A.util.isEmpty(cidn)  )||(!$A.util.isEmpty(masterId))||(!$A.util.isEmpty(birthDate))){
                component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(acn)) {
            if((!$A.util.isEmpty(cac) )||(!$A.util.isEmpty(cidn))||(!$A.util.isEmpty(masterId) )||(!$A.util.isEmpty(birthDate)))
            {
                component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(masterId) ) { 
            if((!$A.util.isEmpty(lastname))|| (!$A.util.isEmpty(cidn) )||(!$A.util.isEmpty(cac) )||(!$A.util.isEmpty(birthDate)))
            {
                component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            } else {
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(cidn) ) {
            if((!$A.util.isEmpty(cac) )||(!$A.util.isEmpty(lastname) )||(!$A.util.isEmpty(birthDate))||(!$A.util.isEmpty(masterId)))
            {
                component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(cac) ) {
            if((!$A.util.isEmpty(lastname))||(!$A.util.isEmpty(birthDate))||(!$A.util.isEmpty(cidn))||(!$A.util.isEmpty(masterId)))
            {
                component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            } else {
                component.set("v.message", '');
                validExpense = true;
            }
        } 
           /* else if(!$A.util.isEmpty(fnn)) {
                if((!$A.util.isEmpty(lastname))||(!$A.util.isEmpty(birthDate) )||(!$A.util.isEmpty(cac))||(!$A.util.isEmpty(masterId))||(!$A.util.isEmpty(cidn)))
                {
                    component.set("v.message", 'TCM Search cannot be performed due to invalid combination of fields.Check using valid combination of Fields.');                                                               
                    validExpense = false;
                    component.set("v.errDiv",false);
                } else {
                    component.set("v.message", '');
                    validExpense = true;
                }
            } */
        
                else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(abn) ) || (!$A.util.isEmpty(acn) ) ||(!$A.util.isEmpty(birthDate) )) {
                    if(!$A.util.isEmpty(lastname)  && !$A.util.isEmpty(abn)){
                        component.set("v.message", '');
                        validExpense = true;
                    }
                    else if(!$A.util.isEmpty(lastname) && !$A.util.isEmpty(acn) ){
                        component.set("v.message", '');
                        validExpense = true;
                    }
                        else if(!$A.util.isEmpty(lastname) && !$A.util.isEmpty(birthDate) )
                        {
                            component.set("v.message", '');
                            validExpense = true;
                        }
                            else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(cidn)) || (!$A.util.isEmpty(cac)) || (!$A.util.isEmpty(birthDate)) || (!$A.util.isEmpty(abn)) || (!$A.util.isEmpty(acn)) || (!$A.util.isEmpty(masterId)))
                            {
                                component.set("v.message", '');
                                validExpense = true;
                            }
                                else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(cidn)) || (!$A.util.isEmpty(cac)) || (!$A.util.isEmpty(masterId))) {
                                    component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                                    validExpense = false;
                                    component.set("v.errDiv",false);
                                }
                                    else if((!$A.util.isEmpty(abn)) || (!$A.util.isEmpty(acn))||(!$A.util.isEmpty(birthDate)) && (!$A.util.isEmpty(cidn)) && (!$A.util.isEmpty(cac) ) && (!$A.util.isEmpty(masterId))) {
                                        component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                                        validExpense = false;
                                        component.set("v.errDiv",false);
                                    }
                }
                    else {
                        component.set("v.message", 'No Search Criteria Provided');                                                               
                        validExpense = false;
                        component.set("v.errDiv",false)
                    }
        
        //alert(JSON.stringify(nameField.get("v.errors")));
        if(JSON.stringify(nameField.get("v.errors"))!='[{"message":null}]' && lastname!=''){
            //alert(JSON.stringify(nameField.get("v.errors")));
        validExpense=false;
          component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }     
         if(JSON.stringify(emailField.get("v.errors"))!='[{"message":null}]' && email!=''){
            //alert(JSON.stringify(emailField.get("v.errors")));
        validExpense=false;
          component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }   
   
        if(validExpense)
          {
              component.set("v.errDiv",true);
              var na = [];
              var size=[];
              var offset="";
              component.set("v.expenses", na);
              var action = component.get("c.getTCMSearch");
              action.setParams({
                  "lname": lastname,
                  "abn": abn,
                  "bdate": birthDate,
                  "email": email,
                  "acn": acn,
                  "cac": cac,
                  "cidn": cidn,
                  "masterId": masterId
                  
                  
                 
                  
                  
                  
              });
          
              action.setCallback(this, function(response)
                                 {
                                     
                                     
                                     
            var state = response.getState();
                                     
                                     
if (state === "SUCCESS") 
                    {
                                
                        var result = JSON.parse(response.getReturnValue());
                        
                        if (result==null || result.length==0 ){
                            
                            component.set("v.message","No matching record has been found. Please try again");
                            component.set("v.errDiv",false); 
                        }
                        else
                        { 
                            if(result.data!=null)
                            {  
                                if(result.data!=null&&result.data.paging!=null)
                                {
                                  
                                    if(result.data.paging.offset==0){
                                        
                                        var k=parseInt(result.data.paging.offset);
                                        component.set("v.offset",result.data.paging.offset);
                                        k=k+1;
                                        size.push('');
                                        size.push('   Page '+k+':');
                                        size.push('Showing Records From '+k);
                                        size.push('To '+parseInt(result.data.paging.resultBlockSize));
                                        component.set("v.listsize",size.join(" "));
                                        
                                        
                                    }
                                    
                                    else if(result.data.paging.offset!=null && result.data.paging.offset!=0){
                                        var k=parseInt(result.data.paging.offset)/parseInt(result.data.paging.resultBlockSize);
                                        component.set("v.offset",result.data.paging.offset);
                                        k=k+1;
                                        var m=parseInt(result.data.paging.offset)+1;
                                        var l=parseInt(result.data.paging.offset)+parseInt(result.data.paging.resultBlockSize);
                                        size.push(''); 
                                        size.push('   Page '+k+":");
                                        size.push('Showing records from '+m);
                                        size.push('To '+l);
                                        component.set("v.listsize",size.join(" "));
                                        
                                    }
                                    
                                }
                                
                                if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset!='0')
                                { 
                                    component.set("v.next", true);
                                }
                                if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset=='0')
                                { 
                                    component.set("v.prev", true);
                                    
                                }
                                if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset=='0'&& result.data.paging.lastPage=='Y')
                                {
                                    component.set("v.flag", true); 
                                }          
                                component.set("v.advsearch",true);
                              
                                component.set("v.expenses",result.data.customers);
                                
                            }
                            else
                            {    
                             component.set("v.expenses","");
                             component.set("v.message","No matching record has been found. Please try again");
                             component.set("v.errDiv",false); 
                            }
                            
                        }  
                        
                        
                    }
                                     
                                     
                                     
else if(state === "ERROR")
                 {
                 //alert("in error");
                 component.set("v.message", response.getError()[0].message);
                 }
                                     
                                 });
$A.enqueueAction(action);
      
  }},

helperTCMSearchPRM:function(component,event,helper){
    // P2OB-4921 - Hawaii - set the attribute and display result
  	component.set("v.intsearchbutton",false);
    component.set("v.tcmsearchbutton",true);
    var whichOne3 = event.getSource().getLocalId();
      
        component.set("v.whichButton3", whichOne3);
        if(whichOne3=='button3'){
            component.set("v.clearflag",false);
        }
        
        var validExpense = true;
            
        var nameField = component.find("LastnamePRM");
        var lastname = nameField.get("v.value");
           
        var abnField = component.find("abnPRM");
        var abn = abnField.get("v.value");
        
            
        var acnField = component.find("acnPRM");
        var acn = acnField.get("v.value");
         
                
        var cidnField = component.find("cidnPRM");
        var cidn = cidnField.get("v.value");   
            
      /* var fnnField = component.find("fnn");
        var fnn = fnnField.get("v.value"); */  
      
        var offset='0';
  
        
        
        if(!$A.util.isEmpty(abn)) {
            if((!$A.util.isEmpty(acn))||(!$A.util.isEmpty(cidn))){
                component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(acn)) {
            if((!$A.util.isEmpty(cidn)))
            {
                component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        }  else if(!$A.util.isEmpty(cidn) ) {
            if((!$A.util.isEmpty(lastname) ))
            {
                component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } 
           /* else if(!$A.util.isEmpty(fnn)) {
                if((!$A.util.isEmpty(lastname))||(!$A.util.isEmpty(birthDate) )||(!$A.util.isEmpty(cac))||(!$A.util.isEmpty(masterId))||(!$A.util.isEmpty(cidn)))
                {
                    component.set("v.message", 'TCM Search cannot be performed due to invalid combination of fields.Check using valid combination of Fields.');                                                               
                    validExpense = false;
                    component.set("v.errDiv",false);
                } else {
                    component.set("v.message", '');
                    validExpense = true;
                }
            } */
        
                else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(abn) ) || (!$A.util.isEmpty(acn) )) {
                    if(!$A.util.isEmpty(lastname)  && !$A.util.isEmpty(abn)){
                        component.set("v.message", '');
                        validExpense = true;
                    }
                    else if(!$A.util.isEmpty(lastname) && !$A.util.isEmpty(acn) ){
                        component.set("v.message", '');
                        validExpense = true;
                    }
                            else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(cidn)) || (!$A.util.isEmpty(abn)) || (!$A.util.isEmpty(acn)))
                            {
                                component.set("v.message", '');
                                validExpense = true;
                            }
                                else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(cidn))) {
                                    component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                                    validExpense = false;
                                    component.set("v.errDiv",false);
                                }
                                    else if((!$A.util.isEmpty(abn)) || (!$A.util.isEmpty(acn)) && (!$A.util.isEmpty(cidn))) {
                                        component.set("v.message", 'TCM Search cannot be performed due to invalid combination of Fields.Please Check Using Valid Combination Of Fields.');                                                               
                                        validExpense = false;
                                        component.set("v.errDiv",false);
                                    }
                }
                    
                    else {
                        component.set("v.message", 'No Search Criteria Provided');                                                               
                        validExpense = false;
                        component.set("v.errDiv",false)
                    }
        
        //alert(JSON.stringify(nameField.get("v.errors")));
        if(JSON.stringify(nameField.get("v.errors"))!='[{"message":null}]' && lastname!=''){
            //alert(JSON.stringify(nameField.get("v.errors")));
        validExpense=false;
          component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }     
         
        if(validExpense)
          {
              component.set("v.errDiv",true);
              var na = [];
              var size=[];
              var offset="";
              component.set("v.expenses", na);
              var action = component.get("c.getTCMSearchPRM");
              action.setParams({
                  "lname": lastname,
                  "abn": abn,
                  "acn": acn,
                  "cidn": cidn,

                  
              });
          
              action.setCallback(this, function(response)
                                 {
                                     
                                     
                                     
            var state = response.getState();
                                     
                                     
if (state === "SUCCESS") 
                    {
                                
                        var result = JSON.parse(response.getReturnValue());
                        
                        if (result==null || result.length==0 ){
                            
                            if((!$A.util.isEmpty(lastname)) && ($A.util.isEmpty(abn)) && ($A.util.isEmpty(acn)) && ($A.util.isEmpty(cidn))){
                                         component.set("v.message","No results found for "+lastname +".");
                                         }
                                         else if((!$A.util.isEmpty(abn)) && ($A.util.isEmpty(lastname)) && ($A.util.isEmpty(acn)) && ($A.util.isEmpty(cidn))){
                                           component.set("v.message","No results found for "+abn +".");  
                                         }
                                         else if((!$A.util.isEmpty(acn)) && ($A.util.isEmpty(lastname)) && ($A.util.isEmpty(abn)) && ($A.util.isEmpty(cidn))){
                                           component.set("v.message","No results found for "+acn +".");  
                                         }
                                             else{
                                               component.set("v.message","No results found for "+cidn +".");  
                                             }
                                        
                                         
                        }
                        else
                        { 
                            if(result.data!=null)
                            {  
                                if(result.data!=null&&result.data.paging!=null)
                                {
                                  
                                    if(result.data.paging.offset==0){
                                        
                                        var k=parseInt(result.data.paging.offset);
                                        component.set("v.offset",result.data.paging.offset);
                                        k=k+1;
                                        size.push('');
                                        size.push('   Page '+k+':');
                                        size.push('Showing Records From '+k);
                                        size.push('To '+parseInt(result.data.paging.resultBlockSize));
                                        component.set("v.listsize",size.join(" "));
                                        
                                        
                                    }
                                    
                                    else if(result.data.paging.offset!=null && result.data.paging.offset!=0){
                                        var k=parseInt(result.data.paging.offset)/parseInt(result.data.paging.resultBlockSize);
                                        component.set("v.offset",result.data.paging.offset);
                                        k=k+1;
                                        var m=parseInt(result.data.paging.offset)+1;
                                        var l=parseInt(result.data.paging.offset)+parseInt(result.data.paging.resultBlockSize);
                                        size.push(''); 
                                        size.push('   Page '+k+":");
                                        size.push('Showing records from '+m);
                                        size.push('To '+l);
                                        component.set("v.listsize",size.join(" "));
                                        
                                    }
                                    
                                }
                                
                                if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset!='0')
                                { 
                                    component.set("v.next", true);
                                }
                                if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset=='0')
                                { 
                                    component.set("v.prev", true);
                                    
                                }
                                if(result.data!=null&&result.data.paging!=null&&result.data.paging.offset=='0'&& result.data.paging.lastPage=='Y')
                                {
                                    component.set("v.flag", true); 
                                }          
                                component.set("v.advsearch",true);
                              
                                component.set("v.expenses",result.data.customers);
                                
                            }
                            else
                            {    
                             component.set("v.expenses","");
                             component.set("v.message","No matching record has been found. Please try again");
                             component.set("v.errDiv",false); 
                            }
                            
                        }  
                        
                        
                    }
                                     
                                     
                                     
else if(state === "ERROR")
                 {
                 //alert("in error");
                 component.set("v.message", response.getError()[0].message);
                 }
                                     
                                 });
$A.enqueueAction(action);
      
  }},


  checkboxSelect : function(component, event, helper) {
    
var selectedRec = event.getSource().get("v.value");
    var getAllId = component.find("boxPack");
    var tabname = event.getSource();
    if(getAllId.length != undefined){
  for (var i = 0; i < getAllId.length ; i++) {
        if (getAllId[i].get("v.value") == true) {
        getAllId[i].set("v.value", false);
        }
      }
     } 
    event.getSource().set("v.value", true);      
      
      
      
  },
  //MOVED TO helper.js for refactoring
  dointernalSearch:function(component,event,helper){         
    var whichOne2 = event.getSource().getLocalId();
      
    component.set("v.whichButton2", whichOne2);
    if(whichOne2=='button2'){
            component.set("v.clearflag",false);
        }    
    
        
    var validExpense = true;
        
    var nameField = component.find("Lastname");
    var lastname = nameField.get("v.value");
        
    var abnField = component.find("abn");
    var abn = abnField.get("v.value");
     
        
    var acnField = component.find("acn");
    var acn = acnField.get("v.value");
    
    
    var cacField = component.find("cac");
    var cac = cacField.get("v.value");    
            
    var cidnField = component.find("cidn");
    var cidn = cidnField.get("v.value");   
        
        
    var birthDateField = component.find("birthDate");
    var birthDate = birthDateField.get("v.value");
        
    var emailField = component.find("email");
    var email = emailField.get("v.value");
                  
    var masterIdField = component.find("masterId");
    var masterId = masterIdField.get("v.value");
    /* 
    var fnnField = component.find("fnn");
    var fnn = fnnField.get("v.value");    
     */
        
   
    
  
     if(!$A.util.isEmpty(abn)) {
            if((!$A.util.isEmpty(acn)) ||(!$A.util.isEmpty(cac) )||(!$A.util.isEmpty(cidn)  )||(!$A.util.isEmpty(masterId))||(!$A.util.isEmpty(birthDate))){
                component.set("v.message", 'Invalid search parameters, please provide a valid search combination');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(acn)) {
            if((!$A.util.isEmpty(cac) )||(!$A.util.isEmpty(cidn))||(!$A.util.isEmpty(masterId) )||(!$A.util.isEmpty(birthDate)))
            {
                component.set("v.message", 'Invalid search parameters, please provide a valid search combination');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(masterId) ) { 
            if((!$A.util.isEmpty(lastname))|| (!$A.util.isEmpty(cidn) )||(!$A.util.isEmpty(cac) )||(!$A.util.isEmpty(birthDate)))
            {
                component.set("v.message", 'Invalid search parameters, please provide a valid search combination');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            } else {
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(cidn) ) {
            if((!$A.util.isEmpty(cac) )||(!$A.util.isEmpty(lastname) )||(!$A.util.isEmpty(birthDate))||(!$A.util.isEmpty(masterId)))
            {
                component.set("v.message", 'Invalid search parameters, please provide a valid search combination');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(cac) ) {
            if((!$A.util.isEmpty(lastname))||(!$A.util.isEmpty(birthDate))||(!$A.util.isEmpty(cidn))||(!$A.util.isEmpty(masterId)))
            {
                component.set("v.message", 'Invalid search parameters, please provide a valid search combination');                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            } else {
                component.set("v.message", '');
                validExpense = true;
            }
        }    //May be part of future story when FNN will be part of UI
            /*else if(!$A.util.isEmpty(fnn)) {
                if((!$A.util.isEmpty(lastname))||(!$A.util.isEmpty(birthDate) )||(!$A.util.isEmpty(cac))||(!$A.util.isEmpty(masterId))||(!$A.util.isEmpty(cidn)))
                {
                    component.set("v.message", 'TCM Search cannot be performed due to invalid combination of fields.Check using valid combination of fields.');                                                               
                    validExpense = false;
                    component.set("v.errDiv",false);
                } else {
                    component.set("v.message", '');
                    validExpense = true;
                }
            } */
        
                else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(abn) ) || (!$A.util.isEmpty(acn) ) ||(!$A.util.isEmpty(birthDate) )) {
                    if(!$A.util.isEmpty(lastname)  && !$A.util.isEmpty(abn)){
                        component.set("v.message", '');
                        validExpense = true;
                    }
                    else if(!$A.util.isEmpty(lastname) && !$A.util.isEmpty(acn) ){
                        component.set("v.message", '');
                        validExpense = true;
                    }
                        else if(!$A.util.isEmpty(lastname) && !$A.util.isEmpty(birthDate) )
                        {
                            component.set("v.message", '');
                            validExpense = true;
                        }
                            else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(cidn)) || (!$A.util.isEmpty(cac)) || (!$A.util.isEmpty(birthDate)) || (!$A.util.isEmpty(abn)) || (!$A.util.isEmpty(acn)) || (!$A.util.isEmpty(masterId)))
                            {
                                component.set("v.message", '');
                                validExpense = true;
                            }
                                else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(cidn)) || (!$A.util.isEmpty(cac)) || (!$A.util.isEmpty(masterId))) {
                                    component.set("v.message", 'Invalid search parameters, please provide a valid search combination');                                                               
                                    validExpense = false;
                                    component.set("v.errDiv",false);
                                }
                                    else if((!$A.util.isEmpty(abn)) || (!$A.util.isEmpty(acn))||(!$A.util.isEmpty(birthDate)) && (!$A.util.isEmpty(cidn)) && (!$A.util.isEmpty(cac) ) && (!$A.util.isEmpty(masterId))) {
                                        component.set("v.message", 'Invalid search parameters, please provide a valid search combination');                                                               
                                        validExpense = false;
                                        component.set("v.errDiv",false);
                                    }
                }
                    else {
                        component.set("v.message", 'No Search Criteria Provided');                                                               
                        validExpense = false;
                        component.set("v.errDiv",false)
                    }     
  
        
        if(JSON.stringify(nameField.get("v.errors"))!='[{"message":null}]' && lastname!=''){
            //alert(JSON.stringify(nameField.get("v.errors")));
        validExpense=false;
          component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }     
         if(JSON.stringify(emailField.get("v.errors"))!='[{"message":null}]' && email!=''){
            //alert(JSON.stringify(emailField.get("v.errors")));
        validExpense=false;
          component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }   
            
        
                                                                                                                                                                                                        
    if(validExpense)
      {
         component.set("v.errDiv",true);
         //alert("it is a valid data");
          var na = [];
          component.set("v.expenses1", na);
          var action = component.get("c.getinternalSearch");
          action.setParams({
              "lname": lastname,
              "abn": abn,
              "bdate": birthDate,
              "email": email,
              "acn": acn,
              "cac": cac,
              "cidn": cidn,
              "masterId": masterId
             
              
              
              
          });
      
          action.setCallback(this, function(response)
                             {
                                 var state = response.getState();
                                 //alert('rrr==' + state);
                                 if (state === "SUCCESS") 
                                 {  
                                     var result = response.getReturnValue();
                                     //alert('rrr=' + result);
                                     var expenses = [];
                                     var pgsize=[];
                                     if (result==null || result.length==0  ){
                                         component.set("v.message","No Records Found.Please Search In TCM!");
                                     }
                                     for (var i=0; i<result.length;i++)
                                     {
                                         var detailtemp = {};
                                         
                                         detailtemp = { 'sobjectType': 'Account','Id': '','CIDN__c':'','Name':'','ABN__c':'','ACN__c':'','Data_Sovereign_Status__c':'','birthDate__c':'','Type':'','Business_Unit__c':''};
                                         detailtemp.Name = result[i].Name;
                                         detailtemp.ABN__c = result[i].ABN__c;
                                         detailtemp.ACN__c = result[i].ACN__c;
                                         //detailtemp.Email = result[i].Customer_Status__c;
                                         //detailtemp.BirthDate = result[i].TCM_MasterID__c;
                                         detailtemp.Id = result[i].Id;              
                                         detailtemp.CIDN__c = result[i].CIDN__c;
                                         detailtemp.Data_Sovereign_Status__c = result[i].Data_Sovereign_Status__c;
                                         detailtemp.birthDate__c=result[i].birthDate__c;
                                         detailtemp.Type=result[i].Type;
                                         detailtemp.Business_Unit__c=result[i].Business_Unit__c;
                                         expenses.push(detailtemp);
                                     } 
                                    
                                     var pageSize = component.get("v.pageSize");
                                    // hold all the records into an attribute named "ContactData"
                                    component.set("v.expenses1", expenses);
                                    // get size of all the records and then hold into an attribute "totalRecords"
                                    component.set("v.totalRecords", expenses.length);
                                    // set star as 0
                                    component.set("v.startPage",0);
                                    
                                    component.set("v.endPage",pageSize-1);
                                    var PaginationList = [];
                                    for(var i=0; i< pageSize; i++){
                                        if(expenses.length> i)
                                            PaginationList.push(expenses[i]);    
                                    }
                                    component.set('v.PaginationList', PaginationList);
                                    component.set("v.isIntSearch",true);
                                     
                                    var recs2display=[];
                                    recs2display.push('   Page '+(Math.ceil(component.get("v.endPage")/25))+":");
                                    recs2display.push("   Showing Results From ");
                                    recs2display.push(component.get("v.startPage")+1);
                                    recs2display.push("To");
                                    recs2display.push(component.get("v.PaginationList").length);
                                    recs2display.push("  ");
                                component.set("v.recs",recs2display.join(" "));
                                 }
                                 else if(component.isValid() && state === "ERROR")
                                 {
                                     component.set("v.message", response.getError()[0].message);
                                 }
                                 
                             });
          $A.enqueueAction(action);
          
          
          
      }
    
      
      
      
      
  }

  ,
  
  dointernalSearchPRM:function(component,event,helper){
    // P2OB-4921 - Hawaii - set the attribute and display result
  	component.set("v.intsearchbutton",true);
    component.set("v.tcmsearchbutton",false);    
             
    var whichOne4 = event.getSource().getLocalId();
      
    component.set("v.whichButton4", whichOne4);

    if(whichOne4=='button4'){
            component.set("v.clearflag",false);
        }    
    
        
    var validExpense = true;

    var nameField = component.find("LastnamePRM");
    var lastname = nameField.get("v.value");
      
    var abnField = component.find("abnPRM");
    var abn = abnField.get("v.value");
     
        
    var acnField = component.find("acnPRM");
    var acn = acnField.get("v.value");
     
            
    var cidnField = component.find("cidnPRM");
    var cidn = cidnField.get("v.value");   
        
    /* 
    var fnnField = component.find("fnn");
    var fnn = fnnField.get("v.value");    
     */
        
  
     if(!$A.util.isEmpty(abn)) {
            if((!$A.util.isEmpty(acn)) ||(!$A.util.isEmpty(cidn))){
                // P2OB-10414 - Update the invalid search error message on TPC in Advanced Customer Search
                component.set("v.message", $A.get("$Label.c.prmInvalidSearchErrorMessage"));                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        } else if(!$A.util.isEmpty(acn)) {
            if((!$A.util.isEmpty(cidn)))
            {
                // P2OB-10414 - Update the invalid search error message on TPC in Advanced Customer Search
                component.set("v.message", $A.get("$Label.c.prmInvalidSearchErrorMessage"));                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        }  else if(!$A.util.isEmpty(cidn) ) {
            if((!$A.util.isEmpty(lastname)))
            {
                // P2OB-10414 - Update the invalid search error message on TPC in Advanced Customer Search
                component.set("v.message", $A.get("$Label.c.prmInvalidSearchErrorMessage"));                                                               
                validExpense = false;
                component.set("v.errDiv",false);
            }else{
                component.set("v.message", '');
                validExpense = true;
            }
        }     //May be part of future story when FNN will be part of UI
            /*else if(!$A.util.isEmpty(fnn)) {
                if((!$A.util.isEmpty(lastname))||(!$A.util.isEmpty(birthDate) )||(!$A.util.isEmpty(cac))||(!$A.util.isEmpty(masterId))||(!$A.util.isEmpty(cidn)))
                {
                    component.set("v.message", 'TCM Search cannot be performed due to invalid combination of fields.Check using valid combination of fields.');                                                               
                    validExpense = false;
                    component.set("v.errDiv",false);
                } else {
                    component.set("v.message", '');
                    validExpense = true;
                }
            } */
        
                else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(abn) ) || (!$A.util.isEmpty(acn) )) {
                    if(!$A.util.isEmpty(lastname)  && !$A.util.isEmpty(abn)){
                        component.set("v.message", '');
                        validExpense = true;
                    }
                    else if(!$A.util.isEmpty(lastname) && !$A.util.isEmpty(acn) ){
                        component.set("v.message", '');
                        validExpense = true;
                    }
                           else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(cidn)) || (!$A.util.isEmpty(abn)) || (!$A.util.isEmpty(acn)))
                            {
                                component.set("v.message", '');
                                validExpense = true;
                            }
                                else if((!$A.util.isEmpty(lastname)) || (!$A.util.isEmpty(cidn))) {
                                    // P2OB-10414 - Update the invalid search error message on TPC in Advanced Customer Search
                                    component.set("v.message", $A.get("$Label.c.prmInvalidSearchErrorMessage"));                                                               
                                    validExpense = false;
                                    component.set("v.errDiv",false);
                                }
                                    else if((!$A.util.isEmpty(abn)) || (!$A.util.isEmpty(acn)) && (!$A.util.isEmpty(cidn))) {
                                        // P2OB-10414 - Update the invalid search error message on TPC in Advanced Customer Search
                                        component.set("v.message", $A.get("$Label.c.prmInvalidSearchErrorMessage"));                                                               
                                        validExpense = false;
                                        component.set("v.errDiv",false);
                                    }
                }
                    else {
                        component.set("v.message", 'No Search Criteria Provided');                                                               
                        validExpense = false;
                        component.set("v.errDiv",false)
                    }     
  
        
        if(JSON.stringify(nameField.get("v.errors"))!='[{"message":null}]' && lastname!=''){
            //alert(JSON.stringify(nameField.get("v.errors")));
        validExpense=false;
          component.set("v.message", 'Invalid search criteria. Please update search criteria and try again');
        }     
                                                                                                                                                                                                     
    if(validExpense)
      {
         component.set("v.errDiv",true);
         //alert("it is a valid data");
          var na = [];
          component.set("v.expenses1", na);
          var action = component.get("c.getinternalSearchPRM");
          action.setParams({
              "lname": lastname,
              "abn": abn,
              "acn": acn,
              "cidn": cidn,
 });
      
          action.setCallback(this, function(response)
                             {
                                 var state = response.getState();
                                 //alert('rrr==' + state);
                                 if (state === "SUCCESS") 
                                 {  
                                     var result = response.getReturnValue();
                                     var expenses = [];
                                     var pgsize=[];
                                     if (result==null || result.length==0  ){
                                          if((!$A.util.isEmpty(lastname)) && ($A.util.isEmpty(abn)) && ($A.util.isEmpty(acn)) && ($A.util.isEmpty(cidn))){
                                         component.set("v.message","No results found for "+lastname +".");
                                         }
                                         else if((!$A.util.isEmpty(abn)) && ($A.util.isEmpty(lastname)) && ($A.util.isEmpty(acn)) && ($A.util.isEmpty(cidn))){
                                           component.set("v.message","No results found for "+abn +".");  
                                         }
                                         else if((!$A.util.isEmpty(acn)) && ($A.util.isEmpty(lastname)) && ($A.util.isEmpty(abn)) && ($A.util.isEmpty(cidn))){
                                           component.set("v.message","No results found for "+acn +".");  
                                         }
                                             else{
                                               component.set("v.message","No results found for "+cidn +".");  
                                             }
                                        // component.set("v.message","No Records Found.Please Search In TCM!");
                                     }
                                     for (var i=0; i<result.length;i++)
                                     {
                                         var detailtemp = {};
                                         
                                         detailtemp = { 'sobjectType': 'Account','Id': '','CIDN__c':'','Name':'','ABN__c':'','ACN__c':'','Data_Sovereign_Status__c':'','Business_Unit__c':''};
                                         detailtemp.Name = result[i].Name;
                                         detailtemp.ABN__c = result[i].ABN__c;
                                         detailtemp.ACN__c = result[i].ACN__c;
                                         //detailtemp.Email = result[i].Customer_Status__c;
                                         //detailtemp.BirthDate = result[i].TCM_MasterID__c;
                                         detailtemp.Id = result[i].Id;              
                                         detailtemp.CIDN__c = result[i].CIDN__c;
                                         detailtemp.Data_Sovereign_Status__c = result[i].Data_Sovereign_Status__c;
                                         //detailtemp.birthDate__c=result[i].birthDate__c;
                                         //detailtemp.Type=result[i].Type;
                                         detailtemp.Business_Unit__c=result[i].Business_Unit__c;
                                         expenses.push(detailtemp);
                                         
                                     } 
                                     
                                     var pageSize = component.get("v.pageSize");
                                    // hold all the records into an attribute named "ContactData"
                                    component.set("v.expenses1", expenses);
                                     
                                    // get size of all the records and then hold into an attribute "totalRecords"
                                    component.set("v.totalRecords", expenses.length);
                                    // set star as 0
                                    component.set("v.startPage",0);
                                    
                                    component.set("v.endPage",pageSize-1);
                                    var PaginationList = [];
                                    for(var i=0; i< pageSize; i++){
                                        
                                        if(expenses.length> i)
                                            PaginationList.push(expenses[i]);    
                                    }
                                     
                                    component.set('v.PaginationList', PaginationList);
                                    component.set("v.isIntSearch",true);
                                     
                                    var recs2display=[];
                                    recs2display.push('   Page '+(Math.ceil(component.get("v.endPage")/25))+":");
                                    recs2display.push("   Showing Results From ");
                                    recs2display.push(component.get("v.startPage")+1);
                                    recs2display.push("To");
                                    recs2display.push(component.get("v.PaginationList").length);
                                    recs2display.push("  ");
                                component.set("v.recs",recs2display.join(" "));
                                 }
                                 else if(component.isValid() && state === "ERROR")
                                 {
                                     component.set("v.message", response.getError()[0].message);
                                 }
                                 
                             });
          $A.enqueueAction(action);
          
          
          
      }
    
      
      
      
      
  }

  ,

  
  helperValidateEmail:function(component,event,helper){
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
  
  helpervalidateString: function(component, event, helper){
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
  
  helpervalidateStringPRM: function(component, event, helper){
      var isValidName = true; 
        var nameField = component.find("LastnamePRM");
        
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

  insertselectedAccountContact: function(component, event, impid) {
    var action = component.get('c.accountContactSave');
    
      action.setParams({
       "lstRecordId": JSON.stringify(impid)
      });
     
      action.setCallback(this, function(response) {
       
       var arrayOfMapKeys = [];
       var state = response.getState();
       var value = '';
       var accountid = '';
              if (state === "SUCCESS") {
        
        if (response.getReturnValue() != '') {
            
         var errormap =  response.getReturnValue();
            
            for( var singlekey in errormap){
                arrayOfMapKeys.push(singlekey);
                console.log(errormap[singlekey]);
                if(errormap[singlekey] != ''){
                    value = errormap[singlekey];
                    accountid = value.substring(18);
                    value = value.substring(0,18);
                   
                    component.set("v.view", 'Done');
                    component.set("v.valueid", value);
                    component.set("v.accountid", accountid);
                              
         
          
      var urlEvent = $A.get("e.force:navigateToURL");
                    
        urlEvent.setParams({
      "url": "/lightning/r/Account/"+value+"/view"
    });
                    
                    
                    
        urlEvent.fire();
      
                    
                 }
               
          component.set("v.message", singlekey);
            }
       
  } else {
         console.log('This Customer cannot be found in TCM - Follow new Customer Creation process');
        }
        
       }
      });
     
      $A.enqueueAction(action);
    }
    
})