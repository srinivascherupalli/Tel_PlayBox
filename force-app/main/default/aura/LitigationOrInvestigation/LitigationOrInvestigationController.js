({
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    doInit: function(component,event,helper) {
    	var action=component.get("c.getData");
        console.log('--- rec id'+component.get("v.recordId"));
        action.setParams({"fieldSetname":component.get("v.FieldsetName"),
                          "recordid":component.get("v.recordId")
                          });
        var p = helper.executeAction(component, action);
             
            // use the promise to do something 
            p.then($A.getCallback(function(result){
                console.log(result);
                component.set("v.queAndAns",result);
                var action1=component.get("c.getData");
        		action1.setParams({"fieldSetname":'Litigation_1',
                          "recordid":component.get("v.recordId")
                          });
                var Promise1=helper.executeAction(component, action1);
            	return Promise1;
                
            })).then($A.getCallback(function(result){
                console.log(result);
                component.set("v.queAndAnsLitigation1",result);
                var action2=component.get("c.getData");
        		action2.setParams({"fieldSetname":'Litigation_2',
                          "recordid":component.get("v.recordId")
                          });
                var Promise2=helper.executeAction(component, action2);
            	return Promise2;
                
            })).then($A.getCallback(function(result){
                component.set("v.queAndAnsLitigation2",result);
                var action3=component.get("c.getData");
        		action3.setParams({"fieldSetname":'Litigation_3',
                          "recordid":component.get("v.recordId")
                          });
                var Promise3=helper.executeAction(component, action3);
            	return Promise3;
                
            })).then($A.getCallback(function(result){
                component.set("v.queAndAnsLitigation3",result);
                var action4=component.get("c.getData");
        		action4.setParams({"fieldSetname":'Investigation_1',
                          "recordid":component.get("v.recordId")
                          });
                var Promise4=helper.executeAction(component, action4);
            	return Promise4;
                
            })).then($A.getCallback(function(result){
                component.set("v.queAndAnsInvestigation1",result);
                var action5=component.get("c.getData");
        		action5.setParams({"fieldSetname":'Investigation_2',
                          "recordid":component.get("v.recordId")
                          });
                var Promise5=helper.executeAction(component, action5);
            	return Promise5;
                
            })).then($A.getCallback(function(result){
                component.set("v.queAndAnsInvestigation2",result);
                var action6=component.get("c.getData");
        		action6.setParams({"fieldSetname":'Investigation_3',
                          "recordid":component.get("v.recordId")
                          });
                var Promise6=helper.executeAction(component, action6);
            	return Promise6;
                
            })).then($A.getCallback(function(result){
                component.set("v.queAndAnsInvestigation3",result);
                var action7=component.get("c.getData");
        		action7.setParams({"fieldSetname":'Investigation',
                          "recordid":component.get("v.recordId")
                          });
                var Promise7=helper.executeAction(component, action7);
            	return Promise7;
            })).then($A.getCallback(function(result){
                component.set("v.queAndAnsInvestigation",result);
                var action8=component.get("c.getData");
        		action8.setParams({"fieldSetname":'Investigation_Questions',
                          "recordid":component.get("v.recordId")
                          });
                var Promise8=helper.executeAction(component, action8);
            	return Promise8;
                          
            })).then($A.getCallback(function(result){
                component.set("v.QuestionsInvestigation",result);
                                          
            })).catch(
        $A.getCallback(function(error){
            // Something went wrong
            alert('An error occurred : ' + error.message);
        })
     );
        
    }
})