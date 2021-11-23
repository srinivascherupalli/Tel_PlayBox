/*******************************
EDGE-119161
Author:Ila 
**********************************/
({
    doInit : function(component, event, helper){
         helper.fetchsqList(component, event,helper);
	},
    
    checkSq: function(component, event, helper){
        helper.checkSq(component, event, helper);
    },
    
    handleRowAction: function(component, event, helper){
        var selectedRow=event.getParam('selectedRows');
        var setRows=[];
        setRows.push(selectedRow[0]);
        component.set("v.Techtype", setRows[0].Techtype);
        console.log('tech' ,setRows[0].Techtype);
    },
    showCheckButton:function(component, event, helper){
        var sqList=component.get("v.sqList");
        for(var i=0; i<sqList.length;i++){
            var sq=sqList[i];
            if(sq.isSelected){
                component.set("v.isenabled",true);
                component.set("v.technologyType",sq.techType);
                break;
            }
        }
}
})