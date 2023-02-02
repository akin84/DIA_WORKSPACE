/**
 * @description       :
 * @author            : Ferdi AKIN
 * @last modified on  : 02-02-2023
 * @last modified by  : Ferdi AKIN
 **/
@isTest
public with sharing class testOpenTasksTrigger {
  @isTest
  private static void testCountOpenTasks() {
    Account testAccount = new Account(
      Name = 'Test Account',
      Type = 'Prospect',
      RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE Name = 'United States'
        LIMIT 1
      ]
      .Id
    );
    insert testAccount;

    Account testAccount2 = new Account(
      Name = 'Test Account2',
      Type = 'Installation Partner',
      RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE Name = 'United States'
        LIMIT 1
      ]
      .Id
    );
    insert testAccount2;

    Account testAccount3 = new Account(
      Name = 'Test Account3',
      Type = 'Prospect',
      RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE Name = 'EMEA'
        LIMIT 1
      ]
      .Id
    );
    insert testAccount3;

    Task emailTask = new Task(
      Subject = 'Test Email Task',
      Type = 'Email',
      WhatId = testAccount.Id,
      Status = 'In Progress'
    );
    Task callTask = new Task(
      Subject = 'Test Call Task',
      Type = 'Call',
      WhatId = testAccount.Id,
      Status = 'Not Started'
    );
    Task meetingTask = new Task(
      Subject = 'Test Meeting Task',
      Type = 'Meeting',
      WhatId = testAccount.Id,
      Status = 'Deferred'
    );
    Task otherTask = new Task(
      Subject = 'Test Other Task',
      Type = 'Other',
      WhatId = testAccount.Id,
      Status = 'Not Started'
    );
    insert new List<Task>{ emailTask, callTask, meetingTask, otherTask };

    testAccount = [
      SELECT
        Id,
        Open_Tasks_Email__c,
        Open_Tasks_Call__c,
        Open_Tasks_Meeting__c,
        Open_Tasks_Other__c
      FROM Account
      WHERE Id = :testAccount.Id
    ];
    System.assertEquals(1, testAccount.Open_Tasks_Email__c);
    System.assertEquals(1, testAccount.Open_Tasks_Call__c);
    System.assertEquals(1, testAccount.Open_Tasks_Meeting__c);
    System.assertEquals(1, testAccount.Open_Tasks_Other__c);

    emailTask.Status = 'Completed';
    update emailTask;

    testAccount2 = [
      SELECT
        Id,
        Open_Tasks_Email__c,
        Open_Tasks_Call__c,
        Open_Tasks_Meeting__c,
        Open_Tasks_Other__c
      FROM Account
      WHERE Id = :testAccount2.Id
    ];
    System.assertEquals(0, testAccount2.Open_Tasks_Email__c);
    System.assertEquals(1, testAccount2.Open_Tasks_Call__c);
    System.assertEquals(1, testAccount2.Open_Tasks_Meeting__c);
    System.assertEquals(1, testAccount2.Open_Tasks_Other__c);

    delete callTask;

    testAccount3 = [
      SELECT
        Id,
        Open_Tasks_Email__c,
        Open_Tasks_Call__c,
        Open_Tasks_Meeting__c,
        Open_Tasks_Other__c
      FROM Account
      WHERE Id = :testAccount3.Id
    ];
    System.assertEquals(0, testAccount3.Open_Tasks_Email__c);
    System.assertEquals(0, testAccount3.Open_Tasks_Call__c);
    System.assertEquals(1, testAccount3.Open_Tasks_Meeting__c);
    System.assertEquals(1, testAccount3.Open_Tasks_Other__c);
  }
}
