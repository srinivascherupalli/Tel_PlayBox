/*--------------------------------------------------------------------------------------
Name : PaginationHelper
Description : Lightning UI Helper for implementing pagination
Author: Aishwarya Yeware
Story: EDGE-80858
--------------------------------------------------------------------------------------------------*/

({
    /*---------------------------------------------------------------------------------------
    Name : getrecords
    Description : Method to retrive records
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/
	getrecords : function(component,startNumber,EndNumber,compName){
        var listofrecords=[];
        var recordData=component.get('v.data');
        var i=startNumber;
        for(i;i<EndNumber;i++){
           listofrecords.push(recordData[i]); 
        }
        component.set("v.StartRec",startNumber + 1);
        component.set("v.endRec",EndNumber);
        var appEvent = $A.get("e.c:paginationEvent");
       
        //Set event attribute value
        //Start of EDGE-148577: adding componentName from which it is fired
        appEvent.setParams({"PageData" : listofrecords,
                            "Alldata": recordData,
                            "StartRecord" : startNumber + 1,
                            "EndRecord" : EndNumber,
                            "CurrentPage" : component.get('v.CurrentPage'),
                            "TotalPages" : component.get('v.TotalPages'),
                            "PageSize" : component.get('v.PageSize'),
                            "TotalRecords" :component.get('v.data').length,
                            "componentName":compName
        }); 
        //End of EDGE-148577
        appEvent.fire(); 
    }
})