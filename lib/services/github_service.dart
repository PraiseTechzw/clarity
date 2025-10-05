import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  String? _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'Clarity-App/1.0',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'token $_accessToken';
    }

    return headers;
  }

  // Get user profile information
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Get user repositories
  Future<List<Map<String, dynamic>>> getUserRepositories({
    String sort = 'updated',
    String direction = 'desc',
    int perPage = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/user/repos?sort=$sort&direction=$direction&per_page=$perPage',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> repos = json.decode(response.body);
        return repos.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching repositories: $e');
      return [];
    }
  }

  // Get repository details
  Future<Map<String, dynamic>?> getRepository(String owner, String repo) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching repository: $e');
      return null;
    }
  }

  // Get repository commits
  Future<List<Map<String, dynamic>>> getRepositoryCommits(
    String owner,
    String repo, {
    String? since,
    String? until,
    int perPage = 30,
  }) async {
    try {
      String url = '$_baseUrl/repos/$owner/$repo/commits?per_page=$perPage';
      if (since != null) url += '&since=$since';
      if (until != null) url += '&until=$until';

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> commits = json.decode(response.body);
        return commits.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching commits: $e');
      return [];
    }
  }

  // Get repository issues
  Future<List<Map<String, dynamic>>> getRepositoryIssues(
    String owner,
    String repo, {
    String state = 'all',
    String sort = 'updated',
    String direction = 'desc',
    int perPage = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/repos/$owner/$repo/issues?state=$state&sort=$sort&direction=$direction&per_page=$perPage',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> issues = json.decode(response.body);
        return issues.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching issues: $e');
      return [];
    }
  }

  // Get repository pull requests
  Future<List<Map<String, dynamic>>> getRepositoryPullRequests(
    String owner,
    String repo, {
    String state = 'all',
    String sort = 'updated',
    String direction = 'desc',
    int perPage = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/repos/$owner/$repo/pulls?state=$state&sort=$sort&direction=$direction&per_page=$perPage',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> prs = json.decode(response.body);
        return prs.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching pull requests: $e');
      return [];
    }
  }

  // Get repository statistics
  Future<Map<String, dynamic>?> getRepositoryStats(
    String owner,
    String repo,
  ) async {
    try {
      // Get contributors
      final contributorsResponse = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/contributors'),
        headers: _headers,
      );

      // Get languages
      final languagesResponse = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/languages'),
        headers: _headers,
      );

      // Get commit activity
      final activityResponse = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/stats/commit_activity'),
        headers: _headers,
      );

      Map<String, dynamic> stats = {};

      if (contributorsResponse.statusCode == 200) {
        final List<dynamic> contributors = json.decode(
          contributorsResponse.body,
        );
        stats['contributors'] = contributors.length;
        stats['totalContributions'] = contributors.fold<int>(
          0,
          (sum, contributor) =>
              sum + (contributor['contributions'] as int? ?? 0),
        );
      }

      if (languagesResponse.statusCode == 200) {
        stats['languages'] = json.decode(languagesResponse.body);
      }

      if (activityResponse.statusCode == 200) {
        final List<dynamic> activity = json.decode(activityResponse.body);
        stats['commitActivity'] = activity;
      }

      return stats;
    } catch (e) {
      print('Error fetching repository stats: $e');
      return null;
    }
  }

  // Search repositories
  Future<List<Map<String, dynamic>>> searchRepositories(
    String query, {
    String sort = 'updated',
    String order = 'desc',
    int perPage = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/repositories?q=${Uri.encodeComponent(query)}&sort=$sort&order=$order&per_page=$perPage',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error searching repositories: $e');
      return [];
    }
  }

  // Get user's organizations
  Future<List<Map<String, dynamic>>> getUserOrganizations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/orgs'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> orgs = json.decode(response.body);
        return orgs.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching organizations: $e');
      return [];
    }
  }

  // Get repository branches
  Future<List<Map<String, dynamic>>> getRepositoryBranches(
    String owner,
    String repo,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/branches'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> branches = json.decode(response.body);
        return branches.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching branches: $e');
      return [];
    }
  }

  // Get repository releases
  Future<List<Map<String, dynamic>>> getRepositoryReleases(
    String owner,
    String repo,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/releases'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = json.decode(response.body);
        return releases.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching releases: $e');
      return [];
    }
  }

  // Check if repository exists and is accessible
  Future<bool> isRepositoryAccessible(String owner, String repo) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get repository content (files and folders)
  Future<List<Map<String, dynamic>>> getRepositoryContent(
    String owner,
    String repo, {
    String path = '',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> content = json.decode(response.body);
        return content.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching repository content: $e');
      return [];
    }
  }
}
