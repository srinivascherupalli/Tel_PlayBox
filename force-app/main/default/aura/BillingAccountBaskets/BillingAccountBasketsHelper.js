({
    //EDGE:153317:Display active baskets in related list andOpens the basket page on click of basket Name
    fetchActiveBaskets: function(component, event) {

        var showActiveBasket= [];

        var url = "";
        url = window.location.href;
        var communitySiteId = false;
        if (url.includes("partners.enterprise.telstra.com.au")) {
            communitySiteId = true;
        } else if (url.includes("partners")) {
            communitySiteId = true;
        }
        var action = component.get("c.fetchActiveBaskets");
        action.setParams({

            'billingaccId': component.get("v.billingACCid")

        });
        // set call back
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                if (communitySiteId) {
                    records.forEach(function(record){
                        record.linkName = '/partners/s/detail/'+record.Id;
                        url=record.linkName
                    });
                }
                else{
                    records.forEach(function(record){
                        record.linkName = '/'+record.Id;
                    });
                }
                component.set("v.listOfActiveBaskets", records);

                if(records.length >5){
                    records.length=5;
                    for(var i=0;i<records.length;i++){
                         showActiveBasket.push(records[i]);
                    }
                    component.set("v.viewFewActiveBaskets", showActiveBasket);
                }else{
                    component.set("v.viewFewActiveBaskets", records);
                }

            } 
        });
        // enqueue the server side action
        $A.enqueueAction(action);

    },
     getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
      	var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

})