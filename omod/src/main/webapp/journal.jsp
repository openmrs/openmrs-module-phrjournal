<%@ include file="/WEB-INF/view/module/personalhr/template/include.jsp" %>
<personalhr:require privilege="View Journal" otherwise="/phr/login.htm" redirect="/module/phrjournal/journal.form" />

<c:if test="${hasPermission}">

<openmrs:globalProperty var="phrStarted" key="personalhr.started" defaultValue="false"/>
<c:if test="${phrStarted}">
	<%@ page import="org.openmrs.web.WebConstants" %>
	<%
		 session.setAttribute(WebConstants.OPENMRS_HEADER_USE_MINIMAL, "true");
	%>
</c:if>

<%@ include file="/WEB-INF/template/header.jsp"%>
<openmrs:htmlInclude file="/dwr/engine.js" />	

<link rel="stylesheet" href="<openmrs:contextPath/>/moduleResources/phrjournal/css/journal.css" type="text/css"/>

	<div id="module-content">
		<div id="nav-bar">
			<openmrs:hasPrivilege privilege="PHR Single Patient Access">
				<button id="new-entry-button" type="button" onclick="newEntry(); return false;">New Entry</button>
			</openmrs:hasPrivilege>
			<div id="entries-by-month-nav">
				 <span id="month-title-span">Past Entries</span>
				<ol id="month-list"></ol>
			</div>
		</div>
		<div id="entry-pane">
			<div id="search-pane">
				<span id="search-text"></span>
				<div id="search-action-div">  
					<form id="search-form" method="get" action="<openmrs:contextPath/>/module/phrjournal/journal.form">  
						<input type="text" id="search-box" name="search" ></input>
						<input id="search-button" type="submit" value="Search"></input>
						<input id="display-all-button" type="submit" value="Display All Entries" name="displayAll"></input>
					</form>
				</div>
			</div>
			<openmrs:hasPrivilege privilege="PHR Single Patient Access">
				<c:if test="${empty entries}">
					<c:if test="${searching}">
						<div id="no-results">
							<span id="no-results-text">There were no entries matching your search.</span>
						</div>
					</c:if>
					<c:if test="${!searching}">
						<div id="no-results">
							<span id="no-results-text">You don't have any journal entries yet.<br><br> Why don't you <a href="<openmrs:contextPath/>/module/phrjournal/new_entry.form">write</a> one?</span>
						</div>
					</c:if>
				</c:if>
			</openmrs:hasPrivilege>
			<c:forEach var="entry" items="${entries}">
			  <c:if test="${entry.parentEntryId==null}">
				<div class="entry">
					<div class="title-bar">
						<span class="entry-title">${entry.title}</span>
						<span class="entry-date">
							<openmrs:formatDate date="${entry.dateCreated}" format="MM/dd/yyyy K:mm a"/>
							<openmrs:hasPrivilege privilege="PHR Single Patient Access">
								<a href="#" id="delete=entry-${entry.entryId}" onclick="deleteEntry(${entry.entryId},&quot;${entry.title}&quot;)">
									<img src="<openmrs:contextPath/>/moduleResources/phrjournal/img/delete.png" title="Delete Entry"/>
								</a>
							</openmrs:hasPrivilege>
						</span>
					</div>
					<div class="entry-content" >${entry.content}</div>
					<br/>
					<c:forEach var="entry_comment" items="${entries}">
					  <c:if test="${entry_comment.parentEntryId!=null && entry_comment.parentEntryId==entry.entryId}">					
						<div class="comment-title-bar">
							<span class="comment-title">${entry_comment.title}</span>
							<span class="comment-date">
								<openmrs:formatDate date="${entry_comment.dateCreated}" format="MM/dd/yyyy K:mm a"/>
  							    <span class="comment-author">by ${entry_comment.creator.personName.fullName}</span>
								<openmrs:hasPrivilege privilege="PHR Single Patient Access">
									<a href="#" id="delete=entry-${entry_comment.entryId}" onclick="deleteEntry(${entry_comment.entryId},&quot;${entry_comment.title}&quot;)">
										<img src="<openmrs:contextPath/>/moduleResources/phrjournal/img/delete.png" title="Delete Entry"/>
									</a>
								</openmrs:hasPrivilege>
							</span>
						</div>
						<div class="comment-content" >${entry_comment.content}</div>	
						<br/>
					  </c:if>				
					</c:forEach>
					
					<div id="edit-comment-panel-${entry.entryId}" style="display:none;">
						COMMENT: <textarea id="comment-${entry.entryId}" rows="3" cols="80"></textarea>
					</div>
					<br/>
					<div id="comment-button-panel-${entry.entryId}">
						<button id="leave-comment-button-${entry.entryId}" onclick="addCommentClick(${entry.entryId})">Leave a Comment</button>
						<button id="cancel-comment-button-${entry.entryId}"  style="display:none;" onclick="cancelCommentClick(${entry.entryId})">Cancel</button>
						<button id="save-comment-button-${entry.entryId}"  style="display:none;" onclick="saveCommentClick(${entry.entryId})">Save</button>
					</div>
					<br/>
				</div>
			  </c:if>				
			</c:forEach>
		</div>
	</div>

