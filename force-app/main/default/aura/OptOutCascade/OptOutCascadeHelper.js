({
    callServerForCasCadingAllACR : function(component, event, helper,listOfIds)  {
        //EDGE - 30617
        //var action = component.get("c.saveRecords");
        var action = component.get("c.saveAcrPreferences");
        action.setParams({
            "acrId":component.get("v.recordId"),
            "ids":listOfIds
        });
        action.setCallback(this, function(response){
            if(response.getState()=="SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration : 2500,
                    "message": $A.get("$Label.c.OptOutSuccess"),
                    type: "success" 
                });
                toastEvent.fire();
            } else if(response.getState()=="ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration : 2500,
                    "message": $A.get("$Label.c.Opt_Out_Cascade_Failed"),
                    type: "error"
                });
                toastEvent.fire();
            }
            var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
                "recordId": component.get("v.recordId")
            });
            urlEvent.fire();
         });
        $A.enqueueAction(action);
    },
    onLoad : function(component, event,helper,sortFieldName){
        var action = component.get("c.getAllAccountContactRelationRecords");
        action.setParams({
            "acrId":component.get("v.recordId"),
            "sortField": sortFieldName,
         	"sortOrder": component.get("v.isAsc")
        });
        action.setCallback(this, function(response) {
            var lst=[];
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {
                
                var result=JSON.parse(response.getReturnValue());
                if(result!=null && result!=[] && result!=''){
                    
                    for (var i=0; i<result.length;i++)
                    {
                        var detailtemp = {};
                        
                        detailtemp = { 'sobjectType': 'AccountContactRelation','Id': '','Roles':'','Name':'','Relationship_End_Date__c':'' };
                        detailtemp.Roles=result[i].Roles;
                        detailtemp.Id=result[i].Id;
                        detailtemp.Name=result[i].Account.Name;
                        detailtemp.Relationship_End_Date__c=result[i].Relationship_End_Date__c;
                        lst.push(detailtemp);
                    } 
                    
                    component.set("v.testList",lst);
                    component.set("v.lengthOfList",lst.length);
                    this.selectAllRecordsOnLoad(component, event, helper);
                    
                }
                else{
                    component.set("v.testList",[]);
                    component.set("v.message",$A.get("$Label.c.NO_ACR_FOUND"));
                    component.set("v.isEnabled",true);
                }
            }
            else{
                component.set("v.testList",[]);
                component.set("v.message",$A.get("$Label.c.Some_Error"));
                component.set("v.isEnabled",true);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    selectAllRecordsOfHelper : function(component, event,helper) {
		var getAllId = component.find("boxPackSingle");
        if(component.find("boxPack").get("v.value")){
            component.set("v.isEnabled",false);
            if(! Array.isArray(getAllId)){
                getAllId.set("v.value",true);
            }else{
                for (var i = 0; i < getAllId.length; i++) {
                    
                    getAllId[i].set("v.value",true); 
                }
                
            } 
        }
        else{
            component.set("v.isEnabled",true);
            if(! Array.isArray(getAllId)){
                getAllId.set("v.value",false);
                
            }else{
                for (var i = 0; i < getAllId.length; i++) {
                    getAllId[i].set("v.value",false);
                }
                
            } 
        }
        
    },
    selectAllRecordsOnLoad : function(component, event, helper) {
        component.find("boxPack").set("v.value",true);
        this.selectAllRecordsOfHelper(component, event,helper);
    },
    checkSingleRecordsHelper : function(component, event, helper) {
        var count=0;
        var getAllId = component.find("boxPackSingle");
        if(! Array.isArray(getAllId)){
            if(getAllId.get("v.value")!=true){
                component.find("boxPack").set("v.value",false);
                component.set("v.isEnabled",true);
            }
            else{
                component.find("boxPack").set("v.value",true);
                component.set("v.isEnabled",false);
            }
        }else{
            for (var i = 0; i < getAllId.length; i++) {
                if(getAllId[i].get("v.value")!=true){
                    component.find("boxPack").set("v.value",false);
                    
                }
                else{
                   count=count+1; 
                }
            }
            if(count==getAllId.length){
                component.find("boxPack").set("v.value",true);
                component.set("v.isEnabled",false);
            }
            if(count!=0){
                component.set("v.isEnabled",false);
            }
            else{
                component.set("v.isEnabled",true);
            }
        }
        
    },
    sortHelper: function(component, event,helper, sortFieldName) {
      if(sortFieldName.includes('Relationship_End_Date__c')){
          component.set("v.selectedTabsoft", 'Relationship_End_Date__c'); 
        }
      else if(sortFieldName.includes('Account.name')){
         component.set("v.selectedTabsoft", 'Account.name');   
        }
      var currentDir = component.get("v.arrowDirection");
      if (currentDir == 'arrowdown') {  
         component.set("v.arrowDirection", 'arrowup');
         // set the isAsc flag to true for sort in Assending order.  
         component.set("v.isAsc", "ASC");
      } else {
         component.set("v.arrowDirection", 'arrowdown');
         component.set("v.isAsc", "DESC");
      }
      this.onLoad(component, event,helper,sortFieldName);
   },
    continueButtonHelper: function(component, event,helper){
         var getAllId = component.find("boxPackSingle");
         var listOfIds=[];
         if(getAllId.length != undefined){
              for (var i = 0; i < getAllId.length ; i++) {
              if (getAllId[i].get("v.value") == true) {
                    listOfIds.push(getAllId[i].get("v.text"));
               }
              }
         } else{
              listOfIds.push(getAllId.get("v.text"));
         }
        this.callServerForCasCadingAllACR(component, event, helper,listOfIds);
    }
    
})