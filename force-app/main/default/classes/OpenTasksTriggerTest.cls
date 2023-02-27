/**
 * @description       :
 * @author            : Ferdi AKIN
 * @group             :
 * @last modified on  : 02-27-2023
 * @last modified by  : Ferdi AKIN
 **/
@isTest
private class OpenTasksTriggerTest {
  private static final Integer ACCOUNTS_NUMBER = 5;
  private static final Integer TASKS_NUMBER = 5;
  static Id recordTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByName()
    .get('United States')
    .getRecordTypeId();

  @TestSetup
  private static void makeData() {
    List<Account> accounts = new List<Account>();

    for (Integer i = 0; i < ACCOUNTS_NUMBER; i++) {
      Account acc = new Account(
        Name = 'Test Account ' + i,
        Type = 'Prospect',
        RecordTypeId = recordTypeAccount
      );
      accounts.add(acc);
    }
    insert accounts;

    List<Task> tasks = new List<Task>();
    for (Account acc : accounts) {
      for (Integer i = 0; i < TASKS_NUMBER; i++) {
        Task tskCall = new Task(
          Subject = 'Call',
          Type = 'Call',
          WhatId = acc.Id
        );
        tasks.add(tskCall);
        Task tskEmail = new Task(
          Subject = 'Email',
          Type = 'Email',
          WhatId = acc.Id
        );
        tasks.add(tskEmail);
        Task tskMeeting = new Task(
          Subject = 'Meeting',
          Type = 'Meeting',
          WhatId = acc.Id
        );
        tasks.add(tskMeeting);
        Task tskOther = new Task(
          Subject = 'Other',
          Type = 'Other',
          WhatId = acc.Id
        );
        tasks.add(tskOther);
      }
    }
    insert tasks;
  }

  @isTest
  private static void shouldHaveAccountsAndTasksInDatabase() {
    Assert.areEqual(
      ACCOUNTS_NUMBER,
      [SELECT COUNT() FROM Account],
      'Failed to get expected amount of Accounts'
    );
    Integer numberOfTaskTypes = 4;
    Test.startTest();
    Assert.areEqual(
      (ACCOUNTS_NUMBER * TASKS_NUMBER * numberOfTaskTypes),
      [SELECT COUNT() FROM Task],
      'Failed to get expected amount of tasks'
    );
    Test.stopTest();
  }

  //insert scenario
  @isTest
  public static void insertNewTaskAccount() {
    Account account = [SELECT Id FROM Account LIMIT 1];
    Id accId = account.Id;

    Task tskOther = new Task(
      Subject = 'Other',
      Type = 'Other',
      Status = 'Not Started',
      WhatId = accId
    );

    Test.startTest();
    insert tskOther;
    Test.stopTest();
    Assert.areEqual(
      TASKS_NUMBER + 1,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :accId]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on Account after insert'
    );
  }

  //close a task & re-open it scenario
  @isTest
  private static void closeTask() {
    //closing
    Account account = [SELECT Id FROM Account LIMIT 1];
    Id accId = account.Id;

    Task openTsk = [
      SELECT Type, Status
      FROM Task
      WHERE WhatId = :accId AND Status != 'Completed' AND Type = 'Email'
      LIMIT 1
    ];
    openTsk.Status = 'Completed';

    Test.startTest();
    update openTsk;
    Test.stopTest();
    Assert.areEqual(
      TASKS_NUMBER - 1,
      [SELECT Open_Tasks_Email__c FROM Account WHERE Id = :accId]
      .Open_Tasks_Email__c,
      'Failed to get expected amount of open tasks on Account after closing a task'
    );
  }
  @isTest
  private static void reopenTask() {
    //closing
    Account account = [SELECT Id FROM Account LIMIT 1];
    Id accId = account.Id;

    Task openTsk = [
      SELECT Type, Status
      FROM Task
      WHERE WhatId = :accId AND Status != 'Completed' AND Type = 'Email'
      LIMIT 1
    ];
    //re-opening
    openTsk.Status = 'In progress';

    Test.startTest();
    update openTsk;
    Test.stopTest();
    Assert.areEqual(
      TASKS_NUMBER,
      [SELECT Open_Tasks_Email__c FROM Account WHERE Id = :accId]
      .Open_Tasks_Email__c,
      'Failed to get expected amount of open tasks on Account after re-opening a task'
    );
  }

  //delete scenario
  @isTest
  private static void deleteTask() {
    Account account = [SELECT Id FROM Account LIMIT 1];
    Id accId = account.Id;

    Task openTsk = [
      SELECT Type, Status
      FROM Task
      WHERE WhatId = :accId AND Status != 'Completed' AND Type = 'Other'
      LIMIT 1
    ];

    Assert.areEqual(
      TASKS_NUMBER,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :accId]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on Account before delete'
    );

    Test.startTest();
    delete openTsk;
    Test.stopTest();
    Assert.areEqual(
      TASKS_NUMBER - 1,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :accId]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on Account after delete'
    );
  }

  //reparenting a task to a new account scenario
  @isTest
  private static void reparentingTask() {
    Account account = [SELECT Id FROM Account LIMIT 1];
    Id accId = account.Id;

    Task openTsk = [
      SELECT WhatId
      FROM Task
      WHERE WhatId != :accId AND Status != 'Completed' AND Type = 'Other'
      LIMIT 1
    ];
    Id firstParent = openTsk.WhatId;
    openTsk.WhatId = accId;

    //count on first related Account
    Test.startTest();
    update openTsk;
    Test.stopTest();
    Assert.areEqual(
      TASKS_NUMBER - 1,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :firstParent]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on first related Account'
    );

    //count on current related Account
    Assert.areEqual(
      TASKS_NUMBER + 1,
      [SELECT Open_Tasks_Other__c FROM Account WHERE Id = :accId]
      .Open_Tasks_Other__c,
      'Failed to get expected amount of open tasks on current related Account'
    );
  }
}
