/**
 * A basic pub-sub mechanism for sibling component communication
 *
 * TODO - adopt standard flexipage sibling communication mechanism when it's available.
 * Modifications : 
 * 1. 10-August-2020 : Team Hawaii : Ritika Jaiswal : P2OB-7583,P2OB-8434 : Using the PubSub for passing ArticleDetails across components on the same community-page.
 */

const events = {};

/**
 * Confirm that two page references have the same attributes
 * @param {object} pageRef1 - The first page reference
 * @param {object} pageRef2 - The second page reference
 */
const samePageRef = (pageRef1, pageRef2) => {
    //P2OB-8434, P2OB-7583 : Adding a check to prevent error when component cannot pass pageReference
    if(pageRef1 && pageRef2){
    const obj1 = pageRef1.attributes;
    const obj2 = pageRef2.attributes;
    return Object.keys(obj1)
        .concat(Object.keys(obj2))
        .every(key => {
            return obj1[key] === obj2[key];
        });
    }
};

/**
 * JIRA : P2OB-8434, P2OB-7583 : Confirm that two page references match, where pageReference is the page-URL passed as a string 
 * @param  {String} pageRef1 - The first page reference
 * @param  {String} pageRef2 - The second page reference
 */
const sameSourcePage = (pageRef1, pageRef2) => {	
    var result = false;
    if(pageRef1 && pageRef2){  
        result = (pageRef1 === pageRef2);
    }	
      return result;	      	
  };

  /**
 * JIRA : P2OB-8434, P2OB-7583 : Provide a way for listeners to register using their page-URL. This can be used with Aura-Components placed on community-pages. 
 * @param {String} eventName - Event to which listener want to register, for recieving updates
 * @param {Method} callback - Reference of the method of listener, which should be executed on callback
 * @param {Object} thisArg - Reference of the component
 * @param {String} pageURL - Page URL to indicate source of listener 
 */
  const registerListenerwithURL = (eventName, callback, thisArg ,pageURL) => {	
      console.log('Display all listeners', events);
    if (!pageURL) {	
         throw new Error(	
            'pubsub listeners need a pageURL'	
        );	
    }	
    if (!events[eventName]) {	
        events[eventName] = [];	
    }	
    const duplicate = events[eventName].find(listener => {      	
       return listener.callback === callback && listener.pageURL === pageURL && listener.thisArg === thisArg;      	
    });	
    if (!duplicate) {      	
        events[eventName].push({ callback, thisArg, pageURL });	
    }	
};	



/**
 * Registers a callback for an event
 * @param {string} eventName - Name of the event to listen for.
 * @param {function} callback - Function to invoke when said event is fired.
 * @param {object} thisArg - The value to be passed as the this parameter to the callback function is bound.
 */
const registerListener = (eventName, callback, thisArg) => {
    // Checking that the listener has a pageRef property. We rely on that property for filtering purpose in fireEvent()
    if (!thisArg.pageRef) {
        throw new Error(
            'pubsub listeners need a "@wire(CurrentPageReference) pageRef" property'
        );
    }

    if (!events[eventName]) {
        events[eventName] = [];
    }
    const duplicate = events[eventName].find(listener => {
        return listener.callback === callback && listener.thisArg === thisArg;
    });
    if (!duplicate) {
        events[eventName].push({ callback, thisArg });
    }
};

/**
 * Unregisters a callback for an event
 * @param {string} eventName - Name of the event to unregister from.
 * @param {function} callback - Function to unregister.
 * @param {object} thisArg - The value to be passed as the this parameter to the callback function is bound.
 */
const unregisterListener = (eventName, callback, thisArg) => {
    if (events[eventName]) {
        events[eventName] = events[eventName].filter(
            listener =>
                listener.callback !== callback || listener.thisArg !== thisArg
        );
    }
};

/**
 * Unregisters all event listeners bound to an object.
 * @param {object} thisArg - All the callbacks bound to this object will be removed.
 */
const unregisterAllListeners = thisArg => {
    Object.keys(events).forEach(eventName => {
        events[eventName] = events[eventName].filter(
            listener => listener.thisArg !== thisArg
        );
    });
};

/**
 * Fires an event to listeners.
 * @param {object} pageRef - Reference of the page that represents the event scope.
 * @param {string} eventName - Name of the event to fire.
 * @param {*} payload - Payload of the event to fire.
 */
const fireEvent = (pageRef, eventName, payload) => {
    if (events[eventName]) {
        //Get listeners registered for the given event
        const listeners = events[eventName];
        listeners.forEach(listener => {
            if (samePageRef(pageRef, listener.thisArg.pageRef)) {
                try {
                    listener.callback.call(listener.thisArg, payload);
                } catch (error) {
                    console.log('***Telstra:prmPubSub:FireEvent:failure in callback',error);
                }
            }
            //P2OB-8434, P2OB-7583 : Callback to listeners registered using PageURL
            if(sameSourcePage(pageRef,listener.pageURL)){
                try {
                    listener.callback.call(listener.thisArg, listener.thisArg, payload);
                } catch (error) {
                    console.log('***Telstra:prmPubSub:FireEvent:failure in callback',error);
                }
            }
        });
    }
};

export {
    registerListener,
    unregisterListener,
    unregisterAllListeners,
    fireEvent,	
    registerListenerwithURL
};