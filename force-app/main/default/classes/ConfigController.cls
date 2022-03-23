/*
************************************************************************************************************************************
Class Name: ConfigController
@author: Ashwin.A.
@date :  22-03-2022

*************************************************************************************************************************************
*/

public class ConfigController {
    
    /*
**********************************************************************************
Method Name	: getConfigs
Description : To get all config records
Author		: Ashwin.A
**********************************************************************************
*/   
    @AuraEnabled
    public static leadwrapper getConfigs(String caseId){
        
        List<Config__c> configList = new List<Config__c>();
        configList = [SELECT Id,Label__c,Type__c,Amount__c FROM Config__c LIMIT 49999];
        Case caseRec = [SELECT status FROM Case WHERE Id =:caseId LIMIT 1 ];
        leadwrapper response = new leadwrapper();
        response.configList = configList;
        response.leadStatus = caseRec.status;
        return response;
        
    }  
    /*
**********************************************************************************
Method Name	: getCaseConfigs
Description : To get all config records associated with selected case
Author		: Ashwin.A
**********************************************************************************
*/    
    @AuraEnabled
    public static List<Case_Config__c> getCaseConfigs(String caseId){
        
        List<Case_Config__c> configList = new List<Case_Config__c>();
        configList = [SELECT Id,Label__c,Type__c,Amount__c FROM Case_Config__c WHERE Case__c =: caseId LIMIT 49999];
        return configList;
        
    }   
    
    /*
**********************************************************************************
Method Name	: saveData
Description : To save config records to case record
Author		: Ashwin.A
**********************************************************************************
*/     
    @AuraEnabled
    public static String saveData(List<String> configIds,String caseId){
        
        try{
            
            List<Case_Config__c> caseconfigCheck = [SELECT Id FROM Case_Config__c WHERE Case__c =: caseId AND Config__c IN: configIds LIMIT 49999];
            if(caseconfigCheck.size()>0){ //If selected config is already part of case, cancel the request
                return 'duplicate'; 
                
            } else{
                List<Case_Config__c> caseConfigList = new List<Case_Config__c>();
                for(String configId : configIds){
                    
                    Case_Config__c caseConfig = new Case_Config__c();
                    caseConfig.Case__c = caseId;
                    caseConfig.Config__c = configId;
                    caseConfigList.add(caseConfig);
                }
                Insert caseConfigList;
                return null;
            }
        }catch(Exception e){
            return e.getMessage();
        }     
        
    }
    /*
**********************************************************************************
Method Name	: sendData
Description : To send data to external service and update case status to closed
Author		: Ashwin.A
**********************************************************************************
*/     
    @AuraEnabled
    public static String sendData(String caseId){
        
        try{  Case c = [Select Id,status,(SELECT Id,label__c,type__c,amount__c From Case_Configs__r) FROM Case WHERE Id =: caseId Limit 1] ; 
            
            List<wrapper> wrapList = new List<wrapper>() ;  
            if(c.Case_Configs__r.size()>0){
                for(Case_Config__c rec : c.Case_Configs__r ){
                    wrapper wrap = new wrapper();
                    wrap.id =  rec.id;
                    wrap.label =  rec.label__c;
                    wrap.type =  rec.type__c;
                    wrap.amount =  rec.amount__c;
                    wrapList.add(wrap);
                }
            }
            
            JSONGenerator gen = JSON.createGenerator(true);    
            gen.writeStartObject();      
            gen.writeStringField('CaseId', c.Id);
            gen.writeStringField('Status',c.status);
            gen.writeStringField('caseConfigs',JSON.serialize(wrapList));    
            
            gen.writeEndObject();    
            String jsonS = gen.getAsString();
            
            String endpoint = 'https://caseconfig.requestcatcher.com';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setbody(jsonS);
            Http http = new Http();
            HTTPResponse response = http.send(req); 
            
            c.status='Closed';
            Update c;
            return null;
           }catch(Exception e){
               return e.getMessage();
           }     
        
    }
    
    public class wrapper{
        
        public String id;
        public String label;
        public String type;
        public Decimal amount;
        
    }
    
    public class leadwrapper{
        
        @AuraEnabled public List<Config__c> configList; 
        @AuraEnabled public String leadStatus;
        
        
    }
    
    
    
}