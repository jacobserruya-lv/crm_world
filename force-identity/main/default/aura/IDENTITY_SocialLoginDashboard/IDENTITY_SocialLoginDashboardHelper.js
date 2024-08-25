({
    createLineChart : function(cmp, temp, elemId) {
        
        var el = cmp.find(elemId).getElement();
        var ctx = el.getContext('2d');
        temp = JSON.parse(temp);
        console.log('in helper - temp');
        console.log(temp);

        var labelset = []; // months list
        var lineValue = [];
        var weChatValue = [];
        var weChatMobileValue = [];
        var kakaoValue = [];


        for(var a=0; a< temp.length; a++){
          labelset.push(temp[a]["label"]);
            lineValue.push(temp[a]["lineValue"]);
            weChatValue.push(temp[a]["weChatValue"]); 
            weChatMobileValue.push(temp[a]["weChatMobileValue"]);                     
            kakaoValue.push(temp[a]["kakaoValue"]);
        }
        
        var chart = new Chart(ctx, {
            type: 'line',
            data: {
              labels: labelset,
              datasets: [{ 
                  data: lineValue,
                  label: 'Line',
                  fill: false,
                  borderWidth: 3,
                  pointBackgroundColor: "#FFFFFF",
                  pointBorderWidth: 4,
                  pointHoverRadius: 8,
                  pointRadius: 6,
                  pointHitRadius: 10,
                  borderColor: "#88D840"
                }, { 
                  data: weChatValue,
                  label: 'WeChat',
                  fill: false,
                  borderWidth: 3,
                  pointBackgroundColor: "#FFFFFF",
                  pointBorderWidth: 4,
                  pointHoverRadius: 8,
                  pointRadius: 6,
                  pointHitRadius: 10,
                  borderColor: "#4474c4"
                }, { 
                  data: weChatMobileValue,
                  label: 'WeChat_Mobile',
                  fill: false,
                  borderWidth: 3,
                  pointBackgroundColor: "#FFFFFF",
                  pointBorderWidth: 4,
                  pointHoverRadius: 8,
                  pointRadius: 6,
                  pointHitRadius: 10,
                  borderColor: "#6b9cfb"
                }, { 
                  data: kakaoValue,
                  label: 'Kakao',
                  fill: false,
                  borderWidth: 3,
                  pointBackgroundColor: "#FFFFFF",
                  pointBorderWidth: 4,
                  pointHoverRadius: 8,
                  pointRadius: 6,
                  pointHitRadius: 10,
                  borderColor: "#FFE812"
                }
              ]
            }
        });
    },
    
    createDoughnutChart : function(cmp, temp, elemId) {
      
      var el = cmp.find(elemId).getElement();
      var ctx = el.getContext('2d');
      
      var labelset=[] ;
      var dataset=[] ;
      var colorset=[];
      
      if(temp == 'No data to display')
      {
          labelset.push('No data');
          dataset.push(0);
          colorset.push('');
      }
      else
      {
          temp = JSON.parse(temp);
          console.log('in helper - temp');
          console.log(temp);
          
          temp.forEach(function(key) {
              dataset.push(key.count) ;
              if(key.label == 'Line'){
                colorset.push("#88D840");
                labelset.push(key.label) ;
              }                
              else if(key.label == 'Kakao'){
                colorset.push("#FFE812");
                labelset.push(key.label) ;
              }                
              else if(key.label == 'WeChat'){
                colorset.push("#4474c4");
                labelset.push(key.label) ;
              }
              else if(key.label == 'WeChat_Mobile'){
                colorset.push("#6b9cfb");
                labelset.push(key.label) ;
              }
              else{
                colorset.push("#CCCCCC");
                labelset.push("Other");
              }
          });
      }

      console.log('labelset: '+labelset);
      console.log('dataset: '+dataset);
      console.log('colorset: '+colorset);
      
      var data = {
          labels: labelset, 
          datasets: [
              {
                  label: labelset,
                  data: dataset,
                  backgroundColor: colorset
              }
          ]
      };
      
      new Chart(ctx, {
          type: 'doughnut',
          data: data
      });
    }    
  
})