({
    
    sort: function(component, index){
        var sortingIndex = component.get("v.sortingIndex");
        var headers = component.get("v.tableData.headers");
        var header = headers[index];
        if(sortingIndex==index)
            header.sortingDir = (header.sortingDir=="desc")?'asc':'desc';
        else
            header.sortingDir = 'desc';
        component.set("v.tableData.headers", headers);
        component.set("v.sortingIndex", index);
        this.sortingAlg(component, index, header.sortingDir, header.type, component.get("v.tableData.rows"));
    },
    
    sortingAlg: function(component, index, sortingDir, type, rows){
        rows.sort(this.getSortingFunction(type, index, sortingDir));
		component.set("v.tableData.rows", []);
		component.set("v.tableData.rows",rows);
    },
    
    getSortingFunction: function(type, index, sortingDir){
        var mult = (sortingDir=='desc')?1:-1;
        if(type==='Date'){
            return function(a,b){
				if(a[index].date == b[index].date) return 0;
                else if(a[index].date > b[index].date) return mult*-1;
                else return mult;
            }
        }
        else{
            return function(a,b){
                if(a[index].label == b[index].label) return 0;
                else if(a[index].label > b[index].label) return mult*-1;
                else return mult;
            }
        }
    }
    
    
})