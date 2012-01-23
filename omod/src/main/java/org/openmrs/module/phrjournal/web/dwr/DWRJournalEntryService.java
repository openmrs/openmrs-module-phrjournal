/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.phrjournal.web.dwr;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.module.phrjournal.JournalEntryService;
import org.openmrs.module.phrjournal.domain.JournalEntry;

public class DWRJournalEntryService {	
	
	public List<JournalEntry> getJournalEntries(){
        HttpSession session = uk.ltd.getahead.dwr.WebContextFactory.get().getSession(false);
        Integer patientId = (Integer) session.getAttribute("patientId");
        Person per = (patientId==null? Context.getAuthenticatedUser().getPerson() : Context.getPatientService().getPatient(patientId));
		return Context.getService(JournalEntryService.class).getJournalEntryForPerson(per, true);
	}
	
	public void softDeleteEntry(Integer entryId){
		JournalEntryService journalService = Context.getService(JournalEntryService.class); 
		JournalEntry entry = journalService.getJournalEntry(entryId);
		journalService.softDelete(entry);
	}
	
    public void saveComment(String newComment, Integer parentEntryId){
        JournalEntryService journalService = Context.getService(JournalEntryService.class); 
        JournalEntry entry = new JournalEntry("Comment", newComment);
        entry.setParentEntryId(parentEntryId);
        entry.setCreator(Context.getAuthenticatedUser().getPerson());
        journalService.saveJournalEntry(entry);
    }	
}
