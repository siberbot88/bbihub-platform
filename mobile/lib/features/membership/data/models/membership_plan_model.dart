enum BillingCycle { monthly, yearly }

enum MembershipTier { free, premium }

class MembershipPlanModel {
  final String id;
  final String name;
  final String description;
  final MembershipTier tier;
  final int monthlyPrice;
  final int yearlyPrice;
  final bool isRecommended;
  final List<String> featuresIncluded;
  final List<String> featuresExcluded;

  const MembershipPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.monthlyPrice,
    required this.yearlyPrice,
    this.isRecommended = false,
    required this.featuresIncluded,
    this.featuresExcluded = const [],
  });

  // Helper to get price based on cycle
  int getPrice(BillingCycle cycle) {
    return cycle == BillingCycle.monthly ? monthlyPrice : yearlyPrice;
  }
}
