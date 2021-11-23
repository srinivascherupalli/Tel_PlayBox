({
	doInit : function(component, event, helper) {
        //debugger;
        //var pagesize=component.get('v.PageSize');
        //var recordsCount=component.get('v.columns');
		//component.set("v.TotalPages", Math.ceil(recordsCount /pagesize));
		
          component.set('v.CurrentPage',1);
       
	},
    //Method to handle Next functionality
    handleNext : function(component,event,helper){
       // var previousPage=component.get('CurrentPage');
        var currentPage=(component.get('v.CurrentPage')*component.get('v.PageSize'));
        var endPage=currentPage+component.get('v.PageSize')>component.get('v.data').length?component.get('v.data').length:currentPage+component.get('v.PageSize');
        //helper.getrecords(component,currentPage,endPage);
        //component.set('v.PreviousPage',previousPage);
        var currPage=component.get('v.CurrentPage') +1;
        component.set('v.CurrentPage',currPage);
        //Start of EDGE-148577: componentName from which it is fired
        var compName = component.get('v.componentName');
        helper.getrecords(component,currentPage,endPage,compName);
        //End of EDGE-148577
    },
    //Method to handle previous functionality
    handlePrevious : function(component,event,helper){
        var currentPage=(component.get('v.CurrentPage')-1)*component.get('v.PageSize')-component.get('v.PageSize');
        var endPage=currentPage+component.get('v.PageSize');
        component.set('v.CurrentPage',component.get('v.CurrentPage')-1);
        //Start of EDGE-148577: componentName from which it is fired
        var compName = component.get('v.componentName');
        helper.getrecords(component,currentPage,endPage,compName);
        //End of EDGE-148577
    },
    //method to handle display first page records
    handleFirst : function(component,event,helper){
        var pagesize=component.get('v.PageSize');
        component.set('v.CurrentPage',1);
        //Start of EDGE-148577: componentName from which it is fired
        var compName = component.get('v.componentName');
        helper.getrecords(component,0,pagesize,compName);
        //End of EDGE-148577
    },
    //method to handle display last page records
    handleLast : function(component,event,helper){
        var currentPage=(component.get('v.TotalPages')*component.get('v.PageSize'))-component.get('v.PageSize');
        var endPage=component.get('v.data').length;
        component.set('v.CurrentPage',component.get('v.TotalPages'));
        //Start of EDGE-148577: componentName from which it is fired
        var compName = component.get('v.componentName');
        helper.getrecords(component,currentPage,endPage,compName);
        //End of EDGE-148577
    },
    //get initial parent data for pagination
    getParentData :function(component,event,helper){
        
        var pagesize=component.get('v.PageSize');
        component.set('v.data',event.getParam("Alldata"));
        component.set("v.TotalPages", Math.ceil(event.getParam("Alldata").length /pagesize));
        component.set("v.totalRecs",event.getParam("Alldata").length);
        var endNumber;
        if(event.getParam("Alldata").length>pagesize){
            endNumber=pagesize;
        }else{
            endNumber=event.getParam("Alldata").length;
        }
        helper.getrecords(component,0,endNumber);
    }
})