import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/client_card.dart';
import 'add_client_screen.dart';
import 'client_details_screen.dart';
import 'search_screen.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _navigateToSearch,
            tooltip: 'Search',
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.error}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        provider.loadClients();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredClients = _getFilteredClients(
            provider.clients,
            provider.projects,
          );

          if (filteredClients.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadClients(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredClients.length,
              itemBuilder: (context, index) {
                final client = filteredClients[index];
                final clientProjects = provider.projects
                    .where((project) => project.clientName == client.name)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClientCard(
                    client: client,
                    projects: clientProjects,
                    onTap: () =>
                        _navigateToClientDetails(client, clientProjects),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_client_fab",
        onPressed: _navigateToAddClient,
        icon: const Icon(Icons.add),
        label: const Text('Add Client'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Clients Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first client to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddClient,
            icon: const Icon(Icons.add),
            label: const Text('Add Client'),
          ),
        ],
      ),
    );
  }

  List<Client> _getFilteredClients(
    List<Client> clients,
    List<Project> projects,
  ) {
    if (_searchQuery.isEmpty) return clients;

    final query = _searchQuery.toLowerCase();
    return clients.where((client) {
      return client.name.toLowerCase().contains(query) ||
          (client.email != null &&
              client.email!.toLowerCase().contains(query)) ||
          (client.company != null &&
              client.company!.toLowerCase().contains(query));
    }).toList();
  }

  void _navigateToSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
  }

  void _navigateToAddClient() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddClientScreen()));
  }

  void _navigateToClientDetails(Client client, List<Project> projects) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClientDetailsScreen(client: client),
      ),
    );
  }
}
