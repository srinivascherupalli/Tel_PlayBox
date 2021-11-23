/****************************************************************************
@Name: IdeaTrigger.
@Author: SFO/ Sri
@CreateDate: 22/10/2019
@Sprint : 19.14[P2OB-3302]
@Description: This Trigger is for Idea Object - P2OB-3302
*****************************************************************************/
trigger IdeaTrigger on Idea (before insert, 
                             before update,
                             before delete,
                             after insert,
                             after update,
                             after delete){
                                 //Implemeted Trigger framework
                                 fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
                             }