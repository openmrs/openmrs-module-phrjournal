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
package org.openmrs.module.phrjournal.web.controller;

import java.util.ArrayList;
import java.util.HashSet;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.openmrs.Person;
import org.openmrs.User;
import org.openmrs.api.context.Context;
import org.openmrs.module.personalhr.PhrService;
import org.openmrs.module.phrjournal.JournalEntryService;
import org.openmrs.module.phrjournal.domain.JournalEntry;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;


@Controller
public class JournalController {

	@RequestMapping(value="/module/phrjournal/journal", method=RequestMethod.GET)
	public void getEntry(@RequestParam(value="patientId",required=false) Integer patientId,
	                     @RequestParam(value="id",required=false) Integer id,
	                     @RequestParam(value="search",required=false) String searchText,
	                     @RequestParam(value="displayAll",required=false) String displayAll,
	                     HttpServletRequest request){
		HttpSession session = request.getSession();
		session.setAttribute("hasPermission",true);
		session.setAttribute("searching",false);
		User user = Context.getAuthenticatedUser();
		Person per = null;
	    if(patientId == null) {
	        patientId = (Integer) session.getAttribute("patientId");
	    }
		if(patientId == null) {
		    per = user.getPerson(); 
		} else {
		    per = Context.getPatientService().getPatient(patientId);
            session.setAttribute("patientId", patientId);
		}
		
		if(id != null){
			List<JournalEntry> entries = new ArrayList<JournalEntry>();
			JournalEntry entry= Context.getService(JournalEntryService.class).getJournalEntry(id);
			List<JournalEntry> comments = Context.getService(JournalEntryService.class).findComments(entry);
			entries.add(entry);
			entries.addAll(comments);
			if(hasPermission(user,patientId)){
				session.setAttribute("entries", entries);
			}else{
				session.setAttribute("hasPermission",false);
			}
		}else if(searchText != null && !searchText.trim().equals("") && displayAll == null){
			List<JournalEntry> entries = ((JournalEntryService) Context.getService(JournalEntryService.class)).findEntries(searchText, per, true);
			addMissingParents(entries);
			session.setAttribute("entries", entries);
			session.setAttribute("searching",true);
		}else{
			List<JournalEntry> entries = Context.getService(JournalEntryService.class).getJournalEntryForPerson(per,true);
            addMissingComments(entries);
			session.setAttribute("entries", entries);
		}
	}
	
	/**
     * Add missing parent entries for comments
     * 
     * @param entries original entries found through search
     */
    private void addMissingParents(List<JournalEntry> entries) {
        // TODO Auto-generated method stub
        HashSet<Integer> parents = new HashSet<Integer>();
        for(JournalEntry entry : entries) {
            Integer parentId = entry.getParentEntryId();
            if(parentId!=null) {
                parents.add(parentId);
            }
        }
        
        for(Integer parent : parents) {
            boolean exists = false;
            for(JournalEntry entry : entries) {
                if(entry.getEntryId().equals(parent)) {
                    exists = true;
                    break;
                }
            }
            if(!exists) {
                JournalEntry entry= Context.getService(JournalEntryService.class).getJournalEntry(parent);
                entries.add(entry);
            }
        }        
    }
    
    /**
     * Add missing comments written by doctors or caregivers
     * 
     * @param entries original entries found through search
     */
    private void addMissingComments(List<JournalEntry> entries) {
        // TODO Auto-generated method stub
        HashSet<JournalEntry> parents = new HashSet<JournalEntry>();
        for(JournalEntry entry : entries) {
            Integer parentId = entry.getParentEntryId();
            if(parentId==null) {
                parents.add(entry);
            }
        }
        
        for(JournalEntry parent : parents) {
            List<JournalEntry> comments = Context.getService(JournalEntryService.class).findComments(parent);
            for(JournalEntry comment : comments) {
                if(!comment.getCreator().getPersonId().equals(parent.getCreator().getPersonId())) {
                    entries.add(comment);
                }
            }
        }        
    }
    

    private boolean hasPermission(User u, Integer id){
	    PhrService ps = Context.getService(PhrService.class);
	    
	    if(id==null || u==null) {
	        return false;
	    } 
	    
		return ps.hasPrivilege("View Journal", Context.getPatientService().getPatient(id), null, u);
	}
}