/*
 * create TabObj object
 * Oct 2016 / Xavier Templet /  add test key !== 'sessionId' to avoid json error with firefox 
 */

function createUpdateTableInTabObj (id, status, root,comment,channel)
{
	return {id:id,status:status ,root:root, comment:comment, channel:channel}
}

/*
add TabObj object to the list of the surveys we need to update
 */
function setObjectInWebStorage(obj)
{
	localStorage.setItem(obj.id, JSON.stringify(obj));
}

/*
get TabObj by Key
 */
function getObjectInWebStorage(key)
{
	//console.log('localStorage: '+localStorage.getItem(key));
	return JSON.parse(localStorage.getItem(key));
}


function changeSurveyLocal(id,status)
{
	localStorages.setItem(id,status);
}

/*
	itarate all localStorage vars and if this key is not the 'sfdc.h_and_t.cookieset' that SF generate
	it's a TabObj and we need to update the date in the table
 */
function updatePage()
{
	var wasChange = 0;
	for ( var i = 0, len = localStorage.length; i < len; ++i ) 
	{
		key = localStorage.key( i );
		if(key !== 'sfdc.h_and_t.cookieset')
		{
			if(updateDataFromServer(key,getObjectInWebStorage(key)))
			{
			  wasChange ++;
			}
		}

	}
	
}


/*
	get-id:survey id
		newstatus: the status that this survey should change to.

	res: check if this id are in the smartTable.jsonData (are appear in the console table at all)
	if not - remove him from the localStroage and re false..
	otherwise - true;
 */
updateDataFromServer = function (id,newstatus)
{
	if(smartTable.jsonData && smartTable.jsonData.length > 0)
	{
		var result = smartTable.jsonData.filter(function(v) {
			return v.survey.Id === id; // filter out appropriate one
		})[0];
		if(result)
		{
			changeInTable(id, newstatus);
			localStorage.removeItem(id);
			return true;
		}

	}
	else
	{
		localStorage.removeItem(id); //there is nothing in the big query so there is nothing to update !
	}
	return false;
}

/*
	changeInTable
		get-id:survey id
		newstatus: the status that this survey should change to.
	res:
	if this survey id are appear in the console table
	update him.

 */
function changeInTable (id, newstatus)
{
	updateRootChannelCommentHistory(id, newstatus.root, newstatus.channel, newstatus.comment);
	updateStatus(id, newstatus.status);
}


/*
Listener to the localStorage to see if there is any update that we need to do, that came from other tab.

 */
setInterval(function(){ 
	for ( var i = 0, len = localStorage.length; i < len; ++i )
	{
		key = localStorage.key( i );
		//console.log('key: '+key);

		if((key !== 'sfdc.h_and_t.cookieset') && (key !== 'sessionId'))
		{
			updatePage();
			console.log('ChangeTable');   
	    }
	}
}, 3000);