/*
dustUtil are made all the preprocessing of the dusttempale 
 */

var dustUtil =
{
	compileDustTemplates : function()
	{
		var removeSpaces = function(s)
		{
			return s.replace(/^[\t]+|[\t ]+$|[\n\r]+/gm, '').replace(/[\t ]{2,}/gm, '');
		}

		$('script[type="text/dust-template"]').each(function () {
			dust.compileFn(removeSpaces(this.innerHTML), this.id);
		});
	},

	dustRender : function(template, data, container, callback)
	{
		dust.render(
			template,
			data,
			function (e, html)
			{
				if (e)
				{
					return;
				}

				if(container)
				{
					container.append(html);
				}

				if(callback)
				{
					callback();
				}
			}
		);
	}

};
window.UTILS = dustUtil;