<%@ include file="/WEB-INF/template/footer.jsp" %>
<openmrs:htmlInclude file="/dwr/engine.js"/>
<openmrs:htmlInclude file="/dwr/util.js"/>
<script src="<openmrs:contextPath/>/dwr/interface/DWRJournalEntryService.js"></script>
<script type="text/javascript">
	var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];

	$j(document).ready(function(){
		DWRJournalEntryService.getJournalEntries(function(posts){createNavList(posts);});
		$j("#search-box").val(gup("search"));
		
	});

	function gup(name){
	  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	  var regexS = "[\\?&]"+name+"=([^&#]*)";
	  var regex = new RegExp( regexS );
	  var results = regex.exec( window.location.href );
	  if( results == null )
	    return "";
	  else
	    return results[1];
	}
	
	function newEntry(){
		window.location="new_entry.form";
	}
	
	function createNavList(posts){
		var postsByMonth={};
		for(var i = 0; i < posts.length; i++){
			var post = posts[i];
			if(post.parentEntryId==null) {
				var postMonth = new Date(post.dateCreated).getMonth()
				if(!(postMonth in postsByMonth)){ 
					postsByMonth[postMonth] = [post];
				}else{
					postsByMonth[postMonth].push(post);
				}
			}
		}
		for(var monthSet in postsByMonth){
			createMonth(postsByMonth[monthSet]);
		}
	}
	
	function createMonth(posts){
		var listHTML = "<li><span class=\"month-link\" onclick=\"expand('#id-list')\" id=\"#id-link\">#mon</span><ol id=\"#id-list\" style=\"display:none;\"></ol></li>"
		var date = new Date(posts[0].dateCreated);
		var idString = date.getMonth() + "-" + date.getFullYear();
		var monthString = months[date.getMonth()];
		listHTML = listHTML.replace(new RegExp("#id",'g'),idString);
		listHTML = listHTML.replace(new RegExp("#mon",'g'),monthString);
		var monthList = $j(listHTML);
		for(var i = 0; i < posts.length; i++){
			$j("<li><a class=\"post-link\" href=\"<openmrs:contextPath/>/module/phrjournal/journal.form?id="+posts[i].entryId+"\">"+posts[i].title+"</a></li>").appendTo(monthList.find("#"+idString+"-list"));
		}
		monthList.appendTo("#month-list");
	}
	
	function expand(toExpand){
		$j("#"+toExpand).toggle(100);
	}

	function deleteEntry(entryId,entryTitle){
		if(confirm("Are your sure you want to delete \""+ entryTitle + "\"?")){
			DWRJournalEntryService.softDeleteEntry(entryId,function(){
				location.reload(true);
			});
		}
	}
	
	//
	//Leave a Comment handling
	//
	function addCommentClick(entryId){
		toggleEditingComment(entryId);
	}
	
	function cancelCommentClick(entryId){
		toggleEditingComment(entryId);
		//clearEditingArea();
	}
	
	function saveCommentClick(entryId){
		writeComment(entryId);
		//toggleEditingComment(entryId);
	}
	
	function toggleEditingComment(entryId){
		if ($j("#edit-comment-panel-"+entryId).is(":hidden")) {
			$j("#edit-comment-panel-"+entryId).slideDown("fast", function(){
				$j("#leave-comment-button-"+entryId).toggle();
				$j("#save-comment-button-"+entryId).toggle();
				$j("#cancel-comment-button-"+entryId).toggle();
			});
		}else{
			$j("#edit-comment-panel-"+entryId).slideUp("fast", function(){
				$j("#leave-comment-button-"+entryId).toggle();
				$j("#save-comment-button-"+entryId).toggle();
				$j("#cancel-comment-button-"+entryId).toggle();
			});
		}
	}	

	function writeComment(entryId) {
		  var newComment = dwr.util.getValue("comment-"+entryId);
		  var parentEntryId = entryId;
		  dwr.engine.beginBatch();
		  DWRJournalEntryService.saveComment(newComment, parentEntryId,function(){
				location.reload(true);
			});
		  //fillAddressTable();
		  //fillAlertAddressSelect();
		  dwr.engine.endBatch();
		  //clearEditingArea();
		  //toggleEditingComment(entryId);
	}	
</script>
</c:if>
<c:if test="${!hasPermission}">
	<h2>You do not have permission to view this journal entry.</h2>
</c:if>