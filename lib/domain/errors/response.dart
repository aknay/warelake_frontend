

enum ErrorCode {
  clientError,
  serverError,
  memberNotFound,
  memberExists,
  groupNotFound,
  groupStatusIsDeleted,
  itemVarationForPersonalPlanLimitExecced,
  unknown,
}

extension MyEnumExtension on ErrorCode {
  int toInt() {
    switch (this) {
      case ErrorCode.itemVarationForPersonalPlanLimitExecced:
        return 3;
      default:
        return -1; // Handle default case as needed
    }
  }

  static ErrorCode fromInt(int value) {
    switch (value) {
      case 3:
        return ErrorCode.itemVarationForPersonalPlanLimitExecced;

      default:
        return ErrorCode.unknown;
    }
  }

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
      case ErrorCode.itemVarationForPersonalPlanLimitExecced:
        return 'item Varation for personal plan limit exceeded';
      case ErrorCode.unknown:
        return 'unknown error';
    }
  }
}

class ErrorResponse {
  final ErrorCode code;
  final String message;
  final int httpStatusCode;

  const ErrorResponse({required this.code, required this.message, required this.httpStatusCode});

  bool get isUnauthorizedError => httpStatusCode == 401;
  bool get isUnsettleDebtError => httpStatusCode == 402;

  factory ErrorResponse.withStatusCode({required String message, required int statusCode}) {
    return ErrorResponse(code: ErrorCode.clientError, message: message, httpStatusCode: statusCode);
  }

  factory ErrorResponse.withOtherError({required String message}) {
    return ErrorResponse(code: ErrorCode.clientError, message: message, httpStatusCode: -1);
  }

  factory ErrorResponse.fromJson({required Map<String, dynamic> json, required int statusCode}) {
    Map<String, dynamic> error = json['error'];
    final code = MyEnumExtension.fromInt(error['code']);
    return ErrorResponse(code: code, message: error["message"], httpStatusCode: statusCode);
  }
}
