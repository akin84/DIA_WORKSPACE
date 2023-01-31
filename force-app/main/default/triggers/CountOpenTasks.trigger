trigger CountOpenTasks on Task (after insert, after update, after delete) {
    
  
    Set<Id> accountIds = new Set<Id>();
    ID Recordtype = [SELECT Id FROM RecordType WHERE Name ='United States' LIMIT 1].Id;
  
    List<Task> tasks;
    if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isDelete)) {
      tasks = Trigger.old;
    } else if (Trigger.isAfter && Trigger.isInsert) {
      tasks = Trigger.new;
    }

  
    for (Task t : tasks) {
        if (t.WhatId != null) {
          accountIds.add(t.WhatId);
        }
    }


  
    List<Account> rltdAccounts = [SELECT Id, RecordTypeID, Type, Open_Tasks_Email__c, Open_Tasks_Call__c, Open_Tasks_Meeting__c, Open_Tasks_Other__c, 
                                  (SELECT ID,Type,Status,WhatId FROM Tasks) 
                                  FROM Account WHERE Id IN :accountIds AND Type = 'Prospect' AND RecordTypeID = :Recordtype];

  
  Map<Id, Account> updatedAccounts = new Map<Id, Account>();

  
  for (Account acc : rltdAccounts) {
      Integer openEmailTask = 0;
      Integer openCallTask = 0;
      Integer openMeetingTask = 0;
      Integer openOtherTask = 0;
          for (Task tsk : acc.tasks) {
              if (tsk.WhatId == acc.Id) {
                  if (tsk.Status != 'Completed') {
                      if (tsk.Type == 'Email') {
                          openEmailTask++;
                      } else if (tsk.Type == 'Call') {
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
                      } else {
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