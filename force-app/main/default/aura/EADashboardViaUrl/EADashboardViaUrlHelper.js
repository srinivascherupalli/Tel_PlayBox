/****************************************************************************
@Name: EA Dashboard
@Author: Mathew Horvath(Einstein Team)
@CreateDate: 03/06/2020
@Description: Sprint 20.08 ; P2OB-5864 : Original Version
              Sprint 20.10 ; P2OB-8071: Setting OpenLocation Attribute.
@Deployment  :   Pallavi B(SFO Team)
@Last Modified Date  : 15/07/2020
*****************************************************************************/
({

    setParameters: function (cmp) {
        console.warn("setting parameters.. (helper)");
        // get parameters 
        var params = {};
        // if pageReference valid, use this (if lightning component tab directly)
        if (cmp.get("v.pageReference")) {
            var state = cmp.get("v.pageReference").state;
            for (var prop in state) {
                params[prop] = state[prop];
            }

        } else {
            // otherwise extract from window url (if on page)
            var sPageURL = window.location.search.substring(1);
            var pairs = sPageURL.split("&");
            for (var i = 0; i < pairs.length; i++) {
                var pair = pairs[i].split("=");
                params[pair[0]] = decodeURIComponent(pair[1]);
            }
        }

        // check if dashboard id has been passed
        if (params.c__id) {
            var dashboardId = params.c__id;
            cmp.set("v.dashboardId", dashboardId);
        }

        // check if comma delimited string of parameters (fields) 
        var parameters;
        if (params.c__parameters)
            parameters = params.parameters;
        else
            parameters = cmp.get("v.parameters");

        // check for filter string
        var filterString;
        if (params.c__filterString)
            filterString = params.filterString;
        else
            filterString = cmp.get("v.filterString");

        var arrParameters = parameters.split(",");
        for (var i = 0; i < arrParameters.length; i++) {
            var replace = "#" + arrParameters[i] + "#";
            var re = new RegExp(replace, "g");

            var value = params["c__" + arrParameters[i]];

            filterString = filterString.replace(re, value);
        }
        cmp.set("v.filterValue", filterString);
        console.warn(filterString);


        // double check for any other parameters passed to dashboard
        if (params.c__height) {
            cmp.set("v.height", params.c__height)
        }

        if (params.c__showHeader) {
            cmp.set("v.showHeader", params.c__showHeader)
        }

        if (params.c__showTitle) {
            cmp.set("v.showTitle", params.c__showTitle)
        }

        if (params.c__openLinksInNewWindow) {
            cmp.set("v.openLinksInNewWindow", params.c__openLinksInNewWindow)
        }

        if (params.c__showSharing) {
            cmp.set("v.showSharing", params.c__showSharing)
        }

        if (params.c__openLocation) {
            cmp.set("v.openLocation", params.c__openLocation)
        }

    }
})