import { LightningElement } from 'lwc';
import {parentComponent, info, warn, debug, error, flushLogs}
from 'c/frontEndTxnLog';

export default class FrontEndLoggerTest extends LightningElement {

  renderedCallback() {
    parentComponent('FrontEndLoggerTest');
  }
  infoClick(event) {
    info('Dummy info message');
  }
  debugClick(event) {
    debug('Dummy debug message');
  }
  warnClick(event) {
    warn('Dummy warn message');
  }
  errorClick(event) {
    let errorObject = new Object();
  
    errorObject.message    = 'errorDescription';
    errorObject.level      = 'ERROR';
    errorObject.loggerName = 'componentName';
    errorObject.timestamp  = 'new Date().toLocaleString()';
    errorObject.severity = 'LOW';
    errorObject.interfaceName = 'interfaceName';
    errorObject.elementName = 'elementName';
    errorObject.referenceNumber = 'referenceNumber';
    errorObject.capability = 'TestLabel';
    errorObject.endPointURL = 'endPointURL';
    errorObject.integrationPayload = 'integrationPayload';
    errorObject.correlationID = 'correlationID';
    errorObject.httpStatusCode = 'httpStatusCode';
    errorObject.errorCode = 'errorCode';
    errorObject.errorDescription = 'errorDescription is High Error';
    errorObject.responseMessage = 'responseMessage';
    errorObject.destinationSystem = 'destinationSystem';
    errorObject.sourceName = 'OTHERS';
    errorObject.businessDescription = 'businessDescription';
    errorObject.errorCategory = 'errorCategory';
    errorObject.exceptionUUID = 'correlationID';    

    error(errorObject);
  }
  flushClick(event) {
    flushLogs('newGuid');
  }
  
}