({
    doInit : function(component,event,helper) {
        helper.doInit(component,event,helper);
    },
    handleSort : function(component,event,helper) {
        helper.handleSort(component,event,helper);
    },
    handleClick : function(component,event,helper) {
        helper.handleClick(component,event,helper);
    },
    updateSelectedText: function (component,event) {
        var selectedIds= [];
        var selectedRows = event.getParam('selectedRows');
        
        selectedRows.forEach(currentItem => {
            selectedIds.push(currentItem.Id);
        });
            // console.log(selectedIds);
            component.set('v.selectedRowsCount', selectedRows.length);
            component.set('v.selectedConfigIds', selectedIds);
        },
            
            
        })