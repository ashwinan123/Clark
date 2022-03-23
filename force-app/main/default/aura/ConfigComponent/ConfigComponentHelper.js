({
    doInit : function(component,event,helper) {
        
        component.set('v.columns', [
            {label: 'Label',fieldName: 'Label__c', type: 'text'},
            {label: 'Type', fieldName: 'Type__c', type: 'text'},
            {label: 'Amount',sortable: true, fieldName: 'Amount__c', type: 'Number'}
        ]);
        
        var caseId = component.get('v.recordId'); 
        var Action = component.get('c.getConfigs');
         Action.setParams({
            "caseId" : caseId
        });
        Action.setCallback(this, function(response) {
            var state = response.getState();            
            if (component.isValid() && state === "SUCCESS") {
              
                var items = response.getReturnValue();
                  //console.log(items.leadStatus);
                if(items.configList.length>0){
                    component.set('v.allConfigs',items.configList); 
                    component.set('v.ConfigsSize',items.length);     
                }
                if(items.leadStatus == 'Closed'){
                   component.set('v.isdisabled','true');  
                }
            }
        });
        
        
        $A.enqueueAction(Action);
    },
    
    sortBy: function(field, reverse, primer) {
        var key = primer
        ? function(x) {
            return primer(x[field]);
        }
        : function(x) {
            return x[field];
        };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    
    handleSort : function(component,event,helper) {
        
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        console.log(sortedBy+'ddd'+sortDirection);
        var data = component.get('v.allConfigs');
        var cloneData = data.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        component.set('v.allConfigs', cloneData);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy);
        
    },
    
    handleClick : function(component,event,helper) {  
        var selectedIds = component.get('v.selectedConfigIds'); 
        var caseId = component.get('v.recordId'); 
        if(selectedIds.length == 0){
            alert('Please select any records to proceed');
            return false;
        }
        
        
        var Action = component.get('c.saveData');
        Action.setParams({
            "configIds" : selectedIds,
            "caseId" : caseId
        });
        Action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") { 
                
                var returnValue  = response.getReturnValue();
                if(returnValue == null){                
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Your updates have been saved"
                    });
                    toastEvent.fire();
                    component.set('v.selectedConfigIds', []);
                    
                    var childCmp = component.find('childCmp');
                    childCmp.refreshData();
                    
                } else if(returnValue == 'duplicate'){
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": 'error',
                        "message": "Selected Config is already added to case"
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
        
    },
    
    
})