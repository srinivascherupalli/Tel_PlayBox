({
    doInit : function(component, event, helper) {
        var url = window.location.href;
        if(url.includes('sourceSystemUrl')){
        helper.navigateToAddressPage(component, event, helper,url);
        }
        else{
        component.set("v.addresses",null);
        component.set("v.nbnAddresses",null);
        component.find("inputAddress").set("v.value",component.get("v.inputAddress"));           
        }  
    },
    
	validateAddress : function(component, event, helper) {
        if(component.get("v.searchBy") == 'address'){
            if(component.find("inputAddress").get("v.value") == null || component.find("inputAddress").get("v.value") ==''){
                helper.showToast(component, 'Warning !', 'Please provide a valid search string');
            }else{
                helper.searchAddressFromEast(component);
                component.set("v.addressSearch", false);
        		component.set("v.loadingSpinner", true);
        		component.set("v.eastResponse", true);
        		setTimeout(function(){
            	component.set("v.loadingSpinner", false);
       			}, 3000);
            }
            component.set("v.searchByAddressFlag" ,true);
            component.set("v.searchByAdboridFlag" ,false);
            
        }
        else if(component.get("v.searchBy") == 'adborid'){
            if(component.find("inputAdborID").get("v.value") == null || component.find("inputAdborID").get("v.value") ==''){
                helper.showToast(component, 'Warning !', 'Please provide a valid/10 digit ADBORID');
            }else{
                helper.searchAddressFromNBNEast(component);
                component.set("v.addressSearch", false);
        		component.set("v.loadingSpinner", true);
        		component.set("v.eastResponse", true);
        		setTimeout(function(){
            component.set("v.loadingSpinner", false);
       }, 2000);
            }
            component.set("v.searchByAdboridFlag" ,true);
            component.set("v.searchByAddressFlag" ,false);
            
        } 	
        
    },
    
    disableTextBox : function(component, event, helper) {
        var checkSearchOption = event.getSource().get("v.text");
        if(checkSearchOption == 'adborid'){
            component.find("inputAdborID").set("v.disabled",false);
            component.find("inputAddress").set("v.disabled",true);
            component.find("inputAddress").set("v.value",'');
            component.set("v.searchBy",checkSearchOption);
        }else if (checkSearchOption == 'address'){
            component.find("inputAdborID").set("v.disabled",true);
            component.find("inputAddress").set("v.disabled",false);
            component.find("inputAdborID").set("v.value",'');
            component.set("v.searchBy",checkSearchOption);
        }
    },
    
    validateAdborIDInput : function(component, event, helper) {
       var adborid = component.get("v.inputAdborID");
       var reg = /^\d$/;
        var value="";
       for(var i=0;i<adborid.length;i++){
               if(reg.test(adborid[i])){
                    value=value+adborid[i].toString();
        		}
        }
            adborid=value; 
        	component.set('v.inputAdborID', adborid);
    },
    
    BackToSearchAddress : function(component, event, helper) {
       component.set("v.addressSearch", !component.get("v.addressSearch"));
       component.set("v.eastResponse", !component.get("v.eastResponse"));
       component.set("v.addresses",null);
       component.set("v.nbnAddresses",null);
       var searchType = component.get("v.searchBy");
        if(searchType == 'adborid'){
            component.find("inputAdborID").set("v.disabled",false);
            component.find("inputAddress").set("v.disabled",true);
            component.find("adborid").set("v.value",true);
        }
    }
    ,
    saveAddress : function(component, event, helper) {
        var idx = event.getSource().get("v.name");
        var searchType = component.get("v.searchBy");
        component.set("v.loadingSpinner", true); 
        helper.saveAddress(component, event, helper, idx,searchType);
    }
    ,
    navigateToSiteCreate : function(component, event, helper) {
        helper.cancelButtonHelper(component, event, helper);
    }
})