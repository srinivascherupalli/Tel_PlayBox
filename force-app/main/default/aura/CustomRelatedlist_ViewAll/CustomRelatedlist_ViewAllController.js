({
    init : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var myJSON = JSON.stringify(myPageRef);
        console.log('myPageRef'+myJSON);
        try{
            var strTitle = myPageRef.state.c__strTitle;
            component.set("v.strTitle", strTitle);
            var objectName = myPageRef.state.c__objectName;
            component.set("v.objectName", objectName);
            var headerIcon = myPageRef.state.c__headerIcon;
            component.set("v.headerIcon", headerIcon);
            var hyperlinkField = myPageRef.state.c__hyperlinkField;
            component.set("v.hyperlinkField", hyperlinkField);
            var parentObjectName = myPageRef.state.c__parentObjectName;
            component.set("v.parentObjectName", parentObjectName);
            var relationshipApiName = myPageRef.state.c__relationshipApiName;
            component.set("v.relationshipApiName", relationshipApiName);
            var paramsList = myPageRef.state.c__paramsList;
            component.set("v.paramsList", paramsList);
            var filterStr = myPageRef.state.c__filterStr;
            component.set("v.filterStr", filterStr);
            var fieldsList = myPageRef.state.c__fieldsList;
            component.set("v.fieldsList", fieldsList);
            var fieldsLabelLst = myPageRef.state.c__fieldsLabelLst;
            component.set("v.fieldsLabelLst", fieldsLabelLst);
            var parRecordId = myPageRef.state.c__parRecordId;
            component.set("v.parRecordId", parRecordId);
        }
        catch(err){
            console.log('err.message'+err.message);
        }

    }
})