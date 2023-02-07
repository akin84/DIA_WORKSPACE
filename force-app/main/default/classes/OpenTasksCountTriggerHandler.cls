/**
 * @description       :
 * @author            : Ferdi AKIN
 * @group             :
 * @last modified on  : 02-07-2023
 * @last modified by  : Ferdi AKIN
 **/
public with sharing class OpenTasksCountTriggerHandler {
  public static void handlerAfterInsert(List<Task> newTasks) {
    Set<Id> accIdsSet = new Set<Id>();
    ID Recordtype = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'United States'
      LIMIT 1
    ]
    .Id;

    for (Task ts : newTasks) {
      if (ts.WhatId != null) {
        accIdsSet.add(ts.WhatId);
      }
    }

    if (!accIdsSet.isEmpty()) {
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
            WHERE WhatId IN :accIdsSet
          )
        FROM Account
        WHERE
          Id IN :accIdsSet
          AND Type = 'Prospect'
          AND RecordTypeID = :Recordtype
      ];

      System.enqueueJob(new OpenTasksOnAccountQueue(rltdAccounts));
    }
  }

  public static void handlerAfterUpdate(
    Map<Id, Task> oldMapTasks,
    List<Task> newTasks
  ) {
    Set<Id> accIdsSet = new Set<Id>();
    ID Recordtype = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'United States'
      LIMIT 1
    ]
    .Id;

    for (Task ts : newTasks) {
      Task tskOld = oldMapTasks.get(ts.Id);
      if (
        ts.Status != tskOld.Status ||
        ts.Type != tskOld.Type ||
        ts.WhatId != tskOld.WhatId
      ) {
        accIdsSet.add(ts.WhatId);
        accIdsSet.add(tskOld.WhatId);
      }
    }

    if (!accIdsSet.isEmpty()) {
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
            WHERE WhatId IN :accIdsSet
          )
        FROM Account
        WHERE
          Id IN :accIdsSet
          AND Type = 'Prospect'
          AND RecordTypeID = :Recordtype
      ];

      System.enqueueJob(new OpenTasksOnAccountQueue(rltdAccounts));
    }
  }

  public static void handlerAfterDelete(List<Task> oldTasks) {
    Set<Id> accIdsSet = new Set<Id>();
    ID Recordtype = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'United States'
      LIMIT 1
    ]
    .Id;

    for (Task ts : oldTasks) {
      accIdsSet.add(ts.WhatId);
    }

    if (!accIdsSet.isEmpty()) {
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
            WHERE WhatId IN :accIdsSet
          )
        FROM Account
        WHERE
          Id IN :accIdsSet
          AND Type = 'Prospect'
          AND RecordTypeID = :Recordtype
      ];

      system.enqueueJob(new OpenTasksOnAccountQueue(rltdAccounts));
    }
  }
}
