/*
 * Copyright (c) 2012-2016 by Zalo Group.
 * All Rights Reserved.
 */
package com.vng.zing.usermanagementapps.model;

import com.vng.zing.logger.ZLogger;
import com.vng.zing.stats.Profiler;
import com.vng.zing.stats.ThreadProfiler;
import org.apache.log4j.Logger;
import org.apache.thrift.TException;

/**
 * @Note: Class model xử lý business chính cho mỗi loại handler , được thiết kế
 * theo pattern Singleton Object, thiết kế kiểu này cho phép các Model object
 * truy xuất được lẫn nhau (cùng package nên truy xuất được các thuộc tính
 * protected của nhau), có thể bổ sung thiết kế bằng cách tạo ra 1 TBaseModel xử
 * lý các hàm tiện ích chung, các Biz Model khác thừa kế từ đó
 *
 * @author namnq
 */
public class TCalcModel {

	private static final Logger _Logger = ZLogger.getLogger(TCalcModel.class);
	public static final TCalcModel Instance = new TCalcModel();

	private TCalcModel() {
	}

	public long plus(int a, int b) throws TException {
		ThreadProfiler profiler = Profiler.getThreadProfiler();
		profiler.push(this.getClass(), "dowork");
		long ret = a + b;
		profiler.pop(this.getClass(), "dowork");
		_Logger.debug(String.format("plus(%d, %d) = %d", a, b, ret));
		return ret;
	}

	public long multiply(int a, int b) throws TException {
		ThreadProfiler profiler = Profiler.getThreadProfiler();
		profiler.push(this.getClass(), "dowork");
		long ret = a * b;
		profiler.pop(this.getClass(), "dowork");
		_Logger.debug(String.format("multiply(%d, %d) = %d", a, b, ret));
		return ret;
	}
}
