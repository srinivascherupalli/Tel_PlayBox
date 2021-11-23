({
    doInit: function (component, event, helper) {
        component.invocationCallbacks = {};
        var action = component.get("c.getVFBaseURL");
        action.setStorable();
        action.setCallback(this, function (response) {
            var vfBaseURL = response.getReturnValue().toLowerCase();
            component.set("v.vfBaseURL", vfBaseURL.toLowerCase());
            var topic = component.get("v.topic");
            console.log('message^^^^^');
            window.addEventListener("message", function (event) {
                if (event.origin !== vfBaseURL) {
                    console.log(event.origin+'^^^event.origin^^');
                    console.log(vfBaseURL+'^^^vfBaseURL^^');
                    // Not the expected origin: reject message
                    return;
                }
                console.log(event.data.topic);
                // Only handle messages we are interested in
                if (event.data.topic === topic) {
                    // Retrieve the callback for the specified invocation id
                    var callback = component.invocationCallbacks[event.data.invocationId];
                    if (callback && typeof callback == 'function') {
                        callback(event.data.result,event.data.error);
                        // callback(event.data.error);
                        delete component.invocationCallbacks[event.data.invocationId];
                    }
                }
            }, false);
        });
        $A.enqueueAction(action);
    },
    doInvoke: function (component, event, helper) {
        console.log('^^^^^');
        var vfBaseURL = component.get("v.vfBaseURL");
        var topic = component.get("v.topic");
        var args = event.getParam('arguments');
                console.log(args);

        var invocationId = helper.getUniqueId();
        component.invocationCallbacks[invocationId] = args.callback;
        
       
        var argvar=args.methodParams;       
        
        var pageParam= new Object();
        pageParam.pageObjectID=argvar.pageObjectID;
        pageParam.pimsAPIType=argvar.pimsAPIType;
        pageParam.pimsCallType=argvar.pimsCallType;
      
          
        var message = {
            topic: topic,
            invocationId: invocationId,
            methodName: args.methodName,
           // methodParams: args.methodParams
            methodParams: pageParam
        };
        console.log('^^^ssss^^'+vfBaseURL);
       
        var baseUrl = window.location.toString();
           console.log(baseUrl +'***baseUrl');
           console.log(baseUrl.search(/partners/)+'***baseUrl');
           var hostname = window.location.hostname;
           var lexBaseURL="https://";
           var vf;
           if(baseUrl.indexOf("/partners/")>-1){
                vf = component.find("vfFrameCommunity").getElement().contentWindow;
           }else{
                vf = component.find("vfFrame").getElement().contentWindow;
           }
         vf.postMessage(message, vfBaseURL);
       
    }
})