import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/github_service.dart';
import '../models/github_models.dart';

class GitHubProvider with ChangeNotifier {
  final GitHubService _githubService = GitHubService();

  GitHubUser? _user;
  List<GitHubRepository> _repositories = [];
  Map<String, GitHubStats> _repositoryStats = {};
  Map<String, List<GitHubCommit>> _repositoryCommits = {};
  Map<String, List<GitHubIssue>> _repositoryIssues = {};
  Map<String, List<GitHubPullRequest>> _repositoryPullRequests = {};

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _savedToken;

  // Getters
  GitHubUser? get user => _user;
  List<GitHubRepository> get repositories => _repositories;
  Map<String, GitHubStats> get repositoryStats => _repositoryStats;
  Map<String, List<GitHubCommit>> get repositoryCommits => _repositoryCommits;
  Map<String, List<GitHubIssue>> get repositoryIssues => _repositoryIssues;
  Map<String, List<GitHubPullRequest>> get repositoryPullRequests =>
      _repositoryPullRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize provider and load saved token
  Future<void> initialize() async {
    await _loadSavedToken();
  }

  // Set authentication token and save it
  Future<void> setAccessToken(String token) async {
    _githubService.setAccessToken(token);
    _savedToken = token;
    _isAuthenticated = true;
    await _saveToken(token);
    notifyListeners();
  }

