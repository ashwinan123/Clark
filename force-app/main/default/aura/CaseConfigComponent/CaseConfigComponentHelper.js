({
    doInit : function(component,event,helper) {
      
        component.set('v.columns', [
            {label: 'Label',fieldName: 'Label__c', type: 'text'},
            {label: 'Type', fieldName: 'Type__c', type: 'text'},
            {label: 'Amount', fieldName: 'Amount__c', type: 'Number'}
        ]);
        
        var caseId = component.get('v.caseId'); 
        var Action = component.get('c.getCaseConfigs');
        Action.setParams({
            "caseId" : caseId
        });
        Action.setCallback(this, function(response) {
            var state = response.getState();            
            if (component.isValid() && state === "SUCCESS") {
                //console.log(response.getReturnValue());
                var items = response.getReturnValue();
                if(items.length>0){
                    component.set('v.allCaseConfigs',items); 
                    component.set('v.caseConfigsSize',items.length);     
                }
            }
        });
        
        
        $A.enqueueAction(Action);
        
    },
    
     handleNext : function(component,event,helper) {
        
          var caseId = component.get('v.caseId'); 
        var Action = component.get('c.sendData');
        Action.setParams({
            "caseId" : caseId
        });
        Action.setCallback(this, function(response) {
            var state = response.getState();            
            if (component.isValid() && state === "SUCCESS") {
               component.set('v.isdisabled','true');
                
                var returnValue  = response.getReturnValue();
                console.log(returnValue);
                if(returnValue == null){                
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Your updates have been saved"
                    });
                    toastEvent.fire();
                    
                }
              
            }else if(state === "ERROR"){ 
                var errors = response.getError();
                
                //console.log(errors);
                var toastEvent = $A.get("e.force:showToast");                    
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "Your request could not be processed. Please try again"
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(Action);
         
     }
})