enum ErrorCode {
  clientError,
  serverError,
  memberNotFound,
  memberExists,
  groupNotFound,
  groupStatusIsDeleted,
}

extension MyEnumExtension on ErrorCode {
  String get value {
    switch (this) {
      case ErrorCode.serverError:
        return "server_error";
      case ErrorCode.memberNotFound:
        return "member_not_found";
      case ErrorCode.memberExists:
        return "member_exists";
      case ErrorCode.groupNotFound:
        return "group_not_found";
      case ErrorCode.clientError:
        return "client_error";
      case ErrorCode.groupStatusIsDeleted:
        return "group status is deleted";
    }
  }
}

class ErrorResponse {
  final ErrorCode code;
  final String message;
  final int statusCode;

  const ErrorResponse({required this.code, required this.message, required this.statusCode});

  bool get isUnauthorizedError => statusCode == 401;
  bool get isUnsettleDebtError => statusCode == 402;

  factory ErrorResponse.withStatusCode({required String message, required int statusCode}) {
    return ErrorResponse(code: ErrorCode.clientError, message: message, statusCode: statusCode);
  }

  factory ErrorResponse.withOtherError({required String message}) {
    return ErrorResponse(code: ErrorCode.clientError, message: message, statusCode: -1);
  }

  factory ErrorResponse.fromJson({required Map<String, dynamic> json, required int statusCode}) {
    Map<String, dynamic> error = json['error'];
    final code = ErrorCode.values.firstWhere((e) => e.value == error["code"]);
    return ErrorResponse(code: code, message: error["message"], statusCode: statusCode);
  }
}