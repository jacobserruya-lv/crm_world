 
/*
   MY: 2016/01/28 VOICE 2 : bannedWordList namespace
*/
 var bannedWordHandler = {};
(function(){
	this.bannedWordArray = [];
	this.firstTime = true;
	// Special Charateres to consider if used with banned words 
	this.specialCharc = [',','.',':',';','!','?','#','\'','(',')','-','_','*','+','\n'];

	this.initBannedWordsList = function(bannedWordList)
	{
		if(!jQuery.isEmptyObject(bannedWordList))
		{
			if(this.firstTime)
			{
				this.firstTime = false;
				for(var index = 0;index < bannedWordList.length;index++)
				{
					this.bannedWordArray.push(bannedWordList[index].toLocaleLowerCase().trim());
				}
			}
		}
	}
	/*
		text - the input that we need to find if there is 
		banned word in him
		output : true  - contain banWord
				 false - text free from banned words 
	 */
	this.containBannedWords = function(text)
	{
		text = text.toLocaleLowerCase();
		var ans = false;
		$('.BanWordList').html('');
		bandWordsList = ''
		//replace all spiceal charc like in IC_BannedWords
		for(var spIndex =0; spIndex<this.specialCharc;spIndex++)
		{
			text = text.split(this.specialCharc[spIndex]).join(' ');
		}
        text= text.replace(/[\n\r]/g, ' ');
		for(var banWordIndex = 0;banWordIndex<this.bannedWordArray.length;
			banWordIndex++)
		{
			var banWord =this.bannedWordArray[banWordIndex];
			var n = text.search(new RegExp("\\b" + banWord+ "\\b", "g"));
			if(
				(n > -1  && ((text[n-1] == ' ' || text[n-1] == undefined) ||(text[n+banWord.length] == ' ' || text[n+banWord.length] == undefined)))
			)
			{
				bandWordsList += banWord + ',';
				ans = true;
			}

		}
		$('.BanWordList').html(bandWordsList.substring(0, bandWordsList.length - 1));
		return ans
	}
}).apply(bannedWordHandler);