  // Load saved token from SharedPreferences
  Future<void> _loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('github_token');
      if (savedToken != null && savedToken.isNotEmpty) {
        _savedToken = savedToken;
        _githubService.setAccessToken(savedToken);
        _isAuthenticated = true;
        // Auto-load user profile if token exists
        await loadUserProfile();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved token: $e');
    }
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('github_token', token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // Clear authentication and remove saved token
  Future<void> clearAuthentication() async {
    _githubService.setAccessToken('');
    _isAuthenticated = false;
    _savedToken = null;
    _user = null;
    _repositories.clear();
    _repositoryStats.clear();
    _repositoryCommits.clear();
    _repositoryIssues.clear();
    _repositoryPullRequests.clear();
    _error = null;

    // Remove saved token from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('github_token');
    } catch (e) {
      print('Error removing saved token: $e');
    }

    notifyListeners();
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    if (!_isAuthenticated) return;

    _setLoading(true);
    try {
      final userData = await _githubService.getUserProfile();
      if (userData != null) {
        _user = GitHubUser.fromJson(userData);
        _error = null;
      } else {
        _error = 'Failed to load user profile';
      }
    } catch (e) {
      _error = 'Error loading user profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load user repositories
  Future<void> loadRepositories({
    String sort = 'updated',
    String direction = 'desc',
  }) async {
    if (!_isAuthenticated) return;

    _setLoading(true);
    try {
      final reposData = await _githubService.getUserRepositories(
        sort: sort,
        direction: direction,
      );
      _repositories = reposData
          .map((repo) => GitHubRepository.fromJson(repo))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Error loading repositories: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load repository statistics
  Future<void> loadRepositoryStats(String owner, String repo) async {
    if (!_isAuthenticated) return;

    final repoKey = '$owner/$repo';
    try {
      final statsData = await _githubService.getRepositoryStats(owner, repo);
      if (statsData != null) {
        _repositoryStats[repoKey] = GitHubStats.fromJson(statsData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading repository stats: $e');
    }
  }

  // Load repository commits
  Future<void> loadRepositoryCommits(
    String owner,
    String repo, {
    String? since,
    String? until,
  }) async {
    if (!_isAuthenticated) return;

    final repoKey = '$owner/$repo';
    try {
      final commitsData = await _githubService.getRepositoryCommits(
        owner,
        repo,
        since: since,
        until: until,
      );
      _repositoryCommits[repoKey] = commitsData
          .map((commit) => GitHubCommit.fromJson(commit))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading repository commits: $e');
    }
  }

  // Load repository issues
  Future<void> loadRepositoryIssues(
    String owner,
    String repo, {
    String state = 'all',
  }) async {
    if (!_isAuthenticated) return;

    final repoKey = '$owner/$repo';
    try {
      final issuesData = await _githubService.getRepositoryIssues(
        owner,
        repo,
        state: state,
      );
      _repositoryIssues[repoKey] = issuesData
          .map((issue) => GitHubIssue.fromJson(issue))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading repository issues: $e');
    }
  }

  // Load repository pull requests
  Future<void> loadRepositoryPullRequests(
    String owner,
    String repo, {
    String state = 'all',
  }) async {
    if (!_isAuthenticated) return;

    final repoKey = '$owner/$repo';
    try {
      final prsData = await _githubService.getRepositoryPullRequests(
        owner,
        repo,
        state: state,
      );
      _repositoryPullRequests[repoKey] = prsData
          .map((pr) => GitHubPullRequest.fromJson(pr))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading repository pull requests: $e');
    }
  }

  // Load all data for a repository
  Future<void> loadRepositoryData(String owner, String repo) async {
    if (!_isAuthenticated) return;

    await Future.wait([
      loadRepositoryStats(owner, repo),
      loadRepositoryCommits(owner, repo),
      loadRepositoryIssues(owner, repo),
      loadRepositoryPullRequests(owner, repo),
    ]);
  }

  // Search repositories
  Future<List<GitHubRepository>> searchRepositories(String query) async {
    if (!_isAuthenticated) return [];

    try {
      final searchData = await _githubService.searchRepositories(query);
      return searchData.map((repo) => GitHubRepository.fromJson(repo)).toList();
    } catch (e) {
      print('Error searching repositories: $e');
      return [];
    }
  }

  // Get repository by full name
  GitHubRepository? getRepositoryByFullName(String fullName) {
    try {
      return _repositories.firstWhere((repo) => repo.fullName == fullName);
    } catch (e) {
      return null;
    }
  }

  // Get commits for a repository
  List<GitHubCommit> getCommitsForRepository(String owner, String repo) {
    return _repositoryCommits['$owner/$repo'] ?? [];
  }

  // Get issues for a repository
  List<GitHubIssue> getIssuesForRepository(String owner, String repo) {
    return _repositoryIssues['$owner/$repo'] ?? [];
  }

  // Get pull requests for a repository
  List<GitHubPullRequest> getPullRequestsForRepository(
    String owner,
    String repo,
  ) {
    return _repositoryPullRequests['$owner/$repo'] ?? [];
  }

  // Get stats for a repository
  GitHubStats? getStatsForRepository(String owner, String repo) {
    return _repositoryStats['$owner/$repo'];
  }

  // Get development activity summary
  Map<String, dynamic> getDevelopmentActivity(String owner, String repo) {
    final commits = getCommitsForRepository(owner, repo);
    final issues = getIssuesForRepository(owner, repo);
    final pullRequests = getPullRequestsForRepository(owner, repo);
    final stats = getStatsForRepository(owner, repo);

    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastMonth = now.subtract(const Duration(days: 30));

    final recentCommits = commits.where((c) => c.date.isAfter(lastWeek)).length;
    final recentIssues = issues
        .where((i) => i.createdAt.isAfter(lastWeek))
        .length;
    final recentPRs = pullRequests
        .where((pr) => pr.createdAt.isAfter(lastWeek))
        .length;

    final monthlyCommits = commits
        .where((c) => c.date.isAfter(lastMonth))
        .length;
    final monthlyIssues = issues
        .where((i) => i.createdAt.isAfter(lastMonth))
        .length;
    final monthlyPRs = pullRequests
        .where((pr) => pr.createdAt.isAfter(lastMonth))
        .length;

    return {
      'recentActivity': {
        'commits': recentCommits,
        'issues': recentIssues,
        'pullRequests': recentPRs,
      },
      'monthlyActivity': {
        'commits': monthlyCommits,
        'issues': monthlyIssues,
        'pullRequests': monthlyPRs,
      },
      'totalActivity': {
        'commits': commits.length,
        'issues': issues.length,
        'pullRequests': pullRequests.length,
        'openIssues': issues.where((i) => i.state == 'open').length,
        'openPRs': pullRequests.where((pr) => pr.state == 'open').length,
        'mergedPRs': pullRequests.where((pr) => pr.state == 'merged').length,
      },
      'stats': stats,
    };
  }

  // Get productivity insights
  List<String> getProductivityInsights(String owner, String repo) {
    final activity = getDevelopmentActivity(owner, repo);
    final insights = <String>[];

    final recentCommits = activity['recentActivity']['commits'] as int;
    final recentIssues = activity['recentActivity']['issues'] as int;
    final recentPRs = activity['recentActivity']['pullRequests'] as int;

    if (recentCommits == 0) {
      insights.add(
        'No commits in the last 7 days. Consider increasing development activity.',
      );
    } else if (recentCommits >= 10) {
      insights.add('High commit activity! Great development momentum.');
    }

    if (recentIssues > recentPRs * 2) {
      insights.add(
        'More issues than PRs. Consider focusing on resolving existing issues.',
      );
    }

    final openIssues = activity['totalActivity']['openIssues'] as int;
    final totalIssues = activity['totalActivity']['issues'] as int;

    if (totalIssues > 0 && (openIssues / totalIssues) > 0.7) {
      insights.add(
        'High ratio of open issues. Consider prioritizing issue resolution.',
      );
    }

    return insights;
  }

  // Get intelligent development insights across all repositories
  Map<String, dynamic> getIntelligentInsights() {
    final insights = <String, dynamic>{};

    if (_repositories.isEmpty) {
      return {
        'overallScore': 0,
        'insights': [
          'No repositories found. Start by creating or cloning some repositories.',
        ],
        'recommendations': [
          'Create your first repository to begin tracking development activity.',
        ],
        'metrics': {},
      };
    }

    // Calculate overall development score
    final overallScore = _calculateOverallScore();
    insights['overallScore'] = overallScore;

    // Generate insights
    final insightList = <String>[];
    final recommendations = <String>[];

    // Language diversity analysis
    final languages = _getLanguageDistribution();
    if (languages.length == 1) {
      insightList.add(
        'You\'re focused on ${languages.keys.first}. Consider diversifying your tech stack.',
      );
      recommendations.add(
        'Try learning a new programming language or framework.',
      );
    } else if (languages.length >= 5) {
      insightList.add(
        'Great language diversity! You\'re working with ${languages.length} different languages.',
      );
    }

    // Repository activity analysis
    final activeRepos = _getActiveRepositories();
    final inactiveRepos = _repositories.length - activeRepos;

    if (inactiveRepos > activeRepos) {
      insightList.add(
        'Most of your repositories are inactive. Consider focusing on fewer projects.',
      );
      recommendations.add(
        'Archive or delete unused repositories to improve focus.',
      );
    } else if (activeRepos >= _repositories.length * 0.8) {
      insightList.add(
        'Excellent! Most of your repositories are actively maintained.',
      );
    }

    // Code quality analysis
    final qualityMetrics = _analyzeCodeQuality();
    if (qualityMetrics['avgStars'] < 5) {
      insightList.add(
        'Your repositories have low visibility. Consider improving documentation and README files.',
      );
      recommendations.add(
        'Add comprehensive README files and documentation to increase repository visibility.',
      );
    }

    // Development velocity analysis
    final velocity = _analyzeDevelopmentVelocity();
    if (velocity['commitsPerWeek'] < 2) {
      insightList.add(
        'Low development velocity detected. Consider setting up a consistent development schedule.',
      );
      recommendations.add(
        'Try committing code at least 2-3 times per week to maintain momentum.',
      );
    } else if (velocity['commitsPerWeek'] > 10) {
      insightList.add(
        'High development velocity! You\'re very active in your repositories.',
      );
    }

    // Issue management analysis
    final issueMetrics = _analyzeIssueManagement();
    if (issueMetrics['openIssueRatio'] > 0.7) {
      insightList.add(
        'High number of open issues. Consider prioritizing issue resolution.',
      );
      recommendations.add(
        'Set aside time each week to address open issues and pull requests.',
      );
    }

    insights['insights'] = insightList;
    insights['recommendations'] = recommendations;
    insights['metrics'] = {
      'totalRepositories': _repositories.length,
      'activeRepositories': activeRepos,
      'languagesUsed': languages.length,
      'totalStars': _repositories.fold<int>(
        0,
        (sum, repo) => sum + (repo.stars ?? 0),
      ),
      'totalForks': _repositories.fold<int>(
        0,
        (sum, repo) => sum + (repo.forks ?? 0),
      ),
      'commitsPerWeek': velocity['commitsPerWeek'],
      'openIssues': issueMetrics['totalOpenIssues'],
      'closedIssues': issueMetrics['totalClosedIssues'],
    };

    return insights;
  }

  // Calculate overall development score (0-100)
  int _calculateOverallScore() {
    int score = 0;

    // Repository count score (max 20 points)
    if (_repositories.length >= 10) {
      score += 20;
    } else if (_repositories.length >= 5) {
      score += 15;
    } else if (_repositories.length >= 1) {
      score += 10;
    }

    // Activity score (max 30 points)
    final activeRepos = _getActiveRepositories();
    final activityRatio = activeRepos / _repositories.length;
    score += (activityRatio * 30).round();

    // Quality score (max 25 points)
    final avgStars =
        _repositories.fold<double>(0, (sum, repo) => sum + (repo.stars ?? 0)) /
        _repositories.length;
    if (avgStars >= 50) {
      score += 25;
    } else if (avgStars >= 10) {
      score += 20;
    } else if (avgStars >= 5) {
      score += 15;
    } else if (avgStars > 0) {
      score += 10;
    }

    // Language diversity score (max 15 points)
    final languages = _getLanguageDistribution();
    if (languages.length >= 5) {
      score += 15;
    } else if (languages.length >= 3) {
      score += 10;
    } else if (languages.length >= 2) {
      score += 5;
    }

    // Documentation score (max 10 points)
    final reposWithDescription = _repositories
        .where(
          (repo) => repo.description != null && repo.description.isNotEmpty,
        )
        .length;
    final docRatio = reposWithDescription / _repositories.length;
    score += (docRatio * 10).round();

    return score.clamp(0, 100);
  }

  // Get language distribution
  Map<String, int> _getLanguageDistribution() {
    final languages = <String, int>{};
    for (final repo in _repositories) {
      if (repo.language != null && repo.language!.isNotEmpty) {
        languages[repo.language!] = (languages[repo.language!] ?? 0) + 1;
      }
    }
    return languages;
  }

  // Get active repositories (updated in last 30 days)
  int _getActiveRepositories() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return _repositories.where((repo) {
      final updatedAt = DateTime.tryParse((repo.updatedAt ?? '') as String);
      return updatedAt != null && updatedAt.isAfter(thirtyDaysAgo);
    }).length;
  }

  // Analyze code quality metrics
  Map<String, dynamic> _analyzeCodeQuality() {
    final totalStars = _repositories.fold<int>(
      0,
      (sum, repo) => sum + (repo.stars ?? 0),
    );
    final totalForks = _repositories.fold<int>(
      0,
      (sum, repo) => sum + (repo.forks ?? 0),
    );
    final reposWithDescription = _repositories
        .where(
          (repo) => repo.description != null && repo.description.isNotEmpty,
        )
        .length;

    return {
      'avgStars': _repositories.isNotEmpty
          ? totalStars / _repositories.length
          : 0.0,
      'avgForks': _repositories.isNotEmpty
          ? totalForks / _repositories.length
          : 0.0,
      'descriptionRatio': _repositories.isNotEmpty
          ? reposWithDescription / _repositories.length
          : 0.0,
      'totalStars': totalStars,
      'totalForks': totalForks,
    };
  }

  // Analyze development velocity
  Map<String, dynamic> _analyzeDevelopmentVelocity() {
    // This would ideally analyze commit history, but for now we'll use repository activity
    final activeRepos = _getActiveRepositories();
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    // Estimate commits per week based on repository activity
    final recentActivity = _repositories.where((repo) {
      final updatedAt = DateTime.tryParse((repo.updatedAt ?? '') as String);
      return updatedAt != null && updatedAt.isAfter(oneWeekAgo);
    }).length;

    return {
      'commitsPerWeek': recentActivity * 2, // Rough estimate
      'activeRepositories': activeRepos,
      'recentActivity': recentActivity,
    };
  }

  // Analyze issue management
  Map<String, dynamic> _analyzeIssueManagement() {
    int totalOpenIssues = 0;
    int totalClosedIssues = 0;

    for (final repo in _repositories) {
      totalOpenIssues += repo.openIssuesCount ?? 0;
      // Estimate closed issues (this would ideally come from API)
      totalClosedIssues += (repo.openIssuesCount ?? 0) * 2; // Rough estimate
    }

    final totalIssues = totalOpenIssues + totalClosedIssues;
    final openIssueRatio = totalIssues > 0
        ? totalOpenIssues / totalIssues
        : 0.0;

    return {
      'totalOpenIssues': totalOpenIssues,
      'totalClosedIssues': totalClosedIssues,
      'openIssueRatio': openIssueRatio,
    };
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
