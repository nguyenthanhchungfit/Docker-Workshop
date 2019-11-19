/*
 * Copyright (c) 2012-2016 by Zalo Group.
 * All Rights Reserved.
 */
package com.vng.zing.usermanagementapps.servers;

import com.vng.zing.jettyserver.WebServers;
import com.vng.zing.usermanagementapps.handlers.StatsHandler;
import com.vng.zing.usermanagementapps.handlers.TrackHandler;
import org.eclipse.jetty.servlet.ServletHandler;

/**
 *
 * @author namnq
 */
public class HServers {

	public boolean setupAndStart() {
		WebServers servers = new WebServers("usermanagementapps");
		ServletHandler handler = new ServletHandler();
		handler.addServletWithMapping(TrackHandler.class, "/track");
		handler.addServletWithMapping(StatsHandler.class, "/stats");
		servers.setup(handler);
		return servers.start();
	}
}
