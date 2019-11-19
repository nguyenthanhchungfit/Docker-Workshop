/*
 * Copyright (c) 2012-2016 by Zalo Group.
 * All Rights Reserved.
 */
package com.vng.zing.usermanagementapps.model;

import com.vng.zing.logger.ZLogger;
import com.vng.zing.stats.Profiler;
import com.vng.zing.stats.ThreadProfiler;
import java.io.PrintWriter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.log4j.Logger;

/**
 * @Note: Class model xử lý business chính cho mỗi loại handler/controller ,
 * được thiết kế theo pattern Singleton Object, thiết kế kiểu này cho phép các
 * Model object truy xuất được lẫn nhau (cùng package nên truy xuất được các
 * thuộc tính protected của nhau), có thể bổ sung thiết kế bằng cách tạo ra 1
 * BaseModel xử lý các hàm tiện ích chung, các Biz Model khác thừa kế từ đó
 *
 * @author namnq
 */
public class StatsModel extends BaseModel {

	private static final Logger _Logger = ZLogger.getLogger(StatsModel.class);
	public static final StatsModel Instance = new StatsModel();

	private StatsModel() {
	}

	@Override
	public void process(HttpServletRequest req, HttpServletResponse resp) {
		ThreadProfiler profiler = Profiler.getThreadProfiler();
		resp.setContentType("text/html; charset=UTF-8");
		PrintWriter out = null;
		try {
			out = resp.getWriter();
			///TODO..
			profiler.push(this.getClass(), "output");
			out.println("You are accessing /stats");
			profiler.pop(this.getClass(), "output");
		} catch (Exception ex) {
			_Logger.error(null, ex);
		} finally {
			if (out != null) {
				out.close();
			}
		}
	}
}
