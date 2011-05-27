<%@ include file="/WEB-INF/template/include.jsp" %>
<div id="journal-div"  >
		<div class="tooltipPhr">
		<spring:message code="phrjournal.tooltip.journal"/>
		</div>
		<iframe src ="${pageContext.request.contextPath}/module/phrjournal/journal.form?patientId=${model.patientId}" width="100%" height="800">
		Loading Journal Page...
		</iframe>
</div>