class Role {
  String roleName;
  String id;
  String teamId;
  bool isDefault;
  String roleDescription;
  String status;
  List<Access> accesses;

  Role({
    required this.roleName,
    required this.id,
    required this.teamId,
    required this.isDefault,
    required this.roleDescription,
    required this.status,
    required this.accesses,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleName: json['role_name'],
      id: json['id'],
      teamId: json['team_id'],
      isDefault: json['is_default'],
      roleDescription: json['role_description'],
      status: json['status'],
      accesses: List<Access>.from(json['accesses'].map((x) => Access.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_name': roleName,
      'id': id,
      'team_id': teamId,
      'is_default': isDefault,
      'role_description': roleDescription,
      'status': status,
      'accesses': List<dynamic>.from(accesses.map((x) => x.toJson())),
    };
  }
}

class Access {
  bool canCreate;
  bool fullAccess;
  bool canView;
  bool canDelete;
  bool canEdit;
  List<MorePermission> morePermissions;
  String accessName;

  Access({
    required this.canCreate,
    required this.fullAccess,
    required this.canView,
    required this.canDelete,
    required this.canEdit,
    required this.morePermissions,
    required this.accessName,
  });

  factory Access.fromJson(Map<String, dynamic> json) {
    return Access(
      canCreate: json['can_create'],
      fullAccess: json['full_access'],
      canView: json['can_view'],
      canDelete: json['can_delete'],
      canEdit: json['can_edit'],
      morePermissions: json['more_permissions'] == null ? [] : List<MorePermission>.from(json['more_permissions'].map((x) => MorePermission.fromJson(x))),
      accessName: json['access_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_create': canCreate,
      'full_access': fullAccess,
      'can_view': canView,
      'can_delete': canDelete,
      'can_edit': canEdit,
      'more_permissions': List<dynamic>.from(morePermissions.map((x) => x.toJson())),
      'access_name': accessName,
    };
  }
}

class MorePermission {
  bool isEnabled;
  String permissionFormatted;
  String permission;

  MorePermission({
    required this.isEnabled,
    required this.permissionFormatted,
    required this.permission,
  });

  factory MorePermission.fromJson(Map<String, dynamic> json) {
    return MorePermission(
      isEnabled: json['is_enabled'],
      permissionFormatted: json['permission_formatted'],
      permission: json['permission'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'permission_formatted': permissionFormatted,
      'permission': permission,
    };
  }
}
