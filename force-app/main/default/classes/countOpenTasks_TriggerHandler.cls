/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 02-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class countOpenTasks_TriggerHandler {
  public static void handlerAfterInsert(List<Task> newTasks) {
    processTasks(newTasks);
  }

  public static void handlerAfterUpdate(
    List<Task> oldTasks,
    List<Task> newTasks
  ) {
    processTasks(oldTasks);
  }

  public static void handlerAfterDelete(List<Task> oldTasks) {
    processTasks(oldTasks);
  }

  private static void processTasks(List<Task> tasks) {
    Set<Id> accountIds = new Set<Id>();
    ID Recordtype = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'United States'
      LIMIT 1
    ]
    .Id;

    for (Task t : tasks) {
      if (t.WhatId != null) {
        accountIds.add(t.WhatId);
      }
    }

    List<Account> rltdAccounts = [
      SELECT
        Id,
        RecordTypeID,
        Type,
        Open_Tasks_Email__c,
        Open_Tasks_Call__c,
        Open_Tasks_Meeting__c,
        Open_Tasks_Other__c,
        (
          SELECT Id, Type, Status, WhatId
          FROM Tasks
          WHERE WhatId IN :accountIds AND Status != 'Completed' AND Type != NULL
        )
      FROM Account
      WHERE
        Id IN :accountIds
        AND Type = 'Prospect'
        AND RecordTypeID = :Recordtype
    ];

    Integer openEmailTask = 0;
    Integer openCallTask = 0;
    Integer openMeetingTask = 0;
    Integer openOtherTask = 0;

    Map<Id, Account> updatedAccounts = new Map<Id, Account>();

    for (Account acc : rltdAccounts) {
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
        }
      }
      acc.Open_Tasks_Email__c = openEmailTask;
      acc.Open_Tasks_Call__c = openCallTask;
      acc.Open_Tasks_Meeting__c = openMeetingTask;
      acc.Open_Tasks_Other__c = openOtherTask;
      updatedAccounts.put(acc.Id, acc);
    }
    try {
      update updatedAccounts.values();
    } catch (Exception ex) {
      System.debug('The following exception occured: ' + ex);
    }
  }
}
