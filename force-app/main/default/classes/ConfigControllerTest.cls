/*
************************************************************************************************************************************
Class Name: ConfigControllerTest (Test class for ConfigController)
@author: Ashwin.A.
@date :  22-03-2022

*************************************************************************************************************************************
*/
@isTest
public class ConfigControllerTest {
    /*
**********************************************************************************
Method Name	: setup
Description : Setup method to create data
Author		: Ashwin.A
**********************************************************************************
*/    
    @testSetup static void setup() {
        
        List<Config__c> testConfigs = new List<Config__c>();
        for(Integer i=0;i<3;i++) {
            testConfigs.add(new Config__c(label__c = 'TestAcct'+i,type__c='standard',amount__c=1000));
        }
        insert testConfigs;
        
        Case testcase = new Case(Status = 'New',Origin = 'Web',Subject = 'Testsubject');
        insert testcase;
        
        List<Case_Config__c> testCaseConfigs = new List<Case_Config__c>();
        for(Integer i=0;i<3;i++) {
            testCaseConfigs.add(new Case_Config__c(Config__c = testConfigs[i].Id, Case__c = testcase.Id));
        }
        insert testCaseConfigs;
        
        
    }
    /*
**********************************************************************************
Method Name	: testgetConfigs
Description : test method for getConfigs()
Author		: Ashwin.A
**********************************************************************************
*/    
    @isTest
    public static void testgetConfigs(){
        
        List<Config__c> ConfigsLits =[SELECT Id,label__c,type__c,amount__c FROM Config__c LIMIT 49999];
        Case caseRec = [SELECT Id,Status FROM Case LIMIT 1];
        List<Case_Config__c> CaseConfigsLits =[SELECT Id,label__c,Case__c FROM Case_Config__c WHERE Case__c =: caseRec.Id LIMIT 49999];
        //system.debug(caseRec);
        //system.debug(CaseConfigsLits);
        ConfigController.leadwrapper result = ConfigController.getConfigs(caseRec.Id);
        system.assertEquals(result.configList.size(), 3);
        
    }
    /*
**********************************************************************************
Method Name	: testgetCaseConfigs
Description : test method for getCaseConfigs()
Author		: Ashwin.A
**********************************************************************************
*/    
    @isTest
    public static void testgetCaseConfigs(){
        
        Case caseRec = [SELECT Id,Status FROM Case LIMIT 1];
        
        List<Case_Config__c> result =  ConfigController.getCaseConfigs(caseRec.Id); 
        system.assertEquals(result.size(), 3);
        
    }
    /*
**********************************************************************************
Method Name	: testsaveData
Description : test method for saveData()
Author		: Ashwin.A
**********************************************************************************
*/    
    @isTest
    public static void testsaveData(){
        
        Case caseRec = [SELECT Id,Status FROM Case LIMIT 1];
        Config__c configRec = new Config__c(label__c = 'TestAcct',type__c='standard',amount__c=1000);
        insert configRec;
        List<String> configIds = new List<String>();
        configIds.add(configRec.Id);
        String result = ConfigController.saveData(configIds,caseRec.Id); 
        system.assertEquals(result, null);
        
    }
    /*
**********************************************************************************
Method Name	: testsaveDataNegative
Description : test method for saveData() exception scenario
Author		: Ashwin.A
**********************************************************************************
*/     
    @isTest
    public static void testsaveDataNegative(){
        
        
        Config__c configRec = new Config__c(label__c = 'TestAcct',type__c='standard',amount__c=1000);
        insert configRec;
        List<String> configIds = new List<String>();
        configIds.add(configRec.Id);
        String result = ConfigController.saveData(configIds,''); 
        system.assertNotEquals(result, null);
        
    }
    /*
**********************************************************************************
Method Name	: testsendData
Description : test method for sendData()
Author		: Ashwin.A
**********************************************************************************
*/     
    @isTest
    public static void testsendData(){
        
        Case caseRec = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new configCalloutMock());
        String result = ConfigController.sendData(caseRec.Id);
        system.debug(result);
        system.assertNotEquals(result, null);
        
    }
    
}