/// Model đại diện cho một giải đấu bóng đá từ FootballData API
class LeagueModel {
  final String id;
  final String name;
  final String country;
  final String? logo;
  final String? countryFlag;
  final String? season;
  final int? totalTeams;
  final bool isActive;

  const LeagueModel({
    required this.id,
    required this.name,
    required this.country,
    this.logo,
    this.countryFlag,
    this.season,
    this.totalTeams,
    this.isActive = true,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    // API trả về: league_id, league_name, country, league_image
    final name = json['league_name'] as String? ??
        json['name'] as String? ??
        json['competition_name'] as String? ??
        '';
    final logo = json['league_image'] as String? ??
        json['logo'] as String? ??
        json['league_logo'] as String?;
    return LeagueModel(
      id: (json['league_id'] ?? json['id'] ?? '').toString(),
      name: name,
      country: json['country'] as String? ?? '',
      logo: logo,
      countryFlag: json['country_flag'] as String?,
      season: json['season']?.toString(),
      totalTeams: json['total_teams'] as int?,
      isActive: (json['active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'league_id': id,
        'name': name,
        'country': country,
        'logo': logo,
        'country_flag': countryFlag,
        'season': season,
        'total_teams': totalTeams,
        'active': isActive,
      };
}
