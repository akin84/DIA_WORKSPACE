/**
 * @description       :
 * @author            : Ferdi AKIN
 * @group             :
 * @last modified on  : 02-07-2023
 * @last modified by  : Ferdi AKIN
 **/
@isTest
private class OpenTasksTriggerTest {
  static Id recordTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByName()
    .get('United States')
    .getRecordTypeId();

  @testSetup
  static void makeData() {
    Account a1 = new Account();
    a1.Name = 'Test Account 1';
    a1.RecordTypeId = recordTypeAccount;
    a1.Type = 'Prospect';
    insert a1;

    Account a2 = new Account();
    a2.Name = 'Test Account 2';
    a2.RecordTypeId = recordTypeAccount;
    a2.Type = 'Technology Partner';
    insert a2;

    Account a3 = new Account();
    a3.Name = 'Test Account 3';
    a3.Type = 'Prospect';
    insert a3;

    Account a4 = new Account();
    a4.Name = 'Test Account 4';
    insert a4;

    Task t1 = new Task();
    t1.WhatId = a1.Id;
    t1.Type = 'Email';
    t1.Status = 'Deferred';
    insert t1;

    Task t2 = new Task();
    t2.WhatId = a2.Id;
    t2.Type = 'Call';
    t2.Status = 'In Progress';
    insert t2;

    Task t3 = new Task();
    t3.WhatId = a3.Id;
    t3.Type = 'Meeting';
    t3.Status = 'Deferred';
    insert t3;

    Task t4 = new Task();
    t4.WhatId = a4.Id;
    t4.Type = 'Other';
    t4.Status = 'Not Started';
    insert t4;

    Task t5 = new Task();
    t5.WhatId = a1.Id;
    t5.Type = 'Email';
    t5.Status = 'Not Started';
    insert t5;

    Task t6 = new Task();
    t6.WhatId = a1.Id;
    t6.Type = 'Other';
    t6.Status = 'In Progress';
    insert t6;

    Task t7 = new Task();
    t7.WhatId = a1.Id;
    t7.Type = 'Call';
    t7.Status = 'In Progress';
    insert t7;

    Task t8 = new Task();
    t8.WhatId = a1.Id;
    t8.Type = 'Meeting';
    t8.Status = 'In Progress';
    insert t8;
  }

