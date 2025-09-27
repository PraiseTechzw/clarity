import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import 'client_details_screen.dart';
import 'project_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SearchCategory _selectedCategory = SearchCategory.all;
  List<String> _searchHistory = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter Results',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Category Filter
          _buildCategoryFilter(),

          // Search Results
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search projects, clients, notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {
                    // TODO: Implement voice search
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice search coming soon!'),
                      ),
                    );
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          // Trigger search on enter
          setState(() {
            _searchQuery = value;
            _addToSearchHistory(value);
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: SearchCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                _getCategoryLabel(category),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              elevation: isSelected ? 2 : 0,
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildEmptySearchState();
    }

    return Consumer<ProjectProvider>(
      builder: (context, provider, child) {
        final results = _getSearchResults(provider);

        if (results.isEmpty) {
          return _buildNoResultsState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSearchResultCard(result),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptySearchState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Search Everything',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search across projects, clients, and notes to find what you\'re looking for',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Search History
              if (_searchHistory.isNotEmpty) ...[
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _searchHistory
                      .map((history) => _buildSearchHistoryChip(history))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              // Quick Suggestions
              Text(
                'Quick Suggestions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSearchSuggestion('Recent projects'),
                  _buildSearchSuggestion('Client names'),
                  _buildSearchSuggestion('Project notes'),
                  _buildSearchSuggestion('High priority'),
                  _buildSearchSuggestion('Overdue tasks'),
                  _buildSearchSuggestion('Payment pending'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestion(String suggestion) {
    return ActionChip(
      label: Text(
        suggestion,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        setState(() {
          _searchQuery = suggestion;
          _searchController.text = suggestion;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
      ),
      elevation: 1,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
    );
  }

  Widget _buildSearchHistoryChip(String history) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _searchQuery = history;
            _searchController.text = history;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                history,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchHistory.remove(history);
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No Results Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search terms or filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Card(
      elevation: 3,
      shadowColor: _getResultColor(result.type).withOpacity(0.2),
      child: InkWell(
        onTap: () => _navigateToResult(result),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getResultColor(result.type).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getResultColor(result.type).withOpacity(0.1),
                        _getResultColor(result.type).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getResultColor(result.type).withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    _getResultIcon(result.type),
                    color: _getResultColor(result.type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getResultColor(
                                result.type,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getResultColor(
                                  result.type,
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getResultIcon(result.type),
                                  size: 14,
                                  color: _getResultColor(result.type),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getResultTypeLabel(result.type),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: _getResultColor(result.type),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SearchResult> _getSearchResults(ProjectProvider provider) {
    final query = _searchQuery.toLowerCase();
    List<SearchResult> results = [];

    // Search projects
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.projects) {
      for (final project in provider.projects) {
        if (_matchesQuery(project.name, query) ||
            _matchesQuery(project.clientName, query) ||
            _matchesQuery(project.notes ?? '', query)) {
          results.add(
            SearchResult(
              type: SearchResultType.project,
              id: project.id,
              title: project.name,
              subtitle:
                  '${project.clientName} • \$${project.budget.toStringAsFixed(0)}',
              data: project,
            ),
          );
        }
      }
    }

    // Search clients
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.clients) {
      for (final client in provider.clients) {
        if (_matchesQuery(client.name, query) ||
            _matchesQuery(client.company ?? '', query) ||
            _matchesQuery(client.email ?? '', query)) {
          results.add(
            SearchResult(
              type: SearchResultType.client,
              id: client.id,
              title: client.name,
              subtitle: client.company ?? client.email ?? 'No company info',
              data: client,
            ),
          );
        }
      }
    }

    return results;
  }

  bool _matchesQuery(String text, String query) {
    return text.toLowerCase().contains(query);
  }

  void _navigateToResult(SearchResult result) {
    switch (result.type) {
      case SearchResultType.project:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ProjectDetailsScreen(project: result.data as Project),
          ),
        );
        break;
      case SearchResultType.client:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ClientDetailsScreen(client: result.data as Client),
          ),
        );
        break;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search Filters',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...SearchCategory.values.map((category) {
              return ListTile(
                title: Text(_getCategoryLabel(category)),
                leading: Radio<SearchCategory>(
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(SearchCategory category) {
    switch (category) {
      case SearchCategory.all:
        return 'All';
      case SearchCategory.projects:
        return 'Projects';
      case SearchCategory.clients:
        return 'Clients';
    }
  }

  String _getResultTypeLabel(SearchResultType type) {
    switch (type) {
      case SearchResultType.project:
        return 'Project';
      case SearchResultType.client:
        return 'Client';
    }
  }

  IconData _getResultIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.project:
        return Icons.folder;
      case SearchResultType.client:
        return Icons.person;
    }
  }

  Color _getResultColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.project:
        return Theme.of(context).colorScheme.primary;
      case SearchResultType.client:
        return Colors.blue;
    }
  }

  void _addToSearchHistory(String query) {
    if (query.trim().isNotEmpty && !_searchHistory.contains(query.trim())) {
      setState(() {
        _searchHistory.insert(0, query.trim());
        if (_searchHistory.length > 5) {
          _searchHistory = _searchHistory.take(5).toList();
        }
      });
    }
  }
}

enum SearchCategory { all, projects, clients }

enum SearchResultType { project, client }

class SearchResult {
  final SearchResultType type;
  final String id;
  final String title;
  final String subtitle;
  final dynamic data;

  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
  });
}
