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
    doinit: function(component, event, helper) {
        //console.log('loadingSpinner');
        component.set("v.loadingSpinner", true);
        setTimeout(function() {
            component.set("v.loadingSpinner", false);
        }, 3000);
        component.set("v.gridColumns", helper.getColumnDefinitions1(component));
        var productBasket=component.get("v.ProdBasket");
        if(productBasket!=null && productBasket.Transition_basket_stage__c=='Check Eligibility Completed')//added for edge-90448
        {
            component.set("v.hideCheckboxColumn",true);
        }else
            component.set("v.hideCheckboxColumn",false);
        
    },      
    getGetLegacyServices : function(component,event,helper){
        //This function fetches the details of the available services for all the sites in the basket 
        //and return services correponding selected site
		////added for edge -90448
		var paramsS = event.getParam('arguments');
      //  alert('&&&&&&&&&&&---->'+JSON.stringify(paramsS.selectedRecord));
		var productBasket=component.get("v.ProdBasket");  
        console.log('productBasket.Transition_basket_stage__c'+productBasket.Transition_basket_stage__c);
        if(productBasket.Transition_basket_stage__c=='Check Eligibility Completed')//added for edge-90448
        {
            component.set("v.hideCheckboxColumn",true);
        }else{
            component.set("v.hideCheckboxColumn",false);
        }
        document.getElementById("GetServicesCmp").style.display = "block";
        var adborid = component.get('v.adborid');
        console.log('Adborid-->'+adborid);
        if(adborid)
        { 
            var sitesMap_V2 = component.get('v.sitesMap_V2');
            var data = component.get('v.sites_new');
          //  alert('&&&&&&&&&&&---->'+JSON.stringify(data));
            console.log('site mapv2-->'+JSON.stringify(sitesMap_V2));
            if(sitesMap_V2!= null && sitesMap_V2 && sitesMap_V2[adborid] && sitesMap_V2[adborid]!='undefined')
            {
                component.set('v.noService',false);              
                component.set("v.sitesValue_V2",sitesMap_V2[adborid]);
                //console.log('inside if sitesMap_V2-->');
                var productlist=component.get('v.sitesValue_V2.productList');
                if(productlist!=null && productlist!='')
                {
                    component.set('v.checkService',true);
                    component.set("v.siteCount", data.serviceCount);
                    var productList = component.get('v.sitesValue_V2.productList');
                    var action2=component.get('c.initializeGridDataMap');
                    action2.setCallback(this, function(response) {
                        component.set('v.gridDataMap', response.getReturnValue());
                    });
                    $A.enqueueAction(action2);
                     var sitesValue_V2=component.get('v.sitesValue_V2');
                    //component.set("v.loadingSpinner", true);
                    var selecteddata=component.find("transitionserviceTable");
                    //helper.handleSelectedProductList(component,event,helper);
                    var selectedProd=component.get("v.selectedProd");
                    //console.log('selectedProd list-->'+JSON.stringify(selectedProd));
                    component.set("v.loadingSpinner", true);
                    var action=component.get('c.getServicesTablewrapper');
                    var resdata;
                    var toUpdateData= [];
                    action.setParams({
                        "sitesValue_V2":sitesValue_V2
                    });
                    action.setCallback(this, function(response) {
                        if(response.getState()=='SUCCESS'){
                            resdata = response.getReturnValue();     
                        }
                        if(resdata!=null){
                            var selectedRows=[];
                            var girdDataMap = new Map();
                            resdata.forEach(function(element) {
                                var childList=[];
                                if (element.product=='PSTN' || element.product=='ISDN2DID' ||  element.product=='ISDN-BRA' || element.product=='ISDN2') {
                                    if(element.checkValue==true)
                                    {
                                        selectedRows.push(element.keyProduct);
                                        var selectedProdvalue=adborid+'-'+element.product;
                                        if(selectedProd.indexOf(selectedProdvalue) ==-1){
                                            selectedProd.push(selectedProdvalue);
                                        }
                                    }
                                    if(element.Children !=null)
                                    {
                                        element.Children.forEach(function(child){
                                            //selectedRows.push(child.product);
                                            if(element.checkValue==true)
                                            {
                                                child.checkValue=true;
                                                selectedRows.push(child.keyProduct);
                                            }
                                            childList.push(child.product);
                                            
                                            if(child.Children !=null){
                                                child.Children.forEach(function(grandChild){	
                                                    if(element.checkValue==true)
                                                {
                                                     selectedRows.push(grandChild.keyProduct);
                                                        grandChild.checkValue=true;
                                                }   
                                                    childList.push(grandChild.product);
                                                });
                                            }
                                        });
                                    }
                                    
                                }
                                girdDataMap.set(element,childList);	
                                toUpdateData.push(element);
                            }
                                        );
                            var temojson = JSON.parse(JSON.stringify(toUpdateData).split('Children').join('_children'));               
                            //component.set("v.loadingSpinner", false);
                            component.set("v.gridData", temojson);					
                            selecteddata.set("v.selectedRows", selectedRows);
                            //console.log('selectedRows_11'+JSON.stringify(selectedRows));
                            selecteddata.set("v.expandedRows", selectedRows);
                            component.set("v.gridExpandedRows",selectedRows);
                            component.set("v.gridDataMap",girdDataMap);  
                        }
                        component.set("v.selectedProd",selectedProd);
                        component.find("transitionserviceTable").expandAll();
                        component.set("v.loadingSpinner", false);                        
                    });
                    $A.enqueueAction(action);
                    //helper.HandleCheckValueOnProductSelectDeselect(component,event,helper);
                }else
                {
                    component.set('v.noService',true);
                    component.set('v.checkService',false);
                    component.set("v.sitesValue_V2",sitesMap_V2[adborid]);
                }
                
            }else
			{
				component.set('v.noService',true);
				component.set('v.checkService',false);
				//component.set("v.sitesValue_V2",sitesMap_V2[adborid]);
			}
            
        }
         component.set("v.lcoadingSpinner", false); 
        
    },
    displayNone : function(component, event, helper) {
        document.getElementById("GetServicesCmp").style.display = "none";
    },
    handleRowselection : function(component,event,helper){
        var productBasket=component.get("v.ProdBasket"); 
        /*        
        var selectedRowsArray = 
        var allData=dTable.get("v.data");
        var finalSelection=[];
        var childMap2=new Map();
        childMap2 = component.get("v.gridDataMap");
        var adborid = component.get('v.adborid');*/
        var selectedProd = component.get("v.selectedProd");
        var dTable = component.find("transitionserviceTable");
        var selectedRow=dTable.getSelectedRows();//added for 99048
       // alert(JSON.stringify(selectedProd));
        console.log('handle slectt-->'+JSON.stringify(selectedRow));
        var selectedRow1=dTable.get("v.selectedRows");//added for 99048
        console.log('handle slectt11-->'+JSON.stringify(selectedRow1));
        var selectedProdAdborid=[]; 
        //added for edge -90448
        //console.log('productBasket.Transition_basket_stage__c'+productBasket.Transition_basket_stage__c);
        if(productBasket.Transition_basket_stage__c!='Check Eligibility Completed')//added for edge-90448
        {	                      
                if(selectedRow.length>0)
                    helper.handlechildSelectDeselect(component,event,helper);           		
            	else
                    console.log('inside else');
            
        }else{
            component.set("v.hideCheckboxColumn",true);//added for 99048
        } 
        helper.HandleCheckValueOnProductSelectDeselect(component,event,helper); //added for 99048 
        helper.passSelectedProdHelper(component, event, helper);//added for 99048
    },
    //to pass selected products from child to parent using event
    passSelectedProd : function(component, event, helper) {
        helper.passSelectedProdHelper(component, event, helper);
        
    },
    ontoggleEvent : function(component,event,helper){
    	 helper.handlechildSelectDeselect(component,event,helper);
	}
})