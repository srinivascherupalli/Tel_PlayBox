({     
    fillRateCardMap : function(component,CallingPlan,response) {
        var state = response.getState();
        if (state == "SUCCESS") {
            var res = response.getReturnValue();
            if(res){
                var rateCardMap = [];
                var rateCardList =  res.rateCardMap;
                for(var key in rateCardList){
                    rateCardMap.push({value:rateCardList[key], key:key});
                }
                console.log('rateCardMap ',res.rateCardMap);
                component.set("v.RateCardMap", rateCardMap);
                component.set("v.CallingPlan", CallingPlan);
                component.set("v.solutionType",res.solutionType);
                var columns = [];
                var cols = res.mapFromToColumnHeader;
                for(var key in cols){
                    var index = parseInt(key);
                    var val = parseInt(cols[key]);
                    columns.push({value:val, key:index});
                }
                component.set("v.ColumnHeaders", columns);
                /*if(CallingPlan == 'Right Plan'){
                    component.set("v.isRightPlan", true);
                }*/
                
            }
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    component.set('v.errorMessage',errors[0].message);
                }
            }
        }
    },

    // changes  by shashank - DIGI-37779
    toggleFeature : function(component,response) {
        //isDMSRateMatrixActive
        console.log('toggle feature ');
        // console.log('response-',response)
        var state = response.getState();
        if (state == "SUCCESS") {
            var res = response.getReturnValue();
            
				console.log('res isDMSRateMatrixActive-',res);
                component.set("v.isDMSRateMatrixActive", res);


            
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    component.set('v.errorMessage',errors[0].message);
                }
            }
        }
    },
    // changes ended by shashank - DIGI-37779
})