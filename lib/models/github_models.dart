class GitHubRepository {
  final String id;
  final String name;
  final String fullName;
  final String description;
  final String htmlUrl;
  final String cloneUrl;
  final String language;
  final int stars;
  final int forks;
  final int watchers;
  final bool isPrivate;
  final bool isFork;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime pushedAt;
  final String defaultBranch;
  final int openIssuesCount;
  final int size;
  final Map<String, int>? languages;
  final GitHubUser owner;

  GitHubRepository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.htmlUrl,
    required this.cloneUrl,
    required this.language,
    required this.stars,
    required this.forks,
    required this.watchers,
    required this.isPrivate,
    required this.isFork,
    required this.createdAt,
    required this.updatedAt,
    required this.pushedAt,
    required this.defaultBranch,
    required this.openIssuesCount,
    required this.size,
    this.languages,
    required this.owner,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      description: json['description'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      cloneUrl: json['clone_url'] ?? '',
      language: json['language'] ?? '',
      stars: json['stargazers_count'] ?? 0,
      forks: json['forks_count'] ?? 0,
      watchers: json['watchers_count'] ?? 0,
      isPrivate: json['private'] ?? false,
      isFork: json['fork'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      pushedAt: DateTime.parse(
        json['pushed_at'] ?? DateTime.now().toIso8601String(),
      ),
      defaultBranch: json['default_branch'] ?? 'main',
      openIssuesCount: json['open_issues_count'] ?? 0,
      size: json['size'] ?? 0,
      languages: json['languages'] != null
          ? Map<String, int>.from(json['languages'])
          : null,
      owner: GitHubUser.fromJson(json['owner'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'html_url': htmlUrl,
      'clone_url': cloneUrl,
      'language': language,
      'stargazers_count': stars,
      'forks_count': forks,
      'watchers_count': watchers,
      'private': isPrivate,
      'fork': isFork,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pushed_at': pushedAt.toIso8601String(),
      'default_branch': defaultBranch,
      'open_issues_count': openIssuesCount,
      'size': size,
      'languages': languages,
      'owner': owner.toJson(),
    };
  }
}

class GitHubUser {
  final String id;
  final String login;
  final String name;
  final String email;
  final String avatarUrl;
  final String htmlUrl;
  final String bio;
  final String company;
  final String location;
  final String blog;
  final int publicRepos;
  final int publicGists;
  final int followers;
  final int following;
  final DateTime createdAt;
  final DateTime updatedAt;

  GitHubUser({
    required this.id,
    required this.login,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.bio,
    required this.company,
    required this.location,
    required this.blog,
    required this.publicRepos,
    required this.publicGists,
    required this.followers,
    required this.following,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'].toString(),
      login: json['login'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      bio: json['bio'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      blog: json['blog'] ?? '',
      publicRepos: json['public_repos'] ?? 0,
      publicGists: json['public_gists'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'bio': bio,
      'company': company,
      'location': location,
      'blog': blog,
      'public_repos': publicRepos,
      'public_gists': publicGists,
      'followers': followers,
      'following': following,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class GitHubCommit {
  final String sha;
  final String message;
  final String htmlUrl;
  final GitHubUser author;
  final GitHubUser committer;
  final DateTime date;
  final int additions;
  final int deletions;
  final int changes;
  final List<String> files;

  GitHubCommit({
    required this.sha,
    required this.message,
    required this.htmlUrl,
    required this.author,
    required this.committer,
    required this.date,
    required this.additions,
    required this.deletions,
    required this.changes,
    required this.files,
  });

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    return GitHubCommit(
      sha: json['sha'] ?? '',
      message: json['commit']?['message'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      author: GitHubUser.fromJson(json['author'] ?? {}),
      committer: GitHubUser.fromJson(json['committer'] ?? {}),
      date: DateTime.parse(
        json['commit']?['author']?['date'] ?? DateTime.now().toIso8601String(),
      ),
      additions: json['stats']?['additions'] ?? 0,
      deletions: json['stats']?['deletions'] ?? 0,
      changes: json['stats']?['total'] ?? 0,
      files: (json['files'] as List<dynamic>? ?? [])
          .map((file) => file['filename'] as String? ?? '')
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sha': sha,
      'message': message,
      'html_url': htmlUrl,
      'author': author.toJson(),
      'committer': committer.toJson(),
      'date': date.toIso8601String(),
      'additions': additions,
      'deletions': deletions,
      'changes': changes,
      'files': files,
    };
  }
}

class GitHubIssue {
  final String id;
  final String number;
  final String title;
  final String body;
  final String state;
  final String htmlUrl;
  final GitHubUser user;
  final List<String> labels;
  final List<GitHubUser> assignees;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final int comments;

  GitHubIssue({
    required this.id,
    required this.number,
    required this.title,
    required this.body,
    required this.state,
    required this.htmlUrl,
    required this.user,
    required this.labels,
    required this.assignees,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    required this.comments,
  });

  factory GitHubIssue.fromJson(Map<String, dynamic> json) {
    return GitHubIssue(
      id: json['id'].toString(),
      number: json['number'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      state: json['state'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      user: GitHubUser.fromJson(json['user'] ?? {}),
      labels: (json['labels'] as List<dynamic>? ?? [])
          .map((label) => label['name'] as String? ?? '')
          .toList(),
      assignees: (json['assignees'] as List<dynamic>? ?? [])
          .map((assignee) => GitHubUser.fromJson(assignee))
          .toList(),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
      comments: json['comments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'body': body,
      'state': state,
      'html_url': htmlUrl,
      'user': user.toJson(),
      'labels': labels,
      'assignees': assignees.map((assignee) => assignee.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'comments': comments,
    };
  }
}

class GitHubPullRequest {
  final String id;
  final String number;
  final String title;
  final String body;
  final String state;
  final String htmlUrl;
  final GitHubUser user;
  final GitHubUser? mergedBy;
  final List<String> labels;
  final List<GitHubUser> assignees;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? mergedAt;
  final DateTime? closedAt;
  final int additions;
  final int deletions;
  final int changedFiles;
  final int comments;
  final int reviewComments;
  final String headRef;
  final String baseRef;

  GitHubPullRequest({
    required this.id,
    required this.number,
    required this.title,
    required this.body,
    required this.state,
    required this.htmlUrl,
    required this.user,
    this.mergedBy,
    required this.labels,
    required this.assignees,
    required this.createdAt,
    required this.updatedAt,
    this.mergedAt,
    this.closedAt,
    required this.additions,
    required this.deletions,
    required this.changedFiles,
    required this.comments,
    required this.reviewComments,
    required this.headRef,
    required this.baseRef,
  });

  factory GitHubPullRequest.fromJson(Map<String, dynamic> json) {
    return GitHubPullRequest(
      id: json['id'].toString(),
      number: json['number'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      state: json['state'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      user: GitHubUser.fromJson(json['user'] ?? {}),
      mergedBy: json['merged_by'] != null
          ? GitHubUser.fromJson(json['merged_by'])
          : null,
      labels: (json['labels'] as List<dynamic>? ?? [])
          .map((label) => label['name'] as String? ?? '')
          .toList(),
      assignees: (json['assignees'] as List<dynamic>? ?? [])
          .map((assignee) => GitHubUser.fromJson(assignee))
          .toList(),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      mergedAt: json['merged_at'] != null
          ? DateTime.parse(json['merged_at'])
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
      additions: json['additions'] ?? 0,
      deletions: json['deletions'] ?? 0,
      changedFiles: json['changed_files'] ?? 0,
      comments: json['comments'] ?? 0,
      reviewComments: json['review_comments'] ?? 0,
      headRef: json['head']?['ref'] ?? '',
      baseRef: json['base']?['ref'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'body': body,
      'state': state,
      'html_url': htmlUrl,
      'user': user.toJson(),
      'merged_by': mergedBy?.toJson(),
      'labels': labels,
      'assignees': assignees.map((assignee) => assignee.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'merged_at': mergedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'additions': additions,
      'deletions': deletions,
      'changed_files': changedFiles,
      'comments': comments,
      'review_comments': reviewComments,
      'head_ref': headRef,
      'base_ref': baseRef,
    };
  }
}

class GitHubStats {
  final int totalCommits;
  final int totalAdditions;
  final int totalDeletions;
  final int totalIssues;
  final int openIssues;
  final int closedIssues;
  final int totalPullRequests;
  final int openPullRequests;
  final int mergedPullRequests;
  final int closedPullRequests;
  final Map<String, int> languages;
  final List<Map<String, dynamic>> commitActivity;
  final int contributors;

  GitHubStats({
    required this.totalCommits,
    required this.totalAdditions,
    required this.totalDeletions,
    required this.totalIssues,
    required this.openIssues,
    required this.closedIssues,
    required this.totalPullRequests,
    required this.openPullRequests,
    required this.mergedPullRequests,
    required this.closedPullRequests,
    required this.languages,
    required this.commitActivity,
    required this.contributors,
  });

  factory GitHubStats.fromJson(Map<String, dynamic> json) {
    return GitHubStats(
      totalCommits: json['totalCommits'] ?? 0,
      totalAdditions: json['totalAdditions'] ?? 0,
      totalDeletions: json['totalDeletions'] ?? 0,
      totalIssues: json['totalIssues'] ?? 0,
      openIssues: json['openIssues'] ?? 0,
      closedIssues: json['closedIssues'] ?? 0,
      totalPullRequests: json['totalPullRequests'] ?? 0,
      openPullRequests: json['openPullRequests'] ?? 0,
      mergedPullRequests: json['mergedPullRequests'] ?? 0,
      closedPullRequests: json['closedPullRequests'] ?? 0,
      languages: Map<String, int>.from(json['languages'] ?? {}),
      commitActivity: List<Map<String, dynamic>>.from(
        json['commitActivity'] ?? [],
      ),
      contributors: json['contributors'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCommits': totalCommits,
      'totalAdditions': totalAdditions,
      'totalDeletions': totalDeletions,
      'totalIssues': totalIssues,
      'openIssues': openIssues,
      'closedIssues': closedIssues,
      'totalPullRequests': totalPullRequests,
      'openPullRequests': openPullRequests,
      'mergedPullRequests': mergedPullRequests,
      'closedPullRequests': closedPullRequests,
      'languages': languages,
      'commitActivity': commitActivity,
      'contributors': contributors,
    };
  }
}
