({
    doInit : function(component, event, helper) {		 
        console.log('PRMDatatabledoInit');   
        var DataTableName= console.log(component.get('v.DataTableName'));
        console.log("DataTableName1"+DataTableName);     
        console.log(component.get('v.data'));
        console.log(component.get('v.columnData'));
        //Selected row attribute contains only array of IDs
        component.set('v.columnData', component.get("v.data"));  
        var selectedRows = component.get("v.data");       
        var setRows = [];
        console.log('selectedRows[0] before'+selectedRows[0]);
        
            if(selectedRows[0]){
                setRows.push(selectedRows[0].Id);
                //console.log('selectedRows[0] after'+selectedRows[0]);
                 //component.find("datatable").set("v.selectedRows", setRows); // <-- Crashed datatable if "v.selectedRows"
                console.log('setting pre selection');  
                console.log(component.get('v.selectedRows')); 
                component.set("v.RecomondedAccId" ,selectedRows[0].Id );
                component.set("v.PartnerAccId" ,selectedRows[0].Id ); 
           }
                            
       
        component.set("v.showTable",true);

        /*
        helper.setData(component,
            component.get("v.columnData"),
            component.get("v.columns")
            );
           */
        // helper.getDataHelper(component, event);
    },
    updateSelectedText : function(component, event, helper){
        // alert("Selected");
        console.log('**^^***'+event.getSource().get("v.text"));
        var res = event.getSource().get("v.text").split(":");
        console.log('Partner Id*****'+res[0]);
        console.log('Name*****'+res[1]);
        let obj =[] ;
        // v1.2 start
        var accName = res[1].split("*");
        var distributorId = accName[1].split("^")[1];
        var distributorName = accName[1].split("^")[0];
        console.log('distributorId*****'+distributorId+'***distributorName***'+distributorName);
        obj.push({Name:accName[0]});
        obj.push({Id:res[0]});
        component.set("v.RecomondedAccId" ,res[0]);
        component.set("v.PartnerAccId" ,res[0]);
        if(distributorId != undefined && distributorId != ''){
        	console.log('distributor*****');
            component.set("v.distributorId" ,distributorId);
            component.set("v.distributorName" ,distributorName);
        }
        component.set("v.selectedRowsDetails" ,JSON.stringify(obj) );
        component.set("v.selectedRowsList" , [res[0]]);
        // v1.2 end
        let buttn = component.find("btnContinue");
        if(buttn != undefined){
        	buttn.set('v.disabled',false);
        }
        let butn = component.find("btnContinueRec");
        if(butn != undefined){
        	butn.set('v.disabled',false);
        }
        
        /*
        var selectedRows = event.getParam('selectedRows');
                 
      //  var selectedRows = component.get("v.data");       
       // var setRows = [];
      //  console.log('selectedRows[0] before'+selectedRows[0]);
        
        
        //  console.log('selectedRows'+selectedRows);
        //  
        
        component.set("v.selectedRowsCount" ,1);
        let obj =[] ; 
        for (var i = 0; i < selectedRows.length; i++){
            obj.push({Name:selectedRows[i].Name});
            obj.push({Id:selectedRows[i].Id});
            component.set("v.RecomondedAccId" ,selectedRows[i].Id );
            component.set("v.PartnerAccId" ,selectedRows[i].Id );
        }
        component.set("v.selectedRowsDetails" ,JSON.stringify(obj) );
        component.set("v.selectedRowsList" ,event.getParam('selectedRows') );
        console.log('selectedRows');
        console.log(selectedRows);
        */
    },
    handleContinue : function(cmp, event) {
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        //alert("testhandecont");
        var appEvent = $A.get("e.c:SubmitToPartnerEvent");
        var AccId= cmp.get('v.RecomondedAccId');
        var PrimaryDistributor = cmp.get("v.distributorId"); // v1.2
        var PrimaryDistributorName = cmp.get("v.distributorName"); // v1.2
        console.log("PRMDATATABLEController handleContinue****"+AccId+'**PrimaryDistributor**'+PrimaryDistributor+'**PrimaryDistributorName**'+PrimaryDistributorName);
        appEvent.setParams({
            "IsContinue" : true,
            "ReconmondedId":AccId,
            "OverideIncumbent":false,
            "IsContinuePartner":true,
            "IsOverrideINC":false,
            "valPrimaryDistributor":PrimaryDistributor,
            "valPrimaryDistributorName":PrimaryDistributorName,
            "PartnerSelectedDetails":"{!v.selectedRowsList}" });
        appEvent.fire();
        /* $A.createComponent("c:PRMSubmitToPartnerRecordForm", {

        }, function(newCmp) {
            if (component.isValid()) {
                component.set("v.body", newCmp);
            }
        });*/
    },
    handleOveride : function(cmp, event) {
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        //alert("testhandecont");
        var appEvent = $A.get("e.c:SubmitToPartnerEvent");
        var AccId= cmp.get('v.RecomondedAccId');
        
        appEvent.setParams({
            "IsContinue" : true,
            "OverideIncumbent":true,
            "IsOverrideINC":false,
            "IsContinuePartner":false,
            "IsIncumbentBack":false,
            "IsIncumbentSave":false,
            "PartnerSelectedDetails":"{!v.selectedRowsList}" });
        appEvent.fire();
        /*  $A.createComponent("c:PRMSubmitToPartnerRecordForm", {

        }, function(newCmp) {
            if (component.isValid()) {
                component.set("v.body", newCmp);
            }
        });*/
     },
    handleCancel : function(cmp, event) {
        //Fired when cancel is clicked.
        $A.get("e.force:closeQuickAction").fire();
       /*  appEvent.setParams({
            "IsContinue" : true,
            "OverideIncumbent":true,
            "IsOverrideINC":false,
            "IsContinuePartner":false,
            "IsIncumbentBack":false,
            "IsIncumbentSave":false,
            "PartnerSelectedDetails":"{!v.selectedRowsList}" });
        appEvent.fire();
        $A.createComponent("c:PRMSubmitToPartnerRecordForm", {

        }, function(newCmp) {
            if (component.isValid()) {
                component.set("v.body", newCmp);
            }
        });*/
    },
    handleOverideINC : function(cmp, event) {
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        //alert("testhandecont");
        var appEvent = $A.get("e.c:SubmitToPartnerEvent");
        var AccId= cmp.get('v.RecomondedAccId');
        console.log("RecomondedAccIdiNC"+AccId);
        //alert("handleOverideINC");      
        //  // "IsOverrideINC":true,
        appEvent.setParams({
            "IsContinue" : true,
            "IsContinuePartner":false,
            "IsOverrideINC":true,
            "OverideIncumbent":false,
            "IsIncumbentBack":false,
            "IsIncumbentSave":false,
            "PartnerSelectedDetails":"{!v.selectedRowsList}" });
        appEvent.fire();
        
        /*$A.createComponent("c:PRMSubmitToPartnerRecordForm", {

        }, function(newCmp) {
            if (component.isValid()) {
                component.set("v.body", newCmp);
            }
        });*/
    }
    
})