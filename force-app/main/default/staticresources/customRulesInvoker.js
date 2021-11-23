require(['cs_js/cs-full'], function(CS) {	
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.CONFIGURATOR_READY,
		function(payload){
			setTimeout( 
				function() {
					return CS.Rules.evaluateAllRules('aftershowscreen');
				}, 500
			);
		}
	);
	
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.CONFIGURATOR_LAUNCH,
		function(payload){
			jQuery("h2:contains('The Product definition, that the Product configuration was created from, needs to be recompiled for v2.')").hide();
			jQuery("h2:contains('Product configuration has an older version of Product definition and needs to have its rules re-executed and be revalidated.')").hide();
			jQuery("h2:contains('Configuration upgrader needs to be run on the Product configuration.')").hide();
			let notifyContainer = document.getElementById("csSldsNotifyContainer");
			let notifyContainerChildren = notifyContainer.children
			var warningElement;

			for(var i = 0; i < notifyContainerChildren.length; i++){
				var notifyChild = notifyContainerChildren[i];
				if(notifyChild != undefined && notifyChild != null){
					if(notifyChild.classList.contains("cs-validation-message-box-warning"))
						warningElement = notifyChild;
				}
			}
			if(warningElement != null) {
				let warningChildren = warningElement.children;
				var warChildElement;
				for(var i = 0; i < warningChildren.length; i++){
					var warChild = warningChildren[i];
					if(warChild != undefined && warChild != null){
						if(warChild.classList.contains("slds-notify__content") && warChild.classList.contains("cs-validation-message-box-text")){
							warChildElement = warChild;
						}
					}
				}
				if(warChildElement != null){
					let divChilds = warChildElement.children;
					var shouldHideWarning = true;
					for(var i = 0; i < divChilds.length; i++){
						var divChild = divChilds[i];
						if(divChild != undefined && divChild != null){
							if(divChild.getAttribute("style") != "display: none;")
								shouldHideWarning = false;
						}	
					}
					if(shouldHideWarning)
						warningElement.setAttribute("Style", "display:none;"); 
					else 
						warningElement.removeAttribute("Style");
				}
			}
			return;
		}
	);
		
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.RULES_FINISHED,
		function(payload){ 
			jQuery("h2:contains('The Product definition, that the Product configuration was created from, needs to be recompiled for v2.')").hide();
			jQuery("h2:contains('Product configuration has an older version of Product definition and needs to have its rules re-executed and be revalidated.')").hide();
			jQuery("h2:contains('Configuration upgrader needs to be run on the Product configuration.')").hide();
			let notifyContainer = document.getElementById("csSldsNotifyContainer");
			let notifyContainerChildren = notifyContainer.children
			var warningElement;

			for(var i = 0; i < notifyContainerChildren.length; i++){
				var notifyChild = notifyContainerChildren[i];
				if(notifyChild != undefined && notifyChild != null){
					if(notifyChild.classList.contains("cs-validation-message-box-warning"))
						warningElement = notifyChild;					
				}
			}
			if(warningElement != null) {
				let warningChildren = warningElement.children;
				var warChildElement;
				for(var i = 0; i < warningChildren.length; i++){
					var warChild = warningChildren[i];
					if(warChild != undefined && warChild != null){
						if(warChild.classList.contains("slds-notify__content") && warChild.classList.contains("cs-validation-message-box-text")){
							warChildElement = warChild;
						}
					}
				}
				if(warChildElement != null){
					let divChilds = warChildElement.children;
					var shouldHideWarning = true;
					for(var i = 0; i < divChilds.length; i++){
						var divChild = divChilds[i];
						if(divChild != undefined && divChild != null){
							if(divChild.getAttribute("style") != "display: none;")
								shouldHideWarning = false;
						}	
					}
					if(shouldHideWarning)
						warningElement.setAttribute("Style", "display:none;"); 
					else
						warningElement.removeAttribute("Style");
				}
			}
			if(document.getElementsByClassName('attributeErrorMessage').length > 0  ){
				jQuery('.attributeErrorMessage').parent().prepend("<a name='error'></a>");
				jQuery('.footer-error-indicator').css({'display':'inline'});
				jQuery('.icon-error-triangle .tooltip-text').html('Review the following fields');
				jQuery('.attributeError').each(function(i) { jQuery('.icon-error-triangle .tooltip-text').append('<li>' + '<a href="#error">' + jQuery(this).siblings('label').eq(0).text() + '</a>' + '</li>'); });
				jQuery('.tooltip-text').find('a').css({color:'#ffffff'});
			}
			
			jQuery('.ribbon-error-indicator.slds-notify--toast.error-visible').hide();
			
			return;
		}
	);

	CS.EventHandler.subscribe(
		CS.EventHandler.Event.AFTER_SHOW_SCREEN_ACTION,
		function(payload){
			return CS.Rules.evaluateAllRules('aftershowscreen');
		}
	);
	
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.AFTER_NEXT_SCREEN_ACTION,
		function(payload){
			return CS.Rules.evaluateAllRules('afternextscreen');
		}
	);
	
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.AFTER_PREVIOUS_SCREEN_ACTION,
		function(payload){
			return CS.Rules.evaluateAllRules('afterpreviousscreen');
		}
	);
	
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.AFTER_CONTINUE_ACTION,
		function(payload){
			return CS.Rules.evaluateAllRules('aftercontinue');
		}
	);
	
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.AFTER_REMOVE_RELATED_PRODUCT_ACTION,
		function(payload){
			return CS.Rules.evaluateAllRules('afterremoverelatdproductaction');
		}
	);
	
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.AFTER_EDIT_RELATED_PRODUCT_ACTION,
		function(payload){
			return CS.Rules.evaluateAllRules('aftereditrelatdproductaction');
		}
	);
	
	CS.EventHandler.subscribe(
		CS.EventHandler.Event.AFTER_ADD_RELATED_PRODUCT_ACTION,
		function(payload){
			jQuery("h2:contains('The Product definition, that the Product configuration was created from, needs to be recompiled for v2.')").hide();
			jQuery("h2:contains('Product configuration has an older version of Product definition and needs to have its rules re-executed and be revalidated.')").hide();
			jQuery("h2:contains('Configuration upgrader needs to be run on the Product configuration.')").hide();
			let notifyContainer = document.getElementById("csSldsNotifyContainer");
			let notifyContainerChildren = notifyContainer.children
			var warningElement;

			for(var i = 0; i < notifyContainerChildren.length; i++){
				var notifyChild = notifyContainerChildren[i];
				if(notifyChild != undefined && notifyChild != null){
					if(notifyChild.classList.contains("cs-validation-message-box-warning"))
						warningElement = notifyChild;
				}
			}
			if(warningElement != null) {
				let warningChildren = warningElement.children;
				var warChildElement;
				for(var i = 0; i < warningChildren.length; i++){
					var warChild = warningChildren[i];
					if(warChild != undefined && warChild != null){
						if(warChild.classList.contains("slds-notify__content") && warChild.classList.contains("cs-validation-message-box-text")){
							warChildElement = warChild;
						}
					}
				}
				if(warChildElement != null){
					let divChilds = warChildElement.children;
					var shouldHideWarning = true;
					for(var i = 0; i < divChilds.length; i++){
						var divChild = divChilds[i];
						if(divChild != undefined && divChild != null){
							if(divChild.getAttribute("style") != "display: none;")
								shouldHideWarning = false;
						}	
					}
					if(shouldHideWarning)
						warningElement.setAttribute("Style", "display:none;"); 
					else 
						warningElement.removeAttribute("Style");
				}
			}
			return;
		}
	);
	CS.EventHandler.subscribeFirst(
		CS.EventHandler.Event.BEFORE_FINISH_ACTION,
			function(payload){ 
		   setTimeout(function(){
			 if(document.getElementsByClassName('attributeErrorMessage').length > 0  ){
			  jQuery('.attributeErrorMessage').parent().prepend("<a name='error'></a>");
			  jQuery('.footer-error-indicator').css({'display':'inline'});
			  jQuery('.icon-error-triangle .tooltip-text').html('Review the following fields');
			  jQuery('.attributeError').each(function(i) { jQuery('.icon-error-triangle .tooltip-text').append('<li>' + '<a href="#error">' + jQuery(this).siblings('label').eq(0).text() + '</a>' + '</li>'); });
			  jQuery('a').css({color:'#ffffff'}); 
			 }
		   },500);  
	});
});