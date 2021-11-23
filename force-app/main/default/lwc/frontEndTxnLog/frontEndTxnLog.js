/**
 * Common Javascript file used for Front End Transaction Logging
 */
 
/**
 * Importing Apex class which inserts Transaction Logs into Transaction Log object
 */
import logUITransaction from "@salesforce/apex/FrontEndTransactionLog.transactionLogFromUI";
//import logPlatformEventFromUI from "@salesforce/apex/FrontEndTransactionLog.logPlatformEventFromUI";

let componentName;
let transactionLogs = [];
 
/**
 * Function to get UI component name where transaction logging is enabled
 */
const parentComponent = (UIComponentName) => {
  componentName = UIComponentName;
}
 
/**
 * Function to get INFO log level
 */
const info = (infoLoggerMsg) => {
  let infoObject = new Object();
 
  infoObject.message    = infoLoggerMsg;
  infoObject.level      = 'INFO';
  infoObject.loggerName = componentName;
  infoObject.timestamp  = new Date().toLocaleString();
 
  transactionLogs.push(JSON.stringify(infoObject));
}
 
/**
 * Function to get WARN log level
 */
const warn = (warnLoggerMsg) => {
  let warnObject = new Object();
 
  warnObject.message    = warnLoggerMsg;
  warnObject.level      = 'WARN';
  warnObject.loggerName = componentName;
  warnObject.timestamp  = new Date().toLocaleString();
 
  transactionLogs.push(JSON.stringify(warnObject));
}

/**
 * Function to get DEBUG log level
 */
const debug = (debugLoggerMsg) => {
  let debugObject = new Object();
 
  debugObject.message    = debugLoggerMsg;
  debugObject.level      = 'DEBUG';
  debugObject.loggerName = componentName;
  debugObject.timestamp  = new Date().toLocaleString();
 
  transactionLogs.push(JSON.stringify(debugObject));
}

  const simpleError = (errorLoggerMsg) => {
    let errorObject = new Object();
  
    errorObject.message    = errorLoggerMsg;
    errorObject.level      = 'ERROR';
    errorObject.loggerName = componentName;
    errorObject.timestamp  = new Date().toLocaleString();
  
    transactionLogs.push(JSON.stringify(errorObject));
  }

  /**
  * Function to get ERROR log level with multiple details for Error
  */
  const error = (errorObject) => {
    transactionLogs.push(JSON.stringify(errorObject));
 }

/**
 * Function to call apex code to push logs into Transaction Log object
 */
const flushLogs = (UICorrelationId) => {
  logUITransaction({
    transactionLog : transactionLogs.join('\n'),
    correlationId  : UICorrelationId
  });
  transactionLogs = [];
}
 
/**
 * exporting function which can be imported in UI component
 * to enable Transaction Logging
 */
export {parentComponent, info, warn, debug, error, flushLogs}