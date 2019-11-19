
namespace cpp calc
namespace java com.vng.zing.calc.thrift
namespace php calc

service Calc {
	i64 plus(1:i32 a, 2:i32 b);
	i64 multiply(1:i32 a, 2:i32 b);
}

