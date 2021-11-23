({
   
   doInit : function(cmp, event, helper){
         var pageRef = cmp.get("v.pageReference");
         var recordIdTemp = pageRef && pageRef.state ? pageRef.state.c__recordId : '';
         cmp.set("v.recordId", recordIdTemp); 
         var optionFlag = pageRef && pageRef.state ? pageRef.state.c__assignOption : '';
         cmp.set("v.assignOption", atob(optionFlag)); 
         helper.toggle(cmp, event);      
         helper.fetchAllLinkedCases(cmp,event);
   },
   cancelClick : function(cmp,event, helper){
      var workspaceAPI = cmp.find("workspace");
      workspaceAPI.isConsoleNavigation().then(function(response) {
         if(response == true){
            workspaceAPI.getFocusedTabInfo().then(function(response){
               workspaceAPI.closeTab({tabId:response.tabId});
            })
            .catch(function(error){
                console.log(error);
            });
         }else{
             window.close();
         }
      });
   },

   assignCases : function(cmp,event, helper){

      var _selectedRowsDetails = cmp.get("v.selectedRowsDetails");
      
      if(_selectedRowsDetails.length == 0){    
         helper.showToastMessage(cmp, event, "warning", "Warning", "Please select at least one case to be assigned to you.");
         return;
      }

      helper.toggle(cmp, event);

      var _action = cmp.get('c.assignCasesToUser');
      _action.setParams({
         "caseIDS":_selectedRowsDetails
      });
      _action.setCallback(this, function(res){
         console.log('res statte '+res.getState());
         helper.toggle(cmp, event);

         if(res.getState() =='SUCCESS'){
            console.log(res.getReturnValue());        
            helper.fetchAllLinkedCases(cmp,event);
            helper.showToastMessage(cmp, event, "success", "Success!", "Records assigned successfully !");
         }else{
            helper.showToastMessage(cmp, event, "error", "Error", "Error occurred while processing request "+res.getReturnValue());
         }
      });
      $A.enqueueAction(_action);
   },

   storeSelectedRows : function(cmp,event,helper){
      var _selectedRows = event.getParam("selectedRows");
      cmp.set("v.selectedRows", _selectedRows);
      var obj =[] ; 
      for (var i = 0; i < _selectedRows.length; i++){       
         obj.push(_selectedRows[i].Id);
      }

      cmp.set("v.selectedRowsDetails" ,obj);
   }
 })