enum Flavor {
  FOSS,
  PROD
}
class BuildFlavor {
  static Flavor flavor = Flavor.PROD;
  static bool get isFoss => flavor == Flavor.FOSS;
}