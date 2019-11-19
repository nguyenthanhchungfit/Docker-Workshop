/*
 * Copyright (c) 2012-2016 by Zalo Group.
 * All Rights Reserved.
 */
package com.vng.zing.usermanagementapps.handlers;

import com.vng.zing.calc.thrift.Calc;
import com.vng.zing.logger.ZLogger;
import com.vng.zing.stats.Profiler;
import com.vng.zing.stats.ThreadProfiler;
import com.vng.zing.usermanagementapps.model.TCalcModel;
import org.apache.log4j.Logger;
import org.apache.thrift.TException;

/**
 * @Note: Class handler xử lý thrift request, class handler được thiết kế để cho
 * phép tạo rất nhiều object, mỗi object tương đương với 1 request đầu vào
 * (object tạm thời), phần xử lý (implement IFace) chỉ đơn giản gọi lại phần xử
 * lý trong Model tương ứng
 *
 * => Không nên tạo thuộc tính thành viên trong class handler (vì sẽ có rất
 * nhiều object handler được tạo ra), hoặc chỉ tạo các thuộc tính primitive
 * types (boolean, char, short, int, long, float, double), hoặc chỉ tạo thuộc
 * tính static. Nếu cần thì hãy thêm trong class model tương ứng.
 *
 * @author namnq
 */
public class TCalcHandler implements Calc.Iface {

	private static final Logger _Logger = ZLogger.getLogger(TCalcHandler.class);

	@Override
	public long plus(int a, int b) throws TException {
		ThreadProfiler profiler = Profiler.createThreadProfiler("TCalcHandler.plus", false);
		try {
			return TCalcModel.Instance.plus(a, b);
		} finally {
			Profiler.closeThreadProfiler();
		}
	}

	@Override
	public long multiply(int a, int b) throws TException {
		ThreadProfiler profiler = Profiler.createThreadProfiler("TCalcHandler.multiply", false);
		try {
			return TCalcModel.Instance.multiply(a, b);
		} finally {
			Profiler.closeThreadProfiler();
		}
	}
}
