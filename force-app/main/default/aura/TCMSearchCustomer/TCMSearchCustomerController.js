/**
* @Description : EDGE 36. Customer Search By lightning
* @Author : Shambo Ray
* @Date : 11/11/2017
* @Story : EDGE-36
* @Changes : DEFECT FIXES- 19/11/2017,NEW STORY- @EDGE-3858- 04/12/2017,NEW STORY - @EDGE-8046- 10/01/2018
*/
({ 
     doInit : function(component, event, helper) {       
    console.log('test');
	var action = component.get("c.fetchUser");
	action.setCallback(this, function(response) {
	var state = response.getState();
	if (state === "SUCCESS") {
		var storeResponse = response.getReturnValue();
        console.log('storeResponse'+storeResponse);
		component.set("v.userInfo", storeResponse);
        component.set("v.PRMflag", true);
      }
    });
        $A.enqueueAction(action); 
    },
    
    onchange :  function (component,expense, event){
       
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
        
        if(!$A.util.isEmpty(lastname)||!$A.util.isEmpty(abn)||!$A.util.isEmpty(acn)||!$A.util.isEmpty(cac)||!$A.util.isEmpty(cidn)||!$A.util.isEmpty(birthDate)||!$A.util.isEmpty(email)||!$A.util.isEmpty(masterId))
        {
            
            component.set("v.cleardisable",false);
            
        }
        else{
            component.set("v.cleardisable",true);
        }
       
    	
	}
 	,
    
    onchangePRM :  function (component,expense, event){
       
        var nameField = component.find("LastnamePRM");
        var lastname = nameField.get("v.value");
            
        var abnField = component.find("abnPRM");
        var abn = abnField.get("v.value");
          
            
        var acnField = component.find("acnPRM");
        var acn = acnField.get("v.value");
         
                
        var cidnField = component.find("cidnPRM");
        var cidn = cidnField.get("v.value");   
            
        if(!$A.util.isEmpty(lastname)||!$A.util.isEmpty(abn)||!$A.util.isEmpty(acn)||!$A.util.isEmpty(cidn))
        {
            
            component.set("v.cleardisable",false);
            
        }
        else{
            component.set("v.cleardisable",true);
        }
       
    	
	}
 	,
    
    
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
       	
        helper.helperValidateEmail(component, event, helper);
		
    },
    
    // @Description : EDGE-3858|Javascript method to validate LastName @Author : Shambo Ray
    validateString: function(component, event, helper){
        
        helper.helpervalidateString(component, event, helper);
        
    },
    
    validateStringPRM: function(component, event, helper){
        
        helper.helpervalidateStringPRM(component, event, helper);
        
    },
    
    //moved to helper.js @10/01/2018
    internalSearch: function(component,event, helper) 
    {
        helper.dointernalSearch(component,event,helper);
		
    },
    
    internalSearchPRM: function(component,event, helper) 
    {
        helper.dointernalSearchPRM(component,event,helper);

    },
    /*
     * Method will be called when use clicks on next button and performs the 
     * calculation to show the next set of records
     */
    //EDGE-8046
   nextInternal : function(component, event){
       
        var sObjectList = component.get("v.expenses1");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
       
        
       var recs2display=[];
       recs2display.push('   Page '+(Math.ceil(component.get("v.endPage")/25))+":")
       recs2display.push("   Showing Results From ");
       recs2display.push(component.get("v.startPage")+1);
       recs2display.push("To");
       recs2display.push(component.get("v.startPage")+component.get("v.PaginationList").length);
       recs2display.push("  ");
       //alert(component.get("v.PaginationList").length);
       component.set("v.recs",recs2display.join(" "));

    },
    /*
     * Method will be called when use clicks on previous button and performs the 
     * calculation to show the previous set of records
     */
    //EDGE-8046
    prevInternal : function(component, event){
        var sObjectList = component.get("v.expenses1");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        var recs2display=[];
        recs2display.push('   Page '+(Math.ceil(component.get("v.endPage")/25))+":");
        recs2display.push("   Showing Results From ");
        recs2display.push(component.get("v.startPage")+1);
        recs2display.push("To");
        recs2display.push(component.get("v.startPage")+component.get("v.PaginationList").length);
        recs2display.push("  ");
        //alert(component.get("v.PaginationList").length);
        component.set("v.recs",recs2display.join(" "));
        
        
    },     
   	 //moved to helper.js @10/01/2018
    tcmSearch: function(component,event,helper) {
        helper.helperTCMSearch(component,event,helper);
	},
    
    tcmSearchPRM: function(component,event,helper) {
        helper.helperTCMSearchPRM(component,event,helper);
	},
    
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
    
   	importAccountContact: function(component, event, helper) {
         var impid = [] ;
         var getAllId = component.find("boxPack");
         
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
         
         helper.insertselectedAccountContact(component, event, impid);
     
 	},  
    
    
    Next:function(component,expense,helper){
        
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
        /*PART OF EDGE-36 PREVIOUSLY
        var fnnField = component.find("fnn");
        var fnn = fnnField.get("v.value");
        */
          
        var next=true;
        var prev=false;
       
        helper.dotcmSearch(component,expense,lastname,abn,acn,cac,cidn,birthDate,email,masterId,prev,next); 
    },
    
    NextPRM:function(component,expense,helper){
        
        var nameField = component.find("LastnamePRM");
        var lastname = nameField.get("v.value");
            
        var abnField = component.find("abnPRM");
        var abn = abnField.get("v.value");
          
            
        var acnField = component.find("acnPRM");
        var acn = acnField.get("v.value");   
                
        var cidnField = component.find("cidnPRM");
        var cidn = cidnField.get("v.value");   
           
        /*PART OF EDGE-36 PREVIOUSLY
        var fnnField = component.find("fnn");
        var fnn = fnnField.get("v.value");
        */
          
        var next=true;
        var prev=false;
       
        helper.dotcmSearchPRM(component,expense,lastname,abn,acn,cidn,prev,next); 
    },
    
    Clear:function(component,expense){
       	component.set("v.cleardisable",true);
        component.set("v.prev",false);
        component.set("v.next",false);
        component.set("v.flag",false);
        component.set("v.clearflag",true);
        component.set("v.expenses1","");
        component.set("v.expenses","");
        component.set("v.message","");
        component.set("v.isIntSearch",false);
        component.set("v.advsearch",false);
        component.find("abn").set("v.value","");
        component.find("Lastname").set("v.value","");
        component.find("Lastname").set("v.errors",[{message: null}]);
        component.find("acn").set("v.value","");
        component.find("cac").set("v.value","");
        component.find("cidn").set("v.value","");
        component.find("birthDate").set("v.value","");
        component.find("email").set("v.value","");
        component.find("email").set("v.errors",[{message: null}]);
        component.find("masterId").set("v.value","");
        //component.find("fnn").set("v.value","");
	}   ,
    
    
	ClearPRM:function(component,expense){
       	component.set("v.cleardisable",true);
        component.set("v.prev",false);
        component.set("v.next",false);
        component.set("v.flag",false);
        component.set("v.clearflag",true);
        component.set("v.expenses1","");
        component.set("v.expenses","");
        component.set("v.message","");
        component.set("v.isIntSearch",false);
        component.set("v.advsearch",false);
        component.find("abnPRM").set("v.value","");
        component.find("LastnamePRM").set("v.value","");
        component.find("LastnamePRM").set("v.errors",[{message: null}]);
        component.find("acnPRM").set("v.value","");
        component.find("cidnPRM").set("v.value","");
        //component.find("fnn").set("v.value","");
	}   ,
    
    
    Previous:function(component,expense,helper){
        
        
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
        var fnn = fnnField.get("v.value");*/    
        var prev=true;
        var next=false;
        helper.dotcmSearch(component,expense,lastname,abn,acn,cac,cidn,birthDate,email,masterId,prev,next); 
},   
    
    PreviousPRM:function(component,expense,helper){
        
        
        var nameField = component.find("LastnamePRM");
        var lastname = nameField.get("v.value");
            
        var abnField = component.find("abnPRM");
        var abn = abnField.get("v.value");
           
            
        var acnField = component.find("acnPRM");
        var acn = acnField.get("v.value");
            
       
        var cidnField = component.find("cidnPRM");
        var cidn = cidnField.get("v.value");   
            
       /* var fnnField = component.find("fnn");
        var fnn = fnnField.get("v.value");*/    
        var prev=true;
        var next=false;
        helper.dotcmSearchPRM(component,expense,lastname,abn,acn,cidn,prev,next); 
}   
    
})