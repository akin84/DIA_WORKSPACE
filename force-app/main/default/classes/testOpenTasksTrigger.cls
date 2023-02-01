/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class testOpenTasksTrigger {
    @isTest
    private static void testCountOpenTasks() {
        
        Account testAccount = new Account(Name='Test Account', Type='Prospect', RecordTypeId=[SELECT Id FROM RecordType WHERE Name = 'United States' LIMIT 1].Id);
        insert testAccount;

        Task emailTask = new Task(Subject='Test Email Task', Type='Email', WhatId=testAccount.Id, Status='In Progress');
        Task callTask = new Task(Subject='Test Call Task', Type='Call', WhatId=testAccount.Id, Status='Not Started');
        Task meetingTask = new Task(Subject='Test Meeting Task', Type='Meeting', WhatId=testAccount.Id, Status='Deferred');
        Task otherTask = new Task(Subject='Test Other Task', Type='Other', WhatId=testAccount.Id, Status='Not Started');
        insert new List<Task> { emailTask, callTask, meetingTask, otherTask };

        Account updatedAccount = [SELECT Id, Open_Tasks_Email__c, Open_Tasks_Call__c, Open_Tasks_Meeting__c, Open_Tasks_Other__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(1, updatedAccount.Open_Tasks_Email__c);
        System.assertEquals(1, updatedAccount.Open_Tasks_Call__c);
        System.assertEquals(1, updatedAccount.Open_Tasks_Meeting__c);
        System.assertEquals(1, updatedAccount.Open_Tasks_Other__c);

        emailTask.Status = 'Completed';
        update emailTask;

        updatedAccount = [SELECT Id, Open_Tasks_Email__c, Open_Tasks_Call__c, Open_Tasks_Meeting__c, Open_Tasks_Other__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(0, updatedAccount.Open_Tasks_Email__c);
        System.assertEquals(1, updatedAccount.Open_Tasks_Call__c);
        System.assertEquals(1, updatedAccount.Open_Tasks_Meeting__c);
        System.assertEquals(1, updatedAccount.Open_Tasks_Other__c);

        delete callTask;

        updatedAccount = [SELECT Id, Open_Tasks_Email__c, Open_Tasks_Call__c, Open_Tasks_Meeting__c, Open_Tasks_Other__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(0, updatedAccount.Open_Tasks_Email__c);
        System.assertEquals(0, updatedAccount.Open_Tasks_Call__c);
        System.assertEquals(1, updatedAccount.Open_Tasks_Meeting__c);
        System.assertEquals(1, updatedAccount.Open_Tasks_Other__c);
    }
}