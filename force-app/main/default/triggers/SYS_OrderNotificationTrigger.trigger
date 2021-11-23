/*
	Author: Dunna, Uday Kumar
	Date: 14/09/2021
*/

trigger SYS_OrderNotificationTrigger on OrderNotification__e (after insert) {  
    new SYS_OrderNotificationTriggerHandler().run();
  }