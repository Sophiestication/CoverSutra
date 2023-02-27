(: The XQuery prolog, where we set up the variables we're expecting :)
declare variable $AppleTopicListStyleSheetURL as xs:string external;
declare variable $AppleTopicListHeadline as xs:string external;
declare variable $AppleTopicListResults external;

<html>
	<head>
		<title>{$AppleTopicListHeadline}</title>
		<link href="{$AppleTopicListStyleSheetURL}" rel="stylesheet" media="all"/>
	</head>
	<body id="apple-pd">
		<div id="navbox" class="gradient">
			<div id="navleftbox">
				<a class="navlink_left" href="help:anchor='access' bookID=com.apple.machelp">Home</a></div>
			<div id="navrightbox">
				<a class="navlink_right" href="help:anchor='xall' bookID=com.apple.machelp">Index</a></div>
		</div>
		<div id="list">
		<h1>{$AppleTopicListHeadline}</h1>
{
	for $item in $AppleTopicListResults
	return <p><a href="{data($item/url)}">{data($item/title)}</a></p>
}
		</div>
	</body>
</html>