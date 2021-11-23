/****************************************************************************
@Name: EA Dashboard
@Author: Mathew Horvath(Einstein Team)
@CreateDate: 03/06/2020
@Description: Sprint 20.08 ; P2OB-5864 : Original Version
              Sprint 20.10 ; P2OB-8071 : Added OpenLocation Attribute.
@Deployment  :   Pallavi B(SFO Team)
*****************************************************************************/
({
    refresh: function(cmp, evt, helper) {
        // helper.setParameters(cmp);
        location.reload();
    },
    doInit: function (cmp, evt, helper) {
        console.warn("doInit called");
        console.warn("#" + evt.getEventType() + "#");
        console.warn(cmp);


        if (evt.getEventType() == "APPLICATION") {
            console.warn("event type APPLICATION received - refreshing view")
            $A.get('e.force:refreshView').fire();

        } else {
            helper.setParameters(cmp);


        }

    }
})