/*
 * Copyright (c) 2012-2016 by Zalo Group.
 * All Rights Reserved.
 */
package com.vng.zing.usermanagementapps.common;

import com.googlecode.htmlcompressor.compressor.HtmlCompressor;
import com.vng.zing.logger.ZLogger;
import hapax.Template;
import hapax.TemplateException;
import hapax.TemplateLoader;
import hapax.TemplateResourceLoader;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import org.apache.log4j.Logger;
import org.json.simple.JSONValue;

/**
 *
 * @author triettv
 */
public class TemplateManager {

	private static final Logger _Logger = ZLogger.getLogger(TemplateManager.class);
	private static ConcurrentMap<String, TemplateLoader> _InstMap = new ConcurrentHashMap<String, TemplateLoader>();

	public static TemplateLoader getTemplateLoader(String baseDir) {
		assert (baseDir != null);
		String key = baseDir.trim();
		TemplateLoader ret = _InstMap.get(key);
		if (ret == null) {
			ret = TemplateResourceLoader.create(key);
			TemplateLoader old = _InstMap.putIfAbsent(key, ret);
			if (old != null) {
				ret = old;
			}
		}
		return ret;
	}

	public static Template getTemplate(String tplName) throws TemplateException {
		TemplateLoader temploader = TemplateManager.getTemplateLoader("view/");
		return temploader.getTemplate(tplName);
	}

	public static Template getTemplate(String baseDir, String tplName) throws TemplateException {
		TemplateLoader temploader = getTemplateLoader(baseDir);
		return temploader.getTemplate(tplName);
	}

	public static Template getTemplateJsonCompressed(String baseDir, String tplName) throws TemplateException {
		TemplateLoader temploader = getTemplateLoader(baseDir);
		Template tpl = temploader.getTemplateFromString(tplName);
		if (tpl == null) {
			String tpl_data;
			try {
				tpl_data = temploader.getTplData(tplName);
				if (tpl_data == null) {
					return null;
				}
				HtmlCompressor compressor = new HtmlCompressor();
				tpl_data = compressor.compress(tpl_data);
				tpl_data = JSONValue.toJSONString(tpl_data);
				tpl = temploader.getTemplateFromString(tplName, tpl_data);
			} catch (Exception ex) {
				_Logger.error(null, ex);
				return null;
			}

		}
		return tpl;
	}
}
