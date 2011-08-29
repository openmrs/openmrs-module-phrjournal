package org.openmrs.module.phrjournal.extension.html;

import org.openmrs.api.context.Context;
import org.openmrs.module.Extension;
import org.openmrs.module.web.extension.PatientDashboardTabExt;

public class PatientJournalTab extends PatientDashboardTabExt {

    /**
     * default constructor: set display order attribute
     */
    public PatientJournalTab() {
        super();
        String order = Context.getAdministrationService().getGlobalProperty("phrjournal.PatientJournalTab.displayorder");
        this.setOrder(Integer.valueOf(order==null? "6": order));
    }
    
	public Extension.MEDIA_TYPE getMediaType(){
		return Extension.MEDIA_TYPE.html;
	}
	
	@Override
	public String getPortletUrl() {
		return "journalTab";
	}

	@Override
	public String getTabId() {
		return "phrjournal";
	}

	@Override
	public String getTabName() {
		return "My Journal";
	}

    @Override
    public String getRequiredPrivilege() {
        return "View Journal";
    }

}
