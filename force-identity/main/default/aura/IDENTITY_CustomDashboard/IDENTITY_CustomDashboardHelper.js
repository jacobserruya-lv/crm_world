({
    createBarChart : function(cmp, temp, elemId) {
        
        var el = cmp.find(elemId).getElement();
        var ctx = el.getContext('2d');
        var amount;
        var amountByUsers;
        var data;


        temp.forEach(function(key) {
            if(key.label == 'amount')
                amount = key.count;
            if(key.label == 'amountByUsers')
                amountByUsers = key.count;
        });

        console.log('in helper - temp');
        console.log(temp);
                
        if(elemId == 'VerificationCodeEmailsAmount')
        {
            data = {
                labels: ["last 30 days"],
                datasets: [
                  {
                    label: "Amount",
                    backgroundColor: "#94E7A8", 
                    data: [amount]
                  }, {
                    label: "Amount / users",
                    backgroundColor: "#C7F296",
                    data: [amountByUsers]
                  }
                ]
            }
        }
        else
        {
            data = {
                labels: ["last 30 days"],
                datasets: [
                  {
                    label: "Amount",
                    backgroundColor: "#94E7A8", 
                    data: [amount]
                  }
                ]
            }
        }
        
        new Chart(ctx, {
            type: 'bar',
            data: data,
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });
    },
    
    createDoughnutChart : function(cmp, temp, elemId) {
        
        var el = cmp.find(elemId).getElement();
        var ctx = el.getContext('2d');

        console.log('in helper - temp');
        console.log(temp);

        var labelset=[] ;
        var dataset=[] ;
        temp.forEach(function(key) {
            labelset.push(key.label) ; 
            dataset.push(key.count) ;
        });
        
        var data = {
            labels: ["Email", "Mobile"], 
            datasets: [
                {
                    label: labelset,
                    data: dataset,
                    backgroundColor: [
                        "#94E7A8",
                        "#C7F296"
                    ]              
                }
            ]
        };
        
        new Chart(ctx, {
            type: 'doughnut',
            data: data
        });
    }
})