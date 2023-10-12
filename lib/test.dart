import 'dart:async';

Future<int> fetchValue() async {
  // Giả lập một công việc bất đồng bộ, ví dụ lấy dữ liệu từ mạng.
  await Future.delayed(const Duration(seconds: 2)); // Đợi 2 giây (ví dụ)

  // Trả về một giá trị kiểu int
  return 42;
}

void main() async {
  int result = await fetchValue(); // Chuyển đổi Future<int> thành int
  print("Giá trị đã giải quyết từ Future: $result");
}