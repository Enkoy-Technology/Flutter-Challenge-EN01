// ignore_for_file: file_names

class ResponseData<T> {
  final bool isSuccessful;
  final T? data;
  final List<String> errorMessages;
  final dynamic additionalParameters;

  ResponseData(
      {required this.isSuccessful,
      this.errorMessages = const [],
      this.data,
      this.additionalParameters});

  factory ResponseData.fromJson(dynamic json,
      {T Function(dynamic data)? dataParser}) {
    return ResponseData<T>(
        data: dataParser != null && json["isSuccessful"]
            ? dataParser(json["data"])
            : null,
        errorMessages: List<String>.from(json["errorMessages"] ?? []),
        isSuccessful: json["isSuccessful"],
        additionalParameters: json["additionalParameters"]);
  }
}
