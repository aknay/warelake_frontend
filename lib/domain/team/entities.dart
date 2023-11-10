import 'package:inventory_frontend/data/currency.code/valueobject.dart';

class Team {
  // Generated by server
  String? id;

  // Required fields
  String name;
  String? contactName;
  String? email;
  String? country;
  String? countryCode;
  String? createdBy;
  bool? isSKUEnabled;
  bool? isSalesInclusiveTaxEnabled;
  String? salesTaxType;
  bool? taxGroupEnabled;
  String? languageCode;

  // Required fields
  String timeZone;
  String currencyCode;

  int? pricePrecision;
  int? planType;
  String? planName;
  String? planPeriod;
  String? accountCreatedDate;
  bool? isOrgActive;
  bool? isQuickSetupCompleted;
  bool? isDefaultOrg;

  Team({
    // Generated by server
    this.id,

    // Required fields
    required this.name,
    this.contactName,
    this.email,
    this.country,
    this.countryCode,
    this.createdBy,
    this.isSKUEnabled,
    this.isSalesInclusiveTaxEnabled,
    this.salesTaxType,
    this.taxGroupEnabled,
    this.languageCode,

    // Required fields
    required this.timeZone,
    required this.currencyCode,
    this.pricePrecision,
    this.planType,
    this.planName,
    this.planPeriod,
    this.accountCreatedDate,
    this.isOrgActive,
    this.isQuickSetupCompleted,
    this.isDefaultOrg,
  });

  factory Team.create({required String name, required String timeZone, required CurrencyCode currencyCode}) {
    return Team(name: name, timeZone: timeZone, currencyCode: currencyCode.name);
  }

  // Factory method to create a Team instance from a JSON map
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['team_id'],
      name: json['name'],
      contactName: json['contact_name'],
      email: json['email'],
      country: json['country'],
      countryCode: json['country_code'],
      createdBy: json['created_by'],
      isSKUEnabled: json['is_sku_enabled'],
      isSalesInclusiveTaxEnabled: json['is_sales_inclusive_tax_enabled'],
      salesTaxType: json['sales_tax_type'],
      taxGroupEnabled: json['tax_group_enabled'],
      languageCode: json['language_code'],
      timeZone: json['time_zone'],
      currencyCode: json['currency_code'],
      pricePrecision: json['price_precision'],
      planType: json['plan_type'],
      planName: json['plan_name'],
      planPeriod: json['plan_period'],
      accountCreatedDate: json['account_created_date'],
      isOrgActive: json['is_org_active'],
      isQuickSetupCompleted: json['is_quick_setup_completed'],
      isDefaultOrg: json['is_default_org'],
    );
  }

  // Method to convert the Team instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'team_id': id,
      'name': name,
      'contact_name': contactName,
      'email': email,
      'country': country,
      'country_code': countryCode,
      'created_by': createdBy,
      'is_sku_enabled': isSKUEnabled,
      'is_sales_inclusive_tax_enabled': isSalesInclusiveTaxEnabled,
      'sales_tax_type': salesTaxType,
      'tax_group_enabled': taxGroupEnabled,
      'language_code': languageCode,
      'time_zone': timeZone,
      'currency_code': currencyCode,
      'price_precision': pricePrecision,
      'plan_type': planType,
      'plan_name': planName,
      'plan_period': planPeriod,
      'account_created_date': accountCreatedDate,
      'is_org_active': isOrgActive,
      'is_quick_setup_completed': isQuickSetupCompleted,
      'is_default_org': isDefaultOrg,
    };
  }
}
