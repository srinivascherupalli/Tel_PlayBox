({
    startTimer : function(component, event, helper) {
        //var countDownDate = new Date(component.get("v.endTime"));
        var now = new Date().getTime();
        var endtime = now + (60000*component.get("v.durationTime"));
        console.log(endtime);
        // Update the count down every 1 second
        var timer = setInterval(function() {
            
            // Get todays date and time
            var now = new Date().getTime();
            console.log(now);
            // Find the distance between now and the count down date
            var distance = endtime - now;
            
            // Time calculations for days, hours, minutes and seconds
            var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            // Display the result in the element with id="demo"
            //var timeLeft =  hours + "h " + minutes + "m " + seconds + "s ";
            var timeLeft =  "0" + minutes + ":" + seconds ;
            component.set("v.timeLeft", timeLeft);
            if(minutes == '00' && seconds == '00'){
                console.log('Time completed');
                clearInterval(timer);
                var cmpEvent = component.getEvent("countdownevent");
                //cmpEvent.fire();
                var cmpEvent = component.getEvent("resetNumbermgmtForm");
                cmpEvent.fire();
            }
        }, 1000);
    }
})