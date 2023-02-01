/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger CountOpenTasks on Task (after insert, after update, after delete) {
    
    ID Recordtype = [SELECT Id FROM RecordType WHERE Name ='United States' LIMIT 1].Id;
  
    List<Account> rltdAccounts = [SELECT Id, RecordTypeID, Type, Open_Tasks_Email__c, Open_Tasks_Call__c, Open_Tasks_Meeting__c, Open_Tasks_Other__c                                 
                                  FROM Account WHERE Type = 'Prospect' AND RecordTypeID = :Recordtype LIMIT 5000];
    
    List<Task> openTasks = [SELECT Id, WhatId, Status, Type FROM Task WHERE WhatId != null  AND Type != null AND Status != 'Completed' LIMIT 5000];
  
  	Integer openEmailTask = 0;
  	Integer openCallTask = 0;
  	Integer openMeetingTask = 0;
  	Integer openOtherTask = 0;
    
  Map<Id, Account> updatedAccounts = new Map<Id, Account>();
  
  for (Account acc : rltdAccounts) {
          for (Task tsk : openTasks) {
              if (tsk.WhatId == acc.Id) {
                  if (tsk.Status != 'Completed') {
                      if (tsk.Type == 'Email') {
                          openEmailTask++;
                      } else if (tsk.Type == 'Call') {
                          openCallTask = 0;
                          openCallTask++;
                      } else if (tsk.Type == 'Meeting') {
                          openMeetingTask++;
                      } else {
                          openOtherTask++;
                      }
                  } else {
                      if (tsk.Type == 'Email') {
                          openEmailTask--;
                      } else if (tsk.Type == 'Call') {
                          openCallTask--;
                      } else if (tsk.Type == 'Meeting') {
                          openMeetingTask--;
                      } else if (tsk.Type == 'Other') {
                          openOtherTask--;
                      }
                  }
                  acc.Open_Tasks_Email__c = openEmailTask;
                  acc.Open_Tasks_Call__c = openCallTask;
                  acc.Open_Tasks_Meeting__c = openMeetingTask;
                  acc.Open_Tasks_Other__c = openOtherTask;
              }
          }
          
          updatedAccounts.put(acc.Id, acc);
  }

  
  try {
      update updatedAccounts.values();
  } catch (Exception ex) {
      System.debug('The following exception occured: ' + ex);
  }
  
}