({
    doInitialization : function (component, event, helper) {
        var parentId=component.get("v.recordId");
        var action=component.get('c.getOpportunityFromId');
        var proposalArray=[];
        var columns = [
            {
                fieldName: 'fileUrl',
                label: 'Document Name',
                sortable: false,
                type: 'url', 
                typeAttributes: { 
                    label: {
                        fieldName: 'fileName'
                    },
                    target: '_self'
                },
            },
            {
                fieldName: 'ModifiedDate',
                label: 'Last Modified Date',
                type : 'date',
                typeAttributes: {  
                    day: 'numeric',  
                    month: 'short',  
                    year: 'numeric',  
                    hour: '2-digit',  
                    minute: '2-digit',  
                    second: '2-digit',
                    hour12: false
                },
                sortable: true
            }
        ];      
        component.set('v.columns', columns);
        var title="Proposal Documents";
        action.setParams({
            oppId : parentId
        });
        action.setCallback(this,function(response){     
            var state=response.getState();
            
            if(state==="SUCCESS")
            {
                component.set("v.totalNumberOfRows", response.getReturnValue().length);
                if(response.getReturnValue().length == 0) {
                	component.set("v.proposalNumber",title + ' ' + '(' + '0' + ')');   
                	component.set("v.proposalDetailsArray", null);    
                } else if(response.getReturnValue().length > 0 && response.getReturnValue().length <= 3) {
                    component.set("v.proposalNumber",title + ' ' + '(' + response.getReturnValue().length + ')');
                    component.set("v.proposalDetailsArray", response.getReturnValue());
                    component.set("v.offSet", component.get("v.proposalDetailsArray").length);
                } else {
                    component.set("v.proposalNumber",title + ' ' + '(' + '3+' + ')');
                    for(var i=0; i<3;i++)
                    {
                        proposalArray.push(response.getReturnValue()[i]);
                        //alert('response.getReturnValue(i)'+response.getReturnValue()[i]);
                    }
                    component.set("v.proposalDetailsArray",proposalArray);
                    component.set("v.offSet", proposalArray.length);
                }   
                console.log('&&&&&&' + component.get("v.totalNumberOfRows"));
            } 
        });
        $A.enqueueAction(action);
    },
    createProposal: function(cmp,event,helper){
        cmp.set("v.isFlowOpen",true);
    },
    handleComponentEvent: function(cmp,event,helper){
        cmp.set("v.isFlowOpen",false);
    },
    closeModel :  function(cmp,event,helper){
        cmp.set("v.isFlowOpen",false);
    },
    
    loadMoreData: function (cmp, event, helper) {
        var parentId = cmp.get("v.recordId");
        event.getSource().set("v.isLoading", true);
        cmp.set('v.loadMoreStatus', 'Loading');
        var offSet = cmp.get("v.offSet");
        var rowsToLoad = cmp.get('v.rowsToLoad');
        var action=cmp.get('c.getProposal');
        action.setParams({
            offSet : offSet,
            numberOfRows : rowsToLoad,
            oppId : parentId
        });
        action.setCallback(this,function(response){ 
            var state = response.getState();
            console.log('&&&&&&' + cmp.get('v.totalNumberOfRows'));
            console.log('******' + cmp.get('v.proposalDetailsArray').length);
            if(state==="SUCCESS")
            {
                if (cmp.get('v.proposalDetailsArray').length >= cmp.get('v.totalNumberOfRows')) {
                    cmp.set('v.enableInfiniteLoading', false);
                    cmp.set('v.loadMoreStatus', 'No more data to load');
                } else {
                    var currentData = cmp.get('v.proposalDetailsArray');
                    var newData = currentData.concat(response.getReturnValue());
                    cmp.set('v.proposalDetailsArray', newData);
                    cmp.set("v.offSet", newData.length);
                    cmp.set('v.loadMoreStatus', '');
                    //cmp.set('v.totalNumberOfRows', (cmp.get('v.totalNumberOfRows') - newData.length));
                }
                event.getSource().set("v.isLoading", false); 
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    }
})