  @isTest
  static void testHandlerAfterInsert() {
    Account a1 = [
      SELECT Id, Name, RecordTypeId, Type
      FROM Account
      WHERE
        RecordTypeId = :recordTypeAccount
        AND Name = 'Test Account 1'
        AND Type = 'Prospect'
    ];
    Task t5 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Email' AND Status = 'Not Started'
    ];
    Task t6 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Other' AND Status = 'In Progress'
    ];
    Task t7 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Call' AND Status = 'In Progress'
    ];
    Task t8 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Meeting' AND Status = 'In Progress'
    ];

    Account a = [
      SELECT
        Id,
        Open_Tasks_Email__c,
        Open_Tasks_Meeting__c,
        Open_Tasks_Call__c,
        Open_Tasks_Other__c
      FROM Account
      WHERE Id = :a1.Id
    ];
    System.assertEquals(2, a.Open_Tasks_Email__c, 'New Email Task inserted');
    System.assertEquals(1, a.Open_Tasks_Other__c, 'New Other Task inserted');
    System.assertEquals(
      1,
      a.Open_Tasks_Meeting__c,
      'New Meeting Task inserted'
    );
    System.assertEquals(1, a.Open_Tasks_Call__c, 'New Call Task inserted');
  }

  @isTest
  static void testHandlerAfterUpdate() {
    Account a2 = [
      SELECT Id, Name, RecordTypeId, Type
      FROM Account
      WHERE
        RecordTypeId = :recordTypeAccount
        AND Name = :'Test Account 2'
        AND Type = 'Technology Partner'
    ];
    Task t2 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a2.Id AND Type = 'Call' AND Status = 'In Progress'
    ];
    Task tk1 = [SELECT Id, Status FROM Task WHERE Id = :t2.Id];
    tk1.Status = 'Completed';
    update tk1;

    Account ac1 = [
      SELECT Id, Open_Tasks_Call__c
      FROM Account
      WHERE Id = :a2.Id
    ];
    System.assertEquals(null, ac1.Open_Tasks_Call__c, 'Call Task Updated');

    Account a4 = [
      SELECT Id, Name, RecordTypeId, Type
      FROM Account
      WHERE Name = :'Test Account 4'
    ];
    Task t4 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a4.Id AND Type = 'Other' AND Status = 'Not Started'
    ];
    Task tk2 = [SELECT Id, Status FROM Task WHERE Id = :t4.Id];
    tk2.Status = 'Completed';
    update tk2;

    Account ac2 = [
      SELECT Id, Open_Tasks_Other__c
      FROM Account
      WHERE Id = :a4.Id
    ];
    System.assertEquals(
      null,
      ac2.Open_Tasks_Other__c,
      'Open Other Task Updated But Not Calculated on Related Account'
    );

    Account a1 = [
      SELECT Id, Name, RecordTypeId, Type
      FROM Account
      WHERE
        RecordTypeId = :recordTypeAccount
        AND Name = 'Test Account 1'
        AND Type = 'Prospect'
    ];
    Task t5 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Email' AND Status = 'Not Started'
    ];
    t5.Status = 'In Progress';
    update t5;

    Task t6 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Other' AND Status = 'In Progress'
    ];
    t6.Status = 'Completed';
    update t6;

    Task t7 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Call' AND Status = 'In Progress'
    ];
    t7.Status = 'Completed';
    update t7;

    Account ac3 = [
      SELECT Id, Open_Tasks_Email__c, Open_Tasks_Call__c, Open_Tasks_Other__c
      FROM Account
      WHERE Id = :a1.Id
    ];
    System.assertEquals(2, ac3.Open_Tasks_Email__c, 'Open Email Task Updated');
    System.assertEquals(0, ac3.Open_Tasks_Call__c, 'Open Call Task Updated');
    System.assertEquals(1, ac3.Open_Tasks_Other__c, 'Open Other Task Updated');
  }

  @isTest
  static void testHandlerAfterDelete() {
    // Account a3 = [SELECT Id, Name, RecordTypeId, Type FROM Account WHERE Name = 'Test Account 3'];
    // Task t3 = [SELECT Id, Status, Type, WhatId FROM Task WHERE WhatId = :a3.Id];
    // delete t3;

    // Account ac3 = [SELECT Id, Open_Tasks_Meeting__c FROM Account WHERE Id = :a3.Id ];
    // System.assertEquals(0, ac3.Open_Tasks_Meeting__c, 'Meeting Task deleted');

    Account a1 = [
      SELECT Id, Name, RecordTypeId, Type
      FROM Account
      WHERE
        RecordTypeId = :recordTypeAccount
        AND Name = 'Test Account 1'
        AND Type = 'Prospect'
    ];
    Task t1 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Email' AND Status = 'Not Started'
    ];
    delete t1;
    Task t6 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Other' AND Status = 'In Progress'
    ];
    delete t6;
    Task t7 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Call' AND Status = 'In Progress'
    ];
    delete t7;
    Task t8 = [
      SELECT Id, Status, Type, WhatId
      FROM Task
      WHERE WhatId = :a1.Id AND Type = 'Meeting' AND Status = 'In Progress'
    ];
    delete t8;

    Account ac1 = [
      SELECT
        Id,
        Open_Tasks_Email__c,
        Open_Tasks_Meeting__c,
        Open_Tasks_Call__c,
        Open_Tasks_Other__c
      FROM Account
      WHERE Id = :a1.Id
    ];
    System.assertEquals(1, ac1.Open_Tasks_Email__c, 'Email Task deleted');
    System.assertEquals(0, ac1.Open_Tasks_Meeting__c, 'Meeting Task deleted');
    System.assertEquals(0, ac1.Open_Tasks_Call__c, 'Call Task deleted');
    System.assertEquals(0, ac1.Open_Tasks_Other__c, 'Other Task deleted');
  }
}
