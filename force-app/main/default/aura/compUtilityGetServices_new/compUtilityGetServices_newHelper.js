/*
===============================================================================================================================
Component Name : compUtilityGetServices_new
Developer Name : Ravi
COntroller Class : CompUtilityReplicatorManager
===============================================================================================================================
Sr.No.    Developer Name       	Modified  Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     			CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/

({
    SUCCESS : 'success',
    ERROR : 'error',
	//navigate to basket
    navigateToRollCall: function(component, event, helper) {
        var urlToBasket = window.location.href;
        var occ = urlToBasket.indexOf('#');
        var actualURL = urlToBasket.substring(0, occ) + '#/sObject/' + component.get('v.basketId');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": actualURL
        });
        urlEvent.fire();
        
    },
	//show custom toast
    showCustomToast : function(cmp, message, title, type){
        $A.createComponent(
            "c:customToast",
            {
                "type" : type,
                "message" : message,
                "title" : title
            },
            function(customComp, status, error){
                if(status === "SUCCESS"){
                    var body = cmp.find("container");
                    body.set("v.body", customComp);
                }
                else if(status === "INCOMPLETE"){
                    console.log("No resonse");
                }
                else if(status === "ERROR"){
                    console.log("Error : " + error);
                }   
            }
        );
    },
	//method to display tree grid columns
    getColumnDefinitions1: function (component) {
		//var icon = component.get("v.iconName");
		var columns = [
			{
                type: 'text',
                fieldName: 'product',
                label: 'Product',
                initialWidth: 300
            },
            {
                type: 'text',
                fieldName: 'eligibilityStatus',
                label: 'Eligibility',
                initialWidth: 200,
                cellAttributes: 
             	{                   
                 	"iconName": {
                        "fieldName": "iconName" ,
                        "size":"x-small"
                    }
            	}
                
            },
            {
                type: 'text',
                fieldName: 'eligibilityReason',
                label: 'Reason',
                initialWidth: 300
            },
		];
		return columns;
	},
	//Handle Check Value On Product Select and Deselect
	HandleCheckValueOnProductSelectDeselect: function(component,event,helper,adborid){
	    var sitesMap=component.get("v.sitesMap_V2");
        var adborid1=component.get("v.adborid");
		var product=component.get("v.selectedProd");
		var action=component.get('c.HandleCheckValueOnProductSelectDeselect');
		action.setParams({
			sitesMap_v2: sitesMap,
			selectedProduct:product,
            adborid:adborid1
		});
		action.setCallback(this, function(response) {
			if(response.getState()=='SUCCESS'){
				var mapData=response.getReturnValue();
            	console.log('site mapv2 heplr2-->'+JSON.stringify(mapData));
				component.set("v.sitesMap_V2",mapData);
			}else
			{
			    console.log('Inside handle check site map v2 error');
			}
		});
		 $A.enqueueAction(action); 
         //this.reviewConfirmDisabledHelper(component,event,helper);  
         this.passSelectedProdHelper(component,event,helper);
	},
            //to pass event data 
    passSelectedProdHelper : function(component, event, helper) {
        var siteMapv2 = component.get("v.sitesMap_V2");
        // alert(JSON.stringify('******@@@@@@@>'+JSON.stringify(siteMapv2)));
        var adborId = component.get("v.adborid");        
        var selectedProd = component.get("v.selectedProd");
        var getSelectedProd = $A.get("e.c:GetSelectedProduct");
        getSelectedProd.setParams({
            "selectedProduct"   : selectedProd,
            "sitesMap_V2" : siteMapv2
        });
        getSelectedProd.fire();        
    },
   	//to handle slection of child on selection of parent
    handlechildSelectDeselect: function(component, event, helper){
         var dTable = component.find("transitionserviceTable");
         var allData=dTable.get("v.data");
         var slectedRows=dTable.get("v.selectedRows");
         var slectedRowsArray=dTable.getSelectedRows();
         var expandedRows=dTable.getCurrentExpandedRows();
         var finalselection=[];
        //var slectedRowsJson=JSON.stringify(slectedRows);
        var expanededRowsJson=JSON.stringify(expandedRows);
        var adborid = component.get("v.adborid");
        console.log('adborid'+adborid);
        var selectedRows=[];
        var slectedRowsJson='';
        //console.log(slectedRowsArray);
        //console.log(slectedRows);
        if(slectedRowsArray.length>0)
        {
         	console.log('inside if'+JSON.stringify(slectedRowsArray));
            //console.log('slectedRowsJson'+slectedRowsJson);
            slectedRowsArray.forEach(function (s){
                //console.log('s-->'+JSON.stringify(s));
                if(s.keyProduct==adborid+'-ISDN2'){
                   s.keyProduct=adborid+'-ISND';
                    //console.log('s after-->'+JSON.stringify(s));
                }
                 selectedRows.push(s);
            }); 	
        }
        else
        {
            console.log('inside else'+JSON.stringify(slectedRows));
            slectedRows.forEach(function(s){
               //console.log('s-->'+JSON.stringify(s));
               if(s==adborid+'-ISDN2'){
                  s=adborid+'-ISND';
                   //console.log('s after-->'+JSON.stringify(s));
               }
               selectedRows.push(s);
            });
        
        	
        }
        	slectedRowsJson=JSON.stringify(selectedRows);
        	console.log('slectedRowsJson'+slectedRowsJson);
            allData.forEach(function(element){
                if(element.product=='ISDN2'){// added for edge 90448
                    	element.product='ISND';
                	}
                if(slectedRowsJson.includes(element.product))
                {
                    
                    if(element.product!='ISDN' && (element.product=='PSTN' || element.product=='ISDN-BRA'|| element.product=='ISND' || element.product=='ISDN2DID'))
                    {
						finalselection.push(element.keyProduct);                        
                        if(element._children!=null)
                        {
                            element._children.forEach(function(child)
                            { 
                                finalselection.push(child.keyProduct);
                                if(child._children!=null)
                                {
                                    child._children.forEach(function(grandchild)
                                    {
                                         finalselection.push(grandchild.keyProduct);
                                    });
                                }
                            });
                        }
                    }
                        
                }
                if(element.product=='ISND'){
                    element.product='ISDN2';
                }
            
            });
        
        dTable.set("v.selectedRows", finalselection);
        console.log('selectedRow-->'+JSON.stringify(finalselection));
        var selectedProd = component.get("v.selectedProd");
        var selectedProdAdborid=[]; 
        for (var i = 0; i < finalselection.length; i++) {
            if (finalselection[i] != null) {
                if (finalselection[i]==adborid+'-PSTN' || finalselection[i]==adborid+'-ISDN-BRA' || finalselection[i]==adborid+'-ISDN2' || finalselection[i]==adborid+'-ISDN2DID') {					
                    //console.log('finalselection[i]'+JSON.stringify(finalselection[i]));                    
                    var selectedProdvalue=finalselection[i];
                    selectedProdAdborid.push(selectedProdvalue);
                    if(selectedProd.indexOf(selectedProdvalue) ==-1){
                        selectedProd.push(selectedProdvalue);
                    }
                }
            }
        }
        if(selectedProd!=undefined && selectedProd!=null){
            selectedProd.forEach(function (element){
                if(element!=undefined){
                    if(element.includes(adborid)){
                        if(!selectedProdAdborid.includes(element)){
                            selectedProd.splice(selectedProd.indexOf(element),1);
                        }
                    }
                }
            });
         }
         this.HandleCheckValueOnProductSelectDeselect(component,event,helper);      
    },
    //added for 99048 to update selectedProd attribute
    handleSelectedProductList: function(component,event,helper){
        var siteMapv2 = component.get("v.sitesMap_V2");
        var action=component.get('c.HandleCheckValueOnProductSelectDeselect');
		action.setParams({
			sitesMap_v2: siteMapv2
		});
		action.setCallback(this, function(response) {
			if(response.getState()=='SUCCESS'){
				var Listprod=response.getReturnValue();
            	component.set("v.selectedProd",Listprod);
			}else
			{
			    console.log('Inside handle check site map v2 error');
			}
		});
		 $A.enqueueAction(action);     
    }
})